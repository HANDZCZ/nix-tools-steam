{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = {
    flake-parts,
    ...
  } @ inputs: flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      perSystem = { self', pkgs, lib, ... }: {
        packages = lib.zipAttrsWith (_: vals: lib.head vals) (lib.attrValues (import ./packages.nix { inherit pkgs; }));
        devShells = {
          bwrap = import ./shell.nix { inherit pkgs; use-bwrap = true; };
          no-bwrap = import ./shell.nix { inherit pkgs; use-bwrap = false; };
          default = self'.devShells.bwrap;
        };
      };
      flake = {
        mkKernelPackages = linuxPackages: {
          hv-bypass = {
            cpuid_fault_emulation = linuxPackages.callPackage ./HV_bypass/cpuid_fault_emulation/package.nix {};
          };
        };
      };
    };
}
