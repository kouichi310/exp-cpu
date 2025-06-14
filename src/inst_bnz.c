#include "inst_bnz.h"
#include "mem.h"

int isa_bnz(Cpub *cpub, const Instruction *inst)
{
    /* fetch branch target from the operand already decoded */
    Uword target = inst->d;
    /* condition code is lower 4 bits of raw instruction */
    Uword bc = inst->raw & 0x0F;

    if (bc == 0x1) { /* BNZ */
        if (!cpub->zf) {
            cpub->pc = target;
        }
    }
    /* other branch codes are not implemented; treated as not taken */
    return RUN_STEP;
}
