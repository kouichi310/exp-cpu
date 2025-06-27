#include "inst_and.h"
/* 命令実装 */
#include "cpu_utils.h"

int isa_and(Cpub *cpub, const Instruction *inst)
{
    Uword src = cpu_read_reg(cpub, inst->dest);
    Uword result = src & inst->imm;
    cpu_write_reg(cpub, inst->dest, result);
    cpu_set_logic_flags(cpub, result);
    return RUN_STEP;
}
