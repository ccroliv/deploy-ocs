#!/usr/bin/env bash
#
#       Instalacao OCS Iventory Unix - Shift
#       Versão: 20220927

# Source function library to use the echo_success and echo_failure functions.
. /etc/init.d/functions

OCS_AGENT_VERSAO="https://github.com/OCSInventory-NG/UnixAgent/releases/download/v2.6.1/Ocsinventory-unix-agent-2.6.1.tar.gz"
OCS_PERL_VERSAO="5.36.0"
OCS_LOG_PATH="/var/log/ocsinvetory.log"
OCS_AGENT_TAG_CLIENTE=""
OCS_SERVER_URL_INVENTORY=http://inventory.shift.com.br/ocsinventory
OCS_PACK_DOWNLOAD="https://github.com/OCSInventory-NG/Packager-for-Unix/archive/refs/heads/master.zip"


# Functions
verifySuccess () {
        [ $? -eq 0 ] && echo_success || echo_failure
        echo
}

downloadInstalador() {
    ArquivoInstalador="PacoteOCS.zip"
	mkdir -pv /inst/pacotes
    if [ ! -f "/inst/pacotes/${ArquivoInstalador}" ]; then
        echo "Download Pacote OCS"
        curl -fL -o /inst/pacotes/${ArquivoInstalador} ${OCS_PACK_DOWNLOAD}
        echo -n "Download Pacote OCS"
        verifySuccess
        echo -n "Pacote OCS"
        unzip /inst/pacotes/${ArquivoInstalador} -d /inst/pacotes/ &> /dev/null
        verifySuccess && echo -en "\n"
    fi
}
	
	
telaInicial()	{
	echo "######################################"
	echo "#"
	echo "#"
	echo "#		Instalador Automatizado do OCS - Shift			"
	echo "#"
	echo "#"
	echo "######################################"
	echo "\n"
	echo "ATENCAO, PREENCHA COM CUIDADO"
	echo "\n"
	echo "Digite o Cliente"
	read OCS_AGENT_TAG_CLIENTE	
	echo "\n"
}

setFile()	{
	cd /inst/pacotes/Packager-for-Unix-master/
	ArquivoConfigOCS="packageOCSAgent.config"
	cat << EOF >> /inst/pacotes/Packager-for-Unix-master/packageOCSAgent.config
##################################
# Package creation configuration #
##################################

# Proxy configuration
export PROXY_HOST=
export PROXY_PORT=

# OCS Inventory installation directory
export OCS_INSTALL_DIR=/opt/ocsinventory

# Perl Download Link
export PERL_VERSION=5.36.0
export PERL_DL_LINK=http://www.cpan.org/src/5.0/perl-${PERL_VERSION}.tar.gz

# OCS Agent Download Link
export OCSAGENT_DL_LINK=https://github.com/OCSInventory-NG/UnixAgent/releases/download/v2.6.1/Ocsinventory-unix-agent-2.6.1.tar.gz                                                                                                    
# Nmap download link
export NMAP_DL_LINK=https://nmap.org/dist/nmap-7.70.tgz

# Parser ini details
export PARSER_INI_PATH=${OCS_INSTALL_DIR}/perl/lib/${PERL_VERSION}/XML/SAX/ParserDetails.ini

#############################
# OCS Agent crontab options #
#############################

# Create crontab for automatic inventory
export OCS_AGENT_CRONTAB=1

# How many hours between each crontab call
export OCS_AGENT_CRONTAB_HOUR=5

#####################################
# OCS Agent execution configuration #
#####################################

# Lazy mode
export OCS_AGENT_LAZY=1

# Machine TAG
export OCS_AGENT_TAG=CLIENTE

# Server url
export OCS_SERVER_URL=https://inventory.shift.com.br/ocsinventory

# SSL activated
export OCS_SSL_ENABLED=0

# SSL certificate path on host system
export OCS_SSL_CERTIFICATE_FULL_PATH=/path/to/my/certificate

# Create log file
export OCS_LOG_FILE=1

# Log file path
export OCS_LOG_FILE_PATH=/var/log/ocsinvetory/ocsinventory.log

EOF
	verifySuccess && echo -en "\n"
}

setVariaveis()	{
	cd /inst/pacotes/Packager-for-Unix-master/
	sed -i s/OCS_AGENT_TAG=CLIENTE/PERL_VERSION=${OCS_AGENT_TAG_CLIENTE}/g packageOCSAgent.config
	sleep 1
}
	
executaInstalador()	{
	cd /inst/pacotes/Packager-for-Unix-master/
	/bin/bash packageOCSAgent.sh
}
	
interacaoUsuario(){
	telaInicial
	echo "\n"
	echo "Preparando..."
	echo "\n"
	echo "\n"
	echo "\n"
	echo "CLIENTE TAG=" $OCS_AGENT_TAG_CLIENTE
	echo "\n"
	echo "\n"
	sleep 2 
	downloadInstalador
	setFile
	setVariaveis
	executaInstalador
}

case "$1" in
    install)
        interacaoUsuario
        ;;
    *)
        echo "Padrão de Execução: /bin/bash deploy.sh install"
        exit 1
esac



