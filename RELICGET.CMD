             /* Build this over RELIC *PGM */

             CMD        Prompt('Relic Package Download')
             PARM       KWD(PLOC)  TYPE(*CHAR) LEN(128) PROMPT('Source ZIP')
             PARM       KWD(pDIR)  TYPE(*CHAR) LEN(27)  PROMPT('Folder after extract') +
                          ALWUNPRT(*NO)
             PARM       KWD(PNAME) TYPE(*CHAR) LEN(10)  PROMPT('Into *LIB') ALWUNPRT(*NO)

 