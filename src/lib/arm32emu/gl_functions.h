/* The OpenGL ES entry points the engine imports, as an X-macro list. */
#ifndef ZC_GL_FUNCTIONS_H
#define ZC_GL_FUNCTIONS_H

typedef unsigned int GLenum, GLuint, GLbitfield;
typedef int GLint, GLsizei;
typedef float GLfloat;
typedef unsigned char GLboolean, GLubyte;
typedef char GLchar;

#define GL_FUNCTIONS(X) \
    X(void, glActiveTexture, (GLenum)) \
    X(void, glAttachShader, (GLuint, GLuint)) \
    X(void, glBindAttribLocation, (GLuint, GLuint, const GLchar *)) \
    X(void, glBindTexture, (GLenum, GLuint)) \
    X(void, glBlendFunc, (GLenum, GLenum)) \
    X(void, glClear, (GLbitfield)) \
    X(void, glClearColor, (GLfloat, GLfloat, GLfloat, GLfloat)) \
    X(void, glClientActiveTexture, (GLenum)) \
    X(void, glColor4f, (GLfloat, GLfloat, GLfloat, GLfloat)) \
    X(void, glColor4ub, (GLubyte, GLubyte, GLubyte, GLubyte)) \
    X(void, glColorPointer, (GLint, GLenum, GLsizei, const void *)) \
    X(void, glCompileShader, (GLuint)) \
    X(void, glCompressedTexImage2D, (GLenum, GLint, GLenum, GLsizei, GLsizei, GLint, GLsizei, const void *)) \
    X(GLuint, glCreateProgram, (void)) \
    X(GLuint, glCreateShader, (GLenum)) \
    X(void, glDeleteProgram, (GLuint)) \
    X(void, glDeleteShader, (GLuint)) \
    X(void, glDeleteTextures, (GLsizei, const GLuint *)) \
    X(void, glDisable, (GLenum)) \
    X(void, glDisableClientState, (GLenum)) \
    X(void, glDisableVertexAttribArray, (GLuint)) \
    X(void, glDrawArrays, (GLenum, GLint, GLsizei)) \
    X(void, glDrawElements, (GLenum, GLsizei, GLenum, const void *)) \
    X(void, glEnable, (GLenum)) \
    X(void, glEnableClientState, (GLenum)) \
    X(void, glEnableVertexAttribArray, (GLuint)) \
    X(void, glGenTextures, (GLsizei, GLuint *)) \
    X(GLenum, glGetError, (void)) \
    X(void, glGetFloatv, (GLenum, GLfloat *)) \
    X(void, glGetIntegerv, (GLenum, GLint *)) \
    X(void, glGetProgramiv, (GLuint, GLenum, GLint *)) \
    X(void, glGetShaderiv, (GLuint, GLenum, GLint *)) \
    X(GLint, glGetUniformLocation, (GLuint, const GLchar *)) \
    X(GLboolean, glIsTexture, (GLuint)) \
    X(void, glLightfv, (GLenum, GLenum, const GLfloat *)) \
    X(void, glLineWidth, (GLfloat)) \
    X(void, glLinkProgram, (GLuint)) \
    X(void, glLoadIdentity, (void)) \
    X(void, glLoadMatrixf, (const GLfloat *)) \
    X(void, glMaterialf, (GLenum, GLenum, GLfloat)) \
    X(void, glMaterialfv, (GLenum, GLenum, const GLfloat *)) \
    X(void, glMatrixMode, (GLenum)) \
    X(void, glNormalPointer, (GLenum, GLsizei, const void *)) \
    X(void, glOrthof, (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)) \
    X(void, glPopMatrix, (void)) \
    X(void, glPushMatrix, (void)) \
    X(void, glReadPixels, (GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, void *)) \
    X(void, glRotatef, (GLfloat, GLfloat, GLfloat, GLfloat)) \
    X(void, glScalef, (GLfloat, GLfloat, GLfloat)) \
    X(void, glScissor, (GLint, GLint, GLsizei, GLsizei)) \
    X(void, glShaderSource, (GLuint, GLsizei, const GLchar *const *, const GLint *)) \
    X(void, glTexCoordPointer, (GLint, GLenum, GLsizei, const void *)) \
    X(void, glTexEnvi, (GLenum, GLenum, GLint)) \
    X(void, glTexImage2D, (GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, const void *)) \
    X(void, glTexParameteri, (GLenum, GLenum, GLint)) \
    X(void, glTranslatef, (GLfloat, GLfloat, GLfloat)) \
    X(void, glUniform1f, (GLint, GLfloat)) \
    X(void, glUniform1i, (GLint, GLint)) \
    X(void, glUniform2fv, (GLint, GLsizei, const GLfloat *)) \
    X(void, glUniform3f, (GLint, GLfloat, GLfloat, GLfloat)) \
    X(void, glUniform3fv, (GLint, GLsizei, const GLfloat *)) \
    X(void, glUniform4f, (GLint, GLfloat, GLfloat, GLfloat, GLfloat)) \
    X(void, glUniform4fv, (GLint, GLsizei, const GLfloat *)) \
    X(void, glUniformMatrix2fv, (GLint, GLsizei, GLboolean, const GLfloat *)) \
    X(void, glUniformMatrix3fv, (GLint, GLsizei, GLboolean, const GLfloat *)) \
    X(void, glUniformMatrix4fv, (GLint, GLsizei, GLboolean, const GLfloat *)) \
    X(void, glUseProgram, (GLuint)) \
    X(void, glVertexAttrib4f, (GLuint, GLfloat, GLfloat, GLfloat, GLfloat)) \
    X(void, glVertexAttribPointer, (GLuint, GLint, GLenum, GLboolean, GLsizei, const void *)) \
    X(void, glVertexPointer, (GLint, GLenum, GLsizei, const void *))

#endif
