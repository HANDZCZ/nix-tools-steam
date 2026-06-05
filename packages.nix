{ pkgs }:

{
  accela = pkgs.callPackage ./accela/package.nix {};
  gbe_tools = pkgs.callPackage ./gbe_tools/package.nix {};
}

