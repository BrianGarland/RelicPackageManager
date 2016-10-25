             PGM        PARM(&SRCLIB &OBJLIB &TGTRLS)
             DCL        VAR(&SRCLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&OBJLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&TGTRLS) TYPE(*CHAR) LEN(10)

             /* check the object lib exists, if not create */

             CHKOBJ     OBJ(&OBJLIB) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(CRTLIB LIB(&OBJLIB))

             CRTSQLRPGI OBJ(&OBJLIB/RELIC) SRCFILE(&SRCLIB/QSOURCE) SRCMBR(RELIC) +
                          REPLACE(*YES) COMMIT(*NONE) TEXT('')
             CRTSQLRPGI OBJ(&OBJLIB/SYNC) SRCFILE(&SRCLIB/QSOURCE) SRCMBR(SYNC) REPLACE(*YES) +
                          COMMIT(*NONE) TEXT('')
             CRTCMD     CMD(&OBJLIB/RELICGET) PGM(&OBJLIB/RELIC) SRCFILE(&SRCLIB/QSOURCE) +
                          SRCMBR(RELICGET) REPLACE(*YES) TEXT('')

             ENDPGM

