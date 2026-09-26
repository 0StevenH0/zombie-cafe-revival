.class interface abstract Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;
.super Ljava/lang/Object;
.source "OfflineStorage.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/capcom/zombiecafeandroid/offline/OfflineStorage$ForContext;
    }
.end annotation


# virtual methods
.method public abstract externalFilesDir()Ljava/io/File;
.end method

.method public abstract filesDir()Ljava/io/File;
.end method

.method public abstract openAsset(Ljava/lang/String;)Ljava/io/InputStream;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation
.end method
