;TITLE    GAME4TH     
PAGE  60,132  
STSEG  SEGMENT  
       DB 64 DUP (0)  
STSEG  ENDS  
;-----------------------------------  
DTSEG  SEGMENT  
DATAH  DB   10H,10H,10H,10H,10H,10H,10H,10H,10H  
DATAL  DB   20H,21H,22H,23H,24H,25H,26H,27H,28H  
DTSEG  ENDS  
CR     EQU 0DH  
LF     EQU 0AH  
;------------------------------------  
CDSEG SEGMENT   
MAIN  PROC FAR  
      ASSUME CS:CDSEG,DS:DTSEG,SS:STSEG  
      MOV  AX,DTSEG  
      MOV  DS,AX  
      MOV  AX,0600H  
      MOV  BH,00011110B  
      MOV  CX,0  
      MOV  DH,18H  
      MOV  DL,04FH  
      INT  10H  
        
FISH: MOV  AX,0600H  
      MOV  BH,00011110B  
      MOV  CX,0  
      MOV  DH,18H  
      MOV  DL,04FH  
      INT  10H  
      MOV  AH,02   
      MOV  BH,00       
      MOV  SI,OFFSET DATAH  
      MOV  DI,OFFSET DATAL        
      MOV  DH,[SI]  
      MOV  DL,[DI]  
      INT  10H  
      MOV  AX,0201H  
      MOV  DL,'+'  
      INT  21H  
      MOV  AH,02   
      MOV  BH,00  
      MOV  DH,[SI]+1  
      MOV  DL,[DI]+1  
      INT  10H   
      MOV  AX,0201H  
      MOV  DL,'#'  
      INT  21H  
      MOV  AH,02   
      MOV  BH,00  
      MOV  DH,[SI]+2  
      MOV  DL,[DI]+2  
      INT  10H   
      MOV  AX,0201H  
      MOV  DL,'#'  
      INT  21H  
      MOV  AH,02   
      MOV  BH,00  
      MOV  DH,[SI]+3  
      MOV  DL,[DI]+3  
      INT  10H   
      MOV  AX,0201H  
      MOV  DL,'#'  
      INT  21H  
      MOV  AH,02   
      MOV  BH,00  
      MOV  DH,[SI]+4  
      MOV  DL,[DI]+4  
      INT  10H   
      MOV  AX,0201H  
      MOV  DL,'#'  
      INT  21H  
      MOV  AH,02   
      MOV  BH,00  
      MOV  DH,[SI]+5  
      MOV  DL,[DI]+5  
      INT  10H   
      MOV  AX,0201H  
      MOV  DL,'#'  
      INT  21H  
      MOV  AH,02   
      MOV  BH,00  
      MOV  DH,[SI]+6  
      MOV  DL,[DI]+6  
      INT  10H   
      MOV  AX,0201H  
      MOV  DL,'#'  
      INT  21H  
      MOV  AH,02   
      MOV  BH,00  
      MOV  DH,[SI]+7  
      MOV  DL,[DI]+7  
      INT  10H   
      MOV  AX,0201H  
      MOV  DL,'#'  
      INT  21H  
      MOV  AH,02   
      MOV  BH,00  
      MOV  DH,[SI]+8  
      MOV  DL,[DI]+8  
      INT  10H   
      MOV  AX,0201H  
      MOV  DL,'>'  
      INT  21H                        
        
LOOP1:MOV  AH,0     ;—≠ª∑ ‰»Î  
      MOV  AL,0  
      INT  16H  
      CMP  AH,72  
      JE   UP                  
      CMP  AH,80  
      JE   DOWN     
      CMP  AH,77  
      JE   RIGHT  
      CMP  AH,75  
      JE   LEFT    
         
UP:   MOV  SI,OFFSET DATAH  
      MOV  DI,OFFSET DATAL        
      MOV  DH,[SI]+8  
      MOV  DL,[DI]+8  
      MOV  CH,DH  
      MOV  CL,DL  
      DEC  DH  
      MOV  [SI]+8,DH  
      MOV  [DI]+8,DL    
      JMP  BACK              
                 
DOWN: MOV  SI,OFFSET DATAH  
      MOV  DI,OFFSET DATAL        
      MOV  DH,[SI]+8  
      MOV  DL,[DI]+8  
      MOV  CH,DH  
      MOV  CL,DL  
      INC  DH  
      MOV  [SI]+8,DH  
      MOV  [DI]+8,DL   
      JMP  BACK           
   
LEFT: MOV  SI,OFFSET DATAH  
      MOV  DI,OFFSET DATAL        
      MOV  DH,[SI]+8  
      MOV  DL,[DI]+8  
      MOV  CH,DH  
      MOV  CL,DL  
      DEC  DL  
      MOV  [SI]+8,DH  
      MOV  [DI]+8,DL   
      JMP  BACK            
    
RIGHT:MOV  SI,OFFSET DATAH  
      MOV  DI,OFFSET DATAL        
      MOV  DH,[SI]+8  
      MOV  DL,[DI]+8  
      MOV  CH,DH  
      MOV  CL,DL  
      INC  DL  
      MOV  [SI]+8,DH  
      MOV  [DI]+8,DL   
      JMP  BACK  
              
BACK: MOV  DH,[SI]+7  
      MOV  DL,[DI]+7    
      MOV  [SI]+7,CH  
      MOV  [DI]+7,CL   
      MOV  CH,DH  
      MOV  CL,DL  
      MOV  DH,[SI]+6  
      MOV  DL,[DI]+6    
      MOV  [SI]+6,CH  
      MOV  [DI]+6,CL   
      MOV  CH,DH  
      MOV  CL,DL  
      MOV  DH,[SI]+5  
      MOV  DL,[DI]+5    
      MOV  [SI]+5,CH  
      MOV  [DI]+5,CL   
      MOV  CH,DH  
      MOV  CL,DL  
      MOV  DH,[SI]+4  
      MOV  DL,[DI]+4    
      MOV  [SI]+4,CH  
      MOV  [DI]+4,CL   
      MOV  CH,DH  
      MOV  CL,DL  
      MOV  DH,[SI]+3  
      MOV  DL,[DI]+3    
      MOV  [SI]+3,CH  
      MOV  [DI]+3,CL   
      MOV  CH,DH  
      MOV  CL,DL   
      MOV  DH,[SI]+2  
      MOV  DL,[DI]+2    
      MOV  [SI]+2,CH  
      MOV  [DI]+2,CL   
      MOV  CH,DH  
      MOV  CL,DL  
      MOV  DH,[SI]+1  
      MOV  DL,[DI]+1    
      MOV  [SI]+1,CH  
      MOV  [DI]+1,CL   
      MOV  CH,DH  
      MOV  CL,DL   
      MOV  DH,[SI]  
      MOV  DL,[DI]    
      MOV  [SI],CH  
      MOV  [DI],CL   
      MOV  CH,DH  
      MOV  CL,DL  
      JMP  FISH        
        
MAIN  ENDP   
CDSEG ENDS         
      END  MAIN 