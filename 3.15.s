.file	"3.15.s"
.text
.global	sum
.type	sum, @function
sum:
	movq $0, %rax		#ax = 0(クリア)
loop_start:
	addq (%rdi), %rax	#rax = rdiのアドレスの値
	addq $4, %rdi		#rdi = rdi + 4(int型のオフセット)
	subw $1, %si		#si = si - 1(siは最初引数でもらった5が入っている)
	jnz loop_start		#esiが0出ないならloop_startラベルにジャンプ
	ret
