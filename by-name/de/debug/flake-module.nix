# SPDX-FileCopyrightText: 2024 Dusk Banks <me@bb010g.com>
# SPDX-License-Identifier: ISC
flakeModuleArgs@{
  config,
  flake-parts-lib,
  lib,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkForce;
  inherit (lib.strings) escapeNixIdentifier;
  inherit (lib.trivial) warn;
  _file = ./flake-module.nix;
in
{
  inherit _file;
  options.perSystem = mkPerSystemOption (
    perSystemFlakeModuleArgs@{ system, ... }:
    {
      inherit _file;
      config.debug = lib.mkForce (
        if config.debug then
          perSystemFlakeModuleArgs // perSystemFlakeModuleArgs.config._module.args
        else
          warn
            "flake-parts: {option}`config.allSystems.${escapeNixIdentifier (toString system)}.debug` forced when {option}`config.debug` is false"
            { }
      );
    }
  );
  config = mkIf config.debug {
    flake = {
      inherit _file;
      config.debug = lib.mkForce (flakeModuleArgs // flakeModuleArgs.config._module.args);
    };
  };
}
