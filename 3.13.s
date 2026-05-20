.file	"3.13.s"
.data	
	buffer:	.skip 255	#255バイト分メモリを確保
.text
.global	main
main:
	movl $3, %eax		#eax = 3(read)
	movl $0, %ebx		#ebx = 0(fd: stdin)
	movl $buffer, %ecx	#ecx = buffer(データを保存するアドレス)
	movl $255, %edx		#edx = 255(読み込むバイト数)
	int $0x80		#システムコール
	
	movl $4, %eax		#eax = 4(write)
	movl $1, %ebx		#ebx = 1(fd: stdout)
	movl $buffer, %ecx	#ecx = buffer(データが保存されているアドレス)
	int $0x80		#システムコール
	
	movl $1, %eax		#eax = 1(exit)
	int $0x80		#システムコール
