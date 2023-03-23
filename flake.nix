{
  description = "Nix packaging for rrule_nim";
  inputs.nixpkgs.url = github:nixos/nixpkgs?ref=nixos-22.11;

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

    devShell = genSystems (system:
      pkgs.${system}.mkShell {
        packages = with pkgs.${system}; [
          nimlsp
          nim
        ];
      });
  };
}
