_ENTER()
{
   echo -e '\e[31;1m'
   read -p $'\nEnter para prosseguir.'
   echo -e '\e[m'
}

############################################################
# Listagem de Categorias/Fichas no Banco
############################################################
_DATABASE()
{
    local inc='0'
    local category
    local show
    local directory
    local archive_show

    echo -e "Opções Disponiveis no ${NAME}\n"
    for show in *; do
        if [[ "$inc" -eq '0' ]]; then
            echo -e "[ "$inc" ] ${cyan_}MENU PRINCIPAL${end_}"
            inc=$(( $inc + 1 ))
        fi
        echo "[ $inc ] ${show^}"
        directory[$inc]="${show}" # Capturando indice
        inc=$(( $inc + 1 ))
    done
    echo -e '\e[36;1m'
    read -p $'\nSelecione Qual Categoria você deseja acessar: ' category
    echo -e '\e[m'
    # O diretório existe no banco?
    if [[ "$category" = '0' ]]; then
        popd &>/dev/null
        return 32
    fi
    if [[ ! -d "${directory[$category]}" ]]; then
        echo "A categoria não existe."
        _ENTER
        popd &>/dev/null
        return 1
    fi
    while :; do
        # filmes disponiveis na categoria.
        echo -e "\n########################### ${directory[$category]^}"
        local inc='0'
        pushd "${directory[$category]}" &>/dev/null
        for archive_show in *; do
            if [[ "$inc" -eq '0' ]]; then
                echo -e "[ "$inc" ] ${cyan_}VOLTAR${end_}"
                inc=$(( $inc + 1 ))
            fi
            print_archive_show="${archive_show//_/ }" # Trocando _ por Espaço.
            echo "[ $inc ] ${print_archive_show^}"
            archive[$inc]="${archive_show}" # Capturando indice
            inc=$(( $inc + 1 ))
        done
        echo -e '\e[36;1m'
        read -p $'O que você deseja assistir?: ' watch_now
        echo -e '\e[m'
        if [[ "$watch_now" = 0 ]]; then
            popd &>/dev/null
            break
        elif [[ -z "$watch_now" ]]; then
            continue
        elif [[ ! -e "${archive[$watch_now]}" ]]; then
            echo "Não encontrei esse filme."
            continue
        fi
        (   # Abertura subshell para não sujar ambiente.
            source "${archive[$watch_now]}"
            # Chamando a função para tocar o video.
            _PLAY "$title_name" "$classification" "$url_video" "$description"
        )
    done
}


############################################################
# Função para tocar o padrão, se em todas os gates
# o video se mostrar disponivel o streamming começa.
############################################################
_PLAY()
{
    local title_name="$1"
    local classification="$2"
    local url_video="$3"
    local description="$4"

    echo "======================================================================"
    echo -e "${blue_}Você está Assistindo:${end_} $title_name"
    echo -e "${blue_}Classificação:       ${end_} $classification"
    echo -e "${blue_}Descrição:${end_}"
    echo "$description"
    echo -e "=======================================================================\n"
    echo -e "
     ############# OPÇÕES DO PLAYER #############
     ${cyan_}'q/ESC'${end_} Retornar.
     ${cyan_}'f'${end_} Full Screen.${end_}
     ${cyan_}'p'${end_} Pausar.${end_}
     ${cyan_}'9'${end_} Aumentar Volume.
     ${cyan_}'0'${end_} Abaixar Volume
     ${cyan_}'Direcional Direita'${end_}  Avança 10 segundos.
     ${cyan_}'Direcional Esquerda'${end_} Retrocede 10 segundos.
   "
    youtube-dl -q "$url_video" -o - | mplayer - &>/dev/null
}