#ifndef MEM_H
#define MEM_H
/* メモリ操作API */

#include "cpu_board.h"

Addr mem_read(const CpuBoard *cpub, Addr addr);
void mem_write(CpuBoard *cpub, Addr addr, Addr data);

#endif /* MEM_H */
