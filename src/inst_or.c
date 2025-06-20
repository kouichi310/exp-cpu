#include "inst_or.h"

static Uword or_read_reg(const Cpub *cpub, DestReg reg)
{
    return (reg == DEST_ACC) ? cpub->acc : cpub->ix;
}

static void or_write_reg(Cpub *cpub, DestReg reg, Uword val)
{
    if (reg == DEST_ACC) {
        cpub->acc = val;
    } else {
        cpub->ix = val;
    }
    cpub->zf = (val == 0);
    cpub->nf = (val & 0x80) != 0;
    cpub->vf = 0;
}

int isa_or(Cpub *cpub, const Instruction *inst)
{
    Uword src = or_read_reg(cpub, inst->dest);
    Uword result = src | inst->imm;
    or_write_reg(cpub, inst->dest, result);
    return RUN_STEP;
}
