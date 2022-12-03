# $@ = target file
# $< = first dependency
# $^ = all dependencies

C_SOURCES = $(wildcard ./src/kernel/*.c ./src/drivers/*.c)
HEADERS = $(wildcard ./src/kernel/*.h ./src/drivers/*.h)
LINK_SCRIPT = $(wildcard ./ld_script.lds)

# Nice syntax for file extension replacement
OBJ = ${C_SOURCES:.c=.o}

all: run

./out/kernel.bin: ./obj/kernel_entry.o ${OBJ}
	ld -o $@ -T ${LINK_SCRIPT} $^ --oformat binary 

./obj/kernel_entry.o: ./src/boot/kernel_entry.asm
	nasm $< -f elf64 -o $@

./obj/%.o: ./src/kernel/%.c ./src/drivers/%.c ${HEADERS}
	gcc -g -ffreestanding -c $^ -o $@

./out/boot_sect.bin: ./src/boot/boot_sect.asm
	nasm $< -f bin -o $@

os-image.bin: ./out/boot_sect.bin ./out/kernel.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-x86_64 -s -fda  $<

clean:
	rm ./out/*.bin ./obj/*.o os-image.bin ./src/kernel/*.o ./src/drivers/*.o
