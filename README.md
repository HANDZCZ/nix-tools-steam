
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

## How to install/enable hypervisor bypass

For hypervisor bypass, you need:
1. UMIP (User Mode Instruction Prevention) to return the right values
1. support for CPUID Faulting
1. modified proton build

> In some games, you will need to replace `reflex.dll`, and some games won't even run until the bypass gets updated.

UMIP support is achieved in multiple ways, and you should only **choose one**.
- disable kernel's UMIP
- patch the kernel
- use a kernel module (recommended)

For cpus that don't support CPUID Faulting, you will need to enable the cpuid_fault_emulation kernel module.
For this kernel module, you can also choose to load it on boot,
but if you choose to do so, you won't have hardware virtualisation!

Example config:
```nix
imports = [
  inputs.nix-tools-steam.nixosModules.hv-bypass
];

gaming.hv-bypass = {
  enable = true;
  umip.kernelModule.enable = true;
  cpuid_fault_emulation.enable = true;
};
```

If you read all this (maybe even copied the example) and don't understand what you are supposed to do/enable/use,
then please read the descriptions on the options in `hv-bypass` NixOS module for more info.
If even then you still have no idea what to do, please read up on how hypervisor bypass works on Linux, what you need, and when!

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

