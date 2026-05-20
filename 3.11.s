.file	"3.11.s"
.data
	msg:	.string		"This above all: to thine own self be true.\n"
	len:	.long		45
.text
.global	main
main:
	movl $4, %eax		#eax = 4(write)
	movl $1, %ebx		#ebx = 1(fd: stdout)
	movl $msg, %ecx		#ecx = msg
	movl len, %edx		#edx = len
	int $0x80		#システムコール
	movl $1, %eax		#eax = 1(exit)
	int $0x80		#システムコール
