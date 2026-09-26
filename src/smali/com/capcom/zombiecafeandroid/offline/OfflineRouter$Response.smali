.class final Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;
.super Ljava/lang/Object;
.source "OfflineRouter.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "Response"
.end annotation


# instance fields
.field final body:[B

.field final ok:Z


# direct methods
.method private constructor <init>(Z[B)V
    .locals 0

    .prologue
    .line 55
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 56
    iput-boolean p1, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->ok:Z

    .line 57
    iput-object p2, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->body:[B

    .line 58
    return-void
.end method

.method static fail()Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;
    .locals 3

    .prologue
    .line 73
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    const/4 v1, 0x0

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;-><init>(Z[B)V

    return-object v0
.end method

.method static ok([B)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;
    .locals 3

    .prologue
    .line 61
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    const/4 v1, 0x1

    if-nez p0, :cond_0

    const/4 v2, 0x0

    new-array p0, v2, [B

    :cond_0
    invoke-direct {v0, v1, p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;-><init>(Z[B)V

    return-object v0
.end method

.method static text(Ljava/lang/String;)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;
    .locals 4

    .prologue
    const/4 v3, 0x0

    .line 66
    invoke-static {p0}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->ascii(Ljava/lang/String;)[B

    move-result-object v0

    .line 67
    array-length v1, v0

    add-int/lit8 v1, v1, 0x1

    new-array v1, v1, [B

    .line 68
    array-length v2, v0

    invoke-static {v0, v3, v1, v3, v2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 69
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    const/4 v2, 0x1

    invoke-direct {v0, v2, v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;-><init>(Z[B)V

    return-object v0
.end method
