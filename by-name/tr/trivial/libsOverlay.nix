# SPDX-FileCopyrightText: 2024 Dusk Banks <me@bb010g.com>
# SPDX-License-Identifier: ISC
finalArgs: prevArgs:

let
  lib.trivial.isNull = prevTrivial.isNull or builtins.isNull;

  prevTrivial = prevLib.trivial;
  prevLib = prevArgs.lib;
in
lib.trivial
