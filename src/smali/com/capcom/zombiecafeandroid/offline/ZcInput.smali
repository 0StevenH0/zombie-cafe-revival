.class final Lcom/capcom/zombiecafeandroid/offline/ZcInput;
.super Ljava/lang/Object;
.source "ZcInput.java"


# instance fields
.field private final buf:[B

.field private pos:I


# direct methods
.method constructor <init>([B)V
    .locals 0

    .prologue
    .line 11
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 12
    iput-object p1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    .line 13
    return-void
.end method

.method private need(I)V
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 20
    if-ltz p1, :cond_0

    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->remaining()I

    move-result v0

    if-le p1, v0, :cond_1

    .line 21
    :cond_0
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "wanted "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " bytes at offset "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", have "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->remaining()I

    move-result v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 23
    :cond_1
    return-void
.end method


# virtual methods
.method bool()Z
    .locals 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    const/4 v0, 0x1

    .line 31
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v1

    .line 32
    if-le v1, v0, :cond_0

    .line 33
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "bool byte was "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " at offset "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v2, v2, -0x1

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 35
    :cond_0
    if-ne v1, v0, :cond_1

    :goto_0
    return v0

    :cond_1
    const/4 v0, 0x0

    goto :goto_0
.end method

.method bytes(I)[B
    .locals 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 82
    invoke-direct {p0, p1}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->need(I)V

    .line 83
    new-array v0, p1, [B

    .line 84
    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    const/4 v3, 0x0

    invoke-static {v1, v2, v0, v3, p1}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 85
    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/2addr v1, p1

    iput v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    .line 86
    return-object v0
.end method

.method f32()F
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 64
    const/4 v0, 0x4

    invoke-direct {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->need(I)V

    .line 65
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    aget-byte v0, v0, v1

    and-int/lit16 v0, v0, 0xff

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v2, v2, 0x1

    aget-byte v1, v1, v2

    and-int/lit16 v1, v1, 0xff

    shl-int/lit8 v1, v1, 0x8

    or-int/2addr v0, v1

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v2, v2, 0x2

    aget-byte v1, v1, v2

    and-int/lit16 v1, v1, 0xff

    shl-int/lit8 v1, v1, 0x10

    or-int/2addr v0, v1

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v2, v2, 0x3

    aget-byte v1, v1, v2

    and-int/lit16 v1, v1, 0xff

    shl-int/lit8 v1, v1, 0x18

    or-int/2addr v0, v1

    .line 67
    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v1, v1, 0x4

    iput v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    .line 68
    invoke-static {v0}, Ljava/lang/Float;->intBitsToFloat(I)F

    move-result v0

    return v0
.end method

.method f64()D
    .locals 9
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    const/16 v8, 0x8

    .line 72
    invoke-direct {p0, v8}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->need(I)V

    .line 73
    const-wide/16 v2, 0x0

    .line 74
    const/4 v0, 0x7

    :goto_0
    if-ltz v0, :cond_0

    .line 75
    shl-long/2addr v2, v8

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v4, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/2addr v4, v0

    aget-byte v1, v1, v4

    int-to-long v4, v1

    const-wide/16 v6, 0xff

    and-long/2addr v4, v6

    or-long/2addr v2, v4

    .line 74
    add-int/lit8 v0, v0, -0x1

    goto :goto_0

    .line 77
    :cond_0
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v0, v0, 0x8

    iput v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    .line 78
    invoke-static {v2, v3}, Ljava/lang/Double;->longBitsToDouble(J)D

    move-result-wide v0

    return-wide v0
.end method

.method i16()I
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 46
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u16()I

    move-result v0

    int-to-short v0, v0

    return v0
.end method

.method i32()I
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 50
    const/4 v0, 0x4

    invoke-direct {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->need(I)V

    .line 51
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    aget-byte v0, v0, v1

    and-int/lit16 v0, v0, 0xff

    shl-int/lit8 v0, v0, 0x18

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v2, v2, 0x1

    aget-byte v1, v1, v2

    and-int/lit16 v1, v1, 0xff

    shl-int/lit8 v1, v1, 0x10

    or-int/2addr v0, v1

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v2, v2, 0x2

    aget-byte v1, v1, v2

    and-int/lit16 v1, v1, 0xff

    shl-int/lit8 v1, v1, 0x8

    or-int/2addr v0, v1

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v2, v2, 0x3

    aget-byte v1, v1, v2

    and-int/lit16 v1, v1, 0xff

    or-int/2addr v0, v1

    .line 53
    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v1, v1, 0x4

    iput v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    .line 54
    return v0
.end method

.method i64()J
    .locals 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    const-wide v4, 0xffffffffL

    .line 58
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v0

    int-to-long v0, v0

    and-long/2addr v0, v4

    .line 59
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v2

    int-to-long v2, v2

    and-long/2addr v2, v4

    .line 60
    const/16 v4, 0x20

    shl-long/2addr v0, v4

    or-long/2addr v0, v2

    return-wide v0
.end method

.method remaining()I
    .locals 2

    .prologue
    .line 16
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    array-length v0, v0

    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    sub-int/2addr v0, v1

    return v0
.end method

.method rest()[B
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 99
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->remaining()I

    move-result v0

    invoke-virtual {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->bytes(I)[B

    move-result-object v0

    return-object v0
.end method

.method string()[B
    .locals 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 91
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i16()I

    move-result v0

    .line 92
    if-gez v0, :cond_0

    .line 93
    new-instance v1, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "negative string length "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, " at offset "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v2, v2, -0x2

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 95
    :cond_0
    invoke-virtual {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->bytes(I)[B

    move-result-object v0

    return-object v0
.end method

.method u16()I
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 39
    const/4 v0, 0x2

    invoke-direct {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->need(I)V

    .line 40
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    aget-byte v0, v0, v1

    and-int/lit16 v0, v0, 0xff

    shl-int/lit8 v0, v0, 0x8

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v2, v2, 0x1

    aget-byte v1, v1, v2

    and-int/lit16 v1, v1, 0xff

    or-int/2addr v0, v1

    .line 41
    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v1, v1, 0x2

    iput v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    .line 42
    return v0
.end method

.method u8()I
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 26
    const/4 v0, 0x1

    invoke-direct {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->need(I)V

    .line 27
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->buf:[B

    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    add-int/lit8 v2, v1, 0x1

    iput v2, p0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->pos:I

    aget-byte v0, v0, v1

    and-int/lit16 v0, v0, 0xff

    return v0
.end method
