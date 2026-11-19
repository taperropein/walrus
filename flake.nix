{
  description = "WebAssembly Lightweight RUntime (Samsung)";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    # https://discourse.nixos.org/t/get-nix-flake-to-include-git-submodule/30324/23
    # needed for vendored GCUtil among others
    self.submodules = true;
  };

  outputs = { self, nixpkgs, ...}@inputs :
  let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forEachSupportedSystem =
      f:
      inputs.nixpkgs.lib.genAttrs supportedSystems (
        system:
        f {
          inherit system;
          pkgs = import nixpkgs { inherit system; };
        }
      );
  in
  {
    packages = forEachSupportedSystem (
      { pkgs, system } :
      {
        default = pkgs.clangStdenv.mkDerivation {
          name = "walrus";
          src = ./.;
          buildInputs = with pkgs; [
            cmake
            pkgconf
            libuv
          ];
        };
      }
    );
  };
}
