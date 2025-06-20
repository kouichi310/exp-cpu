#ifndef CPU_UTILS_H
#define CPU_UTILS_H
/* 汎用CPUユーティリティ */

#include "cpu_board.h"
#include "isa.h"

Uword cpu_read_reg(const CpuBoard *cpu, DestReg reg);
void cpu_write_reg(CpuBoard *cpu, DestReg reg, Uword value);
void cpu_set_nz_flags(CpuBoard *cpu, Uword result);
void cpu_set_logic_flags(CpuBoard *cpu, Uword result);

#endif /* CPU_UTILS_H */
