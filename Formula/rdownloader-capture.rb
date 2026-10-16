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
  version "1.33.0"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "degoya/rdownloader/rdownloader"

  on_macos do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.33.0/rdownloader-macos-aarch64.tar.gz"
      sha256 "ad06f55c08a3fed6728755883b1c7710fa774e17c068e0d576954f5c3b567ed9"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.33.0/rdownloader-macos-x86_64.tar.gz"
      sha256 "a2b52678f45bfaa45bb0a7987d1e83cdbf19decd80be9c79622828d05a86e221"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.33.0/rdownloader-linux-aarch64.tar.gz"
      sha256 "19fb3e60c6da4919313b122ec1c11336397a297dbd9e5a900c31071cba9e620d"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.33.0/rdownloader-linux-x86_64.tar.gz"
      sha256 "22694ca6287d3dce9ddcf033a31d8a3632df0c881c58e4ef00ed91d1d280de94"
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
