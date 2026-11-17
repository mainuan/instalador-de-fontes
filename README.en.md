<div align="center">

<img src="https://raw.githubusercontent.com/mainuan/.github/main/profile/assets/mainuan-logo.svg" width="96" alt="Mainuan logo">

# Font Installer (instalador-de-fontes)

Previews a font file and installs it for the current user, without administrator rights.

[![CI](https://github.com/mainuan/instalador-de-fontes/actions/workflows/ci.yml/badge.svg)](https://github.com/mainuan/instalador-de-fontes/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/mainuan/instalador-de-fontes)](https://github.com/mainuan/instalador-de-fontes/releases)
[![License](https://img.shields.io/github/license/mainuan/instalador-de-fontes)](LICENSE)

[Português](README.md)

</div>

---

## What it is

`font-installer-gui` opens a font file in a small `yad` window showing a
sample text rendered in that font plus its name, style, type, family and
foundry (read with `fc-scan`). On **Install**, the file is copied to
`~/.local/share/fonts` and the fontconfig cache is rebuilt. Nothing is written
outside the user's home directory.

It ships with the Mainuan ISO and is offered by the file manager as
**Install Font** for TrueType, OpenType, WOFF and WOFF2 files. The interface
is translated into 33 languages and follows the session language.

## Installation

Download the `.deb` and `SHA256SUMS` from the
[latest release](https://github.com/mainuan/instalador-de-fontes/releases/latest)
(tagged releases start at 1.1.0; the old `continuous` release is no longer
updated):

```bash
sha256sum --check --ignore-missing SHA256SUMS
sudo apt install ./instalador-de-fontes_*_all.deb
```

## Usage

```bash
font-installer-gui <font-file>
```

One file at a time. Exit status `0` when the font was installed or the window
was closed, `1` when no existing file was given or the file is not a font. See
`man font-installer-gui`.

## Build and tests

```bash
dpkg-buildpackage -us -uc -b
```

The build runs `tests/test_installer.sh`, `tests/test_i18n.sh` (with stubbed
`yad`, `fc-scan`, `fc-cache` and `convert`) and `desktop-file-validate`. The
[CI](.github/workflows/ci.yml) also checks the translation catalogs, runs
`lintian`, installs the package in a clean Ubuntu 26.04, installs a real
DejaVu Sans font through it (only `yad` is stubbed), then reinstalls, removes
and purges it. Translation workflow: [`docs/i18n/README.md`](docs/i18n/README.md).

## Credits and license

Written by Natanael Barbosa Santos
([sudo-give-me-coffee](https://github.com/sudo-give-me-coffee)), originally for
TigerOS; CI and package maintenance by Charles Santana
([selrahcsan](https://github.com/selrahcsan)); translation, Debian packaging,
tests and manual page by Rafael Ruscher ([ruscher](https://github.com/ruscher)).

Licensed under the [GNU GPL version 2](LICENSE).
