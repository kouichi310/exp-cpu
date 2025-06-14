#include "inst_loadstore.h"

void ld_write_acc(Cpub *cpub, Uword val) {
    cpub->acc = val;
    cpub->zf = (val == 0);
    cpub->nf = (val & 0x80) != 0;
}

int isa_ld(Cpub *cpub, const Instruction *inst)
{
    Uword val = 0;
    switch (inst->addressing_mode) {
        case AM_ACC:
            val = cpub->acc;
            break;
        case AM_IX:
            val = cpub->ix;
            break;
        case AM_IMM:
            val = inst->imm;
            break;
        case AM_ABS:
            val = mem_read(cpub, inst->imm);
            break;
        case AM_ABS_D:
            val = mem_read(cpub, (inst->imm + cpub->pc) & 0xFF);
            break;
        case AM_IX_D:
            val = mem_read(cpub, (inst->imm + cpub->ix) & 0xFF);
            break;
        case AM_IX_DD:
            val = mem_read(cpub, (inst->imm + cpub->ix + cpub->pc) & 0xFF);
            break;
        default:
            return RUN_HALT;
    }
    ld_write_acc(cpub, val);
    return RUN_STEP;
}