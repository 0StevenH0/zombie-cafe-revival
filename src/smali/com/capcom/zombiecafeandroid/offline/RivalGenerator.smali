.class final Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;
.super Ljava/lang/Object;
.source "RivalGenerator.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;,
        Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;
    }
.end annotation


# static fields
.field private static final DEFAULT_COMBAT:D = 8.0

.field private static final DEFAULT_ENERGY:D = 100.0

.field private static final DEFENDER_NAMES:[Ljava/lang/String;

.field static final FULL_ENERGY:F = 1000000.0f

.field static final MAX_DEFENDERS:I = 0xc

.field private static final MIN_TARGET:D = 1.0


# instance fields
.field private final catalog:Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .prologue
    .line 38
    const/16 v0, 0x26

    new-array v0, v0, [Ljava/lang/String;

    const/4 v1, 0x0

    const-string v2, "Abigail"

    aput-object v2, v0, v1

    const/4 v1, 0x1

    const-string v2, "Alfonso"

    aput-object v2, v0, v1

    const/4 v1, 0x2

    const-string v2, "Barney"

    aput-object v2, v0, v1

    const/4 v1, 0x3

    const-string v2, "Bianca"

    aput-object v2, v0, v1

    const/4 v1, 0x4

    const-string v2, "Carlos"

    aput-object v2, v0, v1

    const/4 v1, 0x5

    const-string v2, "Cecilia"

    aput-object v2, v0, v1

    const/4 v1, 0x6

    const-string v2, "Dmitri"

    aput-object v2, v0, v1

    const/4 v1, 0x7

    const-string v2, "Dolores"

    aput-object v2, v0, v1

    const/16 v1, 0x8

    const-string v2, "Edgar"

    aput-object v2, v0, v1

    const/16 v1, 0x9

    const-string v2, "Eloise"

    aput-object v2, v0, v1

    const/16 v1, 0xa

    const-string v2, "Felix"

    aput-object v2, v0, v1

    const/16 v1, 0xb

    const-string v2, "Fiona"

    aput-object v2, v0, v1

    const/16 v1, 0xc

    const-string v2, "Gordon"

    aput-object v2, v0, v1

    const/16 v1, 0xd

    const-string v2, "Greta"

    aput-object v2, v0, v1

    const/16 v1, 0xe

    const-string v2, "Hector"

    aput-object v2, v0, v1

    const/16 v1, 0xf

    const-string v2, "Hilda"

    aput-object v2, v0, v1

    const/16 v1, 0x10

    const-string v2, "Ignatius"

    aput-object v2, v0, v1

    const/16 v1, 0x11

    const-string v2, "Imogen"

    aput-object v2, v0, v1

    const/16 v1, 0x12

    const-string v2, "Jasper"

    aput-object v2, v0, v1

    const/16 v1, 0x13

    const-string v2, "Juniper"

    aput-object v2, v0, v1

    const/16 v1, 0x14

    const-string v2, "Klaus"

    aput-object v2, v0, v1

    const/16 v1, 0x15

    const-string v2, "Lorna"

    aput-object v2, v0, v1

    const/16 v1, 0x16

    const-string v2, "Marvin"

    aput-object v2, v0, v1

    const/16 v1, 0x17

    const-string v2, "Nadia"

    aput-object v2, v0, v1

    const/16 v1, 0x18

    const-string v2, "Oscar"

    aput-object v2, v0, v1

    const/16 v1, 0x19

    const-string v2, "Ophelia"

    aput-object v2, v0, v1

    const/16 v1, 0x1a

    const-string v2, "Percy"

    aput-object v2, v0, v1

    const/16 v1, 0x1b

    const-string v2, "Priya"

    aput-object v2, v0, v1

    const/16 v1, 0x1c

    const-string v2, "Quentin"

    aput-object v2, v0, v1

    const/16 v1, 0x1d

    const-string v2, "Rosalind"

    aput-object v2, v0, v1

    const/16 v1, 0x1e

    const-string v2, "Sergio"

    aput-object v2, v0, v1

    const/16 v1, 0x1f

    const-string v2, "Tabitha"

    aput-object v2, v0, v1

    const/16 v1, 0x20

    const-string v2, "Ulric"

    aput-object v2, v0, v1

    const/16 v1, 0x21

    const-string v2, "Valerie"

    aput-object v2, v0, v1

    const/16 v1, 0x22

    const-string v2, "Wendell"

    aput-object v2, v0, v1

    const/16 v1, 0x23

    const-string v2, "Xenia"

    aput-object v2, v0, v1

    const/16 v1, 0x24

    const-string v2, "Yusuf"

    aput-object v2, v0, v1

    const/16 v1, 0x25

    const-string v2, "Zelda"

    aput-object v2, v0, v1

    sput-object v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->DEFENDER_NAMES:[Ljava/lang/String;

    return-void
.end method

.method constructor <init>(Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;)V
    .locals 0

    .prologue
    .line 87
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 88
    if-nez p1, :cond_0

    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->empty()Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    move-result-object p1

    :cond_0
    iput-object p1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->catalog:Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    .line 89
    return-void
.end method

.method private static addUnique(Ljava/util/List;Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;",
            ">;",
            "Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;",
            ")V"
        }
    .end annotation

    .prologue
    .line 205
    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;

    .line 206
    iget v0, v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->type:I

    iget v2, p1, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->type:I

    if-ne v0, v2, :cond_0

    .line 211
    :goto_0
    return-void

    .line 210
    :cond_1
    invoke-interface {p0, p1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0
.end method

.method static ascii(Ljava/lang/String;)[B
    .locals 4

    .prologue
    .line 280
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    new-array v2, v0, [B

    .line 281
    const/4 v0, 0x0

    :goto_0
    array-length v1, v2

    if-ge v0, v1, :cond_1

    .line 282
    invoke-virtual {p0, v0}, Ljava/lang/String;->charAt(I)C

    move-result v1

    .line 283
    const/16 v3, 0x80

    if-ge v1, v3, :cond_0

    :goto_1
    int-to-byte v1, v1

    aput-byte v1, v2, v0

    .line 281
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 283
    :cond_0
    const/16 v1, 0x3f

    goto :goto_1

    .line 285
    :cond_1
    return-object v2
.end method

.method private candidates(Ljava/util/List;Ljava/util/List;I)Ljava/util/List;
    .locals 8
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;",
            ">;",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;",
            ">;I)",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;",
            ">;"
        }
    .end annotation

    .prologue
    const/4 v5, 0x0

    .line 178
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 180
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    .line 181
    new-instance v3, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;

    iget v4, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    const-wide/high16 v6, 0x4008000000000000L    # 3.0

    invoke-direct {v3, v4, v0, v6, v7}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;-><init>(ILcom/capcom/zombiecafeandroid/offline/CharacterRecord;D)V

    invoke-static {v1, v3}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->addUnique(Ljava/util/List;Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;)V

    goto :goto_0

    .line 183
    :cond_0
    invoke-interface {p1}, Ljava/util/List;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_1

    invoke-interface {p1, v5}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    move-object v2, v0

    .line 185
    :goto_1
    if-nez v2, :cond_3

    move-object v0, v1

    .line 201
    :goto_2
    return-object v0

    .line 184
    :cond_1
    invoke-interface {p2}, Ljava/util/List;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_2

    invoke-interface {p2, v5}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    move-object v2, v0

    goto :goto_1

    :cond_2
    const/4 v0, 0x0

    move-object v2, v0

    goto :goto_1

    .line 189
    :cond_3
    invoke-interface {p2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :cond_4
    :goto_3
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_6

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    .line 190
    iget-object v4, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->catalog:Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    iget v5, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    invoke-virtual {v4, v5}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->get(I)Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;

    move-result-object v4

    .line 191
    if-eqz v4, :cond_5

    invoke-virtual {v4}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->isInfectable()Z

    move-result v5

    if-eqz v5, :cond_4

    iget v4, v4, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->levelRequired:I

    if-gt v4, p3, :cond_4

    .line 192
    :cond_5
    new-instance v4, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;

    iget v5, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    const-wide/high16 v6, 0x4000000000000000L    # 2.0

    invoke-direct {v4, v5, v0, v6, v7}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;-><init>(ILcom/capcom/zombiecafeandroid/offline/CharacterRecord;D)V

    invoke-static {v1, v4}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->addUnique(Ljava/util/List;Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;)V

    goto :goto_3

    .line 196
    :cond_6
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->catalog:Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->all()Ljava/util/List;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :cond_7
    :goto_4
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_8

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;

    .line 197
    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->isInfectable()Z

    move-result v4

    if-eqz v4, :cond_7

    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->isBaseRoster()Z

    move-result v4

    if-eqz v4, :cond_7

    iget v4, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->levelRequired:I

    if-gt v4, p3, :cond_7

    .line 198
    new-instance v4, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;

    iget v0, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->type:I

    const-wide/high16 v6, 0x3ff0000000000000L    # 1.0

    invoke-direct {v4, v0, v2, v6, v7}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;-><init>(ILcom/capcom/zombiecafeandroid/offline/CharacterRecord;D)V

    invoke-static {v1, v4}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->addUnique(Ljava/util/List;Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;)V

    goto :goto_4

    :cond_8
    move-object v0, v1

    .line 201
    goto :goto_2
.end method

.method private static clamp(DDD)D
    .locals 2

    .prologue
    .line 296
    cmpg-double v0, p0, p2

    if-gez v0, :cond_0

    :goto_0
    return-wide p2

    :cond_0
    cmpl-double v0, p0, p4

    if-lez v0, :cond_1

    move-wide p2, p4

    goto :goto_0

    :cond_1
    move-wide p2, p0

    goto :goto_0
.end method

.method private static concat([B[B)[B
    .locals 4

    .prologue
    const/4 v3, 0x0

    .line 289
    array-length v0, p0

    array-length v1, p1

    add-int/2addr v0, v1

    new-array v0, v0, [B

    .line 290
    array-length v1, p0

    invoke-static {p0, v3, v0, v3, v1}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 291
    array-length v1, p0

    array-length v2, p1

    invoke-static {p1, v3, v0, v1, v2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 292
    return-object v0
.end method

.method static levelFactor(I)D
    .locals 6

    .prologue
    .line 174
    const-wide/high16 v0, 0x3ff0000000000000L    # 1.0

    const-wide/high16 v2, 0x3fd0000000000000L    # 0.25

    const/4 v4, 0x0

    invoke-static {v4, p0}, Ljava/lang/Math;->max(II)I

    move-result v4

    int-to-double v4, v4

    mul-double/2addr v2, v4

    add-double/2addr v0, v2

    return-wide v0
.end method

.method private maxEnergy(II)D
    .locals 4

    .prologue
    .line 167
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->catalog:Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    invoke-virtual {v0, p1}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->get(I)Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;

    move-result-object v0

    .line 168
    if-eqz v0, :cond_0

    iget v1, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->energy:I

    if-lez v1, :cond_0

    iget v0, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->energy:I

    int-to-double v0, v0

    .line 169
    :goto_0
    invoke-static {p2}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->levelFactor(I)D

    move-result-wide v2

    mul-double/2addr v0, v2

    return-wide v0

    .line 168
    :cond_0
    const-wide/high16 v0, 0x4059000000000000L    # 100.0

    goto :goto_0
.end method

.method private static nameSuffix(Ljava/util/List;Lcom/capcom/zombiecafeandroid/offline/CafeState;)[B
    .locals 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;",
            ">;",
            "Lcom/capcom/zombiecafeandroid/offline/CafeState;",
            ")[B"
        }
    .end annotation

    .prologue
    const/4 v6, 0x2

    const/4 v5, 0x1

    const/4 v4, 0x0

    .line 258
    const/4 v0, 0x0

    .line 259
    invoke-interface {p0}, Ljava/util/List;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_1

    .line 260
    invoke-interface {p0, v4}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    iget-object v0, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->name:[B

    .line 266
    :cond_0
    :goto_0
    if-nez v0, :cond_3

    .line 267
    new-array v0, v4, [B

    .line 276
    :goto_1
    return-object v0

    .line 261
    :cond_1
    iget-object v1, p1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    if-eqz v1, :cond_2

    .line 262
    iget-object v0, p1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    iget-object v0, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->name:[B

    goto :goto_0

    .line 263
    :cond_2
    iget-object v1, p1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_0

    .line 264
    iget-object v0, p1, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    invoke-interface {v0, v4}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    iget-object v0, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->name:[B

    goto :goto_0

    .line 269
    :cond_3
    array-length v1, v0

    .line 270
    if-lt v1, v6, :cond_4

    add-int/lit8 v2, v1, -0x2

    aget-byte v2, v0, v2

    const/16 v3, 0xd

    if-ne v2, v3, :cond_4

    add-int/lit8 v2, v1, -0x1

    aget-byte v2, v0, v2

    if-nez v2, :cond_4

    .line 271
    new-array v0, v6, [B

    fill-array-data v0, :array_0

    goto :goto_1

    .line 273
    :cond_4
    if-lt v1, v5, :cond_5

    add-int/lit8 v1, v1, -0x1

    aget-byte v0, v0, v1

    if-nez v0, :cond_5

    .line 274
    new-array v0, v5, [B

    aput-byte v4, v0, v4

    goto :goto_1

    .line 276
    :cond_5
    new-array v0, v4, [B

    goto :goto_1

    .line 271
    :array_0
    .array-data 1
        0xdt
        0x0t
    .end array-data
.end method

.method private pick(Ljava/util/List;DLjava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;
    .locals 14
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;",
            ">;D",
            "Ljava/util/Random;",
            ")",
            "Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;"
        }
    .end annotation

    .prologue
    .line 215
    new-instance v7, Ljava/util/ArrayList;

    invoke-direct {v7}, Ljava/util/ArrayList;-><init>()V

    .line 216
    const-wide/16 v2, 0x0

    .line 217
    const/4 v6, 0x0

    .line 218
    const-wide v0, 0x7fefffffffffffffL    # Double.MAX_VALUE

    .line 219
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v10

    move-wide v4, v0

    :goto_0
    invoke-interface {v10}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-interface {v10}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;

    .line 220
    iget v1, v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->type:I

    const/4 v8, 0x0

    const-wide/high16 v12, 0x3ff0000000000000L    # 1.0

    invoke-virtual {p0, v1, v8, v12, v13}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->power(IID)D

    move-result-wide v8

    .line 221
    cmpg-double v1, v8, v4

    if-gez v1, :cond_0

    move-wide v4, v8

    move-object v6, v0

    .line 225
    :cond_0
    const-wide/high16 v12, 0x3ff4000000000000L    # 1.25

    mul-double v12, v12, p2

    cmpg-double v1, v8, v12

    if-gtz v1, :cond_5

    .line 226
    invoke-interface {v7, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 227
    iget-wide v0, v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->weight:D

    add-double/2addr v0, v2

    :goto_1
    move-wide v2, v0

    .line 229
    goto :goto_0

    .line 230
    :cond_1
    invoke-interface {v7}, Ljava/util/List;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_2

    move-object v0, v6

    .line 240
    :goto_2
    return-object v0

    .line 233
    :cond_2
    invoke-virtual/range {p4 .. p4}, Ljava/util/Random;->nextDouble()D

    move-result-wide v0

    mul-double/2addr v0, v2

    .line 234
    invoke-interface {v7}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v4

    move-wide v2, v0

    :cond_3
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_4

    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;

    .line 235
    iget-wide v8, v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->weight:D

    sub-double/2addr v2, v8

    .line 236
    const-wide/16 v8, 0x0

    cmpg-double v1, v2, v8

    if-gtz v1, :cond_3

    goto :goto_2

    .line 240
    :cond_4
    invoke-interface {v7}, Ljava/util/List;->size()I

    move-result v0

    add-int/lit8 v0, v0, -0x1

    invoke-interface {v7, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;

    goto :goto_2

    :cond_5
    move-wide v0, v2

    goto :goto_1
.end method

.method private static pickLevel(Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;ILcom/capcom/zombiecafeandroid/offline/Tier;Ljava/util/Random;)I
    .locals 6

    .prologue
    const/4 v2, 0x2

    .line 244
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->template:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    iget v0, v0, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->type:I

    if-ne v0, v1, :cond_1

    const/4 v0, 0x0

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->template:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    iget v1, v1, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    invoke-static {v0, v1}, Ljava/lang/Math;->max(II)I

    move-result v0

    .line 246
    :goto_0
    sget-object v1, Lcom/capcom/zombiecafeandroid/offline/Tier;->EASY:Lcom/capcom/zombiecafeandroid/offline/Tier;

    if-ne p2, v1, :cond_2

    .line 247
    invoke-virtual {p3, v2}, Ljava/util/Random;->nextInt(I)I

    move-result v1

    sub-int/2addr v0, v1

    .line 253
    :cond_0
    :goto_1
    int-to-double v0, v0

    const-wide/16 v2, 0x0

    int-to-double v4, p1

    invoke-static/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->clamp(DDD)D

    move-result-wide v0

    double-to-int v0, v0

    return v0

    .line 244
    :cond_1
    add-int/lit8 v0, p1, 0x1

    invoke-virtual {p3, v0}, Ljava/util/Random;->nextInt(I)I

    move-result v0

    goto :goto_0

    .line 248
    :cond_2
    sget-object v1, Lcom/capcom/zombiecafeandroid/offline/Tier;->HARD:Lcom/capcom/zombiecafeandroid/offline/Tier;

    if-ne p2, v1, :cond_0

    .line 249
    invoke-virtual {p3, v2}, Ljava/util/Random;->nextInt(I)I

    move-result v1

    add-int/2addr v0, v1

    goto :goto_1
.end method


# virtual methods
.method generate(Lcom/capcom/zombiecafeandroid/offline/FriendCafe;Lcom/capcom/zombiecafeandroid/offline/FriendCafe;Lcom/capcom/zombiecafeandroid/offline/RivalProfile;JD)Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;
    .locals 26

    .prologue
    .line 99
    new-instance v14, Ljava/util/Random;

    move-wide/from16 v0, p4

    invoke-direct {v14, v0, v1}, Ljava/util/Random;-><init>(J)V

    .line 101
    if-eqz p1, :cond_0

    move-object/from16 v0, p1

    iget-object v2, v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    iget-object v2, v2, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->isEmpty()Z

    move-result v2

    if-nez v2, :cond_0

    .line 102
    move-object/from16 v0, p1

    iget-object v2, v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    iget-object v2, v2, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    move-object v11, v2

    .line 103
    :goto_0
    const/4 v3, 0x1

    if-eqz p1, :cond_1

    move-object/from16 v0, p1

    iget-object v2, v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    iget v2, v2, Lcom/capcom/zombiecafeandroid/offline/CafeState;->level:I

    :goto_1
    invoke-static {v3, v2}, Ljava/lang/Math;->max(II)I

    move-result v12

    .line 104
    const/4 v2, 0x0

    .line 105
    invoke-interface {v11}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    move v10, v2

    :goto_2
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_2

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    .line 106
    const/4 v4, 0x0

    iget v2, v2, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    invoke-static {v4, v2}, Ljava/lang/Math;->max(II)I

    move-result v2

    invoke-static {v10, v2}, Ljava/lang/Math;->max(II)I

    move-result v2

    move v10, v2

    .line 107
    goto :goto_2

    .line 102
    :cond_0
    move-object/from16 v0, p2

    iget-object v2, v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    iget-object v2, v2, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    move-object v11, v2

    goto :goto_0

    .line 103
    :cond_1
    move-object/from16 v0, p2

    iget-object v2, v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    iget v2, v2, Lcom/capcom/zombiecafeandroid/offline/CafeState;->level:I

    goto :goto_1

    .line 109
    :cond_2
    const-wide/16 v8, 0x0

    .line 110
    invoke-interface {v11}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :goto_3
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_3

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    .line 111
    iget v4, v2, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    iget v2, v2, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    const-wide/high16 v6, 0x3ff0000000000000L    # 1.0

    move-object/from16 v0, p0

    invoke-virtual {v0, v4, v2, v6, v7}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->power(IID)D

    move-result-wide v4

    add-double/2addr v8, v4

    .line 112
    goto :goto_3

    .line 114
    :cond_3
    move-object/from16 v0, p3

    iget-object v15, v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->tier:Lcom/capcom/zombiecafeandroid/offline/Tier;

    .line 115
    iget-wide v2, v15, Lcom/capcom/zombiecafeandroid/offline/Tier;->minRatio:D

    invoke-virtual {v14}, Ljava/util/Random;->nextDouble()D

    move-result-wide v4

    iget-wide v6, v15, Lcom/capcom/zombiecafeandroid/offline/Tier;->maxRatio:D

    iget-wide v0, v15, Lcom/capcom/zombiecafeandroid/offline/Tier;->minRatio:D

    move-wide/from16 v16, v0

    sub-double v6, v6, v16

    mul-double/2addr v4, v6

    add-double v16, v2, v4

    .line 116
    const-wide/high16 v4, 0x3fd0000000000000L    # 0.25

    const-wide/high16 v6, 0x4010000000000000L    # 4.0

    move-wide/from16 v2, p6

    invoke-static/range {v2 .. v7}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->clamp(DDD)D

    move-result-wide v2

    mul-double v16, v16, v2

    .line 117
    mul-double v2, v8, v16

    const-wide/high16 v4, 0x3ff0000000000000L    # 1.0

    invoke-static {v2, v3, v4, v5}, Ljava/lang/Math;->max(DD)D

    move-result-wide v18

    .line 118
    move-object/from16 v0, p3

    invoke-virtual {v0, v12}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->rivalLevel(I)I

    move-result v20

    .line 120
    move-object/from16 v0, p2

    iget-object v2, v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    invoke-static {v11, v2}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->nameSuffix(Ljava/util/List;Lcom/capcom/zombiecafeandroid/offline/CafeState;)[B

    move-result-object v21

    .line 121
    move-object/from16 v0, p2

    iget-object v2, v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    iget-object v2, v2, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    move-object/from16 v0, p0

    move/from16 v1, v20

    invoke-direct {v0, v11, v2, v1}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->candidates(Ljava/util/List;Ljava/util/List;I)Ljava/util/List;

    move-result-object v22

    .line 122
    invoke-interface {v11}, Ljava/util/List;->size()I

    move-result v2

    add-int/lit8 v2, v2, 0x2

    int-to-double v2, v2

    const-wide/high16 v4, 0x4000000000000000L    # 2.0

    const-wide/high16 v6, 0x4028000000000000L    # 12.0

    invoke-static/range {v2 .. v7}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->clamp(DDD)D

    move-result-wide v2

    double-to-int v4, v2

    .line 124
    new-instance v23, Ljava/util/ArrayList;

    invoke-direct/range {v23 .. v23}, Ljava/util/ArrayList;-><init>()V

    .line 125
    const-wide/16 v2, 0x0

    move-wide v12, v2

    .line 126
    :goto_4
    invoke-interface/range {v22 .. v22}, Ljava/util/List;->isEmpty()Z

    move-result v2

    if-nez v2, :cond_4

    invoke-interface/range {v23 .. v23}, Ljava/util/List;->size()I

    move-result v2

    if-ge v2, v4, :cond_4

    cmpg-double v2, v12, v18

    if-gez v2, :cond_4

    .line 127
    sub-double v2, v18, v12

    move-object/from16 v0, p0

    move-object/from16 v1, v22

    invoke-direct {v0, v1, v2, v3, v14}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->pick(Ljava/util/List;DLjava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;

    move-result-object v2

    .line 128
    iget-object v3, v2, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->template:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    invoke-virtual {v3}, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->copy()Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    move-result-object v3

    .line 129
    iget v5, v2, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->type:I

    iput v5, v3, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    .line 130
    invoke-static {v2, v10, v15, v14}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->pickLevel(Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;ILcom/capcom/zombiecafeandroid/offline/Tier;Ljava/util/Random;)I

    move-result v2

    iput v2, v3, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    .line 131
    const v2, 0x49742400    # 1000000.0f

    iput v2, v3, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->energy:F

    .line 132
    sget-object v2, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->DEFENDER_NAMES:[Ljava/lang/String;

    sget-object v5, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->DEFENDER_NAMES:[Ljava/lang/String;

    array-length v5, v5

    invoke-virtual {v14, v5}, Ljava/util/Random;->nextInt(I)I

    move-result v5

    aget-object v2, v2, v5

    invoke-static {v2}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->ascii(Ljava/lang/String;)[B

    move-result-object v2

    move-object/from16 v0, v21

    invoke-static {v2, v0}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->concat([B[B)[B

    move-result-object v2

    iput-object v2, v3, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->name:[B

    .line 133
    move-object/from16 v0, v23

    invoke-interface {v0, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 134
    iget v2, v3, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    iget v3, v3, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    const-wide/high16 v6, 0x3ff0000000000000L    # 1.0

    move-object/from16 v0, p0

    invoke-virtual {v0, v2, v3, v6, v7}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->power(IID)D

    move-result-wide v2

    add-double/2addr v2, v12

    move-wide v12, v2

    .line 135
    goto :goto_4

    .line 138
    :cond_4
    invoke-interface/range {v23 .. v23}, Ljava/util/List;->size()I

    move-result v2

    const/4 v3, 0x1

    if-le v2, v3, :cond_6

    const-wide v2, 0x3ff199999999999aL    # 1.1

    mul-double v2, v2, v18

    cmpl-double v2, v12, v2

    if-lez v2, :cond_6

    .line 139
    invoke-interface/range {v23 .. v23}, Ljava/util/List;->size()I

    move-result v2

    add-int/lit8 v2, v2, -0x1

    move-object/from16 v0, v23

    invoke-interface {v0, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    move-object v10, v2

    check-cast v10, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    .line 140
    iget v2, v10, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    iget v3, v10, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    const-wide/high16 v4, 0x3ff0000000000000L    # 1.0

    move-object/from16 v0, p0

    invoke-virtual {v0, v2, v3, v4, v5}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->power(IID)D

    move-result-wide v24

    .line 141
    const-wide/high16 v2, 0x3ff0000000000000L    # 1.0

    sub-double v4, v12, v18

    div-double v4, v4, v24

    sub-double/2addr v2, v4

    const-wide v4, 0x3fd6666666666666L    # 0.35

    const-wide/high16 v6, 0x3ff0000000000000L    # 1.0

    invoke-static/range {v2 .. v7}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->clamp(DDD)D

    move-result-wide v2

    .line 142
    iget v4, v10, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->type:I

    iget v5, v10, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->level:I

    move-object/from16 v0, p0

    invoke-direct {v0, v4, v5}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->maxEnergy(II)D

    move-result-wide v4

    mul-double/2addr v4, v2

    double-to-float v4, v4

    iput v4, v10, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->energy:F

    .line 143
    const-wide/high16 v4, 0x3ff0000000000000L    # 1.0

    sub-double v2, v4, v2

    mul-double v2, v2, v24

    sub-double/2addr v12, v2

    move-wide v10, v12

    .line 146
    :goto_5
    move-object/from16 v0, p2

    iget-object v2, v0, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->state:Lcom/capcom/zombiecafeandroid/offline/CafeState;

    invoke-virtual {v2}, Lcom/capcom/zombiecafeandroid/offline/CafeState;->copy()Lcom/capcom/zombiecafeandroid/offline/CafeState;

    move-result-object v12

    .line 147
    move/from16 v0, v20

    iput v0, v12, Lcom/capcom/zombiecafeandroid/offline/CafeState;->level:I

    .line 148
    iget v2, v12, Lcom/capcom/zombiecafeandroid/offline/CafeState;->rating:F

    float-to-double v2, v2

    const-wide/high16 v4, 0x3ff0000000000000L    # 1.0

    sub-double v4, v16, v4

    const-wide v6, 0x3fd3333333333333L    # 0.3

    mul-double/2addr v4, v6

    add-double/2addr v2, v4

    invoke-virtual {v14}, Ljava/util/Random;->nextDouble()D

    move-result-wide v4

    const-wide/high16 v6, 0x3fe0000000000000L    # 0.5

    sub-double/2addr v4, v6

    const-wide v6, 0x3fc999999999999aL    # 0.2

    mul-double/2addr v4, v6

    add-double/2addr v2, v4

    const-wide v4, 0x3fa999999999999aL    # 0.05

    const-wide v6, 0x3fee666666666666L    # 0.95

    invoke-static/range {v2 .. v7}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->clamp(DDD)D

    move-result-wide v2

    double-to-float v2, v2

    iput v2, v12, Lcom/capcom/zombiecafeandroid/offline/CafeState;->rating:F

    .line 149
    iget-object v2, v12, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->clear()V

    .line 150
    iget-object v2, v12, Lcom/capcom/zombiecafeandroid/offline/CafeState;->zombies:Ljava/util/List;

    move-object/from16 v0, v23

    invoke-interface {v2, v0}, Ljava/util/List;->addAll(Ljava/util/Collection;)Z

    .line 151
    iget-object v2, v12, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    if-eqz v2, :cond_5

    .line 152
    iget-object v2, v12, Lcom/capcom/zombiecafeandroid/offline/CafeState;->owner:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    invoke-virtual/range {p3 .. p3}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->fullName()Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->ascii(Ljava/lang/String;)[B

    move-result-object v3

    move-object/from16 v0, v21

    invoke-static {v3, v0}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->concat([B[B)[B

    move-result-object v3

    iput-object v3, v2, Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;->name:[B

    .line 155
    :cond_5
    move-object/from16 v0, p2

    invoke-virtual {v0, v12}, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->withState(Lcom/capcom/zombiecafeandroid/offline/CafeState;)Lcom/capcom/zombiecafeandroid/offline/FriendCafe;

    move-result-object v2

    invoke-virtual {v2}, Lcom/capcom/zombiecafeandroid/offline/FriendCafe;->toBytes()[B

    move-result-object v3

    .line 156
    new-instance v2, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;

    invoke-virtual/range {p3 .. p3}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->fullName()Ljava/lang/String;

    move-result-object v4

    invoke-interface/range {v23 .. v23}, Ljava/util/List;->size()I

    move-result v7

    move-object v5, v15

    move/from16 v6, v20

    invoke-direct/range {v2 .. v11}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Result;-><init>([BLjava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;IIDD)V

    return-object v2

    :cond_6
    move-wide v10, v12

    goto :goto_5
.end method

.method power(IID)D
    .locals 5

    .prologue
    .line 161
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->catalog:Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    invoke-virtual {v0, p1}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->get(I)Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;

    move-result-object v0

    .line 162
    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->combatFactor()I

    move-result v0

    int-to-double v0, v0

    .line 163
    :goto_0
    invoke-direct {p0, p1, p2}, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;->maxEnergy(II)D

    move-result-wide v2

    mul-double/2addr v0, v2

    mul-double/2addr v0, p3

    const-wide/high16 v2, 0x4059000000000000L    # 100.0

    div-double/2addr v0, v2

    return-wide v0

    .line 162
    :cond_0
    const-wide/high16 v0, 0x4020000000000000L    # 8.0

    goto :goto_0
.end method
