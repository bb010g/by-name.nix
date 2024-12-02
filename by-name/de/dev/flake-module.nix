# SPDX-FileCopyrightText: 2024 Dusk Banks <me@bb010g.com>
# SPDX-License-Identifier: ISC
{
  config,
  inputs,
  parentFlake,
  ...
}:
let
  inherit (parentFlake) outputs;
  lib = outputs.libs.default;
  libs.libs =
    let
      f = inputs.nixpkgs.lib.__unfix__;
      overlay = outputs.libOverlays.libs;
      prev = f final;
      new = overlay final prev;
      final = prev // new;
    in
    new;
in
{
  _file = ./flake.nix;
  imports = [
    inputs.git-hooks-nix.flakeModule
    inputs.treefmt-nix.flakeModule
  ];
  config.debug = true;
  config.flake = {
    _file = ./flake.nix;
    config = outputs // {
      inherit parentFlake lib;
      libsLib = config.flake.libs.libs;
      libs = outputs.libs // libs;
      examples.bb010g = lib.filesystem.readNameBasedTableDirectory {
        readRowsDirectory = lib.filesystem.readDirectory;
        rowsPath = /home/bb010g/Sources/Sysadmin/bb010g/nix/by-name;
        rowFromFile = {
          "byNameConfiguration.nix" =
            args@{ directoryEntry, ... }:
            {
              byNameConfiguration = import directoryEntry.path args;
            };
          "flakeModule.nix" =
            { directoryEntry, ... }:
            {
              flakeModule = directoryEntry.path;
            };
          "homeManagerModule.nix" =
            { directoryEntry, ... }:
            {
              homeManagerModule = directoryEntry.path;
            };
          "lib.nix" =
            { directoryEntry, ... }:
            {
              lib = directoryEntry.path;
            };
          "nixosModule.nix" =
            { directoryEntry, ... }:
            {
              nixosModule = directoryEntry.path;
            };
          "nixpkgsOverlay.nix" =
            { directoryEntry, ... }:
            {
              nixpkgsOverlay = directoryEntry.path;
            };
          "systemManagerModule.nix" =
            { directoryEntry, ... }:
            {
              systemManagerModule = directoryEntry.path;
            };
        };
      };
      examples.by-name = lib.filesystem.readNameBasedTableDirectory {
        rowsPath = ../..;
        rowFromFile = {
          "libsOverlay.nix" =
            { directoryEntry, ... }:
            {
              libsOverlay = import directoryEntry.path;
            };
          "flake.nix" =
            { directoryEntry, ... }:
            {
              flake = directoryEntry.path;
            };
          "flake.lock" =
            { directoryEntry, ... }:
            {
              flakeLock = directoryEntry.path;
            };
        };
        specialColumns.a.dev = 1;
        specialColumns.b.dev = 2;
        specialColumns.a.fancy = 10;
        specialColumns.b.fancy = 20;
      };
    };
  };
  config.perSystem =
    { config, pkgs, ... }:
    {
      config.devShells.default = pkgs.callPackage (
        {
          mkShellNoCC,
          reuse,
          ...
        }:
        mkShellNoCC {
          inputsFrom = [
            config.pre-commit.devShell
            config.treefmt.build.devShell
          ];
          nativeBuildInputs = [
            reuse
          ];
        }
      ) { };
      config.pre-commit.settings.hooks.eclint.enable = true;
      config.pre-commit.settings.hooks.reuse.enable = true;
      config.pre-commit.settings.hooks.treefmt.enable = true;
      config.pre-commit.settings.hooks.treefmt.packageOverrides.treefmt = config.treefmt.build.wrapper;
      config.pre-commit.settings.hooks.treefmt.settings.formatters = lib.attrValues config.treefmt.build.programs;
      config.treefmt.flakeCheck = lib.mkIf (
        config.pre-commit.check.enable && config.pre-commit.hooks.treefmt.enable
      ) false;
      config.treefmt.programs.deadnix.enable = true;
      config.treefmt.programs.deadnix.no-lambda-arg = true;
      config.treefmt.programs.deadnix.no-lambda-pattern-names = true;
      config.treefmt.programs.nixfmt.enable = true;
      config.treefmt.programs.statix.enable = true;
      config.treefmt.programs.statix.disabled-lints = [
        "deprecated_is_null"
      ];
      config.treefmt.projectRootFile = ".envrc";
    };
  config.systems = lib.systems.flakeExposed;
}
