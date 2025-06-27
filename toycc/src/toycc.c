/*
 * ToyCC – 教育用CPU向けの簡易コンパイラ
 * 変数宣言や配列、if/while、入出力などを支援する
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_SYMS 256
#define MAX_LABELS 256
#define MAX_PATCHES 512
#define MAX_CODE 1024

/* hidden scratch locations used for array assignments */
#define TMP_IDX_ADDR 0xFE
#define TMP_VAL_ADDR 0xFF

/* シンボル(変数)情報 */
typedef struct {
    char name[32];
    int addr;
    int size;
    int defined;
} Symbol;

/* ラベル情報 */
typedef struct {
    char name[32];
    int addr;
    int defined;
} Label;

/* 未解決ジャンプのパッチ位置 */
typedef struct {
    int label;
    int pos;
} Patch;

/* 変数テーブル */
static Symbol symbols[MAX_SYMS];
static int sym_count = 0;
static int next_addr = 0x100; /* 次に割り当てるアドレス */

/* ラベルおよびパッチ管理 */
static Label labels[MAX_LABELS];
static int label_count = 0;
static Patch patches[MAX_PATCHES];
static int patch_count = 0;

/* データ領域の初期値 */
static unsigned char init_data[0x100];

/* 生成されるバイトコード */
static unsigned char code[MAX_CODE];
static int code_len = 0;
static int temp_label_id = 0; /* 自動生成ラベル */

/* シンボル名からエントリを検索 */
static int find_symbol(const char *name)
{
    for (int i = 0; i < sym_count; i++) {
        if (strcmp(symbols[i].name, name) == 0)
            return i;
    }
    return -1;
}

/* 新しいシンボルを登録 */
static int add_symbol(const char *name, int size)
{
    if (sym_count >= MAX_SYMS) {
        fprintf(stderr, "symbol table full\n");
        exit(1);
    }
    strcpy(symbols[sym_count].name, name);
    symbols[sym_count].addr = next_addr;
    symbols[sym_count].size = size;
    for (int i = 0; i < size; i++) {
        init_data[next_addr - 0x100 + i] = 0;
    }
    next_addr += size;
    symbols[sym_count].defined = 1;
    return sym_count++;
}

/* シンボルのアドレス取得 */
static int get_symbol_addr(const char *name)
{
    int idx = find_symbol(name);
    if (idx < 0) {
        fprintf(stderr, "undefined variable: %s\n", name);
        exit(1);
    }
    return symbols[idx].addr;
}

/* ラベルを検索 */
static int find_label(const char *name)
{
    for (int i = 0; i < label_count; i++) {
        if (strcmp(labels[i].name, name) == 0)
            return i;
    }
    return -1;
}

/* ラベルを取得、なければ作成 */
static int get_label(const char *name)
{
    int idx = find_label(name);
    if (idx >= 0)
        return idx;
    if (label_count >= MAX_LABELS) {
        fprintf(stderr, "label table full\n");
        exit(1);
    }
    strcpy(labels[label_count].name, name);
    labels[label_count].defined = 0;
    labels[label_count].addr = 0;
    return label_count++;
}

/* 後で埋め込むラベル参照を登録 */
static void add_patch(int label_idx, int pos)
{
    if (patch_count >= MAX_PATCHES) {
        fprintf(stderr, "too many patches\n");
        exit(1);
    }
    patches[patch_count].label = label_idx;
    patches[patch_count].pos = pos;
    patch_count++;
}

/* ラベル定義。対応するパッチを解決 */
static void define_label(const char *name, int addr)
{
    int idx = get_label(name);
    if (labels[idx].defined) {
        fprintf(stderr, "label redefined: %s\n", name);
        exit(1);
    }
    labels[idx].addr = addr & 0xFF;
    labels[idx].defined = 1;
    for (int i = 0; i < patch_count; i++) {
        if (patches[i].label == idx && code[patches[i].pos] == 0xFF) {
            code[patches[i].pos] = labels[idx].addr;
        }
    }
}

