# SPDX-FileCopyrightText: 2024 Dusk Banks <me@bb010g.com>
# SPDX-License-Identifier: ISC
{ lib, ... }:
let
  inherit (builtins) mapAttrs;
in
rec {
  libOverlays.default =
    finalLib: prevLib:
    let
      libs = libOverlays.libs finalLib prevLib;
    in
    mapAttrs (libsName: libsValue: prevLib.${libsName} // libsValue) libs;
  libOverlays.libs =
    finalLib: prevLib:
    let
      finalArgs = {
        lib = finalLib;
      };
      prevArgs = {
        lib = prevLib;
      };
    in
    mapAttrs (libsName: libsOverlay: libsOverlay finalArgs prevArgs) libsOverlays;
  libs.default = lib.extend libOverlays.default;
  libsOverlays.filesystem = import ./by-name/fi/filesystem/libsOverlay.nix;
  libsOverlays.path = import ./by-name/pa/path/libsOverlay.nix;
  libsOverlays.strings = import ./by-name/st/strings/libsOverlay.nix;
  libsOverlays.trivial = import ./by-name/tr/trivial/libsOverlay.nix;
}
