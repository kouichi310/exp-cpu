#include "inst_add.h"

static Uword add_read_reg(const Cpub *cpub, DestReg reg)
{
    return (reg == DEST_ACC) ? cpub->acc : cpub->ix;
}

static void add_write_reg(Cpub *cpub, DestReg reg, Uword val)
{
    if (reg == DEST_ACC) {
        cpub->acc = val;
    } else {
        cpub->ix = val;
    }
}

int isa_add(Cpub *cpub, const Instruction *inst)
{
    Uword src = add_read_reg(cpub, inst->dest);
    unsigned int sum = src + inst->imm;
    Uword result = sum & 0xFF;

    add_write_reg(cpub, inst->dest, result);

    /* CF is unaffected by ADD */
    cpub->vf = (((src ^ result) & (inst->imm ^ result) & 0x80) != 0);
    cpub->nf = (result & 0x80) != 0;
    cpub->zf = (result == 0);

    return RUN_STEP;
}
