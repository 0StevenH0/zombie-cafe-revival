.class public final Lcom/capcom/zombiecafeandroid/offline/Immersive;
.super Ljava/lang/Object;
.source "Immersive.java"


# static fields
.field private static final CUTOUT_ALWAYS:I = 0x3

.field private static final CUTOUT_SHORT_EDGES:I = 0x1

.field private static final FLAGS:I = 0x1706

.field private static volatile surfaceSize:J


# direct methods
.method private constructor <init>()V
    .locals 0

    .prologue
    .line 47
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static apply(Landroid/app/Activity;)V
    .locals 3

    .prologue
    .line 59
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->supported()Z

    move-result v0

    if-nez v0, :cond_0

    .line 67
    :goto_0
    return-void

    .line 62
    :cond_0
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v0

    .line 63
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x1c

    if-lt v1, v2, :cond_1

    .line 64
    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->drawUnderCutout(Landroid/view/Window;)V

    .line 66
    :cond_1
    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    const/16 v1, 0x1706

    invoke-virtual {v0, v1}, Landroid/view/View;->setSystemUiVisibility(I)V

    goto :goto_0
.end method

.method private static drawUnderCutout(Landroid/view/Window;)V
    .locals 4

    .prologue
    .line 70
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-lt v0, v1, :cond_1

    const/4 v0, 0x3

    .line 71
    :goto_0
    invoke-virtual {p0}, Landroid/view/Window;->getAttributes()Landroid/view/WindowManager$LayoutParams;

    move-result-object v1

    .line 73
    :try_start_0
    const-class v2, Landroid/view/WindowManager$LayoutParams;

    const-string v3, "layoutInDisplayCutoutMode"

    invoke-virtual {v2, v3}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    .line 74
    invoke-virtual {v2, v1}, Ljava/lang/reflect/Field;->getInt(Ljava/lang/Object;)I

    move-result v3

    if-eq v3, v0, :cond_0

    .line 75
    invoke-virtual {v2, v1, v0}, Ljava/lang/reflect/Field;->setInt(Ljava/lang/Object;I)V

    .line 76
    invoke-virtual {p0, v1}, Landroid/view/Window;->setAttributes(Landroid/view/WindowManager$LayoutParams;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 81
    :cond_0
    :goto_1
    return-void

    .line 70
    :cond_1
    const/4 v0, 0x1

    goto :goto_0

    .line 78
    :catch_0
    move-exception v0

    .line 79
    const-string v1, "display cutout mode unavailable"

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    goto :goto_1
.end method

.method public static height(Landroid/app/Activity;)I
    .locals 4

    .prologue
    .line 120
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->supported()Z

    move-result v0

    if-nez v0, :cond_0

    .line 121
    invoke-virtual {p0}, Landroid/app/Activity;->getWindowManager()Landroid/view/WindowManager;

    move-result-object v0

    invoke-interface {v0}, Landroid/view/WindowManager;->getDefaultDisplay()Landroid/view/Display;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Display;->getHeight()I

    move-result v0

    .line 124
    :goto_0
    return v0

    .line 123
    :cond_0
    sget-wide v0, Lcom/capcom/zombiecafeandroid/offline/Immersive;->surfaceSize:J

    .line 124
    const-wide/16 v2, 0x0

    cmp-long v2, v0, v2

    if-eqz v2, :cond_1

    long-to-int v0, v0

    goto :goto_0

    :cond_1
    invoke-static {p0}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->windowSize(Landroid/app/Activity;)Landroid/graphics/Point;

    move-result-object v0

    iget v0, v0, Landroid/graphics/Point;->y:I

    goto :goto_0
.end method

.method public static readSurfaceSize()Z
    .locals 8

    .prologue
    const/4 v0, 0x0

    .line 154
    sget-object v1, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mGLView:Landroid/opengl/GLSurfaceView;

    .line 155
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->supported()Z

    move-result v2

    if-eqz v2, :cond_0

    if-nez v1, :cond_1

    .line 170
    :cond_0
    :goto_0
    return v0

    .line 158
    :cond_1
    invoke-virtual {v1}, Landroid/view/View;->getWidth()I

    move-result v2

    .line 159
    invoke-virtual {v1}, Landroid/view/View;->getHeight()I

    move-result v1

    .line 160
    if-lez v2, :cond_0

    if-lez v1, :cond_0

    .line 163
    int-to-long v4, v2

    const/16 v0, 0x20

    shl-long/2addr v4, v0

    int-to-long v6, v1

    or-long/2addr v4, v6

    .line 164
    sget-wide v6, Lcom/capcom/zombiecafeandroid/offline/Immersive;->surfaceSize:J

    cmp-long v0, v4, v6

    if-eqz v0, :cond_2

    .line 165
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "full screen game size "

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, "x"

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->d(Ljava/lang/String;)V

    .line 167
    :cond_2
    sput-wide v4, Lcom/capcom/zombiecafeandroid/offline/Immersive;->surfaceSize:J

    .line 168
    sput v2, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mScreenWidth:I

    .line 169
    sput v1, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mScreenHeight:I

    .line 170
    const/4 v0, 0x1

    goto :goto_0
.end method

.method public static show(Landroid/app/Dialog;)V
    .locals 4

    .prologue
    const/16 v3, 0x8

    .line 88
    invoke-virtual {p0}, Landroid/app/Dialog;->getWindow()Landroid/view/Window;

    move-result-object v1

    .line 89
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->supported()Z

    move-result v0

    if-eqz v0, :cond_0

    if-nez v1, :cond_1

    .line 90
    :cond_0
    invoke-virtual {p0}, Landroid/app/Dialog;->show()V

    .line 100
    :goto_0
    return-void

    .line 93
    :cond_1
    invoke-virtual {v1, v3}, Landroid/view/Window;->addFlags(I)V

    .line 95
    :try_start_0
    invoke-virtual {p0}, Landroid/app/Dialog;->show()V

    .line 96
    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    const/16 v2, 0x1706

    invoke-virtual {v0, v2}, Landroid/view/View;->setSystemUiVisibility(I)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 98
    invoke-virtual {v1, v3}, Landroid/view/Window;->clearFlags(I)V

    goto :goto_0

    :catchall_0
    move-exception v0

    invoke-virtual {v1, v3}, Landroid/view/Window;->clearFlags(I)V

    .line 99
    throw v0
.end method

.method private static supported()Z
    .locals 2

    .prologue
    .line 50
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x13

    if-lt v0, v1, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public static surfaceHeight()I
    .locals 2

    .prologue
    .line 178
    sget-wide v0, Lcom/capcom/zombiecafeandroid/offline/Immersive;->surfaceSize:J

    long-to-int v0, v0

    return v0
.end method

.method public static surfaceScale()F
    .locals 2

    .prologue
    .line 183
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->surfaceWidth()I

    move-result v0

    const/16 v1, 0x500

    if-gt v0, v1, :cond_0

    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->surfaceHeight()I

    move-result v0

    const/16 v1, 0x3e8

    if-le v0, v1, :cond_1

    :cond_0
    const/high16 v0, 0x40000000    # 2.0f

    :goto_0
    return v0

    :cond_1
    const/high16 v0, 0x3f800000    # 1.0f

    goto :goto_0
.end method

.method public static surfaceWidth()I
    .locals 3

    .prologue
    .line 174
    sget-wide v0, Lcom/capcom/zombiecafeandroid/offline/Immersive;->surfaceSize:J

    const/16 v2, 0x20

    ushr-long/2addr v0, v2

    long-to-int v0, v0

    return v0
.end method

.method public static viewSize(I)I
    .locals 1

    .prologue
    .line 104
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->supported()Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 p0, -0x1

    :cond_0
    return p0
.end method

.method public static width(Landroid/app/Activity;)I
    .locals 4

    .prologue
    .line 110
    invoke-static {}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->supported()Z

    move-result v0

    if-nez v0, :cond_0

    .line 111
    invoke-virtual {p0}, Landroid/app/Activity;->getWindowManager()Landroid/view/WindowManager;

    move-result-object v0

    invoke-interface {v0}, Landroid/view/WindowManager;->getDefaultDisplay()Landroid/view/Display;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Display;->getWidth()I

    move-result v0

    .line 114
    :goto_0
    return v0

    .line 113
    :cond_0
    sget-wide v0, Lcom/capcom/zombiecafeandroid/offline/Immersive;->surfaceSize:J

    .line 114
    const-wide/16 v2, 0x0

    cmp-long v2, v0, v2

    if-eqz v2, :cond_1

    const/16 v2, 0x20

    ushr-long/2addr v0, v2

    long-to-int v0, v0

    goto :goto_0

    :cond_1
    invoke-static {p0}, Lcom/capcom/zombiecafeandroid/offline/Immersive;->windowSize(Landroid/app/Activity;)Landroid/graphics/Point;

    move-result-object v0

    iget v0, v0, Landroid/graphics/Point;->x:I

    goto :goto_0
.end method

.method private static windowSize(Landroid/app/Activity;)Landroid/graphics/Point;
    .locals 7

    .prologue
    .line 130
    invoke-virtual {p0}, Landroid/app/Activity;->getWindowManager()Landroid/view/WindowManager;

    move-result-object v0

    .line 131
    invoke-interface {v0}, Landroid/view/WindowManager;->getDefaultDisplay()Landroid/view/Display;

    move-result-object v1

    .line 132
    new-instance v2, Landroid/graphics/Point;

    invoke-virtual {v1}, Landroid/view/Display;->getWidth()I

    move-result v3

    invoke-virtual {v1}, Landroid/view/Display;->getHeight()I

    move-result v4

    invoke-direct {v2, v3, v4}, Landroid/graphics/Point;-><init>(II)V

    .line 134
    :try_start_0
    sget v3, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v4, 0x1e

    if-lt v3, v4, :cond_0

    .line 135
    const-class v1, Landroid/view/WindowManager;

    const-string v3, "getCurrentWindowMetrics"

    const/4 v4, 0x0

    new-array v4, v4, [Ljava/lang/Class;

    invoke-virtual {v1, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    const/4 v3, 0x0

    new-array v3, v3, [Ljava/lang/Object;

    invoke-virtual {v1, v0, v3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    .line 136
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    const-string v3, "getBounds"

    const/4 v4, 0x0

    new-array v4, v4, [Ljava/lang/Class;

    invoke-virtual {v1, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    const/4 v3, 0x0

    new-array v3, v3, [Ljava/lang/Object;

    invoke-virtual {v1, v0, v3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/graphics/Rect;

    .line 137
    invoke-virtual {v0}, Landroid/graphics/Rect;->width()I

    move-result v1

    invoke-virtual {v0}, Landroid/graphics/Rect;->height()I

    move-result v0

    invoke-virtual {v2, v1, v0}, Landroid/graphics/Point;->set(II)V

    .line 144
    :goto_0
    return-object v2

    .line 139
    :cond_0
    const-class v0, Landroid/view/Display;

    const-string v3, "getRealSize"

    const/4 v4, 0x1

    new-array v4, v4, [Ljava/lang/Class;

    const/4 v5, 0x0

    const-class v6, Landroid/graphics/Point;

    aput-object v6, v4, v5

    invoke-virtual {v0, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    const/4 v3, 0x1

    new-array v3, v3, [Ljava/lang/Object;

    const/4 v4, 0x0

    aput-object v2, v3, v4

    invoke-virtual {v0, v1, v3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 141
    :catch_0
    move-exception v0

    .line 142
    const-string v1, "full window size unavailable"

    invoke-static {v1, v0}, Lcom/capcom/zombiecafeandroid/offline/OfflineLog;->w(Ljava/lang/String;Ljava/lang/Throwable;)V

    goto :goto_0
.end method
