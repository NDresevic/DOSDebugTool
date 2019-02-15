; ------------------------------------------------------------------
; _string_to_hex -- Ucitava heksadecimalni string u hex_string
; Ulaz: SI = pocetak hex stringa od 4 karaktera
; Izlaz: hex_string = hex string 
; -------------------------------------------------------------------
_string_to_hex:

	push cx
	push di
	push ax
	push si
	
	mov cx, 4									; duzina stringa
	mov di, hex_string
	
	petlja16:
	mov ax, [si]
	mov word [cs:di], ax						; ubacivanje ASCII koda 
	inc di
	inc si
	loop petlja16
	mov [cs:di], byte 0 						; zavrsavanje sa 0
	
	pop si
	pop ax
	pop di
	pop cx
	ret
	
; ------------------------------------------------------------------
; _string_to_int -- Konvertuje heksadecimalni string u int
; Ulaz: SI = pocetak stringa
; Izlaz: AX = celobrojna vrednost (int)
; -------------------------------------------------------------------
_string_to_int:

	pusha
	mov ax, si                      			; Duzina stringa u AX 
	call _string_length				
	add si, ax                      			; Pocinjemo od znaka sa krajnje desne strane
	dec si
	mov cx, ax                      			; Duzina stringa se koristi kao brojac znakova
	mov bx, 0                       			; U BX ce biti trazena celobrojna vrednost
	mov ax, 0

	; Racunamo heksadecimalnu vrednost kod pozicionog sistema sa osnovom 16        

	mov word [multiplikator], 1       			; Prvi znak mnozimo sa 1
	
Sledeci:

	mov ax, 0
	mov byte al, [si]                   		; Uzimamo znak
	
	; proveravamo da li je cifra od 0 do 9
	cmp al, 57									;9
	jg proveri_veliko_slovo
	cmp al, 48									;0
	jl greska
	jmp cifra
	
	; proveravamo da li je slovo od A do F
	proveri_veliko_slovo:
	cmp al, 70									;F
	jg proveri_malo_slovo
	cmp al, 65									;A
	jl greska
	jmp veliko_slovo
	
	; proveravamo da li je slovo od a do f
	proveri_malo_slovo:
	cmp al, 102 								;f
	jg greska 
	cmp al, 97									;a
	jl greska
	jmp malo_slovo
	
	malo_slovo:
	sub al, 97									; oduzima 'a'
	add al, 10									; dodaje 10 zbog hexa		
	jmp dalje
	
	veliko_slovo:
	sub al, 65									; oduzima 'A'
	add al, 10									; dodaje 10 zbog hexa
	jmp dalje
	
	cifra: 
	sub al, 48                      			; Konvertujemo iz ASCII u broj
	jmp dalje
	
	dalje:
	mul word [multiplikator]           			; Mnozimo sa pozicijom
	add  bx, ax                      			; Dodajemo u BX
	push ax                          			; Mnozimo multiplikator sa 16
	mov word ax, [multiplikator]
	mov dx, 16
	mul dx
	mov word [multiplikator], ax
	pop ax
	dec cx                          			; Da li ima jos znakova
	cmp cx, 0
	je Izlaz
	dec si                          			; Pomeramo se na sledecu poziciju ulevo
	jmp Sledeci
	
Izlaz:

	mov word [tmp], bx                 			; Privremeno cuvamo dobijeni int zbog 'popa'
	popa
	mov word ax, [tmp]
	ret

   multiplikator   dw 0  
   tmp             dw 0
   
   ; ispis poruke greske
   greska:
   mov [stampaj_gresku], byte 1
   mov si, pogresan_unos_broja
   call _print
   ret 
   
; ------------------------------------------------------------------
; _string_length -- Vraca duzinu stringa
; Ulaz: AX = pointer na pocetak stringa
; Izlaz: AX = duzina u bajtovoma (bez zavrsne nule)
; ------------------------------------------------------------------

_string_length:

	pusha
	mov bx, ax                      		; Adresa pocetka stringa u BX
	mov cx, 0                      			; Brojac bajtova
	
Dalje:

	cmp byte [bx], 0                   		; Da li se na lokaciji na koju pokazuje 
	je Kraj                        			; pointer nalazi nula (kraj stringa)?
	inc bx                          		; Ako nije nula, uvecaj brojac za jedan
	inc cx                          		; i pomeri pointer na sledeci bajt.
	jmp Dalje
	
Kraj:

	mov word [TmpBrojac], cx           		; Privremeno sacuvati broj bajtova
	popa                                	; jer vacamo sve registre sa steka (tj. menjamo AX).
	mov ax, [TmpBrojac]            			; Vracamo broj bajtova (duzinu stringa) u AX.
	ret

   TmpBrojac    dw 0

; ------------------------------------------------------------------
; _int_to_hex - Konvertuje decimalni broj u heksadecilalni
; Ulaz: AX = int broj
; Izlaz: brojUHex = hex broj 
; ------------------------------------------------------------------	

_int_to_hex:
	pusha
	
	mov cx, 0
	push ax
	
petlja14:
	pop ax
	mov dx, 0
	mov bx, 10
	div bx
	
	push dx
	push ax
	inc cx
	
	cmp ax, 0
	jne petlja14
	
	
	pop dx
	mov bx, brojUHex
	
provera_u_video:
	pop dx
	add dl, 48
	mov [bx], byte dl
	
	inc bx
	dec cx
	
	cmp cx, 0
	jne provera_u_video
	mov [bx], byte 0
	
	popa
	ret

; ------------------------------------------------------------------

segment .data

brojUHex: db 0, 0, 0, 0, 0
pogresan_unos_broja: db 'Greska, pogresan unos broja.', 0
stampaj_gresku: db 0