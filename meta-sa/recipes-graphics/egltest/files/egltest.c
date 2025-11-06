#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <stdio.h>

#ifndef EGL_PLATFORM_SURFACELESS_MESA
#define EGL_PLATFORM_SURFACELESS_MESA 0x31DD
#endif

int main(void)
{
    EGLDisplay display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (display == EGL_NO_DISPLAY)
        display = eglGetPlatformDisplay(EGL_PLATFORM_SURFACELESS_MESA, EGL_DEFAULT_DISPLAY, NULL);

    if (display == EGL_NO_DISPLAY) {
        printf("EGL: no display found\n");
        return 1;
    }

    if (!eglInitialize(display, NULL, NULL)) {
        printf("EGL: initialization failed\n");
        return 1;
    }

    printf("EGL initialized successfully ✅\n");

    EGLint numConfigs;
    eglGetConfigs(display, NULL, 0, &numConfigs);
    printf("EGL found %d configs\n", numConfigs);

    eglTerminate(display);
    return 0;
}
