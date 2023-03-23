{
  description = "Nix packaging for rrule_nim";
  inputs.nixpkgs.url = github:nixos/nixpkgs?ref=nixos-unstable;

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs =
      genSystems (system:
        import nixpkgs {inherit system;});
  in {
    packages = genSystems (system: {
      rrule_nim = pkgs.${system}.callPackage ./. {};
      default = self.packages.${system}.rrule_nim;
    });
  };
}
