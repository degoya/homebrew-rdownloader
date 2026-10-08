# rDownloader's formula in the tap degoya/homebrew-rdownloader (RD-180-06). Rendered from
# packaging/homebrew/rdownloader.rb.in in degoya/rDownloader by scripts/package-managers.sh, and
# replaced by the release workflow with every release: change the template, not this file.
class Rdownloader < Formula
  desc "Local-first download manager with a web interface"
  homepage "https://rdownloader.net"
  version "1.19.0"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.19.0/rdownloader-macos-aarch64.tar.gz"
      sha256 "9e94f39fab4c470223558320c0c3eff88609f88f8cfb282e93766c8e7d93b156"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.19.0/rdownloader-macos-x86_64.tar.gz"
      sha256 "f4dafe6cf2c3cfeeb264317603a4d65dc2a11ed89fcbcab390119db423610aef"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.19.0/rdownloader-linux-aarch64.tar.gz"
      sha256 "85acb8bcffbb986d1122a0258f9b551cc9e2fe6b06026822a7d0dbe7eddc1b3a"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.19.0/rdownloader-linux-x86_64.tar.gz"
      sha256 "4fed8fbc3445b5806a5fadc60f70dfa0ad756525925ea47fb65b5beff7c506fb"
    end
  end

  def install
    # The archive is the portable layout, and it stays together in libexec: the service installs
    # its bundled plugins from plugins/ beside the executable, and the macOS NZB helper app starts
    # the rdownloader-capture beside itself. bin/ gets scripts that exec the real files, because
    # through a symlink the executable would look for plugins/ in bin/ on macOS. The launcher
    # scripts are left out: they keep PID files and logs next to themselves, in the Cellar.
    libexec.install "rdownloader", "rdownloader-capture", "plugins"
    libexec.install "rDownloader Capture.app" if OS.mac?
    bin.write_exec_script libexec/"rdownloader", libexec/"rdownloader-capture"
  end

  def post_install
    (var/"rdownloader").mkpath
  end

  def caveats
    text = <<~EOS
      Start the service now and at every login, then open http://127.0.0.1:8710 for the setup
      wizard:
        brew services start rdownloader

      The service runs in #{var}/rdownloader: the database and the installed plugins in data/,
      the default download folder in downloads/. Upgrades keep both. Leave the autostart to
      `brew services`: it starts the service in that folder, while `rdownloader autostart
      install` would start it with its working folder inside the installation.

      The desktop capture agent (Click'n'Load, clipboard, .nzb files) is installed beside it; its
      own formula starts it at every login:
        brew install degoya/rdownloader/rdownloader-capture

      Media, stream and archive features need their external tools, for example:
        brew install ffmpeg yt-dlp
    EOS
    if OS.mac?
      text += <<~EOS

        The macOS binaries are ad-hoc signed, not notarized. Homebrew's download carries no
        quarantine flag, so Gatekeeper lets them run.
      EOS
    else
      text += <<~EOS

        The Linux binaries need glibc 2.39 or newer (`ldd --version`).
      EOS
    end
    text
  end

  service do
    run [opt_libexec/"rdownloader", "serve"]
    working_dir var/"rdownloader"
    keep_alive true
    log_path var/"log/rdownloader.log"
    error_log_path var/"log/rdownloader.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rdownloader --version")
  end
end
