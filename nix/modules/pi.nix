{ pkgs, lib, config, ... }:

# Shared pi setup. ~/.pi/agent/settings.json stays a normal, machine-local
# file (providers, models, theme, ...); activation only
#   - sets `npmCommand` to the pinned npm from npm-tools.nix
#   - installs the packages below via `pi install` (adds them to `packages`
#     if needed). Packages are never removed; use `pi remove <source>`.

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
    "npm:pi-matt-pocock-skills"
    "npm:pi-claude-bridge"
  ];
in
{
  home.activation.piSettings = lib.hm.dag.entryAfter [ "npmTools" ] ''
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

      for spec in ${lib.escapeShellArgs packages}; do
        if [[ $spec == npm:* ]]; then
          # npm:name[@version] / npm:@scope/name[@version] -> name
          name=''${spec#npm:}
          if [[ $name == @* ]]; then
            rest=''${name#@}
            [[ $rest == *@* ]] && name="@''${rest%@*}"
          else
            name=''${name%@*}
          fi
          if [ -d "${agentDir}/npm/node_modules/$name" ] && \
             ${jq} -e --arg s "$spec" 'any(.packages[]?; . == $s or .source? == $s)' "${settings}" > /dev/null; then
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
