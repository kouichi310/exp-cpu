#include "inst_adc.h"
/* 命令実装 */
#include "cpu_utils.h"

int isa_adc(CpuBoard *cpub, const Instruction *inst)
{
    Uword src = cpu_read_reg(cpub, inst->dest);
    unsigned int operand = inst->imm + cpub->cf;
    unsigned int sum = src + operand;
    Uword result = sum & 0xFF;

    cpu_write_reg(cpub, inst->dest, result);

    cpub->cf = (sum & 0x100) != 0;
    Uword op8 = operand & 0xFF;
    cpub->vf = (((src ^ result) & (op8 ^ result) & 0x80) != 0);
    cpu_set_nz_flags(cpub, result);

    return RUN_STEP;
}
