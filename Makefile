.PHONY := clean install test
RELEASE_DIR := .release
WORKFLOW_ZIP := Linguee.Search.alfredworkflow
VERSION_FILE := LATEST_VERSION
VERSION := $(shell cat $(VERSION_FILE))

all: workflow

install: workflow
	@echo "Openning the newly created $(WORKFLOW_ZIP)."
	open $(WORKFLOW_ZIP)

build-release:
	@echo "Building a release binary..."
	swift build -c release

workflow: collect-workflow
	@echo "Creating a workflow archive..."
	zip -ju $(WORKFLOW_ZIP) $(RELEASE_DIR)/*
	@echo "$(WORKFLOW_ZIP) was successfully created."

collect-workflow: build-release test info.plist version | $(RELEASE_DIR)
	@echo "Collecting workflow archive files in $(RELEASE_DIR)"
	cp .build/release/LingueeOnAlfred $(RELEASE_DIR)/
	cp Icons/* $(RELEASE_DIR)/

$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)

test:
	@echo "Running tests..."
	swift test

clean:
	@echo "Cleaning all..."
	rm -rf "$(RELEASE_DIR)"
	rm -f "$(WORKFLOW_ZIP)"
	swift package clean

info.plist version: _create_version_files

_create_version_files: | $(RELEASE_DIR)
	@echo "Creating info.plist."
	@echo "Updating version to $(VERSION)."
	sed 's/$$(VERSION)/$(VERSION)/g' info.plist.tmpl > $(RELEASE_DIR)/info.plist
	echo '$(VERSION)' > $(VERSION_FILE)
	cp $(VERSION_FILE) $(RELEASE_DIR)/version

format:
	@echo "Formatting the code..."
	swift-format -i --configuration swift-format.config.json -r Sources Tests
