; this is a asm file write by leejorn
; other people who use this code ??? HAHAHAHA 
; connect me : lijizhan@126.com 

assume cs:code, ds:data, ss:stack

data segment
         ticknum dw 1 dup(0)
         snake_head dw 1 dup(0) ; snake_list head, 
         snake_tail dw 1 dup(0) ; snake_list tail, 
	 static_head dw 1 dup(0); head, no change = snake_list
         static_tail dw 1 dup(0); tail, no change = snake_list + 80*25*4
	 snake_list dd 80*25 dup(0) ; snake_list single is (col(8bit) row(8bit) dir(8bit) flag(8bit))
         world_map db 80*25 dup(0) ; dir(8bit) 
         food_pos dw 1 dup(0)  ; food pos (col(8bit) row(8bit)) 
data ends

stack segment
        db 8000H dup(0)
stack ends

code segment
        start: mov ax, data
               mov ds, ax
               mov ax, stack
               mov ss, ax
               mov sp, 8000H

               ; clear all the world_map
               call clear_world

	       ; init the static head and tail. do not change after now
               mov [static_head], offset snake_list
               mov [static_tail], offset snake_list
               add [static_tail], (80*25-1)*4

	       ; init the run snake_head and snake_tail
               push ax
               mov ax, [static_tail]
               mov [snake_tail], ax
               mov [snake_head], ax
               pop ax

	       ; init the first one snake grid
	       sub [snake_head], 4
               push bx
               mov bx, [snake_head]
               mov byte ptr [bx], 40; col 40      0 <= col <= 79
               mov byte ptr [bx+1], 13; row 13    0 <= row <= 24
               pop bx

               sub [snake_head], 4
               push bx
               mov bx, [snake_head]
               mov byte ptr [bx], 39 ; col 39
               mov byte ptr [bx+1], 13 ; row 13
               pop bx

               ; draw the init snake
               call draw_snake
               ; call draw_snake_head

               ; init the food
               push bx
               mov bx, offset food_pos
               mov byte ptr [bx], 20
               mov byte ptr [bx+1], 20
               pop bx

	       ; draw the init food
               call draw_food
               
	       ; the first thing is : reset new timer tick process, use int 21h (25) to reset int 1ch
               push ds
               mov ax, seg tick_proc
               mov ds, ax
               mov dx, offset tick_proc
               mov ah, 25h
               mov al, 1ch
               int 21h
               pop ds

             push cx
             mov cx, 30000 
        s1:  loop s1
             pop cx
             mov ax, 4c00h
             int 21h

       tick_proc: cli
                  push ax
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
                  sti
                  ret

	; gen new food pos, if no food now
	gen_food: ret

	; up, right, down, left the snake list
	; esc game y/n ? when button esc
        ; quit game if button y, continue game if button n
	read_keyword: push ax
                      push bx
                      mov ax, 0
                      int 16h
                 kw1: cmp al, 'i' ; up
                      jne kw2
                      mov bx, 1
                      jmp kw_do
                 kw2: cmp al, 'k' ; down
                      jne kw3
                      mov bx, 2
                      jmp kw_do
                 kw3: cmp al, 'j' ; left
                      jne kw4
                      mov bx, 3
                      jmp kw_do
                 kw4: cmp al, 'l' ; right
                      jne kw_do
                      mov bx, 4
               kw_do: cmp bx, 0
                      je kw_done

                      push bp
                      mov bp, sp
                      pushf
                      push bx
                      call snake_eat_ahead  
                      popf
                      mov sp, bp
                      pop bp

             kw_done: pop bx
                      pop ax
		      ret 

        ; snake_eat_ahead
        snake_eat_ahead: push bp
                         mov bp, sp
                         pushf

			 mov ax, [bp + 4] ; dir
			 mov si, [snake_head]
                         mov dx, [si]
                 sea_up: cmp ax, 1
			 jne sea_down
                         cmp dh, 0
                         je sea_done
                         sub dh, 1
                         jmp sea_do
               sea_down: cmp ax, 2
                         jne sea_left
                         cmp dh, 24
                         je sea_done
                         add dh, 1
                         jmp sea_do
               sea_left: cmp ax, 3
                         jne sea_right
                         cmp dl, 0
                         je sea_done
                         sub dl, 1
                         jmp sea_do                       
              sea_right: cmp ax, 4
                         jne sea_done
                         cmp dl, 79
                         je sea_done
                         add dl, 1
                         jmp sea_do
                 sea_do: cmp si, [static_head] ; if need turn around
                         je sea_head_around
                         sub si, 4
        sea_head_around: mov si, [static_tail] ; head around to static tail
                         mov [si], dx ; add head
                         mov [snake_head], si ; change head
                         call draw_snake_head ; draw head 

                         cmp dx, [food_pos] ; if eat the food
                         je sea_food
                         mov si, [snake_tail]
                         cmp si, [static_head]
                         je sea_tail_around
                         sub si, 4
        sea_tail_around: mov si, [static_tail] ; tail around to static tail
                         mov [snake_tail], si
                         call clear_snake_tail
                         jmp sea_done

              sea_food:  call clear_food
              
               sea_done: popf
                         mov sp, bp
                         pop bp
                         ret

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
                     mov al, ' '
                     mov ah, 0
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
		     je dsp2
		     mov ax, [di]
		     push ax
                     inc bx
                     add di, 4
                     cmp di, [static_tail] 
                     jna dsp1
                     mov di, [static_head]
                     jmp dsp1	
               dsp2: cmp bx, 0
                     je dsp3
                     push bx
                     mov al, '*'
                     mov ah, 00000010b
                     push ax
		     call draw_point

               dsp3: popf
                     pop bx
                     pop ax
                     pop di
		     mov sp, bp
		     pop bp
		     		
		     ret

    draw_snake_head: push bp
		     mov bp, sp
                     push ax
		     push bx
                     pushf

                     mov bx, word ptr [snake_head]
                     mov ax, [bx]
		     push ax
                     mov ax, 1
                     push ax
                     mov al, '*'
                     mov ah, 00000010b
                     push ax
		     call draw_point

                     popf
		     pop bx
                     pop ax
		     mov sp, bp
		     pop bp
		     ret

   clear_snake_tail: push bp
		     mov bp, sp
                     push ax
		     push bx
                     pushf

                     mov bx, word ptr [snake_tail]
		     mov ax, [bx]
		     push ax
                     mov ax, 1
                     push ax
                     mov al, ' '
                     mov ah, 0
                     push ax
		     call draw_point
                     mov word ptr [bx], 0 ; clear tail data
                     mov word ptr [bx+2], 0

                     popf
		     pop bx
                     pop ax
		     mov sp, bp
		     pop bp
		     ret

	  draw_food: push bp
		     mov bp, sp
                     push ax
                     pushf

                     mov ax, word ptr [food_pos]
		     push ax
                     mov ax, 1
                     push ax
                     mov al, '$'
                     mov ah, 10001110b
                     push ax
		     call draw_point

                     popf
                     pop ax
		     mov sp, bp
		     pop bp
		     ret

       clear_food:   push bp
		     mov bp, sp
                     push ax
                     pushf

                     mov ax, word ptr [food_pos]
		     push ax
                     mov ax, 1
                     push ax
                     mov al, ' '
                     mov ah, 0
                     push ax
		     call draw_point
                     
                     mov word ptr [food_pos], 0 ; clear food pos

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

                    mov bx, ss:[bp+4]     ; draw char
                    mov cx, ss:[bp+4+2]   ; loop times
		    mov ax, 0B800H
		    mov es, ax
		    mov si, 0
	       do1: mov ax, 2h
                    mul byte ptr ss:[bp+4+4+si]  ; pos cow
                    mov di, ax
                    mov ax, 160
                    mul byte ptr ss:[bp+4+4+si+1] ; pos row
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
                            
