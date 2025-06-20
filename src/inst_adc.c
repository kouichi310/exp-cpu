#include "inst_adc.h"

static Uword adc_read_reg(const Cpub *cpub, DestReg reg)
{
    return (reg == DEST_ACC) ? cpub->acc : cpub->ix;
}

static void adc_write_reg(Cpub *cpub, DestReg reg, Uword val)
{
    if (reg == DEST_ACC) {
        cpub->acc = val;
    } else {
        cpub->ix = val;
    }
}

int isa_adc(Cpub *cpub, const Instruction *inst)
{
    Uword src = adc_read_reg(cpub, inst->dest);
    unsigned int operand = inst->imm + cpub->cf;
    unsigned int sum = src + operand;
    Uword result = sum & 0xFF;

    adc_write_reg(cpub, inst->dest, result);

    cpub->cf = (sum & 0x100) != 0;
    Uword op8 = operand & 0xFF;
    cpub->vf = (((src ^ result) & (op8 ^ result) & 0x80) != 0);
    cpub->nf = (result & 0x80) != 0;
    cpub->zf = (result == 0);

    return RUN_STEP;
}
