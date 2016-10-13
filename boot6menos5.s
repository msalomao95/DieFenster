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

start:
	mov $0x00, %ah
	int $0x16		#Le caractere

	cmp $'1', %al
	je clear

	cmp $'2', %al
	je printBootloaderVersion


	cmp $'4', %al
	je restart

	mov	$0x0e, %ah
	mov	$0x0e, %bh
	mov	$0x0e, %bl
	int $0x10		#Imprime caractere na tela
	jmp start

clear:
	mov $0x00, %ah
	mov $0x00, %al
	int $0x10
	jmp start
	
printBootloaderVersion:

	mov $version, %edx

	printLoop:
		mov (%edx), %al
		cmp $0, %al
		je start
		
		push %edx
		mov $0x0E, %ah
		int $0x10
		pop %edx
		
		inc %edx
		jmp printLoop
		
	jmp printLoop

restart:
	int $0x19

version: .ascii "Die Fenster bootloader v0.4\n\r\0"

. = _start + 510
.byte		0X55, 0xAA
