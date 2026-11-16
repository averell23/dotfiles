{ pkgs, lib, config, inputs, ... }:

# Shared pi setup. ~/.pi/agent/settings.json stays a normal, machine-local
# file (providers, models, theme, ...); activation only
#   - sets `npmCommand` to the pinned npm from npm-tools.nix
#   - installs `packages` via `pi install` (adds them to `packages` if needed)
#   - removes `retiredPackages` via `pi remove` (other packages are never
#     removed automatically)
#
# Skills from public git repos are pinned as flake inputs (flake.nix) and
# linked read-only into ~/.pi/agent/skills/<name>. Update them with
# `nix flake update <input>`.

let
  home = config.home.homeDirectory;
  agentDir = "${home}/.pi/agent";
  settings = "${agentDir}/settings.json";
  pi = "${home}/.local/share/npm-tools/wrappers/pi";
  npm = "${home}/.local/share/npm-tools/libexec/npm";
  jq = "${pkgs.jq}/bin/jq";

  packages = [
    "npm:pi-web-access"
    "npm:@upstash/context7-pi"
    "npm:pi-chrome"
    "${home}/.config/nono/packages/nolabs-ai/pi"
    "npm:context-mode"
    "npm:pi-open-tui"
    "npm:pi-acp"
    "npm:pi-wayfinder-guard"
    "npm:pi-claude-bridge"
  ];

  # Removed on every machine at the next switch. Agent files the package
  # copied to ~/.pi/agent/agents are deleted too, unless they were edited.
  retiredPackages = [
    "npm:pi-matt-pocock-skills" # deprecated, replaced by pi-wayfinder-guard + skills below
  ];

  # Install name -> { src = <flake input>; path = <skill dir in that repo>; }
  mattpocock = path: { src = inputs.mattpocock-skills; path = "skills/${path}"; };
  skills = {
    code-review = mattpocock "engineering/code-review";
    diagnosing-bugs = mattpocock "engineering/diagnosing-bugs";
    domain-modeling = mattpocock "engineering/domain-modeling";
    grill-with-docs = mattpocock "engineering/grill-with-docs";
    grilling = mattpocock "productivity/grilling";
    handoff = mattpocock "productivity/handoff";
    implement-spec = mattpocock "engineering/implement-spec";
    implement = mattpocock "engineering/implement";
    pr = mattpocock "engineering/pr";
    prototype = mattpocock "engineering/prototype";
    research = mattpocock "engineering/research";
    setup-matt-pocock-skills = mattpocock "engineering/setup-matt-pocock-skills";
    tdd = mattpocock "engineering/tdd";
    to-spec = mattpocock "engineering/to-spec";
    to-tickets = mattpocock "engineering/to-tickets";
    wait-what = mattpocock "productivity/wait-what";
    wayfinder = mattpocock "engineering/wayfinder";
  };

  skillDir = name: { src, path }:
    let dir = "${src}/${path}"; in
    if builtins.pathExists "${dir}/SKILL.md" then dir
    else throw "pi.nix: skill '${name}': ${path}/SKILL.md not found in its source";
in
{
  home.file = lib.mapAttrs'
    (name: skill: lib.nameValuePair ".pi/agent/skills/${name}" {
      source = skillDir name skill;
      recursive = true;
    })
    skills;

  home.activation.piSettings = lib.hm.dag.entryAfter [ "npmTools" ] ''
    # npm:name[@version] / npm:@scope/name[@version] -> name
    piNpmName() {
      local name=''${1#npm:} rest
      if [[ $name == @* ]]; then
        rest=''${name#@}
        [[ $rest == *@* ]] && name="@''${rest%@*}"
      else
        name=''${name%@*}
      fi
      echo "$name"
    }
    piConfigured() {
      ${jq} -e --arg s "$1" 'any(.packages[]?; . == $s or .source? == $s)' "${settings}" > /dev/null
    }

    if [ ! -x "${pi}" ]; then
      warnEcho "pi: ${pi} not found, skipping pi setup"
    elif [[ ! -v DRY_RUN ]]; then
      mkdir -p "${agentDir}"
      [ -s "${settings}" ] || echo '{}' > "${settings}"

      if ! ${jq} -e --arg npm "${npm}" '.npmCommand == [$npm]' "${settings}" > /dev/null; then
        tmp=$(mktemp "${settings}.XXXXXX")
        ${jq} --arg npm "${npm}" '.npmCommand = [$npm]' "${settings}" > "$tmp" \
          && mv "$tmp" "${settings}" || { rm -f "$tmp"; warnEcho "pi: could not update ${settings}"; }
      fi

      for spec in ${lib.escapeShellArgs retiredPackages}; do
        piConfigured "$spec" || continue
        # pi loads all extensions on `pi remove` (which may copy their agents
        # again), so keep the originals and clean up afterwards
        originals=$(mktemp -d)
        cp "${agentDir}/npm/node_modules/$(piNpmName "$spec")"/agents/*.md "$originals" 2>/dev/null || true
        if "${pi}" remove "$spec"; then
          for agent in "$originals"/*.md; do
            [ -e "$agent" ] || continue
            copy="${agentDir}/agents/''${agent##*/}"
            if cmp -s "$agent" "$copy"; then rm -f "$copy"; fi
          done
        else
          warnEcho "pi: failed to remove $spec"
        fi
        rm -rf "$originals"
      done

      for spec in ${lib.escapeShellArgs packages}; do
        if [[ $spec == npm:* ]]; then
          if [ -d "${agentDir}/npm/node_modules/$(piNpmName "$spec")" ] && piConfigured "$spec"; then
            continue
          fi
        elif [[ $spec == /* && ! -e $spec ]]; then
          warnEcho "pi: $spec does not exist, skipping"
          continue
        fi
        "${pi}" install "$spec" || warnEcho "pi: failed to install $spec"
      done
    fi
  '';
}
