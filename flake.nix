{
  description = "nix-patcher is a tool for patching Nix flake inputs, semi-automatically.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.patch2pr.url = "github:phanirithvij/patch2pr/use-git";
  inputs.patch2pr.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, patch2pr }:
    let
      systems = nixpkgs.legacyPackages.x86_64-linux.go.meta.platforms;
      lib = nixpkgs.lib;
    in
    {
      packages = lib.genAttrs systems (sys: 
        let 
          pkgs = nixpkgs.legacyPackages.${sys};
        in
        {
          nix-patcher = pkgs.callPackage ./patcher.nix {
            nix = pkgs.nixVersions.latest;
            patch2pr = patch2pr.packages.${sys}.default;
          };
        }
      );

      apps = lib.genAttrs systems (sys: 
        let selfpkgs = self.packages.${sys};
        in {
          default.type = "app";
          default.program = lib.getExe selfpkgs.nix-patcher;
        }
      );
    };
}
