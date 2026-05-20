.file	"3.9.s"
.text
.global	main
main:
	movl $0x765cafe, %eax	#eax = 0x765cafe
	subl $3939, %eax		#eax = eax - 3939
	ret
