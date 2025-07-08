################################################################################
## Makefile config

SHELL       := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.ONESHELL:
.SILENT:
MAKEFLAGS   += --warn-undefined-variables
MAKEFLAGS   += --no-builtin-rules

################################################################################

APP_ID=io.github.mattiasb.MagicSetEditor2

################################################################################


.PHONY: all install build

all: flatpak

run: bundle
	flatpak run $(APP_ID)

shell: install
	flatpak run --command=sh $(APP_ID)

bundle:
	echo ⋅ Bundle
	flatpak-builder --repo=repo        \
			--ccache           \
                        --disable-download \
                        --force-clean      \
                        --arch=x86_64      \
                        build              \
                        $(APP_ID).yaml | pr -to 2
	flatpak build-bundle repo $(APP_ID).flatpak $(APP_ID) stable | pr -to 2

flatpak: build/
	echo ⋅ Flatpak
	flatpak-builder --ccache           \
                        --disable-download \
                        --force-clean      \
                        build              \
                        $(APP_ID).yaml | pr -to 2

install: build/
	echo ⋅ Install
	flatpak-builder --ccache           \
                        --disable-download \
                        --force-clean      \
                        --install          \
                        --user             \
                        build              \
                        $(APP_ID).yaml | pr -to 2

clean:
	rm -rf build

################################################################################

build/:
	echo ⋅ Build
	flatpak-builder --ccache      \
                        --force-clean \
                        build         \
                        $(APP_ID).yaml | pr -to 2
