org 0x7c00;启动扇区存放段地址
base_stack equ 0x7c00
base_loader equ 0x1000
offset_loader equ 0x0
root_dir_sectors equ 0x000e
sector_root_start equ 0x0013
sector_fat1 equ 0x0001
sector_balance equ 0x0011
jmp start
nop
BS_OEMN db "MINEB"
BPB_BytersPerSec dw 512
BPB_SecPerClus db 1
BPB_RsvdSecCnt dw 1
BPB_NumFATs db 2
BPB_RootEntCnt dw 224
BPB_TotSec16 dw 2880
BPB_Media db 0xf0
BPB_FATSz16 dw 9
BPB_SecPerTrk dw 18
BPB_NumHeads dw 2
BPB_hiddSec dd 0
BPB_TotSec32 dd 0
BS_DrvNum db 0
BS_VolID dd 0
BS_VolLab db 'bootloader'
BS_FileSysType db 'FAT12'

start:
    mov AX,CS
    mov SS,AX
    mov DS,AX
    mov ES,AX
    mov SP,base_stack

    ;===== clear screen
    mov AX,0x0600;H06滚动窗口,L0清空
    mov BX,0x0200;控制背景与光标颜色
    mov CX,0x0;显示每行字符,左上角标号,H列L行
    mov DX,0xffff;右下角
    int 0x10
    ;===== set focus
    mov AX,0x200
    mov BX,0
    mov DX,0
    int 0x10
    ;===== display on screen:start botting...
    mov AX,0x1301;功能设置
    mov BX,0x000f;属性设置
    mov CX,0x0a;长度设置
    mov DX,0x0;游标号设置
    ;push AX
    ;mov AX,DS
    ;mov ES,AX;显示内容内存地址
    ;pop AX
    mov BP,boot_message;显示内容内存地址,BH页码
    int 0x10
    ;====== reset floppy
    xor AH,0x0
    xor DL,0x0
    int 0x13
    call func_read_one_sector00
;===== read one sector from floppy
func_read_one_sector:
    push BP
    mov BP,SP
    sub ESP,2
    mov byte [BP-2],CL
    push BX
    mov BL,[BPB_SecPerTrk]
    div BL
    inc AH
    mov CL,AH
    mov DH,AL
    shr AL,1
    mov CH,AL
    and DH,1
    pop BX
    mov DL,[BS_DrvNum]

go_on_reading:
    mov AH,2
    mov AH,byte [BP-2]
    int 0x13
    jc go_on_reading
    add ESP,2
    pop BP
    ret
;====== search loader.bin
   mov word [SectorNo],sector_root_start
search_root:
    cmp word [RootDirSizeForLoop],0
    jz no_loader_bin
    dec word [RootDirSizeForLoop]
    mov AX,0x0
    mov ES,AX
    mov BX,0x8000
    mov AX,[SectorNo]
    mov CL,1
    call func_read_one_sector
    mov SI,loader_file_name
    mov DI,0x8000
    cld
    mov DX,0x0010

search_loader_bin:
    cmp DX,0
    jz search_root
    dec DX
    mov CX,11

cmp_file_name:
    cmp CX,0
    jz file_name_found
    dec CX
    lodsb
    cmp AL,byte [ES:DI]
    jz go_on
    jmp file_different

go_on:
    inc DI
    jmp cmp_file_name

file_different:
    and DI,0xffe0
    add DI,0x0020
    mov SI, loader_file_name
    jmp search_loader_bin

goto_next_sector_root:
    add word [SectorNo],1
    jmp search_root
;=====
no_loader_bin:
    mov AX,0x1301
    mov BX,0x008c
    mov CX,0x0015
    mov DX,0x0100
    mov BP,no_loader_message
    int 0x0010
    jmp $
;====
file_name_found:
    ret
;===== message
boot_message:
    db "Botting..."
no_loader_message:
    db "ERROR:No LOADER Found"
loader_file_name:
    db "LOADER BIN",0
;===== tmp variable
RootDirSizeForLoop dw root_dir_sectors
SectorNo dw 0
Odd dw 0
;风怒横飞雪,
;日悲纵长影.
times 510-($-$$) db 0
dw 0xaa55