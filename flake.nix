{
  description = "Listen iio-sensor-proxy and auto change Hyprland output orientation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # <https://github.com/nix-systems/nix-systems>
    systems.url = "github:nix-systems/default-linux";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      systems,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs (import systems);
      pkgsFor = eachSystem (
        system:
        import nixpkgs {
          localSystem = system;
          overlays = [ ];
        }
      );
    in
    {

      packages = eachSystem (system: {
        default = pkgsFor.${system}.callPackage ./default.nix { };
      });

      devShells = eachSystem (system: {
        default = pkgsFor.${system}.mkShell {

          nativeBuildInputs = with pkgsFor.${system}; [
            pkg-config
            dbus
            meson
            ninja
          ];
        };
      });
    };
}
