{ lib, stdenvNoCC, fetchurl, installShellFiles }:

stdenvNoCC.mkDerivation rec {
  pname = "things-cli";
  version = "0.11.0";

  # Signed + notarized release binaries; hashes match the upstream cask.
  src = {
    aarch64-darwin = fetchurl {
      url = "https://github.com/ryanlewis/things-cli/releases/download/v${version}/things_${version}_darwin_arm64.tar.gz";
      sha256 = "b336d40c99ac88f4624a4192f5fb4ce09e1059f9827e9f6bdff0ed1136b4d848";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/ryanlewis/things-cli/releases/download/v${version}/things_${version}_darwin_amd64.tar.gz";
      sha256 = "646afdf6db251684c0e03fc91dd16e35c0ac34f9bc2958115c2f2e7f9ce19b45";
    };
  }.${stdenvNoCC.hostPlatform.system};

  sourceRoot = ".";
  nativeBuildInputs = [ installShellFiles ];
  dontBuild = true;
  # Keep Apple's code signature intact.
  dontStrip = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 things $out/bin/things
    installShellCompletion --cmd things \
      --bash <($out/bin/things completions bash) \
      --zsh  <($out/bin/things completions zsh) \
      --fish <($out/bin/things completions fish)
    runHook postInstall
  '';

  meta = {
    description = "Command-line interface for Things3 on macOS";
    homepage = "https://github.com/ryanlewis/things-cli";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    mainProgram = "things";
  };
}
