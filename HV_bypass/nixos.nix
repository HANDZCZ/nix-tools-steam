flake: { config, lib, ... }:

let
  cfg = config.gaming.hv-bypass;
  kernel-pkgs = flake.mkKernelPackages config.boot.kernelPackages;
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

      patchKernel = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to patch User Mode Instruction Prevention (UMIP) dummy_limit in kernel source.
          This will rebuild the kernel!

          Only required for Intel 9th gen and newer, AMD Ryzen 3000 and newer and Steam Deck
        '';
      };

      kernelModule = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to enable kernel module for dynamic changing of UMIP SGDT/SIDT limit values.
            This will NOT require kernel rebuild.

            Only required for Intel 9th gen and newer, AMD Ryzen 3000 and newer and Steam Deck
          '';
        };

        package = mkOption {
          type = types.package;
          default = kernel-pkgs.hv-bypass.umip_sgdt_sidt_fix;
          description = ''
            The kernel module package to install.
            Automatically builds against your system's active kernel.
          '';
        };
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
        default = kernel-pkgs.hv-bypass.cpuid_fault_emulation;
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
    umip-patch = {
      name = "Adjust GDT limit emulation";
      patch = ./umip/x86-umip-Adjust-GDT-limit-emulation.patch;
    };
    cpuid_autoLoad = cfg.cpuid_fault_emulation.enable && cfg.cpuid_fault_emulation.autoLoad;
  in lib.mkIf cfg.enable {
    warnings = lib.optional (cfg.umip.disable && cfg.umip.patchKernel) ''
      Hypervisor bypass: umip.disabled and umip.patchKernel are both enabled
                         You are building UMIP patched kernel, that won't have UMIP enabled!
    ''
    ++ lib.optional (cfg.umip.disable && cfg.umip.kernelModule.enable) ''
      Hypervisor bypass: umip.disabled and umip.kernelModule.enable are both enabled
                         You are building UMIP kernelModule, that won't get used, because UMIP is disabled!
    ''
    ++ lib.optional (cfg.umip.patchKernel && cfg.umip.kernelModule.enable) ''
      Hypervisor bypass: umip.patchKernel and umip.kernelModule.enable are both enabled
                         You are building UMIP kernelModule and UMIP patched kernel, only one of these is needed!
    '';

    boot.kernelParams = lib.mkIf cfg.umip.disable [ "clearcpuid=umip" ];
    boot.kernelPatches = lib.mkIf cfg.umip.patchKernel [ umip-patch ];

    boot.extraModulePackages =
      lib.optionals cfg.cpuid_fault_emulation.enable [ cfg.cpuid_fault_emulation.package ]
      ++ lib.optionals cfg.umip.kernelModule.enable [ cfg.umip.kernelModule.package ];

    boot.kernelModules =
      lib.optionals cpuid_autoLoad [ "cpuid_fault_emulation" ]
      ++ lib.optionals cfg.umip.kernelModule.enable [ "umip_sgdt_sidt_fix" ];

    boot.blacklistedKernelModules = lib.mkIf cpuid_autoLoad [ "kvm" "kvm-amd" ];
  };
}

