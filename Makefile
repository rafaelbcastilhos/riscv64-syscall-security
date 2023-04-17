test_security: boot.o libs.o handlers.o test.o test_security.lds
	~/Downloads/riscv/bin/riscv64-unknown-linux-gnu-ld -T test_security.lds -o test_security boot.o libs.o handlers.o test.o

boot.o: boot.s
	~/Downloads/riscv/bin/riscv64-unknown-linux-gnu-as -g -o boot.o boot.s

libs.o: libs.s
	~/Downloads/riscv/bin/riscv64-unknown-linux-gnu-as -g -o libs.o libs.s

handlers.o: handlers.s
	~/Downloads/riscv/bin/riscv64-unknown-linux-gnu-as -g -o handlers.o handlers.s

test.o: test.s
	~/Downloads/riscv/bin/riscv64-unknown-linux-gnu-as -g -o test.o test.s

clean:
	rm *.o
	rm test_security

run: test_security
	qemu-system-riscv64 -machine virt -cpu rv64 -smp 1 -m 128M -nographic -serial mon:stdio -bios none -kernel test_security

debug: test_security
	qemu-system-riscv64 -machine virt -cpu rv64 -smp 1 -m 128M -nographic -serial mon:stdio -bios none -kernel test_security -gdb tcp::1234 -S & xterm -e ~/Downloads/riscv/bin/riscv64-unknown-linux-gnu-gdb -ex "target remote:1234" -ex "set confirm off" -ex "add-symbol-file ./test_security 0x80000000"
