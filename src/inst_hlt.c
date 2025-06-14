#include "inst_hlt.h"

int isa_hlt(Cpub *cpub, const Instruction *inst)
{
    (void)cpub;

    /* HLT opcodes are 0x0C through 0x0F */
    if (inst->raw >= 0x0c && inst->raw <= 0x0f) {
        return RUN_HALT;
    }

    /* unimplemented system instructions behave as NOP */
    return RUN_STEP;
}
