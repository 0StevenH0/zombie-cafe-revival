/*
 * OpenGL ES 1.x / 2.0 for the guest. Arguments arrive soft-float (floats in
 * core registers) and pointers are guest addresses; guest memory is directly
 * addressable from the host, so client-side arrays are passed through as
 * translated pointers and the driver reads them at draw time. The engine never
 * binds buffer objects, so every array pointer is a real address.
 */
#include "hle.h"

#include "gl_functions.h"

#define DECLARE(ret, name, args) extern ret name args;
GL_FUNCTIONS(DECLARE)

/* glBindFramebufferOES is an extension: looked up at runtime. */
extern void *eglGetProcAddress(const char *);
static void (*p_glBindFramebufferOES)(GLenum, GLuint);

#define I(n) ((GLint)zc_arg(c, n))
#define U(n) ((GLuint)zc_arg(c, n))
#define F(n) zc_argf(c, n)
#define P(n) zc_ptr(zc_arg(c, n))
#define B(n) ((GLboolean)zc_arg(c, n))
#define V(expr) do { expr; return 0; } while (0)

static int h_glActiveTexture(zc_cpu *c) { V(glActiveTexture(U(0))); }
static int h_glAttachShader(zc_cpu *c) { V(glAttachShader(U(0), U(1))); }
static int h_glBindAttribLocation(zc_cpu *c) { V(glBindAttribLocation(U(0), U(1), P(2))); }
static int h_glBindTexture(zc_cpu *c) { V(glBindTexture(U(0), U(1))); }
static int h_glBlendFunc(zc_cpu *c) { V(glBlendFunc(U(0), U(1))); }
static int h_glClear(zc_cpu *c) { V(glClear(U(0))); }
static int h_glClearColor(zc_cpu *c) { V(glClearColor(F(0), F(1), F(2), F(3))); }
static int h_glClientActiveTexture(zc_cpu *c) { V(glClientActiveTexture(U(0))); }
static int h_glColor4f(zc_cpu *c) { V(glColor4f(F(0), F(1), F(2), F(3))); }
static int h_glColor4ub(zc_cpu *c) { V(glColor4ub(B(0), B(1), B(2), B(3))); }
static int h_glColorPointer(zc_cpu *c) { V(glColorPointer(I(0), U(1), I(2), P(3))); }
static int h_glCompileShader(zc_cpu *c) { V(glCompileShader(U(0))); }
static int h_glCompressedTexImage2D(zc_cpu *c)
{
    V(glCompressedTexImage2D(U(0), I(1), U(2), I(3), I(4), I(5), I(6), P(7)));
}
static int h_glCreateProgram(zc_cpu *c) { zc_ret(c, glCreateProgram()); return 0; }
static int h_glCreateShader(zc_cpu *c) { zc_ret(c, glCreateShader(U(0))); return 0; }
static int h_glDeleteProgram(zc_cpu *c) { V(glDeleteProgram(U(0))); }
static int h_glDeleteShader(zc_cpu *c) { V(glDeleteShader(U(0))); }
static int h_glDeleteTextures(zc_cpu *c) { V(glDeleteTextures(I(0), P(1))); }
static int h_glDisable(zc_cpu *c) { V(glDisable(U(0))); }
static int h_glDisableClientState(zc_cpu *c) { V(glDisableClientState(U(0))); }
static int h_glDisableVertexAttribArray(zc_cpu *c) { V(glDisableVertexAttribArray(U(0))); }
static int h_glDrawArrays(zc_cpu *c) { V(glDrawArrays(U(0), I(1), I(2))); }
static int h_glDrawElements(zc_cpu *c) { V(glDrawElements(U(0), I(1), U(2), P(3))); }
static int h_glEnable(zc_cpu *c) { V(glEnable(U(0))); }
static int h_glEnableClientState(zc_cpu *c) { V(glEnableClientState(U(0))); }
static int h_glEnableVertexAttribArray(zc_cpu *c) { V(glEnableVertexAttribArray(U(0))); }
static int h_glGenTextures(zc_cpu *c) { V(glGenTextures(I(0), P(1))); }
static int h_glGetError(zc_cpu *c) { zc_ret(c, glGetError()); return 0; }
static int h_glGetFloatv(zc_cpu *c) { V(glGetFloatv(U(0), P(1))); }
static int h_glGetIntegerv(zc_cpu *c) { V(glGetIntegerv(U(0), P(1))); }
static int h_glGetProgramiv(zc_cpu *c) { V(glGetProgramiv(U(0), U(1), P(2))); }
static int h_glGetShaderiv(zc_cpu *c) { V(glGetShaderiv(U(0), U(1), P(2))); }
static int h_glGetUniformLocation(zc_cpu *c) { zc_ret(c, (uint32_t)glGetUniformLocation(U(0), P(1))); return 0; }
static int h_glIsTexture(zc_cpu *c) { zc_ret(c, glIsTexture(U(0))); return 0; }
static int h_glLightfv(zc_cpu *c) { V(glLightfv(U(0), U(1), P(2))); }
static int h_glLineWidth(zc_cpu *c) { V(glLineWidth(F(0))); }
static int h_glLinkProgram(zc_cpu *c) { V(glLinkProgram(U(0))); }
static int h_glLoadIdentity(zc_cpu *c) { (void)c; glLoadIdentity(); return 0; }
static int h_glLoadMatrixf(zc_cpu *c) { V(glLoadMatrixf(P(0))); }
static int h_glMaterialf(zc_cpu *c) { V(glMaterialf(U(0), U(1), F(2))); }
static int h_glMaterialfv(zc_cpu *c) { V(glMaterialfv(U(0), U(1), P(2))); }
static int h_glMatrixMode(zc_cpu *c) { V(glMatrixMode(U(0))); }
static int h_glNormalPointer(zc_cpu *c) { V(glNormalPointer(U(0), I(1), P(2))); }
static int h_glOrthof(zc_cpu *c) { V(glOrthof(F(0), F(1), F(2), F(3), F(4), F(5))); }
static int h_glPopMatrix(zc_cpu *c) { (void)c; glPopMatrix(); return 0; }
static int h_glPushMatrix(zc_cpu *c) { (void)c; glPushMatrix(); return 0; }
static int h_glReadPixels(zc_cpu *c) { V(glReadPixels(I(0), I(1), I(2), I(3), U(4), U(5), P(6))); }
static int h_glRotatef(zc_cpu *c) { V(glRotatef(F(0), F(1), F(2), F(3))); }
static int h_glScalef(zc_cpu *c) { V(glScalef(F(0), F(1), F(2))); }
static int h_glScissor(zc_cpu *c) { V(glScissor(I(0), I(1), I(2), I(3))); }
static int h_glShaderSource(zc_cpu *c)
{
    GLsizei n = I(1);
    uint32_t arr = zc_arg(c, 2);
    const GLchar **srcs = calloc((size_t)(n > 0 ? n : 1), sizeof *srcs);
    for (GLsizei i = 0; i < n; i++)
        srcs[i] = zc_ptr(zc_rd32(arr + 4u * (uint32_t)i));
    glShaderSource(U(0), n, srcs, P(3));
    free(srcs);
    return 0;
}
static int h_glTexCoordPointer(zc_cpu *c) { V(glTexCoordPointer(I(0), U(1), I(2), P(3))); }
static int h_glTexEnvi(zc_cpu *c) { V(glTexEnvi(U(0), U(1), I(2))); }
static int h_glTexImage2D(zc_cpu *c) { V(glTexImage2D(U(0), I(1), I(2), I(3), I(4), I(5), U(6), U(7), P(8))); }
static int h_glTexParameteri(zc_cpu *c) { V(glTexParameteri(U(0), U(1), I(2))); }
static int h_glTranslatef(zc_cpu *c) { V(glTranslatef(F(0), F(1), F(2))); }
static int h_glUniform1f(zc_cpu *c) { V(glUniform1f(I(0), F(1))); }
static int h_glUniform1i(zc_cpu *c) { V(glUniform1i(I(0), I(1))); }
static int h_glUniform2fv(zc_cpu *c) { V(glUniform2fv(I(0), I(1), P(2))); }
static int h_glUniform3f(zc_cpu *c) { V(glUniform3f(I(0), F(1), F(2), F(3))); }
static int h_glUniform3fv(zc_cpu *c) { V(glUniform3fv(I(0), I(1), P(2))); }
static int h_glUniform4f(zc_cpu *c) { V(glUniform4f(I(0), F(1), F(2), F(3), F(4))); }
static int h_glUniform4fv(zc_cpu *c) { V(glUniform4fv(I(0), I(1), P(2))); }
static int h_glUniformMatrix2fv(zc_cpu *c) { V(glUniformMatrix2fv(I(0), I(1), B(2), P(3))); }
static int h_glUniformMatrix3fv(zc_cpu *c) { V(glUniformMatrix3fv(I(0), I(1), B(2), P(3))); }
static int h_glUniformMatrix4fv(zc_cpu *c) { V(glUniformMatrix4fv(I(0), I(1), B(2), P(3))); }
static int h_glUseProgram(zc_cpu *c) { V(glUseProgram(U(0))); }
static int h_glVertexAttrib4f(zc_cpu *c) { V(glVertexAttrib4f(U(0), F(1), F(2), F(3), F(4))); }
static int h_glVertexAttribPointer(zc_cpu *c) { V(glVertexAttribPointer(U(0), I(1), U(2), B(3), I(4), P(5))); }
static int h_glVertexPointer(zc_cpu *c) { V(glVertexPointer(I(0), U(1), I(2), P(3))); }

static int h_glBindFramebufferOES(zc_cpu *c)
{
    if (!p_glBindFramebufferOES)
        p_glBindFramebufferOES = (void (*)(GLenum, GLuint))eglGetProcAddress("glBindFramebufferOES");
    if (p_glBindFramebufferOES)
        p_glBindFramebufferOES(U(0), U(1));
    return 0;
}

void zc_hle_gl_init(void)
{
#define REGISTER(ret, name, args) zc_hle_register(#name, h_##name);
    GL_FUNCTIONS(REGISTER)
    zc_hle_register("glBindFramebufferOES", h_glBindFramebufferOES);
}
