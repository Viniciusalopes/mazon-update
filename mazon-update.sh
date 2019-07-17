#!/usr/bin/env bash
# Template orgulhosamente criado por (Shell-Base)
#-----------HEADER-------------------------------------------------------------|
#AUTOR
#  Vovolinux <suporte@vovolinux.com.br>
#
##DATA-DE-CRIAÇÃO
#  12/07/2019 às 03:41 
#
#PROGRAMA
#  mazon-update
#
#PEQUENA-DESCRIÇÃO
#  Update pós instalação para Mazon OS 1.4.3 beta
#
#LICENÇA
#  MIT
#
#HOMEPAGE
#  https://vovolinux.com.br/vovomazon 
#
#CHANGELOG
#
#------------------------------------------------------------------------------|

# Interrompe a execução em caso de qualquer erro
set -e


#--------VÁRIAVEIS------------------------------------------------------------->

# Diretorio de trabalho
temp_dir='/tmp/mazon-update'

# Arquivo de log
arquivo_log='/var/log/mazon-update.log'

# Espelhos onde estão os pacotes
base='http://vovolinux.com.br/vovomazon/packages/base/'
xapp='http://vovolinux.com.br/vovomazon/packages/xapp/'
extra='http://vovolinux.com.br/vovomazon/packages/extra/'

# Flag para encerrar
fase_final=3

# Kernel atual
kernel=$(uname -r)

# Mensagens
msg_atencao='\n*******************************************************************************
***************************     A T E N Ç Ã O !     ***************************
*******************************************************************************\n'

msg_parar=' OK.\n Seu sistema não foi alterado.'

msg_reiniciar=' Reiniciar agora? [s/N]: ' 

msg_ate_breve=' OK.\n Até breve!'

msg_continuar=' Deseja continuar? [s/N]: '

msg_atualizar=' Deseja atualizar agora? [s/N] '

#           ******************************************************************************* 
msg_fase_1=' Este script vai fazer as segiuntes modificações no seu sistema:
 - Atualizar os módulos do python3
 - Atualizar os programas: mz (mzsearch), mkinitramfs e o banana do Jeff  XD
 - Atualizar o kernel para versão 5.1.3\n'

msg_fase_2=' Este script vai fazer as segiuntes modificações no seu sistema:
 - Atualizar pacotes do xfce4;
 - Instalar recursos para redes com compartilhamento via samba;
 - Atualizar os pacotes: thunar, networkmanager, openssh e pulseaudio.\n'

msg_fase_3=' Este script vai instalar os seguintes aplicativos:
 - Google Chrome, Thunderbird, Gimp, Inkscape, Kdenlive, Audacity, VLC,
   SimpleScreenRecorder, NetBeans, Visual Studio Code, php7, Terminator,
   VirtualBox e Gnome Discos.

 - Também serão instalados temas para o ambiente XFCE, pacotes de fontes
   e o tema de cursores Breeze.

 Mas não se preocupe! Será solicitada uma confirmação sua para cada programa,
 e você pode optar por não instalar um ou mais programas dessa lista.'

msg_atualizado=' \nSeu sistema está atualizado. Boa diversão!\n The FIM. =)\n'


#------------------------------------------------------------------------------>


#--------FUNÇÕES--------------------------------------------------------------->

# Grava o log de início da fase
log_iniciando()
{
    echo "[ "$(date)" ] FASE ${fase}: Iniciando..." >> ${arquivo_log} # Grava log
}

# Grava o log de fim da fase
log_concluindo()
{
    echo "[ "$(date)" ] FASE ${fase}: Concluída!" >> ${arquivo_log} # Grava log
}

# Cria o arquivo com a flag da fase
get_fase()
{
    if [ "${kernel}" == "5.1.3-mzn" ]; then  # Verifica se o novo kernel já está instalado
         echo "2" > ~/fase         # Pula a fase 1
         fase=2
         echo "[ "$(date)" ] FASE ${fase}: Kernel ${kernel} já está instalado." >> ${arquivo_log} # Grava log
    else    
        if ! [[ -e ~/fase ]]; then    # Se não existir o arquivo com a flag da fase,
            echo "1" > ~/fase         # Cria o arquivo com a fase 1
            fase=1                    # Seta a flag da fase
            echo "[ "$(date)" ] FASE ${fase}: Primeira execução." >> ${arquivo_log} # Grava log
            echo 
        else
            fase=$(cat ~/fase)        # Obtem a fase atual do arquivo
        fi
    fi
}


# Incrementa e atualiza a fase
atualiza_fase()
{
    fase=$((fase+1))          # Incrementa a fase
    echo "${fase}" > ~/fase   # Atualiza o arquivo com a flag
}

# Preparação do ambiente
prepara()
{
    # Cria o dir temporária
    cria_dir_temp

    # Entra no diretório temporário
    cd ${temp_dir}
    pwd
    sleep 2.5s  # Para conferir visualmente no console
}


