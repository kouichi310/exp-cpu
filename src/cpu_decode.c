#include "cpu_decode.h"

static int needs_operand(OperandMode mode)
{
    return !(mode == OP_B_ACC || mode == OP_B_IX);
}

void decode(Cpub *cpub, Instruction *inst)
{
    Addr effective_addr;

    if (inst->opcode == OP_B) {
        inst->d = mem_read(cpub, cpub->pc++);
        inst->imm = inst->d;
        return;
    }

    if (needs_operand(inst->mode)) {
        inst->d = mem_read(cpub, cpub->pc++);
    }

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
        inst->imm = mem_read(cpub, inst->d & 0xFF);
        break;
    case OP_B_ABS_D:
        inst->imm = mem_read(cpub, 0x100 | (inst->d & 0xFF));
        break;
    case OP_B_IX_P:
        effective_addr = (cpub->ix + inst->d) & 0xFF;
        inst->imm = mem_read(cpub, effective_addr);
        break;
    case OP_B_IX_D:
        effective_addr = 0x100 | ((cpub->ix + inst->d) & 0xFF);
        inst->imm = mem_read(cpub, effective_addr);
        break;
    default:
        inst->imm = 0;
        break;
    }
}