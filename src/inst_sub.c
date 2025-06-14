#include "inst_sub.h"

static Uword sub_read_reg(const Cpub *cpub, DestReg reg)
{
    return (reg == DEST_ACC) ? cpub->acc : cpub->ix;
}

static void sub_write_reg(Cpub *cpub, DestReg reg, Uword val)
{
    if (reg == DEST_ACC) {
        cpub->acc = val;
    } else {
        cpub->ix = val;
    }
}

int isa_sub(Cpub *cpub, const Instruction *inst)
{
    Uword src = sub_read_reg(cpub, inst->dest);
    unsigned int diff = src - inst->imm;
    Uword result = diff & 0xFF;

    sub_write_reg(cpub, inst->dest, result);

    /* CF is unaffected by SUB */
    cpub->vf = (((src ^ inst->imm) & (src ^ result) & 0x80) != 0);
    cpub->nf = (result & 0x80) != 0;
    cpub->zf = (result == 0);

    return RUN_STEP;
}
