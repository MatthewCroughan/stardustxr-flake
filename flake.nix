{
  inputs = {
    wlxmirror-nixpkgs.url = "github:matthewcroughan/nixpkgs/mc/wlxmirror";
    manifold = {
      url = "github:matthewcroughan/manifold/mc/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    server = {
      url = "github:StardustXR/server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flatland = {
      url = "github:StardustXR/flatland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    azimuth = {
      url = "github:stardustxr/azimuth/mc/nixify";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    eclipse = {
      url = "github:stardustxr/eclipse/mc/nixify";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, flatland, server, azimuth, eclipse, nixpkgs, manifold, wlxmirror-nixpkgs, ... }:
  let
    pkgsOriginal = nixpkgs.legacyPackages.x86_64-linux;
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = nixpkgs.lib.singleton (final: prev: {
        openxr-loader = final.callPackage ./openxr-loader.nix { };
        monado = prev.monado.overrideAttrs (_: {
          setupHook = prev.writeText "setup-hook" ''
            export XDG_CONFIG_DIRS=@out@/share''${XDG_CONFIG_DIRS:+:''${XDG_CONFIG_DIRS}}
          '';
          postFixup = ''
            ln -s $out/share/openxr/1/openxr_monado.json $out/share/openxr/1/active_runtime.json
          '';
          src = prev.fetchgit {
            rev = "715bbd7b218f88fc45f47adae08412bf7f165fb0";
            url = "https://gitlab.freedesktop.org/monado/monado.git";
            sha256 = "sha256-A0PXrFlYEqYHk2h4N8dAAtx32TWS+2WvPJz4rDnOito=";
          };
        });
      });
    };
  in
  {
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [
        manifold.packages.x86_64-linux.default
        (server.packages.x86_64-linux.default.overrideAttrs (old: {
          buildInputs = (builtins.filter (x: x != pkgsOriginal.openxr-loader) old.buildInputs) ++ [pkgs.openxr-loader ];
        }))
        (flatland.packages.x86_64-linux.default.overrideAttrs (old: {
          prePatch = ''
            substituteInPlace src/surface.rs --replace \
              'pub const PPM: f32 = 3000.0;' 'pub const PPM: f32 = 5000.0;'
          '';
        }))
        eclipse.packages.x86_64-linux.default
        azimuth.packages.x86_64-linux.default
        wlxmirror-nixpkgs.legacyPackages.x86_64-linux.wlxmirror
        (pkgs.monado.override { stdenv = pkgs.withCFlags [ "-O3" ] pkgs.stdenv; })
      ];
    };
  };
}
