# Internacionalização (i18n) do instalador-de-fontes

* **Domínio gettext:** `instalador-de-fontes` (nome do pacote Debian).
* **Idioma-fonte:** inglês; a interface brasileira está em `po/pt_BR.po`.
* **API:** `gettext.sh` (pacote `gettext-base`, declarado em `Depends`):
  `gettext "texto"` para mensagens simples e `eval_gettext "… \$variavel …"` para
  mensagens com variáveis (o `$` vai escapado para o xgettext ver o nome).
* **Idioma:** nunca forçado; segue `LANGUAGE`/`LC_ALL`/`LC_MESSAGES`/`LANG`.

## Onde os catálogos são procurados (`TEXTDOMAINDIR`)

1. `$INSTALADOR_DE_FONTES_LOCALEDIR`, se definida;
2. `build/locale` na raiz do repositório (ao rodar `src/font-installer.sh` do código-fonte);
3. `/usr/share/locale` (pacote instalado).

## Layout

```
po/i18n.sh, po/i18n.conf   script padrão Mainuan e configuração
po/POTFILES.in             [Shell] src/font-installer.sh, [Desktop] src/launcher.desktop.in
po/LINGUAS                 idiomas instalados (hoje só pt_BR)
po/instalador-de-fontes.pot
po/pt_BR.po
src/launcher.desktop.in    modelo do .desktop (Name em inglês)
tests/test_i18n.sh         teste com yad/fc-scan/fc-cache/convert falsos
```

## Tarefas

```bash
po/i18n.sh extract && po/i18n.sh update
po/i18n.sh validate && po/i18n.sh check-pot
po/i18n.sh add es
po/i18n.sh compile build/locale && LANGUAGE=en src/font-installer.sh fonte.ttf
tests/test_i18n.sh        # sem janelas: stubs em PATH temporário, HOME temporário
```

## Empacotamento

`build.sh` e o workflow `.github/workflows/blank.yml` geram
`/usr/share/applications/font-installer.desktop` com `msgfmt --desktop` e instalam
`/usr/share/locale/<lang>/LC_MESSAGES/instalador-de-fontes.mo`
(`po/i18n.sh compile`). Ambos exigem `gettext` no build; o pacote passa a depender
de `gettext-base`. O workflow roda `check-pot`, `validate` e o teste.

## Particularidades

* **Amostra tipográfica:** "The quick brown fox jumps over the lazy dog" é traduzível
  (comentário `Translators:` pede um pangrama/frase curta no idioma). Em pt_BR a
  frase foi mantida em inglês para a interface ficar idêntica; um revisor pode
  trocá-la por um pangrama português (ex.: "Um pequeno jabuti xereta viu dez
  cegonhas felizes.") só em `po/pt_BR.po`.
* **Marca legada:** o msgid do título é genérico ("Font Installer"), mas o pt_BR
  mantém "Instalador de fontes do Tiger OS". O `.desktop` ainda tem
  `Exec=/usr/tiger_tools/font-installer.sh` e `Categories=X-TigerTools;`
  (o pacote instala `/usr/bin/font-installer-gui`); não alterado — pendência.
* Rótulos do formulário são passados ao yad como `RÓTULO:LBL`; traduções não
  devem conter `!` no fim de rótulos nem quebras de linha.
* O texto `'s` após a família (`Família: Foo's`) e os valores lidos do `fc-scan`
  não são traduzidos.
