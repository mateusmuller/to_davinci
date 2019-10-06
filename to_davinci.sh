#!/usr/bin/env bash
#
# to_davinci.sh - Um simples script que faz a conversão dos vídeos para a utilização no DaVinci Resolve.
#
# Website:     https://4fasters.com.br
# Autor:       Mateus Gabriel Müller
# Créditos:
#
# Os créditos vão todos para o Henrique da equipe do Diolinux que lançou a ideia, e eu só
# reescrevi para aderir a minha necessidade.
# >>>> https://www.diolinux.com.br/2019/02/codecs-certos-no-davinci-resolve.html <<<<
#
# ------------------------------------------------------------------------ #
# O QUE ELE FAZ?
# Recebe como parâmetro um diretório e faz uma busca recursiva de TODOS os vídeos nos
# formatos mov, mp4, mkv e webm, convertendo para o codec do DaVinci.
#
# CONFIGURAÇÃO?
# Eu geralmente mantenho o script no /home do usuário e crio um link simbólico
# para algum diretório na variável PATH.
#
# $ ln -s /home/mateus/Scripts/to_davinci/to_davinci.sh /usr/local/bin/to_davinci
#
# COMO USAR?
#
# $ to_davinci /home/mateus/Vídeos
#
# ------------------------------------------------------------------------ #
# Changelog:
#
#   v1.0 07/03/2019, Mateus Müller:
#     - Primeira versão com bugs! Hahaha
#   v1.1 23/09/2019, Mateus Müller
#     - Corrigido bug no find com "\" e identado
#   v1.2 06/10/2019, Mateus Müller
#     - Adicionado "uniq" e removido a gambi do último diretório
#     - Corrigido alguns comentários de EN para PT
#
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 5.0.3
# ------------------------------------------------------------------------ #
#
# -------------------------------VARIÁVEIS----------------------------------------- #
DESTINO_CONVERTER="$1"
IFS=$'\n'
# -------------------------------EXECUÇÃO----------------------------------------- #
#
# Faz um "for" buscando todas as músicas, mas deixando somente o diretório, sem o nome
# do arquivo.
for diretorio_conversao in $(find "$DESTINO_CONVERTER" -type f \( -iname \*.mov \
                                                               -o -iname \*.mp4 \
                                                               -o -iname \*.mkv \
                                                               -o -iname \*.webm \) \
                                                               -printf "%h\n" | \
                                                               sort | \
                                                               uniq)
do
  # Diretório convertidos existe? Se não, crie!
  [ ! -d "$diretorio_conversao/convertidos" ] && mkdir "$diretorio_conversao/convertidos"
    # Mesma busca de antes, mas agora mostra somente o nome do arquivo
    for arquivo_conversao in $(find "$diretorio_conversao" -type f \( -iname \*.mov \
                                                                   -o -iname \*.mp4 \
                                                                   -o -iname \*.mkv \
                                                                   -o -iname \*.webm \) \
                                                                   -printf "%f\n")
    do
      # O arquivo já foi convertido? Se não, vamos converter!
      [ ! -f "$diretorio_conversao/convertidos/${arquivo_conversao%.*}.mov" ] && {
        ffmpeg -i "$diretorio_conversao/$arquivo_conversao" -codec:v mpeg4 \
                                                            -q:v 0 \
                                                            -codec:a pcm_s16le \
                                                            -max_muxing_queue_size 9999 \
                                                            "$diretorio_conversao/convertidos/${arquivo_conversao%.*}.mov"
      }
    done
done
# ------------------------------------------------------------------------ #
