{
  description = "nixos-sbfde-demo";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-sbfde = {
      url = "github:andsens/nixos-sbfde";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lanzaboote.follows = "lanzaboote";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }:
    {
      nixosConfigurations = {
        "4U" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit (self) inputs; };
          modules = [
            ./configuration.nix
            { networking.hostName = "4U"; }
          ];
        };
        installer = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit (self) inputs; };
          modules = [
            ./installer-configuration.nix
            { networking.hostName = "installer"; }
          ];
        };
      };
    };
}
