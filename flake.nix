{
  description = "Dialogue auto-skipper for Genshin Impact on Linux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      # Default system for top-level outputs
      defaultSystem = "x86_64-linux";
      
      # Base packages for evaluating nixos modules
      basePkgs = import nixpkgs {
        system = defaultSystem;
        overlays = [ self.overlays.default ];
      };
      
      # Import NixOS module (needs lib, pkgs from nixpkgs, not flake utils)
      nixosModule = import ./nixos/module.nix {
        lib = basePkgs.lib;
        pkgs = basePkgs;
        config = {}; # Empty config - will be provided during evaluation
      };
      
      # Import home-manager module similarly
      hmModule = import ./nixos/home-manager.nix {
        lib = basePkgs.lib;
        pkgs = basePkgs;
        config = {}; # Empty config - will be provided during evaluation
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in
      {
        packages = {
          default = pkgs.genshin-autoskip;
          genshin-autoskip = pkgs.genshin-autoskip;
        };

        devShells.default = pkgs.mkShell {
          name = "genshin-autoskip-dev";
          
          buildInputs = with pkgs; [
            python311
            uv
            pytest
            genshin-autoskip
          ];
          
          # Add runtime dependencies for development
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.libx11
            pkgs.glib
            pkgs.gtk3
            pkgs.cairo
            pkgs.pipewire
            pkgs.gst_all_1.gstreamer
            pkgs.gst_all_1.gst-plugins-base
            pkgs.gst_all_1.gst-plugins-good
            pkgs.gobject-introspection
          ];
          
          shellHook = ''
            export PATH="$PWD:$PATH"
            echo "Genshin Autoskip dev environment ready!"
            echo ""
            echo "Available commands:"
            echo "  genshin-autoskip          - Run the auto-skipper"
            echo "  uv run pytest              - Run tests"
            echo "  uv run genshin-autoskip --dry-run  - Test without key presses"
          '';
        };
      }
    ) // {
      overlays.default = final: prev: {
        genshin-autoskip = final.callPackage ./. { };
      };
      
      # NixOS module
      nixosModules.default = nixosModule;
      
      # Home-manager module
      homeManagerModules.default = hmModule;
    };
}
