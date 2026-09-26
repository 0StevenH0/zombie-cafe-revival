.class final Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;
.super Ljava/lang/Object;
.source "OfflineRouter.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;,
        Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;
    }
.end annotation


# static fields
.field static final CB_ANALYTICS:I = 0x0

.field static final MAX_METADATA_IDS:I = 0x40


# direct methods
.method private constructor <init>()V
    .locals 0

    .prologue
    .line 80
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static blob([B)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;
    .locals 1

    .prologue
    .line 129
    if-eqz p0, :cond_0

    array-length v0, p0

    if-nez v0, :cond_1

    :cond_0
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->fail()Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    :goto_0
    return-object v0

    :cond_1
    invoke-static {p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->ok([B)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    goto :goto_0
.end method

.method private static decode(Ljava/lang/String;)Ljava/lang/String;
    .locals 1

    .prologue
    .line 181
    :try_start_0
    const-string v0, "UTF-8"

    invoke-static {p0, v0}, Ljava/net/URLDecoder;->decode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object p0

    .line 185
    :goto_0
    return-object p0

    .line 184
    :catch_0
    move-exception v0

    goto :goto_0

    .line 182
    :catch_1
    move-exception v0

    goto :goto_0
.end method

.method static endpoint(Ljava/lang/String;)Ljava/lang/String;
    .locals 2

    .prologue
    .line 134
    if-nez p0, :cond_0

    .line 135
    const-string v0, ""

    .line 140
    :goto_0
    return-object v0

    .line 137
    :cond_0
    const/16 v0, 0x3f

    invoke-virtual {p0, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    .line 138
    if-ltz v0, :cond_1

    const/4 v1, 0x0

    invoke-virtual {p0, v1, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    .line 139
    :cond_1
    const/16 v0, 0x2f

    invoke-virtual {p0, v0}, Ljava/lang/String;->lastIndexOf(I)I

    move-result v0

    .line 140
    add-int/lit8 v0, v0, 0x1

    invoke-virtual {p0, v0}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v0

    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-virtual {v0, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v0

    goto :goto_0
.end method

.method private static metadataIds(Ljava/util/Map;)Ljava/util/List;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Map",
            "<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;)",
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .prologue
    .line 166
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    .line 167
    const/4 v0, 0x0

    move v1, v0

    :goto_0
    const/16 v0, 0x40

    if-ge v1, v0, :cond_0

    .line 168
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "u"

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 169
    if-nez v0, :cond_1

    .line 176
    :cond_0
    return-object v2

    .line 172
    :cond_1
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v3

    if-lez v3, :cond_2

    .line 173
    invoke-interface {v2, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 167
    :cond_2
    add-int/lit8 v0, v1, 0x1

    move v1, v0

    goto :goto_0
.end method

.method static query(Ljava/lang/String;)Ljava/util/Map;
    .locals 9
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            ")",
            "Ljava/util/Map",
            "<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .prologue
    const/4 v5, 0x0

    .line 144
    new-instance v1, Ljava/util/HashMap;

    invoke-direct {v1}, Ljava/util/HashMap;-><init>()V

    .line 145
    if-nez p0, :cond_0

    move-object v0, v1

    .line 161
    :goto_0
    return-object v0

    .line 148
    :cond_0
    const/16 v0, 0x3f

    invoke-virtual {p0, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    .line 149
    if-gez v0, :cond_1

    move-object v0, v1

    .line 150
    goto :goto_0

    .line 152
    :cond_1
    add-int/lit8 v0, v0, 0x1

    invoke-virtual {p0, v0}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v0

    const-string v2, "&"

    invoke-virtual {v0, v2}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v6

    array-length v7, v6

    move v4, v5

    :goto_1
    if-ge v4, v7, :cond_5

    aget-object v3, v6, v4

    .line 153
    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v0

    if-nez v0, :cond_2

    .line 152
    :goto_2
    add-int/lit8 v0, v4, 0x1

    move v4, v0

    goto :goto_1

    .line 156
    :cond_2
    const/16 v0, 0x3d

    invoke-virtual {v3, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v8

    .line 157
    if-ltz v8, :cond_3

    invoke-virtual {v3, v5, v8}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    move-object v2, v0

    .line 158
    :goto_3
    if-ltz v8, :cond_4

    add-int/lit8 v0, v8, 0x1

    invoke-virtual {v3, v0}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v0

    .line 159
    :goto_4
    invoke-static {v2}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;->decode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;->decode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-interface {v1, v2, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_2

    :cond_3
    move-object v2, v3

    .line 157
    goto :goto_3

    .line 158
    :cond_4
    const-string v0, ""

    goto :goto_4

    :cond_5
    move-object v0, v1

    .line 161
    goto :goto_0
.end method

.method static route(Ljava/lang/String;ILcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;
    .locals 5

    .prologue
    const/4 v3, 0x0

    .line 83
    invoke-static {p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;->endpoint(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 84
    invoke-static {p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;->query(Ljava/lang/String;)Ljava/util/Map;

    move-result-object v1

    .line 86
    const-string v2, "gettimestamp.php"

    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 87
    invoke-interface {p2}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;->nowSeconds()J

    move-result-wide v0

    invoke-static {v0, v1}, Ljava/lang/Long;->toString(J)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->text(Ljava/lang/String;)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    .line 125
    :goto_0
    return-object v0

    .line 89
    :cond_0
    const-string v2, "getrandomgamestate.php"

    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 90
    invoke-interface {p2}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;->randomRival()[B

    move-result-object v0

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;->blob([B)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    goto :goto_0

    .line 92
    :cond_1
    const-string v2, "getgamestate.php"

    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_2

    const-string v2, "getsng.php"

    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_2

    const-string v2, "getspecialgamestate.php"

    .line 93
    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_5

    .line 94
    :cond_2
    const-string v0, "u"

    invoke-interface {v1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 95
    if-eqz v0, :cond_3

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    if-nez v1, :cond_4

    :cond_3
    invoke-interface {p2}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;->randomRival()[B

    move-result-object v0

    :goto_1
    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;->blob([B)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    goto :goto_0

    :cond_4
    invoke-interface {p2, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;->rivalFor(Ljava/lang/String;)[B

    move-result-object v0

    goto :goto_1

    .line 97
    :cond_5
    const-string v2, "getmetadata.php"

    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_8

    .line 98
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    .line 99
    invoke-static {v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter;->metadataIds(Ljava/util/Map;)Ljava/util/List;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_6
    :goto_2
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_7

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 100
    invoke-interface {p2, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;->metadataFor(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 101
    if-eqz v3, :cond_6

    .line 102
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const/16 v4, 0x3a

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const/16 v3, 0xa

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    goto :goto_2

    .line 105
    :cond_7
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->text(Ljava/lang/String;)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    goto/16 :goto_0

    .line 107
    :cond_8
    const-string v1, "getspecialmetadata.php"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_9

    .line 108
    const-string v0, ""

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->text(Ljava/lang/String;)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    goto/16 :goto_0

    .line 110
    :cond_9
    const-string v1, "savegamestate.php"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_a

    .line 111
    invoke-interface {p2}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Backend;->onGameStateSaved()V

    .line 112
    invoke-static {v3}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->ok([B)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    goto/16 :goto_0

    .line 114
    :cond_a
    const-string v1, "getgifts.php"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_b

    .line 115
    const-string v0, "NO_DATA"

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->text(Ljava/lang/String;)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    goto/16 :goto_0

    .line 117
    :cond_b
    const-string v1, "gotgifts.php"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_c

    const-string v1, "givegift.php"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_c

    const-string v1, "settoken.php"

    .line 118
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_c

    const-string v1, "versioncheck.php"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_c

    const-string v1, "glinfo.php"

    .line 119
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_d

    .line 120
    :cond_c
    invoke-static {v3}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->ok([B)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    goto/16 :goto_0

    .line 122
    :cond_d
    if-nez p1, :cond_e

    .line 123
    invoke-static {v3}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->ok([B)Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    goto/16 :goto_0

    .line 125
    :cond_e
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;->fail()Lcom/capcom/zombiecafeandroid/offline/OfflineRouter$Response;

    move-result-object v0

    goto/16 :goto_0
.end method
