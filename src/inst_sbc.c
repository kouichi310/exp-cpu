#include "inst_sbc.h"

static Uword sbc_read_reg(const Cpub *cpub, DestReg reg)
{
    return (reg == DEST_ACC) ? cpub->acc : cpub->ix;
}

static void sbc_write_reg(Cpub *cpub, DestReg reg, Uword val)
{
    if (reg == DEST_ACC) {
        cpub->acc = val;
    } else {
        cpub->ix = val;
    }
}

int isa_sbc(Cpub *cpub, const Instruction *inst)
{
    Uword src = sbc_read_reg(cpub, inst->dest);
    unsigned int operand = inst->imm + cpub->cf;
    unsigned int diff = src - operand;
    Uword result = diff & 0xFF;

    sbc_write_reg(cpub, inst->dest, result);

    cpub->cf = (diff & 0x100) != 0;
    Uword op8 = operand & 0xFF;
    cpub->vf = (((src ^ op8) & (src ^ result) & 0x80) != 0);
    cpub->nf = (result & 0x80) != 0;
    cpub->zf = (result == 0);

    return RUN_STEP;
}
