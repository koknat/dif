Label1:
	xor rax, rax                          ; rax = false
	
	; divisibility by four
	test rcx, 3               
	jnz done                              ; yes = not divisible by 4
	
	setz al                               ; al = ZF  [i.e. `true`, since `jnz` above]
