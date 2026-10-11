# rDownloader's formula in the tap degoya/homebrew-rdownloader (RD-180-06). Rendered from
# packaging/homebrew/rdownloader.rb.in in degoya/rDownloader by scripts/package-managers.sh, and
# replaced by the release workflow with every release: change the template, not this file.
class Rdownloader < Formula
  desc "Local-first download manager with a web interface"
  homepage "https://rdownloader.net"
  version "1.24.0"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.24.0/rdownloader-macos-aarch64.tar.gz"
      sha256 "13742ecc8104adf6166b654c1ea19892d3d8e915f1e192da9e2cf829779d6c9f"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.24.0/rdownloader-macos-x86_64.tar.gz"
      sha256 "b065a028a8d1cfdc793973381582602dc1939e38bf7b3a7b1e7db6c0f160df26"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/degoya/rDownloader/releases/download/v1.24.0/rdownloader-linux-aarch64.tar.gz"
      sha256 "8e6097b6b7956b4d078ac324bf2eb0106f20f4dec9e6b636922ac5a72b99825e"
    end
    on_intel do
      url "https://github.com/degoya/rDownloader/releases/download/v1.24.0/rdownloader-linux-x86_64.tar.gz"
      sha256 "e7af67f6aa1d455733e88736e71d86e0ff2136a95b8c88bbb6c5e13fdf69da81"
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
