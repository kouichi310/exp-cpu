#include "isa_table.h"
#include "inst_ld.h"
#include "inst_st.h"
#include "inst_eor.h"
#include "inst_or.h"
#include "inst_and.h"
#include "inst_cmp.h"
#include "inst_shift.h"
#include "inst_add.h"
#include "inst_adc.h"
#include "inst_sub.h"
#include "inst_sbc.h"
#include "inst_bnz.h"
#include "inst_hlt.h"
#include "inst_io.h"
#include "inst_cf.h"

ExecFunc isa_exec_table[256] = {
    [OP_SYS] = isa_hlt,
    [OP_IO]  = isa_io,
    [OP_CF]  = isa_cf,
    [OP_SR]  = isa_shift,
    [OP_B]   = isa_bnz,
    [OP_LD]  = isa_ld,
    [OP_ST]  = isa_st,
    [OP_SBC] = isa_sbc,
    [OP_ADC] = isa_adc,
    [OP_SUB] = isa_sub,
    [OP_ADD] = isa_add,
    [OP_EOR] = isa_eor,
    [OP_OR]  = isa_or,
    [OP_AND] = isa_and,
    [OP_CMP] = isa_cmp,
};