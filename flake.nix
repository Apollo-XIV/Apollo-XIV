{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-gleam.url = "github:arnarg/nix-gleam";
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
    terranix.url = "github:terranix/terranix";
  };

  outputs = { self
  , nixpkgs
  , flake-utils
  , nix-gleam
  , terranix 
  , nixpkgs-terraform
  }: 
  flake-utils.lib.eachDefaultSystem(system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nix-gleam.overlays.default
        ];
      };

      terraform = nixpkgs-terraform.packages.${system}."1.9.5";

      terraformConfiguration = terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          ./nix/infra.nix
        ];
      };
    in {
      apps = {
        apply = {
          type = "app";
          program = toString (pkgs.writers.writeBash "apply" ''
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${terraformConfiguration} config.tf.json \
              && ${terraform}/bin/terraform init \
              && ${terraform}/bin/terraform apply
          '');
        };
        destroy = {
          type = "app";
          program = toString (pkgs.writers.writeBash "destroy" ''
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${terraformConfiguration} config.tf.json \
              && ${terraform}/bin/terraform init \
              && ${terraform}/bin/terraform destroy
          '');
          };
        };

      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            gleam
            direnv
            erlang_27
            nix-direnv
            terraform
            (pkgs.writeShellScriptBin "ask" ''
              ollama run mistral $1
            '')
            tailwindcss
            just
            nodePackages.prettier
          ];
        };
      };

      packages = {
        default = pkgs.buildGleamApplication {
          pname = "apollo_blog";
          version = "0.0.1";
          src = ./.;
        };
      };
    }
  );
}
