.class final Lcom/capcom/zombiecafeandroid/offline/CafeState;
.super Ljava/lang/Object;
.source "CafeState.java"


# instance fields
.field flags:[B

.field level:I

.field money:I

.field owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

.field rating:F

.field ratingBonus:F

.field toxin:I

.field u1:D

.field u13:Z

.field u6:I

.field u7:I

.field u9:I

.field final zombies:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method constructor <init>()V
    .locals 1

    .prologue
    .line 13
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 24
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    .line 25
    const/4 v0, 0x0

    new-array v0, v0, [B

    iput-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->flags:[B

    return-void
.end method

.method static read(Lcom/capcom/zombiecafeandroid/offline/ZcInput;I)Lcom/capcom/zombiecafeandroid/offline/CafeState;
    .locals 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 29
    new-instance v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;

    invoke-direct {v1}, Lcom/capcom/zombiecafeandroid/offline/CafeState;-><init>()V

    .line 30
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->f64()D

    move-result-wide v2

    iput-wide v2, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u1:D

    .line 31
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->f32()F

    move-result v0

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->rating:F

    .line 32
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v0

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->toxin:I

    .line 33
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v0

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->money:I

    .line 34
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v0

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->level:I

    .line 35
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v0

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u6:I

    .line 36
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v0

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u7:I

    .line 37
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->f32()F

    move-result v0

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->ratingBonus:F

    .line 38
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v0

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u9:I

    .line 39
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->bool()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 40
    invoke-static {p0, p1}, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->read(Lcom/capcom/zombiecafeandroid/offline/ZcInput;I)Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    move-result-object v0

    iput-object v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    .line 42
    :cond_0
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v2

    .line 43
    const/4 v0, 0x0

    :goto_0
    if-ge v0, v2, :cond_1

    .line 44
    iget-object v3, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    invoke-static {p0, p1}, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->read(Lcom/capcom/zombiecafeandroid/offline/ZcInput;I)Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    move-result-object v4

    invoke-interface {v3, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 43
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 46
    :cond_1
    const/16 v0, 0x3e

    if-le p1, v0, :cond_3

    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    move-result v0

    .line 47
    :goto_1
    if-ltz v0, :cond_2

    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->remaining()I

    move-result v2

    if-le v0, v2, :cond_4

    .line 48
    :cond_2
    new-instance v1, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "bad flag count "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 46
    :cond_3
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v0

    goto :goto_1

    .line 50
    :cond_4
    invoke-virtual {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->bytes(I)[B

    move-result-object v0

    iput-object v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->flags:[B

    .line 51
    const/16 v0, 0x21

    if-le p1, v0, :cond_5

    .line 52
    invoke-virtual {p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->bool()Z

    move-result v0

    iput-boolean v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u13:Z

    .line 54
    :cond_5
    return-object v1
.end method


# virtual methods
.method copy()Lcom/capcom/zombiecafeandroid/offline/CafeState;
    .locals 4

    .prologue
    .line 87
    new-instance v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;

    invoke-direct {v1}, Lcom/capcom/zombiecafeandroid/offline/CafeState;-><init>()V

    .line 88
    iget-wide v2, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u1:D

    iput-wide v2, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u1:D

    .line 89
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->rating:F

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->rating:F

    .line 90
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->toxin:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->toxin:I

    .line 91
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->money:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->money:I

    .line 92
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->level:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->level:I

    .line 93
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u6:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u6:I

    .line 94
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u7:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u7:I

    .line 95
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->ratingBonus:F

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->ratingBonus:F

    .line 96
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u9:I

    iput v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u9:I

    .line 97
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    if-nez v0, :cond_0

    const/4 v0, 0x0

    :goto_0
    iput-object v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    .line 98
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_1
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    .line 99
    iget-object v3, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->copy()Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    move-result-object v0

    invoke-interface {v3, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_1

    .line 97
    :cond_0
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->copy()Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    move-result-object v0

    goto :goto_0

    .line 101
    :cond_1
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->flags:[B

    invoke-virtual {v0}, [B->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [B

    iput-object v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->flags:[B

    .line 102
    iget-boolean v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u13:Z

    iput-boolean v0, v1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u13:Z

    .line 103
    return-object v1
.end method

.method write(Lcom/capcom/zombiecafeandroid/offline/ZcOutput;I)V
    .locals 2

    .prologue
    .line 58
    iget-wide v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u1:D

    invoke-virtual {p1, v0, v1}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->f64(D)V

    .line 59
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->rating:F

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->f32(F)V

    .line 60
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->toxin:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 61
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->money:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 62
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->level:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 63
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u6:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 64
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u7:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 65
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->ratingBonus:F

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->f32(F)V

    .line 66
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u9:I

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 67
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    if-eqz v0, :cond_1

    const/4 v0, 0x1

    :goto_0
    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->bool(Z)V

    .line 68
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    if-eqz v0, :cond_0

    .line 69
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    invoke-virtual {v0, p1, p2}, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->write(Lcom/capcom/zombiecafeandroid/offline/ZcOutput;I)V

    .line 71
    :cond_0
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v0

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->u8(I)V

    .line 72
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_1
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_2

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    .line 73
    invoke-virtual {v0, p1, p2}, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->write(Lcom/capcom/zombiecafeandroid/offline/ZcOutput;I)V

    goto :goto_1

    .line 67
    :cond_1
    const/4 v0, 0x0

    goto :goto_0

    .line 75
    :cond_2
    const/16 v0, 0x3e

    if-le p2, v0, :cond_4

    .line 76
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->flags:[B

    array-length v0, v0

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->i32(I)V

    .line 80
    :goto_2
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->flags:[B

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->bytes([B)V

    .line 81
    const/16 v0, 0x21

    if-le p2, v0, :cond_3

    .line 82
    iget-boolean v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->u13:Z

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->bool(Z)V

    .line 84
    :cond_3
    return-void

    .line 78
    :cond_4
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->flags:[B

    array-length v0, v0

    invoke-virtual {p1, v0}, Lcom/capcom/zombiecafeandroid/offline/ZcOutput;->u8(I)V

    goto :goto_2
.end method
