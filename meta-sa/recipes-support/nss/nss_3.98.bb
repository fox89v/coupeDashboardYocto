DESCRIPTION = "Sa override: disable broken NSS recipe on musl SDK"
LICENSE = "CLOSED"
PR = "999"

python () {
    raise bb.parse.SkipRecipe("NSS disabled for musl SDK")
}