#include "inst_cmp.h"

static Uword cmp_read_reg(const Cpub *cpub, DestReg reg)
{
    return (reg == DEST_ACC) ? cpub->acc : cpub->ix;
}

int isa_cmp(Cpub *cpub, const Instruction *inst)
{
    Uword src = cmp_read_reg(cpub, inst->dest);
    unsigned int diff = src - inst->imm;
    Uword result = diff & 0xFF;

    cpub->cf = (diff & 0x100) != 0;
    cpub->vf = (((src ^ inst->imm) & (src ^ result) & 0x80) != 0);
    cpub->nf = (result & 0x80) != 0;
    cpub->zf = (result == 0);

    return RUN_STEP;
}
