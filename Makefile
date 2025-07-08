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
MANIFEST=$(APP_ID).yaml

BUNDLE=$(APP_ID).flatpak
BUILD=build
REPO=repo

################################################################################


.PHONY: all run shell bundle install clean

all: build/

run: install
	flatpak run $(APP_ID)

################################################################################
## Build

bundle: $(BUNDLE)
install: $(BUNDLE)
	echo ⋅ Installing bundle [$(BUNDLE)]
	flatpak install                   \
		--user                    \
		--noninteractive          \
		--bundle                  \
		--reinstall               \
		$(BUNDLE)                 \
		| pr -to 2

shell:
	echo flatpak-builder --run        \
			--ccache          \
			$(BUILD)          \
			$(MANIFEST)       \
			/bin/bash

clean:
	rm -rf $(BUILD) $(REPO) $(BUNDLE)

################################################################################

$(BUILD)/.done:
$(BUILD)/: $(MANIFEST) $(BUILD)/.done
	echo ⋅ Building [$(BUILD)]
	flatpak-builder --force-clean     \
			--disable-updates \
			--ccache          \
			--build-only      \
			$(BUILD)          \
			$(MANIFEST)       \
		| pr -to 2
	touch $(BUILD)/.done

$(REPO)/.lock:
$(REPO)/: $(REPO)/.lock | $(BUILD)/
	echo ⋅ Exporting repository [$(REPO)]
	flatpak-builder --finish-only     \
			--repo=$(REPO)    \
			$(BUILD)          \
			$(MANIFEST)       \
		| pr -to 2

$(BUNDLE): | $(BUILD)/ $(REPO)/
	echo ⋅ Exporting bundle [$(BUNDLE)]
	flatpak build-bundle $(REPO)      \
		             $(BUNDLE)    \
		             $(APP_ID)    \
		             stable       \
		| pr -to 2
