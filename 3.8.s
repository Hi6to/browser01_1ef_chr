.file	"3.8.s"
.text
.global	main
main:
	movq $0x100010000, %rax	#rax = 0x100010000
	movw $0x10, %ax			#ax = 0x10
	ret
