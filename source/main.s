.section .init
.globl _start
_start:
    ldr r0,=0x20200000

    mov r1,#1
    lsl r1,#18
    str r1,[r0,#4]

    mov r1,#1
    lsl r1,#16

loop$:
    @ Set GPIO 16 (r1) to low, turning ACT LED on
    str r1,[r0,#40]

    @ Wait some time before bringing GPIO 16 high to let light stay on
    mov r2,#0x3F0000
    wait1$:
        sub r2,#1
        cmp r2,#0
        bne wait1$

    @ Bring GPIO 16 (r1) high, turning off ACT LED
    str r1,[r0,#28]

    @ Wait some more time before b loop$ to actually let light stay off for a bit
    mov r2,#0x3F0000
    wait2$:
        sub r2,#1
        cmp r2,#0
        bne wait2$

    @ Loop around to the start to keep blinking forever
    b loop$
