             /* Build this over EVFPRTY *PGM */

             CMD        Prompt('*EVENTF Prettify')
             PARM       KWD(PLIB) TYPE(*CHAR) LEN(10) MIN(1) ALWUNPRT(*NO) +
                          PROMPT('Library')
             PARM       KWD(PPGM)  TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('Program')
             PARM       KWD(PDSP) TYPE(*CHAR) LEN(4) PROMPT('Display') +
                          MIN(0) RSTD(*YES) DFT(*YES) VALUES(*NO *YES)
             PARM       KWD(PINF) TYPE(*CHAR) LEN(4) PROMPT('Show Info') +
                          MIN(0) RSTD(*YES) DFT(*NO) VALUES(*NO *YES) 