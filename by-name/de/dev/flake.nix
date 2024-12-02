# SPDX-FileCopyrightText: 2024 Dusk Banks <me@bb010g.com>
# SPDX-License-Identifier: ISC
{
  description = "Development flake for by-name.nix";

  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.getFlake.url = "github:ursi/get-flake";
  inputs.git-hooks-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
  inputs.git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.git-hooks-nix.url = "github:cachix/git-hooks.nix";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  outputs =
    inputs:
    let
      parentFlake = inputs.getFlake ../../..;
      devInputs = parentFlake.inputs // { by-name = parentFlake; } // inputs;
    in
    inputs.flake-parts.lib.mkFlake {
      inputs = devInputs;
      specialArgs = { inherit parentFlake; };
    } ./flake-module.nix;
}
