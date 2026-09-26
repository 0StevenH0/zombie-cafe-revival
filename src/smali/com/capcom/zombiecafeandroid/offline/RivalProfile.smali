.class final Lcom/capcom/zombiecafeandroid/offline/RivalProfile;
.super Ljava/lang/Object;
.source "RivalProfile.java"


# static fields
.field private static final FIRST_NAMES:[Ljava/lang/String;

.field private static final LAST_NAMES:[Ljava/lang/String;

.field static final NEIGHBORS:[Lcom/capcom/zombiecafeandroid/offline/RivalProfile;


# instance fields
.field final firstName:Ljava/lang/String;

.field final lastName:Ljava/lang/String;

.field final levelOffset:I

.field final tier:Lcom/capcom/zombiecafeandroid/offline/Tier;

.field final uid:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 12

    .prologue
    const/4 v11, 0x4

    const/4 v10, 0x3

    const/4 v9, 0x2

    const/4 v7, 0x1

    const/4 v8, 0x0

    .line 10
    const/16 v0, 0x18

    new-array v0, v0, [Ljava/lang/String;

    const-string v1, "Brains"

    aput-object v1, v0, v8

    const-string v1, "Mildred"

    aput-object v1, v0, v7

    const-string v1, "Gutsy"

    aput-object v1, v0, v9

    const-string v1, "Boris"

    aput-object v1, v0, v10

    const-string v1, "Ghoulia"

    aput-object v1, v0, v11

    const/4 v1, 0x5

    const-string v2, "Rigor"

    aput-object v2, v0, v1

    const/4 v1, 0x6

    const-string v2, "Bertha"

    aput-object v2, v0, v1

    const/4 v1, 0x7

    const-string v2, "Sloppy"

    aput-object v2, v0, v1

    const/16 v1, 0x8

    const-string v2, "Mortimer"

    aput-object v2, v0, v1

    const/16 v1, 0x9

    const-string v2, "Grub"

    aput-object v2, v0, v1

    const/16 v1, 0xa

    const-string v2, "Stitch"

    aput-object v2, v0, v1

    const/16 v1, 0xb

    const-string v2, "Munch"

    aput-object v2, v0, v1

    const/16 v1, 0xc

    const-string v2, "Gristle"

    aput-object v2, v0, v1

    const/16 v1, 0xd

    const-string v2, "Vera"

    aput-object v2, v0, v1

    const/16 v1, 0xe

    const-string v2, "Clyde"

    aput-object v2, v0, v1

    const/16 v1, 0xf

    const-string v2, "Pickles"

    aput-object v2, v0, v1

    const/16 v1, 0x10

    const-string v2, "Lurch"

    aput-object v2, v0, v1

    const/16 v1, 0x11

    const-string v2, "Moldy"

    aput-object v2, v0, v1

    const/16 v1, 0x12

    const-string v2, "Crumpet"

    aput-object v2, v0, v1

    const/16 v1, 0x13

    const-string v2, "Igor"

    aput-object v2, v0, v1

    const/16 v1, 0x14

    const-string v2, "Agatha"

    aput-object v2, v0, v1

    const/16 v1, 0x15

    const-string v2, "Rotten"

    aput-object v2, v0, v1

    const/16 v1, 0x16

    const-string v2, "Mabel"

    aput-object v2, v0, v1

    const/16 v1, 0x17

    const-string v2, "Otis"

    aput-object v2, v0, v1

    sput-object v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->FIRST_NAMES:[Ljava/lang/String;

    .line 15
    const/16 v0, 0x14

    new-array v0, v0, [Ljava/lang/String;

    const-string v1, "McGee"

    aput-object v1, v0, v8

    const-string v1, "Marrow"

    aput-object v1, v0, v7

    const-string v1, "Gnawson"

    aput-object v1, v0, v9

    const-string v1, "Rotwell"

    aput-object v1, v0, v10

    const-string v1, "Graves"

    aput-object v1, v0, v11

    const/4 v1, 0x5

    const-string v2, "Mortis"

    aput-object v2, v0, v1

    const/4 v1, 0x6

    const-string v2, "Bunsworth"

    aput-object v2, v0, v1

    const/4 v1, 0x7

    const-string v2, "Gravy"

    aput-object v2, v0, v1

    const/16 v1, 0x8

    const-string v2, "Stew"

    aput-object v2, v0, v1

    const/16 v1, 0x9

    const-string v2, "Fleshman"

    aput-object v2, v0, v1

    const/16 v1, 0xa

    const-string v2, "Crumb"

    aput-object v2, v0, v1

    const/16 v1, 0xb

    const-string v2, "Spleen"

    aput-object v2, v0, v1

    const/16 v1, 0xc

    const-string v2, "Tibbs"

    aput-object v2, v0, v1

    const/16 v1, 0xd

    const-string v2, "Kettle"

    aput-object v2, v0, v1

    const/16 v1, 0xe

    const-string v2, "Sausage"

    aput-object v2, v0, v1

    const/16 v1, 0xf

    const-string v2, "Noodle"

    aput-object v2, v0, v1

    const/16 v1, 0x10

    const-string v2, "Gizzard"

    aput-object v2, v0, v1

    const/16 v1, 0x11

    const-string v2, "Brisket"

    aput-object v2, v0, v1

    const/16 v1, 0x12

    const-string v2, "Moss"

    aput-object v2, v0, v1

    const/16 v1, 0x13

    const-string v2, "Hollow"

    aput-object v2, v0, v1

    sput-object v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->LAST_NAMES:[Ljava/lang/String;

    .line 22
    const/16 v0, 0x8

    new-array v6, v0, [Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    const-string v1, "900000001"

    const-string v2, "Brains"

    const-string v3, "McGee"

    sget-object v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->EASY:Lcom/capcom/zombiecafeandroid/offline/Tier;

    const/4 v5, -0x2

    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;I)V

    aput-object v0, v6, v8

    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    const-string v1, "900000002"

    const-string v2, "Mildred"

    const-string v3, "Marrow"

    sget-object v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->EASY:Lcom/capcom/zombiecafeandroid/offline/Tier;

    const/4 v5, -0x1

    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;I)V

    aput-object v0, v6, v7

    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    const-string v1, "900000003"

    const-string v2, "Sloppy"

    const-string v3, "Gravy"

    sget-object v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->EASY:Lcom/capcom/zombiecafeandroid/offline/Tier;

    const/4 v5, -0x3

    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;I)V

    aput-object v0, v6, v9

    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    const-string v1, "900000004"

    const-string v2, "Gutsy"

    const-string v3, "Gnawson"

    sget-object v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->EVEN:Lcom/capcom/zombiecafeandroid/offline/Tier;

    const/4 v5, -0x1

    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;I)V

    aput-object v0, v6, v10

    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    const-string v1, "900000005"

    const-string v2, "Boris"

    const-string v3, "Rotwell"

    sget-object v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->EVEN:Lcom/capcom/zombiecafeandroid/offline/Tier;

    move v5, v8

    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;I)V

    aput-object v0, v6, v11

    const/4 v7, 0x5

    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    const-string v1, "900000006"

    const-string v2, "Ghoulia"

    const-string v3, "Graves"

    sget-object v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->EVEN:Lcom/capcom/zombiecafeandroid/offline/Tier;

    move v5, v8

    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;I)V

    aput-object v0, v6, v7

    const/4 v7, 0x6

    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    const-string v1, "900000007"

    const-string v2, "Rigor"

    const-string v3, "Mortis"

    sget-object v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->HARD:Lcom/capcom/zombiecafeandroid/offline/Tier;

    move v5, v8

    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;I)V

    aput-object v0, v6, v7

    const/4 v7, 0x7

    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    const-string v1, "900000008"

    const-string v2, "Bertha"

    const-string v3, "Bunsworth"

    sget-object v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->HARD:Lcom/capcom/zombiecafeandroid/offline/Tier;

    move v5, v8

    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;I)V

    aput-object v0, v6, v7

    sput-object v6, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->NEIGHBORS:[Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    return-void
.end method

.method constructor <init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;I)V
    .locals 0

    .prologue
    .line 40
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 41
    iput-object p1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->uid:Ljava/lang/String;

    .line 42
    iput-object p2, p0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->firstName:Ljava/lang/String;

    .line 43
    iput-object p3, p0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->lastName:Ljava/lang/String;

    .line 44
    iput-object p4, p0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->tier:Lcom/capcom/zombiecafeandroid/offline/Tier;

    .line 45
    iput p5, p0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->levelOffset:I

    .line 46
    return-void
