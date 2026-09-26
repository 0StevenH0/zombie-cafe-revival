.class public final Lcom/capcom/zombiecafeandroid/offline/OfflineStore;
.super Ljava/lang/Object;
.source "OfflineStore.java"


# static fields
.field static final PRODUCTS:[Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .prologue
    .line 18
    const/4 v0, 0x5

    new-array v0, v0, [Ljava/lang/String;

    const/4 v1, 0x0

    const-string v2, "zc_50_toxin_3"

    aput-object v2, v0, v1

    const/4 v1, 0x1

    const-string v2, "zc_125_toxin_2"

    aput-object v2, v0, v1

    const/4 v1, 0x2

    const-string v2, "zc_350_toxin_2"

    aput-object v2, v0, v1

    const/4 v1, 0x3

    const-string v2, "zc_800_toxin_2"

    aput-object v2, v0, v1

    const/4 v1, 0x4

    const-string v2, "zc_2000_toxin_2"

    aput-object v2, v0, v1

    sput-object v0, Lcom/capcom/zombiecafeandroid/offline/OfflineStore;->PRODUCTS:[Ljava/lang/String;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .prologue
    .line 22
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static completePurchase(Landroid/content/Intent;)V
    .locals 3

    .prologue
    .line 26
    :try_start_0
    invoke-static {p0}, Lcom/capcom/zombiecafeandroid/offline/OfflineStore;->productFromIntent(Landroid/content/Intent;)Ljava/lang/String;

    move-result-object v0

    .line 27
    if-nez v0, :cond_0

    .line 28
    sget v1, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->purchaseSlot:I

    .line 29
    if-ltz v1, :cond_0

    sget-object v2, Lcom/capcom/zombiecafeandroid/offline/OfflineStore;->PRODUCTS:[Ljava/lang/String;

    array-length v2, v2

    if-ge v1, v2, :cond_0

    .line 30
    sget-object v0, Lcom/capcom/zombiecafeandroid/offline/OfflineStore;->PRODUCTS:[Ljava/lang/String;

    aget-object v0, v0, v1

    .line 33
    :cond_0
    if-nez v0, :cond_1

    .line 34
    const-string v0, "purchase without a product id or slot; nothing granted"

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 42
    :goto_0
    return-void

    .line 37
    :cond_1
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "granting "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->d(Ljava/lang/String;)V

    .line 38
    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->boughtToxin(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 39
    :catch_0
    move-exception v0

    .line 40
    const-string v1, "purchase failed"

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    goto :goto_0
.end method

.method private static productFromIntent(Landroid/content/Intent;)Ljava/lang/String;
    .locals 6

    .prologue
    const/4 v0, 0x0

    .line 45
    if-nez p0, :cond_1

    .line 58
    :cond_0
    :goto_0
    return-object v0

    .line 48
    :cond_1
    invoke-virtual {p0}, Landroid/content/Intent;->getExtras()Landroid/os/Bundle;

    move-result-object v1

    .line 49
    if-eqz v1, :cond_0

    .line 52
    const-string v2, "ItemName0"

    invoke-virtual {v1, v2}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 53
    sget-object v3, Lcom/capcom/zombiecafeandroid/offline/OfflineStore;->PRODUCTS:[Ljava/lang/String;

    array-length v4, v3

    const/4 v2, 0x0

    :goto_1
    if-ge v2, v4, :cond_0

    aget-object v5, v3, v2

    .line 54
    invoke-virtual {v5, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_2

    move-object v0, v1

    .line 55
    goto :goto_0

    .line 53
    :cond_2
    add-int/lit8 v2, v2, 0x1

    goto :goto_1
.end method
