#!/usr/bin/env bash

# i18n: domínio gettext = nome do pacote Debian. Catálogos instalados em
# /usr/share/locale; para rodar a partir do código-fonte, compile com
# "po/i18n.sh compile build/locale" (detectado automaticamente) ou defina
# INSTALADOR_DE_FONTES_LOCALEDIR.
export TEXTDOMAIN=instalador-de-fontes
if [ -n "${INSTALADOR_DE_FONTES_LOCALEDIR}" ]; then
  export TEXTDOMAINDIR="${INSTALADOR_DE_FONTES_LOCALEDIR}"
elif [ -d "$(dirname "$(readlink -f "${0}")")/../build/locale" ]; then
  export TEXTDOMAINDIR="$(dirname "$(readlink -f "${0}")")/../build/locale"
else
  export TEXTDOMAINDIR=/usr/share/locale
fi
. gettext.sh

[ -f "${1}" ] || {
  gettext "You need to provide a file!"; echo
  exit
}

font_file=$(readlink -f "${1}")
base_name=$(basename "${font_file}")

window_title=$(gettext "Font Installer")
# Translators: yad button label (generic confirmation).
ok_button=$(gettext "OK")

data=$(fc-scan --format "n:%{fullname}\ns:%{style}\nt:%{fontformat}\nf:%{family}\nd:%{foundry}\n" "${font_file}")

[ ! "${?}" == "0" ] && {
  yad --center --borders=32 --button="${ok_button}" --fixed --text="$(eval_gettext "The file '\$font_file' is not a valid font file!")\n" --width=480 --title="${window_title}" --window-icon=font-ttf  --fixed
  exit 1
}

font_name=$(echo "${data}"    | grep "^n:" | cut -c 3- | head -n 1)
font_style=$(echo "${data}"   | grep "^s:" | cut -c 3- | head -n 1)
font_family=$(echo "${data}"  | grep "^f:" | cut -c 3- | head -n 1)
font_type=$(echo "${data}"    | grep "^t:" | cut -c 3- | head -n 1)
font_foundry=$(echo "${data}" | grep "^d:" | cut -c 3- | head -n 1)

preview_file=$(mktemp --suffix=.png)
# Translators: sample text rendered with the font being previewed. Use a short
# pangram (a sentence containing every letter) or a short typical sentence in
# your language, so users can judge how the font renders it.
sample_text=$(gettext "The quick brown fox jumps over the lazy dog")
convert -size 736x240 -background white -font "${font_file}" -pointsize 64 -fill black -gravity center caption:"${sample_text}" -flatten "${preview_file}"

# Translators: field labels of the font details form; keep the trailing colon.
yad --center --borders=32 --image-on-top --image="${preview_file}" --form --field=" ":LBL --field="$(gettext "Name:")":LBL --field="$(gettext "Style:")":LBL --field="$(gettext "Type:")":LBL --field="$(gettext "Family:")":LBL --field="$(gettext "Foundry:") ":LBL --field=" ":LBL --field=" ":LBL --field="${font_name}":LBL --field="${font_style}":LBL --field="${font_type}":LBL --field="${font_family}'s":LBL --field="${font_foundry}":LBL --field=" ":LBL --columns=2 --button="$(gettext "Cancel")":252 --button="$(gettext "Install")":0 --title="$(eval_gettext "Font Installer - \$base_name")" --window-icon=font-ttf --fixed && {

  mkdir -p "${HOME}/.local/share/fonts"
  cp "${font_file}" "${HOME}/.local/share/fonts"

  fc-cache -f -v|yad --title="${window_title}" --window-icon=font-ttf --center --borders=32 --no-buttons --fixed --text="$(eval_gettext "Installing the font \$font_name \$font_style")\n" --progress --pulsate --auto-close --width=480 --progress-text=" " --fixed

  yad --center --borders=32 --button="${ok_button}" --fixed --text="$(gettext "The installation was successful!")\n" --width=480 --title="${window_title}" --window-icon=font-ttf

}

rm "${preview_file}"
