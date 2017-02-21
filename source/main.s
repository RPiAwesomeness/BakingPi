.section .init
.globl _start
_start:
    b main

.section .text
main:
    @ Set the stack pointer to 0x8000, bottom of
    mov sp,#0x8000

    pinNum .req r0
    pinVal .req r1
    mov pinNum,#16
    mov pinVal,#1


    bl SetGpioFunction
    .unreq pinNum
    .unreq pinVal

loop$:
    pinNum .req r0
    pinVal .req r1
    mov pinNum,#16
    mov pinVal,#0

    @ Set the GPIO pin defined in r0 to the value in r1
    bl SetGpio
    .unreq pinNum
    .unreq pinVal

    @ Wait some time before bringing GPIO 16 high to let light stay on
    decr .req r0
    mov decr,#0x3F0000
    wait1$:
        sub decr,#1
        teq decr,#0
        bne wait1$
    .unreq decr

    pinNum .req r0
    pinVal .req r1
    mov pinNum,#16
    mov pinVal,#1

    @ Set the GPIO pin defined in r0 to the value in r1
    bl SetGpio
    .unreq pinNum
    .unreq pinVal

    @ Wait some more time before b loop$ to actually let light stay off for a bit
    decr .req r0
    mov decr,#0x3F0000
    wait2$:
        sub decr,#1
        teq decr,#0
        bne wait2$
    .unreq decr

    @ Loop around to the start to keep blinking forever
    b loop$
