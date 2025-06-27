#include "inst_io.h"
/* 命令実装 */

int isa_io(Cpub *cpub, const Instruction *inst)
{
    if (inst->raw & 0x08) {
        /* IN: IBUF -> ACC, clear flag */
        cpub->acc = cpub->ibuf->buf;
        cpub->ibuf->flag = 0;
    } else {
        /* OUT: ACC -> OBUF, set flag */
        cpub->obuf.buf = cpub->acc;
        cpub->obuf.flag = 1;
    }
    return RUN_STEP;
}
