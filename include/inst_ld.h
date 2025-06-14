#ifndef INST_LD_H
#define INST_LD_H

#include "isa.h"
#include "mem.h"

int isa_ld(Cpub *cpub, const Instruction *inst);
void ld_write_acc(Cpub *cpub, Uword val);

#endif /* INST_LD_H */
