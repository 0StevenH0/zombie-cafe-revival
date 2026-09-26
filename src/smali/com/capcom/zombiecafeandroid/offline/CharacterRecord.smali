.class final Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;
.super Ljava/lang/Object;
.source "CharacterRecord.java"


# instance fields
.field energy:F

.field level:I

.field name:[B

.field type:I

.field u10:I

.field u11:I

.field u12:I

.field u13:I

.field u14:I

.field u16:I

.field u2:I

.field u3:I

.field u5:I

.field u6:J

.field u7:I

.field u8:J

.field u9:J


# direct methods
.method constructor <init>()V
    .locals 1

    .prologue
    .line 13
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 15
    const/4 v0, 0x0

    new-array v0, v0, [B

    iput-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->name:[B

    return-void
.end method

.method static read(Lcom/capcom/zombiecafeandroid/offline/ZcInput;I)Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;
    .locals 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 33
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    invoke-direct {v0}, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;-><init>()V

    .line 34
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    .line 35
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->string()[B

    move-result-object v1

    iput-object v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->name:[B

    .line 36
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u2:I

    .line 37
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u3:I

    .line 38
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->f32()F

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->energy:F

    .line 39
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u5:I

    .line 40
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i64()J

    move-result-wide v2

    iput-wide v2, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u6:J

    .line 41
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u7:I

    .line 42
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i64()J

    move-result-wide v2

    iput-wide v2, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u8:J

    .line 43
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i64()J

    move-result-wide v2

    iput-wide v2, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u9:J

    .line 44
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u10:I

    .line 45
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u11:I

    .line 46
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u12:I

    .line 47
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u13:I

    .line 48
    const/16 v1, 0x1d

    if-le p1, v1, :cond_0

    .line 49
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u14:I

    .line 50
    const/16 v1, 0x2e

    if-le p1, v1, :cond_0

    .line 51
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    .line 52
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v1

    iput v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u16:I

    .line 55
    :cond_0
    return-object v0
.end method


# virtual methods
.method copy()Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;
    .locals 4

    .prologue
    .line 83
    new-instance v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    invoke-direct {v1}, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;-><init>()V

    .line 84
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    .line 85
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->name:[B

    invoke-virtual {v0}, [B->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [B

    iput-object v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->name:[B

    .line 86
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u2:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u2:I

    .line 87
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u3:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u3:I

    .line 88
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->energy:F

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->energy:F

    .line 89
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u5:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u5:I

    .line 90
    iget-wide v2, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u6:J

    iput-wide v2, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u6:J

    .line 91
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u7:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u7:I

    .line 92
    iget-wide v2, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u8:J

    iput-wide v2, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u8:J

    .line 93
    iget-wide v2, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u9:J

    iput-wide v2, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u9:J

    .line 94
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u10:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u10:I

    .line 95
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u11:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u11:I

    .line 96
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u12:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u12:I

    .line 97
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u13:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u13:I

    .line 98
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u14:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u14:I

    .line 99
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    .line 100
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u16:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u16:I

    .line 101
    return-object v1
.end method

.method write(Lcom/capcom/zombiecafeandroid/offline/ZcOutput;I)V
    .locals 2

    .prologue
    .line 59
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->u8(I)V

    .line 60
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->name:[B

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->string([B)V

    .line 61
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u2:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->u8(I)V

    .line 62
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u3:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->u8(I)V

    .line 63
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->energy:F

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->f32(F)V

    .line 64
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u5:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->u8(I)V

    .line 65
    iget-wide v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u6:J

    invoke-virtual {p1, v0, v1}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i64(J)V

    .line 66
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u7:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->u8(I)V

    .line 67
    iget-wide v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u8:J

    invoke-virtual {p1, v0, v1}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i64(J)V

    .line 68
    iget-wide v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u9:J

    invoke-virtual {p1, v0, v1}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i64(J)V

    .line 69
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u10:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 70
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u11:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 71
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u12:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 72
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u13:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 73
    const/16 v0, 0x1d

    if-le p2, v0, :cond_0

    .line 74
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u14:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->u8(I)V

    .line 75
    const/16 v0, 0x2e

    if-le p2, v0, :cond_0

    .line 76
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 77
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->u16:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 80
    :cond_0
    return-void
.end method