.end method

.method static forUid(Ljava/lang/String;)Lcom/capcom/zombiecafeandroid/offline/RivalProfile;
    .locals 5

    .prologue
    .line 59
    if-nez p0, :cond_0

    const-string p0, ""

    .line 60
    :cond_0
    sget-object v2, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->NEIGHBORS:[Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    array-length v3, v2

    const/4 v0, 0x0

    move v1, v0

    :goto_0
    if-ge v1, v3, :cond_2

    aget-object v0, v2, v1

    .line 61
    iget-object v4, v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->uid:Ljava/lang/String;

    invoke-virtual {v4, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_1

    .line 66
    :goto_1
    return-object v0

    .line 60
    :cond_1
    add-int/lit8 v0, v1, 0x1

    move v1, v0

    goto :goto_0

    .line 65
    :cond_2
    new-instance v0, Ljava/util/Random;

    invoke-static {p0}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->stableHash(Ljava/lang/String;)J

    move-result-wide v2

    invoke-direct {v0, v2, v3}, Ljava/util/Random;-><init>(J)V

    .line 66
    invoke-static {p0, v0}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->random(Ljava/lang/String;Ljava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    move-result-object v0

    goto :goto_1
.end method

.method static random(Ljava/lang/String;Ljava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/RivalProfile;
    .locals 6

    .prologue
    .line 71
    invoke-static {p1}, Lcom/capcom/zombiecafeandroid/offline/Tier;->roll(Ljava/util/Random;)Lcom/capcom/zombiecafeandroid/offline/Tier;

    move-result-object v4

    .line 72
    iget v0, v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->maxLevelOffset:I

    iget v1, v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->minLevelOffset:I

    sub-int/2addr v0, v1

    add-int/lit8 v0, v0, 0x1

    .line 73
    iget v1, v4, Lcom/capcom/zombiecafeandroid/offline/Tier;->minLevelOffset:I

    invoke-virtual {p1, v0}, Ljava/util/Random;->nextInt(I)I

    move-result v0

    add-int v5, v1, v0

    .line 74
    new-instance v0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    sget-object v1, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->FIRST_NAMES:[Ljava/lang/String;

    sget-object v2, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->FIRST_NAMES:[Ljava/lang/String;

    array-length v2, v2

    .line 75
    invoke-virtual {p1, v2}, Ljava/util/Random;->nextInt(I)I

    move-result v2

    aget-object v2, v1, v2

    sget-object v1, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->LAST_NAMES:[Ljava/lang/String;

    sget-object v3, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->LAST_NAMES:[Ljava/lang/String;

    array-length v3, v3

    .line 76
    invoke-virtual {p1, v3}, Ljava/util/Random;->nextInt(I)I

    move-result v3

    aget-object v3, v1, v3

    move-object v1, p0

    invoke-direct/range {v0 .. v5}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/capcom/zombiecafeandroid/offline/Tier;I)V

    .line 74
    return-object v0
.end method

.method static stableHash(Ljava/lang/String;)J
    .locals 6

    .prologue
    .line 82
    const-wide v2, 0x3ffffffffffe5L

    .line 83
    const/4 v0, 0x0

    :goto_0
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v1

    if-ge v0, v1, :cond_0

    .line 84
    const-wide/16 v4, 0x1f

    mul-long/2addr v2, v4

    invoke-virtual {p0, v0}, Ljava/lang/String;->charAt(I)C

    move-result v1

    int-to-long v4, v1

    add-long/2addr v2, v4

    .line 83
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 86
    :cond_0
    return-wide v2
.end method


# virtual methods
.method fullName()Ljava/lang/String;
    .locals 2

    .prologue
    .line 49
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->firstName:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->lastName:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method rivalLevel(I)I
    .locals 3

    .prologue
    const/4 v2, 0x1

    .line 53
    invoke-static {v2, p1}, Ljava/lang/Math;->max(II)I

    move-result v0

    .line 54
    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->levelOffset:I

    add-int/2addr v1, v0

    invoke-static {v0, v1}, Ljava/lang/Math;->min(II)I

    move-result v0

    invoke-static {v2, v0}, Ljava/lang/Math;->max(II)I

    move-result v0

    return v0
.end method
