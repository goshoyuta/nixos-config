{ ... }:

{
  xdg.configFile."fcitx5/config".text = ''
    [Hotkey]
    DeactivateKeys=Escape
  '';

  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    Font=Noto Sans CJK JP 13
  '';

  xdg.configFile."fcitx5/conf/mozc.conf".text = ''
    [General]
    FundamentalCharacterForm=FUNDAMENTAL_HALF_WIDTH
  '';

  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
    [Groups/0]
    # Group Name
    Name=Default
    # Layout
    Default Layout=us
    # Default Input Method
    DefaultIM=mozc

    [Groups/0/Items/0]
    # Name
    Name=keyboard-us
    # Layout
    Layout=

    [Groups/0/Items/1]
    # Name
    Name=mozc
    # Layout
    Layout=

    [GroupOrder]
    0=Default
  '';
  };
}
