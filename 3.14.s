.file	"3.14.s"
.data
	msg: 	.string		"I_love_you!\r"
	msg1: 	.string		"\n"
	len: 	.long 		12
	len1:	.long		1
.text
.global	main
main:
	movl $1000000, %edi	#edi = 1000000
	movl $1, %ebx		#ebx = 1(fd: stdout)
	movl $msg, %ecx		#ecx = msg
	movl len, %edx		#edx = len
loop_start:
	movl $4, %eax		#eax = 4(write)
	int $0x80		#システムコール
	subl $1, %edi		#edi = edi - 1
	jnz loop_start		#ediが0出ないならloop_startラベルにジャンプ
	
	movl $4, %eax		#eax = 4(write)
	movl $msg1, %ecx	#ecx = msg1
	movl len1, %edx		#edx = len1
	int $0x80		#システムコール
	
	movl $1, %eax		#eax = 1(exit)
	int $0x80		#システムコール
