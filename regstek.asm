; Pomocni fajl u kome se ispisuju registri, stek i peek 
; funkcija_za_ispis_registara
; funkcija_za_ispis_steka
; fukcija_za_ispis_peek
; ispis_hexadecimalne_vrednosti_ax
; ispisi_slovo_h
	
; ------------------------------------------------------------------
; funkcija_za_ispis_registara -- Ispisuje inicijalni prikaz registara
; ------------------------------------------------------------------

funkcija_za_ispis_registara:
	mov bx, [pozicija_bx]							; pocetna pozicija ispisa
	mov   si, registri								; ispis labele 'Registers'
	call ispis_u_video

	add word [pozicija_bx], 142						; prelazak u sledeci red
	mov bx, [pozicija_bx]
	mov si, poruka_ax								; ispis labele 'ax: '
	call ispis_u_video
	mov ax, [registar_AX]							; ispis sadrzaja registra AX 
	call ispis_hexadecimalne_vrednosti_ax

	mov si, poruka_bx
	add word [pozicija_bx], 142
	mov bx, [pozicija_bx]
	call ispis_u_video
	mov ax, [registar_BX] 							; ispis sadrzaja registra BX 
	call ispis_hexadecimalne_vrednosti_ax
	
	mov si, poruka_cx
	add word [pozicija_bx], 142
	mov bx, [pozicija_bx]
	call ispis_u_video
	mov ax, [registar_CX] 							; ispis sadrzaja registra CX 
	call ispis_hexadecimalne_vrednosti_ax

	mov si, poruka_dx
	add word [pozicija_bx], 142
	mov bx, [pozicija_bx]
	call ispis_u_video
	mov ax, [registar_DX]							; ispis sadrzaja registra DX 
	call ispis_hexadecimalne_vrednosti_ax
	
	mov si, poruka_si
	add word [pozicija_bx], 142
	mov bx, [pozicija_bx]
	call ispis_u_video
	mov ax, [registar_SI]							; ispis sadrzaja registra SI
	call ispis_hexadecimalne_vrednosti_ax

	mov si, poruka_di
	add word [pozicija_bx], 142
	mov bx, [pozicija_bx]
	call ispis_u_video
	mov ax, [registar_DI] 							; ispis sadrzaja registra DI
	call ispis_hexadecimalne_vrednosti_ax
	
	ret
	
; ------------------------------------------------------------------
; funkcija_za_ispis_steka -- Ispisuje prikaz steka 
; ------------------------------------------------------------------
	
funkcija_za_ispis_steka:
	mov bx, [pozicija_bx]							; pocetna pozicija ispisa
	mov si, stek									; ispis labele 'Stack'
	call ispis_u_video
	
	add word [pozicija_bx], 150						; prelazak u sledeci red
	mov bx, [pozicija_bx]
	mov si, poruka_1								; '1: '
	call ispis_u_video
	mov ax, [prvi_stek]								; ispis 1. elementa sa steka
	call ispis_hexadecimalne_vrednosti_ax
	
	add word [pozicija_bx], 142
	mov bx, [pozicija_bx]
	mov si, poruka_2
	call ispis_u_video
	mov ax, [drugi_stek]							; ispis 2. elementa sa steka
	call ispis_hexadecimalne_vrednosti_ax

	add word [pozicija_bx], 142
	mov bx, [pozicija_bx]
	mov si, poruka_3
	call ispis_u_video
	mov ax, [treci_stek] 							; ispis 3. elementa sa steka
	call ispis_hexadecimalne_vrednosti_ax
	
	add word [pozicija_bx], 142
	mov bx, [pozicija_bx]
	mov si, poruka_4
	call ispis_u_video
	mov ax, [cetvrti_stek]							; ispis 4. elementa sa steka
	call ispis_hexadecimalne_vrednosti_ax

	add word [pozicija_bx], 142
	mov bx, [pozicija_bx]
	mov si, poruka_5
	call ispis_u_video
	mov ax, [peti_stek]								; ispis 5. elementa sa steka
	call ispis_hexadecimalne_vrednosti_ax
	
	add word [pozicija_bx], 142
	mov bx, [pozicija_bx]
	mov si, poruka_6
	call ispis_u_video
	mov ax, [sesti_stek]							; ispis 6. elementa sa steka
	call ispis_hexadecimalne_vrednosti_ax
	
	ret
; ------------------------------------------------------------------
; fukcija_za_ispis_peek -- Ispisuje prikaz peeka 
; ------------------------------------------------------------------

fukcija_za_ispis_peek:
	push bx 
	push ax 
	push si 
	push cx 
	
	mov bx, [dole_desno]							; pocinje odmah posle registara ili steka 
	
	add bx, 142
	mov si, poruka_seg								; ispis labele 'seg '
	call ispis_u_video
	mov ax, [peek_segment]							; ispis segmentnog dela 
	call ispis_hexadecimalne_vrednosti_ax

	add bx, 142
	mov si, poruka_off								; ispis labele 'off '
	call ispis_u_video
	mov ax, [peek_offset]							; ispis offsetnog dela
	call ispis_hexadecimalne_vrednosti_ax
	
	add bx, 142 
	mov si, poruka_val								; ispis labele 'val: '
	call ispis_u_video
	
	mov ax, [peek_value]							; ispis vrednosti
	mov cx, 2										; 2 byte 
	mov dx, s_code									; hex vrednost
	call bin2hex
	mov si, s_code
	call ispis_u_video
	call ispisi_slovo_h
	
	pop cx 
	pop si 
	pop ax 
	pop bx 
	ret 

; ------------------------------------------------------------------
; ispis_hexadecimalne_vrednosti_ax -- Ispisuje heksadecimalno vrednost registra AX 
; Ulaz: AX - vrednost koja se ispisuje 
; ------------------------------------------------------------------

ispis_hexadecimalne_vrednosti_ax:
	mov cx, 4 										; broj znakova
	mov dx, s_code 									; dx sadrzi gde smestas  

	call bin2hex									; konverzija binarnog broja u heksadecimalne znakove 

	mov si, s_code 									; ispisuje na ekran 
	call ispis_u_video
	call ispisi_slovo_h
	
	ret	

; ------------------------------------------------------------------
; ispisi_slovo_h -- Ispisuje slovo h  
; ------------------------------------------------------------------
	
ispisi_slovo_h:
	
	mov word [es:bx], 104							; kod za slovo 'h'
	inc bx
	mov byte [es:bx], byte GREEN
	inc bx
	mov word [pozicija_bx], bx 
	
	ret

; --------------------------------------------
	
segment .data

registri: db 'Registers', 0
poruka_ax: db 'ax: ', 0
poruka_bx: db 'bx: ', 0
poruka_cx: db 'cx: ', 0
poruka_dx: db 'dx: ', 0
poruka_si: db 'si: ', 0
poruka_di: db 'di: ', 0

stek: db 'Stack', 0
poruka_1: db ' 1: ', 0
poruka_2: db ' 2: ', 0
poruka_3: db ' 3: ', 0
poruka_4: db ' 4: ', 0
poruka_5: db ' 5: ', 0
poruka_6: db ' 6: ', 0

poruka_seg: db 'seg ', 0
poruka_off: db 'off ', 0
poruka_val: db 'val:  ', 0

s_code:  db ' ', 0, 0, 0               				; scan_code - hex vrednost   
slovo_h: db 'h ', 0	
