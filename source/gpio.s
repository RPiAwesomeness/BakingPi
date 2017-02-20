.globl GetGpioAddress
GetGpioAddress:
    ldr r0,=0x20200000
    mov pc,lr

.globl SetGpioFunction
SetGpioFunction:
    @ r0 <= 53
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

        add r2, r2,lsl #1
        lsl r1,r2
        str r1,[r0]
        pop {pc}
