.class final Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;
.super Ljava/lang/Object;
.source "RivalGenerator.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/capcom/zombiecafeandroid/offline/RivalGenerator;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "Candidate"
.end annotation


# instance fields
.field final template:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

.field final type:I

.field final weight:D


# direct methods
.method constructor <init>(ILcom/capcom/zombiecafeandroid/offline/CharacterRecord;D)V
    .locals 1

    .prologue
    .line 78
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 79
    iput p1, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->type:I

    .line 80
    iput-object p2, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->template:Lcom/capcom/zombiecafeandroid/offline/CharacterRecord;

    .line 81
    iput-wide p3, p0, Lcom/capcom/zombiecafeandroid/offline/RivalGenerator$Candidate;->weight:D

    .line 82
    return-void
.end method
