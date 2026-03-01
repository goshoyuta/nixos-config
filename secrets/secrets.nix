let
  user-yg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEusR5sczdEDKcoIaxcgzTwoZLGIxx0AAHylWIS10hPu";
  # NixOS インストール後に各ホストの SSH ホスト鍵を追記:
  #   ssh-keyscan localhost 2>/dev/null | grep ed25519
  # x1carbon = "ssh-ed25519 AAAA...";
  # vultr = "ssh-ed25519 AAAA...";
in
{
  "user-password.age".publicKeys = [ user-yg ];
  "espanso-base.age".publicKeys = [ user-yg ];
  "env-local-kouro.age".publicKeys = [ user-yg ];
}