# Cria o dir de trabalho
cria_dir_temp()
{
    if ! [[ -d "${temp_dir}" ]]; then    # Se não existir o dir
        mkdir -v "${temp_dir}"           # Cria o dir
    fi
}

# Download dos pacotes da fase
download()
{
    cd "${temp_dir}"
    for pacote in "${pacotes[@]}"; do                # Para cada pacote da fase
        if [[ -e "${temp_dir}/${pacote}" ]]; then    # Verifica se o pacote já foi baixado
            echo -e ">>> ${pacote} já foi baixado."  # Exibe na tela que já foi
            sleep 0.5s                                # Para conferir visualmente no console
        else
            wget "${espelho}${pacote}"               # Faz o download do pacote
            echo "[ "$(date)" ] FASE ${fase}: Download do pacote ${pacote}." >> ${arquivo_log} # Grava log
        fi
    done
}


# Instalação dos pacotes da fase
instala()
{
    for pacote in "${pacotes[@]}"; do    # Para cada pacote da fase
        banana -i "${pacote}"            # Instala o pacote
        echo "[ "$(date)" ] FASE ${fase}: Pacote ${pacote} instalado." >> ${arquivo_log} # Grava log
    done
}


# Seleção e execução das fases
executa()
{
    # Obtém a fase atual    
    get_fase

    if [ $((fase+1)) -gt $fase_final ]; then    # Se a fase atual é a última do script, já executou tudo.
        rm -f fase > /dev/null
        echo -e "${msg_atualizado}"
        exit 1
    fi

    if [ ${fase} -eq 1 ]; then                  # Fase 1
        echo -e "${msg_atencao}${msg_fase_1}"
        read -ep "${msg_continuar}" -n 1
    
        case "$REPLY" in
            s|S) fase1 ;;                 
            *) echo -e "${msg_parar}"  ;;
        esac
        exit 0
    fi
    
    if [ ${fase} -eq 2 ]; then                  # Fase 2
        echo -e "${msg_atencao}${msg_fase_2}"
        read -ep "${msg_continuar}" -n 1

        case "$REPLY" in
            s|S) fase2 ;;                 
            *) echo -e "${msg_parar}"  ;;
        esac
        exit 0       
    fi

    if [ ${fase} -eq 3 ]; then                  # Fase 3
        echo -e "${msg_atencao}${msg_fase_3}"
        read -ep "${msg_continuar}" -n 1

        case "$REPLY" in
            s|S) fase3 ;;                 
            *) echo -e "${msg_parar}"  ;;
        esac
        exit 0       
    fi
}

fase1()
{
    log_iniciando
    prepara

    # Seta o espelho
    espelho=${base}
    
    # Download do mz python3 - v1.0.1.1
    wget https://raw.githubusercontent.com/mazonos/mz/master/mz
    echo "[ "$(date)" ] FASE ${fase}: Download do pacote mz." >> ${arquivo_log} #

    # Permite a execução do mz 
    chmod +x mz 

    # Substitui o mz atual    
    mv -v mz /sbin/mz 
    echo "[ "$(date)" ] FASE ${fase}: Pacote mz python3 - v1.0.1.1 instalado." >> ${arquivo_log} # Grava log
  
    # Atualiza o python e seus módulos
    cd /usr/bin
    mv -v python python.old
    ln -sv python3 python
    cd ~
    echo "Aguarde alguns instantes, este processo pode demorar..."
    pip3 install --upgrade pip

    mz           # Atualiza modulos do python para o mz
    mz u         # Atualiza a lista de pacotes

    # Instala o banana do Jeff XD
    git clone https://github.com/slackjeff/bananapkg
    chmod +x bananapkg/install.sh
    bash bananapkg/install.sh
    
    # Seta os pacotes da fase
    pacotes=(
        'mkinitramfs-1.0-1.mz'
        'linux-5.1.3-1.mz'
        'linux_headers-5.1.3-1.mz'
        'linux_modules-5.1.3-1.mz'
        'linux_docs-5.1.3-1.mz'
        'linux_firmware-20190514-1.mz'
    )

    # Remove o pacote para garantir que a nova versão será instalada
    if [[ -e /sbin/mkinitramfs ]]; then
        rm -fv /sbin/mkinitramfs
    fi

    if [[ -e /usr/bin/mkinitramfs ]]; then
        rm -fv /usr/bin/mkinitramfs
    fi
    
    if [[ -e /usr/share/mkinitramfs ]]; then
        rm -rfv /usr/share/mkinitramfs
    fi
    sleep 3.5s  # Para conferir visualmente no console

    # Download dos pacotes da fase
    download

    # Instala os pacotes da fase
    instala
    
    echo -e "${msg_atencao} Você precisa atualizar o menu do GRUB para utilizar o kernel instalado."
    echo -e ' Recomendo atualizar agora nos seguintes casos:
 - Se você utiliza apenas a Mazon Os em seu computador;
 - Se tem mais de um sistema operacional mas o GRUB é gerenciado pela Mazon Os.

 Caso o GRUB seja gerenciado por outro sistema operacional, atualize-o por ele.'

    read -ep "${msg_atualizar}" -n 1
    
    case "$REPLY" in
	# Atualiza o menu do GRUB com o novo kernel
        s|S) grub-mkconfig -o /boot/grub/grub.cfg ;;
        *) echo -e 'OK. Continuando...' ;;
    esac
    exit 0
    
    log_concluindo

    # Incrementa para iniciar da fase 2 no próximo boot
    atualiza_fase

    echo -e "${msg_atencao} O Kernel foi atualizado.\n Para utilizar o novo Kernel você precisa reiniciar o sistema."
    read -ep "${msg_reiniciar}" -n 1
    
    case "$REPLY" in
        s|S) reboot ;;
        *) echo -e "${msg_ate_breve}" ;;
    esac
    exit 0
}

