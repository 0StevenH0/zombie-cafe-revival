.class public final Lcom/capcom/zombiecafeandroid/offline/OfflineServer;
.super Ljava/lang/Object;
.source "OfflineServer.java"

# interfaces
.implements Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;
    }
.end annotation


# static fields
.field private static instance:Lcom/capcom/zombiecafeandroid/offline/OfflineServer;


# instance fields
.field private final difficulty:D

.field private generator:Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;

.field private final randomSeeds:Ljava/util/Random;

.field private final repository:Lcom/capcom/zombiecafeandroid/offline/RivalRepository;


# direct methods
.method constructor <init>(Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;)V
    .locals 2

    .prologue
    .line 43
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 40
    new-instance v0, Ljava/util/Random;

    invoke-direct {v0}, Ljava/util/Random;-><init>()V

    iput-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->randomSeeds:Ljava/util/Random;

    .line 44
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;

    invoke-direct {v0, p1}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;-><init>(Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;)V

    iput-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->repository:Lcom/capcom/zombiecafeandroid/offline/RivalRepository;

    .line 45
    invoke-static {p1}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->readDifficulty(Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;)D

    move-result-wide v0

    iput-wide v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->difficulty:D

    .line 46
    return-void
.end method

.method private generator()Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;
    .locals 2

    .prologue
    .line 134
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->generator:Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;

    if-nez v0, :cond_0

    .line 135
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->repository:Lcom/capcom/zombiecafeandroid/offline/RivalRepository;

    invoke-virtual {v1}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->loadCatalog()Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    move-result-object v1

    invoke-direct {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;-><init>(Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;)V

    iput-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->generator:Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;

    .line 137
    :cond_0
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->generator:Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;

    return-object v0
.end method

.method public static declared-synchronized get(Landroid/content/Context;)Lcom/capcom/zombiecafeandroid/offline/OfflineServer;
    .locals 3

    .prologue
    .line 49
    const-class v1, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;

    monitor-enter v1

    :try_start_0
    sget-object v0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->instance:Lcom/capcom/zombiecafeandroid/offline/OfflineServer;

    if-nez v0, :cond_1

    .line 50
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p0

    .line 51
    :cond_0
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;

    new-instance v2, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage$ForContext;

    invoke-direct {v2, p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage$ForContext;-><init>(Landroid/content/Context;)V

    invoke-direct {v0, v2}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;-><init>(Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;)V

    sput-object v0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->instance:Lcom/capcom/zombiecafeandroid/offline/OfflineServer;

    .line 53
    :cond_1
    sget-object v0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->instance:Lcom/capcom/zombiecafeandroid/offline/OfflineServer;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    monitor-exit v1

    return-object v0

    .line 49
    :catchall_0
    move-exception v0

    monitor-exit v1

    throw v0
.end method

.method private static mix(JI)J
    .locals 4

    .prologue
    .line 127
    int-to-long v0, p2

    const-wide v2, -0x61c8864680b583ebL

    mul-long/2addr v0, v2

    add-long/2addr v0, p0

    .line 128
    const/16 v2, 0x1e

    ushr-long v2, v0, v2

    xor-long/2addr v0, v2

    const-wide v2, -0x40a7b892e31b1a47L    # -0.0014818730883930777

    mul-long/2addr v0, v2

    .line 129
    const/16 v2, 0x1b

    ushr-long v2, v0, v2

    xor-long/2addr v0, v2

    const-wide v2, -0x6b2fb644ecceee15L    # -1.981759996145912E-208

    mul-long/2addr v0, v2

    .line 130
    const/16 v2, 0x1f

    ushr-long v2, v0, v2

    xor-long/2addr v0, v2

    return-wide v0
.end method

.method private static readDifficulty(Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;)D
    .locals 8

    .prologue
    const/4 v1, 0x0

    .line 141
    invoke-interface {p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;->externalFilesDir()Ljava/io/File;

    move-result-object v2

    .line 142
    const/4 v0, 0x2

    new-array v3, v0, [Ljava/io/File;

    .line 143
    if-eqz v2, :cond_1

    new-instance v0, Ljava/io/File;

    const-string v4, "offline.properties"

    invoke-direct {v0, v2, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    :goto_0
    aput-object v0, v3, v1

    const/4 v0, 0x1

    new-instance v2, Ljava/io/File;

    .line 144
    invoke-interface {p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;->filesDir()Ljava/io/File;

    move-result-object v4

    const-string v5, "offline.properties"

    invoke-direct {v2, v4, v5}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    aput-object v2, v3, v0

    .line 146
    array-length v4, v3

    move v2, v1

    :goto_1
    if-ge v2, v4, :cond_3

    aget-object v5, v3, v2

    .line 147
    if-eqz v5, :cond_0

    invoke-virtual {v5}, Ljava/io/File;->isFile()Z

    move-result v0

    if-nez v0, :cond_2

    .line 146
    :cond_0
    :goto_2
    add-int/lit8 v0, v2, 0x1

    move v2, v0

    goto :goto_1

    .line 143
    :cond_1
    const/4 v0, 0x0

    goto :goto_0

    .line 150
    :cond_2
    new-instance v0, Ljava/util/Properties;

    invoke-direct {v0}, Ljava/util/Properties;-><init>()V

    .line 152
    :try_start_0
    new-instance v1, Ljava/io/FileInputStream;

    invoke-direct {v1, v5}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/lang/NumberFormatException; {:try_start_0 .. :try_end_0} :catch_1

    .line 154
    :try_start_1
    invoke-virtual {v0, v1}, Ljava/util/Properties;->load(Ljava/io/InputStream;)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 156
    :try_start_2
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V

    .line 158
    const-string v1, "rival.difficulty"

    const-string v6, "1.0"

    invoke-virtual {v0, v1, v6}, Ljava/util/Properties;->getProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Double;->parseDouble(Ljava/lang/String;)D

    move-result-wide v0

    .line 159
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "rival.difficulty="

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0, v1}, Ljava/lang/StringBuilder;->append(D)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, " from "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v6}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->d(Ljava/lang/String;)V

    .line 167
    :goto_3
    return-wide v0

    .line 156
    :catchall_0
    move-exception v0

    invoke-virtual {v1}, Ljava/io/InputStream;->close()V

    .line 157
    throw v0
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_0
    .catch Ljava/lang/NumberFormatException; {:try_start_2 .. :try_end_2} :catch_1

    .line 161
    :catch_0
    move-exception v0

    .line 162
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "could not read "

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    goto :goto_2

    .line 163
    :catch_1
    move-exception v0

    .line 164
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "bad rival.difficulty in "

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    goto :goto_2

    .line 167
    :cond_3
    const-wide/high16 v0, 0x3ff0000000000000L    # 1.0

    goto :goto_3
.end method

.method private rival(Lcom/capcom/zombiecafeandroid/offline/RivalProfile;JLcom/capcom/zombiecafeandroid/offline/FriendCafe;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;)[B
    .locals 8

    .prologue
    const/4 v0, 0x0

    .line 116
    if-nez p5, :cond_0

    .line 117
    const-string v1, "no cafe layout available for a rival"

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 122
    :goto_0
    return-object v0

    .line 120
    :cond_0
    invoke-direct {p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->generator()Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;

    move-result-object v0

    const/4 v1, 0x3

    invoke-static {p2, p3, v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->mix(JI)J

    move-result-wide v4

    iget-wide v6, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->difficulty:D

    move-object v1, p4

    move-object v2, p5

    move-object v3, p1

    invoke-virtual/range {v0 .. v7}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->generate(Lcom/capcom/zombiecafeandroid/offline/FriendCafe;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;Lcom/capcom/zombiecafeandroid/offline/RivalProfile;JD)Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;

    move-result-object v0

    .line 121
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "rival "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->d(Ljava/lang/String;)V

    .line 122
    iget-object v0, v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;->blob:[B

    goto :goto_0
.end method


# virtual methods
.method difficulty()D
    .locals 2

    .prologue
    .line 69
    iget-wide v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->difficulty:D

    return-wide v0
.end method

.method public declared-synchronized metadataFor(Ljava/lang/String;)Ljava/lang/String;
    .locals 10

    .prologue
    const/4 v0, 0x1

    .line 95
    monitor-enter p0

    :try_start_0
    invoke-static {p1}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->forUid(Ljava/lang/String;)Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    move-result-object v1

    .line 96
    iget-object v2, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->repository:Lcom/capcom/zombiecafeandroid/offline/RivalRepository;

    invoke-virtual {v2}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->loadPlayer()Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v2

    .line 97
    if-eqz v2, :cond_0

    iget-object v0, v2, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    iget v0, v0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->level:I

    :cond_0
    invoke-virtual {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->rivalLevel(I)I

    move-result v0

    .line 98
    const-wide v2, 0x3fc999999999999aL    # 0.2

    const-wide v4, 0x3fe6666666666666L    # 0.7

    new-instance v6, Ljava/util/Random;

    iget-object v1, v1, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->uid:Ljava/lang/String;

    invoke-static {v1}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->stableHash(Ljava/lang/String;)J

    move-result-wide v8

    invoke-direct {v6, v8, v9}, Ljava/util/Random;-><init>(J)V

    invoke-virtual {v6}, Ljava/util/Random;->nextDouble()D

    move-result-wide v6

    mul-double/2addr v4, v6

    add-double/2addr v2, v4

    .line 100
    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;

    const-string v4, "%d:%f:%d:0:0:0:0"

    const/4 v5, 0x3

    new-array v5, v5, [Ljava/lang/Object;

    const/4 v6, 0x0

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    aput-object v0, v5, v6

    const/4 v0, 0x1

    invoke-static {v2, v3}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v2

    aput-object v2, v5, v0

    const/4 v0, 0x2

    const/16 v2, 0x3f

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    aput-object v2, v5, v0

    invoke-static {v1, v4, v5}, Ljava/lang/String;->format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result-object v0

    monitor-exit p0

    return-object v0

    .line 95
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public nowSeconds()J
    .locals 4

    .prologue
    .line 110
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    const-wide/16 v2, 0x3e8

    div-long/2addr v0, v2

    return-wide v0
.end method

.method public declared-synchronized onGameStateSaved()V
    .locals 1

    .prologue
    .line 105
    monitor-enter p0

    :try_start_0
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->repository:Lcom/capcom/zombiecafeandroid/offline/RivalRepository;

    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->archiveSnapshot()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 106
    monitor-exit p0

    return-void

    .line 105
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public declared-synchronized randomRival()[B
    .locals 8

    .prologue
    .line 76
    monitor-enter p0

    :try_start_0
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->randomSeeds:Ljava/util/Random;

    invoke-virtual {v0}, Ljava/util/Random;->nextLong()J

    move-result-wide v0

    invoke-static {}, Ljava/lang/System;->nanoTime()J

    move-result-wide v2

    xor-long/2addr v2, v0

    .line 77
    const-string v0, "random"

    new-instance v1, Ljava/util/Random;

    const/4 v4, 0x1

    invoke-static {v2, v3, v4}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->mix(JI)J

    move-result-wide v4

    invoke-direct {v1, v4, v5}, Ljava/util/Random;-><init>(J)V

    invoke-static {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->random(Ljava/lang/String;Ljava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    move-result-object v1

    .line 78
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->repository:Lcom/capcom/zombiecafeandroid/offline/RivalRepository;

    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->loadPlayer()Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v4

    .line 79
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->repository:Lcom/capcom/zombiecafeandroid/offline/RivalRepository;

    new-instance v5, Ljava/util/Random;

    const/4 v6, 0x2

    invoke-static {v2, v3, v6}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->mix(JI)J

    move-result-wide v6

    invoke-direct {v5, v6, v7}, Ljava/util/Random;-><init>(J)V

    invoke-virtual {v0, v4, v5}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->pickLayout(Lcom/capcom/zombiecafeandroid/offline/FriendCafe;Ljava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v5

    move-object v0, p0

    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->rival(Lcom/capcom/zombiecafeandroid/offline/RivalProfile;JLcom/capcom/zombiecafeandroid/offline/FriendCafe;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;)[B
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result-object v0

    monitor-exit p0

    return-object v0

    .line 76
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public respond(Ljava/lang/String;I)Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;
    .locals 4

    .prologue
    .line 58
    :try_start_0
    invoke-static {p1, p2, p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;->route(Ljava/lang/String;ILcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v1

    .line 59
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "cb="

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, " "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-static {p1}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;->endpoint(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    .line 60
    iget-boolean v0, v1, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->ok:Z

    if-eqz v0, :cond_0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " -> "

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v3, v1, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->body:[B

    array-length v3, v3

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, " bytes"

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    :goto_0
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 59
    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->d(Ljava/lang/String;)V

    .line 61
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;

    iget-boolean v2, v1, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->ok:Z

    iget-object v1, v1, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->body:[B

    invoke-direct {v0, v2, v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;-><init>(Z[B)V

    .line 64
    :goto_1
    return-object v0

    .line 60
    :cond_0
    const-string v0, " -> fail"
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 62
    :catch_0
    move-exception v0

    .line 63
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "request failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 64
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;

    const/4 v1, 0x0

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer$Reply;-><init>(Z[B)V

    goto :goto_1
.end method

.method public declared-synchronized rivalFor(Ljava/lang/String;)[B
    .locals 10

    .prologue
    .line 84
    monitor-enter p0

    :try_start_0
    invoke-static {p1}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->forUid(Ljava/lang/String;)Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    move-result-object v1

    .line 85
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->repository:Lcom/capcom/zombiecafeandroid/offline/RivalRepository;

    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->loadPlayer()Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v4

    .line 86
    if-eqz v4, :cond_0

    iget-object v0, v4, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    iget v0, v0, Lcom/capcom/zombiecafeandroid/offline/CafeState;->level:I

    .line 88
    :goto_0
    iget-object v2, v1, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->uid:Ljava/lang/String;

    invoke-static {v2}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->stableHash(Ljava/lang/String;)J

    move-result-wide v2

    const-wide/16 v6, 0x1f

    mul-long/2addr v2, v6

    int-to-long v6, v0

    add-long/2addr v2, v6

    .line 89
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->repository:Lcom/capcom/zombiecafeandroid/offline/RivalRepository;

    iget-object v5, v1, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->uid:Ljava/lang/String;

    new-instance v6, Ljava/util/Random;

    const/4 v7, 0x2

    invoke-static {v2, v3, v7}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->mix(JI)J

    move-result-wide v8

    invoke-direct {v6, v8, v9}, Ljava/util/Random;-><init>(J)V

    invoke-virtual {v0, v5, v4, v6}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->neighborLayout(Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;Ljava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v5

    move-object v0, p0

    .line 90
    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/OfflineServer;->rival(Lcom/capcom/zombiecafeandroid/offline/RivalProfile;JLcom/capcom/zombiecafeandroid/offline/FriendCafe;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;)[B
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result-object v0

    monitor-exit p0

    return-object v0

    .line 86
    :cond_0
    const/4 v0, 0x1

    goto :goto_0

    .line 84
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method
