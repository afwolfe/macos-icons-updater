# macOS Icons Updater

macOS Icons Updater tool automatically replaces custom icons after software updates.

## Problem

After updating applications, custom icons for programs are replaced with standard ones. Replacing requires a lot of repetitive steps.

## Solution

Just put custom icons in the specific folder and run this tool after each update of the software. It will automatically replace all the custom icons.

## Basic Usage

1. Download the tool by going to [releases](https://github.com/vchkhr/macos-icons-updater/releases) and downloading the latest `macos-icons-updater.sh` file.
2. Put all the custom icons in the same folder with the tool.
3. Rename icons as programs named in the Dock.
   1. Do not remove `.icns` extension.
   2. For example, you have created the folder `icons` inside the `Downloads` folder:

    ```sh
    Firefox.icns
    GitHub Desktop.icns
    macos-icons-updater.sh
    Microsoft Word.icns
    TeamViewer.icns
    ```

4. Navigate to the tool in Terminal.
   1. Open Terminal (press <kbd>command</kbd>+<kbd>space</kbd>.
   2. Type `Terminal` and press <kbd>enter</kbd>.
   3. Navigate to the folder where you keep the icons and tool.
      1. Ex: `cd Downloads/icons` and press <kbd>enter</kbd>.
5. Run the tool.
   1. `zsh macos-icons-updater.sh` and press <kbd>enter</kbd>.
6. Icons will be replaced with the new ones, Dock and Finder will be restarted.
7. You may need to relaunch the program or Mac before the Dock icon refreshes.

## Advanced Usage and Arguments

Run the script with the `--help` argument to see all additional options:

```sh
$ ./macos-icons-updater.sh --help
===============================================================
macOS Icons Updater
https://github.com/vchkhr/macos-icons-updater
Please read the documentation from the link above before using.
MIT License is attached at the link above.
===============================================================
 -h   --help              print this help message
 -s   --no-sudo           run script without sudo
 -q   --quiet             reduce output
 -d   --depth <DEPTH>     search depth to find apps in subfolders. Default is 1.
 -i   --icons <PATH>      set the path to the icons. Default to current directory.
 -a   --apps  <PATH>      set the path to the .app bundles. Default to /Applications
 ```

Ex: `./macos-icons-updater.sh --no-sudo -q -d 2 --icons $HOME/icons --apps /Applications`

## Feedback and Donations

Feedback is always welcome at [GitHub Issues](https://github.com/vchkhr/macos-icons-updater/issues).\
You can donate to this project using [Patreon](https://patreon.com/vchkhr).
