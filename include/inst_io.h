#ifndef INST_IO_H
#define INST_IO_H
/* 命令 */

#include "isa.h"

int isa_io(CpuBoard *cpub, const Instruction *inst);

#endif /* INST_IO_H */
