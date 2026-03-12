{ config, pkgs, ... }:

let
  gitAicommit = pkgs.writeShellScriptBin "git-aicommit" ''
    set -e

    # Register untracked files so they appear in diff
    git add -N .

    if git diff --quiet; then
      echo "Nothing to commit."
      exit 0
    fi

    echo "Analyzing changes..."

    # Ask Claude to group changes into logical commits and return JSON
    GROUPS=$(env -u CLAUDECODE claude --print "Analyze the following git changes and group them into logical commits.

Output ONLY a valid JSON array, no other text:
[
  {
    \"files\": [\"relative/path/to/file\"],
    \"message\": \"type: subject\"
  }
]

Grouping rules:
- Each commit = one logical unit of change (one feature, one fix, one concern)
- Group files that are part of the same change together
- Unrelated changes must be separate commits

Commit message rules:
- Conventional Commits: feat | fix | refactor | chore | docs | style | test | perf | ci
- English, imperative mood, lowercase subject, no trailing period, max 72 chars
- Add a body (blank line + explanation) only when WHY needs clarification

=== Changed files ===
$(git status --short)

=== Full diff ===
$(git diff)")

    echo ""
    echo "Commit plan:"
    echo "$GROUPS" | ${pkgs.jq}/bin/jq -r '.[] | "  • \(.message)\n    [\(.files | join(", "))]"'
    echo ""

    # Execute commits group by group
    echo "$GROUPS" | ${pkgs.jq}/bin/jq -c '.[]' | while IFS= read -r group; do
      message=$(echo "$group" | ${pkgs.jq}/bin/jq -r '.message')
      echo "Committing: $message"
      echo "$group" | ${pkgs.jq}/bin/jq -r '.files[]' | xargs git add
      git commit -m "$message"
    done

    echo ""
    echo "Pushing..."
    git push
    echo "Done."
  '';
in

{
  home.packages = [ pkgs.delta gitAicommit ];

  programs.git = {
    enable = true;
    userName = "goshoyuta";
    userEmail = "goshoyuta@gmail.com";

    aliases = {};

    extraConfig = {
      # --- Core ---
      core = {
        editor = "nvim";
        ignorecase = false;
        autocrlf = false;
        pager = "delta";
      };

      # --- Delta ---
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
      };

      # --- Merge ---
      color.ui = true;
      merge = {
        conflictstyle = "diff3";
        tool = "nvimdiff";
      };
      mergetool.prompt = false;

      # --- GitHub ---
      "credential \"https://github.com\"".helper = "!/run/current-system/sw/bin/gh auth git-credential";
      "credential \"https://gist.github.com\"".helper = "!/run/current-system/sw/bin/gh auth git-credential";

      # --- Defaults ---
      pull.ff = "only";
      init.defaultBranch = "main";
    };
  };
}
