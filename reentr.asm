; Fajl u kome je reseno sve za reentrancy i 1Ch
; ucitaj_reentrancy_flegove
; proveri_reentrancy_flegove

; ------------------------------------------------------------------
; ucitaj_reentrancy_flegove -- Funkcija koja ucitava vrednosti InDOS_flag i Critical_error_flag
; ------------------------------------------------------------------
ucitaj_reentrancy_flegove:
	pusha
	push ax 
	push es
	
	cli 
	
	mov ah, 34h											; setovanje InDOS_flag i Critical_error_flag
	int 21h
	
	mov ax, [es:bx]
	mov [InDOS_flag], ax								; InDOS_flag se nalazi na adresi es:bx 
	dec bx 
	mov ax, [es:bx]
	mov [Critical_error_flag], ax						; Critical_error_flag se nalazi odmah pre InDOS_flag
	
	sti 
	pop es 
	pop ax 
	popa
	ret 

; ------------------------------------------------------------------
; proveri_reentrancy_flegove -- Provera vrednosti InDOS_flag i Critical_error_flag
; Ukoliko je bar jedan on njih setovan, onda mora da se saceka da DOS zavrsi sta trenutno radi
; ------------------------------------------------------------------
	
proveri_reentrancy_flegove:

	push ax 
	
	cmp [InDOS_flag], byte 0							; ako nije setovan proveravamo critical error
	je proveri_critical
	mov [moze_DOS], byte 0								; InDOS_flag je 1, ne moze onda 
	jmp izadji_felgovi
	
	proveri_critical:
	cmp byte [Critical_error_flag], byte 0				; ako nije setovan moze da se pokrene program
	je izadji_felgovi
	mov [moze_DOS], byte 0								; Critical_error_flag je 1, ne moze onda 
	
	izadji_felgovi:
	pop ax 
	ret 

; -------------------------------------------------------------------	
; Sacuvati originalni vektor prekida 0x1C, tako da kasnije mozemo da ga vratimo
_novi_1C:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:1Ch*4]
	mov [old_1C_off], bx 
	mov bx, [es:1Ch*4+2]
	mov [old_1C_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, timer_int
	mov [es:1Ch*4], dx
	mov ax, cs
	mov [es:1Ch*4+2], ax
	;push ds		; sacuvati sadrazaj DS jer ga INT 0x08 menja u DS = 0x0040
	;pop gs		; (BIOS Data Area) i sa tako promenjenim DS poziva INT 0x1C
	sti         
	ret

; Vratiti stari vektor prekida 0x1C
_stari_1C:
	cli
	xor ax, ax
	mov es, ax
	mov gs, [cs_TSR]
	mov ax, [gs:old_1C_seg]
	mov [es:1Ch*4+2], ax
	mov dx, [gs:old_1C_off]
	mov [es:1Ch*4], dx
	sti
	ret
	
timer_int:
	push ds 
	
	cmp [cs:obrisan], byte 0 							; ako je obrisan izlazi
	jne izlaz_tajmer
	
	nastavi_dalje:
	push cs 
	pop ds 												; izjednacava cs i ds
	cmp [cs:ponovo_DOS], byte 0							; ako mora ponovo da proverava izlazi
	je izlaz_tajmer 
	
	call proveri_reentrancy_flegove
	cmp [cs:moze_DOS], byte 1							; ako je bar neki flag 1 onda ne moze 
	je izlaz_tajmer
	
	call ispisivanje_vremena
	mov [cs:ponovo_DOS], byte 0							; vraca da ne mora da se proverava 

izlaz_tajmer:
	pop ds
	push word [cs:old_1C_seg]
	push word [cs:old_1C_off]
	retf

; -------------------------------------------------------------------	

segment .data 

InDOS_flag: db 0
Critical_error_flag: db 0
ponovo_DOS: db 0
moze_DOS: db 1

old_1C_seg: dw 0
old_1C_off: dw 0