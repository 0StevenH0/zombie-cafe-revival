.class final Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;
.super Ljava/lang/Object;
.source "CharacterCatalog.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;
    }
.end annotation


# instance fields
.field private final infos:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method private constructor <init>(Ljava/util/List;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;",
            ">;)V"
        }
    .end annotation

    .prologue
    .line 61
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 62
    invoke-static {p1}, Ljava/util/Collections;->unmodifiableList(Ljava/util/List;)Ljava/util/List;

    move-result-object v0

    iput-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->infos:Ljava/util/List;

    .line 63
    return-void
.end method

.method static empty()Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;
    .locals 2

    .prologue
    .line 66
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    invoke-direct {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;-><init>(Ljava/util/List;)V

    return-object v0
.end method

.method private static latin1([B)Ljava/lang/String;
    .locals 3

    .prologue
    .line 120
    array-length v0, p0

    new-array v1, v0, [C

    .line 121
    const/4 v0, 0x0

    :goto_0
    array-length v2, p0

    if-ge v0, v2, :cond_0

    .line 122
    aget-byte v2, p0, v0

    and-int/lit16 v2, v2, 0xff

    int-to-char v2, v2

    aput-char v2, v1, v0

    .line 121
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 124
    :cond_0
    new-instance v0, Ljava/lang/String;

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>([C)V

    return-object v0
.end method

.method static parse([B)Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;
    .locals 14
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capcom/zombiecafeandroid/offline/ZcFormatException;
        }
    .end annotation

    .prologue
    .line 70
    new-instance v11, Lcom/capcom/zombiecafeandroid/offline/ZcInput;

    invoke-direct {v11, p0}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;-><init>([B)V

    .line 71
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v12

    .line 72
    new-instance v13, Ljava/util/ArrayList;

    invoke-direct {v13, v12}, Ljava/util/ArrayList;-><init>(I)V

    .line 73
    const/4 v1, 0x0

    :goto_0
    if-ge v1, v12, :cond_0

    .line 74
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v3

    .line 75
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    .line 76
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    .line 77
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->string()[B

    move-result-object v0

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->latin1([B)Ljava/lang/String;

    move-result-object v2

    .line 78
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->string()[B

    .line 79
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->string()[B

    .line 80
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v7

    .line 81
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u16()I

    move-result v4

    .line 82
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v5

    .line 83
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v6

    .line 84
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    .line 85
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    .line 86
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    .line 87
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    .line 88
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    .line 89
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    .line 90
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    .line 91
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v8

    .line 92
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->f32()F

    .line 93
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i32()I

    .line 94
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->f32()F

    .line 95
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->f32()F

    .line 96
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    .line 97
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->i16()I

    move-result v9

    .line 98
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->u8()I

    move-result v10

    .line 99
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->string()[B

    .line 100
    invoke-virtual {v11}, Lcom/capcom/zombiecafeandroid/offline/ZcInput;->string()[B

    .line 101
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;

    invoke-direct/range {v0 .. v10}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;-><init>(ILjava/lang/String;IIIIIIII)V

    invoke-interface {v13, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 73
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 103
    :cond_0
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;

    invoke-direct {v0, v13}, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;-><init>(Ljava/util/List;)V

    return-object v0
.end method


# virtual methods
.method all()Ljava/util/List;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;",
            ">;"
        }
    .end annotation

    .prologue
    .line 116
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->infos:Ljava/util/List;

    return-object v0
.end method

.method get(I)Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;
    .locals 1

    .prologue
    .line 112
    if-ltz p1, :cond_0

    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->infos:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->infos:Ljava/util/List;

    invoke-interface {v0, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;

    :goto_0
    return-object v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method size()I
    .locals 1

    .prologue
    .line 107
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;->infos:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v0

    return v0
.end method
