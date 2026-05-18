{
  description = "Blueprints Development Environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nil.url = "github:oxalica/nil/c8e8ce72442a164d89d3fdeaae0bcc405f8c015a";

  inputs.nil.flake = true;

  inputs.achitek-ls.url = "github:achitek-org/achitek-ls/a914000a61e46c39bf2a9fdadea411440fd55b52";

  inputs.achitek-ls.flake = true;

  outputs =
    {
      self,
      nil,
      achitek-ls,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        achitek-lsp-server = achitek-ls.packages.${system}.default;
        nix-lsp-server = nil.packages.${system}.nil;
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            buildInputs = [
              achitek-lsp-server
              nix-lsp-server
            ];
          };
      }
    );
}
