{
  description = "flake app that manages formatters for you";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # For debugging: https://github.com/NixOS/nixpkgs/blob/master/lib/debug.nix
  # * `trace`-like functions take two values, print the first to stderr and return the second.
  # * `traceVal`-like functions take one argument which both printed and returned.
  # * `traceSeq`-like functions fully evaluate their traced value before printing (not just to “weak head normal form” like trace does by default).
  # * Functions that end in `-Fn` take an additional function as their first argument, which is applied to the traced value before it is printed.

  # builtins.trace
  # nixpkgs.lib.debug.traceVal 

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        # "x86_64-darwin"
      ];
      pname = "fmtapp";
      # Small tool to iterate over each systems
      eachSystem = fn: nixpkgs.lib.genAttrs systems (sys: fn nixpkgs.legacyPackages.${sys});
      # out: {linux: fn(nixpkgs), ...}
      
      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (ps: inputs.treefmt-nix.lib.evalModule ps ./treefmt.nix);

    in
    # out: {linux: evalModule(nixpkgs, config), ...}
    rec {
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      pythonVenv = eachSystem (pkgs: pkgs.python3.withPackages (ps: [ ps.typer ps.click ps.sh ]));

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell { packages = [ 
          pythonVenv.${pkgs.system}
    pkgs.curl
    pkgs.jq
  ];
        };
      });

      packages = eachSystem (pkgs: {
        default = pkgs.writeShellApplication {
          name = "${pname}";
          runtimeInputs = with pkgs; [
            nodePackages.prettier
            ruff
            nixfmt-rfc-style
          ];
          text = ''
            echo "prettier ''$(prettier --version)"
            ruff --version
            nixfmt --version
          '';
        };
      });

      apps = eachSystem (pkgs: {
        pname = {
          type = "app";
          program = "${self.packages.${pkgs.system}.default}/bin/${pname}";
        };
      });
    };
}
