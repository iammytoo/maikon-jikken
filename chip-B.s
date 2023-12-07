# CHIP-B

# ロード処理。多分消していい。
LD   ACC, 70h
ST   ACC, (00h)
LD   ACC, 70h
ST   ACC, (01h)
LD   ACC, 6h
ST   ACC, (02h)

# 下記台形のパラメータ
# 上底 : 00
# 下底 : 01
# 高さ : 02

# 上底+下底 (carry付き)
RCF
LD  ACC, (00h)
ADC ACC, (01h)

BNC NOT_CARRY
    ST ACC,(19h)
    LD ACC, 01h
    ST ACC, (18h)

NOT_CARRY:
    ST ACC,(19h)
    LD ACC, 00h
    ST ACC, (18h)

# 高さを掛け算用の領域にメモ
LD ACC, (02h)
ST ACC, (09h)

# 2bite乗算の仕様
# 入力1 : 09h
# 入力2_下位 : 19
# 入力2_上位 : 18
# 出力_下位 : 29
# 出力_上位 : 28


# 乗算のメインロジック。
# 入力1を右シフトして、入力2を左シフトしていく
# 入力1の最下位bitが立っている時は解に加算
LOOP:
    LD ACC ,(009h)
    CMP ACC ,0h
    BZ SEND
    SRL ACC
    ST ACC,(009h)
    BC ADD_MEMS
    BA SHIFT_LEFT
    HLT

# 左シフト(2倍)。carryがついていた場合はSHIFT_LEFT_CARRYに飛ぶ
# SLLのcarry flagを見るのが、kue-chipのバグで不安定らしいので、即値で最上位ビットが立っているか判別。
# 非負で使う場合はここを調整
SHIFT_LEFT:
    LD ACC,(019h)
    ADC ACC, -80h
    BC SHIFT_LEFT_CARRY
        SLL ACC
        ST ACC,(019h)
        LD ACC,(018h)
        SLL ACC
        ST ACC,(018h)
    BA LOOP
    HLT

SHIFT_LEFT_CARRY:
    SLL ACC
    ST ACC,(019h)
    LD ACC,(018h)
    SLL ACC
    ADD ACC, 01h
    ST ACC,(018h)
    BA LOOP
    HLT

# 加算処理。carryがついていた場合はADD_CARRYに飛ぶ
ADD_MEMS:
    RCF
    LD ACC,(029h)
    ADC ACC,(019h)
    BC ADD_CARRY
        ST ACC,(029h)
        LD ACC,(028h)
        ADD ACC,(018h)
        ST ACC,(028h)
        BA SHIFT_LEFT
        HLT

ADD_CARRY:
    ST ACC,(029h)
    LD ACC,(028h)
    ADD ACC,(018h)
    ADD ACC, 01h
    ST ACC,(028h)
    BA SHIFT_LEFT
    HLT

# 送信処理。多分もっとコンパクトにできる
SEND:
    LD IX, 00h
    SEND_LOOP:
        LD ACC, (IX+28h)
        OUT
        NO1:
            BNO NO1
            ADD IX, 01h
            CMP IX, 01h
            BZN SEND_LOOP
            HLT
END

HLT