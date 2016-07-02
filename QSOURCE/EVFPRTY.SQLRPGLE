
       Ctl-Opt DftActGrp(*No) ActGrp(*NEW);

       Dcl-Pi EVFPRTY;
         pLib  Char(10);
         pMbr  Char(10);
         pDSP  Char(4);
         pInfo Char(4);
       END-PI;

       //_________________________________________________________


       dcl-pr Cmd int(10) extproc('system');
         cmdstring pointer value options(*string);
       end-pr;

       //_________________________________________________________

       Dcl-C cAlias  'EVFEVENT';
       Dcl-C gSQLLen 128;

       Dcl-S gData  Char(300);
       Dcl-S gQuery Varchar(gSQLLen);

       Dcl-Ds gStreamFile LikeDS(File_Temp);
       Dcl-Ds File_Temp   Qualified          Template;
         PathFile char(128);
         RtvData  char(256);
         OpenMode char(5);
         FilePtr  pointer inz;
       End-ds;

       Dcl-S gShowInfo Ind;
       Dcl-S gDisplay  Ind;

       gShowInfo = (pInfo = '*YES');
       gDisplay  = (pDSP  = '*YES');

       //_________________________________________________________

       If (LOG_Prepare());

         Print('EVFPRETTY (Part of RPM)');
         Print('  Program: ' + %Trim(pLib) + '/' + %Trim(pMbr));
         Print('Show info: ' + %Trim(pInfo));
         Print(*Blank);

         Print('Note: Line numbers will be incorrect for SQLRPGLE.');
         Print(*Blank);

         Print('Type  Sev Line   ID      Text');
         Print('----- --  ------ ------- --->');
         Print(*Blank);

         Pretty_Open();
         Dow (Pretty_Read());
           Pretty_Parse();
         ENDDO;
         Pretty_Close();

         LOG_Close();

         If (gDisplay);
           Cmd('DSPF STMF(''' + %Trim(pLib) + '_'
                              + %Trim(pMbr) + '.txt'')');
         Endif;

       Endif;

       *InLR = *On;
       Return;

       //_________________________________________________________

       Dcl-Proc SqlExecute;
         Dcl-PI SqlExecute;
           pSQLQUERY Varchar(gSQLLen);
         END-PI;

         Exec SQL Execute Immediate :pSQLQUERY;
       END-PROC;

       //_________________________________________________________

       Dcl-Proc Pretty_Open;

         gQuery = 'CREATE ALIAS QTEMP/' + cAlias + ' FOR '
                + %Trim(pLib) + '/'
                + 'EVFEVENT'
                + '(' + %Trim(pMbr) + ')';
         SqlExecute(gQuery);

         EXEC SQL
           DECLARE Pretty_Cur CURSOR FOR
             SELECT * FROM QTEMP/EVFEVENT;

         EXEC SQL OPEN Pretty_Cur;

       END-PROC;

       //_________________________________________________________

       Dcl-Proc Pretty_Read;
         Dcl-Pi *N Ind End-Pi;

         EXEC SQL
           FETCH Pretty_Cur INTO :gData;

         Return (SQLSTATE = '00000');

       END-PROC;

       //_________________________________________________________

       Dcl-Proc Pretty_Parse;

         Dcl-S  lTag Char(10);
         Dcl-Ds lData Qualified;
           Type    Char(1);
           LineNum Char(6);
           Sev     Char(2);
           MsgId   Char(7);
           MsgTxt  Char(100);
         END-DS;

         lTag = %Subst(gData:1:10);

         Select;
           When (lTag = 'ERROR');
             lData.Type    = %Subst(gData:57:1);
             lData.Sev     = %Subst(gData:59:2);
             lData.LineNum = %Subst(gData:38:6);
             lData.MsgId   = %Subst(gData:49:7);
             lData.MsgTxt  = %Subst(gData:66:100);

             lData.LineNum = %TrimL(lData.LineNum:'0');
         ENDSL;

         Select;
           When (lData.Type = 'I' AND gShowInfo);
             Print( 'Info  '
                  + lData.Sev     + '  '
                  + lData.LineNum + ' '
                  + lData.MsgId   + ' '
                  + %TrimR(lData.MsgTxt));

           When (lData.Type = 'S');
             Print( 'Error '
                  + lData.Sev     + '  '
                  + lData.LineNum + ' '
                  + lData.MsgId   + ' '
                  + %TrimR(lData.MsgTxt));

           When (lData.Type = 'T');
             Print( 'Term. '
                  + lData.Sev     + '  '
                  + lData.LineNum + ' '
                  + lData.MsgId   + ' '
                  + %TrimR(lData.MsgTxt));
         ENDSL;

       END-PROC;

       //_________________________________________________________

       Dcl-Proc Pretty_Close;

         EXEC SQL
           CLOSE Pretty_Cur;

         gQuery = 'DROP ALIAS QTEMP/' + cAlias;
         SqlExecute(gQuery);

       End-Proc;

       //_________________________________________________________

       Dcl-Proc Print;
         Dcl-Pi *N;
           pValue Char(129) Value;
         END-PI;

         dcl-pr WriteFile pointer extproc('_C_IFS_fwrite');
           *n pointer value;  //Write data
           *n int(10) value;  //Data size
           *n int(10) value;  //Block size
           *n pointer value;  //Misc pointer
         end-pr;

         pValue = %TrimR(pValue) + x'25';

         WriteFile(%Addr(pValue)
                  :%Len(%TrimR(pValue))
                  :1
                  :gStreamFile.FilePtr);

       END-PROC;

       //_________________________________________________________

       Dcl-Proc LOG_Prepare;
         Dcl-Pi *N Ind End-Pi;

         dcl-pr OpenFile pointer extproc('_C_IFS_fopen');
           *n pointer value;  //File name
           *n pointer value;  //File mode
         end-pr;

         gStreamFile.PathFile = %Trim(pLib) + '_'
                              + %Trim(pMbr) + '.txt' + x'00';
         gStreamFile.OpenMode = 'ab' + x'00';
         gStreamFile.FilePtr  = OpenFile(%addr(gStreamFile.PathFile)
                                        :%addr(gStreamFile.OpenMode));

         Return (gStreamFile.FilePtr <> *null);
         //Returns *on if it failed to open
       End-Proc;

       //_________________________________________________________

       Dcl-Proc LOG_Close;

         dcl-pr CloseFile extproc('_C_IFS_fclose');
           *n pointer value;  //Misc pointer
         end-pr;

         CloseFile(gStreamFile.FilePtr);
       End-Proc; 