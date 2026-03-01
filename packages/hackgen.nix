{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "hackgen";
  version = "2.10.0";

  src = fetchzip {
    url = "https://github.com/yuru7/HackGen/releases/download/v${version}/HackGen_v${version}.zip";
    sha256 = "1rfhrr9g80ywwz4hhzzxsglsrir0llwj38pnc5bwlbngz1hnp0bh";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 *.ttf -t $out/share/fonts/truetype/hackgen
    runHook postInstall
  '';

  meta = with lib; {
    description = "HackGen - a monospaced font combining Hack and GenJyuuGothic";
    homepage = "https://github.com/yuru7/HackGen";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
