.class final Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;
.super Ljava/lang/Object;
.source "CharacterCatalog.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "Info"
.end annotation


# instance fields
.field final attack:I

.field final energy:I

.field final levelRequired:I

.field final name:Ljava/lang/String;

.field final speed:I

.field final type:I

.field final u14:I

.field final u20:I

.field final u21:I

.field final u4:I


# direct methods
.method constructor <init>(ILjava/lang/String;IIIIIIII)V
    .locals 0

    .prologue
    .line 27
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 28
    iput p1, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->type:I

    .line 29
    iput-object p2, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->name:Ljava/lang/String;

    .line 30
    iput p3, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->levelRequired:I

    .line 31
    iput p4, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->energy:I

    .line 32
    iput p5, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->speed:I

    .line 33
    iput p6, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->attack:I

    .line 34
    iput p7, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->u4:I

    .line 35
    iput p8, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->u14:I

    .line 36
    iput p9, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->u20:I

    .line 37
    iput p10, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->u21:I

    .line 38
    return-void
.end method


# virtual methods
.method combatFactor()I
    .locals 2

    .prologue
    .line 55
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->speed:I

    iget v1, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->attack:I

    add-int/2addr v0, v1

    return v0
.end method

.method isBaseRoster()Z
    .locals 1

    .prologue
    .line 47
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->u20:I

    if-nez v0, :cond_0

    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->u21:I

    if-nez v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method isInfectable()Z
    .locals 2

    .prologue
    const/16 v1, 0xff

    .line 42
    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->u4:I

    if-ne v0, v1, :cond_0

    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->u14:I

    if-nez v0, :cond_0

    iget v0, p0, Lcom/capcom/zombiecafeandroid/offline/CharacterCatalog$Info;->levelRequired:I

    if-eq v0, v1, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method
