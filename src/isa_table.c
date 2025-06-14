#include "isa_table.h"
#include "inst_ld.h"
#include "inst_st.h"
#include "inst_eor.h"

ExecFunc isa_exec_table[256] = {
    [OP_LD] = isa_ld,
    [OP_ST] = isa_st,
    [OP_EOR] = isa_eor,
};