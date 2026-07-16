{ config, lib, ... }:

let
  cfg = config.gaming.hv-bypass;
  kernelPackages = config.boot.kernelPackages;
in {
  options.gaming.hv-bypass = with lib; {
    enable = mkEnableOption "hypervisor bypass";

    umip = {
      disable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to add User Mode Instruction Prevention (UMIP) to blacklisted kernel modules (disable it).

          Only required for Intel 9th gen and newer, AMD Ryzen 3000 and newer and Steam Deck
        '';
      };
    };

    cpuid_fault_emulation = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable cpuid_fault_emulation kernel module.

          Only required for AMD Ryzen on AM4 (older than 7000) and Steam Deck
        '';
      };

      package = mkOption {
        type = types.package;
        default = kernelPackages.callPackage ./cpuid_fault_emulation/package.nix {};
        defaultText = literalExpression "config.boot.kernelPackages.callPackage /path/to/package.nix {}";
        description = ''
          The kernel module package to install.
          Automatically builds against your system's active kernel.
        '';
      };

      autoLoad = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to automatically load the module at boot time.

          CAUTION: this will blacklist the kvm and kvm-amd module and you won't be able to use hardware virtualisation!
        '';
      };
    };
  };

  config = let
    cpuid_autoLoad = cfg.cpuid_fault_emulation.enable && cfg.cpuid_fault_emulation.autoLoad;
  in lib.mkIf cfg.enable {
    boot.kernelParams = lib.mkIf cfg.umip.disable [ "clearcpuid=umip" ];

    boot.extraModulePackages =
      lib.optionals cfg.cpuid_fault_emulation.enable [ cfg.cpuid_fault_emulation.package ];

    boot.kernelModules =
      lib.optionals cpuid_autoLoad [ "cpuid_fault_emulation" ];

    boot.blacklistedKernelModules = lib.mkIf cpuid_autoLoad [ "kvm" "kvm-amd" ];
  };
}

