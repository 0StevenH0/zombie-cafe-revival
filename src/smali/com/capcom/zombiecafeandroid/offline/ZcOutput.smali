.class final Lcom/capcom/zombiecafeandroid/offline/ZcOutput;
.super Ljava/lang/Object;
.source "ZcOutput.java"


# instance fields
.field private final out:Ljava/io/ByteArrayOutputStream;


# direct methods
.method constructor <init>()V
    .locals 2

    .prologue
    .line 6
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 7
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    const/16 v1, 0x1000

    invoke-direct {v0, v1}, Ljava/io/ByteArrayOutputStream;-><init>(I)V

    iput-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    return-void
.end method


# virtual methods
.method bool(Z)V
    .locals 2

    .prologue
    .line 14
    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    if-eqz p1, :cond_0

    const/4 v0, 0x1

    :goto_0
    invoke-virtual {v1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 15
    return-void

    .line 14
    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method bytes([B)V
    .locals 3

    .prologue
    .line 50
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    const/4 v1, 0x0

    array-length v2, p1

    invoke-virtual {v0, p1, v1, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    .line 51
    return-void
.end method

.method f32(F)V
    .locals 3

    .prologue
    .line 35
    invoke-static {p1}, Ljava/lang/Float;->floatToRawIntBits(F)I

    move-result v0

    .line 36
    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    and-int/lit16 v2, v0, 0xff

    invoke-virtual {v1, v2}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 37
    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    ushr-int/lit8 v2, v0, 0x8

    and-int/lit16 v2, v2, 0xff

    invoke-virtual {v1, v2}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 38
    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    ushr-int/lit8 v2, v0, 0x10

    and-int/lit16 v2, v2, 0xff

    invoke-virtual {v1, v2}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 39
    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    ushr-int/lit8 v0, v0, 0x18

    and-int/lit16 v0, v0, 0xff

    invoke-virtual {v1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 40
    return-void
.end method

.method f64(D)V
    .locals 7

    .prologue
    .line 43
    invoke-static {p1, p2}, Ljava/lang/Double;->doubleToRawLongBits(D)J

    move-result-wide v2

    .line 44
    const/4 v0, 0x0

    :goto_0
    const/16 v1, 0x8

    if-ge v0, v1, :cond_0

    .line 45
    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    mul-int/lit8 v4, v0, 0x8

    ushr-long v4, v2, v4

    long-to-int v4, v4

    and-int/lit16 v4, v4, 0xff

    invoke-virtual {v1, v4}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 44
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 47
    :cond_0
    return-void
.end method

.method i16(I)V
    .locals 2

    .prologue
    .line 18
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    ushr-int/lit8 v1, p1, 0x8

    and-int/lit16 v1, v1, 0xff

    invoke-virtual {v0, v1}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 19
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    and-int/lit16 v1, p1, 0xff

    invoke-virtual {v0, v1}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 20
    return-void
.end method

.method i32(I)V
    .locals 2

    .prologue
    .line 23
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    ushr-int/lit8 v1, p1, 0x18

    and-int/lit16 v1, v1, 0xff

    invoke-virtual {v0, v1}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 24
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    ushr-int/lit8 v1, p1, 0x10

    and-int/lit16 v1, v1, 0xff

    invoke-virtual {v0, v1}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 25
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    ushr-int/lit8 v1, p1, 0x8

    and-int/lit16 v1, v1, 0xff

    invoke-virtual {v0, v1}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 26
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    and-int/lit16 v1, p1, 0xff

    invoke-virtual {v0, v1}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 27
    return-void
.end method

.method i64(J)V
    .locals 3

    .prologue
    .line 30
    const/16 v0, 0x20

    ushr-long v0, p1, v0

    long-to-int v0, v0

    invoke-virtual {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 31
    long-to-int v0, p1

    invoke-virtual {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 32
    return-void
.end method

.method string([B)V
    .locals 1

    .prologue
    .line 54
    array-length v0, p1

    invoke-virtual {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i16(I)V

    .line 55
    invoke-virtual {p0, p1}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->bytes([B)V

    .line 56
    return-void
.end method

.method toByteArray()[B
    .locals 1

    .prologue
    .line 59
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v0

    return-object v0
.end method

.method u8(I)V
    .locals 2

    .prologue
    .line 10
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->out:Ljava/io/ByteArrayOutputStream;

    and-int/lit16 v1, p1, 0xff

    invoke-virtual {v0, v1}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 11
    return-void
.end method
