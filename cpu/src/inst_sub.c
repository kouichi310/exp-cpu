#include "inst_sub.h"
/* 命令実装 */
#include "cpu_utils.h"

int isa_sub(Cpub *cpub, const Instruction *inst)
{
    Uword src = cpu_read_reg(cpub, inst->dest);
    unsigned int diff = src - inst->imm;
    Uword result = diff & 0xFF;

    cpu_write_reg(cpub, inst->dest, result);

    //cpub->cf = (diff & 0x100) != 0;
    cpub->vf = (((src ^ inst->imm) & (src ^ result) & 0x80) != 0);
    cpu_set_nz_flags(cpub, result);

    return RUN_STEP;
}
