
       // Relic is an open-source package manager created by Liam Allan.
       // It may also go by these names:
       //   - Relic Package Manager
       //   - DWNPKG

       Ctl-Opt DftActGrp(*No) ActGrp(*NEW);

       dcl-pr Cmd int(10) extproc('system');
         cmdstring pointer value options(*string);
       end-pr;
       Dcl-s errmsgid char(7) import('_EXCP_MSGID');

       Dcl-Pr printf Int(10) ExtProc('printf');
         format Pointer Value Options(*String);
       END-PR;

       //*********************************************

       dcl-pr OpenFile pointer extproc('_C_IFS_fopen');
         *n pointer value;  //File name
         *n pointer value;  //File mode
       end-pr;

       dcl-pr ReadFile pointer extproc('_C_IFS_fgets');
         *n pointer value;  //Retrieved data
         *n int(10) value;  //Data size
         *n pointer value;  //Misc pointer
       end-pr;

       dcl-pr CloseFile extproc('_C_IFS_fclose');
         *n pointer value;  //Misc pointer
       end-pr;

       Dcl-C CMD_LEN 300;

       dcl-s PathFile char(CMD_LEN) ;
       dcl-s RtvData char(CMD_LEN) ;
       dcl-s OpenMode char(5) ;
       dcl-s FilePtr pointer inz ;

       //*********************************************

       Dcl-C gRepoZip  'REPO.ZIP';
       Dcl-S gUser     Char(10)     Inz(*User);

       Dcl-S IFSLINK   Varchar(256); //Ending with /
       Dcl-s INTOLIB   Char(10);

       Dcl-S gMode  Char(10);
       Dcl-S gFails Int(3);

       Dcl-Ds gPackage Qualified;
         Name Varchar(32);
         Ver  Varchar(10);
       End-Ds;

       //*********************************************

       Dcl-Pi RELIC;
         pZIPLoc      Char(128) Const;
         pNewDir      Char(50)  Const;
         pLib         Char(10)  Const;
         pFetchOption Char(10)  Const;
       END-PI;

       If (%Parms < 4);
         Print('Three parameters required.');
         Return;
       ENDIF;

       If (pZIPLoc = *Blank OR pLib = *Blank);
         Print('Location and Library cannot be blank.');
         Return;
       ENDIF;

       //*********************************************

       INTOLIB  = pLib;
       IFSLINK  = '/home/' + %Trim(gUser) + '/';

       gFails   = 0;

       If (BUILD_Prepare());

         If (gFails = 0);
           Print('Built from ' + %Trim(pZIPLoc) + ' sucessfully.');
           BUILD_Command('RMDIR DIR(''' + IFSLINK + ''') SUBTREE(*ALL)');
         Else;
           Print('Attempted to build ' + %Trim(pZIPLoc) + '.');
           Print(' > error count: ' + %Char(gFails));
           Print(' > directory not deleted');
         ENDIF;
       Endif;

       *InLR = *On;
       Return;

       //*********************************************

       Dcl-Proc Print;
         Dcl-Pi Print;
           pValue Char(128) Const;
         END-PI;

         printf(%Trim(pValue) + x'25');
       End-Proc;

       //*********************************************

       //FILE_Download will now just
       //download the repo ZIP to the IFS.
       Dcl-Proc FILE_Download;
         Dcl-Pi *N Ind;
           pLocation Varchar(128) Const; //File
         END-PI;

         Dcl-S lFile SQLTYPE(BLOB_FILE);

         //Will download to Current Directory
         lFile_Name = IFSLINK + gRepoZip;
         lFile_NL   = %Len(%TrimR(lFile_Name));
         lFile_FO   = SQFOVR;

         Exec SQL
           SELECT SYSTOOLS.HTTPGETBLOB(:pLocation, '') lFile_DATA
           INTO :lFile
           FROM SYSIBM.SYSDUMMY1;

         Return (SQLSTATE = '00000');

       END-PROC;

       //*********************************************

       Dcl-Proc BUILD_Prepare;
         Dcl-Pi *N Ind End-Pi;

         Dcl-S lBuild   Varchar(CMD_LEN);
         Dcl-S lComment Ind;
         Dcl-S lComTxt  Char(2);

         gPackage.Name = %Trim(pNewDir);
         gPackage.Ver  = '1';

         // Only download if needed; allow for local build-only
         If (pFetchOption = '*FETCH');

           //Download ZIP
           If (FILE_Download(%Trim(pZIPLoc)) = *Off);
             Print('Failed to download ZIP.');
             Return *Off;
           Else;
             Print('ZIP downloaded..');
           ENDIF;

           //Extract the ZIP file
           BUILD_Command('QSH CMD(''jar xf ' + IFSLINK + gRepoZip + ''')');
           BUILD_Command('RMVLNK OBJLNK(''' + IFSLINK + gRepoZip + ''')');
         endif;

         //Use the new folder incase it extracts into a folder
         If (pNewDir <> *Blank);
           IFSLINK += %Trim(pNewDir) + '/';
         ENDIF;

         //Process the build file
         PathFile = IFSLINK + 'build.txt' + x'00';
         OpenMode = 'r' + x'00';
         FilePtr  = OpenFile(%addr(PathFile):%addr(OpenMode));

         If (FilePtr = *null);
           Print('Failed to read build file.');
           Return *Off;
         EndIf;

         //When lComment = *On, ignore line
         lComment = *Off;

         dow  (ReadFile(%addr(RtvData):%Len(RtvData):FilePtr) <> *null);
           RtvData = %Trim(RtvData);
           If (%Subst(RtvData:1:1) = x'25');
             Iter;
           ENDIF;

           RtvData = %xlate(x'00':' ':RtvData) ;  //End of record null
           RtvData = %xlate(x'25':' ':RtvData) ;  //Line feed (LF)
           RtvData = %xlate(x'0D':' ':RtvData) ;  //Carriage return (CR)
           RtvData = %xlate(x'05':' ':RtvData) ;  //Tab
           lBuild = %Trim(RtvData);

           If (lBuild = *Blank);
             Iter;
           ENDIF;

           If (%Len(lBuild) > 2);
             lComTxt = %Subst(lBuild:1:2);
             Select;
               When (lComTxt = '//');
                 Iter;
               When (lComtxt = '/*');
                 lComment = *On;
             ENDSL;

             lComTxt = %Subst(lBuild:%Len(lBuild)-1:2);
             If (lComTxt = '*/');
               lComment = *Off;
               Iter;
             ENDIF;
           ENDIF;

           If (lComment = *On);
             Iter;
           ENDIF;

           Select;

             When (lBuild = 'dirs:');
               Print('Directories directive not supported in build file.');

             When (lBuild = 'files:');
               Print('Files directive not supported in build file.');

             When (lBuild = 'build:');
               gMode = '*BUILD';

             When (lBuild = 'version:');
               gMode = '*VER';

             When (lBuild = 'name:');
               gMode = '*NAME';

             Other;
               Select;
                 When (gMode = '*BUILD');
                   BUILD_Command(lBuild);

                 When (gMode = '*NAME');
                   gPackage.Name = %Trim(lBuild);

                 When (gMode = '*VER');
                   gPackage.Ver = %Trim(lBuild);

               ENDSL;

           ENDSL;

           RtvData = ' ';
         enddo;

         CloseFile(FilePtr);

         Return *On;
       End-Proc;

       //*********************************************

       Dcl-Proc BUILD_Command;
         Dcl-Pi *N;
           pCmd Char(CMD_LEN) Value;
         END-PI;

         pCmd = %ScanRpl('&INTOLIB':%Trim(INTOLIB):pCmd);
         pCmd = %ScanRpl('&DIR/':%Trim(IFSLINK):pCmd);
         pCmd = %ScanRpl('&NAME':%Trim(gPackage.Name):pCmd);
         pCmd = %ScanRpl('&VER':%Trim(gPackage.Ver):pCmd);

         Monitor;
           If (Cmd(pCmd) = 1);
             gFails += 1;
             Print(%Subst(pCmd:1:52) + ' ...');
             Print('> ' + errmsgid);
             Print(*Blank);
           ENDIF;
         On-Error *All;
           gFails += 1;
           Print(%Subst(pCmd:1:52) + ' ...');
           Print('> Caused program crash');
           Print(*Blank);
         Endmon;
       END-PROC;

       //********************************************* 