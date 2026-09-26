.class public final Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;
.super Ljava/lang/Object;
.source "OfflineServer.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/capcom/zombiecafeandroid/offline/OfflineServer;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Reply"
.end annotation


# instance fields
.field public final body:[B

.field public final ok:Z


# direct methods
.method constructor <init>(Z[B)V
    .locals 1

    .prologue
    .line 30
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 31
    iput-boolean p1, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;->ok:Z

    .line 32
    if-nez p2, :cond_0

    const/4 v0, 0x0

    new-array p2, v0, [B

    :cond_0
    iput-object p2, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;->body:[B

    .line 33
    return-void
.end method
