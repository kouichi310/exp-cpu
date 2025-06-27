#include "cpu_utils.h"
/* 共通ヘルパー群 */

Uword cpu_read_reg(const Cpub *cpu, DestReg reg)
{
    return (reg == DEST_ACC) ? cpu->acc : cpu->ix;
}

void cpu_write_reg(Cpub *cpu, DestReg reg, Uword value)
{
    if (reg == DEST_ACC) {
        cpu->acc = value;
    } else {
        cpu->ix = value;
    }
}

void cpu_set_nz_flags(Cpub *cpu, Uword result)
{
    cpu->nf = (result & 0x80) != 0;
    cpu->zf = (result == 0);
}

void cpu_set_logic_flags(Cpub *cpu, Uword result)
{
    cpu->vf = 0;
    cpu_set_nz_flags(cpu, result);
}

