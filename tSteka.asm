; Pomocni program koji testira da li radi stek

 org 100h

	push 1234h
	push 5678h
	push 9101h
	push 1213h
	push 0abbah
	push 0abcdh
	cekaj:
	jmp cekaj
	
	ret