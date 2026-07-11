
# Tools for Steam games

This repository provides multiple packages for working with steam and steam games.
Such as [gbe_fork_tools](https://github.com/Detanup01/gbe_fork_tools) for Goldberg emulator (specifically [gbe_fork](https://github.com/Detanup01/gbe_fork)),
repackaged accela from AppImage,
[SLSsteam](https://github.com/AceSLS/SLSsteam) 32bit libs
and [SamRewritten](https://github.com/PaulCombal/SamRewritten) (achievements manager).

It also provides dev shell containing gbe_tools, accela and SamRewritten, with or without bubblewrap for sandboxing.

```bash
nix develop github:HANDZCZ/nix-tools-steam#no-bwrap
```

If you want to install the packages on your system instead of using a dev shell, you will need to add your own sandboxing, if you want it.

## Flake install

```nix
nix-tools-steam = {
  url = "github:HANDZCZ/nix-tools-steam";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

If some package stops working, try removing nixpkgs override.

## How to install SLSsteam

To install SLSsteam you just need to override steam package and add `LD_AUDIT="/PATH_TO_PKG/library-inject.so:/PATH_TO_PKG/SLSsteam.so"` environmental variable.

Something like this:
```nix
programs.steam.package = let
  sls-steam = inputs.nix-tools-steam.packages.${pkgs.stdenv.hostPlatform.system}.sls-steam;
in pkgs.steam.override {
  extraEnv.LD_AUDIT = "${sls-steam}/lib/library-inject.so:${sls-steam}/lib/SLSsteam.so";
};
```

## How to install other packages

You just need to add the package to either `environment.systemPackages` or `home.packages`,
but not both, that could cause problems.

Example usage:
```nix
environment.systemPackages = let
  nix-tools-steam_packages = inputs.nix-tools-steam.packages.${pkgs.stdenv.hostPlatform.system};
in [
  nix-tools-steam_packages.accela
  nix-tools-steam_packages.gbe_tools
  nix-tools-steam_packages.samrewritten
];
```

