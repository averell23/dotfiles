# dotfiles

Personal system configuration for macOS. Topic-centric layout, managed by **nix-darwin + Home Manager** — declarative, version-controlled, and reproducible.

---

## Structure

Everything is organised by topic area. Each directory represents one tool or concern:

```
asdf/       gnupg/      ruby/       tmux/
bin/        homebrew/   ssh/        vim/
gemini/     iterm/      system/     zed/
git/        nix/        zsh/        ...
```

Two conventions drive how files are activated:

- **`nix/`** — the primary system. Manages packages, shell config, macOS defaults, and Homebrew declaratively via nix-darwin + Home Manager.
- **`*.symlink`** — a small set of files (SSH keys, GPG keys, Zed settings, asdf versions) are symlinked into `$HOME` by the bootstrap script, stripping the `.symlink` extension. These are secrets or files where the symlink mechanism is simpler than a Nix module.

Anything in `bin/` is added to `$PATH` and available everywhere.

---

## How it works

### nix-darwin (`nix/`)

The primary system. nix-darwin manages:

- macOS system defaults (dock, Finder, NSGlobalDomain)
- Homebrew (brews and casks) — installed and removed declaratively on every switch
- Home Manager, embedded as a nix-darwin module

Applying any change means editing a `.nix` file and running:

```bash
darwin-rebuild switch --flake ~/.dotfiles/nix#$(hostname -s)
```

Every switch creates a new **generation** — a complete, named snapshot of the environment. Every package is pinned to the exact commit in `nix/flake.lock`.

**Flake layout:**

```
nix/
├── flake.nix              # entry point; assigns profiles to each machine
├── flake.lock             # pinned input versions (nixpkgs, nix-darwin, home-manager)
├── home.nix               # shared Home Manager config (packages, direnv, home.file)
├── profiles/
│   ├── defaults.nix       # always applied — system settings, macOS defaults, core brews
│   ├── work.nix           # work casks (Slack, Postman, Sequel Ace, Tunnelblick…)
│   └── personal.nix       # personal casks (1Password, Cyberduck, Firefox…)
├── hosts/
│   └── khara.nix          # machine-specific overrides (no profiles apply here)
└── modules/
    ├── git.nix            # programs.git → ~/.config/git/config
    ├── tmux.nix           # programs.tmux → ~/.config/tmux/tmux.conf
    ├── vim.nix            # programs.vim → ~/.vimrc
    └── zsh.nix            # programs.zsh → ~/.zshrc, ~/.zshenv
```

**Profiles** are composable modules. Each machine in `flake.nix` lists whichever profiles apply to it — Homebrew cask lists and Home Manager packages from all selected profiles are merged automatically:

```nix
"Crimple" = mkDarwin "aarch64-darwin" [ ./profiles/work.nix ./profiles/personal.nix ];
"khara"   = mkDarwin "aarch64-darwin" [ ./hosts/khara.nix ];
```

`profiles/defaults.nix` is always included by `mkDarwin` and never needs to be listed explicitly.

**What nix-darwin/Home Manager currently manages:**

| Area | Where |
|---|---|
| macOS system defaults | `profiles/defaults.nix` → applied at activation |
| Homebrew brews (all machines) | `profiles/defaults.nix` → `homebrew.brews` |
| Homebrew casks (work) | `profiles/work.nix` → `homebrew.casks` |
| Homebrew casks (personal) | `profiles/personal.nix` → `homebrew.casks` |
| Git config | `modules/git.nix` → `~/.config/git/config` |
| Tmux config | `modules/tmux.nix` → `~/.config/tmux/tmux.conf` |
| Vim config | `modules/vim.nix` → `~/.vimrc` |
| Zsh config, aliases, plugins | `modules/zsh.nix` → `~/.zshrc`, `~/.zshenv` |
| Direnv + nix-direnv | `home.nix` → shell hook via `.zshrc` |
| CLI packages | `home.nix` → `home.packages` |
| `.gemrc`, `.irbrc` | `home.nix` → `home.file` |

### Legacy symlinks

A small set of files are still managed by `script/bootstrap`. These are secrets or files with no clear benefit from a Nix module:

```
asdf/tool-versions.symlink                   → ~/.tool-versions
gnupg/gnupg/gpg-agent.conf.symlink          → ~/.gnupg/gpg-agent.conf
gnupg/gnupg/gpg.conf.symlink                → ~/.gnupg/gpg.conf
gnupg/gnupg/openpgp-revocs.d.secret.symlink → ~/.gnupg/openpgp-revocs.d
gnupg/gnupg/pubring.gpg.secret.symlink      → ~/.gnupg/pubring.gpg
ssh/ssh/config.secret.symlink               → ~/.ssh/config
ssh/ssh/id_rsa.pub.symlink                  → ~/.ssh/id_rsa.pub
ssh/ssh/id_rsa.secret.symlink               → ~/.ssh/id_rsa
zed/config/zed/settings.secret.json.symlink → ~/.config/zed/settings.json
```

Files ending in `.secret.*` are encrypted with git-crypt and require unlocking before they can be used.

---

