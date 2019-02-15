; Prekidi 09h, 2Fh i rad kada se klikne F1, F2, F3, F4, F5

KBD equ 60h
F1 equ 3Bh
F2 equ 3Ch
F3 equ 3Dh
F4 equ 3Eh
F5 equ 3Fh
F6 equ 0Dh
ENTER_PRESS equ 1Ch
ENTER_RELEASE equ 9Ch
A equ 1Eh

pokreni_tsr:

	call   _novi_09
	mov dx, 00FFh
	mov ah, 31h
	int 21h

; Sacuvati originalni vektor prekida 0x1C, tako da kasnije mozemo da ga vratimo
_novi_09:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:09h*4]
	mov [old_int_off], bx 
	mov bx, [es:09h*4+2]
	mov [old_int_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, tast_int							
	mov [es:09h*4], dx
	mov ax, cs
	mov [es:09h*4+2], ax
	sti         
	ret

; --------------------------------------------	

; Vratiti stari vektor prekida 0x09
_stari_09:
	cli
	xor ax, ax
	mov es, ax
	mov gs, [cs_TSR]						; prethodno sacuvan es 
	mov ax, [gs:old_int_seg]					; zbog tsr-a 
	mov [es:09h*4+2], ax
	mov dx, [gs:old_int_off]
	mov [es:09h*4], dx
	sti
	ret

; --------------------------------------------

; Sacuvati originalni vektor prekida 0x1C, tako da kasnije mozemo da ga vratimo
_novi_2fh:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:2fh*4]
	mov [old_2fh_off], bx 
	mov bx, [es:2fh*4+2]
	mov [old_2fh_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, hendler_2fh
	mov [es:2fh*4], dx
	mov ax, cs
	mov [es:2fh*4+2], ax
	sti         
	ret


; Vratiti stari vektor prekida 0x09
_stari_2fh:
	cli
	xor ax, ax
	mov es, ax
	mov gs, [cs_TSR]
	mov ax, [gs:old_2fh_seg]
	mov [es:2fh*4+2], ax
	mov dx, [gs:old_2fh_off]
	mov [es:2fh*4], dx
	sti
	ret
	
hendler_2fh:
	cmp [cs:obrisan], byte 0
	jne izlaz_iz_hendlera 
	
	cmp ah, [cs:FuncID]
	jne izlaz_iz_hendlera								; ako FunctionID nije isti izadji
	mov al, 0ffh
	
	push cs
	pop es
	mov di, string_TSR
	
	iret 
	
	izlaz_iz_hendlera:
	push word [cs:old_2fh_seg]
	push word [cs:old_2fh_off]
	retf

; --------------------------------------------

tast_int:

	push cs 
	pop ds 

	; puni stek
	call napuni_promenljive_za_stek
	pusha

	cmp [cs:obrisan], byte 0
	jne izlaz 
	
	; puni registre
	mov [zaF5_registar_AX], ax 
	mov [zaF5_registar_BX], bx 
	mov [zaF5_registar_CX], cx 
	mov [zaF5_registar_DX], dx 
	mov [zaF5_registar_SI], si 
	mov [zaF5_registar_DI], di 

; Obrada tastaturnog prekida 

	in al, KBD
	mov bx, 0B800h
	mov es, bx
	mov bx, 460
	
	cmp al, F1
	je .f1
	cmp al, F2
	je .f2
	cmp al, F3 
	je .f3
	cmp al, F4 
	je .f4
	cmp al, F5
	je .f5
	cmp al, ENTER_PRESS
	je .enter_press
	cmp al, ENTER_RELEASE
	je .enter_release
	jmp izlaz
	
; --------------------------------------------
	
	; Pomeranje ispisa jedan karakter ulevo
.f1:
	sub word [gore_levo], 2								; pomeranje za jedno mesto ulevo
	push ax 
	mov ax, word [gore_levo]
	add ax, 2
	mov dx, 0
	mov bx, 160	
	div bx  											; deljenje zbog provere da li je u prvoj koloni
	pop ax 
	cmp dx, 0											; u prvoj koloni je, ostaje u mestu
	jne .preskoci_F1
	add word [gore_levo], 2
	jmp izlaz 
	
	.preskoci_F1:
	add word [gore_levo], 2								; vracas zbog ciscenja prikaza
	call ocisti_prikaz
	sub word [gore_levo], 2
	
	push ax 
	mov ax, word [gore_levo]
	mov word [pozicija_bx], ax 
	pop ax 
	
	mov bx, [gore_levo]
	call ispisi_registre_ili_stek
	jmp izlaz

; --------------------------------------------
	
	; Pomeranje ispisa jedan karakter desno
.f2:
	add word [gore_levo], 2							; pomeranje za jedno mesto udesno
	push ax 
	mov ax, word [gore_levo]
	add ax, 16
	mov dx, 0
	mov bx, 160
	div bx 
	pop ax 
	cmp dx, 0										; u poslednjoj koloni je, ostaje u mestu
	jne .preskoci_F2
	sub word [gore_levo], 2
	jmp izlaz 
	
	.preskoci_F2:
	sub word [gore_levo], 2							; vracas zbog ciscenja prikaza
	call ocisti_prikaz
	add word [gore_levo], 2
	
	push ax 
	mov ax, word [gore_levo]
	mov word [pozicija_bx], ax 
	pop ax 
	
	mov bx, [gore_levo]
	call ispisi_registre_ili_stek
	jmp izlaz

; --------------------------------------------
	
	; Pomeranje ispisa jedan karakter gore
.f3:
	sub word [gore_levo], 160					; pomeranje za jedno mesto gore
	cmp word [gore_levo], 158					; ako je u gornjem redu, stoji u mestu
	jg .preskoci_F3 
	add word [gore_levo], 160
	jmp izlaz 
	
	.preskoci_F3:
	add word [gore_levo], 160					; vracas zbog ciscenja prikaza
	call ocisti_prikaz
	sub word [gore_levo], 160
	
	push ax 
	mov ax, word [gore_levo]
	mov word [pozicija_bx], ax 
	pop ax 
	
	mov bx, [gore_levo]
	call ispisi_registre_ili_stek
	jmp izlaz

; --------------------------------------------
	
	; Pomeranje ispisa jedan karakter dole
.f4:
	add word [gore_levo], 160					; pomeranje za jedno mesto dole 
	cmp word [dole_desno], 3360					; ako je u poslednjem redu, stoji 
	jle .preskoci_F4
	sub word [gore_levo], 160
	jmp izlaz
	
	.preskoci_F4:
	sub word [gore_levo], 160					; vracas zbog ciscenja prikaza
	call ocisti_prikaz
	add word [gore_levo], 160
	push ax 
	mov ax, word [gore_levo]
	mov word [pozicija_bx], ax 
	pop ax 
	
	mov bx, [gore_levo]
	call ispisi_registre_ili_stek
	jmp izlaz
	
; --------------------------------------------		
	
	; Promena ispisa
.f5:
	call napuni_registre					; refreshuje registre 
	call ocisti_prikaz
	inc byte [parnepar]						; povecava brojac parnepar
	mov bx, [gore_levo]
	call ispisi_registre_ili_stek
	jmp izlaz
	
; --------------------------------------------	
	
.enter_press:								; pritisak entera cisti prikaz
	call ocisti_prikaz
	jmp izlaz
	
.enter_release:								; otpustanje entera ispisuje novi prikaz 
	mov bx, [gore_levo]
	call ispisi_registre_ili_stek
	jmp izlaz

; --------------------------------------------
	
izlaz:
	popa
	
	push word [cs:old_int_seg]
	push word [cs:old_int_off]
	retf
	
; --------------------------------------------
	
gore_levo: dw 160
dole_desno: dw 0
pozicija_bx: dw 320
parnepar: db 0

old_int_seg: dw 0
old_int_off: dw 0

old_2fh_seg: dw 0
old_2fh_off: dw 0