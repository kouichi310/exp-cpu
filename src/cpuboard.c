/*
 *	Project-based Learning II (CPU)
 *
 *	Program:	instruction set simulator of the Educational CPU Board
 *	File Name:	cpuboard.c
 *	Descrioption:	simulation(emulation) of an instruction
 */

#include <stdio.h>
#include	"cpuboard.h"


/*=============================================================================
 *   Simulation of a Single Instruction
 *===========================================================================*/
enum {
        OP_HLT = 0x00,
        OP_STA_ABS = 0x10
};

int
step(Cpub *cpub)
{
        Uword   op;

        op = cpub->mem[cpub->pc++];

        switch( op ) {
           case OP_HLT:
                return RUN_HALT;

           case OP_STA_ABS: {
                Addr addr = cpub->mem[cpub->pc++];
                cpub->mem[0x100 | addr] = cpub->acc;
                break;
           }

           default:
                fprintf(stderr,"Unknown opcode: 0x%02x\n",op);
                return RUN_HALT;
        }

        return RUN_STEP;
}


