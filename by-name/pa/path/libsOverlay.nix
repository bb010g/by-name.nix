# SPDX-FileCopyrightText: 2024 Dusk Banks <me@bb010g.com>
# SPDX-License-Identifier: ISC
finalArgs: prevArgs:

let
  lib.path.baseNameOf = prevPath.baseNameOf or builtins.baseNameOf;

  lib.path.dirOf = prevPath.dirOf or builtins.dirOf;

  prevPath = prevLib.path;
  prevLib = prevArgs.lib;
in
lib.path
