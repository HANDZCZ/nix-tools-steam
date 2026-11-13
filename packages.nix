{ pkgs }:

{
  apps = {
    accela = pkgs.callPackage ./accela/package.nix {};
    gbe_tools = pkgs.callPackage ./gbe_tools/package.nix { python3 = pkgs.python313; };
    samrewritten = pkgs.callPackage ./SamRewritten/package.nix {};
  };
  pkgs = {
    steam-solsticegamestudios = pkgs.callPackage ./steam/package-solsticegamestudios.nix {};
    sls-steam = pkgs.callPackage ./SLSsteam/package.nix {};
    steamnetsock-patch = pkgs.callPackage ./SLSsteam/steamnetsock-patch.nix {};
  };
}

