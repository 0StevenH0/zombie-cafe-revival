.class public final Lcom/capcom/zombiecafeandroid/offline/OfflineStorage$ForContext;
.super Ljava/lang/Object;
.source "OfflineStorage.java"

# interfaces
.implements Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "ForContext"
.end annotation


# instance fields
.field private final context:Landroid/content/Context;


# direct methods
.method constructor <init>(Landroid/content/Context;)V
    .locals 0

    .prologue
    .line 22
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 23
    iput-object p1, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage$ForContext;->context:Landroid/content/Context;

    .line 24
    return-void
.end method


# virtual methods
.method public externalFilesDir()Ljava/io/File;
    .locals 2

    .prologue
    .line 33
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage$ForContext;->context:Landroid/content/Context;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;

    move-result-object v0

    return-object v0
.end method

.method public filesDir()Ljava/io/File;
    .locals 1

    .prologue
    .line 28
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage$ForContext;->context:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;

    move-result-object v0

    return-object v0
.end method

.method public openAsset(Ljava/lang/String;)Ljava/io/InputStream;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 38
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage$ForContext;->context:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v0

    return-object v0
.end method
