/*
 *	Project-based Learning II (CPU)
 *
 *	Program:	instruction set simulator of the Educational CPU Board
 *	File Name:	cpu_board.c
 *	Descrioption:	simulation(emulation) of an instruction
 */

#include	"cpu_board.h"
/* 命令実行サイクル */
#include	"isa.h"
#include   "isa_table.h"
#include	"cpu_fetch.h"
#include	"cpu_decode.h"


/*=============================================================================
 *   Simulation of a Single Instruction
 *===========================================================================*/
int
run_step(CpuBoard *cpub)/* 1ステップ実行 */
{
	Instruction inst;
	if (!fetch_instruction(cpub, &inst)) {
		return RUN_HALT;
	}
	decode_instruction(cpub, &inst);
	return isa_exec_table[inst.opcode](cpub, &inst);
}


