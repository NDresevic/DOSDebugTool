; Pomocan fajl u kojem se ispisuje vreme na video memoriju 
; ispisivanje_vremena
; ispisivanje_STAROG_vremena 
; ispisi_broj_za_vreme
; ispisi_dve_tacke

SEGMENT CODE

RED equ 04h
CYAN equ 0Bh
GREEN equ 0Ah

; ------------------------------------------------------------------
; ispisivanje_vremena -- Ispisuje trenutno vreme, menja se na F5
; ------------------------------------------------------------------

ispisivanje_vremena:
	
	pusha
	; prvo promena da li moze da se getuje
	call proveri_reentrancy_flegove
	cmp [cs:moze_DOS], byte 1
	je moze_vreme
	mov [ds:ponovo_DOS], byte 1
	popa 
	ret
	
	moze_vreme:
	mov ah, 2ch							; dohvatanje trenutnog vremena 
	int 21h								; ch - sati, cl - minuti, dh - sekunde
	
	mov [sati], ch 					
	mov [minuti], cl 
	mov [sekunde], dh 
	
	popa
	call ispisivanje_STAROG_vremena
	ret
	
; ------------------------------------------------------------------
; ispisivanje_STAROG_vremena -- Ispisuje staro vreme, pri pritiskanju F1, F2, F3, F4
; ------------------------------------------------------------------
	
ispisivanje_STAROG_vremena:

	mov al, [sati]
	call ispisi_broj_za_vreme

	call ispisi_dve_tacke
	
	mov ch, 0
	mov al, [minuti]
	call ispisi_broj_za_vreme
	
	call ispisi_dve_tacke
	
	mov al, [sekunde]
	call ispisi_broj_za_vreme

	ret 
	
; ------------------------------------------------------------------
; ispisi_broj_za_vreme -- Ispisuje AL na video memoriju 
; Ulaz: AL - dvocifreni broj koji se ispisuje 
; ------------------------------------------------------------------

ispisi_broj_za_vreme: 

	mov ah, 0
	
	mov dx, 0
	push bx 							; sacuvaj gde treba da pises
	mov bx, 10							; deli ax sa 10, rezultat je u ax, ostatak u dx
	div bx 
	
	add ax, 48							; za ispis cifre, dodaje 0
	add dx, 48
	
	pop bx
	mov cl, CYAN						; svetlo plava
	
	mov word [es:bx], ax				; upisi cifru deseticu
	inc bx								; predji na boju
	mov byte [es:bx], cl
	inc bx
	mov word [es:bx], dx				; upisi cifru jedinicu
	inc bx
	mov byte [es:bx], cl
	inc bx

	ret 

; ------------------------------------------------------------------
; ispisi_dve_tacke -- Ispisuje : na video memoriju 
; ------------------------------------------------------------------	

ispisi_dve_tacke: 

	mov word [es:bx], 58				; kod za :
	inc bx
	mov byte [es:bx], cl
	inc bx

	ret 

; ------------------------------------------------------------------
	
segment .data

sati: db 0
minuti: db 0
sekunde: db 0 