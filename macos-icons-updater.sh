#!/bin/sh
# Get current directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


echo_err() {
    msg=$1
    echo "\033[0;31m${msg}\033[0m"
}

echo_success() {
    msg=$1
    echo "\033[0;32m${msg}\033[0m"
}

help() {
    echo "==============================================================="
    echo_success "macOS Icons Updater"
    echo "https://github.com/vchkhr/macos-icons-updater"
    echo "Please read the documentation from the link above before using."
    echo "MIT License is attached at the link above."
    echo "==============================================================="
    echo " -h   --help              print this help message"
    echo " -s   --no-sudo           run script without sudo"
    echo " -q   --quiet             reduce output"
    echo " -d   --depth <DEPTH>     search depth to find apps in subfolders. Default is 1."
    echo " -i   --icons <PATH>      set the path to the icons. Default to current directory."
    echo " -a   --apps  <PATH>      set the path to the .app bundles. Default to /Applications"
    exit 0
}

#default values
no_sudo=0
depth=1
icon_dir="$script_dir"
app_dir="/Applications"
# handle multiple arguments
while [ "$1" != "" ]; do
    case "$1" in
        -h | --help ) help; shift ;;
        -s | --no-sudo ) no_sudo=1 ; shift ;;
        -q | --quiet ) quiet=1; shift ;;
        -d | --depth ) depth="$2"; shift 2 ;;
        -i | --icons ) icon_dir="$2"; shift 2 ;;
        -a | --apps ) app_dir="$2"; shift 2 ;;
        * ) shift ;; # shift past unknown args
    esac
done

# Verify directories exist before continuing
if [ ! -d $icon_dir ]; then
    echo_err "Icon directory: $icon_dir does not exist"
    exit 1
fi

if [ ! -d $app_dir ]; then
    echo_err "App directory: $app_dir does not exist"
    exit 1
fi


# Count successful and failed jobs
successful_jobs=0
failed_jobs=0
    
# Process all files in the current directory
# https://unix.stackexchange.com/questions/9496/looping-through-files-with-spaces-in-the-names#9499
# Loops over files ending in .icns with spaces without a subshell.
IFS='
'
set -f
for iconpath in $(find $icon_dir -name "*.icns"); do
    # Shorten icon to just the filename
    icon=$(basename "$iconpath")
    # Get app`s name from icon`s name
    app=${icon/".icns"/""}

    app_path=$(find $app_dir -name "$app.app" -type d -print -maxdepth $depth -quit)
    if [ "$app_path" == "" ]; then 
        if [[ $quiet -eq 0 ]]; then
            echo_err "No app found: \"$app\""
        fi
        (( failed_jobs++ ))
        continue
    fi
    app_contents="$app_path/Contents"

    # Check if there are app and it's "Info.plist" file
    if [ ! -f "$app_contents/Info.plist" ]; then
        if [[ $quiet -eq 0 ]]; then
            echo_err "No app found: \"$app\""
        fi
        (( failed_jobs++ ))
        continue
    fi

    # Get the "Info.plist" file of the app (icon's name is written there)
    info_plist="$app_contents/Info.plist"
    nextLineIsAppIcon=0
    appIcon=""

    # Read every line of "Info.plist" file
    while IFS= read -r line;
    do
        # If this is a key of the icon's name, then make a flag
        if [[ $line == *"<key>CFBundleIconFile</key>"* ]]; then
            nextLineIsAppIcon=1
            continue
        fi

        # Process the line with the icon's name if flag
        if [[ $nextLineIsAppIcon = 1 ]]; then
            # Split by ">" and "<"
            appIcon="$(cut -d'>' -f2 <<< "$line")"
            appIcon="$(cut -d'<' -f1 <<< "$appIcon")"
            break
        fi
    done < "$info_plist"

    # Check if icon's name is not found
    if [[ $nextLineIsAppIcon = 0 ]]; then
        if [[ $quiet -eq 0 ]]; then
            echo_err "Unable to find icon name in \"Info.plist\" for this app: \"$app\""
        fi
        (( failed_jobs++ ))
        continue
    fi

    # Append ".icns" to icon's name if needed
    if [[ $appIcon != *".icns" ]]; then
        appIcon=$appIcon".icns"
    fi

    # Replace app's standard icon with the new one and count successful and failed jobs
    if [[ $no_sudo = 0 ]]; then
        sudo cp "$iconpath" "$app_contents/Resources/$appIcon"
        ((successful_jobs++))
    else
        # Check if file is writable or not
        if [ -w "$app_contents/Resources/$appIcon" ]; then
            cp "$iconpath" "$app_contents/Resources/$appIcon"
            ((successful_jobs++))
        else
            if [[ $quiet -eq 0 ]]; then
                echo_err "Unable to update icon for this application due to not writable permission: \"$app\""
            fi
            ((failed_jobs++))
        fi
    fi
done

# Reload Finder and Dock if not -nosudo flag
if [[ $no_sudo = 0 ]]; then
    sudo killall Finder
    sudo killall Dock
fi

# Display result
if [[ $successful_jobs > 0 ]]; then
    echo_success "Updated icon(s) for "$successful_jobs" app(s)"
else
    if [[ $failed_jobs = 0 ]]; then
        echo_err "No icon(s) updated. Check if you have placed icon(s) in the same directory with this tool"
    else
        echo_err "No icon(s) updated due to error(s)"
    fi
fi
