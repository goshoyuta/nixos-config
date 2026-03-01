let
  user-yg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnOYxqHkS7sYAfHDdf1IQhTz/+E771NbKWeMmpv+hn+";
in
{
  # espanso-base は手動で age 復号するため agenix 管理外
  # age -d -i ~/.ssh/id_ed25519 espanso-base.age > ~/.config/espanso/match/base.yml
}
