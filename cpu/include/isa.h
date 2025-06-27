#ifndef ISA_H
#define ISA_H
/* ISA定義 */

#include "cpu_board.h"

typedef enum {
    OP_SYS = 0x00,
    OP_IO  = 0x10,
    OP_CF  = 0x20,
    OP_B   = 0x30,
    OP_SR  = 0x40,
    OP_LD  = 0x60,
    OP_ST  = 0x70,
    OP_SBC = 0x80,
    OP_ADC = 0x90,
    OP_SUB = 0xA0,
    OP_ADD = 0xB0,
    OP_EOR = 0xC0,
    OP_OR  = 0xD0,
    OP_AND = 0xE0,
    OP_CMP = 0xF0,
} Opcode;

typedef enum {
    DEST_ACC = 0,
    DEST_IX  = 1,
} DestReg;

typedef enum {
    OP_B_ACC   = 0x0,
    OP_B_IX    = 0x1,
    OP_B_IMM   = 0x2, /* 010 or 011 */
    OP_B_ABS_P = 0x4,
    OP_B_ABS_D = 0x5,
    OP_B_IX_P  = 0x6,
    OP_B_IX_D  = 0x7,
} OperandMode;

typedef enum {
    SHIFT_RA = 0,
    SHIFT_LA = 1,
    SHIFT_RL = 2,
    SHIFT_LL = 3,
} ShiftMode;

typedef struct {
    Uword raw;      /* first byte */
    Opcode opcode;  /* high nibble */
    DestReg dest;   /* A bit */
    OperandMode mode; /* B field */
    Uword d;        /* B' byte if present */
    Uword imm;      /* decoded operand */
    Addr effective_addr; /* 計算済みアドレス */
    ShiftMode sm;   /* shift/rotate mode */
    Bit is_rot;     /* rotate instruction flag */
} Instruction;

typedef int (*ExecFunc)(Cpub *, const Instruction *);

#endif /* ISA_H */
