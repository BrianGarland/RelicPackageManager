             /* Build this over RELIC *PGM */

             CMD        Prompt('Relic Package Download')
             PARM       KWD(PLOC)  TYPE(*CHAR) LEN(128) PROMPT('Source +
                          ZIP')
             PARM       KWD(pDIR)  TYPE(*CHAR) LEN(50)  PROMPT('Folder +
                          after extract') ALWUNPRT(*NO)
             PARM       KWD(PNAME) TYPE(*CHAR) LEN(10)  PROMPT('Into +
                          *LIB') ALWUNPRT(*NO)
             parm       kwd(Fetch) type(*char) len(10) prompt('Fetch, or +
                          build-only?') min(0) rstd(*yes) dft(*FETCH) +
                          values(*FETCH *BUILDONLY)
