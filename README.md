# Instalador de fontes
Um pequeno utilitário para pré-visualizar e instalar arquivos de fonte no Tiger OS, ele gera uma imagem com o pangrama "The quick brown fox jumps over the lazy dog" permitinto ver como a fonte é antes de instalá-la 

# Screenshots

![](screenshots/screen01.png)

# Pacote Debian

O pacote `instalador-de-fontes` é gerado a partir de `debian/`:

```bash
dpkg-buildpackage -us -uc -b
```

Os testes (`tests/test_installer.sh` e `tests/test_i18n.sh`) rodam sem abrir
janelas. O CI (`.github/workflows/ci.yml`) compila, testa, roda o lintian e
instala o pacote num Ubuntu 26.04 limpo; uma release só é publicada ao enviar
uma tag `v<versão>` igual à de `debian/changelog`.
