#include "cpu/cpu_decode.h"

void decode(Cpub *cpub, Instruction *inst) {
    switch (inst->addressing_mode) {
        case AM_ACC:
            inst->imm = cpub->acc;
            break;
        case AM_IX:
            inst->imm = cpub->ix;
            break;
        case AM_IMM:
            // Immediate value is already set in inst->imm
            break;
        case AM_ABS:
            inst->imm = mem_read(cpub, inst->raw & 0xFF);
            break;
        case AM_ABS_D:
            inst->imm = mem_read(cpub, (inst->raw & 0xFF) + cpub->pc);
            break;
        case AM_IX_D:
            inst->imm = mem_read(cpub, (inst->raw & 0xFF) + cpub->ix);
            break;
        case AM_IX_DD:
            inst->imm = mem_read(cpub, (inst->raw & 0xFF) + cpub->ix + cpub->pc);
            break;
        default:
            // Handle unknown addressing mode
            inst->imm = 0; // Default to zero if unknown
    }
}