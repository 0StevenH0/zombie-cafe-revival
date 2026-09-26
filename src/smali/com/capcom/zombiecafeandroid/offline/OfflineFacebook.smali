.class public final Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;
.super Ljava/lang/Object;
.source "OfflineFacebook.java"


# static fields
.field static final GET_FRIENDS:I = 0x3

.field static final GET_INFO:I = 0x5

.field static final INIT:I = 0x8

.field static final IS_LOGGED_IN:I = 0x7

.field private static final KEY_LOGGED_OUT:Ljava/lang/String; = "fb_logged_out"

.field private static final KEY_USER_ID:Ljava/lang/String; = "fb_user_id"

.field static final LOGIN:I = 0x2

.field static final LOGOUT:I = 0x6

.field static final MY_FIRST_NAME:Ljava/lang/String; = "Zombie"

.field static final MY_LAST_NAME:Ljava/lang/String; = "Chef"

.field static final POST_STORY:I = 0x4

.field static final POST_WALL:I = 0x0

.field private static final PREFS:Ljava/lang/String; = "zc_offline"

.field static final UPLOAD_PIC:I = 0x1


# direct methods
.method private constructor <init>()V
    .locals 0

    .prologue
    .line 37
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static execute(ILjava/lang/String;Ljava/lang/String;)V
    .locals 4

    .prologue
    const/4 v0, 0x1

    const/4 v1, 0x0

    .line 42
    :try_start_0
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "facebook action="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->d(Ljava/lang/String;)V

    .line 43
    packed-switch p0, :pswitch_data_0

    .line 85
    :cond_0
    :goto_0
    :pswitch_0
    return-void

    .line 45
    :pswitch_1
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->loggedOutByPlayer()Z

    move-result v0

    if-nez v0, :cond_1

    .line 46
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->logIn()V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 82
    :catch_0
    move-exception v0

    .line 83
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "facebook action "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " failed"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    goto :goto_0

    .line 48
    :cond_1
    const/4 v0, 0x0

    :try_start_1
    sput-boolean v0, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mLoggedIn:Z

    goto :goto_0

    .line 52
    :pswitch_2
    const/4 v0, 0x0

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->setLoggedOutByPlayer(Z)V

    .line 53
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->logIn()V

    goto :goto_0

    .line 56
    :pswitch_3
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->loggedOutByPlayer()Z

    move-result v2

    if-nez v2, :cond_2

    :goto_1
    sput-boolean v0, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mLoggedIn:Z

    goto :goto_0

    :cond_2
    move v0, v1

    goto :goto_1

    .line 59
    :pswitch_4
    sget-boolean v0, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mLoggedIn:Z

    if-eqz v0, :cond_0

    .line 60
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->sendMyInfo()V

    goto :goto_0

    .line 64
    :pswitch_5
    sget-boolean v0, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mLoggedIn:Z

    if-nez v0, :cond_3

    .line 65
    const/4 v0, 0x0

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->setLoggedOutByPlayer(Z)V

    .line 66
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->logIn()V

    .line 68
    :cond_3
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->sendFriends()V

    goto :goto_0

    .line 71
    :pswitch_6
    const/4 v0, 0x1

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->setLoggedOutByPlayer(Z)V

    .line 72
    const/4 v0, 0x0

    sput-boolean v0, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mLoggedIn:Z

    .line 73
    const/4 v0, 0x0

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/CapcomFacebook;->onFacebook(Z)V
    :try_end_1
    .catch Ljava/lang/Throwable; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_0

    .line 43
    :pswitch_data_0
    .packed-switch 0x2
        :pswitch_2
        :pswitch_5
        :pswitch_0
        :pswitch_4
        :pswitch_6
        :pswitch_3
        :pswitch_1
    .end packed-switch
.end method

.method private static logIn()V
    .locals 1

    .prologue
    const/4 v0, 0x1

    .line 88
    sput-boolean v0, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mLoggedIn:Z

    .line 89
    sput-boolean v0, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mAllowLogin:Z

    .line 90
    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/CapcomFacebook;->onFacebook(Z)V

    .line 91
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->sendMyInfo()V

    .line 92
    return-void
