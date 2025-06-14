#include "cpu_fetch.h"

int fetch(Cpub *cpub, Instruction *out)
{
    out->raw = mem_read(cpub, cpub->pc);
    out->opcode = (Opcode)(out->raw & 0xF0);
    out->addressing_mode = (AddressingMode)(out->raw & 0x0F);
    return 1;
}