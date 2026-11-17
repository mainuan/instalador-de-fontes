#!/usr/bin/env bash
# Teste funcional de src/font-installer.sh, sem janelas: yad, fc-scan, fc-cache
# e convert são trocados por stubs (PATH temporário) e o HOME é temporário.
# Não depende de locales instalados (roda em C.UTF-8). Requer bash e
# gettext-base (gettext.sh).
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/bin" "$TMP/home" "$TMP/tmp"
cat > "$TMP/bin/yad" <<'STUB'
#!/bin/sh
for a in "$@"; do printf 'yad-arg: %s\n' "$a" >> "$YAD_LOG"; done
printf 'yad-end\n' >> "$YAD_LOG"
case " $* " in
  *" --form "*) exit "${YAD_FORM_EXIT:-0}" ;;
  *" --progress "*) cat > /dev/null ;;
esac
exit 0
STUB
cat > "$TMP/bin/convert" <<'STUB'
#!/bin/sh
for a in "$@"; do last=$a; done
printf 'PNG' > "$last"
STUB
cat > "$TMP/bin/fc-scan" <<'STUB'
#!/bin/sh
[ -n "$FC_SCAN_FAIL" ] && exit 1
printf 'n:Test Sans Bold\ns:Bold\nt:TrueType\nf:Test Sans\nd:Mainuan\n'
STUB
printf '#!/bin/sh\necho fc-cache: done\n' > "$TMP/bin/fc-cache"
chmod +x "$TMP/bin/"*
FONT="$TMP/TestSans-Bold.ttf"
printf 'font' > "$FONT"

fail=0
check() {  # $1 description, $2... command
  local d=$1; shift
  if "$@"; then echo "ok   $d"; else echo "FAIL $d"; fail=1; fi
}
run() {  # run the installer; extra environment as arguments, last one the file
  : > "$TMP/yad.log"
  env -i PATH="$TMP/bin:$PATH" HOME="$TMP/home" TMPDIR="$TMP/tmp" LANG=C.UTF-8 \
      INSTALADOR_DE_FONTES_LOCALEDIR="$TMP/no-locale" YAD_LOG="$TMP/yad.log" "$@" \
      /bin/bash "$ROOT/src/font-installer.sh" "${FILE_ARG[@]}" </dev/null >"$TMP/out" 2>&1
}
fonts="$TMP/home/.local/share/fonts"

# Sem arquivo: mensagem e código de saída diferente de zero.
FILE_ARG=("$TMP/nao-existe.ttf")
rc=0; run || rc=$?
check "missing file exits with failure" test "$rc" -ne 0
check "missing file message" grep -qx "You need to provide a file!" "$TMP/out"

# Arquivo que não é fonte: erro e nada instalado.
FILE_ARG=("$FONT")
rc=0; run FC_SCAN_FAIL=1 || rc=$?
check "invalid font exits with failure" test "$rc" -ne 0
check "invalid font dialog" grep -qxF "yad-arg: --text=The file '$FONT' is not a valid font file!\\n" "$TMP/yad.log"
check "invalid font not installed" test ! -e "$fonts/TestSans-Bold.ttf"

# Cancelar no formulário: nada instalado, pré-visualização removida.
run YAD_FORM_EXIT=252
check "cancel does not install" test ! -e "$fonts/TestSans-Bold.ttf"
check "cancel removes the preview" test -z "$(ls -A "$TMP/tmp")"

# Instalar.
run
check "font details: family value without suffix" grep -qxF "yad-arg: --field=Test Sans:LBL" "$TMP/yad.log"
check "font details: name" grep -qxF "yad-arg: --field=Test Sans Bold:LBL" "$TMP/yad.log"
check "preview image passed to yad" grep -q "^yad-arg: --image=$TMP/tmp/.*\.png$" "$TMP/yad.log"
check "font copied to ~/.local/share/fonts" cmp -s "$FONT" "$fonts/TestSans-Bold.ttf"
check "success dialog" grep -qxF 'yad-arg: --text=The installation was successful!\n' "$TMP/yad.log"
check "preview removed after install" test -z "$(ls -A "$TMP/tmp")"

# Falha ao copiar (pasta de fontes sem permissão): erro, sem mensagem de sucesso.
rm -f "$fonts/TestSans-Bold.ttf"; chmod a-w "$fonts"
rc=0; run || rc=$?
chmod u+w "$fonts"
check "copy failure exits with failure" test "$rc" -ne 0
check "copy failure dialog" grep -qxF 'yad-arg: --text=The font could not be installed.\n' "$TMP/yad.log"
check "copy failure has no success dialog" bash -c "! grep -q 'installation was successful' '$TMP/yad.log'"
check "copy failure removes the preview" test -z "$(ls -A "$TMP/tmp")"

# O .desktop abre um arquivo por processo: o script trata só o primeiro argumento.
check "desktop entry passes one file (%f)" grep -qx "Exec=font-installer-gui %f" "$ROOT/src/launcher.desktop.in"

[ $fail -eq 0 ] && echo "installer test: all checks passed" || { echo "installer test: FAILED"; exit 1; }
