# dotfiles

Personal system configuration for macOS. Topic-centric layout, managed by **nix-darwin + Home Manager** — declarative, version-controlled, and reproducible. asdf and homebrew are available as well.

## Directory Structure

- `script` - contains management scripts
- `nix/` — the primary system. Manages packages, shell config, macOS defaults, and Homebrew declaratively via nix-darwin + Home Manager.
- `bin` - anything in `bin/` is added to `$PATH` and available everywhere.
- `system` - files for system wide configuration

Everything else is organised by topic area. Each directory represents one tool or concern:

```
asdf/       gnupg/      ruby/       tmux/
...
```

## File conventions

- `*.symlink` files are symlinked into `$HOME` by the bootstrap script, stripping the `.symlink` extension. The folder hierarchy inside a topic directory is preserved in `$HOME`. A dot is always prepended to the target path. (e.g. `cooltool/config/cooltool_conf.symlink` is symlinked to `$HOME/.config/cooltool_conf`)
- `*.zsh` files are loaded in the zsh configuration for each new shell

## Available script commands

- `script/bootstrap` - run on a fresh machine. Installs everything, can update the symlinks
- `script/install` - runs install scripts and activates the nix configuration. Does not create new symlinks
- `script/update` - updates all nix and homebrew packages. Does not run installers, does not update symlinks

## How it works

### nix-darwin (`nix/`)

nix-darwin manages:

- macOS system defaults (dock, Finder, NSGlobalDomain)
- Homebrew (brews and casks) — installed and removed declaratively on every switch
- Home Manager, embedded as a nix-darwin module

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
"GUT-201" = mkDarwin "aarch64-darwin" [ ./profiles/work.nix ];
"Khara"   = mkDarwin "aarch64-darwin" [ ./profiles/personal.nix ./hosts/khara.nix ];
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
