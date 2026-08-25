---
name: install-package
description: "Add a desktop application or CLI tool to this dotfiles configuration using the repository's preferred package manager, then install it. Use when the user asks to install or add a package/application/tool."
---

# Install a package

Add the requested application or CLI tool to the declarative configuration, rather than installing it only imperatively. Follow the decision tree below exactly.

## 1. Resolve the application first

Treat the user's name as a search term, not automatically as a package name.

- Search both the Homebrew and Nix package indexes as needed. For Homebrew use `brew search --cask <term>` / `brew search <term>`; for Nix use `nix search nixpkgs <term>` (or an exact-name search where appropriate).
- Check the official project name, package name, and executable name. Account for differences such as a display name versus a cask/attribute name.
- If the request matches multiple unrelated applications, or only produces fuzzy/partial matches, stop and ask the user which application they mean. Include the candidate names and package identifiers in the question.
- Do not silently choose a similarly named package.
- If the requested thing is already installed, tell the user and ask how to proceed.
- If the requested thing is already declared, tell the user where it is declared and do not add a duplicate. Continue with `script/install` only if the user asked to install/reconcile the existing declaration.

## 2. Classify it

Determine whether it is a GUI **desktop application** that would live in `/Applications/` or a **CLI tool** which is installed in the `$PATH` and called from the command line.

If the classification is genuinely unclear, ask the user rather than making an assumption. A package that happens to ship a command-line helper is still a desktop application when its primary purpose is GUI use.

## 3. Choose the package manager

Use the first available option in the applicable branch. Prefer an exact package/cask match; do not substitute a similarly named package without confirmation.

### Desktop application

1. If an exact homebrew cask exists, add its cask token to the appropriate `homebrew.casks` list.

### CLI tool

1. If only an exact nix Nix package exists, add it to the appropriate `home.packages` list.
2. If only an exact Homebrew package exists, add its formula to the appropriate `homebrew.brews` list.
3. If both exist, and the Nix package has the same or a higher version, add the nix package.
4. If both exist, and the Homebrew package has a higher version, ask the user which one should be preferred.
5. If neither exists, report that the package is unavailable through the configured sources.  Do not invent a declaration.

## 4. Select the configuration location

Inspect `nix/flake.nix` and the profile files before editing. This repository currently has:

- `nix/home.nix`: shared Home Manager CLI packages (`home.packages`)
- `nix/profiles/defaults.nix`: settings and Homebrew packages shared by every machine, including common `homebrew.brews` and `homebrew.casks`
- `nix/profiles/work.nix`: work-only packages and casks
- `nix/profiles/personal.nix`: personal-only packages and casks
- `nix/hosts/*.nix`: machine-specific overrides

Put a package in the narrowest appropriate scope:

- shared across all machines: `nix/home.nix` for Nix CLI packages, or `nix/profiles/defaults.nix` for Homebrew packages/casks;
- work-only: `nix/profiles/work.nix`;
- personal-only: `nix/profiles/personal.nix`;
- host-specific: the relevant file under `nix/hosts/`.

If the user has not specified whether the package is for work, personal use, all machines, or a particular host, ask before editing when that choice affects the result. Use the current machine/profile only when the intended scope is clear from context. Avoid putting a package in both a shared file and a profile.

Keep the existing formatting and comments. Add the item once in the relevant list, preferably near related entries. Do not edit `Brewfile`: it is generated/legacy and explicitly says not to edit it. Do not manually edit `nix/flake.lock` for a package addition.

## 5. Ask for confirmation

Tell the user which package you will add, the description from the package manager, the way you will add it and the scope it will be added to.

Ask for explicit confirmation before you proceed.

## 5. Validate and install

After making the smallest necessary edit:

1. Check the diff and confirm the declaration uses the exact identifier found during the search.
2. Validate the flake when practical, for example:
   ```sh
   nix flake check ./nix
   ```
   If evaluation requires a host-specific invocation, report the validation error clearly and do not hide it.
3. Run the repository installer as requested:
   ```sh
   ./script/install
   ```
   This runs `darwin-rebuild switch` for the current macOS LocalHostName and may ask for `sudo`. It also runs any legacy `install.sh` scripts.
4. Report the files changed, package manager used, and whether `script/install` completed successfully. If installation fails, preserve the configuration change, show the relevant error, and explain the next action instead of claiming success.

## Do not modify other configuration

Do not silently make modifications other than to add the package. If other changes are needed, stop and ask for confirmation.
