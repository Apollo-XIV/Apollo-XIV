---
title = "Going Insane with NixOS and Terraform"
abstract = "A (somewhat) brief overview of my descent into madness and reproducability, using NixOS, Terraform, and Kubernetes."
date = "13/10/24"
---
_**A (somewhat) brief overview of my descent into madness and reproducability, using NixOS, Terraform, and Kubernetes.**_


I've recently been doing a DevOps Engineering Apprenticeship, which has really immersed me in the tooling: *Docker,* *Kubernetes,* *Terraform,* and others. As I became interested in more and more of the niches therein, I eventually stumbled upon the Nix package manager. A commonality I saw between Terraform - my most used tool - and Nix was Immutable Infrastructure. 


> **IMMUTABLE INFRASTRUCTURE**
> 
> Immutable Infrastrucute is best simplified as the mindset of *'cattle not pets',* as in, rather than maintaining long-term infrastructure that can drift out of sync or change over time and become unpredictable, create and destroy your infrastructure regularly as part of your build process. Theres a lot more to this idea, but that's the gist of it. [This Hashicorp video is good further reading if you're interested](https://www.hashicorp.com/resources/what-is-mutable-vs-immutable-infrastructure)


Nix and Terraform both have reproducability as their end-goal, but focus on different scales; Nix is all about system management, enabling you to concretely establish the dependencies and state of a server's environment. Terraform, on the other hand, works best at the cloud-resource level, and struggles more the lower you go[^1]. The solution here is the Nix module [Terranix](https://terranix.org/)


This module allows you to write Terraform using the Nix language, meaning you can take advantage of Nix's other features like input tracking, modules, and it also gives you a level of higher level programmability - much like Terragrunt would. The main way I've implemented this is as part of my `flake.nix`. A blank flake file can be seen below.


```nix
{
  inputs = {
    nixpkgs.url = "";
    flake-utils.url = "";
    nixpkgs-terraform.url = "";
    terranix.url = "";
  };

  outputs = {nixpkgs, flake-utils, nixpkgs-terraform, terranix}:
  flake-utils.lib.eachDefaultSystem(system:
  let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
      ];
    }

    terraform = nixpkgs-terraform.packages.${system}."1.9.5";

    terraform_wrapper = pkgs.writeShellScriptBin "terraform" ''
      if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
      cp ${terraformConfiguration} config.tf.json \
        && ${terraform}/bin/terraform "$@"\
    '';

    terraformConfiguration = terranix.lib.terranixConfiguration {
      inherit system;
      modules = [
        ./infra.nix
      ];
    };
  in
  {
    devShells.default = pkgs.mkShell {
      packages = [
        terraform_wrapper
      ];
    }
  })
}
```


[1](): Aside from this, I have gripes with the lack of extensibility available in HCL. I've spent a large amount of time looking at other tools because of how much I dislike the syntax.

