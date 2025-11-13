# solo variante nativesdk
EXTRA_OECONF:class-nativesdk:append = " -Dusedl=no"

# niente parallelismo aggressivo su perl nativesdk
PARALLEL_MAKE:class-nativesdk = ""
EXTRA_OEMAKE:class-nativesdk:append = " -j1"
