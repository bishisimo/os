SHELL=pwsh.exe
asm_path="src/boot.asm"
img_path="out/boot.img"
build:
	nasm.exe $(asm_path) -o $(img_path)
run:
	qemu-system-x86_64.exe -drive format=raw,file=$(img_path)
install:
	make build
	make run
uefi_build:
	@cargo xbuild
	@echo "build success..."
	@make esp_make
esp_make:
	@rm -r "build/esp"|Out-Null
	@mkdir "build/esp/EFI/Boot"|Out-Null
	@echo "mkdir ok..."
	@cp "target/x86_64-unknown-uefi/debug/os.efi" "build/esp/EFI/Boot/BootX64.efi"|Out-Null
efi_run:
	@qemu-system-x86_64.exe -drive if=pflash,format=raw,file=OVMF.fd,readonly=on \
	-drive format=raw,file=fat:rw:build/esp \
	-m 2048 \
	-nographic \
	-no-fd-bootchk \
	-smp 2