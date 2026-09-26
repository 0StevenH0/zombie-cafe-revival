.class final Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;
.super Ljava/lang/Object;
.source "RivalGenerator.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "Result"
.end annotation


# instance fields
.field final blob:[B

.field final defenders:I

.field final level:I

.field final ownerName:Ljava/lang/String;

.field final playerPower:D

.field final rivalPower:D

.field final tier:Lcom/capcom/zombiecafeandroid/offline/Tier;


# direct methods
.method constructor <init>([BLjava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;IIDD)V
    .locals 0

    .prologue
    .line 56
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 57
    iput-object p1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->blob:[B

    .line 58
    iput-object p2, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->ownerName:Ljava/lang/String;

    .line 59
    iput-object p3, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->tier:Lcom/capcom/zombiecafeandroid/offline/Tier;

    .line 60
    iput p4, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->level:I

    .line 61
    iput p5, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->defenders:I

    .line 62
    iput-wide p6, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->playerPower:D

    .line 63
    iput-wide p8, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->rivalPower:D

    .line 64
    return-void
.end method


# virtual methods
.method public toString()Ljava/lang/String;
    .locals 4

    .prologue
    .line 68
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->ownerName:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " tier="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->tier:Lcom/capcom/zombiecafeandroid/offline/Tier;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " level="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->level:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " defenders="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->defenders:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " power="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-wide v2, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->rivalPower:D

    .line 69
    invoke-static {v2, v3}, Ljava/lang/Math;->round(D)J

    move-result-wide v2

    invoke-virtual {v0, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " vs player "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-wide v2, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->playerPower:D

    invoke-static {v2, v3}, Ljava/lang/Math;->round(D)J

    move-result-wide v2

    invoke-virtual {v0, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 68
    return-object v0
.end method
