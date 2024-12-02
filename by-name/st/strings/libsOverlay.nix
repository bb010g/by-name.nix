# SPDX-FileCopyrightText: 2024 Dusk Banks <me@bb010g.com>
# SPDX-License-Identifier: ISC
finalArgs: prevArgs:

let
  lib.strings.toString = prevStrings.toString or builtins.toString;

  prevStrings = prevLib.strings;
  prevLib = prevArgs.lib;
in
lib.strings
