.class final Lcom/capcom/zombiecafeandroid/offline/RivalRepository;
.super Ljava/lang/Object;
.source "RivalRepository.java"


# static fields
.field static final CHARACTER_ASSET:Ljava/lang/String; = "data/characterData.bin.mid"

.field private static final MAX_IMPORT_BYTES:I = 0x100000

.field static final MAX_SNAPSHOTS:I = 0x6

.field static final SERVER_DATA:Ljava/lang/String; = "ServerData.dat"

.field static final TEMPLATE_ASSET:Ljava/lang/String; = "offline/rival_template.dat"


# instance fields
.field private final storage:Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;


# direct methods
.method constructor <init>(Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;)V
    .locals 0

    .prologue
    .line 36
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 37
    iput-object p1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->storage:Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;

    .line 38
    return-void
.end method

.method private static addWeighted(Ljava/util/List;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;I)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/FriendCafe;",
            ">;",
            "Lcom/capcom/zombiecafeandroid/offline/FriendCafe;",
            "I)V"
        }
    .end annotation

    .prologue
    .line 179
    const/4 v0, 0x0

    :goto_0
    if-ge v0, p2, :cond_0

    .line 180
    invoke-interface {p0, p1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 179
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 182
    :cond_0
    return-void
.end method

.method private static fileSafe(Ljava/lang/String;)Ljava/lang/String;
    .locals 6

    .prologue
    const/16 v3, 0x5f

    const/4 v1, 0x0

    .line 169
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    move v0, v1

    .line 170
    :goto_0
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v2

    if-ge v0, v2, :cond_6

    const/16 v2, 0x40

    if-ge v0, v2, :cond_6

    .line 171
    invoke-virtual {p0, v0}, Ljava/lang/String;->charAt(I)C

    move-result v2

    .line 172
    const/16 v4, 0x61

    if-lt v2, v4, :cond_0

    const/16 v4, 0x7a

    if-le v2, v4, :cond_3

    :cond_0
    const/16 v4, 0x41

    if-lt v2, v4, :cond_1

    const/16 v4, 0x5a

    if-le v2, v4, :cond_3

    :cond_1
    const/16 v4, 0x30

    if-lt v2, v4, :cond_2

    const/16 v4, 0x39

    if-le v2, v4, :cond_3

    :cond_2
    const/16 v4, 0x2d

    if-eq v2, v4, :cond_3

    if-ne v2, v3, :cond_4

    :cond_3
    const/4 v4, 0x1

    .line 173
    :goto_1
    if-eqz v4, :cond_5

    :goto_2
    invoke-virtual {v5, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 170
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    :cond_4
    move v4, v1

    .line 172
    goto :goto_1

    :cond_5
    move v2, v3

    .line 173
    goto :goto_2

    .line 175
    :cond_6
    invoke-virtual {v5}, Ljava/lang/StringBuilder;->length()I

    move-result v0

    if-nez v0, :cond_7

    const-string v0, "_"

    :goto_3
    return-object v0

    :cond_7
    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    goto :goto_3
.end method

.method private imported()Ljava/util/List;
    .locals 10
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/FriendCafe;",
            ">;"
        }
    .end annotation

    .prologue
    .line 127
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 128
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 129
    new-instance v2, Ljava/io/File;

    iget-object v3, p0, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->storage:Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;

    invoke-interface {v3}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;->filesDir()Ljava/io/File;

    move-result-object v3

    const-string v4, "offline/cafes"

    invoke-direct {v2, v3, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-interface {v0, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 130
    iget-object v2, p0, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->storage:Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;

    invoke-interface {v2}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;->externalFilesDir()Ljava/io/File;

    move-result-object v2

    .line 131
    if-eqz v2, :cond_0

    .line 132
    new-instance v3, Ljava/io/File;

    const-string v4, "cafes"

    invoke-direct {v3, v2, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-interface {v0, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 134
    :cond_0
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :cond_1
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_4

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/io/File;

    .line 135
    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->sortedDatFiles(Ljava/io/File;)[Ljava/io/File;

    move-result-object v3

    array-length v4, v3

    const/4 v0, 0x0

    :goto_0
    if-ge v0, v4, :cond_1

    aget-object v5, v3, v0

    .line 136
    invoke-virtual {v5}, Ljava/io/File;->length()J

    move-result-wide v6

    const-wide/32 v8, 0x100000

    cmp-long v6, v6, v8

    if-lez v6, :cond_3

    .line 135
    :cond_2
    :goto_1
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 139
    :cond_3
    invoke-static {v5}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->parseFile(Ljava/io/File;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v5

    .line 140
    if-eqz v5, :cond_2

    .line 141
    invoke-interface {v1, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_1

    .line 145
    :cond_4
    return-object v1
.end method

.method private static parseFile(Ljava/io/File;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
    .locals 4

    .prologue
    const/4 v0, 0x0

    .line 201
    invoke-static {p0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->readFile(Ljava/io/File;)[B

    move-result-object v1

    .line 202
    if-nez v1, :cond_0

    .line 209
    :goto_0
    return-object v0

    .line 206
    :cond_0
    :try_start_0
    invoke-static {v1}, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->parse([B)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
    :try_end_0
    .catch Lcom/capcom/zombiecafeandroid/offline/ZcFormatException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v0

    goto :goto_0

    .line 207
    :catch_0
    move-exception v1

    .line 208
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "skipping "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, ": "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;->getMessage()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    goto :goto_0
.end method

.method private static readAll(Ljava/io/InputStream;)[B
    .locals 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 253
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 254
    const/16 v1, 0x2000

    new-array v1, v1, [B

    .line 256
    :goto_0
    invoke-virtual {p0, v1}, Ljava/io/InputStream;->read([B)I

    move-result v2

    if-lez v2, :cond_0

    .line 257
    const/4 v3, 0x0

    invoke-virtual {v0, v1, v3, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_0

    .line 259
    :cond_0
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v0

    return-object v0
.end method

.method private readAsset(Ljava/lang/String;)[B
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 214
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->storage:Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;

    invoke-interface {v0, p1}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;->openAsset(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v0

    .line 216
    :try_start_0
    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->readAll(Ljava/io/InputStream;)[B
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result-object v1

    .line 218
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V

    .line 216
    return-object v1

    .line 218
    :catchall_0
    move-exception v1

    invoke-virtual {v0}, Ljava/io/InputStream;->close()V

    .line 219
    throw v1
.end method

.method private static readFile(Ljava/io/File;)[B
    .locals 4

    .prologue
    const/4 v0, 0x0

    .line 223
    invoke-virtual {p0}, Ljava/io/File;->isFile()Z

    move-result v1

    if-nez v1, :cond_0

    .line 235
    :goto_0
    return-object v0

    .line 227
    :cond_0
    :try_start_0
    new-instance v2, Ljava/io/FileInputStream;

    invoke-direct {v2, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 229
    :try_start_1
    invoke-static {v2}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->readAll(Ljava/io/InputStream;)[B
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    move-result-object v1

    .line 231
    :try_start_2
    invoke-virtual {v2}, Ljava/io/InputStream;->close()V

    move-object v0, v1

    .line 229
    goto :goto_0

    .line 231
    :catchall_0
    move-exception v1

    invoke-virtual {v2}, Ljava/io/InputStream;->close()V

    .line 232
    throw v1
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_0

    .line 233
    :catch_0
    move-exception v1

    .line 234
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "could not read "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2, v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    goto :goto_0
.end method

.method private snapshots()Ljava/util/List;
    .locals 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/FriendCafe;",
            ">;"
        }
    .end annotation

    .prologue
    .line 149
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 150
    new-instance v0, Ljava/io/File;

    iget-object v2, p0, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->storage:Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;

    invoke-interface {v2}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;->filesDir()Ljava/io/File;

    move-result-object v2

    const-string v3, "offline/snapshots"

    invoke-direct {v0, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->sortedDatFiles(Ljava/io/File;)[Ljava/io/File;

    move-result-object v2

    array-length v3, v2

    const/4 v0, 0x0

    :goto_0
    if-ge v0, v3, :cond_1

    aget-object v4, v2, v0

    .line 151
    invoke-static {v4}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->parseFile(Ljava/io/File;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v4

    .line 152
    if-eqz v4, :cond_0

    .line 153
    invoke-interface {v1, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 150
    :cond_0
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 156
    :cond_1
    return-object v1
.end method

.method private static sortedDatFiles(Ljava/io/File;)[Ljava/io/File;
    .locals 7

    .prologue
    const/4 v0, 0x0

    .line 185
    invoke-virtual {p0}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object v1

    .line 186
    if-nez v1, :cond_0

    .line 187
    new-array v0, v0, [Ljava/io/File;

    .line 197
    :goto_0
    return-object v0

    .line 189
    :cond_0
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    .line 190
    array-length v3, v1

    :goto_1
    if-ge v0, v3, :cond_2

    aget-object v4, v1, v0

    .line 191
    invoke-virtual {v4}, Ljava/io/File;->isFile()Z

    move-result v5

    if-eqz v5, :cond_1

    invoke-virtual {v4}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v5

    sget-object v6, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-virtual {v5, v6}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v5

    const-string v6, ".dat"

    invoke-virtual {v5, v6}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v5

    if-eqz v5, :cond_1

    .line 192
    invoke-interface {v2, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 190
    :cond_1
    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    .line 195
    :cond_2
    invoke-interface {v2}, Ljava/util/List;->size()I

    move-result v0

    new-array v0, v0, [Ljava/io/File;

    invoke-interface {v2, v0}, Ljava/util/List;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Ljava/io/File;

    .line 196
    invoke-static {v0}, Ljava/util/Arrays;->sort([Ljava/lang/Object;)V

    goto :goto_0
.end method

.method private template()Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
    .locals 2

    .prologue
    .line 161
    :try_start_0
    const-string v0, "offline/rival_template.dat"

    invoke-direct {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->readAsset(Ljava/lang/String;)[B

    move-result-object v0

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->parse([B)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v0

    .line 164
    :goto_0
    return-object v0

    .line 162
    :catch_0
    move-exception v0

    .line 163
    const-string v1, "bundled rival template unavailable"

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 164
    const/4 v0, 0x0

    goto :goto_0
.end method

.method private static writeFile(Ljava/io/File;[B)V
    .locals 3

    .prologue
    .line 241
    :try_start_0
    new-instance v0, Ljava/io/FileOutputStream;

    invoke-direct {v0, p0}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 243
    :try_start_1
    invoke-virtual {v0, p1}, Ljava/io/FileOutputStream;->write([B)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 245
    :try_start_2
    invoke-virtual {v0}, Ljava/io/FileOutputStream;->close()V

    .line 250
    :goto_0
    return-void

    .line 245
    :catchall_0
    move-exception v1

    invoke-virtual {v0}, Ljava/io/FileOutputStream;->close()V

    .line 246
    throw v1
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_0

    .line 247
    :catch_0
    move-exception v0

    .line 248
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "could not write "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    goto :goto_0
.end method


# virtual methods
.method archiveSnapshot()V
    .locals 6

    .prologue
    .line 98
    new-instance v0, Ljava/io/File;

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->storage:Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;

    invoke-interface {v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;->filesDir()Ljava/io/File;

    move-result-object v1

    const-string v2, "ServerData.dat"

    invoke-direct {v0, v1, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 99
    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->readFile(Ljava/io/File;)[B

    move-result-object v0

    .line 100
    if-nez v0, :cond_1

    .line 124
    :cond_0
    :goto_0
    return-void

    .line 104
    :cond_1
    :try_start_0
    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->parse([B)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
    :try_end_0
    .catch Lcom/capcom/zombiecafeandroid/offline/ZcFormatException; {:try_start_0 .. :try_end_0} :catch_0

    .line 109
    new-instance v1, Ljava/io/File;

    iget-object v2, p0, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->storage:Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;

    invoke-interface {v2}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;->filesDir()Ljava/io/File;

    move-result-object v2

    const-string v3, "offline/snapshots"

    invoke-direct {v1, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 110
    invoke-virtual {v1}, Ljava/io/File;->isDirectory()Z

    move-result v2

    if-nez v2, :cond_2

    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 113
    :cond_2
    invoke-static {v1}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->sortedDatFiles(Ljava/io/File;)[Ljava/io/File;

    move-result-object v2

    .line 114
    array-length v3, v2

    if-lez v3, :cond_3

    array-length v3, v2

    add-int/lit8 v3, v3, -0x1

    aget-object v2, v2, v3

    invoke-static {v2}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->readFile(Ljava/io/File;)[B

    move-result-object v2

    invoke-static {v2, v0}, Ljava/util/Arrays;->equals([B[B)Z

    move-result v2

    if-nez v2, :cond_0

    .line 117
    :cond_3
    new-instance v2, Ljava/io/File;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "snap-"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v4

    invoke-virtual {v3, v4, v5}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ".dat"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v2, v1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v2, v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->writeFile(Ljava/io/File;[B)V

    .line 118
    invoke-static {v1}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->sortedDatFiles(Ljava/io/File;)[Ljava/io/File;

    move-result-object v1

    .line 119
    const/4 v0, 0x0

    :goto_1
    array-length v2, v1

    add-int/lit8 v2, v2, -0x6

    if-ge v0, v2, :cond_0

    .line 120
    aget-object v2, v1, v0

    invoke-virtual {v2}, Ljava/io/File;->delete()Z

    move-result v2

    if-nez v2, :cond_4

    .line 121
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "could not prune "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    aget-object v3, v1, v0

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    const/4 v3, 0x0

    invoke-static {v2, v3}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 119
    :cond_4
    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    .line 105
    :catch_0
    move-exception v0

    .line 106
    const-string v1, "not archiving unparseable ServerData.dat"

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    goto/16 :goto_0
.end method

.method loadCatalog()Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;
    .locals 3

    .prologue
    .line 47
    :try_start_0
    const-string v0, "data/characterData.bin.mid"

    invoke-direct {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->readAsset(Ljava/lang/String;)[B

    move-result-object v0

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->parse([B)Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    move-result-object v0

    .line 48
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "character catalog: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->size()I

    move-result v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " types"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->d(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 52
    :goto_0
    return-object v0

    .line 50
    :catch_0
    move-exception v0

    .line 51
    const-string v1, "character catalog unavailable, using flat stats"

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 52
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->empty()Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    move-result-object v0

    goto :goto_0
.end method

.method loadPlayer()Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
    .locals 3

    .prologue
    .line 42
    new-instance v0, Ljava/io/File;

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->storage:Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;

    invoke-interface {v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;->filesDir()Ljava/io/File;

    move-result-object v1

    const-string v2, "ServerData.dat"

    invoke-direct {v0, v1, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->parseFile(Ljava/io/File;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v0

    return-object v0
.end method

.method neighborLayout(Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;Ljava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
    .locals 4

    .prologue
    .line 83
    new-instance v1, Ljava/io/File;

    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->storage:Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;

    invoke-interface {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineStorage;->filesDir()Ljava/io/File;

    move-result-object v0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "offline/neighbors/"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-static {p1}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->fileSafe(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, ".dat"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 84
    invoke-static {v1}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->parseFile(Ljava/io/File;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v0

    .line 85
    if-eqz v0, :cond_1

    .line 93
    :cond_0
    :goto_0
    return-object v0

    .line 88
    :cond_1
    invoke-virtual {p0, p2, p3}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->pickLayout(Lcom/capcom/zombiecafeandroid/offline/FriendCafe;Ljava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v0

    .line 89
    invoke-virtual {v1}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v2

    .line 90
    if-eqz v0, :cond_0

    invoke-virtual {v2}, Ljava/io/File;->isDirectory()Z

    move-result v3

    if-nez v3, :cond_2

    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 91
    :cond_2
    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->toBytes()[B

    move-result-object v2

    invoke-static {v1, v2}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->writeFile(Ljava/io/File;[B)V

    goto :goto_0
.end method

.method pickLayout(Lcom/capcom/zombiecafeandroid/offline/FriendCafe;Ljava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;
    .locals 4

    .prologue
    .line 58
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 59
    invoke-direct {p0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->imported()Ljava/util/List;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    .line 60
    const/4 v3, 0x3

    invoke-static {v1, v0, v3}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->addWeighted(Ljava/util/List;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;I)V

    goto :goto_0

    .line 62
    :cond_0
    invoke-direct {p0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->template()Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v0

    .line 63
    if-eqz v0, :cond_1

    .line 64
    const/4 v2, 0x2

    invoke-static {v1, v0, v2}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->addWeighted(Ljava/util/List;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;I)V

    .line 66
    :cond_1
    invoke-direct {p0}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->snapshots()Ljava/util/List;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_1
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_2

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    .line 67
    const/4 v3, 0x1

    invoke-static {v1, v0, v3}, Lcom/capcom/zombiecafeandroid/offline/RivalRepository;->addWeighted(Ljava/util/List;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;I)V

    goto :goto_1

    .line 69
    :cond_2
    invoke-interface {v1}, Ljava/util/List;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_3

    if-eqz p1, :cond_3

    .line 70
    invoke-interface {v1, p1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 72
    :cond_3
    invoke-interface {v1}, Ljava/util/List;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_4

    .line 73
    const/4 v0, 0x0

    .line 75
    :goto_2
    return-object v0

    :cond_4
    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v0

    invoke-virtual {p2, v0}, Ljava/util/Random;->nextInt(I)I

    move-result v0

    invoke-interface {v1, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    goto :goto_2
.end method
