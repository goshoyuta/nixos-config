{ config, pkgs, lib, ... }:

{
  home.file.".claude/CLAUDE.md".source = ../dotfiles/claude/CLAUDE.md;

  # --- MCPプラグイン (context7, claude-mem, frontend-design) ---
  home.activation.claudePlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _pluginInstalled() {
      test -f "$HOME/.claude/plugins/installed_plugins.json" && \
        ${pkgs.jq}/bin/jq -e ".[\"$1\"]" "$HOME/.claude/plugins/installed_plugins.json" > /dev/null 2>&1
    }

    if ! _pluginInstalled "context7@claude-plugins-official"; then
      $DRY_RUN_CMD claude plugin install context7 || true
    fi

    if ! _pluginInstalled "frontend-design@claude-plugins-official"; then
      $DRY_RUN_CMD claude plugin install frontend-design || true
    fi

    if ! _pluginInstalled "claude-mem@thedotmack"; then
      $DRY_RUN_CMD claude plugin marketplace add thedotmack/claude-mem || true
      $DRY_RUN_CMD claude plugin install claude-mem || true
    fi
  '';

  # --- スキル (vercel-react-best-practices, web-design-guidelines, find-skills, copywriting) ---
  home.activation.claudeSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    (
      cd /tmp

      if [ ! -d "$HOME/.claude/skills/vercel-react-best-practices" ]; then
        $DRY_RUN_CMD npx --yes skills add vercel-labs/agent-skills --yes --global || true
      fi

      if [ ! -d "$HOME/.claude/skills/find-skills" ]; then
        $DRY_RUN_CMD npx --yes skills add haha0815/claude-meta-skills --yes --global || true
      fi

      if [ ! -d "$HOME/.claude/skills/copywriting" ]; then
        $DRY_RUN_CMD npx --yes skills add coreyhaines31/marketingskills --yes --global || true
      fi
    )
  '';
}
