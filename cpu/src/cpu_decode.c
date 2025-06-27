#include "cpu_decode.h"
/* デコード処理 */

static int needs_operand(OperandMode mode)
{
    return !(mode == OP_B_ACC || mode == OP_B_IX);
}

void decode_instruction(Cpub *cpub, Instruction *inst)
{
    Addr addr = 0;

    if (inst->opcode == OP_B) {
        inst->d = mem_read(cpub, cpub->pc++);
        inst->imm = inst->d;
        return;
    }

    if (inst->opcode == OP_SR) {
        return;
    }

    if (inst->opcode == OP_SYS) {
        Uword sub = inst->raw & 0x0F;
        if (sub == 0x0A) { /* JAL */
            inst->d = mem_read(cpub, cpub->pc++);
            inst->imm = inst->d;
            return;
        } else if (sub == 0x0B) { /* JR */
            return;
        }
    }

    if (needs_operand(inst->mode)) {
        inst->d = mem_read(cpub, cpub->pc++);
    }

    /* メモリアドレス計算 */
    switch (inst->mode) {
    case OP_B_ABS_P:
        addr = inst->d & 0xFF;
        break;
    case OP_B_ABS_D:
        addr = 0x100 | (inst->d & 0xFF);
        break;
    case OP_B_IX_P:
        addr = (cpub->ix + inst->d) & 0xFF;
        break;
    case OP_B_IX_D:
        addr = 0x100 | ((cpub->ix + inst->d) & 0xFF);
        break;
    case OP_B_IMM:
        if (inst->opcode == OP_ST)
            addr = inst->d & 0xFF;
        break;
    default:
        break;
    }

    inst->effective_addr = addr;

    if (inst->opcode == OP_ST)
        return;

    switch (inst->mode) {
    case OP_B_ACC:
        inst->imm = cpub->acc;
        break;
    case OP_B_IX:
        inst->imm = cpub->ix;
        break;
    case OP_B_IMM:
        inst->imm = inst->d;
        break;
    case OP_B_ABS_P:
    case OP_B_ABS_D:
    case OP_B_IX_P:
    case OP_B_IX_D:
        inst->imm = mem_read(cpub, addr);
        break;
    default:
        inst->imm = 0;
        break;
    }
}