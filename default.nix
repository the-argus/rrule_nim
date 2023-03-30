{
  nimPackages,
  nimRelease ? true,
  fetchFromGitHub,
  ...
}: let
  nimFlags = [
    "--threads:on"
    # "-Ddatetime_parse"
  ];
in
  nimPackages.buildNimPackage rec {
    pname = "rrule_nim";
    version = "0.0.1";
    src = ./.;

    nimBinOnly = false;
    nimbleFile = ./rrule.nimble;
    inherit nimRelease nimFlags;

    propagatedBuildInputs = with nimPackages; [
      regex
      (nimPackages.buildNimPackage rec {
        pname = "datetime_parse";
        version = "0.1.0";
        src = fetchFromGitHub {
          owner = "bung87";
          repo = "datetime_parse";
          rev = "2ce54c35e43a165db056ec0135d4f416cb823ccb";
          sha256 = "";
        };
        nimbleFile = "${src}/datetime_parse.nimble";
        nimBinOnly = false;
        nimRelease = true;
      })
      (nimPackages.buildNimPackage rec {
        pname = "rfc3339";
        version = "0.1.1";
        src = fetchFromGitHub {
          owner = "Skrylar";
          repo = "rfc3339";
          rev = "bc89d93f4072c6b6cb692381734d66a9f1f1b82c";
          sha256 = "";
        };
        nimbleFile = "${src}/rfc3339.nimble";
        nimBinOnly = false;
        nimRelease = true;
      })
    ];
    buildInputs = propagatedBuildInputs;
  }
