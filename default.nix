# Genshin Dialogue Autoskip - NixOS Support
{ python3Packages, stdenv, lib, xorg, glib, gtk3, cairo, gobject-introspection, dbus-glib, pipewire, gst_all_1 }:

python3Packages.buildPythonApplication {
  pname = "genshin-autoskip";
  version = "0.1.0";
  
  src = ./.;
  
  format = "pyproject";
  
  nativeBuildInputs = with python3Packages; [
    hatchling
  ];
  
  doCheck = false; # Needs X11/Wayland to run tests
  
  propagatedBuildInputs = with python3Packages; [
    python-xlib
    evdev
    pillow
    rich
    pygobject3
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
