#include "mem.h"
/* メモリアクセス */

Addr mem_read(const Cpub *cpub, Addr addr)
{
    if (addr < MEMORY_SIZE) {
        return cpub->mem[addr];
    }
    return 0;
}

void mem_write(Cpub *cpub, Addr addr, Addr data)
{
    if (addr < MEMORY_SIZE) {
        cpub->mem[addr] = data;
    }
}
