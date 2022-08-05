.PHONY := clean install test

VERSION_FILE := LATEST_VERSION
VERSION := $(shell cat $(VERSION_FILE))

DEBUG ?= 0

ifeq ($(DEBUG), 1)
	WORKFLOW_NAME = Linguee Search (DEBUG)
	BUNDLE_ID = com.samsoniuk.alfred.linguee-search.debug
	BUILD_CONFIG = debug
	BINARY_PATH := .build/apple/Products/Debug/LingueeOnAlfred
	TARGET_DIR = .$(BUILD_CONFIG)
	WORKFLOW_ZIP = Linguee.Search-$(VERSION)-debug.alfredworkflow
else
	WORKFLOW_NAME = Linguee Search
	BUNDLE_ID := com.samsoniuk.alfred.linguee-search
	BUILD_CONFIG := release
	BINARY_PATH := .build/apple/Products/Release/LingueeOnAlfred
	TARGET_DIR := .$(BUILD_CONFIG)
	WORKFLOW_ZIP := Linguee.Search-$(VERSION).alfredworkflow
endif

all: workflow

install: workflow
	@echo "Openning the newly created $(WORKFLOW_ZIP)."
	open $(WORKFLOW_ZIP)

build:
	@echo "Building a $(BUILD_CONFIG) binary..."
	swift build -c $(BUILD_CONFIG) --arch x86_64 --arch arm64

workflow: collect-workflow
	@echo "Creating a workflow archive..."
	zip -ju $(WORKFLOW_ZIP) $(TARGET_DIR)/*
	@echo "$(WORKFLOW_ZIP) was successfully created."

collect-workflow: build test info.plist version | $(TARGET_DIR)
	@echo "Collecting workflow archive files in $(TARGET_DIR)"
	cp $(BINARY_PATH) $(TARGET_DIR)/
	cp Icons/* $(TARGET_DIR)/

$(TARGET_DIR):
	mkdir -p $(TARGET_DIR)

test:
	@echo "Running tests..."
	swift test

clean:
	@echo "Cleaning all..."
	rm -rf "$(TARGET_DIR)"
	rm -f "$(WORKFLOW_ZIP)"
	swift package clean

info.plist version: _create_version_files

_create_version_files: | $(TARGET_DIR)
	@echo "Creating info.plist."
	@echo "Updating version to $(VERSION)."
	sed '\
		s/$$(WORKFLOW_NAME)/$(WORKFLOW_NAME)/g; \
		s/$$(BUNDLE_ID)/$(BUNDLE_ID)/g; \
		s/$$(VERSION)/$(VERSION)/g \
		' \
		info.plist.tmpl > $(TARGET_DIR)/info.plist
	echo '$(VERSION)' > $(VERSION_FILE)
	cp $(VERSION_FILE) $(TARGET_DIR)/version

format:
	@echo "Formatting the code..."
	swift-format -i --configuration swift-format.config.json -r Sources Tests Package.swift
