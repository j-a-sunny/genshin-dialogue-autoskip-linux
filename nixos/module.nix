{ config, lib, pkgs, ... }:

let
  cfg = config.services.genshin-autoskip;
in
{
  options.services.genshin-autoskip = {
    enable = lib.mkEnableOption "genshin-autoskip";
    
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.genshin-autoskip;
      description = "The genshin-autoskip package to use.";
    };
    
    user = lib.mkOption {
      type = lib.types.str;
      default = "user";
      description = "User that will run the autoskip service. Must be in the 'input' group.";
    };
    
    # Configuration options mapped from .env
    notifications = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Desktop notifications on start/pause/quit";
    };
    
    autoConfirm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto-confirm the first answer option; false waits for you";
    };
    
    playingIconColor = lib.mkOption {
      type = lib.types.str;
      default = "236,229,216";
      description = "RGB of the dialogue autoplay icon";
    };
    
    colorTolerance = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Allowed per-channel color deviation";
    };
    
    patchRadius = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Half-size of the pixel box sampled per checkpoint (3 → 7x7)";
    };
    
    matchFraction = lib.mkOption {
      type = lib.types.float;
      default = 0.34;
      description = "Fraction of the box that must match for a checkpoint to trigger";
    };
    
    # Checkpoint coordinates (1080p reference space)
    checkpointPlayingIcon = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = { x = 84; y = 46; };
      description = "Playing icon checkpoint coordinates";
    };
    
    checkpointDialogueIconLower = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = { x = 1301; y = 808; };
      description = "Dialogue icon lower checkpoint coordinates";
    };
    
    checkpointDialogueIconHigher = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = { x = 1301; y = 790; };
      description = "Dialogue icon higher checkpoint coordinates";
    };
    
    checkpointLoadingScreen = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = { x = 1200; y = 700; };
      description = "Loading screen checkpoint coordinates";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Ensure uinput is available
    hardware.uinput.enable = true;
    
    # Add user to input group if not already
    users.users.${cfg.user}.extraGroups = lib.mkForce (lib.unique (config.users.users.${cfg.user}.extraGroups ++ [ "input" ]));
    
    # Create a systemd user service for running genshin-autoskip
    systemd.user.services.genshin-autoskip = {
      description = "Genshin Impact Dialogue Auto-Skipper";
      after = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      environment = {
        NOTIFICATIONS = lib.toString cfg.notifications;
        AUTO_CONFIRM = lib.toString cfg.autoConfirm;
        PLAYING_ICON_COLOR = cfg.playingIconColor;
        COLOR_TOLERANCE = lib.toString cfg.colorTolerance;
        PATCH_RADIUS = lib.toString cfg.patchRadius;
        MATCH_FRACTION = lib.toString cfg.matchFraction;
        CHECKPOINT_PLAYING_ICON = "${cfg.checkpointPlayingIcon.x},${cfg.checkpointPlayingIcon.y}";
        CHECKPOINT_DIALOGUE_ICON_LOWER = "${cfg.checkpointDialogueIconLower.x},${cfg.checkpointDialogueIconLower.y}";
        CHECKPOINT_DIALOGUE_ICON_HIGHER = "${cfg.checkpointDialogueIconHigher.x},${cfg.checkpointDialogueIconHigher.y}";
        CHECKPOINT_LOADING_SCREEN = "${cfg.checkpointLoadingScreen.x},${cfg.checkpointLoadingScreen.y}";
        # Ensure X11/Wayland environment
        DISPLAY = ":0";
        XDG_RUNTIME_DIR = "/run/user/${builtins.toString (config.users.users.${cfg.user}.uid or 1000)}";
        WAYLAND_DISPLAY = "wayland-0";
        # Python path for pygobject
        GI_TYPELIB_PATH = "${pkgs.gobject-introspection}/lib/girepository-1.0:${pkgs.gtk3}/lib/girepository-1.0:${pkgs.glib}/lib/girepository-1.0";
        GST_PLUGIN_PATH = "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0";
        LD_LIBRARY_PATH = "${pkgs.libx11}/lib:${pkgs.glib}/lib:${pkgs.gtk3}/lib:${pkgs.cairo}/lib:${pkgs.pipewire}/lib:${pkgs.gst_all_1.gstreamer}/lib:${pkgs.gst_all_1.gst-plugins-base}/lib";
      };
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/genshin-autoskip";
        Restart = "on-failure";
        RestartSec = 5;
        StandardOutput = "journal";
        StandardError = "journal";
      };
      # We need to run this with the user's graphical session
      # This is a template - actual use requires a user session
    };
    
    # Add to environment.systemPackages if you want the binary available globally
    environment.systemPackages = lib.mkForce [ cfg.package ];
  };
}
