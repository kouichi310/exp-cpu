#include "inst_sys.h"
/* 命令実装 */

int isa_sys(CpuBoard *cpub, const Instruction *inst)
{
    Uword sub = inst->raw & 0x0F;

    /* NOP opcodes are 0x00 through 0x03 */
    if ((inst->raw & 0xFC) == 0x00) {
        return RUN_STEP;
    }

    /* HLT opcodes are 0x0C through 0x0F */
    if (inst->raw >= 0x0c && inst->raw <= 0x0f) {
        return RUN_HALT;
    }

    if (sub == 0x0A) { /* JAL */
        cpub->acc = cpub->pc;
        cpub->pc = inst->d;
        return RUN_STEP;
    }

    if (sub == 0x0B) { /* JR */
        cpub->pc = cpub->acc;
        return RUN_STEP;
    }

    /* Other system instructions are treated as NOP for now */
    return RUN_STEP;
}
