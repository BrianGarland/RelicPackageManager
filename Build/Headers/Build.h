       Dcl-Pr Cmd int(10) extproc('system');
         cmdstring pointer value options(*string);
       End-Pr;
       
       Dcl-Pr printf Int(10) ExtProc('printf');
         format Pointer Value Options(*String);
       End-Pr;
       
       Dcl-Pr GetEnv Pointer ExtProc('getenv');
         envvar Pointer Value Options(*String);
       END-PR;
       
       Dcl-Pr GetCwd Pointer ExtProc('getcwd');
         data Pointer Value;
         size Uns(10) Value;
       End-Pr;

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
       
       dcl-pr WriteFile pointer extproc('_C_IFS_fwrite');
         *n pointer value;  //Write data
         *n int(10) value;  //Data size
         *n int(10) value;  //Block size
         *n pointer value;  //Misc pointer
       end-pr;

       dcl-pr CloseFile extproc('_C_IFS_fclose');
         *n pointer value;  //Misc pointer
       end-pr;