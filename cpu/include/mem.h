#ifndef MEM_H
#define MEM_H
/* メモリ操作API */

#include "cpu_board.h"

Addr mem_read(const Cpub *cpub, Addr addr);
void mem_write(Cpub *cpub, Addr addr, Addr data);

#endif /* MEM_H */
