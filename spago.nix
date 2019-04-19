{ pkgs ? import <nixpkgs> {} }:
let

  patchelf = libPath :
    if pkgs.stdenv.isDarwin
      then ""
      else
        ''
          chmod u+w $SPAGO
          patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath ${libPath} $SPAGO
          chmod u-w $SPAGO
        '';
in

  pkgs.stdenv.mkDerivation rec {
    name = "spago";
    version = "0.7.5.0";

    src =
      if pkgs.stdenv.isDarwin
      then pkgs.fetchurl {
        url = "https://github.com/spacchetti/spago/releases/download/0.7.5.0/osx.tar.gz";
        sha256 = "194q089c1rl5724vqhrrk0jy7fb73gcb29sp74lb2q6pqwmdk5dp";
      }
      else pkgs.fetchurl {
        url = "https://github.com/spacchetti/spago/releases/download/0.7.5.0/linux.tar.gz";
        sha256 = "0dcag75md2bp626ji4k9d3psgdxzrvhl2wyw8np7i99ahjg87jmn";
      };

    buildInputs = [
      pkgs.gmp
      pkgs.zlib
      pkgs.ncurses5
      pkgs.stdenv.cc.cc.lib
    ];
    libPath = pkgs.lib.makeLibraryPath buildInputs;
    dontStrip = true;

    unpackPhase = ''
      mkdir -p $out/bin
      tar xf $src -C $out/bin

      SPAGO=$out/bin/spago
      ${patchelf libPath}


      mkdir -p $out/etc/bash_completion.d/
      $SPAGO --bash-completion-script $SPAGO > $out/etc/bash_completion.d/spago-completion.bash
    '';

    dontInstall = true;
  }
