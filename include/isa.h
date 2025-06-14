#ifndef ISA_H
#define ISA_H

#include "cpuboard.h"

typedef enum {
    OP_LD = 0x20,
} Opcode;

typedef enum {
    AM_ACC = 0x00,
    AM_IX = 0x01,
    AM_IMM = 0x02,
    AM_ABS = 0x04,
    AM_ABS_D = 0x05,
    AM_IX_D = 0x06,
    AM_IX_DD = 0x07,
} AddressingMode;

typedef struct {
    Uword raw;
    Opcode opcode;
    AddressingMode addressing_mode;
    Uword imm;
} Instruction;

typedef int (*ExecFunc)(Cpub *, const Instruction *);

#endif /* ISA_H */
