# Linguee Workflow for Alfred

## Download the workflow

The latest version of the workflow can be downloaded from [GitHub releases](https://github.com/sigito/Linguee-Workflow-for-Alfred/releases).

### Manually install the workflow

You can also build and install the workflow yourself. Just clone the repository and run the next command in Terminal from the directory with the cloned project:
```
make install
```
A new `Linguee.Search.alfredworkflow` workflow would be built from source and opened in Alfred.

## Features

* Rich search resulfts for query translations betwwen English and German.
* Use `l` keyword to search in Alfred.
  * The keyword is configurable in the Alfred workflow settings.
* Open the the translation page in a browser by hitting `↩` (Return) on the result entry.
* Open an initial search query in a browser:
  * `⌘ ↩` (Command-Return) on any search result, or
  * `↩` (Return) on "Search on Linguee for '{query}'". This entry is always added as the last search result.
* Search autocomplete on `↹` (Tab).
* Copy the results with `⌘ C` (Command-C).
* Display a selected result in a large type with "⌘ L" (Command-L).

### Setting a global keyboard schortcut

There is an option to trigger the Linguee Search from anywhere, skipping typing of the command prefix (`l` in our case) in the shared Alfred search window. Unfortunately, Alfred does not import the hotkeys, thus a manual setup is necessary.

The workflow already contains an empty global keyboard shortuct configuration. You should:
1. Open the workflows panel in Alfred settings.
1. Select this workflow.
1. Double-click on the "Hotkey" box in the workflow (alternatively right click and choose "Configure Object...").
1. Press the key combination that should be used as a system-wide shortcut. E.g., `⇧ ⌘ L` (Shift-Command-L).
1. Click "Save".

By default the shortcut would searched for the selected text, or open a ready-to-go Linguee search in Alfred.

To change the assigned key combination, just repeat the steps described above.

More about hotkeys in Alfred available [here](https://www.alfredapp.com/help/workflows/triggers/hotkey/).

## Credits

The workflow is inspired by [linguee-alfred-workflow](https://github.com/alexander-heimbuch/linguee-alfred-workflow) from Alexander Heimbuch.
