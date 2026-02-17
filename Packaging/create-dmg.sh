#!/usr/bin/env bash

# Since create-dmg does not clobber, be sure to delete previous DMG
[[ -f RNGadget-Installer.dmg ]] && rm RNGadget-Installer.dmg

# Create the DMG
create-dmg \
  --volname "RNGadget Installer" \
  --volicon "RNGadgetDMG.icns" \
  --background "background.png" \
  --window-pos 200 120 \
  --window-size 500 375 \
  --icon-size 80 \
  --icon "RNGadget.app" 125 175 \
  --hide-extension "RNGadget.app" \
  --app-drop-link 375 175 \
  "RNGadget-Installer.dmg" \
  "source_folder/"
