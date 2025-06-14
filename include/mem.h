#ifndef MEM_H
#define MEM_H

#include "cpuboard.h"

Addr mem_read(const Cpub *cpub, Addr addr);
void mem_write(Cpub *cpub, Addr addr, Addr data);

#endif