#Copyright © 2016 - Bruno Caltabiano, Guilherme dos Santos Marcon
#and Murilo Salomão
#
#This file is part of Foobar.
#
#Foobar is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Foobar is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

.section .text
.globl	_start

_start:
.code16
	xorw	%ax, %ax
	movw	%ax, %ds
	movw	%ax, %ss
	movw	%ax, %fs
	jmp	start

.type	print_string, @function
# Parametros: %edx contendo a posição da string que será impressa
print_string:
	#convenção de chamadas do c não funcionou muito bem
	#pushl %ebp
	#movl %esp, %ebp
	#movl 8(%ebp), %edx

        print_string_loop:
                mov (%edx), %al
                cmp $0, %al
                je print_string_loop_end

                mov $0x0E, %ah
                int $0x10

                inc %edx
                jmp print_string_loop
	print_string_loop_end:

	#movl %ebp, %esp
	#popl %ebp
	ret

start:
	mov $0x00, %ah
	int $0x16		#Le caractere

	cmp $'1', %al
	jne not_clear
		call clear
		jmp start
	not_clear:

	cmp $'2', %al
	jne not_print_boot_loader
		call printBootloaderVersion
		jmp start
	not_print_boot_loader:

	cmp $'3', %al
	jne not_print_connected_devices
		call printConnectedDevices
		jmp start
	not_print_connected_devices:

	cmp $'4', %al
	jne not_restart
		call restart
		jmp start
	not_restart:

	mov	$0x0e, %ah
	mov	$0x0e, %bh
	mov	$0x0e, %bl
	int $0x10		#Imprime caractere na tela
	jmp start

clear:
	# cleaning window
	mov $0x0700, %ax #Function
	mov $0x07, %bh	 #White on black - Character attribute
	mov $0x0000, %cx
	mov $0x184f, %dx
	int $0x10

	# moving cursor to the top
	mov $0x02, %ah #Function
	mov $0x00, %bh #Row 0
	mov $0x00, %dh #Column 0
	mov $0x00, %dl #Primary page
	int $0x10
	ret
	
printBootloaderVersion:
	mov $version, %edx
	call print_string
	ret

printConnectedDevices:
	
	mov $device1, %edx
	call print_string
	
	int $0x11
	push %eax
	and $1, %eax #floppy disk
	cmp $0, %eax
	je not_dev1
		mov $installed, %edx
		call print_string
		jmp end_dev1
	not_dev1:
		mov $not_installed, %edx
		call print_string
	end_dev1:

	mov $device2, %edx
	call print_string

	pop %eax
	push %eax
	and $2, %eax #coprocessor
	cmp $0, %eax
	je not_dev2
		mov $installed, %edx
		call print_string
		jmp end_dev2
	not_dev2:
		mov $not_installed, %edx
		call print_string
	end_dev2:

	mov $device3, %edx
	call print_string

	pop %eax
	and $4, %eax #pointing device
	cmp $0, %eax
	je not_dev3
		mov $installed, %edx
		call print_string
		jmp end_dev3
	not_dev3:
		mov $not_installed, %edx
		call print_string
		jmp end_dev3
	end_dev3:

	ret

restart:
	int $0x19
	ret

version: .ascii "Die Fenster bootloader v0.6\n\r\0"
device1: .ascii "Floppy disk \0"
device2: .ascii "Coprocessor \0"
device3: .ascii "Pointing device \0"

installed: .ascii "installed\n\r\0"
not_installed: .ascii "not installed\n\r\0"

. = _start + 510
.byte		0X55, 0xAA
