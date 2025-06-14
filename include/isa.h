#ifndef ISA_H
#define ISA_H

#include "cpuboard.h"

typedef enum {
    OP_LD = 0x60,
    OP_ST = 0x70,
    OP_ADD = 0xB0,
    OP_EOR = 0xC0,
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

typedef struct {
    Uword raw;      /* first byte */
    Opcode opcode;  /* high nibble */
    DestReg dest;   /* A bit */
    OperandMode mode; /* B field */
    Uword d;        /* B' byte if present */
    Uword imm;      /* decoded operand */
} Instruction;

typedef int (*ExecFunc)(Cpub *, const Instruction *);

#endif /* ISA_H */
