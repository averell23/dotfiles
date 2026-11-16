{ pkgs, lib, config, ... }:

# Global npm tools, independent of asdf.
#
# Tools are installed into their own npm prefix with a pinned Node.js and run
# through wrappers that call that Node.js directly (instead of the packages'
# `#!/usr/bin/env node` shebang). Tools spawned by them still see the normal
# PATH, so project commands keep using the asdf Node.js.
#
# Tools listed here are installed once if missing. Update them with
# `npm-tools update -g` (or `pi update` for pi itself).

let
  node = pkgs.nodejs_26;
  prefix = "${config.home.homeDirectory}/.local/share/npm-tools";
  wrapperDir = "${prefix}/wrappers";

  tools = [
    "@earendil-works/pi-coding-agent"
    "pi-acp"
  ];

  # Pinned npm using the tools prefix for global installs. After global
  # (un)installs it regenerates the wrappers, if the prefix is writable
  # (it is read-only inside the nono sandbox).
  npm-tools = pkgs.writeShellScriptBin "npm-tools" ''
    set -uo pipefail
    export NPM_CONFIG_PREFIX="${prefix}"

    relink() {
      local tmp bin name first
      ${pkgs.coreutils}/bin/mkdir -p "${prefix}/bin"
      tmp=$(${pkgs.coreutils}/bin/mktemp -d "${prefix}/.wrappers.XXXXXX") || return 1
      for bin in "${prefix}"/bin/*; do
        [ -e "$bin" ] || continue
        name=''${bin##*/}
        first=""
        IFS= read -r first < "$bin" || true
        if [[ $first == "#!"*node* ]]; then
          printf '#!/bin/sh\nexec %s %q "$@"\n' "${node}/bin/node" "$bin" > "$tmp/$name"
          ${pkgs.coreutils}/bin/chmod +x "$tmp/$name"
        else
          ${pkgs.coreutils}/bin/ln -s "$bin" "$tmp/$name"
        fi
      done
      ${pkgs.coreutils}/bin/chmod 755 "$tmp"
      ${pkgs.coreutils}/bin/rm -rf "${wrapperDir}"
      ${pkgs.coreutils}/bin/mv "$tmp" "${wrapperDir}"
    }

    if [ "''${1:-}" = "--relink" ]; then
      relink
      exit
    fi

    global=false
    command=""
    for arg in "$@"; do
      case $arg in
        -g|--global) global=true ;;
        -*) ;;
        *) [ -n "$command" ] || command=$arg ;;
      esac
    done

    PATH="${node}/bin:$PATH" ${node}/bin/npm "$@"
    status=$?

    case $command in
      i|in|ins|inst|insta|instal|install|isntall|add|\
      up|update|upgrade|udpate|\
      un|uninstall|unlink|remove|rm|r|link|ln)
        if $global && [ -w "${prefix}" ]; then relink; fi ;;
    esac
    exit $status
  '';
in
{
  home.packages = [ npm-tools ];

  home.activation.npmTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    missing=()
    for tool in ${lib.escapeShellArgs tools}; do
      [ -d "${prefix}/lib/node_modules/$tool" ] || missing+=("$tool")
    done
    if [ ''${#missing[@]} -gt 0 ]; then
      run ${npm-tools}/bin/npm-tools install -g "''${missing[@]}" \
        || warnEcho "npm-tools: failed to install ''${missing[*]}"
    fi
    run ${npm-tools}/bin/npm-tools --relink

    # Stable path named `npm`, so pi recognises it as npm (see pi's `npmCommand`)
    run mkdir -p "${prefix}/libexec"
    run ln -sfn ${npm-tools}/bin/npm-tools "${prefix}/libexec/npm"
  '';

  # After the asdf shims, so the wrappers take precedence
  programs.zsh.initContent = lib.mkAfter ''
    # Global npm tools (see nix/modules/npm-tools.nix)
    export PATH="${wrapperDir}:$PATH"
  '';
}
