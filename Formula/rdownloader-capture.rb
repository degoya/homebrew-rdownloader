# The capture agent's login service in the tap degoya/homebrew-rdownloader (RD-180-06). Rendered from
# packaging/homebrew/rdownloader-capture.rb.in in degoya/rDownloader by scripts/package-managers.sh,
# and replaced by the release workflow with every release: change the template, not this file.
#
# Homebrew allows one service per formula, and rdownloader's is the service. This formula carries
# the second one: it runs the rdownloader-capture that formula installs. A formula needs a url and
# a keg that is not empty, so it names the same archives with the same SHA-256 — Homebrew's cache
# is keyed by the URL, so nothing is downloaded twice — and keeps their README and LICENSE.
class RdownloaderCapture < Formula
  desc "Desktop agent handing Click'n'Load, clipboard and NZB files to rDownloader"
  homepage "https://rdownloader.net"
  version "1.39.0"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "degoya/rdownloader/rdownloader"

  on_macos do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.39.0/rdownloader-macos-aarch64.tar.gz"
      sha256 "9d7c1197196c2b3fc123e6bd4760fe944cd6a25d1404914bcb836d26a58ac04c"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.39.0/rdownloader-macos-x86_64.tar.gz"
      sha256 "f6c00b05fdc35dc2807548b135f278844c88e3b89b4725e493ec9361de3561ce"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.39.0/rdownloader-linux-aarch64.tar.gz"
      sha256 "7938c67fa5bdfa769ce8ba503f4a6e2caa06d3b72cfd373766941a2c2aef76f8"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.39.0/rdownloader-linux-x86_64.tar.gz"
      sha256 "c49537565067ceac4f8dfa34075cc07148ffb4e2e32fa74ee43b81a145a3562c"
    end
  end

  def install
    # The executable stays in rdownloader's keg, which links bin/rdownloader-capture already; a
    # second copy here would be a link conflict and a second version to keep in step.
    doc.install "README.md", "LICENSE"
  end

  def caveats
    <<~EOS
      Pair the agent with the service once — the capture token is issued in the web interface
      under Settings -> Desktop client and read from standard input:
        rdownloader-capture configure --token-stdin

      Then start it now and at every login:
        brew services start rdownloader-capture

      On macOS it runs as a LaunchAgent in your login session, so the tray icon appears; its
      "Quit" stays quit until the next login or `brew services restart rdownloader-capture`.
      Leave the login start to `brew services`: `rdownloader-capture autostart install` would
      register this version's path, and a second agent finds port 9666 taken.

      Pairing, Click'n'Load and the tray:
        https://github.com/degoya/rDownloader/wiki/capture-agent
    EOS
  end

  service do
    # rdownloader's opt path stays the same across upgrades. A failure restarts the agent, the
    # tray's "Quit" (exit status 0) does not; `keep_alive true` would undo every Quit.
    run [Formula["degoya/rdownloader/rdownloader"].opt_libexec/"rdownloader-capture", "run"]
    keep_alive successful_exit: false
    process_type :interactive
    log_path var/"log/rdownloader-capture.log"
    error_log_path var/"log/rdownloader-capture.log"
  end

  test do
    capture = Formula["degoya/rdownloader/rdownloader"].opt_bin/"rdownloader-capture"
    assert_match version.to_s, shell_output("#{capture} --version")
  end
end
