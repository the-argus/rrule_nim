{
  nimPackages,
  nimRelease ? true,
  ...
}: let
  nimFlags = [
    "--threads:on"
  ];
in
  nimPackages.buildNimPackage rec {
    pname = "rrule_nim";
    version = "0.0.1";
    src = ./.;

    nimBinOnly = false;
    nimbleFile = ./rrule.nimble;
    inherit nimRelease nimFlags;

    propagatedBuildInputs = with nimPackages; [regex];
    buildInputs = propagatedBuildInputs;
  }
