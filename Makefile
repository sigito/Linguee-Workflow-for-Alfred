.PHONY := clean
RELEASE_DIR := .release
WORKFLOW_ZIP := Linguee.Search.alfredworkflow

all: workflow

build-release:
	@echo "Building a release binary..."
	swift build -c release

workflow: collect-workflow
	@echo "Creating a workflow archive..."
	zip -ju $(WORKFLOW_ZIP) $(RELEASE_DIR)/*
	@echo "$(WORKFLOW_ZIP) was successfully created."

collect-workflow: build-release | $(RELEASE_DIR)
	@echo "Collecting workflow archive files in $(RELEASE_DIR)"
	cp .build/release/LingueeOnAlfred $(RELEASE_DIR)/
	cp Workflow/* $(RELEASE_DIR)/

$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)

clean:
	@echo "Cleaning all..."
	rm -rf "$(RELEASE_DIR)"
	rm "$(WORKFLOW_ZIP)"
	swift package clean

