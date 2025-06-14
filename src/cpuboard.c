/*
 *	Project-based Learning II (CPU)
 *
 *	Program:	instruction set simulator of the Educational CPU Board
 *	File Name:	cpuboard.c
 *	Descrioption:	simulation(emulation) of an instruction
 */

#include	"cpu/cpuboard.h"
#include	"cpu/isa.h"
#include   "cpu/isa_table.h"
#include	"cpu/cpu_fetch.h"
#include	"cpu/cpu_decode.h"


/*=============================================================================
 *   Simulation of a Single Instruction
 *===========================================================================*/
int
step(Cpub *cpub)
{
	Instruction inst;
	if (!fetch(cpub, &inst)) {
		return RUN_HALT;
	}
	decode(cpub, &inst);
	return isa_exec_table[inst.opcode](cpub, &inst);
}