.end method

.method private static loggedOutByPlayer()Z
    .locals 3

    .prologue
    const/4 v0, 0x0

    .line 122
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->prefs()Landroid/content/SharedPreferences;

    move-result-object v1

    .line 123
    if-eqz v1, :cond_0

    const-string v2, "fb_logged_out"

    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v0, 0x1

    :cond_0
    return v0
.end method

.method static myUserId()Ljava/lang/String;
    .locals 4

    .prologue
    .line 109
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->prefs()Landroid/content/SharedPreferences;

    move-result-object v1

    .line 110
    if-nez v1, :cond_1

    .line 111
    const-string v0, "100000001"

    .line 118
    :cond_0
    :goto_0
    return-object v0

    .line 113
    :cond_1
    const-string v0, "fb_user_id"

    const/4 v2, 0x0

    invoke-interface {v1, v0, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 114
    if-nez v0, :cond_0

    .line 115
    const v0, 0x5f5e100

    new-instance v2, Ljava/util/Random;

    invoke-direct {v2}, Ljava/util/Random;-><init>()V

    const v3, 0x2faf0800

    invoke-virtual {v2, v3}, Ljava/util/Random;->nextInt(I)I

    move-result v2

    add-int/2addr v0, v2

    invoke-static {v0}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;

    move-result-object v0

    .line 116
    invoke-interface {v1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v1

    const-string v2, "fb_user_id"

    invoke-interface {v1, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v1

    invoke-interface {v1}, Landroid/content/SharedPreferences$Editor;->commit()Z

    goto :goto_0
.end method

.method private static prefs()Landroid/content/SharedPreferences;
    .locals 3

    .prologue
    .line 134
    sget-object v0, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->CONTEXT:Landroid/content/Context;

    .line 135
    if-nez v0, :cond_0

    const/4 v0, 0x0

    :goto_0
    return-object v0

    :cond_0
    const-string v1, "zc_offline"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v0

    goto :goto_0
.end method

.method private static sendFriends()V
    .locals 8

    .prologue
    .line 100
    sget-object v7, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->NEIGHBORS:[Lcom/capcom/zombiecafeandroid/offline/RivalProfile;

    .line 101
    const/4 v0, 0x0

    :goto_0
    array-length v1, v7

    if-ge v0, v1, :cond_0

    .line 102
    aget-object v5, v7, v0

    .line 103
    array-length v1, v7

    invoke-virtual {v5}, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->fullName()Ljava/lang/String;

    move-result-object v2

    iget-object v3, v5, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->uid:Ljava/lang/String;

    iget-object v4, v5, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->firstName:Ljava/lang/String;

    iget-object v5, v5, Lcom/capcom/zombiecafeandroid/offline/RivalProfile;->lastName:Ljava/lang/String;

    const-string v6, ""

    invoke-static/range {v0 .. v6}, Lcom/capcom/zombiecafeandroid/CapcomFacebook;->sendFriendInfo(IILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 101
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 105
    :cond_0
    return-void
.end method

.method private static sendMyInfo()V
    .locals 4

    .prologue
    .line 95
    const-string v0, "Zombie Chef"

    const-string v1, "Zombie"

    const-string v2, "Chef"

    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->myUserId()Ljava/lang/String;

    move-result-object v3

    invoke-static {v0, v1, v2, v3}, Lcom/capcom/zombiecafeandroid/CapcomFacebook;->setFBInfo(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 96
    return-void
.end method

.method private static setLoggedOutByPlayer(Z)V
    .locals 2

    .prologue
    .line 127
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/OfflineFacebook;->prefs()Landroid/content/SharedPreferences;

    move-result-object v0

    .line 128
    if-eqz v0, :cond_0

    .line 129
    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    const-string v1, "fb_logged_out"

    invoke-interface {v0, v1, p0}, Landroid/content/SharedPreferences$Editor;->putBoolean(Ljava/lang/String;Z)Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->commit()Z

    .line 131
    :cond_0
    return-void
.end method
