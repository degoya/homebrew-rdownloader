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
  version "1.28.1"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "degoya/rdownloader/rdownloader"

  on_macos do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.28.1/rdownloader-macos-aarch64.tar.gz"
      sha256 "6abd7472c6032fdbac5980005e0258e5a368c54e565aede2d857ab0e99279310"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.28.1/rdownloader-macos-x86_64.tar.gz"
      sha256 "15be1744797821d6a26d6dab93ebea839ba11af6149677119eb136d9faeb7438"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.28.1/rdownloader-linux-aarch64.tar.gz"
      sha256 "68742ce654805913a4a1d6f356acad496587e1277d4a59adf8757b8932a5f1bf"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.28.1/rdownloader-linux-x86_64.tar.gz"
      sha256 "06ef9fc356bb269a12ee216b9a8d37f2e03f91002614f3ffebb299aafb2d8f3f"
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
