# Genshin Dialogue Autoskip - NixOS Support
# 
# This directory contains Nix expressions to build and install
# genshin-autoskip on NixOS systems.
#
# ## Quick Install via Flakes
#
# ```nix
# # In your flake.nix or home-manager config:
# imports = [
#   (fetchTarball "https://github.com/j-a-sunny/genshin-dialogue-autoskip-linux/archive/refs/heads/main.tar.gz")
# ];
#
# # Or directly from this repo:
# pkgs.genshin-autoskip
# ```
#
# ## Using without flakes (traditional Nix)
#
# ```bash
# nix-build .
# nix-shell . --run "genshin-autoskip"
# ```
#
# ## Requirements
#
# Before running, ensure your user has access to:
# - `/dev/uinput` (see README.md for udev rules)
# - Your user is in the `input` group
#
# Example setup script for NixOS:
#
# ```nix
# { config, pkgs, ... }:
# {
#   # Add udev rule for uinput
#   hardware.uinput.enable = true;
#   
#   # Enable the genshin-autoskip package
#   environment.systemPackages = [ pkgs.genshin-autoskip ];
#   
#   # Allow your user to access input devices
#   users.users.youruser.extraGroups = [ "input" ];
# }
# ```

{
  python3Packages,
  stdenv,
  lib,
  xorg,
  glib,
  gtk3,
  cairo,
  gobject-introspection,
  dbus-glib,
  pipewire,
  gst_all_1,
  libxcrypt-compat,
}:

python3Packages.buildPythonApplication {
  pname = "genshin-autoskip";
  version = "0.1.0";
  
  src = ./.;
  
  doCheck = false; # Needs X11/Wayland to run tests
  
  propagatedBuildInputs = with python3Packages; [
    python-xlib
    evdev
    pillow
    rich
    pygobject3
  ];
  
  nativeBuildInputs = [
    python3Packages.setuptools-scm
  ];
  
  buildInputs = [
    xorg.libX11
    xorg.libXext
    glib
    gtk3
    cairo
    gobject-introspection
    dbus-glib
    pipewire
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    libxcrypt-compat
  ];
  
  meta = with lib; {
    description = "Dialogue auto-skipper for Genshin Impact on Linux (Wine, XWayland or native Wayland)";
    homepage = "https://github.com/j-a-sunny/genshin-dialogue-autoskip-linux";
    changelog = "https://github.com/j-a-sunny/genshin-dialogue-autoskip-linux/releases";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [];
    mainProgram = "genshin-autoskip";
  };
}
