#include "inst_add.h"
/* 命令実装 */
#include "cpu_utils.h"

int isa_add(CpuBoard *cpub, const Instruction *inst)
{
    Uword src = cpu_read_reg(cpub, inst->dest);
    unsigned int sum = src + inst->imm;
    Uword result = sum & 0xFF;

    cpu_write_reg(cpub, inst->dest, result);

    /* CF is unaffected by ADD */
    cpub->vf = (((src ^ result) & (inst->imm ^ result) & 0x80) != 0);
    cpu_set_nz_flags(cpub, result);

    return RUN_STEP;
}
