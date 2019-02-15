; Unos sa komandne linije i njihova obrada
; Resavanje start, stop, peek, poke 

; ------------------------------------------------------------------
; ucitaj_cmd - Ucita argumente komandne linije kao string 
; Ulaz: /
; Izlaz: SI = pocetak stringa cmd - a
; -------------------------------------------------------------------
ucitaj_cmd:   

	push cx
	push di
	push ax
	
	cld
	mov cx, 0080h                   		; Maksimalni broj izvrsavanja instrukcije sa prefiksom REPx
	mov di, 81h                     		; Pocetak komandne linije u PSP.
	mov al, ' '                     		; String uvek pocinje praznim mestom (razmak izmedju komande i parametra) 

	mov si, di 								; si pokazuje na pocetak cmd-a 
	
	; nalazimo odakle stvarno pocinje string, ukoliko je neko lupao spejsove 
	call preskoci_spejsove
	mov di, si 								; di pokazuje na '-'
	mov al, 0dh                     		; Trazimo kraj stringa (pritisnut Enter)
	
	opet1:
	cmp [cs:di], al 
	je nasao_enter
	inc di 
	jmp opet1
	
	nasao_enter:
	mov byte [cs:di], 0 					; stavi nulu na kraj 
	
	pop ax
	pop di
	pop cx
	
	ret

; ------------------------------------------------------------------
; proveri_start -- Nalazi koja je komanda sa cmd-a 
; Ulaz: SI = pocetak stringa cmd-a 
; Izlaz: 
; -------------------------------------------------------------------

; Proverava da li pise '-start'
proveri_start:
	mov bx, si								; cuvamo pocetak stringa na bx 

	mov di, poruka_start
.petlja4:
	mov ah, 0
	mov al, byte [ds:di]
	cmp byte [ds:si], al
	jne proveri_stop
	
	cmp [ds:si], byte 0
	je ukucano_start

	inc si
	inc di
	jmp .petlja4
	ret 
	
; --------------------------------------------

; Proverava da li pise '-stop'
proveri_stop:
	mov si, bx
	
	mov di, poruka_stop
.petlja5:
	mov ah, 0
	mov al, byte [ds:di]
	cmp byte [ds:si], al
	jne proveri_peek
	
	cmp [ds:si], byte 0
	je ukucano_stop

	inc si
	inc di
	jmp .petlja5
	
; --------------------------------------------
	
; Proverava da li pise '-peek'
proveri_peek:
	
	; namestanje zbog funkcije repe cmpsb, porednjenje [DS:SI] sa [ES:DI] 
	mov cx, 5									; duzina stringa, 5 slova ima '-peek'
	mov si, bx									; si pokazuje na pocetak, na '-'
	push ds
	pop es
	mov di, poruka_peek	
	pusha
	repe cmpsb                   			
	popa
	je nadji_pocetak_drugog
	jmp proveri_poke
	
	; si sad pokazuje odmah posle reci peek 
	nadji_pocetak_drugog:
	mov gs, [cs_TSR]
	add si, 5									; si pokazuje posle komande peek
	call preskoci_spejsove						; preskace nepotrebne spejsove
	call _string_to_hex
	
	push si 
	mov si, hex_string
	call _string_to_int
	mov [gs:peek_segment], ax 
	pop si 
	
	add si, 4
	call preskoci_spejsove
	call _string_to_hex
	mov si, hex_string
	call _string_to_int
	mov [gs:peek_offset], ax 
	
	mov es, [gs:peek_segment]				; segment iz kog se cita
	mov di, [gs:peek_offset]				; offset
	mov al, byte [es:di]
	mov [gs:peek_value], byte al			; pamcenje u vrednosti na programu koji je u TSR-u
	
	mov byte [gs:bio_peek], byte 1			; pamcenje da je bio jedan peek, zbog ispisa prikaza
	jmp ukucano_peek
	
	ret 
	
; --------------------------------------------
	
