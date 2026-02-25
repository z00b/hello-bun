{
  description = "A simple Hello, Bun! application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = self.packages.${system}.hellbun;

          hellbun = pkgs.callPackage ./pkgs/hellbun { };
        };

        apps = {
          default = self.apps.${system}.hellbun;

          hellbun = {
            type = "app";
            program = "${self.packages.${system}.hellbun}/bin/hellbun";
          };
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = [ self.packages.${system}.hellbun ];
        };
      }
    );
}
