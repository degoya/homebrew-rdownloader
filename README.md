# rDownloader for Homebrew

The Homebrew tap of [rDownloader](https://rdownloader.net), a local-first download manager with a
web interface, for macOS (Apple Silicon and Intel) and Linux (x86-64 and arm64).

```bash
brew install degoya/rdownloader/rdownloader
brew services start rdownloader
```

Then open <http://127.0.0.1:8710> and follow the setup wizard. The service keeps its database,
plugins and default download folder in `$(brew --prefix)/var/rdownloader`, and `brew upgrade`
keeps them. Linux needs glibc 2.39 or newer.

Current version: 1.6.0. The formula is written by the release workflow of
[degoya/rDownloader](https://github.com/degoya/rDownloader) with every release — issues and changes go there,
not here. The handbook's installation page:
<https://github.com/degoya/rDownloader/wiki/installation>.