/* まだ残っているパッチを解決 */
static void resolve_patches(void)
{
    for (int i = 0; i < patch_count; i++) {
        int idx = patches[i].label;
        if (!labels[idx].defined) {
            fprintf(stderr, "undefined label: %s\n", labels[idx].name);
            exit(1);
        }
        if (code[patches[i].pos] == 0xFF)
            code[patches[i].pos] = labels[idx].addr;
    }
}

/* バイトコードを出力 */
static void emit(unsigned char byte)
{
    if (code_len >= MAX_CODE) {
        fprintf(stderr, "code too large\n");
        exit(1);
    }
    code[code_len++] = byte;
}

/* 空白文字を読み飛ばす */
static void parse_ws(FILE *fp)
{
    int c;
    while ((c = fgetc(fp)) != EOF) {
        if (!isspace(c)) {
            ungetc(c, fp);
            break;
        }
    }
}

/* 数値を読み取る */
static int parse_number(FILE *fp)
{
    int c = fgetc(fp);
    int val = 0;
    int base = 10;
    if (c == '0') {
        int c2 = fgetc(fp);
        if (c2 == 'x' || c2 == 'X') {
            base = 16;
            c = fgetc(fp);
        } else {
            if (c2 != EOF) ungetc(c2, fp);
        }
    }
    while (c != EOF && (isdigit(c) || (base == 16 && isxdigit(c)))) {
        int digit;
        if (isdigit(c)) digit = c - '0';
        else digit = (tolower(c) - 'a' + 10);
        val = val * base + digit;
        c = fgetc(fp);
    }
    if (c != EOF) ungetc(c, fp);
    return val & 0xFF;
}

/* 識別子を読み取る */
static void parse_ident(FILE *fp, char *buf)
{
    int c, i = 0;
    while ((c = fgetc(fp)) != EOF && (isalnum(c) || c == '_')) {
        buf[i++] = c;
    }
    if (c != EOF) ungetc(c, fp);
    buf[i] = '\0';
}

/* 次の文字が期待したものか確認 */
static void expect(FILE *fp, char ch)
{
    parse_ws(fp);
    int c = fgetc(fp);
    if (c != ch) {
        fprintf(stderr, "expected '%c'\n", ch);
        exit(1);
    }
}

/* 変数宣言を解析 */
static void parse_decl(FILE *fp)
{
    char ident[32];
    parse_ws(fp);
    parse_ident(fp, ident);
    int size = 1;
    parse_ws(fp);
    int c = fgetc(fp);
    if (c == '[') {
        parse_ws(fp);
        size = parse_number(fp);
        parse_ws(fp);
        expect(fp, ']');
    } else {
        ungetc(c, fp);
    }
    add_symbol(ident, size);
    parse_ws(fp);
    expect(fp, ';');
}

static void emit_expression(FILE *fp); /* forward */

/* 値(変数/即値/配列要素)をACCへロード */
static void emit_load_term(FILE *fp)
{
    int c = fgetc(fp);
    if (isalpha(c)) {
        char id[32];
        ungetc(c, fp);
        parse_ident(fp, id);
        parse_ws(fp);
        c = fgetc(fp);
        if (c == '[') {
            parse_ws(fp);
            emit_expression(fp); /* index -> ACC */
            parse_ws(fp);
            expect(fp, ']');
            int base = get_symbol_addr(id);
            emit(0xB2); emit(base & 0xFF);
            emit(0x68);
            emit(0x67); emit(0x00);
        } else {
            ungetc(c, fp);
            int addr = get_symbol_addr(id);
            emit(0x65); emit(addr & 0xFF);
        }
    } else if (isdigit(c)) {
        ungetc(c, fp);
        int val = parse_number(fp);
        emit(0x62); emit(val & 0xFF);
    } else {
        fprintf(stderr, "invalid term\n");
        exit(1);
    }
}

