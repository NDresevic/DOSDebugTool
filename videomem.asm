; Pomocni fajl koji sadrzi funkcije za pisanje u video memoriju 
; ispis_u_video
; ocisti_ekran_video
; ocisti_prikaz

segment .code

; ------------------------------------------------------------------
; ispis_u_video -- Ispisuje u video memoriju string na koji pokazuje si 
; Ulaz: SI = pocetak stringa
; Izlaz: 
; -------------------------------------------------------------------

ispis_u_video:
	push ax 
	push si
	push es 

	mov ax, 0B800h						; za video memoriju
	mov es, ax

.petlja:
	
	mov al, byte [si] 					; procitamo bajt sa lokacije na koju pokazuje SI
	cmp al, 0 							; proverimo da li smo dosli do kraja stringa
	je zavrsi_funkciju
	
	mov byte [es:bx], al 				; upis karaktera al u video memoriju
	inc bx								; pomeramo se na deo za boju
	mov [es:bx], byte GREEN 			; upis boje za trenutni karakter
	
	inc si 								; naredni karakter u RAM
	inc bx 								; naredna pozicija u video memoriji
	jmp .petlja
	
	zavrsi_funkciju:
	mov word [pozicija_bx], bx 			; cuvanje dokle je upisano na pozicija_bx
	
	pop es 
	pop si 
	pop ax
	ret

; ------------------------------------------------------------------
; ocisti_ekran_video -- Cisti ceo ekran u video memoriji 
; -------------------------------------------------------------------
	
ocisti_ekran_video:
	push bx 							; sacuvaj bx 
	
	mov ax, 0B800h						
	mov es, ax	
	mov bx, 0							; od pocetka ekrana kreni, pozicija 0,0
	
	mov al, ' '							; svuda upisuje spejs
	
	petlja1:
	mov byte [es:bx], al 				; svuda upisuje spejs
	inc bx
	mov [es:bx], byte 00h				; crna pozadina
	inc bx 
	cmp bx, 3840						; ako je stigao do kraja zavrsi 
	je zavrsi_petlju1
	jmp petlja1
	
	zavrsi_petlju1:
	pop bx
	ret

; ------------------------------------------------------------------
; ocisti_prikaz -- Cisti prikaz u video memoriji 
; -------------------------------------------------------------------
	
ocisti_prikaz:
	push bx 
	push ax 
	
	mov ax, 0B800h				
	mov es, ax
	mov bx, [gore_levo]					; pocinje od pocetka prikaza
	mov al, ' '
	
	mov cx, 11							; 11 redova, ukljucujuci peek
	petlja11:
	
	push cx 
	mov cx, 9							; 9 karaktera ima u svakom redu
	petljaa1:
	mov byte [es:bx], al 				; upisuje svuda spejs 
	inc bx
	mov [es:bx], byte 00h				; crna pozadina
	inc bx 
	loop petljaa1
	
	pop cx 
	add bx, 142							; prelazak u sledeci red 
	loop petlja11
	
	zavrsi_petlju2:
	pop ax 
	pop bx
	ret	
	