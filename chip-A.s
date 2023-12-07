LD IX, 00h

NI1:
    BNI NI1
    IN
    ST ACC, (IX+00h)
    ADD IX, 01h
    CMP IX, 01h
    BZN NI1
    HLT

END