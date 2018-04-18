    DATAS SEGMENT    
        Color   DB  1FH        ;定义的背景颜色表  
        Count   DW  1          ;Count计数1秒是变换背景   
    DATAS ENDS  
       
    STACKS SEGMENT STACK 'S'  
        ;堆栈段代码  
        DW 80 DUP(0)  
    STACKS ENDS  
      
    CODES SEGMENT  
        ASSUME CS:CODES,DS:DATAS,SS:STACKS  
    MAIN    PROC    FAR  
        MOV AX,DATAS  
        MOV DS,AX            ;将数据段DATAS存入DS中  
    ;------------------------------------------------------------------    
        MOV DX,SEG INT_1CH   ;SEG标号段地址  
        MOV DS,DX  
        LEA DX,INT_1CH       ;调用子函数INT_1CH 取偏移地址      
          
        ;AH=25H功能:置中断向量AL=中断号 DS:DX=入口  
        MOV AH,25H                  
        MOV AL,1CH           ;设置新的1CH中断向量  
        INT 21H  
          
        ;退出程序并返回操作系统  
        MOV AH,4CH  
        INT 21H  
    MAIN    ENDP      
    ;------------------------------------------------------------------  
    ;子程序:显示背景 FAR(主程序和子程序不在同一代码段)  
    INT_1CH     PROC    FAR  
        PUSH AX      ;保存寄存器  
        PUSH BX  
        PUSH CX  
        PUSH DX  
        PUSH DS  
          
        STI                  ;开中断  
        MOV AX,DATAS  
        MOV DS,AX            ;将数据段DATAS存入DS中  
          
        ;------------------------------------------  
        ;- INT 1CH系统中断每秒发生18.2次          -  
        ;- Count计数至18为1秒变换背景颜色         -  
        ;- Count初值为1,先减1执行一次显示蓝色背景 -  
        ;- 执行时赋值为18,每次减1,减至0更换背景色 -  
        ;------------------------------------------  
          
        DEC Count            ;Count初值为1,先减1  
        JNZ Exit             ;JNZ(结果不为0跳转) 否则Count=0执行背景色输出           
    ;------------------------------------------------------------------   
        ;调用BIOS10H的06号中断设置屏幕初始化或上卷  
          
        ;--------------------------------  
        ;- AL=上卷行数 AL=0全屏幕为空白 -  
        ;- BH=卷入行属性                -  
        ;- CH=左上角行号 CL=左上角列号  -  
        ;- DH=右下角行号 DL=右下角列号  -  
        ;--------------------------------     
      
        ;----------------------------------  
        ;- BL的颜色属性为IRGB|IRGB        -  
        ;- 高4位是背景色 低4位是前景色    -  
        ;- I=高亮 R=红 G=绿 B=蓝 共8色    -  
        ;----------------------------------  
          
        MOV AH,6         ;清全屏  
        MOV AL,0  
        MOV BH,Color         ;起始设置为蓝底白字 1FH=0001(蓝色)|1111B 详解见上表  
        MOV CX,0  
        MOV DX,184FH         ;(全屏)表示18行4F列  
        INT 10H  
          
        ADD Color,8          ;0001|1111+8=27H=0010(绿色)|0111 同理加8      
        MOV Count,18             ;计数至18(1秒)重新开始,赋值为18减至0执行变色  
    ;------------------------------------------------------------------     
    Exit:   
        CLI                    ;关中断  
        POP DS  
        POP DX  
        POP CX  
        POP BX  
        POP AX            ;恢复寄存器    
        IRET                  ;中断返回  
    INT_1CH  ENDP  
    ;------------------------------------------------------------------           
    CODES ENDS  
    END MAIN  
