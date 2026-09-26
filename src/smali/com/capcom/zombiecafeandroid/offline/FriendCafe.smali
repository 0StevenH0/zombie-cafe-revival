.class final Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
.super Ljava/lang/Object;
.source "FriendCafe.java"


# static fields
.field static final CURRENT_VERSION:I = 0x3f

.field private static final MIN_LAYOUT_BYTES:I = 0x20

.field static final MIN_VERSION:I = 0x29


# instance fields
.field final layout:[B

.field final state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

.field final version:I


# direct methods
.method constructor <init>(ILcom/capcom/zombiecafeandroid/offline/CafeState;[B)V
    .locals 0

    .prologue
    .line 22
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 23
    iput p1, p0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->version:I

    .line 24
    iput-object p2, p0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    .line 25
    iput-object p3, p0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->layout:[B

    .line 26
    return-void
.end method

.method static parse([B)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
    .locals 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 29
    if-eqz p0, :cond_0

    array-length v0, p0

    if-nez v0, :cond_1

    .line 30
    :cond_0
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;

    const-string v1, "empty cafe blob"

    invoke-direct {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 32
    :cond_1
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/ZcInput;

    invoke-direct {v0, p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;-><init>([B)V

    .line 33
    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v1

    .line 34
    const/16 v2, 0x29

    if-lt v1, v2, :cond_2

    const/16 v2, 0x3f

    if-le v1, v2, :cond_3

    .line 35
    :cond_2
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "unsupported cafe version "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 37
    :cond_3
    invoke-static {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/CafeState;->read(Lcom/capcom/zombiecafeandroid/offline/ZcInput;I)Lcom/capcom/zombiecafeandroid/offline/CafeState;

    move-result-object v2

    .line 38
    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->rest()[B

    move-result-object v0

    .line 39
    array-length v3, v0

    const/16 v4, 0x20

    if-ge v3, v4, :cond_4

    .line 40
    new-instance v1, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "cafe layout missing ("

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    array-length v0, v0

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, " bytes)"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 42
    :cond_4
    new-instance v3, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    invoke-direct {v3, v1, v2, v0}, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;-><init>(ILcom/capcom/zombiecafeandroid/offline/CafeState;[B)V

    return-object v3
.end method


# virtual methods
.method toBytes()[B
    .locals 3

    .prologue
    .line 46
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;

    invoke-direct {v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;-><init>()V

    .line 47
    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->version:I

    invoke-virtual {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->u8(I)V

    .line 48
    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    iget v2, p0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->version:I

    invoke-virtual {v1, v0, v2}, Lcom/capcom/zombiecafeandroid/offline/CafeState;->write(Lcom/capcom/zombiecafeandroid/offline/ZcOutput;I)V

    .line 49
    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->layout:[B

    invoke-virtual {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->bytes([B)V

    .line 50
    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->toByteArray()[B

    move-result-object v0

    return-object v0
.end method

.method withState(Lcom/capcom/zombiecafeandroid/offline/CafeState;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
    .locals 3

    .prologue
    .line 55
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->version:I

    iget-object v2, p0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->layout:[B

    invoke-direct {v0, v1, p1, v2}, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;-><init>(ILcom/capcom/zombiecafeandroid/offline/CafeState;[B)V

    return-object v0
.end method
