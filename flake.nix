# SPDX-FileCopyrightText: 2024 Dusk Banks <me@bb010g.com>
# SPDX-License-Identifier: ISC
{
  description = "Nix library for name-based, tabular directories";

  inputs.nixpkgs.url = "github:nix-community/nixpkgs.lib";

  outputs = inputs: import ./default.nix { inherit (inputs.nixpkgs) lib; };
}
