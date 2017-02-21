.globl GetSystemTimer
GetSystemTimer:
    ldr r0,=0x20003000
    mov pc,lr

.globl GetTimeStamp
GetTimeStamp:
    push {lr}
    bl GetSystemTimer
    @ Load the value of r0 + 4 into r0 and r1
    ldrd r0,r1,[r0,#4]
    @ Return
    pop {pc}

.globl WaitTime
WaitTime:
    counterLoc .req r3
    @ Get initial timer value, store in r4
    str r4,counterLoc
    loop$:
        @ Compare value in timeWait to r4
        cmp timeWait,r4
        @ If the comparison found r4 > timeWait then return
        mov pc,lr
        @ r4 < timeWait then loop around and check again
        b loop$
