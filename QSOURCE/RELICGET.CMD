             /* Build this over RELIC *PGM */

             CMD        Prompt('Relic Package Download')
             PARM       KWD(PLOC)  TYPE(*CHAR) LEN(128) PROMPT('Source +
                          ZIP')
             PARM       KWD(pDIR)  TYPE(*CHAR) LEN(50)  PROMPT('Folder +
                          after extract') ALWUNPRT(*NO)
             PARM       KWD(PNAME) TYPE(*CHAR) LEN(10)  PROMPT('Into +
                          *LIB') ALWUNPRT(*NO)
             PARM       KWD(PFETCH) TYPE(*char) LEN(10) PROMPT('Fetch, or +
                          build-only?') MIN(0) RSTD(*yes) DFT(*FETCH) +
                          VALUES(*FETCH *BUILDONLY)
             PARM       KWD(PLOG) TYPE(*char) LEN(10) PROMPT('Logging')
                          MIN(0) RSTD(*yes) DFT(*DSP) +
                          VALUES(*DSP *STMF)