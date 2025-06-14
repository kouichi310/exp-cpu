#include "inst_ld.h"

static void ld_write_reg(Cpub *cpub, DestReg dest, Uword val)
{
    if (dest == DEST_ACC) {
        cpub->acc = val;
    } else {
        cpub->ix = val;
    }
    cpub->zf = (val == 0);
    cpub->nf = (val & 0x80) != 0;
}

int isa_ld(Cpub *cpub, const Instruction *inst)
{
    ld_write_reg(cpub, inst->dest, inst->imm);
    return RUN_STEP;
}