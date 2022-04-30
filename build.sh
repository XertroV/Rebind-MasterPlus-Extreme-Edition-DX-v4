#!/usr/bin/env bash

# https://greengumdrops.net/index.php/colorize-your-bash-scripts-bash-color-library/
source ./_colors.bash

_build_mode=${1:-dev}

case $_build_mode in
  dev|release)
    ;;
  *)
    _colortext16 red "⚠ Error: build mode of '$_build_mode' is not a valid option.\n\tOptions: dev, release.";
    exit -1;
    ;;
esac

_colortext16 yellow "🚩 Build mode: $_build_mode"

# if we don't have `dos2unix` below then we need to add `\r` to the `tr -d`
PLUGIN_PRETTY_NAME="$(cat ./src/info.toml | dos2unix | grep '^name' | cut -f 2 -d '=' | tr -d '\"\r' | sed 's/^[ ]*//')"

# prelim stuff
case $_build_mode in
  dev)
    # we will replicate this in the info.toml file later
    export PLUGIN_PRETTY_NAME="${PLUGIN_PRETTY_NAME:-} (Dev)"
    ;;
  *)
    ;;
esac

echo
_colortext16 green "✅ Building: ${PLUGIN_PRETTY_NAME}"

# remove parens, replace spaces with dashes, and uppercase characters with lowercase ones
# => `Never Give Up (Dev)` becomes `never-give-up-dev`
PLUGIN_NAME=$(echo "$PLUGIN_PRETTY_NAME" | tr -d '(),;'\''"' | tr 'A-Z ' 'a-z-')
# echo $PLUGIN_NAME
_colortext16 green "✅ Output file/folder name: ${PLUGIN_NAME}"

BUILD_NAME=$PLUGIN_NAME-$(date +%s).zip
RELEASE_NAME=$PLUGIN_NAME-latest.op
PLUGINS_DIR=${PLUGINS_DIR:-$HOME/win/OpenplanetNext/Plugins}
PLUGIN_DEV_LOC=$PLUGINS_DIR/$PLUGIN_NAME
PLUGIN_RELEASE_LOC=$PLUGINS_DIR/$RELEASE_NAME

7z a ./$BUILD_NAME ./src/*

cp -v $BUILD_NAME $RELEASE_NAME

_colortext16 green "\n✅ Built plugin as ${BUILD_NAME} and copied to ./${RELEASE_NAME}.\n"

# this case should set both _copy_exit_code and _build_dest

case $_build_mode in
  dev)
    # in case it doesn't exist
    _build_dest=$PLUGIN_DEV_LOC
    mkdir -p $_build_dest/
    cp -a -v ./src/* $_build_dest/
    _copy_exit_code="$?"
    sed -i 's/^\(name[ \t="]*\)\(.*\)"/\1\2 (Dev)"/' $_build_dest/info.toml
    export PLUGIN_PRETTY_NAME="${PLUGIN_PRETTY_NAME} \(Dev\)"
    # diff src/info.toml $_build_dest/info.toml
    # cat $_build_dest/info.toml
    ;;
  release)
    _build_dest=$PLUGIN_RELEASE_LOC
    cp -v $RELEASE_NAME $_build_dest
    _copy_exit_code="$?"
    ;;
  *)
    _colortext16 red "\n⚠ Error: unknown build mode: $_build_mode"
esac

echo ""
if [[ "$_copy_exit_code" != "0" ]]; then
  echo $PLUGIN_PRETTY_NAME
  _colortext16 red "⚠ Error: could not copy plugin to Trackmania directory. You might need to click\n\t\`F3 > Scripts > TogglePlugin > PLUGIN\`\nto unlock the file for writing."
  _colortext16 red "⚠   Also, \"Stop Recent\" and \"Reload Recent\" should work, too, if the plugin is the \"recent\" plugin."
else
  _colortext16 green "✅ Copied plugin to Trackmania directory: ${_build_dest}"
fi


# cleanup
case $_build_mode in
  dev)
    # remove the build artifact b/c they'll just take up space
    (rm $BUILD_NAME && _colortext16 green "✅ Removed ${BUILD_NAME}") || _colortext16 red "Failed to remove ${BUILD_NAME}."
    ;;
  *)
    ;;
esac

_colortext16 green "✅ Done."
