.file	"3.10.s"
.text
.global	main
main:
	movq $0, %rax		#rax = 0
	movq $100, %rcx		#rcx = 100

loop_start:
	addq %rcx, %rax		#rax = rax + rcx
	subq $1, %rcx		#rcx = rcx - 1
	jnz loop_start		#rcxが0出ないならloop_startラベルにジャンプ
	ret
