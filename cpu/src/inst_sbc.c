#include "inst_sbc.h"
/* 命令実装 */
#include "cpu_utils.h"

int isa_sbc(Cpub *cpub, const Instruction *inst)
{
    Uword src = cpu_read_reg(cpub, inst->dest);
    unsigned int operand = inst->imm + cpub->cf;
    unsigned int diff = src - operand;
    Uword result = diff & 0xFF;

    cpu_write_reg(cpub, inst->dest, result);

    cpub->cf = (diff & 0x100) != 0;
    Uword op8 = operand & 0xFF;
    cpub->vf = (((src ^ op8) & (src ^ result) & 0x80) != 0);
    cpu_set_nz_flags(cpub, result);

    return RUN_STEP;
}
