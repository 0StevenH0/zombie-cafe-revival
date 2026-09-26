.class Lcom/capcom/zombiecafeandroid/URLManager;
.super Ljava/lang/Object;


# instance fields
.field private a:Landroid/content/Context;


# direct methods
.method constructor <init>(Landroid/content/Context;)V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/capcom/zombiecafeandroid/URLManager;->a:Landroid/content/Context;

    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/URLManager;->a:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;

    move-result-object v0

    invoke-virtual {v0}, Ljava/io/File;->toString()Ljava/lang/String;

    invoke-static {p1}, Lcom/capcom/zombiecafeandroid/URLManager;->a(Landroid/content/Context;)Z

    return-void
.end method

.method public static native LoadedBannerTextureCallback([BI)V
.end method

.method public static native NewRequestCallback([BI)V
.end method

.method public static native NewRequestServerCallback(Z[BII)V
.end method

.method public static a()V
    .locals 6

    const/16 v2, 0x4e20

    new-instance v0, Lorg/apache/http/params/BasicHttpParams;

    invoke-direct {v0}, Lorg/apache/http/params/BasicHttpParams;-><init>()V

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lorg/apache/http/params/HttpConnectionParams;->setStaleCheckingEnabled(Lorg/apache/http/params/HttpParams;Z)V

    invoke-static {v0, v2}, Lorg/apache/http/params/HttpConnectionParams;->setConnectionTimeout(Lorg/apache/http/params/HttpParams;I)V

    invoke-static {v0, v2}, Lorg/apache/http/params/HttpConnectionParams;->setSoTimeout(Lorg/apache/http/params/HttpParams;I)V

    const/16 v1, 0x2000

    invoke-static {v0, v1}, Lorg/apache/http/params/HttpConnectionParams;->setSocketBufferSize(Lorg/apache/http/params/HttpParams;I)V

    sget-object v1, Lorg/apache/http/HttpVersion;->HTTP_1_1:Lorg/apache/http/HttpVersion;

    invoke-static {v0, v1}, Lorg/apache/http/params/HttpProtocolParams;->setVersion(Lorg/apache/http/params/HttpParams;Lorg/apache/http/ProtocolVersion;)V

    const-string v1, "ISO-8859-1"

    invoke-static {v0, v1}, Lorg/apache/http/params/HttpProtocolParams;->setContentCharset(Lorg/apache/http/params/HttpParams;Ljava/lang/String;)V

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lorg/apache/http/params/HttpProtocolParams;->setUseExpectContinue(Lorg/apache/http/params/HttpParams;Z)V

    sget-boolean v1, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->amazonKindle:Z

    if-eqz v1, :cond_0

    const-string v1, "ZombieCafe/1.0.1.0a Amazon"

    invoke-static {v0, v1}, Lorg/apache/http/params/HttpProtocolParams;->setUserAgent(Lorg/apache/http/params/HttpParams;Ljava/lang/String;)V

    :goto_0
    new-instance v1, Lorg/apache/http/conn/scheme/SchemeRegistry;

    invoke-direct {v1}, Lorg/apache/http/conn/scheme/SchemeRegistry;-><init>()V

    new-instance v2, Lorg/apache/http/conn/scheme/Scheme;

    const-string v3, "http"

    invoke-static {}, Lorg/apache/http/conn/scheme/PlainSocketFactory;->getSocketFactory()Lorg/apache/http/conn/scheme/PlainSocketFactory;

    move-result-object v4

    const/16 v5, 0x50

    invoke-direct {v2, v3, v4, v5}, Lorg/apache/http/conn/scheme/Scheme;-><init>(Ljava/lang/String;Lorg/apache/http/conn/scheme/SocketFactory;I)V

    invoke-virtual {v1, v2}, Lorg/apache/http/conn/scheme/SchemeRegistry;->register(Lorg/apache/http/conn/scheme/Scheme;)Lorg/apache/http/conn/scheme/Scheme;

    new-instance v2, Lorg/apache/http/conn/scheme/Scheme;

    const-string v3, "https"

    invoke-static {}, Lorg/apache/http/conn/ssl/SSLSocketFactory;->getSocketFactory()Lorg/apache/http/conn/ssl/SSLSocketFactory;

    move-result-object v4

    const/16 v5, 0x1bb

    invoke-direct {v2, v3, v4, v5}, Lorg/apache/http/conn/scheme/Scheme;-><init>(Ljava/lang/String;Lorg/apache/http/conn/scheme/SocketFactory;I)V

    invoke-virtual {v1, v2}, Lorg/apache/http/conn/scheme/SchemeRegistry;->register(Lorg/apache/http/conn/scheme/Scheme;)Lorg/apache/http/conn/scheme/Scheme;

    new-instance v2, Lorg/apache/http/impl/conn/tsccm/ThreadSafeClientConnManager;

    invoke-direct {v2, v0, v1}, Lorg/apache/http/impl/conn/tsccm/ThreadSafeClientConnManager;-><init>(Lorg/apache/http/params/HttpParams;Lorg/apache/http/conn/scheme/SchemeRegistry;)V

    new-instance v1, Lorg/apache/http/impl/client/DefaultHttpClient;

    invoke-direct {v1, v2, v0}, Lorg/apache/http/impl/client/DefaultHttpClient;-><init>(Lorg/apache/http/conn/ClientConnectionManager;Lorg/apache/http/params/HttpParams;)V

    sput-object v1, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->mHttpClient2:Lorg/apache/http/impl/client/DefaultHttpClient;

    return-void

    :cond_0
    const-string v1, "ZombieCafe/1.0.1.0a"

    invoke-static {v0, v1}, Lorg/apache/http/params/HttpProtocolParams;->setUserAgent(Lorg/apache/http/params/HttpParams;Ljava/lang/String;)V

    goto :goto_0
.end method

.method public static a(Landroid/content/Context;)Z
    .locals 1

    # Offline mode: the "server" is in-process (offline/OfflineServer), so it is
    # always reachable no matter what the device's network is doing.
    const/4 v0, 0x1

    sput-boolean v0, Lcom/capcom/zombiecafeandroid/ZombieCafeAndroid;->CONNECTED:Z

    return v0
.end method


# virtual methods
.method public final a(Ljava/lang/String;I)V
    .locals 1

    # Offline mode: every CCUrlConnection::NewRequest lands here. Instead of
    # HTTP, OfflineBridge answers it in-process and hands the reply to the
    # native callback exactly as the old HTTP path did.
    iget-object v0, p0, Lcom/capcom/zombiecafeandroid/URLManager;->a:Landroid/content/Context;

    invoke-static {v0, p1, p2}, Lcom/capcom/zombiecafeandroid/OfflineBridge;->handleRequest(Landroid/content/Context;Ljava/lang/String;I)V

    return-void
.end method

.method public final b(Ljava/lang/String;I)V
    .locals 2

    # Offline mode: plain URL fetches (mURLRequest) never leave the device.
    # Unreachable anyway - the native library has no caller for it - and a
    # failed fetch never called back, so doing nothing matches the old
    # behaviour without a server.
    const-string v0, "ZCOffline"

    const-string v1, "URLManager.b: dropped offline"

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method
