#include "inst_st.h"

static Uword st_read_reg(const Cpub *cpub, DestReg src)
{
    return (src == DEST_ACC) ? cpub->acc : cpub->ix;
}

static void st_write_operand(Cpub *cpub, OperandMode mode, Uword d, Uword val)
{
    Addr addr;
    switch (mode) {
    case OP_B_ACC:
        cpub->acc = val;
        break;
    case OP_B_IX:
        cpub->ix = val;
        break;
    case OP_B_IMM:
        mem_write(cpub, d & 0xFF, val);
        break;
    case OP_B_ABS_P:
        mem_write(cpub, d & 0xFF, val);
        break;
    case OP_B_ABS_D:
        mem_write(cpub, 0x100 | (d & 0xFF), val);
        break;
    case OP_B_IX_P:
        addr = (cpub->ix + d) & 0xFF;
        mem_write(cpub, addr, val);
        break;
    case OP_B_IX_D:
        addr = 0x100 | ((cpub->ix + d) & 0xFF);
        mem_write(cpub, addr, val);
        break;
    default:
        break;
    }
}

int isa_st(Cpub *cpub, const Instruction *inst)
{
    Uword val = st_read_reg(cpub, inst->dest);
    st_write_operand(cpub, inst->mode, inst->d, val);
    return RUN_STEP;
}
