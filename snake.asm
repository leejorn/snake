; this is a asm file write by leejorn
; other people who use this code ??? HAHAHAHA 
; connect me : lijizhan@126.com 

assume cs:code, ds:data, ss:stack

data segment
         ticknum db 1 dup(0)
         map    dw 25*25 dup(0)
data ends

stack segment
        db 128 dup(0)
stack ends

code segment
        start: mov ax, data
               mov ds, ax
               mov ax, stack
               mov ss, ax
               mov sp, 128

	       push bp
	       mov bp, sp
               mov ax, 0303h
               push ax
               mov ax, 0404h
               push ax
               mov ax, 0505h
               push ax
               mov ax, 0606h
               push ax
               mov ax, 4h
               push ax
               mov al, '*'
               mov ah, 02h
               push ax
               call draw_point
	       mov sp, bp
               pop bp
	      
              
             mov cx, 30000
        p1:  loop p1
             mov ax, 4c00h
             int 21h

        draw_point: push bp
                    mov bp, sp
                    pushf
		    push ax
                    push bx
		    push cx
		    push es
		    push di
		    push si

                    mov bx, ss:[bp+2]     ; draw char
		    mov cx, ss:[bp+2+2]   ; loop times
		    mov ax, 0B800H
		    mov es, ax
		    mov si, 0
	       do1: mov ax, 2h
                    mul byte ptr ss:[bp+2+4+si]  ; pos cow
                    mov di, ax
                    mov ax, 160
                    mul byte ptr ss:[bp+2+4+si+1] ; pos row
                    add di, ax                  ; the draw pos idx
                    mov es:[di], bx
		    add si, 2
		    loop do1
		    
		    pop si
		    pop di
		    pop es
		    pop cx
		    pop bx
		    pop ax
		    popf
		    mov sp, bp
		    pop bp

                    ret
code ends
end start
