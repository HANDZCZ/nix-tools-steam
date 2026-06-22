
# Tools for Steam games

This repository provides [gbe_fork_tools](https://github.com/Detanup01/gbe_fork_tools) for Goldberg emulator (specifically [gbe_fork](https://github.com/Detanup01/gbe_fork)),
repackaged accela from AppImage and [SLSsteam](https://github.com/AceSLS/SLSsteam) 32bit libs.

It also provides dev shell containing gbe_tools and accela, with or without bubblewrap for sandboxing.

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

