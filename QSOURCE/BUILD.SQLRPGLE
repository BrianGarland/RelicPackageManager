
       Ctl-Opt DftActGrp(*No) ActGrp(*NEW);

       //*********************************************

       dcl-pr Cmd int(10) extproc('system');
         cmdstring pointer value options(*string);
       end-pr;
       Dcl-s errmsgid char(7)        import('_EXCP_MSGID');

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

       Dcl-C CMD_LEN 2200;
       Dcl-C VAR_LEN 512;

       Dcl-Ds File_Temp Qualified Template;
         PathFile char(CMD_LEN);
         RtvData char(CMD_LEN);
         OpenMode char(5);
         FilePtr pointer inz;
       End-ds;

       Dcl-Ds gBuildFile  LikeDS(File_Temp);

       //*********************************************

       Dcl-S gUser  Char(10) Inz(*USER);
       Dcl-S gMode  Char(10); //Used for scanning build file
       Dcl-S gLib   Char(10);

       Dcl-S gLine  Int(5); //Current build file line
       Dcl-S gFails Int(3);

       Dcl-Ds Vars_Template Template;
         Key   Char(10);
         Value Pointer Inz(*Null);
       End-Ds;

       Dcl-Ds gPackage Qualified;
         Name   Varchar(32) Inz('');
         Ver    Varchar(10) Inz('');
         MonMsg Like(errmsgid)        Dim(48);
         Vars   LikeDS(Vars_Template) Dim(20);
       End-Ds;

       Dcl-S gIfBlock Ind Inz(*On);

       //*********************************************

       Dcl-Pi BUILD;
         pLib Char(10);
       END-PI;
       
       gLib = pLib;
       If (gLib = *Blank);
         Print('Library not provided. Defaulting to #RELIC.');
         
         gPackage.MonMsg(1) = 'CPF2111';
         gLib = '#RELIC';
         BUILD_Command('CRTLIB ' + gLib);
       ENDIF;

       Print('Build process starting.');

       BUILD_AddVar('&INTOLIB':%Trim(gLib));
       BUILD_AddVar('&USER':%TrimR(gUser));

       BUILD_Prepare();
       
       BUILD_End();

       *InLR = *On;
       Return;

       //*********************************************

       Dcl-Proc Print;
         Dcl-Pi Print;
           pValue Char(132) Value;
         END-PI;

         pValue = %TrimR(pValue) + x'25';
         printf(%Trim(pValue));
       End-Proc;

              //*********************************************

       Dcl-Proc BUILD_Prepare;
         Dcl-Pi *N Ind End-Pi;

         Dcl-S lBuild    Varchar(CMD_LEN);
         Dcl-S lComment  Ind;
         Dcl-S lComTxt   Char(2);
         Dcl-S lMonMsg   Int(3);
         Dcl-S lVarInd   Int(5);
         Dcl-S lLength   Int(5);

         //Will use current directory
         BUILD_AddVar('&DIR/':'');
         BUILD_AddVar('&DIR\':'');

         //Process the build file
         gBuildFile.PathFile = 'build.txt' + x'00';
         gBuildFile.OpenMode = 'r' + x'00';
         gBuildFile.FilePtr  = OpenFile(%addr(gBuildFile.PathFile)
                                       :%addr(gBuildFile.OpenMode));

         If (gBuildFile.FilePtr = *null);
           Print('Failed to read build file.');
           Return *Off;
         Else;
           gLine = 0;
         EndIf;

         //When lComment = *On, ignore line
         lComment  = *Off;
         lBuild    = '';

         dow  (ReadFile(%addr(gBuildFile.RtvData)
                       :%Len(gBuildFile.RtvData)
                       :gBuildFile.FilePtr) <> *null);
           gLine += 1;
           gBuildFile.RtvData = %Trim(gBuildFile.RtvData);
           If (%Subst(gBuildFile.RtvData:1:1) = x'25');
             Iter;
           ENDIF;

           gBuildFile.RtvData = %xlate(x'00':' ':gBuildFile.RtvData);//End of record null
           gBuildFile.RtvData = %xlate(x'25':' ':gBuildFile.RtvData);//Line feed (LF)
           gBuildFile.RtvData = %xlate(x'0D':' ':gBuildFile.RtvData);//Carriage return (CR)
           gBuildFile.RtvData = %xlate(x'05':' ':gBuildFile.RtvData);//Tab

           If (gBuildFile.RtvData = *Blank);
             Iter;
           Else;
             lBuild = %Trim(gBuildFile.RtvData);
             lLength = %Len(lBuild);
             gBuildFile.RtvData = *Blank;
           ENDIF;

           If (%Len(lBuild) >= 2);
             lComTxt = %Subst(lBuild:1:2);
             Select;
               When (lComTxt = '//');
                 Iter;
               When (lComtxt = '/*');
                 lComment = *On;
             ENDSL;

             lComTxt = %Subst(lBuild:lLength-1:2);
             If (lComTxt = '*/');
               lComment = *Off;
               Iter;
             ENDIF;
           ENDIF;

           If (lComment = *On);
             lBuild = '';
             Iter;
           ENDIF;

           Select;

             When (%Subst(lBuild:1:1) = '&' AND gIfBlock);
               lVarInd = %Scan(':':lBuild);
               If (lVarInd > 0);
                 Monitor;
                   BUILD_AddVar(%Subst(lBuild:1:lVarInd-1)
                               :%Subst(lBuild:lVarInd+1));
                 On-Error;
                   Print( 'Failed to register "'
                        + %Subst(lBuild:1:lVarInd) + '"');
                 Endmon;
               Endif;

             When (lBuild = 'dirs:');
               Print('Directories directive not supported in build file.');

             When (lBuild = 'files:');
               Print('Files directive not supported in build file.');

             When (lBuild = 'name:');
               gMode = '*NAME';

             When (lBuild = 'version:');
               gMode = '*VER';

             when (lBuild = 'licenses:');
               Print('License mode currently not supported.');
               gMode = '*LIC';

             When (lBuild = 'monmsg:');
               gMode = '*MONMSG';

             When (lBuild = 'build:');
               gMode = '*BUILD';

             Other;
               Select;
                 When (gMode = '*NAME');
                   gPackage.Name = %Trim(lBuild);
                   BUILD_AddVar('&NAME':gPackage.Name);

                 When (gMode = '*VER');
                   gPackage.Ver = %Trim(lBuild);
                   BUILD_AddVar('&VER':gPackage.Ver);

                 When (gMode = '*MONMSG');
                   lMonMsg = %Lookup(*Blank:gPackage.MonMsg);

                   //If there is space, add it to the monmsg array list
                   If (lMonMsg > 0);
                     gPackage.MonMsg(lMonMsg) = lBuild;
                   Else;
                     Print( 'Unable to monitor "' + lBuild + '". Max capaticy '
                          + 'for monitors hit.');
                   Endif;

                 When (gMode = '*BUILD');

                   If (BUILD_HandleStatement(lBuild));
                     If (gIfBlock);
                       BUILD_Command(lBuild);
                     Endif;
                   Endif;

               ENDSL;

           ENDSL;

         enddo;

         CloseFile(gBuildFile.FilePtr);

         Return *On;
       End-Proc;

       //*********************************************
       // Returns *On if command should run
       // False otherwise

       Dcl-Proc BUILD_HandleStatement;
         Dcl-Pi *N Ind;
           pCmd Varchar(CMD_LEN);
         END-PI;

         Dcl-S lResult Ind;
         Dcl-S lCur    Int(5) Inz(1);
         Dcl-S lIndex  Int(3) Inz(1);
         Dcl-S lParms  Varchar(100) Dim(3);
         Dcl-S lChar   Char(1);
         Dcl-S lSpeech Ind Inz(*Off);

         For lCur = 1 to %Len(pCmd);
           If (lIndex > %Elem(lParms));
             Leave;
           ENDIF;

           lChar = %Subst(pCmd:lCur:1);
           Select;
             When (lChar = ' ');
               If (lSpeech);
                 lParms(lIndex) += lChar;
               Else;
                 lIndex += 1;
               ENDIF;

             When (lChar = '"');
               lSpeech = NOT lSpeech;

             Other;
               lParms(lIndex) += lChar;
           ENDSL;
         ENDFOR;

         lResult = *Off;
         Select;
           When (lParms(1) = 'ifeq');
             Exsr fixParms;
             gIfBlock = (lParms(2) = lParms(3));
           When (lParms(1) = 'ifneq');
             Exsr fixParms;
             gIfBlock = (lParms(2) <> lParms(3));
           When (lParms(1) = 'ifdef');
             gIfBlock = (%Lookup(lParms(2):gPackage.Vars(*).Key) > 0);
           When (lParms(1) = 'ifndef');
             gIfBlock = (%Lookup(lParms(2):gPackage.Vars(*).Key) = 0);

           When (lParms(1) = 'else');
             gIfBlock = NOT gIfBlock;
           When (lParms(1) = 'end');
             gIfBlock = *On;

           Other;
             lResult = *On;

         ENDSL;

         Return lResult;
         
         Begsr fixParms;
           For lCur = 2 to %Elem(lParms);
             If (%Len(lParms(lCur)) > 0);
               If (%Subst(lParms(lCur):1:1) = '&');
                 lIndex = %Lookup(lParms(lCur):gPackage.Vars(*).Key);
                 If (lIndex > 0);
                   lParms(lCur) = %Str(gPackage.Vars(lIndex).Value);
                 Endif;
               Endif;
             EndIf;
           Endfor;
         Endsr;
       END-PROC;

       //*********************************************

       Dcl-Proc BUILD_Command;
         Dcl-Pi *N;
           pCmd Char(CMD_LEN) Value;
         END-PI;

         Dcl-S lIndex Int(3);
         Dcl-S lKey   Varchar(10);

         For lIndex = 1 to %Lookup(*Blank:gPackage.Vars(*).Key) - 1;

           //Trim it down
           lKey = %TrimR(gPackage.Vars(lIndex).Key);

           //If the command contains a defined variable
           If (%Scan(lKey:pCmd) > 0);

             //Replace the key with the value
             pCmd = %ScanRpl(lKey
                            :%Str(gPackage.Vars(lIndex).Value)
                            :pCmd);

           Endif;
         Endfor;

         Monitor;
           If (Cmd(pCmd) = 1);

             //If the error is not in the monmsg list
             //then do display it
             If (%Lookup(errmsgid:gPackage.MonMsg) = 0);
               gFails += 1;
               Print(*Blank);
               Print('ERROR: ');
               Print(' > ' + %TrimR(pCmd));
               Print(' > ' + errmsgid);
               Print(' > Build file line: ' + %Char(gLine));
               Print(*Blank);
             Endif;

           Else;

             Print(%TrimR(%Subst(pCmd:1:36)) + ' ... successful.');

           ENDIF;
         On-Error *All;
           gFails += 1;
           Print(*Blank);
           Print(%Subst(pCmd:1:52) + ' ...');
           Print( '> Caused program crash. See job log for '
                + 'possible information.');
           Print(*Blank);
         Endmon;
       END-PROC;

       //*********************************************

       Dcl-Proc BUILD_AddVar;
         Dcl-Pi *N;
           pKey   Char(10)         Const;
           pValue Varchar(VAR_LEN) Value;
         End-Pi;

         Dcl-S lIndex Int(3);
         Dcl-S lLen   Int(5);

         lIndex = %Lookup(pKey:gPackage.Vars(*).Key);
         If (lIndex = 0);
           lIndex = %Lookup(*Blank:gPackage.Vars(*).Key);
         Endif;
         
         pValue = %Trim(pValue);
         lLen = %Len(pValue) + 1;

         If (lIndex > 0);
           gPackage.Vars(lIndex).Key   = pKey;
           
           If (gPackage.Vars(lIndex).Value = *Null);
             gPackage.Vars(lIndex).Value = %Alloc(lLen);
           Else;
             gPackage.Vars(lIndex).Value = 
                %Realloc(gPackage.Vars(lIndex).Value:lLen);
           Endif;
           %Str(gPackage.Vars(lIndex).Value:lLen) = %Trim(pValue);
         Else;
           Print('Failed to register "' + %Trim(pKey) + '"');
         Endif;
       End-Proc;

       //*********************************************
       
       Dcl-Proc BUILD_End;
         Dcl-S lLen   Int(3);
         Dcl-S lIndex Int(3);
         Dcl-S lPtr   Pointer;
         
         Print('Built ' + gPackage.Name + ' with '
                + %Char(gFails) + ' error(s)');
         
         lLen = %Lookup(*Blank:gPackage.Vars(*).Key);
         If (lLen = 0);
           lLen = %Elem(gPackage.Vars);
         Endif;
         
         For lIndex = 1 to lLen;
           //Dealloc(NE) gPackage.Vars(lIndex).Value;
           lPtr = gPackage.Vars(lIndex).Value;
           Dealloc(NE) lPtr;
         Endfor;
       End-Proc;