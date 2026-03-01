{ lib, stdenvNoCC, fetchurl, glibc, patchelf }:

stdenvNoCC.mkDerivation rec {
  pname = "kilocode-cli";
  version = "7.0.33";

  src = fetchurl {
    url = "https://registry.npmjs.org/@kilocode/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
    sha256 = "1picp81z3x2f93g88q99jlzaya4jcj956wz2rfkq1j4v69vz89y0";
  };

  nativeBuildInputs = [ patchelf ];

  unpackPhase = ''
    tar xzf $src
    sourceRoot="package"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/kilo $out/lib/kilocode-cli/kilo

    # interpreter のみパッチ (rpathは変更しない)
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 $out/lib/kilocode-cli/kilo

    # LD_LIBRARY_PATH を設定するラッパースクリプト
    mkdir -p $out/bin
    cat > $out/bin/kilo <<EOF
    #!/bin/sh
    export LD_LIBRARY_PATH="${glibc}/lib\''${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
    exec "$out/lib/kilocode-cli/kilo" "\$@"
    EOF
    chmod +x $out/bin/kilo
    ln -s $out/bin/kilo $out/bin/kilocode

    runHook postInstall
  '';

  meta = with lib; {
    description = "Kilo Code CLI - open-source AI coding agent";
    homepage = "https://kilo.ai";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "kilo";
  };
}
