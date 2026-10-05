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
  version "1.10.0"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "degoya/rdownloader/rdownloader"

  on_macos do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.10.0/rdownloader-macos-aarch64.tar.gz"
      sha256 "132efdc9e2051497fed8490c270c35caacac633ff4aa942666c7a46d5570b2e5"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.10.0/rdownloader-macos-x86_64.tar.gz"
      sha256 "780c200bb5b799b08fb9ba268c58abaa689d61a6fa6340d992666d9c2c907a1e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.10.0/rdownloader-linux-aarch64.tar.gz"
      sha256 "a24d6fec2c7daf7b3c82f498b75c16d40e934ed125eeb51c2f00a725f6161cd1"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.10.0/rdownloader-linux-x86_64.tar.gz"
      sha256 "88af97ca12a346874a452728785d7cc891820f16bb76cb36729c707d6b1006ac"
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
