/*
 * Stand-in OpenGL ES for the host harness: every entry point the engine uses,
 * recording call counts and handing out object names. Rendering itself is
 * done by test/softgl.c when the harness asks for frame dumps.
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "../gl_functions.h"

uint64_t hostgl_calls, hostgl_draws, hostgl_vertices;
static GLuint next_tex = 1, next_obj = 1;

void glActiveTexture_soft(GLenum);
void glActiveTexture(GLenum a) { hostgl_calls++; glActiveTexture_soft(a); }
void glAttachShader(GLuint a, GLuint b) { (void)a; (void)b; hostgl_calls++; }
void glBindAttribLocation(GLuint a, GLuint b, const GLchar *c) { (void)a; (void)b; (void)c; hostgl_calls++; }
void glBlendFunc_soft(GLenum, GLenum);
void glBlendFunc(GLenum a, GLenum b) { hostgl_calls++; glBlendFunc_soft(a, b); }
void softgl_clear_hook(void);
void glClear(GLbitfield a) { hostgl_calls++; if (a & 0x4000) softgl_clear_hook(); }
void glClientActiveTexture_soft(GLenum);
void glClientActiveTexture(GLenum a) { hostgl_calls++; glClientActiveTexture_soft(a); }
void glCompileShader(GLuint a) { (void)a; hostgl_calls++; }
void glCompressedTexImage2D(GLenum a, GLint b, GLenum c, GLsizei d, GLsizei e, GLint f, GLsizei g, const void *h)
{
    (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; (void)g; (void)h;
    hostgl_calls++;
}
GLuint glCreateProgram(void) { hostgl_calls++; return next_obj++; }
GLuint glCreateShader(GLenum a) { (void)a; hostgl_calls++; return next_obj++; }
void glDeleteProgram(GLuint a) { (void)a; hostgl_calls++; }
void glDeleteShader(GLuint a) { (void)a; hostgl_calls++; }
void glDeleteTextures(GLsizei n, const GLuint *t) { (void)n; (void)t; hostgl_calls++; }
void glDisableVertexAttribArray(GLuint a) { (void)a; hostgl_calls++; }
void glEnableVertexAttribArray(GLuint a) { (void)a; hostgl_calls++; }
void glGenTextures(GLsizei n, GLuint *t)
{
    hostgl_calls++;
    for (GLsizei i = 0; i < n; i++)
        t[i] = next_tex++;
}
GLenum glGetError(void) { hostgl_calls++; return 0; }
void glGetFloatv(GLenum p, GLfloat *v) { (void)p; hostgl_calls++; if (v) v[0] = 0; }
void glGetIntegerv(GLenum p, GLint *v)
{
    hostgl_calls++;
    if (!v)
        return;
    switch (p) {
    case 0x0D33: v[0] = 4096; break;                               /* GL_MAX_TEXTURE_SIZE */
    case 0x0BA2: v[0] = 0; v[1] = 0; v[2] = 1200; v[3] = 540; break; /* GL_VIEWPORT */
    default: v[0] = 0; break;
    }
}
void glGetProgramiv(GLuint a, GLenum p, GLint *v) { (void)a; (void)p; hostgl_calls++; if (v) v[0] = 1; }
void glGetShaderiv(GLuint a, GLenum p, GLint *v) { (void)a; (void)p; hostgl_calls++; if (v) v[0] = 1; }
GLint glGetUniformLocation(GLuint a, const GLchar *n) { (void)a; (void)n; hostgl_calls++; return 0; }
GLboolean glIsTexture(GLuint t) { hostgl_calls++; return t != 0; }
void glLightfv(GLenum a, GLenum b, const GLfloat *c) { (void)a; (void)b; (void)c; hostgl_calls++; }
void glLineWidth(GLfloat a) { (void)a; hostgl_calls++; }
void glLinkProgram(GLuint a) { (void)a; hostgl_calls++; }
void glMaterialf(GLenum a, GLenum b, GLfloat c) { (void)a; (void)b; (void)c; hostgl_calls++; }
void glMaterialfv(GLenum a, GLenum b, const GLfloat *c) { (void)a; (void)b; (void)c; hostgl_calls++; }
void glNormalPointer(GLenum a, GLsizei b, const void *c) { (void)a; (void)b; (void)c; hostgl_calls++; }
void glReadPixels(GLint x, GLint y, GLsizei w, GLsizei h, GLenum f, GLenum t, void *p)
{
    (void)x; (void)y; (void)f; (void)t;
    hostgl_calls++;
    if (p)
        memset(p, 0, (size_t)w * (size_t)h * 4);
}
void glScissor(GLint a, GLint b, GLsizei c, GLsizei d) { (void)a; (void)b; (void)c; (void)d; hostgl_calls++; }
void glShaderSource(GLuint a, GLsizei n, const GLchar *const *s, const GLint *l)
{
    (void)a;
    hostgl_calls++;
    for (GLsizei i = 0; i < n; i++)
        if (s[i] && !l)
            (void)strlen(s[i]); /* touch the translated pointers */
}
void glTexEnvi(GLenum a, GLenum b, GLint c) { (void)a; (void)b; (void)c; hostgl_calls++; }
void glTexParameteri(GLenum a, GLenum b, GLint c) { (void)a; (void)b; (void)c; hostgl_calls++; }
void glUniform1f(GLint a, GLfloat b) { (void)a; (void)b; hostgl_calls++; }
void glUniform1i(GLint a, GLint b) { (void)a; (void)b; hostgl_calls++; }
void glUniform2fv(GLint a, GLsizei b, const GLfloat *c) { (void)a; (void)b; (void)c; hostgl_calls++; }
void glUniform3f(GLint a, GLfloat b, GLfloat c, GLfloat d) { (void)a; (void)b; (void)c; (void)d; hostgl_calls++; }
void glUniform3fv(GLint a, GLsizei b, const GLfloat *c) { (void)a; (void)b; (void)c; hostgl_calls++; }
void glUniform4f(GLint a, GLfloat b, GLfloat c, GLfloat d, GLfloat e) { (void)a; (void)b; (void)c; (void)d; (void)e; hostgl_calls++; }
void glUniform4fv(GLint a, GLsizei b, const GLfloat *c) { (void)a; (void)b; (void)c; hostgl_calls++; }
void glUniformMatrix2fv(GLint a, GLsizei b, GLboolean c, const GLfloat *d) { (void)a; (void)b; (void)c; (void)d; hostgl_calls++; }
void glUniformMatrix3fv(GLint a, GLsizei b, GLboolean c, const GLfloat *d) { (void)a; (void)b; (void)c; (void)d; hostgl_calls++; }
void glUniformMatrix4fv(GLint a, GLsizei b, GLboolean c, const GLfloat *d) { (void)a; (void)b; (void)c; (void)d; hostgl_calls++; }
void glUseProgram(GLuint a) { (void)a; hostgl_calls++; }
void glVertexAttrib4f(GLuint a, GLfloat b, GLfloat c, GLfloat d, GLfloat e) { (void)a; (void)b; (void)c; (void)d; (void)e; hostgl_calls++; }
void glVertexAttribPointer(GLuint a, GLint b, GLenum c, GLboolean d, GLsizei e, const void *f)
{
    (void)a; (void)b; (void)c; (void)d; (void)e; (void)f;
    hostgl_calls++;
}

static void bind_fbo(GLenum a, GLuint b) { (void)a; (void)b; hostgl_calls++; }
void *eglGetProcAddress(const char *name)
{
    return strcmp(name, "glBindFramebufferOES") ? NULL : (void *)bind_fbo;
}
