#include "inst_ld.h"
/* 命令実装 */
#include "cpu_utils.h"

int isa_ld(Cpub *cpub, const Instruction *inst)
{
    cpu_write_reg(cpub, inst->dest, inst->imm);
    return RUN_STEP;
}