
             PGM        PARM(&OBJLIB)
             DCL        VAR(&OBJLIB) TYPE(*CHAR) LEN(10)

             /* check the object lib exists, if not create */

             CHKOBJ     OBJ(&OBJLIB) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(CRTLIB LIB(&OBJLIB))

             CRTSQLRPGI OBJ(&OBJLIB/RELIC) SRCFILE(&OBJLIB/QSOURCE) SRCMBR(RELIC) +
                          REPLACE(*YES) COMMIT(*NONE) TEXT('')

             CALL       RELIC +
                          PARM('https://github.com/OSSILE/RelicPackageManager/archive/master.zip+
                          ' 'RelicPackageManager-master' &OBJLIB '*FETCH' '*SPOOL')

             ENDPGM
 
