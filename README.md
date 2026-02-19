# dotfiles

Personal system configuration for macOS. Topic-centric layout, managed by a combination of **Nix + Home Manager** (for packages and most config files) and a legacy **symlink mechanism** (for the remaining files not yet migrated).

---

## Structure

Everything is organised by topic area. Each directory represents one tool or concern:

```
asdf/       git/        ruby/       vim/
bin/        gnupg/      ssh/        zed/
homebrew/   iterm/      system/     zsh/
nix/        tmux/       ...
```

Two conventions drive how files are activated:

- **`*.symlink`** — symlinked into `$HOME` by the bootstrap script, stripping the `.symlink` extension. These are files not yet managed by Home Manager.
- **`nix/`** — the Home Manager flake. Most config now lives here.

Anything in `bin/` is added to `$PATH` and available everywhere.

---

## How it works

There are two systems running side by side:

### Nix + Home Manager (`nix/`)

The primary system. Manages packages, shell config, and tool-specific config files declaratively. Applying any change means editing a `.nix` file and running:

```bash
home-manager switch --flake ~/.dotfiles/nix
```

Home Manager generates config files as read-only symlinks into the Nix store. Every apply creates a new **generation** — a complete, named snapshot of your environment.

**What it currently manages:**

| Module | Config file generated |
|---|---|
| `nix/modules/git.nix` | `~/.config/git/config` |
| `nix/modules/tmux.nix` | `~/.config/tmux/tmux.conf` |
| `nix/modules/zsh.nix` | `~/.zshrc`, `~/.zshenv` |
| `home.nix` (direnv) | shell hook via `.zshrc` |
| `home.packages` | all CLI tools in `~/.nix-profile/bin` |

### Legacy symlinks

A small number of files are still managed the old way via `script/bootstrap`. These are candidates for future Home Manager migration:

```
asdf/tool-versions.symlink   → ~/.tool-versions
ruby/gemrc.symlink           → ~/.gemrc
ruby/irbrc.symlink           → ~/.irbrc
system/profile.symlink       → ~/.profile
system/Procfile.servers.symlink → ~/.Procfile.servers
vim/vimrc.symlink            → ~/.vimrc
vim/gvimrc.symlink           → ~/.gvimrc
zed/config/zed/settings.json.symlink → ~/.config/zed/settings.json
ssh/, gnupg/                 → SSH and GPG config (encrypted via git-crypt)
```

---

## New machine setup

### 1. Install Nix (Determinate Systems)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

This installs Nix with flakes enabled and provides a clean uninstaller. Restart your shell afterwards.

### 2. Clone the repo

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
```

### 3. Decrypt secrets

```bash
git-crypt unlock /path/to/your-key
```

Required before bootstrapping — SSH config, GPG keys, and API tokens are encrypted.

### 4. Run the bootstrap script

```bash
script/bootstrap
```

This creates all the `*.symlink` symlinks in `$HOME`.

### 5. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Homebrew is still used for GUI apps (casks) and a few tools not in nixpkgs.

### 6. Install Homebrew packages and casks

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

### 7. Apply Home Manager

On first run, `home-manager` isn't installed yet — use `nix run` to bootstrap it:

```bash
cd ~/.dotfiles/nix
nix run home-manager/master -- switch --flake .
```

After the first apply, `home-manager` is on your PATH and you can use the short form from then on.

---

## Day-to-day usage

### Adding or changing a package

Edit `nix/home.nix` or the relevant module, then apply:

```bash
home-manager switch --flake ~/.dotfiles/nix
```

### Adding a shell alias or environment variable

Edit `nix/modules/zsh.nix` — aliases go in `shellAliases`, env vars in `sessionVariables`. Then apply.

### Updating everything

Nix pins exact versions of all packages via `nix/flake.lock`. To pull in newer versions:

```bash
cd ~/.dotfiles/nix
nix flake update        # rewrites flake.lock with latest nixpkgs + home-manager
home-manager switch --flake .
git add flake.lock
git commit -m "Update nix flake inputs"
```

This updates oh-my-zsh, all zsh plugins, fzf, git, vim, tmux, and every other Nix-managed tool in one shot.

### Rolling back

Every `home-manager switch` creates a numbered generation. To go back:

```bash
home-manager generations         # list all generations
home-manager switch --rollback   # revert to previous generation
```

### Uninstalling Nix entirely

```bash
sudo /nix/nix-installer uninstall
```

Removes the Nix APFS volume, daemon, and all traces. The legacy symlink system continues to work independently.

---

## Important concepts

### Generated files are read-only

Files managed by Home Manager — `~/.zshrc`, `~/.config/git/config`, `~/.config/tmux/tmux.conf` — are symlinks into the Nix store and cannot be edited directly. Any external process that tries to write to them will get a permission error. If a process replaces the symlink with a regular file, that file will be overwritten on the next `home-manager switch`.

Always make changes in the relevant `.nix` module, not in the generated file.

### Git config

`~/.config/git/config` is managed by `nix/modules/git.nix`. This means `git config --global` will fail — use the module instead.

For settings that vary per machine or shouldn't be in the shared repo, use `includeIf` in `git.nix`:

```nix
settings.includeIf."gitdir:~/Code/personal/".path = "~/.config/git/personal";
```

For per-repository settings, use `git config --local` — that writes to `.git/config` inside the repo, which git owns and Home Manager never touches.

`~/.config/git/config` (global defaults) and `.git/config` (per-repo overrides) have always coexisted. Git merges them at runtime with the repo-local file taking priority.

### oh-my-zsh and plugins

oh-my-zsh and all zsh plugins (zsh-syntax-highlighting, fzf integration, etc.) are delivered via nixpkgs — pinned to the exact commit recorded in `flake.lock`. They are not cloned from GitHub at runtime. The `nix flake update` workflow above is how you receive updates.

### Secrets

Files ending in `.secret.zsh`, `.secret.symlink`, or `.secret.txt` are encrypted with [git-crypt](https://github.com/AGWA/git-crypt) and committed to the repo. They are transparent to normal git operations once unlocked. Future migration target: [agenix](https://github.com/ryantm/agenix) for Nix-native secret management.

---

## What's next (not yet migrated)

- **nix-darwin** — macOS system defaults (`macos/set-defaults.sh`) declared in Nix
- **asdf → per-project flakes** — replace `~/.tool-versions` with per-project `flake.nix` + direnv
- **agenix** — replace git-crypt for secret management
- **Remaining symlinks** — vim, ruby, zed config into Home Manager modules
- **Device-specific config** — replace `device_configs/*.json` with per-host Nix modules
