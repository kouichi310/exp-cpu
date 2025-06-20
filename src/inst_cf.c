#include "inst_cf.h"

int isa_cf(Cpub *cpub, const Instruction *inst)
{
    if (inst->raw & 0x08) {
        /* SCF: 1 -> CF */
        cpub->cf = 1;
    } else {
        /* RCF: 0 -> CF */
        cpub->cf = 0;
    }
    return RUN_STEP;
}