/* 足し算・引き算のみを扱う簡易式 */
static void emit_expression(FILE *fp)
{
    emit_load_term(fp);
    parse_ws(fp);
    int c = fgetc(fp);
    if (c == '+' || c == '-') {
        int is_add = (c == '+');
        parse_ws(fp);
        c = fgetc(fp);
        if (isalpha(c)) {
            char id[32];
            ungetc(c, fp);
            parse_ident(fp, id);
            int addr = get_symbol_addr(id);
            if (is_add) { emit(0xB5); emit(addr & 0xFF); }
            else { emit(0xA5); emit(addr & 0xFF); }
        } else if (isdigit(c)) {
            ungetc(c, fp);
            int val = parse_number(fp);
            if (is_add) { emit(0xB2); emit(val & 0xFF); }
            else { emit(0xA2); emit(val & 0xFF); }
        } else { fprintf(stderr, "invalid expression\n"); exit(1); }
    } else {
        ungetc(c, fp);
    }
}

static void emit_expression_str(const char *s)
{
    FILE *tmp = fmemopen((void *)s, strlen(s), "r");
    if (!tmp) { perror("fmemopen"); exit(1); }
    emit_expression(tmp);
    fclose(tmp);
}

/* 単純な代入文の解析 */
static void parse_assign(FILE *fp, const char *name)
{
    int addr = get_symbol_addr(name);
    parse_ws(fp);
    expect(fp, '=');
    parse_ws(fp);
    emit_expression(fp);
    parse_ws(fp);
    expect(fp, ';');
    emit(0x75); emit(addr & 0xFF);
}

/* 配列要素への代入 */
static void parse_assign_array(FILE *fp, const char *name)
{
    int base = get_symbol_addr(name);
    expect(fp, '[');
    parse_ws(fp);
    emit_expression(fp);                /* index -> ACC */
    emit(0x75); emit(TMP_IDX_ADDR);     /* save index */
    parse_ws(fp);
    expect(fp, ']');
    parse_ws(fp);
    expect(fp, '=');
    parse_ws(fp);
    emit_expression(fp);                /* value -> ACC */
    emit(0x75); emit(TMP_VAL_ADDR);     /* save value */
    emit(0x65); emit(TMP_IDX_ADDR);     /* reload index */
    emit(0xB2); emit(base & 0xFF);      /* add base */
    emit(0x68);                         /* ACC -> IX */
    emit(0x65); emit(TMP_VAL_ADDR);     /* reload value */
    parse_ws(fp);
    expect(fp, ';');
    emit(0x77); emit(0x00);             /* ST ACC, (IX+0) */
}

typedef struct {
    char id[32];
    int num;
    int is_num;
    int is_array;
    char idx[64];
} Term;

typedef struct {
    Term lhs;
    Term rhs;
    char op[3];
} Condition;

static void parse_term(FILE *fp, Term *t)
{
    int c = fgetc(fp);
    t->is_array = 0;
    if (isalpha(c)) {
        ungetc(c, fp);
        parse_ident(fp, t->id);
        t->is_num = 0;
        parse_ws(fp);
        c = fgetc(fp);
        if (c == '[') {
            int i = 0;
            parse_ws(fp);
            while ((c = fgetc(fp)) != EOF && c != ']') {
                t->idx[i++] = c;
            }
            t->idx[i] = '\0';
            t->is_array = 1;
        } else {
            ungetc(c, fp);
        }
    } else if (isdigit(c)) {
        ungetc(c, fp);
        t->num = parse_number(fp);
        t->is_num = 1;
    } else {
        fprintf(stderr, "invalid term\n");
        exit(1);
    }
}

static void parse_condition(FILE *fp, Condition *cond)
{
    expect(fp, '(');
    parse_ws(fp);
    parse_term(fp, &cond->lhs);
    parse_ws(fp);
    char op[3];
    int c = fgetc(fp);
    if (c == '<' || c == '>' || c == '!') {
        op[0] = c;
        c = fgetc(fp);
        if (c == '=') { op[1] = '='; op[2] = '\0'; }
        else { ungetc(c, fp); op[1] = '\0'; }
    } else if (c == '=') {
        expect(fp, '=');
        strcpy(op, "==");
    } else {
        fprintf(stderr, "invalid operator\n");
        exit(1);
    }
    strcpy(cond->op, op);
    parse_ws(fp);
    parse_term(fp, &cond->rhs);
    parse_ws(fp);
    expect(fp, ')');
}

