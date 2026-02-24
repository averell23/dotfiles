{ ... }: {
  # Set once, do not change after initial install
  system.stateVersion = 5;

  # nix-darwin needs to know the user so home-manager can derive homeDirectory
  users.users.daniel.home = "/Users/daniel";

  # Required since nix-darwin 2025; identifies the admin user for system defaults
  system.primaryUser = "daniel";

  # Register /bin/zsh in /etc/shells so chsh works without sudo
  programs.zsh.enable = true;

  # Determinate Nix manages the Nix installation itself; disable nix-darwin's
  # built-in Nix management to avoid conflicts. Flakes are enabled by Determinate.
  nix.enable = false;

  # Homebrew: brews common to all machines; casks declared per-host
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade    = false;
      cleanup    = "uninstall"; # remove formulae/casks no longer listed
    };
    taps  = [];
    brews = [
      # asdf: manages language runtime versions via shims on PATH.
      # The Homebrew install sets up shims and shell integration cleanly;
      # the Nix package does not replicate this out of the box.
      "asdf"
      # gmp, libyaml: build dependencies for ASDF-managed Ruby. Nix home.packages
      # does not expose headers to the compiler, so these must live in Homebrew
      # where ruby-build can find them.
      "gmp"
      "libyaml"
    ];
    casks = [
      "1password"
      "firefox"
      "fork"         # git client
      "google-chrome"
      "iterm2"
      "obsidian"
      "zed"
      "zotero"
    ];
  };

  # macOS system defaults (migrated from macos/set-defaults.sh)
  system.defaults = {
    NSGlobalDomain = {
      # Disable autocorrect features that interfere with coding
      NSAutomaticCapitalizationEnabled     = false;
      NSAutomaticDashSubstitutionEnabled   = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled  = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      # Hold key gives key repeat rather than accent picker
      ApplePressAndHoldEnabled = false;
      # Show all file extensions in Finder
      AppleShowAllExtensions = true;
    };

    dock = {
      autohide                = true;
      showhidden              = true;
      show-recents            = true;
      mineffect               = "genie";
      mouse-over-hilite-stack = true;
      # Hot corners (actions only; modifiers set via activationScripts below)
      wvous-tl-corner = 3;    # Show application windows
      wvous-tr-corner = 2;    # Mission Control
      wvous-br-corner = 4;    # Desktop
      wvous-bl-corner = 13;   # Lock screen (with Alt/Option modifier)
    };

    finder = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop         = true;
      ShowMountedServersOnDesktop     = true;
      ShowRemovableMediaOnDesktop     = true;
      QuitMenuItem                    = true;
      ShowStatusBar                   = true;
      ShowPathbar                     = false;
      _FXSortFoldersFirst             = true;
      FXDefaultSearchScope            = "SCcf";  # search current folder
      FXEnableExtensionChangeWarning  = false;
      FXPreferredViewStyle            = "clmv";  # column view
    };
  };

  # Settings not yet covered by typed system.defaults options.
  # These run as the user (darwin activation is user-aware for pref domains).
  system.activationScripts.postActivation.text = ''
    # Hot corner modifiers (not covered by typed system.defaults.dock options)
    defaults write com.apple.dock wvous-tl-modifier -int 0
    defaults write com.apple.dock wvous-tr-modifier -int 0
    defaults write com.apple.dock wvous-br-modifier -int 0
    defaults write com.apple.dock wvous-bl-modifier -int 524288

    # Language and locale
    defaults write NSGlobalDomain AppleLanguages        -array "de" "en" "ja" "ro" "en-US"
    defaults write NSGlobalDomain AppleLocale           -string "en_US@currency=EUR"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
    defaults write NSGlobalDomain AppleMetricUnits      -bool true
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

    # Finder: no .DS_Store on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores     -bool true

    # Finder: open window when new removable disk is mounted
    defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
    defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
    defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true

    # Show ~/Library
    chflags nohidden ~/Library

    # AirDrop over every interface
    defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

    # Safari developer settings
    defaults write com.apple.Safari IncludeInternalDebugMenu                            -bool true
    defaults write com.apple.Safari IncludeDevelopMenu                                  -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey           -bool true
    defaults write com.apple.Safari ShowFavoritesBar                                    -bool false
    defaults write com.apple.Safari AutoFillFromAddressBook                             -bool false
    defaults write com.apple.Safari AutoFillPasswords                                   -bool false
    defaults write com.apple.Safari AutoFillCreditCardData                              -bool false
    defaults write com.apple.Safari AutoFillMiscellaneousForms                         -bool false
    defaults write com.apple.Safari AutoOpenSafeDownloads                              -bool false
    defaults write com.apple.Safari WarnAboutFraudulentWebsites                        -bool true
    defaults write com.apple.Safari SendDoNotTrackHTTPHeader                           -bool true
    defaults write com.apple.Safari WebKitJavaEnabled                                  -bool false

    # Software update settings
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
    defaults write com.apple.SoftwareUpdate ScheduleFrequency     -int  1
    defaults write com.apple.SoftwareUpdate AutomaticDownload     -int  1
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int  1
    defaults write com.apple.SoftwareUpdate ConfigDataInstall     -int  1
    defaults write com.apple.commerce AutoUpdate                  -bool true
    defaults write com.apple.appstore WebKitDeveloperExtras       -bool true

    # Photos: don't open when devices are plugged in
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
  '';
}
