; this is a asm file write by leejorn
; other people who use this code ??? HAHAHAHA 
; connect me : lijizhan@126.com 

assume cs:code, ds:data, ss:stack

data segment
         ticknum dw 1 dup(0)
	 snake_head dw dup(0) ; snake_list head, init = add snake_list, 80*25*4, desc when add on grid
         snake_tail dw dup(0) ; snake_list tail, init = add snake_list, 80*25*4, no change after seted
	 snake_list dd 80*25 dup(0) ; snake_list single is (col(8bit) row(8bit) dir(8bit) flag(8bit))
         world_map db 80*25 dup(0) ; dir(8bit) 
         food_pos dw 1 dup(0)  ; food pos (col(8bit) row(8bit)) 
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

               ; clear all the world_map
	       call clear_world

	       ; init the snake_head
               mov [snake_head], offset snake_list
               add [snake_head], 80*25*4   ; get the last pos of snake

               push bx
	       sub [snake_head], 4
	       mov bx, [snake_head]
               mov [bx], 40  ; col 40
               mov [bx+1], 13 ; low 13
               mov [bx+2], 1 ; dir 1:up 2:right 3:down 4:left
               pop bx

               ; init the snake tail = head, after now, no change
               push ax
               mov ax, [snake_head]
               mov [snake_tail], ax
               pop ax

               ; draw the init snake
               call draw_snake

               ; init the food
               mov bx, offset food_pos
               mov byte ptr [bx], 20
               mov byte ptr [bx+1], 20

	       ; draw the init food
               call draw_food
               
	       ; the first thing is : reset new timer tick process, use int 21h (25) to reset int 1ch
               push ds
               mov ds, seg tick_proc
               mov dx, offset tick_proc
               mov ah, 25h
               mov al, 1ch
               int 21h
               pop ds
	      
        s1:  jmp s1
             mov ax, 4c00h
             int 21h

       tick_proc: push ax
                  push bx
                  add [ticknum], 1
		  cmp [ticknum], 200
                  jne tp1
                  mov [ticknum], 0

	     tp1: mov ax, [ticknum]
                  mov bl, 4
                  div bl
                  cmp ah, 0
                  jne tp2
                  call read_keyword  ;  check the keyword buff
  
             tp2: mov ax, [ticknum]
                  mov bl, 20
                  div bl
                  cmp ah, 0
                  jne tp3
                  call gen_food ; random gen food

             tp3: pop bx
                  pop ax
                  ret

	; gen new food pos, if no food now
	gen_food: ret

	; up, right, down, left the snake list
	; esc game y/n ? when button esc
        ; quit game if button y, continue game if button n
	read_keyword: ret 

	clear_world: push bp
                     mov bp, sp
                     push ax
                     pushf
		     mov al, 0 
	       cwp1: cmp al, 80
		     je cwp4
		     mov ah, 0
	       cwp2: cmp ah, 25
		     je cwp3
		     push ax
		     inc ah
		     jmp cwp2
	       cwp3: inc al
		     jmp cwp1
	       cwp4: mov ax, 80*25
                     push ax
                     mov al, '-'
                     mov ah, 00000001b
                     push ax
                     call draw_point
                     popf
		     pop ax
		     mov sp, bp
		     pop bp
		     ret

	clear_snake: push bp
		     mov bp, sp
		     push di
                     push ax
                     push bx
                     pushf

		     mov bx, 0
                     mov di, [snake_head]
               csp1: cmp di, [snake_tail]
		     jnb csp2
		     mov ax, [di]
		     push ax
                     add di, 4
                     inc bx
                     jmp csp1	
               csp2: cmp bx, 0
                     je csp3
                     push bx
                     mov al, ' '
                     mov ah, 0h
                     push ax
		     call draw_point

               csp3: popf
                     pop bx
                     pop ax
                     pop di
		     mov sp, bp
		     pop bp
		     ret

	draw_snake:  push bp
		     mov bp, sp
		     push di
                     push ax
                     push bx
                     pushf

		     mov bx, 0
                     mov di, [snake_head]
               dsp1: cmp di, [snake_tail]
		     jnb dsp2
		     mov ax, [di]
		     push ax
                     add di, 4
                     inc bx
                     jmp dsp1	
               dsp2: cmp bx, 0
                     je dsp3
                     push bx
                     mov al, '*'
                     mov ah, 02h
                     push ax
		     call draw_point

               dsp3: popf
                     pop bx
                     pop ax
                     pop di
		     mov sp, bp
		     pop bp
		     		
		     ret

	draw_food:   push bp
		     mov bp, sp
                     push ax
                     pushf
                     mov ax, word ptr [food_pos]
		     push ax
                     mov ax, 1
                     push ax
                     mov al, '$'
                     mov ah, 10001110b 
		     call draw_point
                     popf
                     pop ax
		     mov sp, bp
		     pop bp
		     ret

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
