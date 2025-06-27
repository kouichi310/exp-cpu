#ifndef CPU_BOARD_H
#define CPU_BOARD_H
/*
 *      Project-based Learning II (CPU)
 *
 *      Program:        instruction set simulator of the Educational CPU Board
 *      File Name:      cpu_board.h
 *      Descrioption:   resource definition of the educational computer board
 */

/*=============================================================================
 *   Architectural Data Types
 *===========================================================================*/
typedef signed char     Sword;
typedef unsigned char   Uword;
typedef unsigned short  Addr;
typedef unsigned char   Bit;


/*=============================================================================
 *   CPU Board Resources
 *===========================================================================*/
#define MEMORY_SIZE     256*2
#define IMEMORY_SIZE    256

typedef struct iobuf {
        Bit     flag;
        Uword   buf;
} IOBuf;

typedef struct cpu_board {
        Uword   pc;
        Uword   acc;
        Uword   ix;
        Bit     cf, vf, nf, zf;
        IOBuf   *ibuf;
        IOBuf   obuf;
        /*
         *   [ add here the other CPU resources if necessary ]
         */
        Uword   mem[MEMORY_SIZE];       /* 0XX:Program, 1XX:Data */
} Cpub;


/*=============================================================================
 *   Top Function of an Instruction Simulation
 *===========================================================================*/
#define RUN_HALT        0
#define RUN_STEP        1
/* 1ステップ実行 */
int     step(Cpub *);

#endif /* CPU_BOARD_H */
