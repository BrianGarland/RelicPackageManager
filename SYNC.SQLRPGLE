
       Ctl-Opt DftActGrp(*No) ActGrp(*NEW);

       //*********************************

       Dcl-Pr Cmd int(10) extproc('system');
         cmdstring pointer value options(*string);
       End-Pr;
       //Dcl-s errmsgid char(7) import('_EXCP_MSGID');

       Dcl-Pr printf Int(10) ExtProc('printf');
         format Pointer Value Options(*String);
       END-PR;

       //*********************************

       Dcl-Ds gObject Qualified;
         OBJNAME Char(10);
       END-DS;

       Dcl-Ds gMember Qualified;
         MLNAME Char(10);
         MLSEU2 Char(10); //Type
       END-DS;

       Dcl-S gBuildInd Int(5)    Inz(1);
       Dcl-S gBuild    Char(300) Dim(250);

       //*********************************

       Dcl-Pi SYNC;
         pLibrary Char(10) Const;
       END-PI;

       BUILD_Add('build:');

       IFS_CreateDir(%Trim(pLibrary) + '/');
       SYS_GetFiles(pLibrary);

       BUILD_Create();

       *InLR = *On;
       Return;

       //*********************************

       Dcl-Proc BUILD_Add;
         Dcl-Pi *N;
           pValue Char(256) Const;
         END-PI;

         gBuild(gBuildInd) = %TrimR(pValue) + x'25';
         gBuildInd += 1;
       END-PROC;

       //*********************************

       Dcl-Proc BUILD_Create;
         dcl-pr OpenFile pointer extproc('_C_IFS_fopen');
           *n pointer value;  //File name
           *n pointer value;  //File mode
         end-pr;

         dcl-pr WriteFile pointer extproc('_C_IFS_fwrite');
           *n pointer value;  //Write data
           *n int(10) value;  //Data size
           *n int(10) value;  //Block size
           *n pointer value;  //Misc pointer
         end-pr;

         dcl-pr CloseFile extproc('_C_IFS_fclose');
           *n pointer value;  //Misc pointer
         end-pr;

         dcl-s PathFile char(256);
         dcl-s OpenMode char(5);
         dcl-s FilePtr pointer inz;

         PathFile = %Trim(pLibrary) + '/build.txt' + x'00';
         OpenMode = 'ab' + x'00';
         FilePtr  = OpenFile(%addr(PathFile):%addr(OpenMode));

         If (FilePtr = *null);
           printf('Failed to write build file.');
           Return;
         EndIf;

         For gBuildInd = 1 to 250;
           If (gBuild(gBuildInd) <> *Blank);
             WriteFile(%Addr(gBuild(gBuildInd))
                      :%Len(%TrimR(gBuild(gBuildInd)))
                      :1
                      :FilePtr);
           ENDIF;
         ENDFOR;

         CloseFile(FilePtr);

       END-PROC;

       //*********************************

       Dcl-Proc SYS_GetFiles;
         Dcl-Pi *N;
           pLib Char(10) Const;
         END-PI;

         EXEC SQL
           DECLARE Obj_Cur CURSOR FOR
           SELECT OBJNAME FROM
             TABLE(QSYS2.OBJECT_STATISTICS(:pLibrary, 'FILE'))
             AS FILES;

         EXEC SQL OPEN Obj_Cur;
         If (SQLSTATE = '00000');
           EXEC SQL FETCH Obj_Cur INTO :gObject;

           Dow (SQLSTATE = '00000');
             BUILD_Add('');
             BUILD_Add('    CRTSRCPF FILE(&INTOLIB/'
                       + %Trim(gObject.OBJNAME) + ') RCDLEN(112)');

             printf( 'Getting ' + %Trim(pLibrary)
                   + '/' + %Trim(gObject.OBJNAME) + '..' + x'25');
             IFS_CreateDir(%Trim(pLibrary) + '/' + %Trim(gObject.OBJNAME));
             SYS_GetMembers(pLib:gObject.OBJNAME);

             EXEC SQL FETCH Obj_Cur INTO :gObject;
           ENDDO;
         ENDIF;

         EXEC SQL CLOSE Obj_Cur;

       END-PROC;

       //*********************************

       Dcl-Proc SYS_GetMembers;
         Dcl-Pi *N;
           pLib Char(10) Const;
           pObj Char(10) Const;
         END-PI;

         If (Cmd(  'DSPFD '
                 + 'FILE(' + %Trim(pLib) + '/' + %Trim(pObj) + ') '
                 + 'TYPE(*MBRLIST) OUTPUT(*OUTFILE) '
                 + 'OUTFILE(QTEMP/MEMBERS)') = 0);

           EXEC SQL
             DECLARE Mbr_Cur CURSOR FOR
             SELECT MLNAME, MLSEU2 FROM QTEMP/MEMBERS;

           EXEC SQL OPEN Mbr_Cur;
           If (SQLSTATE = '00000');
             EXEC SQL FETCH Mbr_Cur INTO :gMember;

             Dow (SQLSTATE = '00000');
               printf('> ' + gMember.MLNAME + '.');
               IFS_SyncSource(pLib:pObj:gMember.MLNAME:gMember.MLSEU2);

               EXEC SQL FETCH Mbr_Cur INTO :gMember;
             ENDDO;
           ENDIF;

           EXEC SQL CLOSE Mbr_Cur;

           EXEC SQL DROP TABLE QTEMP/MEMBERS;
         Else;
         Endif;

       END-PROC;

       //*********************************

       Dcl-Proc IFS_CreateDir;
         Dcl-Pi *N;
           pPath Varchar(64) Const;
         END-PI;
         Dcl-S lPath Varchar(64);

         Cmd('RMDIR DIR(''' + %Trim(pPath) + ''') SUBTREE(*ALL)');
         Cmd('CRTDIR DIR(''' + %Trim(pPath) + ''')');

       END-PROC;

       //*********************************

       Dcl-Proc IFS_SyncSource;
         Dcl-Pi *N;
           pLib Char(10) Const;
           pObj Char(10) Const;
           pMbr Char(10) Const;
           pTyp Char(10) Value;
         END-PI;

         Dcl-S lCmd Varchar(512);

         If (pTyp = *Blank);
           pTyp = 'MBR';
         ENDIF;

         lCmd = '    CPYTOSTMF '
              + 'FROMMBR(''/QSYS.lib/' + %Trim(pLib) + '.lib/'
                                       + %Trim(pObj) + '.file/'
                                       + %Trim(pMbr) + '.mbr'') '
              + 'TOSTMF(''' + %Trim(pLib) + '/'
                            + %Trim(pObj) + '/'
                            + %Trim(pMbr) + '.' + %Trim(pTyp) + ''')'
              + ' STMFOPT(*ADD) CVTDTA(*AUTO) STMFCCSID(1208)';

         printf('.');

         If (Cmd(lCmd) = 0);
           printf('.');

           //Add to build file
           lCmd = '    CPYFRMSTMF '
              + 'FROMSTMF(''&DIR/'
                          + %Trim(pObj) + '/'
                          + %Trim(pMbr) + '.' + %Trim(pTyp) + ''') '
              + 'TOMBR(''/QSYS.lib/&INTOLIB.lib/'
                                 + %Trim(pObj) + '.file/'
                                 + %Trim(pMbr) + '.mbr'') '
              + 'MBROPT(*ADD)';
           BUILD_Add(lCmd);
           printf('completed' + x'25');

         Else;
           printf('failed' + x'25');
           printf( 'Failed CPYTOSTMF on '
                 + %Trim(pLib) + '/'
                 + %Trim(pObj) + '.'
                 + %Trim(pMbr)
                 + '.' + x'25');
         Endif;
       END-PROC; 