.class final Lcom/capcom/zombiecafeandroid/OfflineBridge;
.super Ljava/lang/Object;
.source "OfflineBridge.java"


# direct methods
.method private constructor <init>()V
    .locals 0

    .prologue
    .line 13
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static handleRequest(Landroid/content/Context;Ljava/lang/String;I)V
    .locals 5

    .prologue
    const/4 v4, 0x0

    .line 17
    if-eqz p0, :cond_0

    .line 18
    :goto_0
    invoke-static {p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->get(Landroid/content/Context;)Lcom/capcom/zombiecafeandroid/offline/OfflineServer;

    move-result-object v0

    invoke-virtual {v0, p1, p2}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->respond(Ljava/lang/String;I)Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;

    move-result-object v0

    .line 19
    iget-boolean v1, v0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;->ok:Z

    if-eqz v1, :cond_1

    .line 22
    new-instance v1, Lcom/capcom/zombiecafeandroid/NetworkTask;

    const/4 v2, 0x1

    iget-object v3, v0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;->body:[B

    iget-object v0, v0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;->body:[B

    array-length v0, v0

    invoke-direct {v1, v2, v3, v0, p2}, Lcom/capcom/zombiecafeandroid/NetworkTask;-><init>(Z[BII)V

    new-array v0, v4, [Ljava/lang/String;

    check-cast v0, [Ljava/lang/Object;

    invoke-virtual {v1, v0}, Lcom/capcom/zombiecafeandroid/NetworkTask;->execute([Ljava/lang/Object;)Landroid/os/AsyncTask;

    .line 27
    :goto_1
    return-void

    .line 17
    :cond_0
    sget-object p0, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->CONTEXT:Landroid/content/Context;

    goto :goto_0

    .line 25
    :cond_1
    const/4 v0, 0x0

    invoke-static {v4, v0, v4, p2}, Lcom/capcom/zombiecafeandroid/URLManager;->NewRequestServerCallback(Z[BII)V

    goto :goto_1
.end method
