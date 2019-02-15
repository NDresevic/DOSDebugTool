; Program koji sluzi da podesi vrednosti registara

 org 100h

postavi_vrednosti_registara:
	mov ax, 1234h
	mov bx, 5678h
	mov cx, 9101h
	mov dx, 1213h
	mov si, 0abbah
	mov di, 0abcdh
	jmp postavi_vrednosti_registara
	ret
	
ret 