; Proverava da li pise '-poke'
proveri_poke:
	
	; provera za poke
	mov cx, 5
	mov si, bx
	push ds
	pop es
	mov di, poruka_poke
	pusha
	repe cmpsb                   
	popa
	je nadji_pocetak_drugog1
	jmp greska_u_unosu
	
	; si sad pokazuje odmah posle reci poke 
	nadji_pocetak_drugog1:
	mov gs, [cs_TSR]
	add si, 5
	call preskoci_spejsove
	call _string_to_hex
	
	push si
	mov si, hex_string
	call _string_to_int
	mov [gs:poke_segment], ax 
	pop si 
	
	; deo za offset 
	add si, 4
	call preskoci_spejsove
	call _string_to_hex
	
	push si 
	mov si, hex_string
	call _string_to_int
	mov [gs:poke_offset], ax 
	pop si 	
	
	; deo za vrednost upisa 
	add si, 4 
	call preskoci_spejsove
	call _string_to_hex
	push si
	mov si, hex_string
	call _string_to_int
	pop si
	
	mov es, [gs:poke_segment]	
	mov di, [gs:poke_offset]	
	mov [es:di], byte al						; upisuvanje vrednosti u adresu
	inc di 
	mov [es:di], byte RED 						; boja 		
	
	jmp ukucano_poke
	
	ret 

; --------------------------------------------
; Labela na koju skace ako je pravilno ukucan start, proverava da li je program vec startovan
; Ako nije poziva main, ako jeste izvestava o gresci
; --------------------------------------------
ukucano_start:
	
	mov si, potvrda_start
	call _print
	cmp [ds:cs_TSR], word 0
	jne vec_startovan
	call main
	ret 
	
	vec_startovan:
	mov si, novi_red
	call _print
	mov si, poruka_vec_startovan
	call _print
	ret 

; --------------------------------------------
; Labela na koju skace ako je pravilno ukucan stop, proverava da li je program vec startovan
; Ako jeste prekida ga, ako nije izvestava porukom
; --------------------------------------------
ukucano_stop:
	
	mov si, potvrda_stop
	call _print
	
	cmp [ds:cs_TSR], word 0					; provera da li je tsr startovan 
	jne prekidaj_rad
	mov si, novi_red
	call _print
	mov si, poruka_nije_startovan
	call _print
	ret 
	
	prekidaj_rad:
	push word [cs:cs_TSR]
	pop es
	mov [es:obrisan], byte 1
	;call _stari_09
	;call _stari_2fh
	ret 

; --------------------------------------------
; Labela na koju skace ako je pravilno ukucan peek, proverava da li je program vec startovan
; Ako jeste prikazuje ispis, ako nije izvestava porukom
; --------------------------------------------
	
ukucano_peek:

	mov si, potvrda_peek
	call _print
	
	cmp [ds:cs_TSR], word 0					; provera da li je tsr startovan 
	jne jeste_peek
	mov si, novi_red
	call _print
	mov si, poruka_nije_startovan
	call _print
	ret
	
	jeste_peek:
	mov byte [gs:bio_peek], byte 1
	ret 
	
; --------------------------------------------
; Labela na koju skace ako je pravilno ukucan poke, proverava da li je program vec startovan
; Ako jeste upisuje u memoriju, ako nije izvestava porukom
; --------------------------------------------

ukucano_poke:
	
	mov si, potvrda_poke
	call _print
	
	cmp [ds:cs_TSR], word 0					; provera da li je tsr startovan 
	jne jeste_poke
	mov si, novi_red
	call _print
	mov si, poruka_nije_startovan
	call _print
	ret
	
	jeste_poke:
	ret 
	
; ------------------------------------------------------------------
; preskoci_spejsove -- Preskoci nepotrebne spejsovi
; -------------------------------------------------------------------
preskoci_spejsove:
	cmp [si], byte ' '
	je idi_jos_dalje
	ret 
	
	idi_jos_dalje:
	inc si 
	jmp preskoci_spejsove

; ------------------------------------------------------------------
; greska_u_unosu -- Izvestaj da je pogresna komanda
; -------------------------------------------------------------------
greska_u_unosu:
	push si 
	
	mov si, poruka_greske
	call _print
	
	pop si 
	
	ret 
	
; --------------------------------------------	
	
segment .data 

poruka_start: db '-start', 0
poruka_stop: db '-stop', 0
poruka_peek: db '-peek', 0
poruka_poke: db '-poke', 0

obrisan: db 0
startovan: db 0
bio_peek: db 0

debag: db 'debag', 0

potvrda_start: db 'START', 0
potvrda_stop: db 'STOP', 0
potvrda_peek: db 'PEEK', 0
potvrda_poke: db 'POKE', 0

hex_string:	db 0, 0, 0, 0, 0

peek_segment: dw 0
peek_offset: dw 0
peek_value: db 0

poke_segment: dw 0
poke_offset: dw 0

poruka_greske: db 'Greska, komanda ne postoji.', 0
poruka_vec_startovan: db 'Greska, vec je startovan.', 0
poruka_nije_startovan: db 'Greska, nije startovan.', 0