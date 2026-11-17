<div align="center">

<img src="https://raw.githubusercontent.com/mainuan/.github/main/profile/assets/mainuan-logo.svg" width="96" alt="Logotipo do Mainuan">

# Instalador de fontes

Pré-visualiza um arquivo de fonte e o instala para o usuário atual, sem precisar de senha de administrador.

[![CI](https://github.com/mainuan/instalador-de-fontes/actions/workflows/ci.yml/badge.svg)](https://github.com/mainuan/instalador-de-fontes/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/mainuan/instalador-de-fontes)](https://github.com/mainuan/instalador-de-fontes/releases)
[![Licença](https://img.shields.io/github/license/mainuan/instalador-de-fontes)](LICENSE)
![Base](https://img.shields.io/badge/base-Kubuntu%2026.04%20LTS-0079c1)
![Plasma](https://img.shields.io/badge/KDE%20Plasma-6.6-1d99f3)

[English](README.en.md)

</div>

---

## O que é

O `font-installer-gui` abre um arquivo de fonte numa janela pequena, com um
texto de exemplo desenhado nessa fonte e os dados lidos pelo `fc-scan`: nome,
estilo, tipo, família e fabricante. Ao confirmar, a fonte é copiada para
`~/.local/share/fonts` e o cache do fontconfig é atualizado.

No Mainuan, o programa vem instalado na ISO e aparece no gerenciador de
arquivos como **Instalar fonte** ao abrir um arquivo TrueType, OpenType, WOFF
ou WOFF2. Ele não aparece no menu de aplicativos.

## Funcionalidades

- Pré-visualização com uma frase de exemplo, traduzida para cada idioma.
- Nome, estilo, tipo, família e fabricante da fonte.
- Instalação só na pasta do usuário (`~/.local/share/fonts`), sem `sudo`.
- Atualização do cache de fontes (`fc-cache`) com barra de progresso.
- Mensagem de erro para arquivo inexistente ou que não é fonte.
- Interface em 33 idiomas, que segue o idioma da sessão.

## Instalação

O programa já vem na ISO do Mainuan. Para instalar à mão, baixe o `.deb` e o
`SHA256SUMS` da [última release](https://github.com/mainuan/instalador-de-fontes/releases/latest):

```bash
sha256sum --check --ignore-missing SHA256SUMS
sudo apt install ./instalador-de-fontes_*_all.deb
```

As releases com `.deb` e `SHA256SUMS` são publicadas por tag, a partir da
versão 1.1.0. A release `continuous`, anterior ao empacotamento atual, não é
mais atualizada. O GitHub Releases não é um repositório APT: as atualizações
chegam por novas versões do pacote ou pela ISO.

## Uso

No Dolphin, clique com o botão direito num arquivo `.ttf`, `.otf`, `.woff` ou
`.woff2` e escolha **Abrir com > Instalar fonte**. Pelo terminal:

```bash
font-installer-gui <arquivo-de-fonte>
font-installer-gui ~/Downloads/NotoSans-Regular.ttf
```

O programa trata um arquivo por vez. Código de saída: `0` quando a fonte foi
instalada ou a janela foi fechada; `1` quando nenhum arquivo existente foi
informado ou o arquivo não é uma fonte. Detalhes em `man font-installer-gui`.

## Informações técnicas

| Item | Valor |
|---|---|
| Linguagem | Bash |
| Interface | `yad` |
| Leitura e cache de fontes | `fontconfig` (`fc-scan`, `fc-cache`) |
| Pré-visualização | ImageMagick (`convert`) |
| Traduções | gettext (`gettext.sh`, pacote `gettext-base`) |
| Pacote | `instalador-de-fontes` (`Architecture: all`) |
| Executável | `/usr/bin/font-installer-gui` |
| Atalho | `/usr/share/applications/font-installer.desktop` |
| Base | Kubuntu 26.04 LTS, KDE Plasma 6.6 |

## Compilação e testes

```bash
dpkg-buildpackage -us -uc -b
```

O build compila os catálogos de tradução, gera o `.desktop` traduzido e roda
`tests/test_installer.sh`, `tests/test_i18n.sh` e o `desktop-file-validate`.
Os testes não abrem janelas: `yad`, `fc-scan`, `fc-cache` e `convert` são
trocados por substitutos num `PATH` temporário.

O [CI](.github/workflows/ci.yml) usa o pipeline compartilhado
[`mainuan/.github`](https://github.com/mainuan/.github) num contêiner
Ubuntu 26.04 e:

1. confere o modelo de tradução e os catálogos (`po/i18n.sh check-pot` e
   `po/i18n.sh validate`) e roda `tests/test_installer.sh`;
2. compila com `dpkg-buildpackage` e passa o `lintian` (falha em erro);
3. instala o pacote num Ubuntu 26.04 limpo e confere os catálogos, a página de
   manual e o `.desktop`, as mensagens de erro em português e em inglês com
   código de saída 1 e uma instalação real da fonte DejaVu Sans com `fc-scan`,
   `convert` e `fc-cache` de verdade (só o `yad` é substituído);
4. reinstala, remove e expurga o pacote, sem sobras.

Uma tag `v<versão>`, igual à de `debian/changelog`, publica o `.deb` e o
`SHA256SUMS` na release.

## Traduções

33 idiomas: ar, bn, cs, da, de, el, es, fa, fi, fr, he, hi, hu, id, it, ja,
ko, nb, nl, pl, pt, pt_BR, ro, ru, sv, sw, th, tr, uk, ur, vi, zh_CN e zh_TW.
O texto-fonte é em inglês, e a interface brasileira fica em `po/pt_BR.po`.
Como adicionar ou atualizar um idioma: [`docs/i18n/README.md`](docs/i18n/README.md).

## Contribuição

Relate problemas em [Issues](https://github.com/mainuan/instalador-de-fontes/issues)
e envie mudanças por pull request. O CI roda em cada pull request, em
[Actions](https://github.com/mainuan/instalador-de-fontes/actions).

## Créditos

- **Natanael Barbosa Santos** ([sudo-give-me-coffee](https://github.com/sudo-give-me-coffee)):
  autor do programa, criado originalmente para o TigerOS.
- **Charles Santana** ([selrahcsan](https://github.com/selrahcsan)): CI e
  manutenção do pacote Debian.
- **Rafael Ruscher** ([ruscher](https://github.com/ruscher)): tradução,
  empacotamento Debian, testes e página de manual.

## Licença

[GNU GPL versão 2](LICENSE).
