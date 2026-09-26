.class interface abstract Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;
.super Ljava/lang/Object;
.source "OfflineRouter.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x608
    name = "Backend"
.end annotation


# virtual methods
.method public abstract metadataFor(Ljava/lang/String;)Ljava/lang/String;
.end method

.method public abstract nowSeconds()J
.end method

.method public abstract onGameStateSaved()V
.end method

.method public abstract randomRival()[B
.end method

.method public abstract rivalFor(Ljava/lang/String;)[B
.end method
