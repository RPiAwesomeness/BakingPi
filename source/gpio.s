.globl GetGpioAddress
GetGpioAddress:
    ldr r0,=0x20200000
    mov pc,lr

.globl SetGpioFunction
SetGpioFunction:
    @ r0 <= 53 - there's 54 GPIO pins on a Pi B, so the value in r0 has to be between 0 and 53
    cmp r0,#53
    @ r1 <= 7
    cmpls r1,#7
    @ Jump back to the calling function if previous comparison
    movhi pc,lr

    @ Push the link register (where to return to after completing this branch)
    push {lr}
    @ Put the value in r2 into r0
    mov r2,r0
    /* Branch to GetGpioAddress to get the address of the GPIO controller
       AFTER setting lr to the address of the next instruction */
    bl GetGpioAddress

    functionLoop$:
        @ Compare the value in r2 to the numeric literal 9
        cmp r2,#9
        /* If the cmp r2,#9 comparison found r2 > 9 then subtract 10 from the
           value in r2*/
        subhi r2,#10
        @ If the cmp r2,#9 comparison found r2 > 9 then add 4 to value in r2
        addhi r0,#4
        @ If the cmp r2,#9 comparison found r2 > 9 then branch to functionLoop$
        bhi functionLoop$

        @ Value in r2 x2 (binary left shift by one) + value in r2
        add r2, r2,lsl #1
        @ Logical shift left value in r1 by value in r2
        lsl r1,r2
        @ Store the value in r1 at the location given by r0 + 0 [r0] == [r0,#0]
        str r1,[r0]
        @ Pop the first item off the stack and store it in pc, thus returning
        pop {pc}

.globl SetGpio
SetGpio:
    /*
        Arguments:
            r0: GPIO pin number
            r1: Value to set
    */
    @ .req lets us define human-readable variable names
    pinNum .req r0
    pinVal .req r1

    @ If previous comparison pinNum > 53 return immediately since there are 54 GPIO pins (0-53)
    cmp pinNum,#53
    movhi pc,lr

    @ Put the link register (where to return to) on the stack
    push {lr}
    @ Put the value of pinNum (r0) in r2 because GetGpioAddress will be setting r0
    mov r2,pinNum
    @ Move the alias pinNum from r0 to r2 because the value was moved
    .unreq pinNum
    pinNum .req r2
    @ Branch to GetGpioAddress with link to the next statement
    bl GetGpioAddress
    @ Alias r0 to gpioAddr
    gpioAddr .req r0

    @ Alias r3 to pinBank
    pinBank .req r3
    @ Divide pinNum by 32 (five binary shifts right) and store results in pinBank
    lsr pinBank,pinNum,#5
    @ Multiply pinBank by 4 (2 logical shifts left)
    lsl pinBank,#2
    @ Add gpioAddr and pinBank and store in gpioAddr
    add gpioAddr,pinBank
    @ Un-alias pinBank
    .unreq pinBank

    /*
    @   AND operation between value of pinNum and 31, binary 11111 stored in pinNum
    @   Any value in last five digits that is a 1 will be a 1, otherwise any value
    @   is converted to 0.
    @   EG: pinNum = 10100010
    @       10100010 AND 11111 -> 00000010
    */
    and pinNum,#31
    setBit .req r3
    mov setBit,#1
    @ Binary multiply setBit (currently numeric literal) by value in pinNum
    lsl setBit,pinNum
    .unreq pinNum

    @ Is pinVal equal to 0?
    teq pinVal,#0
    .unreq pinVal
    @ If pinVal == 0 then store value of setBit at gpioAddr + 40
    streq setBit,[gpioAddr,#40]
    @ If pinVal != 0 then store the value of setBit at gpioAddr + 28
    strne setBit,[gpioAddr,#28]
    .unreq setBit
    .unreq gpioAddr
    @ Pop the top item off the stack into pc, returning
    pop {pc}
