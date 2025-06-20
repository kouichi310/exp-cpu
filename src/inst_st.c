#include "inst_st.h"
/* 命令実装 */
#include "cpu_utils.h"

int isa_st(CpuBoard *cpub, const Instruction *inst)
{
    Uword val = cpu_read_reg(cpub, inst->dest);

    switch (inst->mode) {
    case OP_B_ACC:
        cpu_write_reg(cpub, DEST_ACC, val);
        break;
    case OP_B_IX:
        cpu_write_reg(cpub, DEST_IX, val);
        break;
    default:
        mem_write(cpub, inst->effective_addr, val);
        break;
    }
    return RUN_STEP;
}
