#include "isa_table.h"
#include "inst_ld.h"

ExecFunc isa_exec_table[256] = {
    [OP_LD] = isa_ld,
};