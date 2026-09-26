.class final enum Lcom/capcom/zombiecafeandroid/offline/Tier;
.super Ljava/lang/Enum;
.source "Tier.java"


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum",
        "<",
        "Lcom/capcom/zombiecafeandroid/offline/Tier;",
        ">;"
    }
.end annotation


# static fields
.field private static final synthetic $VALUES:[Lcom/capcom/zombiecafeandroid/offline/Tier;

.field public static final enum EASY:Lcom/capcom/zombiecafeandroid/offline/Tier;

.field public static final enum EVEN:Lcom/capcom/zombiecafeandroid/offline/Tier;

.field public static final enum HARD:Lcom/capcom/zombiecafeandroid/offline/Tier;


# instance fields
.field final maxLevelOffset:I

.field final maxRatio:D

.field final minLevelOffset:I

.field final minRatio:D


# direct methods
.method private static synthetic $values()[Lcom/capcom/zombiecafeandroid/offline/Tier;
    .locals 3

    .prologue
    .line 9
    const/4 v0, 0x3

    new-array v0, v0, [Lcom/capcom/zombiecafeandroid/offline/Tier;

    const/4 v1, 0x0

    sget-object v2, Lcom/capcom/zombiecafeandroid/offline/Tier;->EASY:Lcom/capcom/zombiecafeandroid/offline/Tier;

    aput-object v2, v0, v1

    const/4 v1, 0x1

    sget-object v2, Lcom/capcom/zombiecafeandroid/offline/Tier;->EVEN:Lcom/capcom/zombiecafeandroid/offline/Tier;

    aput-object v2, v0, v1

    const/4 v1, 0x2

    sget-object v2, Lcom/capcom/zombiecafeandroid/offline/Tier;->HARD:Lcom/capcom/zombiecafeandroid/offline/Tier;

    aput-object v2, v0, v1

    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 10

    .prologue
    .line 10
    new-instance v1, Lcom/capcom/zombiecafeandroid/offline/Tier;

    const-string v2, "EASY"

    const/4 v3, 0x0

    const-wide v4, 0x3fe3333333333333L    # 0.6

    const-wide v6, 0x3feb333333333333L    # 0.85

    const/4 v8, -0x3

    const/4 v9, -0x1

    invoke-direct/range {v1 .. v9}, Lcom/capcom/zombiecafeandroid/offline/Tier;-><init>(Ljava/lang/String;IDDII)V

    sput-object v1, Lcom/capcom/zombiecafeandroid/offline/Tier;->EASY:Lcom/capcom/zombiecafeandroid/offline/Tier;

    .line 11
    new-instance v1, Lcom/capcom/zombiecafeandroid/offline/Tier;

    const-string v2, "EVEN"

    const/4 v3, 0x1

    const-wide v4, 0x3feccccccccccccdL    # 0.9

    const-wide v6, 0x3ff199999999999aL    # 1.1

    const/4 v8, -0x1

    const/4 v9, 0x0

    invoke-direct/range {v1 .. v9}, Lcom/capcom/zombiecafeandroid/offline/Tier;-><init>(Ljava/lang/String;IDDII)V

    sput-object v1, Lcom/capcom/zombiecafeandroid/offline/Tier;->EVEN:Lcom/capcom/zombiecafeandroid/offline/Tier;

    .line 12
    new-instance v1, Lcom/capcom/zombiecafeandroid/offline/Tier;

    const-string v2, "HARD"

    const/4 v3, 0x2

    const-wide v4, 0x3ff2666666666666L    # 1.15

    const-wide v6, 0x3ff6666666666666L    # 1.4

    const/4 v8, 0x0

    const/4 v9, 0x0

    invoke-direct/range {v1 .. v9}, Lcom/capcom/zombiecafeandroid/offline/Tier;-><init>(Ljava/lang/String;IDDII)V

    sput-object v1, Lcom/capcom/zombiecafeandroid/offline/Tier;->HARD:Lcom/capcom/zombiecafeandroid/offline/Tier;

    .line 9
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/Tier;->$values()[Lcom/capcom/zombiecafeandroid/offline/Tier;

    move-result-object v0

    sput-object v0, Lcom/capcom/zombiecafeandroid/offline/Tier;->$VALUES:[Lcom/capcom/zombiecafeandroid/offline/Tier;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;IDDII)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(DDII)V"
        }
    .end annotation

    .prologue
    .line 19
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    .line 20
    iput-wide p3, p0, Lcom/capcom/zombiecafeandroid/offline/Tier;->minRatio:D

    .line 21
    iput-wide p5, p0, Lcom/capcom/zombiecafeandroid/offline/Tier;->maxRatio:D

    .line 22
    iput p7, p0, Lcom/capcom/zombiecafeandroid/offline/Tier;->minLevelOffset:I

    .line 23
    iput p8, p0, Lcom/capcom/zombiecafeandroid/offline/Tier;->maxLevelOffset:I

    .line 24
    return-void
.end method

.method static roll(Ljava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/Tier;
    .locals 2

    .prologue
    .line 28
    const/16 v0, 0x64

    invoke-virtual {p0, v0}, Ljava/util/Random;->nextInt(I)I

    move-result v0

    .line 29
    const/16 v1, 0x23

    if-ge v0, v1, :cond_0

    .line 30
    sget-object v0, Lcom/capcom/zombiecafeandroid/offline/Tier;->EASY:Lcom/capcom/zombiecafeandroid/offline/Tier;

    .line 35
    :goto_0
    return-object v0

    .line 32
    :cond_0
    const/16 v1, 0x50

    if-ge v0, v1, :cond_1

    .line 33
    sget-object v0, Lcom/capcom/zombiecafeandroid/offline/Tier;->EVEN:Lcom/capcom/zombiecafeandroid/offline/Tier;

    goto :goto_0

    .line 35
    :cond_1
    sget-object v0, Lcom/capcom/zombiecafeandroid/offline/Tier;->HARD:Lcom/capcom/zombiecafeandroid/offline/Tier;

    goto :goto_0
.end method

.method public static valueOf(Ljava/lang/String;)Lcom/capcom/zombiecafeandroid/offline/Tier;
    .locals 1

    .prologue
    .line 9
    const-class v0, Lcom/capcom/zombiecafeandroid/offline/Tier;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object v0

    check-cast v0, Lcom/capcom/zombiecafeandroid/offline/Tier;

    return-object v0
.end method

.method public static values()[Lcom/capcom/zombiecafeandroid/offline/Tier;
    .locals 1

    .prologue
    .line 9
    sget-object v0, Lcom/capcom/zombiecafeandroid/offline/Tier;->$VALUES:[Lcom/capcom/zombiecafeandroid/offline/Tier;

    invoke-virtual {v0}, [Lcom/capcom/zombiecafeandroid/offline/Tier;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lcom/capcom/zombiecafeandroid/offline/Tier;

    return-object v0
.end method