fase2()
{
    log_iniciando

    prepara
    
    # Seta o espelho
    espelho=${xapp}

    # Seta os pacotes da fase
    pacotes=(
        'xfce4_appfinder-4.12.0-1.mz'
        'xfce4_panel-4.12.2-1.mz'
        'xfce4_power_manager-1.6.1-1.mz'    
        'xfce4_session-4.12.1-1.mz'
        'xfce4_settings-4.12.4-1.mz'
        'xfce4_terminal-0.8.7.4-1.mz'
        'xfce4_pulseaudio_plugin-0.4.0-1.mz'
        'pulseaudio-12.2-1.mz'
        'libkrb5-1.16.1-1.mz'
        'libdaemon-0.14-1.mz'
        'libxfce4ui-4.12.1-1.mz'
        'libsamplerate-0.1.9-1.mz'
        'libtirpc-1.0.3-1.mz'
        'libnsl-1.2.0-1.mz'
        'gvfs-1.36.2-1.mz'
        'talloc-2.1.14-1.mz'
        'keybinder-3.0-1.mz'        
        'avahi-0.7-1.mz'
        'keyutils-1.5.10-1.mz'
        'samba-4.8.4-1.mz'           
        'thunar-1.7.0-1.mz'
        'networkmanager-1.12.2-1.mz'
        'openssh-7.7-1.mz'           
    )  
     
    # Download dos pacotes da fase
    download

    # Instala os pacotes da fase
    instala

    # Cria o arquivo padrão do samba
    cp -v /etc/samba/smb.conf.default /etc/samba/smb.conf
    sleep 3.5s  # Para conferir visualmente no console

    log_concluindo

    # Incrementa para iniciar da fase 3
    atualiza_fase

    echo -e "${msg_atencao} O ambiente XFCE e os recursos de rede foram instalados."
    read -ep " Instalar programas adicionais? [s/N]: " -n 1
    
    case "$REPLY" in
        s|S) executa ;;
        *) echo -e "${msg_ate_breve}" ;;
    esac
    echo "[ "$(date)" ] FASE ${fase}: Concluída!" >> ${arquivo_log} # Grava log
    exit 0
}


fase3()
{
    # Incrementa para iniciar da fase 3

    log_iniciando
    
    prepara
    
    # Seta o espelho
    espelho=${extra}

    # Seta os pacotes da fase
    pacotes=(
    'Google Chrome'
    'Thunderbird'
    'Gimp'
    'Inkscape'
    'Kdenlive'
    'Audacity'
    'VLC'
    'SimpleScreenRecorder'
    'NetBeans'
    'Visual Studio Code'
    'php7'
    'Terminator'
    'Zsh'
    'VirtualBox'
    'Team Viewer'
    'Gnome Discos'
    'Breeze Cursors'
    'Temas'
    'Fontes Ubuntu Studio + Microsoft'
    'Shell-Base'
    'Filezilla (desinstalar o atual e instalar o novo)'
    
    )
    
    # Download dos pacotes da fase
    download

    # Instala os pacotes da fase
    instala

    log_concluindo

    # Incrementa para iniciar da fase 3
    atualiza_fase

    echo -e "${msg_atencao} Nada aqui ainda...  :("
    echo -e "${msg_ate_breve}"
    log_concluindo
    exit 0
}

fase4()
{
    # Remover programas que considero desnecessários.
    exit 0
}
#------------------------------------------------------------------------------>


#------TESTES------------------------------------------------------------------>

# Sem root não vai amiguinho. (tks SlackJeff)
[[ "$UID" -ne '0' ]] && { echo "Execute como ROOT."; exit 1 ;}

#------------------------------------------------------------------------------>


# Programa começa aqui :)
executa

