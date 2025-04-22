{
  description = "The flake that is used build the typst document.";


  inputs = {
    
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    flake-utils.url = "github:numtide/flake-utils";
    
    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    font-awesome = {
      url = "github:FortAwesome/Font-Awesome";
      flake = false;
    };
  };


  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system:
    let

      pkgs = import nixpkgs { inherit system; };
      lib = nixpkgs.lib;
      typixLib = typix.lib.${system};

      src = ./src;

      commonArgs = {
        typstSource = "main.typ";
        fontPaths = [ ];
        virtualPaths = [ ];
      };

      unstable_typstPackages = [
        {
          name = "charged-ieee";
          version = "0.1.3";
          hash = "sha256-tfGeuggtRY74VBS4csaYrRF3mIhI2p+68YkJXLVdRNU=";
        }
      ];

      build-drv = typixLib.buildTypstProject (commonArgs // { inherit src unstable_typstPackages; });

      build-script = typixLib.buildTypstProjectLocal (commonArgs // { inherit src unstable_typstPackages; });

      watch-script = typixLib.watchTypstProject commonArgs;

    in rec {


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Flake Check ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #


      checks = self.packages.${system};


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Build ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #


      packages.default = build-drv;


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Run ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #


      apps = rec {
        default = watch;
        build = flake-utils.lib.mkApp { drv = build-script; };
        watch = flake-utils.lib.mkApp { drv = watch-script; };
      };


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Develop ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #


      devShells = { 
        default = typixLib.devShell {
          inherit (commonArgs) fontPaths virtualPaths;
          packages = [ watch-script pkgs.typstfmt ];
        };
      };
      

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    }
  );
}