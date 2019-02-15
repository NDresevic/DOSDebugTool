; Nevena Dresevic RN 25/16
; DOMACI 1 - glavni program 

	org 100h
	
	mov cx, 0FFh                		;This will be the ID number.
IDLoop:       
 
	mov ah, cl                 			;ID -> AH.
	push cx                      		;Preserve CX across call
	mov al, 0                   		;Test presence function code.
	int 2Fh                     		;Call multiplex interrupt.
	pop cx                      		;Restore CX.
	cmp al, 0                   		;Installed TSR?
	je TryNext                 			;Returns zero if none there.
	
	push cx
	mov cx, 11                  		; duzina stringa
	mov si, string_TSR

	pusha
	repe    cmpsb                   	; poredjenje stringova
	popa                            	
	pop cx
	je Installed                		;Branch off if it is ours.

TryNext:        

	mov [FuncID], cl              		;Save function result.

	loop IDLoop                  		;Otherwise, try the next one.
	jmp NotInstalled            		;Failure if we get to this point.

Installed:

	call ucitaj_cmd						; ucitavanje stringa sa komandne linije
	mov word [cs_TSR], es				; cuvanje segmenta programa 
	call proveri_start					; proveravanje starta i dalji tok programa 

	ret

NotInstalled:

	call ucitaj_reentrancy_flegove			; ucitavanje flagova zbog reentrancy-ja
	call ucitaj_cmd							; ucitavanje stringa sa komandne linije
	call proveri_start						; proveravanje starta i dalji tok programa 
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
main:

	mov ax, 0B800h
	mov es, ax
	mov bx, [pozicija_bx]						; gore levo pozicija, 320
	
	; tsr
	call _novi_1C
	call _novi_2fh
	call pokreni_tsr
	ret 

; ------------------------------------------------------------------
; ispisi_registre_ili_stek -- Ispisivanje steka ili registara + peek prikaza po potrebi
; Ako je parnepar paran onda ispisuje registre, ako je neparan onda stek 
; Peek se uvek ispisuje posle prvog trazenja peek-a 
; -------------------------------------------------------------------
ispisi_registre_ili_stek:

	cmp [prvi_start], byte 0					; da li je bio start
	je preskoci1
	mov al, [parnepar]
	cmp al, [stari_parnepar]					; ako se nije promenila vrednost treba staro vreme da ispise
	je staro
	mov [stari_parnepar], al 
	
	; ako je prvi start
	preskoci1:
	mov [prvi_start], byte 1					; stavi da bude 1, da znas da je startovan
	call ispisivanje_vremena
	jmp preskoci_staro
	
	staro:
	call ispisivanje_STAROG_vremena
	
	preskoci_staro:
	mov [pozicija_bx], bx 
	add word [pozicija_bx], 144
	mov bx, [pozicija_bx]
	
	mov al, [parnepar]
	test al, 1									; testiranje da li treba da se ispisu registri ili stek 
	jnz neparan
	call funkcija_za_ispis_registara			; ispis prikaza registara 
	mov [dole_desno], bx						; cuvanje donjeg desnog coska
	
	cmp [bio_peek], byte 0						; da li je do sada bio ukucan peek
	je nije_bilo_peek
	call fukcija_za_ispis_peek					; ako jeste ispisi prikaz peeka
	
	nije_bilo_peek:
	jmp izadji_iz_prikaza
	
	neparan:	
	call funkcija_za_ispis_steka				; ispis stek prikaza 
	mov [dole_desno], bx 						; cuvanje donjeg desnog coska
	
	cmp [bio_peek], byte 0						; da li je do sada bio ukucan peek
	je izadji_iz_prikaza	
	call fukcija_za_ispis_peek					; ako jeste ispisi prikaz peeka
	
	izadji_iz_prikaza:
	ret
	
; ------------------------------------------------------------------
; napuni_registre -- Puni registre vrednostima registara
; ------------------------------------------------------------------
	
napuni_registre:

	mov ax, [zaF5_registar_AX]
	mov [registar_AX], ax 
	mov ax, [zaF5_registar_BX]
	mov [registar_BX], ax 
	mov ax, [zaF5_registar_CX]
	mov [registar_CX], ax 
	mov ax, [zaF5_registar_DX]
	mov [registar_DX], ax 
	mov ax, [zaF5_registar_SI]
	mov [registar_SI], ax
	mov ax, [zaF5_registar_DI]
	mov [registar_DI], ax 
	
	ret 
	
; ------------------------------------------------------------------
; napuni_promenljive_za_stek -- Puni promenljive vrednostima sa steka 
; ------------------------------------------------------------------

napuni_promenljive_za_stek:

	; imam 4 call-a 
	pop word [prvi_call]
	pop word [drugi_call]
	pop word [treci_call]
	pop word [cetvrti_call]
	
	pop word [prvi_stek]
	pop word [drugi_stek]
	pop word [treci_stek]
	pop word [cetvrti_stek]
	pop word [peti_stek]
	pop word [sesti_stek]
	
	; vracanje na stek
	push word [sesti_stek]
	push word [peti_stek]
	push word [cetvrti_stek]
	push word [treci_stek]
	push word [drugi_stek]
	push word [prvi_stek]
	
	push word [cetvrti_call]
	push word [treci_call]
	push word [drugi_call]
	push word [prvi_call]
	
	ret 

; --------------------------------------------

segment .data

string_TSR: db 'TSR by None', 0

registar_AX: db 0, 0
registar_BX: db 0, 0
registar_CX: db 0, 0
registar_DX: db 0, 0
registar_SI: db 0, 0
registar_DI: db 0, 0

zaF5_registar_AX: db 0, 0
zaF5_registar_BX: db 0, 0
zaF5_registar_CX: db 0, 0
zaF5_registar_DX: db 0, 0
zaF5_registar_SI: db 0, 0
zaF5_registar_DI: db 0, 0

prvi_call: db 0, 0
drugi_call: db 0, 0
treci_call: db 0, 0
cetvrti_call: db 0, 0

prvi_stek: db 0, 0
drugi_stek: db 0, 0
treci_stek: db 0, 0
cetvrti_stek: db 0, 0
peti_stek: db 0, 0
sesti_stek: db 0, 0

cs_TSR: dw 0
FuncID: db 0

stari_parnepar: db 0
prvi_start: db 0

broj: db 0, 0, 0, 0, 0, 0

; --------------------------------------------

%include "vreme.asm" 
%include "ekran.asm" 
%include "regstek.asm" 
%include "tsr.asm" 
%include "cmd2.asm" 
%include "zahex.asm" 
%include "videomem.asm"
%include "bin2hex.asm" 
%include "reentr.asm"
;%include "tSteka.asm"
;%include "tester.asm"