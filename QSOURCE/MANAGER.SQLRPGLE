
       //MANAGER is part of the Relic Package Manager

       Ctl-Opt DftActGrp(*No) ActGrp(*NEW);

       dcl-pr Cmd int(10) extproc('system');
         cmdstring pointer value options(*string);
       end-pr;

       Dcl-F PACKAGES Workstn;

       Dcl-S  gForceDL  Ind;
       Dcl-S  gPkgCount Int(5) Inz(10);
       Dcl-Ds gPackages Qualified Dim(50);
         Name   Char(32);
         Desc   Char(64);
         Link   Char(128);
         Folder Char(64);
       END-DS;

       Dcl-S gEntry Char(2) Dim(10);

       //Mainline

       MGR_LoadPackages('');
       If (gForceDL = *On);
         MGR_DownloadPackages();
         MGR_LoadPackages('');
       ENDIF;

       MGR_Display();

       *InLR = *On;
       Return;

       //*****************************

       Dcl-Proc MGR_DownloadPackages;

         Dcl-C cLoc  '/tmp/pkglist.sql';
         Dcl-S lFile SQLTYPE(BLOB_FILE);
         Dcl-S lURL  Varchar(128);

         lURL       = 'https://raw.githubusercontent.com/OSSILE/'
                    + 'RelicPackageManager/master/pkglist.sql';
         lFile_Name = cLoc;
         lFile_NL   = %Len(%TrimR(lFile_Name));
         lFile_FO   = SQFOVR;

         Exec SQL
           SELECT SYSTOOLS.HTTPGETBLOB(:lURL, '') lFile_DATA
           INTO :lFile
           FROM SYSIBM.SYSDUMMY1;

         If (SQLSTATE = '00000');
           Cmd('QSYS/RUNSQLSTM SRCSTMF(''' + cLoc + ''') COMMIT(*NONE)');
         ENDIF;

       END-PROC;

       //*****************************

       Dcl-Proc MGR_LoadPackages;
         Dcl-Pi *N;
           pName Char(20) Value; //Search for a package
         END-PI;

         Dcl-S lQuery Varchar(128);

         Clear gPackages;

         If (pName = *Blank);
           lQuery = 'SELECT '
                    + 'PKG_NAME, '
                    + 'PKG_DESC, '
                    + 'PKG_LINK, '
                    + 'PKG_FLDNAME '
                  + 'FROM '
                    + '#RELIC/PKGLIST '
                  + 'ORDER BY '
                    + 'PKG_ID DESC';
         Else;
           pName  = %ScanRpl('''':'''''':pName);
           lQuery = 'SELECT '
                    + 'PKG_NAME, '
                    + 'PKG_DESC, '
                    + 'PKG_LINK, '
                    + 'PKG_FLDNAME '
                  + 'FROM '
                    + '#RELIC/PKGLIST '
                  + 'WHERE '
                  + 'UPPER(PKG_NAME) LIKE ''' + %Trim(pName) + '%''';
         ENDIF;

         EXEC SQL
           PREPARE PkgQuery FROM :lQuery;
         EXEC SQL
           DECLARE SrchPkg CURSOR FOR PkgQuery;

         EXEC SQL OPEN SrchPkg;
         EXEC SQL
           FETCH NEXT FROM SrchPkg
           FOR 50 ROWS
           INTO :gPackages;

         gPkgCount = SQLER3;
         gForceDL  = (gPkgCount = 0);
         LOADED    = %Char(SQLER3);

         If (gPkgCount < 10);
           gPkgCount = 10;
         ENDIF;

         EXEC SQL CLOSE SrchPkg;

       END-PROC;

       //*****************************

       Dcl-Proc MGR_Display;
         Dcl-S lExit Ind Inz(*Off);

         Dcl-S lIndex  Int(5);

         lIndex = 1;
         Dow (lExit = *Off);

           NAME1  = gPackages(lIndex    ).Name;
           NAME2  = gPackages(lIndex + 1).Name;
           NAME3  = gPackages(lIndex + 2).Name;
           NAME4  = gPackages(lIndex + 3).Name;
           NAME5  = gPackages(lIndex + 4).Name;
           NAME6  = gPackages(lIndex + 5).Name;
           NAME7  = gPackages(lIndex + 6).Name;
           NAME8  = gPackages(lIndex + 7).Name;
           NAME9  = gPackages(lIndex + 8).Name;
           NAME10 = gPackages(lIndex + 9).Name;

           DEV1  = gPackages(lIndex    ).Desc;
           DEV2  = gPackages(lIndex + 1).Desc;
           DEV3  = gPackages(lIndex + 2).Desc;
           DEV4  = gPackages(lIndex + 3).Desc;
           DEV5  = gPackages(lIndex + 4).Desc;
           DEV6  = gPackages(lIndex + 5).Desc;
           DEV7  = gPackages(lIndex + 6).Desc;
           DEV8  = gPackages(lIndex + 7).Desc;
           DEV9  = gPackages(lIndex + 8).Desc;
           DEV10 = gPackages(lIndex + 9).Desc;

           Exfmt LSTPKG;

           Select;
             When (*In12);
               lExit = *On;

             When (*In06);
               MGR_DownloadPackages();
               MGR_LoadPackages('');

             When (*In66); //Page down
               If ((lIndex+20) > gPkgCount);
                 lIndex = (gPkgCount+1)-10;
               Else;
                 lIndex += 10;
               ENDIF;

             When (*In44); //Page up
               If ((lIndex-10) < 1);
                 lIndex = 1;
               Else;
                 lIndex -= 10;
               ENDIF;

             Other;

               If (MGR_Options(lIndex) = *Off);
                 MGR_LoadPackages(SEARCH);
                 lIndex = 1;
               ENDIF;

               ENT1  = *Blank;
               ENT2  = *Blank;
               ENT3  = *Blank;
               ENT4  = *Blank;
               ENT5  = *Blank;
               ENT6  = *Blank;
               ENT7  = *Blank;
               ENT8  = *Blank;
               ENT9  = *Blank;
               ENT10 = *Blank;

           ENDSL;

         ENDDO;
       END-PROC;

       //*****************************

       Dcl-Proc MGR_Options;
         Dcl-Pi *N Ind;
           pIndex Int(5) Const;
         END-PI;

         Dcl-S lRes   Ind;
         Dcl-S lIndex Int(3);
         Dcl-S lPkg   Int(5);
         Dcl-S lOpt   Char(2) Dim(10);

         lRes     = *Off;
         lOpt(1)  = ENT1;
         lOpt(2)  = ENT2;
         lOpt(3)  = ENT3;
         lOpt(4)  = ENT4;
         lOpt(5)  = ENT5;
         lOpt(6)  = ENT6;
         lOpt(7)  = ENT7;
         lOpt(8)  = ENT8;
         lOpt(9)  = ENT9;
         lOpt(10) = ENT10;

         For lIndex = 1 to 10;
           lPkg = (pIndex + lIndex) - 1;
           Select;

             When (lOpt(lIndex) = '11');
               lRes = *On;
               If (gPackages(lPkg).Name <> *Blank);
                 MGR_Install(lPkg);
               ENDIF;

           ENDSL;
         ENDFOR;

         Return lRes;
       END-PROC;

       //*****************************

       Dcl-Proc MGR_Install;
         Dcl-Pi *N;
           pIndex Int(5) Const;
         END-PI;

         Dcl-S lExit Ind Inz(*Off);

         PKGNAME   = gPackages(pIndex).Name;
         PKGDESC1  = %Subst(gPackages(pIndex).Desc:1:26);
         PKGDESC2  = %Subst(gPackages(pIndex).Desc:27:26);

         INTOLIB   = 'QTEMP';
         PRINTMODE = '*DSP';

         Dow (lExit = *Off);
           Exfmt INSTALL;

           Select;
             When (*In12);
               lExit = *On;

             Other;
               If (PRINTMODE = '*DSP' OR
                   PRINTMODE = '*SPOOL');

                 Cmd( 'RELICGET '
                    + 'PLOC(''' + %Trim(gPackages(pIndex).Link) + ''') '
                    + 'PDIR(''' + %Trim(gPackages(pIndex).Folder) + ''') '
                    + 'PNAME(''' + %Trim(INTOLIB) + ''') '
                    + 'PFETCH(*FETCH) '
                    + 'PLOG(''' + %Trim(PRINTMODE) + ''')');

                 lExit = *On;
               ENDIF;
           ENDSL;
         ENDDO;
       END-PROC; 