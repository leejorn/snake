; this is a asm file write by leejorn
; other people who use this code ??? HAHAHAHA 
; connect me : lijizhan@126.com 

assume cs:code, ds:data, ss:stack

data segment
         snakedir db 1 dup(0)
         worldchar db 1 dup(0)
         worldcolor db 1 dup(0)
         snakechar db 1 dup(0)
         snakecolor db 1 dup(0)
         foodchar db 1 dup(0)
         foodcolor db 1 dup(0)
         snake_head dw 1 dup(0) ; snake_list head, 
         snake_tail dw 1 dup(0) ; snake_list tail, 
	 static_head dw 1 dup(0); head, no change = snake_list
         static_tail dw 1 dup(0); tail, no change = snake_list + (80*25 -1)*4
	 snake_list dd 80*25 dup(0) ; snake_list single is (col(8bit) row(8bit) flag(8bit) other(8bit))
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

               mov byte ptr [worldchar], '+'
               mov byte ptr [worldcolor], 00000010b
               mov byte ptr [snakechar], '*'
               mov byte ptr [snakecolor], 00000100b
               mov byte ptr [foodchar], '$'
               mov byte ptr [foodcolor], 00000110b

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
	       mov byte ptr [bx+2], 1; used flag
               pop bx

               sub [snake_head], 4
               push bx
               mov bx, [snake_head]
               mov byte ptr [bx], 39 ; col 39
               mov byte ptr [bx+1], 13 ; row 13
	       mov byte ptr [bx+2], 1; used flag
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

        ; up, right, down, left the snake list
	; esc game y/n ? when button esc
        ; quit game if button y, continue game if button n
	read_keyword: push ax
                      push bx
                      mov ax, 0
                      int 16h 

                      cmp al, 'i' ; up
                      je kw_do                                    
                      cmp al, 'k' ; down
                      je kw_do
                      cmp al, 'j' ; left
                      je kw_do
                      cmp al, 'l' ; right
                      je kw_do
		      cmp al, 'q' ; quit game
                      je kw_break
                      jmp kw_done
               kw_do: mov byte ptr [snakedir], al
                      call snake_eat_ahead                       
		      cmp word ptr [food_pos], 0FFFFH
		      je kw_break

             kw_done: pop bx
                      pop ax
                      jmp read_keyword
            kw_break: pop bx
                      pop ax
                      jmp game_over

        game_over: mov byte ptr [worldcolor], 00000111b
                   call clear_world
                   mov ax, 4c00h
     		   int 21h

        ; snake_eat_ahead
        snake_eat_ahead: push bp
                         mov bp, sp
                         pushf

			 mov si, word ptr [snake_head]
                         mov dx, word ptr [si]
                 sea_up: cmp byte ptr [snakedir], 'i'
			 jne sea_down
                         cmp dh, 0
                         je sea_done
                         sub dh, 1
                         jmp sea_do
               sea_down: cmp byte ptr [snakedir], 'k'
                         jne sea_left
                         cmp dh, 24
                         je sea_done
                         add dh, 1
                         jmp sea_do
               sea_left: cmp byte ptr [snakedir], 'j'
                         jne sea_right
                         cmp dl, 0
                         je sea_done
                         sub dl, 1
                         jmp sea_do                       
              sea_right: cmp byte ptr [snakedir], 'l'
                         jne sea_done
                         cmp dl, 79
                         je sea_done
                         add dl, 1
                 sea_do: cmp si, word ptr [static_head] ; if need turn around
                         je sea_head_around
                         sub si, 4
                         jmp sea_add_head
        sea_head_around: mov si, word ptr [static_tail] ; head around to static tail
        sea_add_head:    mov word ptr [si], dx ; add head
			 mov word ptr [si+2], 1; used flag
                         mov word ptr [snake_head], si ; change head
                         call draw_snake_head ; draw head 

                         cmp dx, word ptr [food_pos] ; if eat the food
                         je sea_food
                         mov si, word ptr [snake_tail]
                         cmp si, word ptr [static_head]
                         je sea_tail_around
                         sub si, 4
                         jmp sea_sub_tail
        sea_tail_around: mov si, word ptr [static_tail] ; tail around to static tail
           sea_sub_tail: mov word ptr [snake_tail], si
                         call clear_snake_tail
                         jmp sea_done

               sea_food: call eat_and_gen_food
              
               sea_done: popf
                         mov sp, bp
                         pop bp
                         ret

        clear_world: pushf
                     push ax
                     push bp
                     mov bp, sp

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
                     mov al, byte ptr [worldchar]
                     mov ah, byte ptr [worldcolor]
                     push ax
                     call draw_point

		     mov sp, bp
		     pop bp
                     pop ax
                     popf
		     ret

	clear_snake: push bp
		     mov bp, sp
		     push di
                     push ax
                     push bx
                     pushf

		     mov bx, 0
                     mov di, word ptr [snake_head]
               csp1: cmp di, word ptr [snake_tail]
		     jnb csp2
		     mov ax, word ptr [di]
		     push ax
                     add di, 4
                     inc bx
                     jmp csp1	
               csp2: cmp bx, 0
                     je csp3
                     push bx
                     mov al, byte ptr [worldchar]
                     mov ah, byte ptr [worldcolor]
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
                     mov di, word ptr [snake_head]
               dsp1: cmp di, word ptr [snake_tail]
		     je dsp2
		     mov ax, word ptr [di]
		     push ax
                     inc bx
                     add di, 4
                     cmp di, word ptr [static_tail] 
                     jna dsp1
                     mov di, word ptr [static_head]
                     jmp dsp1	
               dsp2: cmp bx, 0
                     je dsp3
                     push bx
                     mov al, byte ptr [snakechar]
                     mov ah, byte ptr [snakecolor]
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
                     mov ax, word ptr [bx]
		     push ax
                     mov ax, 1
                     push ax
                     mov al, byte ptr [snakechar]
                     mov ah, byte ptr [snakecolor]
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
		     mov ax, word ptr [bx]
		     push ax
                     mov ax, 1
                     push ax
                     mov al, byte ptr [worldchar]
                     mov ah, byte ptr [worldcolor]
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
                     mov al, byte ptr [foodchar]
                     mov ah, byte ptr [foodcolor]
                     push ax
		     call draw_point

                     popf
                     pop ax
		     mov sp, bp
		     pop bp
		     ret

   eat_and_gen_food: push bp
		     mov bp, sp
                     push ax
		     push bx
		     push dx
                     pushf

                     mov ax, word ptr [food_pos]
		     push ax
                     mov ax, 1
                     push ax
                     mov al, byte ptr [worldchar]
                     mov ah, byte ptr [worldcolor]
                     push ax
		     call draw_point
                     
		     ; gen new food pos
                     xor ax, ax
		     xor dx, dx
                     out 70h, al
                     in al, 71h ; sec
                     mul al
		     mov bx, 80*25
                     div bx
		     mov bx, dx
		     mov si, [static_head]
     find_next_food: cmp bx, 80*25
                     jnb no_new_food
		     cmp byte ptr [bx+si+2], 0
		     je gen_new_food
		     add bx, 1
		     jmp find_next_food
	no_new_food: mov word ptr [food_pos], 0FFFFH
   		     jmp done_new_food		     
       gen_new_food: mov ax, bx
                     xor bx, bx
                     mov bl, 80
		     div bl
		     xchg ah, al
		     mov word ptr [food_pos], ax ; clear food pos

      done_new_food: popf
		     pop dx
		     pop bx
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
                            
