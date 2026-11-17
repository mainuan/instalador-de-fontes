#!/usr/bin/env bash
# Teste de i18n: executa src/font-installer.sh de verdade com LANGUAGE=pt_BR e
# LANGUAGE=en/C, trocando yad, fc-scan, fc-cache e convert por stubs (em um PATH
# temporário) que só registram os argumentos — nenhuma janela é aberta e nada é
# instalado (HOME temporário). Requer bash, GNU gettext (msgfmt, gettext.sh).
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

"$ROOT/po/i18n.sh" compile "$TMP/locale" >/dev/null

mkdir -p "$TMP/bin" "$TMP/home"
STUBPATH="$TMP/bin:$PATH"   # stubs first; the rest of the system as usual
cat > "$TMP/bin/yad" <<'STUB'
#!/bin/sh
for a in "$@"; do printf 'yad-arg: %s\n' "$a" >> "$YAD_LOG"; done
printf 'yad-end\n' >> "$YAD_LOG"
exit 0
STUB
cat > "$TMP/bin/convert" <<'STUB'
#!/bin/sh
for a in "$@"; do printf 'convert-arg: %s\n' "$a" >> "$YAD_LOG"; done
STUB
cat > "$TMP/bin/fc-scan" <<'STUB'
#!/bin/sh
[ -n "$FC_SCAN_FAIL" ] && exit 1
printf 'n:Test Sans Bold\ns:Bold\nt:TrueType\nf:Test Sans\nd:Mainuan\n'
STUB
printf '#!/bin/sh\necho fc-cache: done\n' > "$TMP/bin/fc-cache"
chmod +x "$TMP/bin/"*
: > "$TMP/TestSans-Bold.ttf"

# A glibc ignora LANGUAGE quando o locale efetivo é C/C.UTF-8: para o caso
# pt_BR usa-se um locale real disponível (pt_BR.UTF-8 de preferência).
REAL_LOCALE=$(locale -a 2>/dev/null | grep -m1 -E '^pt_BR\.(utf8|UTF-8)$' \
  || locale -a 2>/dev/null | grep -m1 -E '^en_US\.(utf8|UTF-8)$' \
  || locale -a 2>/dev/null | grep -m1 -viE '^(C|POSIX)' || true)
[ -n "$REAL_LOCALE" ] || { echo "SKIP: no non-C locale available"; exit 0; }
locale_for() { case "$1" in C) echo C;; *) echo "$REAL_LOCALE";; esac; }

fail=0
run() {  # $1 LANGUAGE, $2 FC_SCAN_FAIL (""|1); prints the log
  local log="$TMP/log.$1.$2"; : > "$log"
  env -i PATH="$STUBPATH" HOME="$TMP/home" LANGUAGE="$1" LANG="$(locale_for "$1")" \
      INSTALADOR_DE_FONTES_LOCALEDIR="$TMP/locale" YAD_LOG="$log" FC_SCAN_FAIL="$2" \
      /bin/bash "$ROOT/src/font-installer.sh" "$TMP/TestSans-Bold.ttf" </dev/null >/dev/null || true
  cat "$log"
}
expect() {  # $1 description, $2 haystack, $3 needle
  if grep -qxF -- "$3" <<<"$2"; then echo "ok   $1: $3"; else echo "FAIL $1: missing '$3'"; fail=1; fi
}
usage() { env -i PATH="$STUBPATH" LANGUAGE="$1" LANG="$(locale_for "$1")" INSTALADOR_DE_FONTES_LOCALEDIR="$TMP/locale" \
            /bin/bash "$ROOT/src/font-installer.sh" "$TMP/nao-existe.ttf"; }

F="$TMP/TestSans-Bold.ttf"
out=$(run pt_BR "")
for s in "yad-arg: --field=Nome::LBL" "yad-arg: --field=Estilo::LBL" "yad-arg: --field=Tipo::LBL" \
         "yad-arg: --field=Família::LBL" "yad-arg: --field=Fundação: :LBL" \
         "yad-arg: --button=Cancelar:252" "yad-arg: --button=Instalar:0" \
         "yad-arg: --title=Instalador de fontes do Mainuan - TestSans-Bold.ttf" \
         "yad-arg: --title=Instalador de fontes do Mainuan" \
         'yad-arg: --text=Instalando a fonte Test Sans Bold Bold\n' \
         'yad-arg: --text=A instalação foi um sucesso!\n' "yad-arg: --button=Ok" \
         "convert-arg: caption:The quick brown fox jumps over the lazy dog"; do
  expect pt_BR "$out" "$s"
done
out=$(run pt_BR 1)
expect pt_BR "$out" "yad-arg: --text=O arquivo '$F' não é um arquivo de fonte válido!\\n"
expect pt_BR "$(usage pt_BR)" "Você precisa fornecer um arquivo!"

for lang in en C; do
  out=$(run $lang "")
  for s in "yad-arg: --field=Name::LBL" "yad-arg: --field=Style::LBL" "yad-arg: --field=Type::LBL" \
           "yad-arg: --field=Family::LBL" "yad-arg: --field=Foundry: :LBL" \
           "yad-arg: --button=Cancel:252" "yad-arg: --button=Install:0" \
           "yad-arg: --title=Font Installer - TestSans-Bold.ttf" "yad-arg: --title=Font Installer" \
           'yad-arg: --text=Installing the font Test Sans Bold Bold\n' \
           'yad-arg: --text=The installation was successful!\n' "yad-arg: --button=OK" \
           "convert-arg: caption:The quick brown fox jumps over the lazy dog"; do
    expect $lang "$out" "$s"
  done
  out=$(run $lang 1)
  expect $lang "$out" "yad-arg: --text=The file '$F' is not a valid font file!\\n"
  expect $lang "$(usage $lang)" "You need to provide a file!"
done

[ -z "$(ls -A "$TMP/home/.local/share/fonts" 2>/dev/null | grep -v TestSans)" ] || fail=1
[ $fail -eq 0 ] && echo "i18n test: all checks passed" || { echo "i18n test: FAILED"; exit 1; }
