{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-sbfde.nixosModules.secureboot
    inputs.nixos-sbfde.nixosModules.full-disk-encryption
  ];
  config = {
    system.stateVersion = "25.11";
    time.timeZone = "Europe/Copenhagen";

    networking.useDHCP = lib.mkDefault true;
    services.avahi.allowInterfaces = [ "enp6s0" ];
    nixpkgs.hostPlatform = "x86_64-linux";

    sbfde.secureboot.enable = true;
    sbfde.full-disk-encryption.enable = true;
    sbfde.full-disk-encryption.enrollEmptyKey = true;
    boot = {
      initrd.availableKernelModules = [
        "ahci"
        "xhci_pci"
        "usbhid"
        "sd_mod"
      ];
      initrd.kernelModules = [ ];
      kernelModules = [ "kvm-amd" ];
      loader.timeout = 0;
      initrd.systemd = {
        enable = true;
      };
    };
    fileSystems."/boot" = {
      label = "ESP";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    services = {
      displayManager = {
        gdm.enable = false;
        cosmic-greeter.enable = true;
      };
      desktopManager.cosmic.enable = true;
    };
    # Unlocks gnome keyring when logged in.
    security.pam.services.gdm.enableGnomeKeyring = lib.mkDefault true;

    nix = {
      registry.nixpkgs.flake = inputs.nixpkgs;
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      users.nixos.imports = [
        {
          home.stateVersion = "25.11";
          home.packages = [ pkgs.sbctl ];
        }
      ];
    };
    security.polkit.enable = true;
    security.sudo.enable = true;
    users = {
      mutableUsers = false;
      allowNoPasswordLogin = true;
      users.nixos = {
        isNormalUser = true;
        shell = pkgs.bash;
        hashedPasswordFile = "/etc/secrets.d/nixos.pwhash";
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };
    };
  };
}
