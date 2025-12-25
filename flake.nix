{
  description = "A customizable Quickshell bar flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quickshell.url = "git+https://git.outfoxxed.me/quickshell/quickshell";
  };

  outputs = { self, nixpkgs, quickshell, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.writeShellScriptBin "my-bar" ''
        ${quickshell.packages.${system}.quickshell}/bin/quickshell -p ${./shell.qml} "$@"
      '';

      homeManagerModules.default = import ./module.nix { inherit self; };
    };
}
