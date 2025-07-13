#include "inst_branch.h"
/* 命令実装 */
#include "mem.h"

int isa_branch(Cpub *cpub, const Instruction *inst)
{
    Uword target = inst->d;
    Uword bc = inst->raw & 0x0F;
    Bit taken = 0;

    switch (bc) {
    case 0x0: /* BA  - Always */
        taken = 1;
        break;
    case 0x1: /* BNZ - ZF == 0 */
        taken = !cpub->zf;
        break;
    case 0x2: /* BZP - NF == 0 */
        taken = !cpub->nf;
        break;
    case 0x3: /* BP  - (NF AND ZF) == 0 */
        taken = ((cpub->nf & cpub->zf) == 0);
        break;
    case 0x4: /* BNI - input flag == 0 */
        taken = (cpub->ibuf->flag == 0);
        break;
    case 0x5: /* BNC - CF == 0 */
        taken = (cpub->cf == 0);
        break;
    case 0x6: /* BGE - (VF XOR NF) == 0 */
        taken = ((cpub->vf ^ cpub->nf) == 0);
        break;
    case 0x7: /* BGT - ((VF XOR NF) & ZF) == 0 */
        taken = (((cpub->vf ^ cpub->nf) & cpub->zf) == 0);
        break;
    case 0x8: /* BVF - VF == 1 */
        taken = cpub->vf != 0;
        break;
    case 0x9: /* BZ  - ZF == 1 */
        taken = cpub->zf != 0;
        break;
    case 0xA: /* BN  - NF == 1 */
        taken = cpub->nf != 0;
        break;
    case 0xB: /* BZN - (NF & ZF) == 1 */
        taken = (cpub->nf & cpub->zf);
        break;
    case 0xC: /* BNO - output flag == 1 */
        taken = (cpub->obuf.flag != 0);
        break;
    case 0xD: /* BC  - CF == 1 */
        taken = cpub->cf != 0;
        break;
    case 0xE: /* BLT - (VF XOR NF) == 1 */
        taken = ((cpub->vf ^ cpub->nf) != 0);
        break;
    case 0xF: /* BLE - ((VF XOR NF) & ZF) == 1 */
        taken = (((cpub->vf ^ cpub->nf) & cpub->zf) != 0);
        break;
    default:
        taken = 0;
        break;
    }

    if (taken)
        cpub->pc = target;

    return RUN_STEP;
}
