    DATAS SEGMENT    
        Color   DB  1FH        ;����ı�����ɫ��  
        Count   DW  1          ;Count����1���Ǳ任����   
    DATAS ENDS  
       
    STACKS SEGMENT STACK 'S'  
        ;��ջ�δ���  
        DW 80 DUP(0)  
    STACKS ENDS  
      
    CODES SEGMENT  
        ASSUME CS:CODES,DS:DATAS,SS:STACKS  
    MAIN    PROC    FAR  
        MOV AX,DATAS  
        MOV DS,AX            ;�����ݶ�DATAS����DS��  
    ;------------------------------------------------------------------    
        MOV DX,SEG INT_1CH   ;SEG��Ŷε�ַ  
        MOV DS,DX  
        LEA DX,INT_1CH       ;�����Ӻ���INT_1CH ȡƫ�Ƶ�ַ      
          
        ;AH=25H����:���ж�����AL=�жϺ� DS:DX=���  
        MOV AH,25H                  
        MOV AL,1CH           ;�����µ�1CH�ж�����  
        INT 21H  
          
        ;�˳����򲢷��ز���ϵͳ  
        MOV AH,4CH  
        INT 21H  
    MAIN    ENDP      
    ;------------------------------------------------------------------  
    ;�ӳ���:��ʾ���� FAR(��������ӳ�����ͬһ�����)  
    INT_1CH     PROC    FAR  
        PUSH AX      ;����Ĵ���  
        PUSH BX  
        PUSH CX  
        PUSH DX  
        PUSH DS  
          
        STI                  ;���ж�  
        MOV AX,DATAS  
        MOV DS,AX            ;�����ݶ�DATAS����DS��  
          
        ;------------------------------------------  
        ;- INT 1CHϵͳ�ж�ÿ�뷢��18.2��          -  
        ;- Count������18Ϊ1��任������ɫ         -  
        ;- Count��ֵΪ1,�ȼ�1ִ��һ����ʾ��ɫ���� -  
        ;- ִ��ʱ��ֵΪ18,ÿ�μ�1,����0��������ɫ -  
        ;------------------------------------------  
          
        DEC Count            ;Count��ֵΪ1,�ȼ�1  
        JNZ Exit             ;JNZ(�����Ϊ0��ת) ����Count=0ִ�б���ɫ���           
    ;------------------------------------------------------------------   
        ;����BIOS10H��06���ж�������Ļ��ʼ�����Ͼ�  
          
        ;--------------------------------  
        ;- AL=�Ͼ����� AL=0ȫ��ĻΪ�հ� -  
        ;- BH=����������                -  
        ;- CH=���Ͻ��к� CL=���Ͻ��к�  -  
        ;- DH=���½��к� DL=���½��к�  -  
        ;--------------------------------     
      
        ;----------------------------------  
        ;- BL����ɫ����ΪIRGB|IRGB        -  
        ;- ��4λ�Ǳ���ɫ ��4λ��ǰ��ɫ    -  
        ;- I=���� R=�� G=�� B=�� ��8ɫ    -  
        ;----------------------------------  
          
        MOV AH,6         ;��ȫ��  
        MOV AL,0  
        MOV BH,Color         ;��ʼ����Ϊ���װ��� 1FH=0001(��ɫ)|1111B �����ϱ�  
        MOV CX,0  
        MOV DX,184FH         ;(ȫ��)��ʾ18��4F��  
        INT 10H  
          
        ADD Color,8          ;0001|1111+8=27H=0010(��ɫ)|0111 ͬ����8      
        MOV Count,18             ;������18(1��)���¿�ʼ,��ֵΪ18����0ִ�б�ɫ  
    ;------------------------------------------------------------------     
    Exit:   
        CLI                    ;���ж�  
        POP DS  
        POP DX  
        POP CX  
        POP BX  
        POP AX            ;�ָ��Ĵ���    
        IRET                  ;�жϷ���  
    INT_1CH  ENDP  
    ;------------------------------------------------------------------           
    CODES ENDS  
    END MAIN  