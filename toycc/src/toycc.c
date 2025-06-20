#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_SYMS 256
#define MAX_CODE 1024

typedef struct {
    char name[32];
    int addr;
    int defined;
} Symbol;

static Symbol symbols[MAX_SYMS];
static int sym_count = 0;
static int next_addr = 0x100;

static unsigned char code[MAX_CODE];
static int code_len = 0;

static int find_symbol(const char *name)
{
    for (int i = 0; i < sym_count; i++) {
        if (strcmp(symbols[i].name, name) == 0)
            return i;
    }
    return -1;
}

static int add_symbol(const char *name)
{
    if (sym_count >= MAX_SYMS) {
        fprintf(stderr, "symbol table full\n");
        exit(1);
    }
    strcpy(symbols[sym_count].name, name);
    symbols[sym_count].addr = next_addr++;
    symbols[sym_count].defined = 1;
    return sym_count++;
}

static int get_symbol_addr(const char *name)
{
    int idx = find_symbol(name);
    if (idx < 0) {
        fprintf(stderr, "undefined variable: %s\n", name);
        exit(1);
    }
    return symbols[idx].addr;
}

static void emit(unsigned char byte)
{
    if (code_len >= MAX_CODE) {
        fprintf(stderr, "code too large\n");
        exit(1);
    }
    code[code_len++] = byte;
}

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

static int parse_number(FILE *fp)
{
    int c, val = 0;
    while ((c = fgetc(fp)) != EOF && isdigit(c)) {
        val = val * 10 + (c - '0');
    }
    if (c != EOF) ungetc(c, fp);
    return val & 0xFF;
}

static void parse_ident(FILE *fp, char *buf)
{
    int c, i = 0;
    while ((c = fgetc(fp)) != EOF && (isalnum(c) || c == '_')) {
        buf[i++] = c;
    }
    if (c != EOF) ungetc(c, fp);
    buf[i] = '\0';
}

static void expect(FILE *fp, char ch)
{
    parse_ws(fp);
    int c = fgetc(fp);
    if (c != ch) {
        fprintf(stderr, "expected '%c'\n", ch);
        exit(1);
    }
}


static void parse_decl(FILE *fp)
{
    char ident[32];
    parse_ws(fp);
    parse_ident(fp, ident);
    add_symbol(ident);
    parse_ws(fp);
    expect(fp, ';');
}

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

    char kw[32];
    while (1) {
        parse_ws(fp);
        int c = fgetc(fp);
        if (c == EOF) break;
        if (isalpha(c)) {
            ungetc(c, fp);
            parse_ident(fp, kw);
            if (strcmp(kw, "byte") == 0) {
                parse_decl(fp);
            } else {
                int addr = get_symbol_addr(kw);
                parse_ws(fp);
                expect(fp, '=');
                parse_ws(fp);
                c = fgetc(fp);
                if (isalpha(c)) {
                    char rhs[32];
                    ungetc(c, fp);
                    parse_ident(fp, rhs);
                    int raddr = get_symbol_addr(rhs);
                    emit(0x65); emit(raddr & 0xFF);
                } else if (isdigit(c)) {
                    ungetc(c, fp);
                    int val = parse_number(fp);
                    emit(0x62); emit(val & 0xFF);
                } else {
                    fprintf(stderr, "invalid expression\n");
                    exit(1);
                }

                parse_ws(fp);
                c = fgetc(fp);
                if (c == '+' || c == '-') {
                    int is_add = (c == '+');
                    parse_ws(fp);
                    c = fgetc(fp);
                    if (isalpha(c)) {
                        char rhs2[32];
                        ungetc(c, fp);
                        parse_ident(fp, rhs2);
                        int raddr2 = get_symbol_addr(rhs2);
                        if (is_add) { emit(0xB5); emit(raddr2 & 0xFF); }
                        else { emit(0xA5); emit(raddr2 & 0xFF); }
                    } else if (isdigit(c)) {
                        ungetc(c, fp);
                        int val2 = parse_number(fp);
                        if (is_add) { emit(0xB2); emit(val2 & 0xFF); }
                        else { emit(0xA2); emit(val2 & 0xFF); }
                    } else { fprintf(stderr, "invalid expression\n"); exit(1); }
                } else {
                    ungetc(c, fp);
                }
                parse_ws(fp);
                expect(fp, ';');
                emit(0x75); emit(addr & 0xFF);
            }
        } else {
            fprintf(stderr, "syntax error\n");
            exit(1);
        }
    }

    fclose(fp);

    FILE *out = fopen(argv[2], "w");
    if (!out) {
        perror("open output");
        return 1;
    }
    fprintf(out, ".text 0\n");
    for (int i = 0; i < code_len; i++) {
        fprintf(out, "%02x\n", code[i]);
    }
    fprintf(out, "0f\n");
    fclose(out);
    return 0;
}
