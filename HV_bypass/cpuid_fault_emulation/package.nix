{
  stdenv,
  lib,
  pkgs,
  fetchurl,
  kernelPackages ? pkgs.linuxPackages_latest,
  kernel ? kernelPackages.kernel,
  kernelModuleMakeFlags ? kernelPackages.kernelModuleMakeFlags,
  unzip,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpuid_fault_emulation";
  version = "2026-07-16";

  src = fetchurl {
    url = "https://github.com/HANDZCZ/nix-tools-steam/releases/download/cpuid_fault_emulation-${finalAttrs.version}/cpuid_fault_emulation.zip";
    hash = "sha256-3MRw+VtYV2m8x335y46K8O5hgJ592RyDyYJpJ3GHDbo=";
  };
  sourceRoot = "./";

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [
    unzip
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '/lib/modules/$(KERNEL)/build' '$(KERNEL_DIR)' \
      --replace-fail '$(LLVM) ' ""
  '';

  buildFlags = [
    "KERNEL=${kernel.modDirVersion}"
  ];

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  installPhase = ''
    runHook preInstall

    install -D cpuid_fault_emulation.ko -t $out/lib/modules/${kernel.modDirVersion}/misc/

    runHook postInstall
  '';

  meta = {
    description = "CPUID Fault Emulation kernel module";
    platforms = lib.platforms.linux;
  };
})