static void emit_load_cond_lhs(const Condition *c)
{
    if (c->lhs.is_num) {
        emit(0x62); emit(c->lhs.num & 0xFF);
    } else if (c->lhs.is_array) {
        emit_expression_str(c->lhs.idx);        /* index -> ACC */
        int base = get_symbol_addr(c->lhs.id);
        emit(0xB2); emit(base & 0xFF);
        emit(0x68);
        emit(0x67); emit(0x00);
    } else {
        int addr = get_symbol_addr(c->lhs.id);
        emit(0x65); emit(addr & 0xFF);
    }
}

static void emit_cmp_with_rhs(const Condition *c)
{
    if (c->rhs.is_num) {
        emit(0xF2); emit(c->rhs.num & 0xFF);
    } else if (c->rhs.is_array) {
        /* preserve ACC containing lhs value */
        emit(0x75); emit(TMP_VAL_ADDR);
        emit_expression_str(c->rhs.idx);    /* index -> ACC */
        int base = get_symbol_addr(c->rhs.id);
        emit(0xB2); emit(base & 0xFF);
        emit(0x68);                           /* ACC -> IX */
        emit(0x65); emit(TMP_VAL_ADDR);       /* restore lhs */
        emit(0xF7); emit(0x00);               /* CMP ACC,(IX+0) */
    } else {
        int addr = get_symbol_addr(c->rhs.id);
        emit(0xF5); emit(addr & 0xFF);
    }
}

static int branch_code(const char *op, int invert)
{
    if (!invert) {
        if (strcmp(op, "==") == 0) return 0x9; /* BZ */
        if (strcmp(op, "!=") == 0) return 0x1; /* BNZ */
        if (strcmp(op, "<") == 0) return 0xE;  /* BLT */
        if (strcmp(op, "<=") == 0) return 0xF; /* BLE */
        if (strcmp(op, ">") == 0) return 0x7; /* BGT */
        if (strcmp(op, ">=") == 0) return 0x6; /* BGE */
    } else {
        if (strcmp(op, "==") == 0) return 0x1; /* not equal */
        if (strcmp(op, "!=") == 0) return 0x9; /* equal */
        if (strcmp(op, "<") == 0) return 0x6;  /* >= */
        if (strcmp(op, "<=") == 0) return 0x7; /* > */
        if (strcmp(op, ">") == 0) return 0xF; /* <= */
        if (strcmp(op, ">=") == 0) return 0xE; /* < */
    }
    return 0x0;
}

static void emit_branch(int bc, const char *label)
{
    emit(0x30 | (bc & 0x0F));
    int idx = get_label(label);
    if (labels[idx].defined) {
        emit(labels[idx].addr & 0xFF);
    } else {
        emit(0xFF); /* placeholder */
        add_patch(idx, code_len - 1);
    }
}

static void emit_cond_branch(const Condition *cond, const char *label, int invert)
{
    emit_load_cond_lhs(cond);
    emit_cmp_with_rhs(cond);
    int bc = branch_code(cond->op, invert);
    emit_branch(bc, label);
}

static void parse_block(FILE *fp); /* forward */

static void ungets(FILE *fp, const char *s)
{
    for (int i = strlen(s) - 1; i >= 0; i--) {
        ungetc(s[i], fp);
    }
}

static void parse_if(FILE *fp)
{
    Condition cond;
    parse_ws(fp);
    parse_condition(fp, &cond);
    parse_ws(fp);
    expect(fp, '{');

    char else_label[32];
    char end_label[32];
    sprintf(else_label, "@IFELSE%d", temp_label_id);
    sprintf(end_label, "@IFEND%d", temp_label_id++);

    emit_cond_branch(&cond, else_label, 1); /* if !cond -> else */
    parse_block(fp);                 /* if-block */

    parse_ws(fp);
    char buf[32] = {0};
    int c = fgetc(fp);
    if (c != EOF && isalpha(c)) {
        ungetc(c, fp);
        parse_ident(fp, buf);
    } else if (c != EOF) {
        ungetc(c, fp);
    }

    if (strcmp(buf, "else") == 0) {
        emit_branch(0x0, end_label); /* jump over else */
        define_label(else_label, code_len);
        parse_ws(fp);
        expect(fp, '{');
        parse_block(fp);             /* else-block */
        define_label(end_label, code_len);
    } else {
        if (buf[0] != '\0') ungets(fp, buf);
        define_label(else_label, code_len);
    }
}

