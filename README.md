# Flatpak Sublime (Text & Merge)

This project packages **Sublime Text** and **Sublime Merge** in Flatpak format, with an automated workflow to easily build, install, uninstall, and clean up the environment.

## Project structure

- `builder.sh` → Build Flatpak packages (`.flatpak`) in `target/`.
- `cleaner.sh` → Cleans up the project and returns it to its initial state.
- `setup.sh` → Mini CLI application that centralizes all actions.
- `main/` → Manifestos and construction files.
- `target/` → Folder where bundles are generated (`sublime-text.flatpak`, `sublime-merge.flatpak`).

## Requirements

You need the following packages:

- curl, tar, rsync, and find.
- flatpak and flatpak-builder.

Depending on your Linux distribution, the installation method may vary, which is why it is not specified.

### Install the Freedesktop SDK 24.08

First, make sure you have Flathub configured as remote (if you haven't already):

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

Then install the SDK:

```bash
flatpak install flathub org.freedesktop.Sdk//24.08
```

## Using `setup.sh`

You can perform all possible actions on the project by running:

```bash
./setup.sh
```

You can also run **builder.sh** and **cleaner.sh** individually. They are designed to depend on **setup.sh**, but use them for convenience.

## Additional notes

You can download the files manually from the official website by selecting the direct download of 64-bit .tar.xz. Once extracted, place all the contents in the **main/sublime-merge/files/** or **main/sublime-text/files/** folder and delete the _.desktop_ file you find.

You can package it with **builder.sh** or from **setup.sh** without any problems. This is useful if you want to have specific Sublime builds.

The scripts are all in Spanish except for the commented lines in the code. I was too lazy to put it in English, but if anyone complains, I might add multilingual support.

Remember that if the path where the icons are stored in the Icon/ folder or where the application is stored in the opt/ folder differs from the current one, this script will not work.

This was tested on: Sublime Text Build 4200 and Sublime Merge Build 2112.