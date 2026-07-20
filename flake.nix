{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    umip-kmod = {
      url = "github:HANDZCZ/umip-kmod";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs: flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      perSystem = { self', pkgs, lib, system, ... }: {
        packages = lib.zipAttrsWith (_: vals: lib.head vals) (lib.attrValues (import ./packages.nix { inherit pkgs; }))
          // inputs.umip-kmod.packages.${system};
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
          }
            // inputs.umip-kmod.mkKernelPackages linuxPackages;
        };

        nixosModules = {
          hv-bypass = import ./HV_bypass/nixos.nix self;
        };

        nixosConfigurations = let
          mkHost = module: inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ({ lib, ... }: {
                services.xserver.xkb.layout = "cz";
                console = {
                  font = "Lat2-Terminus16";
                  useXkbConfig = lib.mkDefault true;
                };

                users.users.nix = {
                  isNormalUser = true;
                  initialPassword = "nix";
                  extraGroups = [ "wheel" ];
                };

                system.stateVersion = lib.trivial.release;
              })
              module
            ];
          };
        in {
          test-hv-bypass = mkHost ({ pkgs, ... }: {
            imports = [
              self.nixosModules.hv-bypass
            ];

            boot.kernelPackages = pkgs.linuxPackages_latest;
            environment.systemPackages = [
              self.packages.${pkgs.stdenv.hostPlatform.system}.test_umip
            ];

            gaming.hv-bypass = {
              enable = true;

              umip = {
                #disable = true;
                #patchKernel = true;
                kernelModule.enable = true;
              };

              cpuid_fault_emulation = {
                enable = true;
                #autoLoad = true;
              };
            };
          });
        };
      };
    };
}
