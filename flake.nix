{
  description = "ripasso";

  inputs = {
    ripassoSors = {
      url = file:///git/github.com/cortex/ripasso;
      type = "git";
      ref = "cargoNix";
      flake = false;
    };
  };

  outputs = fleiks @{ self, ripassoSors }:
  {
    datom = { sobUyrld = {
      legysiUyrld = true;

      lamdy = {
        kor, stdenv, mkCargoNix, gpgme, libgpgerror, pkgconfig,
        xorg, openssl, ncurses,
      }:
      let
        crateOverrides = {
          libgpg-error-sys = attrs: {
            LIBGPG_ERROR_CONFIG = libgpgerror.dev + /bin/gpg-error-config;
            buildInputs = [ libgpgerror.dev ];
            postInstall = ''
              mkdir -p $out/share
              cp ./{err-sources.h.in,err-codes.h.in,errnos.in} $out/share/
            '';
          };
          gpg-error = attrs: {
            DEP_GPG_ERROR_GENERATED = libgpg-error-sys + /share;
            buildInputs = [ libgpgerror.dev ];
            patchPhase = '' chmod -R a+r ./ '';
          };
          gpgme-sys = attrs: {
            GPGME_CONFIG = gpgme.dev + "/bin/gpgme-config";
            buildInputs = [ gpgme.dev ];
          };
          ripasso-cursive = attrs: {
            nativeBuildInputs = [ pkgconfig ];
            buildInputs = [
              ncurses openssl xorg.libxcb
            ];
          };
        };

        cargoNix = mkCargoNix {
          nightly = true;
          cargoNixPath = ripassoSors + /Cargo.nix;
          inherit crateOverrides;
        };

        libgpg-error-sys = cargoNix.internal.buildRustCrateWithFeatures {
          packageId = "libgpg-error-sys";
        };

        cursive = cargoNix.workspaceMembers.ripasso-cursive.build;
        gtk = cargoNix.workspaceMembers.ripasso-gtk.build;
        qt = cargoNix.workspaceMembers.ripasso-qt.build;

      in {
        inherit cursive qt gtk;
      };

    }; };

  };
}