static void parse_while(FILE *fp)
{
    Condition cond;
    parse_ws(fp);
    parse_condition(fp, &cond);
    parse_ws(fp);
    expect(fp, '{');
    int start = code_len;
    char end_label[32];
    sprintf(end_label, "@WEND%d", temp_label_id++);
    emit_cond_branch(&cond, end_label, 1); /* if !cond goto end */
    parse_block(fp);
    emit(0x30); /* BA */
    emit(start & 0xFF);
    define_label(end_label, code_len);
}

static void parse_out(FILE *fp)
{
    parse_ws(fp);
    emit_expression(fp);
    parse_ws(fp);
    expect(fp, ';');
    emit(0x10); /* OUT */
}

static void parse_in(FILE *fp)
{
    char id[32];
    parse_ws(fp);
    parse_ident(fp, id);
    parse_ws(fp);
    expect(fp, ';');
    emit(0x18); /* IN */
    int addr = get_symbol_addr(id);
    emit(0x75); emit(addr & 0xFF); /* store to variable */
}

/* 1行の文を解析してコード化 */
static void parse_statement(FILE *fp)
{
    parse_ws(fp);
    int c = fgetc(fp);
    if (c == EOF) return;
    if (isalpha(c)) {
        char kw[32];
        ungetc(c, fp);
        parse_ident(fp, kw);
        parse_ws(fp);
        c = fgetc(fp);
        if (c == ':') {
            define_label(kw, code_len);
            return;
        }
        ungetc(c, fp);
        if (strcmp(kw, "byte") == 0) { parse_decl(fp); return; }
        if (strcmp(kw, "if") == 0) { parse_if(fp); return; }
        if (strcmp(kw, "while") == 0) { parse_while(fp); return; }
        if (strcmp(kw, "hlt") == 0) { expect(fp, ';'); emit(0x0F); return; }
        if (strcmp(kw, "out") == 0) { parse_out(fp); return; }
        if (strcmp(kw, "in") == 0) { parse_in(fp); return; }
        parse_ws(fp);
        c = fgetc(fp);
        if (c == '[') {
            ungetc(c, fp);
            parse_assign_array(fp, kw);
        } else {
            ungetc(c, fp);
            parse_assign(fp, kw);
        }
        return;
    }
    if (c != EOF) {
        fprintf(stderr, "syntax error\n");
        exit(1);
    }
}

/* '{' から '}' までを解析 */
static void parse_block(FILE *fp)
{
    while (1) {
        parse_ws(fp);
        int c = fgetc(fp);
        if (c == EOF) { fprintf(stderr, "unexpected EOF\n" ); exit(1); }
        if (c == '}') break;
        ungetc(c, fp);
        parse_statement(fp);
    }
}

/* ソース全体を処理する */
static void parse_program(FILE *fp)
{
    while (1) {
        parse_ws(fp);
        int c = fgetc(fp);
        if (c == EOF) break;
        ungetc(c, fp);
        parse_statement(fp);
    }
}

/* バイトコードを書き出す */
static void write_output(const char *path)
{
    FILE *out = fopen(path, "w");
    if (!out) {
        perror("open output");
        exit(1);
    }
    fprintf(out, ".text 0\n");
    for (int i = 0; i < code_len; i++) {
        fprintf(out, "%02x\n", code[i]);
    }
    fprintf(out, "0f\n");
    if (next_addr > 0x100) {
        fprintf(out, ".data 0\n");
        for (int i = 0; i < next_addr - 0x100; i++) {
            fprintf(out, "%02x\n", init_data[i]);
        }
    }
    fclose(out);
}

/* エントリポイント */
int main(int argc, char **argv)
{
    if (argc != 3) {
        fprintf(stderr, "usage: %s <source> <out>\n", argv[0]);
        return 1;
    }
    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        perror("open");
        return 1;
    }
    parse_program(fp);
    fclose(fp);
    resolve_patches();
    write_output(argv[2]);
    return 0;
}

