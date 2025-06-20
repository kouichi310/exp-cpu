#include "inst_shift.h"

static Uword read_reg(const Cpub *cpub, DestReg reg)
{
    return (reg == DEST_ACC) ? cpub->acc : cpub->ix;
}

static void write_reg(Cpub *cpub, DestReg reg, Uword val)
{
    if (reg == DEST_ACC) {
        cpub->acc = val;
    } else {
        cpub->ix = val;
    }
}

int isa_shift(Cpub *cpub, const Instruction *inst)
{
    Uword val = read_reg(cpub, inst->dest);
    Uword result = val;
    Bit b0 = val & 0x1;
    Bit b7 = (val >> 7) & 0x1;

    if (inst->is_rot) {
        switch (inst->sm) {
        case SHIFT_RA: /* RRA: rotate right through carry */
            result = (val >> 1) | ((cpub->cf & 1) << 7);
            cpub->cf = b0;
            break;
        case SHIFT_LA: /* RLA: rotate left through carry */
            result = ((val << 1) & 0xFF) | (cpub->cf & 1);
            cpub->cf = b7;
            break;
        case SHIFT_RL: /* RRL: rotate right */
            result = (val >> 1) | (b0 << 7);
            cpub->cf = b0;
            break;
        case SHIFT_LL: /* RLL: rotate left */
            result = ((val << 1) & 0xFF) | b7;
            cpub->cf = b7;
            break;
        }
        cpub->vf = 0;
        cpub->nf = (result & 0x80) != 0;
        cpub->zf = (result == 0);
    } else {
        switch (inst->sm) {
        case SHIFT_RA: /* SRA */
            result = (val >> 1) | (val & 0x80);
            cpub->cf = b0;
            cpub->vf = 0;
            cpub->nf = (result & 0x80) != 0;
            cpub->zf = (result == 0);
            break;
        case SHIFT_LA: /* SLA */
            result = (val << 1) & 0xFF;
            cpub->cf = b7;
            cpub->vf = (b7 ^ ((result >> 7) & 1)) != 0;
            cpub->nf = (result & 0x80) != 0;
            cpub->zf = (result == 0);
            break;
        case SHIFT_RL: /* SRL */
            result = val >> 1;
            cpub->cf = b0;
            cpub->vf = 0;
            cpub->nf = 0;
            cpub->zf = (result == 0);
            break;
        case SHIFT_LL: /* SLL */
            result = (val << 1) & 0xFF;
            cpub->cf = b7;
            cpub->vf = (b7 ^ ((result >> 7) & 1)) != 0;
            cpub->nf = (result & 0x80) != 0;
            cpub->zf = (result == 0);
            break;
        }
    }

    write_reg(cpub, inst->dest, result);
    return RUN_STEP;
}
