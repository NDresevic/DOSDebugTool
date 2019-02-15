; ---------------------------------------------------
; Konverzija binarnog broja u heksadecimalne znakove
; cx - broj znakova
; dx - adresa gde se smestaju znakovi
; Data segment mora da sadrzi string hex_chr
; ---------------------------------------------------

SEGMENT CODE

bin2hex:
	push bp
	mov word bp, dx               		; [bp+di] cemo koristiti da pristupimo
	mov word di, cx               		; memoriji u koju smestamo rezultat
	push di
	dec di	
	push eax   
	
L:	call konv                    		; vrsi konverziju najmanje znacajna 4 bita
	dec  di
	pop  eax   
	shr  eax,4                    		; shift right
	push eax   
	loop L
	
	pop eax    
	pop di
	mov  byte [ds:bp+di], 0	      		; 0 za kraj stringa
	pop bp		
	ret

konv:
	and  ax, 0x000f	              		; u ax upisemo poslednjih 4 bita iz ax
	mov  si, ax
	mov  byte al, [ds:hex_chr+si]    	; koristimo hex_chr kao malu translacionu tabelu
	mov  byte [ds:bp+di], al		  	; upisemo rezultat
	ret
; --------------------------------------

SEGMENT DATA
hex_chr:  db '0123456789ABCDEF'

