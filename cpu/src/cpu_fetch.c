#include "cpu_fetch.h"
/* 命令フェッチ */

int fetch_instruction(Cpub *cpub, Instruction *out)
{
    out->raw = mem_read(cpub, cpub->pc++);
    out->opcode = (Opcode)(out->raw & 0xF0);
    out->dest = (DestReg)((out->raw >> 3) & 0x1);
    if (out->opcode == OP_SR) {
        out->is_rot = (out->raw & 0x04) != 0;
        out->sm = (ShiftMode)(out->raw & 0x03);
        out->mode = OP_B_ACC; /* unused */
    } else {
        Uword b = out->raw & 0x07;
        if (b == 0x03)
            b = 0x02; /* 010 and 011 are both immediate */
        out->mode = (OperandMode)b;
    }
    out->d = 0;
    out->imm = 0;
    out->effective_addr = 0;
    return 1;
}