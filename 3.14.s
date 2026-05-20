.file	"3.14.s"
.data
	msg: 	.string		"I_love_you!"
	len: 	.long 		12
.text
.global	main
main:
	movl $100000, %edi	#edi = 1000000
	movl $4, %eax		#eax = 4(write)
	movl $1, %ebx		#ebx = 1(fd: stdout)
	movl $msg, %ecx		#ecx = msg
	movl len, %edx		#edx = len
loop_start:
	int $0x80		#システムコール
	subl $1, %edi		#edi = edi - 1
	jnz loop_start		#ediが0出ないならloop_startラベルにジャンプ
	movl $1, %eax		#eax = 1(exit)
	int $0x80		#システムコール
