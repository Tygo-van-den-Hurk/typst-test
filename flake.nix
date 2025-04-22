{
  description = "The flake that is used build the typst document.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system:
    let

      pkgs = import nixpkgs { inherit system; };
      lib = nixpkgs.lib;

    in rec {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Flake Check ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

      checks = self.packages.${system};

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Develop ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

      devShell = pkgs.mkShell {
        
        buildInputs = ( with pkgs; [ typst act ] );

        shellHook = (''
          # if the terminal supports color.
          if [[ -n "$(tput colors)" && "$(tput colors)" -gt 2 ]]; then
            export PS1="(\033[1m\033[35mDev-Shell\033[0m) $PS1"
          else 
            export PS1="(Dev-Shell) $PS1"
          fi
          
          unset shellHook
          unset buildInputs
          ''
        );
      };

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Build ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

      packages.default = pkgs.stdenv.mkDerivation rec {
        name = "document";
        src = ./src;

        buildPhase = ''
          runHook preBuild 

          ${pkgs.typst}/bin/typst compile
          
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir --parents $out
          cp --recursive output/* $out
          
          runHook postInstall
        '';
      };
      
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    }
  );
}