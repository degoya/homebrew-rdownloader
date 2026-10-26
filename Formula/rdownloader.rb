# rDownloader's formula in the tap degoya/homebrew-rdownloader (RD-180-06). Rendered from
# packaging/homebrew/rdownloader.rb.in in degoya/rDownloader by scripts/package-managers.sh, and
# replaced by the release workflow with every release: change the template, not this file.
class Rdownloader < Formula
  desc "Local-first download manager with a web interface"
  homepage "https://rdownloader.net"
  version "1.38.0"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.38.0/rdownloader-macos-aarch64.tar.gz"
      sha256 "38eb334f5e49d67d691c69fe82db78175861c3d460df0aeb8d9e04a85c9e02c6"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.38.0/rdownloader-macos-x86_64.tar.gz"
      sha256 "620011bc1bf50b286848d6bd088151fa9b98165b170c8e1f4bdc9714afe42e07"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.38.0/rdownloader-linux-aarch64.tar.gz"
      sha256 "496b5e4abda7f53ddefce9709ce46b0b02031145421632ae2646a04329dfff67"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.38.0/rdownloader-linux-x86_64.tar.gz"
      sha256 "a8e65b9a1715b438a3c9ee1ad0b72957a19a76a576aa697a6aab9fe78030745c"
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
