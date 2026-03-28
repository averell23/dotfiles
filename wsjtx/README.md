# WSJT-X

Weak-signal digital communication modes for amateur radio. Managed **manually** — not through nix-darwin or Homebrew — because the app is unsigned/unnotarized and has no Homebrew cask.

## Installation

### 1. Download the DMG

Download the latest macOS arm64 DMG from the official SourceForge page:

https://sourceforge.net/projects/wsjt/files/

### 2. Install the shared memory LaunchDaemon

macOS's default shared memory limit is too low for WSJT-X. The DMG ships a plist to raise it.

Mount the DMG, then run:

```bash
sudo cp /Volumes/WSJT-X/com.wsjtx.sysctl.plist /Library/LaunchDaemons
sudo chown root:wheel /Library/LaunchDaemons/com.wsjtx.sysctl.plist
```

This sets `kern.sysv.shmmax=52428800` (50 MB) and `kern.sysv.shmall=25600` at every boot.

### 3. Enable the daemon in System Settings

On macOS Sequoia and later, the plist won't run at boot unless you explicitly allow it:

**System Settings → Privacy & Security → scroll to `sysctl` → toggle ON**

### 4. Apply immediately (without rebooting)

```bash
sudo sysctl -w kern.sysv.shmmax=52428800 kern.sysv.shmall=25600
```

Verify:

```bash
sysctl kern.sysv.shmmax kern.sysv.shmall
# kern.sysv.shmmax: 52428800
# kern.sysv.shmall: 25600
```

### 5. Install the app

Drag `wsjtx.app` from the mounted DMG to `/Applications`.

First launch: **right-click → Open** to bypass Gatekeeper (app is unsigned).

---

## Removal

### Remove the app

```bash
rm -rf /Applications/wsjtx.app
```

### Remove the LaunchDaemon

```bash
sudo launchctl unload /Library/LaunchDaemons/com.wsjtx.sysctl.plist
sudo rm /Library/LaunchDaemons/com.wsjtx.sysctl.plist
```

The shared memory limits revert to macOS defaults (`shmmax=4194304`) on the next reboot.

### Undo the Privacy & Security toggle

**System Settings → Privacy & Security → scroll to `sysctl` → toggle OFF**

---

## Notes

- **macOS upgrades** may reset the Privacy & Security toggle, causing the "Unable to create shared memory segment" error on next launch. Re-enable `sysctl` in System Settings to fix it.
- **JTDX conflict**: JTDX ships its own plist (`com.jtdx.sysctl.plist`) that sets a lower `shmmax`. If both are installed, WSJT-X will fail. Remove the JTDX plist and reboot:
  ```bash
  sudo rm /Library/LaunchDaemons/com.jtdx.sysctl.plist
  ```
- This install is **not tracked by nix-darwin**. No `darwin-rebuild switch` will touch it.
