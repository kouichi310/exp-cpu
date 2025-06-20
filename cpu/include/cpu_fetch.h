#ifndef CPU_FETCH_H
#define CPU_FETCH_H
/* fetchステージ */

#include "isa.h"
#include "mem.h"

int fetch_instruction(CpuBoard *cpub, Instruction *out);

#endif /* CPU_FETCH_H */
