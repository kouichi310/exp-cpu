#include "isa_table.h"
#include "inst_ld.h"
#include "inst_st.h"
#include "inst_eor.h"
#include "inst_add.h"
#include "inst_sub.h"
#include "inst_bnz.h"
#include "inst_hlt.h"

ExecFunc isa_exec_table[256] = {
    [OP_SYS] = isa_hlt,
    [OP_B]   = isa_bnz,
    [OP_LD] = isa_ld,
    [OP_ST] = isa_st,
    [OP_SUB] = isa_sub,
    [OP_ADD] = isa_add,
    [OP_EOR] = isa_eor,
};