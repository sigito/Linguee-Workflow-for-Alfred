# Linguee Workflow for Alfred

<p align="center">

<a href="https://www.alfredapp.com/">
  <img src="https://img.shields.io/badge/Alfred-4-blueviolet" />
</a>
<img src="https://img.shields.io/badge/macOS-10.15%20|%2011+-blue" />
<a href="https://github.com/sigito/Linguee-Workflow-for-Alfred/releases/latest">
  <img src="https://img.shields.io/github/v/release/sigito/Linguee-Workflow-for-Alfred?color=important" />
</a>
<a href="https://twitter.com/sigito_is_taken">
  <img src="https://img.shields.io/badge/Contact-%40sigito__is__taken-lightgrey" />
</a>

</p>

<p align="center"><img src="demo.gif" alt="Demo"/></p>

Linguee Search is an Alfred workflow that lets you search for translations on Linguee.com.

* [Download the workflow](#download-the-workflow)
  * [Manually install the workflow](#manually-install-the-workflow)
* [Features](#features)
  * [Setting translation language pair](#setting-translation-language-pair)
  * [Setting a global keyboard schortcut](#setting-a-global-keyboard-schortcut)
  * [Copy behavior](#copy-behavior)
  * [Miscellaneous flags](#miscellaneous-flags)
* [Known issues](#known-issues)
  * [LingueeOnAlfred will damage your computer and you should remove it to the trash (#13)](#lingueeonalfred-will-damage-your-computer-and-you-should-remove-it-to-the-trash-13)
* [License](#license)

## Download the workflow

> ⚠️ This workflow requires [Alfred app with Powerpack](https://www.alfredapp.com/powerpack/).

The latest version of the workflow can be downloaded from [GitHub releases](https://github.com/sigito/Linguee-Workflow-for-Alfred/releases/latest).

### Manually install the workflow

You can also build and install the workflow yourself. Just clone the repository and run the next command in Terminal from the directory with the cloned project:

```shell
make install
```

A new `Linguee.Search.alfredworkflow` workflow would be built from source and opened in Alfred.

## Features

* Rich search results for query translations.
* Use `l` keyword to search in Alfred.
  * The keyword is configurable in the Alfred workflow settings.
* Open the the translation page in a browser by hitting `↩` (Return) on the result entry.
* Open an initial search query in a browser:
  * `⌘ ↩` (Command-Return) on any search result, or
  * `↩` (Return) on "Search on Linguee for '{query}'". This entry is always added as the last search result.
* Search autocomplete on `↹` (Tab).
* Copy the results with `⌘ C` (Command-C).

   See (#copy-behavior) on the copy behavior options.

* Display a selected result in a large type with `⌘ L` (Command-L).
* Quickly look at the tranlation page by tapping `⇧` (Shift) or `⌘ Y` (Command+Y).
* Automatic checks for updates.
  * Use `check_for_updates` variable to control this feature.
  * If a newer version of the workflow is available, an extra result row is added with [an update prompt](periodic_checks_for_updates.png).
* Linguee.com as a fallback search.

  Follow insturctions in the workflow viewer in Alfred to add Linguee to the list of default fallbacks. See [Alfred's help center article](https://www.alfredapp.com/help/features/default-results/fallback-searches/) for more information about the default fallback feature.


### Setting translation language pair

`source_language` and `destination_language` define the language pair used for the translation.

Default pair is English + German. To override this behavior, set the variables to a desired pair. For a full list of available language pairs please visit <https://www.linguee.com/?moreLanguages=1#moreLanguages>. The values of the variables must be a lowercased language name in English. E.g., "english", "german", "french".

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

### Copy behavior

By default all of the translation information, including the initial search text, translations, and the results link, would be copied as a result of `⌘ C` (Command-C) action.

Use `copy_behavior` variable to change default behavior. There are a few possible values it can be set to:

* `all` (default) — copy all of the translation information;
* `url` — copy the Lingue.com link to the translation page;
* `first-translation-only` — copy the first translation only. In case there no translations available, the initial query would be copied instead.

### Miscellaneous flags

* `check_for_updates` – whether the workflow should periodically check for a new version.  
  Possible values: `true` or `false`. Default: `false`.
* `disable_copy_text_promotion` – disables inclusion of a URL to this workflow in the copied result text.  
  Possible values: `true` or `false`. Default: `false`.
* `demo_mode` – return a stubbed response with all states available.  
  Possible values: `true` or `false`. Default: `false`.  
  ⚠️  Setting this varibale would make the workflow to always return stubbed values.

## Known issues

### LingueeOnAlfred will damage your computer and you should remove it to the trash ([#13](https://github.com/sigito/Linguee-Workflow-for-Alfred/issues/13))

The workflow binary is not verified by Apple. Thus macOS would not recognize the binary and suggest to move it to trash.

In order to work this around, go to `System Preferences` > `Security & Privacy`, switch to `General` tab. In the `Allow apps downloaded from:` section select `App Store and identified developers` and then to the right of it tap an `Open Anyway` button.

On the next attempt to search with Linguee, a dialog would pop. Select `Open` and you are good to go!

## License

* The Linguee Workflow for Alfred is released under the MIT license. [See LICENSE](LICENSE) for details.
* The surved results are used according to Linguee's [Terms and Conditions](https://www.linguee.com/english-german/page/termsAndConditions.php).
* The icons are provided by [Susan Kaltschmidt](http://www.susan-kaltschmidt.com/).
