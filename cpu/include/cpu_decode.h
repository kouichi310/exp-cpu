#ifndef CPU_DECODE_H
#define CPU_DECODE_H
/* decodeステージ */

#include "isa.h"
#include "mem.h"

void decode_instruction(CpuBoard *cpub, Instruction *inst);

#endif /* CPU_DECODE_H */
