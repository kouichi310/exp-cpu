#include "inst_hlt.h"

int isa_hlt(Cpub *cpub, const Instruction *inst)
{
    (void)cpub;

    /* NOP opcodes are 0x00 through 0x03 */
    if ((inst->raw & 0xFC) == 0x00) {
        return RUN_STEP;
    }

    /* HLT opcodes are 0x0C through 0x0F */
    if (inst->raw >= 0x0c && inst->raw <= 0x0f) {
        return RUN_HALT;
    }

    /* Other system instructions are treated as NOP for now */
    return RUN_STEP;
}