## New machine setup

### 1. Install Nix (Determinate Systems)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Installs Nix with flakes enabled and a clean uninstaller. Restart your shell afterwards.

### 2. Clone the repo

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
```

### 3. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

nix-darwin manages the Homebrew package list declaratively, but Homebrew itself must be installed first.

### 4. Decrypt secrets

```bash
git-crypt unlock /path/to/your-key
```

Required before bootstrapping — SSH config, GPG keys, Zed settings, and API tokens are encrypted.

### 5. Run the bootstrap script

```bash
script/bootstrap
```

Creates the `*.symlink` symlinks in `$HOME` and then applies nix-darwin for the first time. On the first run, `darwin-rebuild` isn't installed yet, so it bootstraps via:

```bash
nix run nix-darwin -- switch --flake ~/.dotfiles/nix#$(hostname -s)
```

This installs all packages, applies macOS defaults, installs Homebrew casks, and activates Home Manager.

### 6. Add the new machine to flake.nix

Edit `nix/flake.nix` and add an entry under `darwinConfigurations` with the hostname and whichever profiles apply:

```nix
"MyMachine" = mkDarwin "aarch64-darwin" [ ./profiles/work.nix ./profiles/personal.nix ];
```

### 7. Set login shell

```bash
chsh -s /bin/zsh
```

nix-darwin registers `/bin/zsh` in `/etc/shells`. Log out and back in for the change to take effect.

---

## Day-to-day usage

### Applying changes

After editing any `.nix` file:

```bash
darwin-rebuild switch --flake ~/.dotfiles/nix#$(hostname -s)
# or use the convenience script:
script/install
```

### Adding a package

Edit `nix/home.nix` → `home.packages`. Then apply.

### Adding a Homebrew cask

Add it to the appropriate profile — `profiles/work.nix` or `profiles/personal.nix` — then apply. nix-darwin will install new casks and remove any that were deleted from the list, including GUI apps.

> **Warning:** Do not install things with `brew install` or download GUI apps via Homebrew manually. Anything not declared in the config will be uninstalled on the next `darwin-rebuild switch`. Add it to a profile first.

### Adding a shell alias or environment variable

Edit `nix/modules/zsh.nix` — aliases go in `shellAliases`, env vars in `sessionVariables`. Then apply.

### Updating everything

Nix pins exact versions of all packages via `nix/flake.lock`. To pull in newer versions:

```bash
cd ~/.dotfiles/nix
nix flake update                         # rewrites flake.lock with latest inputs
darwin-rebuild switch --flake .#$(hostname -s)
git add flake.lock
git commit -m "Update nix flake inputs"
```

### Rolling back

Every `darwin-rebuild switch` creates a numbered generation:

```bash
darwin-rebuild --list-generations        # list all generations
darwin-rebuild switch --rollback         # revert to previous generation
```

### Uninstalling Nix entirely

```bash
sudo /nix/nix-installer uninstall
```

Removes the Nix APFS volume, daemon, and all traces. The legacy symlink files in `$HOME` remain intact and functional.

---

## Important concepts

### Generated files are read-only

Files managed by Home Manager — `~/.zshrc`, `~/.config/git/config`, `~/.config/tmux/tmux.conf`, `~/.vimrc` — are symlinks into the Nix store and cannot be edited directly. Always make changes in the relevant `.nix` module.

### Git config

`~/.config/git/config` is managed by `nix/modules/git.nix`. Running `git config --global` will fail — use the module instead.

For per-repository settings, use `git config --local` — that writes to `.git/config` which Home Manager never touches.

### Homebrew is declarative

nix-darwin controls Homebrew. On each `darwin-rebuild switch`, it installs anything newly listed and **uninstalls anything no longer listed** — this applies to both CLI tools (brews) and GUI apps (casks). Do not install things manually with `brew install`; add them to a profile first.

The one exception: casks you installed yourself before nix-darwin took over may not be tracked by it and could be left alone. But anything installed after nix-darwin, or by nix-darwin itself, will be removed if dropped from the config.

### ASDF and Nix dev shells coexist

Both are installed and work independently, managed per project via direnv:

| Project `.envrc` | Active environment |
|---|---|
| `use flake` | Nix dev shell — tools from `flake.nix` take priority |
| `use asdf` | ASDF — `.tool-versions` determines versions |
| *(none)* | Global shell: ASDF shims take priority over Nix packages |

The global PATH order (outside any project) is: ASDF shims → Homebrew → Nix packages. This means ASDF wins for language runtimes globally, but a `use flake` project overrides that within its directory.

Practical rule: use ASDF for work projects where teammates rely on `.tool-versions`; use Nix dev shells for personal projects or any project you control entirely. Don't put language runtimes in `home.packages` — they'd be shadowed by ASDF shims anyway.

### Secrets

Files ending in `.secret.zsh`, `.secret.symlink`, or `.secret.txt` are encrypted with [git-crypt](https://github.com/AGWA/git-crypt) and committed to the repo. They are transparent to normal git operations once unlocked.

---

## What's next

- **agenix** — replace git-crypt for Nix-native secret management
