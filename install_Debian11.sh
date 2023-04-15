#!/bin/bash

<<COMMENT
*********************************************************************
[:::::::::::::::DEFINE CONSTANTES:::::::::::DEFINE CONSTANTS::::::::]
*********************************************************************
COMMENT
#	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
DOMAIN="mydomain.cl"				#my.domain.com
ADMINMAIL="mymail@gmail.com"		#Admin's Email
SERVERDIRECTORY="myproject_folder"	#my_project_folder
UPDATETIMEDISTANCE=3600				#update each x seconds
LOCALES="es_CL.UTF-8" 				#Locales
CODEX="UTF-8"						#Codification
TIMEZONE="America/Santiago" 		#TimeZone
DEFAULTERRORSHOW="off"				#On to show errors

UFW_PORTS=(22 80 443)				#All UFW Ports for open

MYSQL_USER="myuser"					#my_mysql_user
MYSQL_PWD="mypass"					#my_mysql_pwd
MYSQL_ROOT_PWD="myrootuser"			#my_root_pwd

DEFAULTWEBPAGE=''					#Default webpage in base64. This page is used for default webpage for your visitants.

#	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
<<COMMENT
*********************************************************************
[:::::::::::::::LIMPIEZA DE PANTALLA Y MENSAJE INICIAL::::::::::::::]
[:::::::::::::::SCREEN CLEANING AND INITIAL MESSAGE:::::::::::::::::]
*********************************************************************
COMMENT
#	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
clear
cd /

echo "'########::'##::::'##:'########::'##::::'##:'####:'##::: ##:'####::::'###::::'########::'##::::'##:'####:'##::: ##:
 ##.... ##: ##:::: ##: ##.... ##: ###::'###:. ##:: ###:: ##:. ##::::'## ##::: ##.... ##: ###::'###:. ##:: ###:: ##:
 ##:::: ##: ##:::: ##: ##:::: ##: ####'####:: ##:: ####: ##:: ##:::'##:. ##:: ##:::: ##: ####'####:: ##:: ####: ##:
 ########:: #########: ########:: ## ### ##:: ##:: ## ## ##:: ##::'##:::. ##: ##:::: ##: ## ### ##:: ##:: ## ## ##:
 ##.....::: ##.... ##: ##.....::: ##. #: ##:: ##:: ##. ####:: ##:: #########: ##:::: ##: ##. #: ##:: ##:: ##. ####:
 ##:::::::: ##:::: ##: ##:::::::: ##:.:: ##:: ##:: ##:. ###:: ##:: ##.... ##: ##:::: ##: ##:.:: ##:: ##:: ##:. ###:
 ##:::::::: ##:::: ##: ##:::::::: ##:::: ##:'####: ##::. ##:'####: ##:::: ##: ########:: ##:::: ##:'####: ##::. ##:
..:::::::::..:::::..::..:::::::::..:::::..::....::..::::..::....::..:::::..::........:::..:::::..::....::..::::..::
	         			BY ELCHELO.CL (NO ELIMINAR)"

#	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

<<COMMENT
*********************************************************************
[:::::::::::::::CREANDO DIRECTORIOS DE TU APLICACIÓN::::::::::::::::]
[:::::::::::CREATING DIRECTORIES FOR YOUR APPLICATION:::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, declararemos un array que contendrán las rutas de los directorios.
La aplicación verificará que estén creados y, de no ser así, los creará.
Verifica que cada directorio tenga una separación de un espacio como mínimo.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we will declare an array that will contain the paths of the directories.
The application will verify if they exist and, if not, it will create them.
Make sure that each directory has at least one space between them.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

#	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#	Agregar o Eliminar Directorios a crear
#	Add or Remove Directories to Create
#	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
declare -a dirs=(
	"/$SERVERDIRECTORY"
	"/$SERVERDIRECTORY/dir1"
	"/$SERVERDIRECTORY/dir2/subdir1"
)

for dir in "${dirs[@]}"
do
	# Verificar si el directorio existe | Check if the directory exists
	if [ -d "$dir" ]; then
		echo "Checkeando.... El directorio $dir existe. Continuamos..."
		echo "Checking.... Directory $dir exists. We continue..."
	else
		# Crear el directorio y mostrar un mensaje | Create the directory and display a message.
		mkdir "$dir"
		chown "www-data:www-data" "$dir"
		echo "El Directorio $dir ha sido creado. Continuamos..."
		echo "The directory $dir has been created. We continue..."
	fi
done

<<COMMENT
*********************************************************************
[:::::::::::::::::::::::UPDATE Y UPGRADE::::::::::::::::::::::::::::]
[:::::::::::::::::::::UPDATE AND UPGRADE::::::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, actualizaremos cada vez que el sistema detecte que hayan
pasado 60 horas o lo declarado por ti en la variable UPDATETIMEDISTANCE.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we will update every time the system detects that 60 hours have 
passed or the time declared by you in the UPDATETIMEDISTANCE variable.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

FILE_INSTALLED_NAME="01-update"
FILE_TIME="01-update-time"

if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	LAST_UPDATE=$(cat $SERVERDIRECTORY/installed/$FILE_TIME)
	NOW=$(date +%s)
	DIFF=$(($NOW - $LAST_UPDATE))
	if [ "$DIFF" -gt $UPDATETIMEDISTANCE ]; then
		apt-get update -y 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
		apt-get upgrade -y
		echo $NOW > $SERVERDIRECTORY/installed/$FILE_TIME
		echo "Genial. Aprovechamos de actualizar tu software."
		echo "Great. We took the opportunity to update your software."
	else
		echo "La base de datos ya han sido actualizadas el dia de hoy."
		echo "The database has already been updated today."
	fi
else
	apt-get update -y 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	apt-get upgrade -y
	NOW=$(date +%s)
	echo "$NOW" | tee /$SERVERDIRECTORY/installed/$FILE_TIME
fi

<<COMMENT
*********************************************************************
[:::::::::::::::::::::::IDIOMAS LOCALES::::::::::::::::::::::::::::]
[:::::::::::::::::::::::LOCAL LANGUAGES::::::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, actualizaremos los Locales al idoma especificado en la
variable LOCALES.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we will update the Locales to the language specified in the LOCALES
variable.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

GIVEMELOCALES=$(cat /etc/default/locale);
if [[ $GIVEMELOCALES == *"$LOCALES"* ]]
then
	echo "La version $LOCALES se encuentra correctamente configurada."
	echo "The $LOCALES version is correctly configured."
else
	rm /etc/locale.gen								#	Delete the generator.
	echo "$LOCALES $CODEX" > /etc/locale.gen			#	Create the generator file.
	rm /etc/default/locale							#	Delete the default locales.
	echo "LANG=$LOCALES" >> /etc/default/locale		#	Add UTF-8 as default
	/usr/sbin/locale-gen							#	Defining the Locales.
	echo "Se ha configurado $GIVEMELOCALES a $LOCALES"
fi

<<COMMENT
*********************************************************************
[:::::::::::::::::::::::::::ZONA HORARIA::::::::::::::::::::::::::::]
[:::::::::::::::::::::::::::::TIME ZONE:::::::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, actualizaremos la zona horaria a lo especificado en TIMEZONE.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, the timezone will be updated to the one specified in TIMEZONE.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

TIME=$(cat /etc/timezone);
if [[ $TIME == "$TIMEZONE" ]]
then
	echo "La zona horaria ya es $TIMEZONE"
	echo "The timezone is already set to $TIMEZONE."
else
	rm /etc/timezone										#	Remove the timezone.
	echo "$TIMEZONE" > /etc/timezone						#	Create the time zone file.
	rm /etc/localtime										#	Delete the symbolic link of the time zone.
	ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime		#	Recreate the symbolic link of the time zone.
	dpkg-reconfigure --frontend noninteractive tzdata		#	Reconfigure the changes.
	echo "Se ha configurado $TIME a $TIMEZONE"
fi

<<COMMENT
*********************************************************************
[:::::::::::::::::::::::::::::::FIREWALL::::::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, actualizaremos el Firewall. Bloquearemos todos los puertos
y solo permitiremos los puertos indicados en UFW_PORTS
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we will update the Firewall. We will block all ports and only 
allow ports in UFW_PORTS
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

FILE_INSTALLED_NAME="02-firewall"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "El firewall UFW ya fue instalada anteriormente."
	echo "The UFW firewall has already been installed previously."
else
	apt-get install ufw -y 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	tail /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME

	for PORT in "${UFW_PORTS[@]}"
	do
		ufw allow "$PORT"
	done
	
	ufw enable
	echo "UFW ha sido Instalado u habilitados los puertos 22, 80 y 443"
	echo "UFW has been installed and ports 22, 80, and 443 have been enabled."
fi

<<COMMENT
*********************************************************************
[::::::::::::::::::::::::::::::MAN::::::::::::::::::::::::::::::::::]
*********************************************************************
COMMENT

FILE_INSTALLED_NAME="03-man"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	version=$(man --version 2> /dev/null)
	echo "La version de Man Pages ($version) ya fue instalada anteriormente."
	echo "The Man Pages version ($version) has already been installed previously."
else
	apt-get install man -y 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	tail /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	echo "Man Pages ha sido Instalado."
	echo "Man Pages has been installed."
fi

FILE_INSTALLED_NAME="04-manespanol"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "La version de Man Pages En Español ya fue instalada anteriormente."
	echo "The Spanish version of Man Pages has already been installed previously."
else
	apt-get install manpages-es -y 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	tail /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	echo "Man Pages En Español ha sido Instalado."
	echo "The Spanish version of Man Pages has been installed."
fi

<<COMMENT
*********************************************************************
[:::::::::::::::::::::::::::::APACHE 2.4::::::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, instalamos la última versión de apache
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we will install the latest version of Apache.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

FILE_INSTALLED_NAME="05-apache"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "Apache 2 ya fue instalada anteriormente."
	echo "Apache 2 has already been installed previously."
else
	apt-get install apache2 -y 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	tail /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	echo "Apache 2 ha sido Instalado."
	echo "Apache 2 has been installed."
fi

<<COMMENT
*********************************************************************
[:::::::::::::::::::::::::::::::::PHP:::::::::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, instalamos alguna versión de PHP
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we install some version of PHP.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

FILE_INSTALLED_NAME="06-php"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "PHP ya fue instalado anteriormente."
	echo "PHP has already been installed previously."
else
	install_php(){
		apt-get update
		apt-get install apt-transport-https lsb-release ca-certificates software-properties-common -y 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
		wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
		sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
		apt-get update -y 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
		apt-get install php$1 -y

		echo "PHP $1 ha sido Instalado"
		echo "PHP $1 has been installed."
	}

	PS3="Elige tu versión de php: | Choose your PHP version:"
	opciones=("8.2" "8.1" "8.0" "7.4" "7.3" "7.2" "7.1" "7.0" "5.6" "No instalar|Dont install")
	select opt in "${opciones[@]}"
	do
		case $opt in 
			"8.2") echo "INSTALAREMOS PHP 8.2 | WILL INSTALL PHP 8.2"
					install_php "8.2"; break
			;;
			"8.1") echo "INSTALAREMOS PHP 8.1 | WILL INSTALL PHP 8.1"
					install_php "8.1"; break
			;;
			"8.0") echo "INSTALAREMOS PHP 8.0 | WILL INSTALL PHP 8.0"
					install_php "8.0"; break
			;;
			"7.4") echo "INSTALAREMOS PHP 7.4 | WILL INSTALL PHP 7.4"
					install_php "7.4"; break
			;;
			"7.3") echo "INSTALAREMOS PHP 7.3 | WILL INSTALL PHP 7.3"
					install_php "7.3"; break
			;;
			"7.2") echo "INSTALAREMOS PHP 7.2 | WILL INSTALL PHP 7.2"
					install_php "7.2"; break
			;;
			"7.1") echo "INSTALAREMOS PHP 7.1 | WILL INSTALL PHP 7.1"
					install_php "7.1"; break
			;;
			"7.0") echo "INSTALAREMOS PHP 7.0 | WILL INSTALL PHP 7.0"
					install_php "7.0"; break
			;;
			"5.6") echo "INSTALAREMOS PHP 5.6 | WILL INSTALL PHP 5.6"
					install_php "5.6"; break
			;;
			"No instalar|Dont install") echo "SALTAREMOS LA INSTALACION DE PHP"
				break
			;;
		esac
	done
fi

<<COMMENT
*********************************************************************
[:::::::::::::::::::::::::::::CERTBOT 2.5.0:::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, instalamos Certbot
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we install Certbot.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

FILE_INSTALLED_NAME="07-certbot"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "CERTBOT ya ha sido instalado."
	echo "CERTBOT has already been installed."
else
	apt-get install snapd -y 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	snap install core 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	snap refresh core 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	snap install --classic certbot 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	ln -s /snap/bin/certbot /usr/bin/certbot
	echo "CERTBOT ha sido Instalado." > /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	echo "CERTBOT has been installed."
fi

<<COMMENT
*********************************************************************
[:::::::::::::::::::::::::::::::SSL:::::::::::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, activaremos SSL, crearemos un certificado para el dominio
y respaldaremos los certificados.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we will enable SSL, create a certificate for the domain, and backup
the certificates.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

FILE_INSTALLED_NAME="08-certOpen"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "Ya se ha activado el soporte para ssl"
else
	a2enmod rewrite
	a2enmod ssl
	systemctl restart apache2
	echo "Se ha activado el soporte para SSL" > /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

FILE_INSTALLED_NAME="09-certcreate"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "El certificado ya ha sido CREADO."
else
	certbot --webroot -w /var/www/html --agree-tos --email marcelo@fibercat.cl certonly -n -d $DOMAIN
	echo "Certificado para $DOMAIN ya CREADO" > /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

FILE_INSTALLED_NAME="10-certCopy"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "El certificado ya ha sido COPIADO."
else
	mkdir /$SERVERDIRECTORY/ssl/$DOMAIN/
	cp /etc/letsencrypt/archive/$DOMAIN/*.* /$SERVERDIRECTORY/ssl/$DOMAIN/

	mv /$SERVERDIRECTORY/ssl/$DOMAIN/cert1.pem /$SERVERDIRECTORY/ssl/$DOMAIN/$DOMAIN.crt  
	mv /$SERVERDIRECTORY/ssl/$DOMAIN/privkey1.pem /$SERVERDIRECTORY/ssl/$DOMAIN/$DOMAIN.key
	mv /$SERVERDIRECTORY/ssl/$DOMAIN/fullchain1.pem /$SERVERDIRECTORY/ssl/$DOMAIN/$DOMAIN.ca-bundle

	echo "Certificado para $DOMAIN COPIADO en /$SERVERDIRECTORY/ssl/$DOMAIN" > /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

<<COMMENT
*********************************************************************
[:::::::::::::::::::::::::CONFIGURAR APACHE:::::::::::::::::::::::::]
[::::::::::::::::::::::::::CONFIGURE APACHE:::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, crearemos el archivo de configuración APACHE.CONF, 
configuraremos los archivos conf del sitio $DOMAIN
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we will create the APACHE.CONF configuration file and configure
the site conf files for $DOMAIN.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

FILE_INSTALLED_NAME="11-apacheConf"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "APACHE ya ha sido configurado"
else
	#	Creamos apache2.conf
	echo '# Global configuration
DefaultRuntimeDir ${APACHE_RUN_DIR}
PidFile ${APACHE_PID_FILE}
Timeout 300
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5
User ${APACHE_RUN_USER}
Group ${APACHE_RUN_GROUP}
HostnameLookups Off
ErrorLog ${APACHE_LOG_DIR}/error.log
LogLevel warn
# Include module configuration:
IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf
# Include list of ports to listen on
Include ports.conf
<Directory />
	Options FollowSymLinks
	AllowOverride None
	Require all denied
</Directory>

<Directory /usr/share>
	AllowOverride None
	Require all granted
</Directory>

<Directory /'$SERVERDIRECTORY'/www>
	Options +Indexes
	AllowOverride All
	Require all granted
</Directory>
AccessFileName .htaccess
<FilesMatch "^\.ht">
	Require all denied
</FilesMatch>
LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %O" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
IncludeOptional conf-enabled/*.conf
IncludeOptional sites-enabled/*.conf' > /$SERVERDIRECTORY/vendor/apache24/apache2.conf
	cp /$SERVERDIRECTORY/vendor/apache24/apache2.conf /etc/apache2/apache2.conf

	echo "APACHE ha sido configurado" > /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

FILE_INSTALLED_NAME="12-certConfigCreation"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "El archivo de configuración ya fue creado."
else
	SSLCERTIFICATEFILE="SSLCertificateFile /$SERVERDIRECTORY/ssl/$DOMAIN/$DOMAIN.crt"
	SSLCERTIFICATEKEYFILE="SSLCertificateKeyFile /$SERVERDIRECTORY/ssl/$DOMAIN/$DOMAIN.key"
	SSLCERTIFICATECHAINFILE="SSLCertificateChainFile /$SERVERDIRECTORY/ssl/$DOMAIN/$DOMAIN.ca-bundle"

	echo '<IfModule mod_ssl.c>
	<VirtualHost _default_:443>

		ServerName '$DOMAIN'
		ServerAlias '$DOMAIN'
		ServerAdmin '$ADMINMAIL'
		DocumentRoot /'$SERVERDIRECTORY'/www
		ErrorLog /'$SERVERDIRECTORY'/logs/ssl.'$DOMAIN'.error.log
		CustomLog /'$SERVERDIRECTORY'/logs/ssl.'$DOMAIN'.access.log combined

		SSLEngine on

		'$SSLCERTIFICATEFILE'
		'$SSLCERTIFICATEKEYFILE'
		'$SSLCERTIFICATECHAINFILE'

		<FilesMatch "\.(cgi|shtml|phtml|php)$">
				SSLOptions +StdEnvVars
		</FilesMatch>
		<Directory /usr/lib/cgi-bin>
				SSLOptions +StdEnvVars
		</Directory>

	</VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet' > /$SERVERDIRECTORY/vendor/apache24/ssl.$DOMAIN.conf
	echo "Certificado para $DOMAIN copiado en /$SERVERDIRECTORY/ssl/$DOMAIN" > /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	cp /$SERVERDIRECTORY/vendor/apache24/ssl.$DOMAIN.conf /etc/apache2/sites-available/ssl.$DOMAIN.conf
	a2ensite ssl.$DOMAIN.conf
	echo "OK" > /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

<<COMMENT
*********************************************************************
[:::::::::::::::::::::::WEBPAGE POR DEFECTO:::::::::::::::::::::::::]
[:::::::::::::::::::::::::::DEFAULT WEBPAGE:::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, crearemos la página web por defecto. Esta debe estar
configurada en BASE64.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we will create the default web page. This should be configured
in BASE64.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

FILE_INSTALLED_NAME="13-htmlIndexCreation"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "Ya se ha creado la web"
else
#	WEB-ERROR-404
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
echo $DEFAULTWEBPAGE | base64 --decode > /$SERVERDIRECTORY/www/index.php
	chown "www-data:www-data" /$SERVERDIRECTORY/www/index.php
	echo "Se ha creado el Index" > /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

<<COMMENT
*********************************************************************
[::::::::::::::::::::::::::::::HTTACESS:::::::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, crearemos el archivo httacess.
Este archivo realiza dos funciones:
1. Redireccionar http a https.
2. Organizar sistema de rutas. Cualquier cosa se escriba en la url y no
se encuentre físciamente como archivo, redirigirá el contenido al index.php
quien controlará lo que se muestra.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we will create the .htaccess file.
This file serves two functions:
1. Redirect HTTP to HTTPS.
2. Organize the routing system. Anything typed in the URL that does not
physically exist as a file will be redirected to index.php,
which will control what is displayed.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

FILE_INSTALLED_NAME="14-httacess"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "Ya se ha creado el archivo httacess"
else
echo '<IfModule mod_rewrite.c>
	<IfModule mod_negotiation.c>
		Options -MultiViews -Indexes
	</IfModule>

	RewriteEngine On
	php_flag display_startup_errors '$DEFAULTERRORSHOW'
	php_flag display_errors '$DEFAULTERRORSHOW'

	# Redireccionar todo el tráfico HTTP a HTTPS
	RewriteCond %{HTTPS} off
	RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d
	RewriteRule ^(.*)$ index.php

</IfModule>' > /$SERVERDIRECTORY/www/.htaccess
	chown "www-data:www-data" /$SERVERDIRECTORY/www/.htaccess
	echo "Se ha creado el archivo httacess" > /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

<<COMMENT
*********************************************************************
[::::::::::::::::::::::::::::MYSQL MARIADB::::::::::::::::::::::::::]
*********************************************************************
COMMENT

<<COMMENT
A continuación, instalaremos MariaDB. Configuraremos el usuario con grant
option y desactivaremos acceso externo root.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Next, we will install MariaDB. We will configure the user with grant
option and disable external root access.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
COMMENT

FILE_INSTALLED_NAME="15-mariadbApp"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then

	echo "Ya se ha instalado MariaDB."
else
	apt-get install mariadb-server -y 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	echo "Listo. Instalada." >> /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	mysql --version  >> /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

FILE_INSTALLED_NAME="16-mariadbCreateUser"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "El Usuario $MYSQL_USER ya ha sido creado con privilegios"
	echo "Usuario: "$MYSQL_USER
	echo "Password: "$MYSQL_PWD
else
	#	Creando usuario fibercat con privilegios
	mysql -u root -e "CREATE USER '"$MYSQL_USER"'@'localhost' IDENTIFIED BY '"$MYSQL_PWD"'"
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '"$MYSQL_USER"'@'localhost' IDENTIFIED BY '"$MYSQL_PWD"' with grant option"
	echo "El Usuario $MYSQL_USER ya ha sido creado con privilegios" 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
	echo "Usuario: "$MYSQL_USER
	echo "Password: "$MYSQL_PWD
fi

FILE_INSTALLED_NAME="17-mariadbDeleteAnonymousTestUsers"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "Ya han sido eliminados los usuarios anonimos y test"
else
	#	Eliminamos ciertos usuarios
	mysql -u root -e "DELETE FROM mysql.user WHERE User=''"
	mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
	echo "Usuarios test y anonimos fueron eliminados" 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

FILE_INSTALLED_NAME="18-mariadbDesactivateRootAccess"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "El usuario ROOT ya ha sido deshabilitado del acceso remoto"
else
	mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
	echo "El usuario ROOT ha sido deshabilitado del acceso remoto" 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

FILE_INSTALLED_NAME="19-mariadbChangeRootPwd"
if [[ -f /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME ]]
then
	echo "El usuario ROOT ya ha modificado su password"
	echo "Usuario: root"
	echo "Password: "$MYSQL_ROOT_PWD
else
	mysqladmin -u root password "$MYSQL_ROOT_PWD"
	#mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PWD');"
	mysql -u root -e "FLUSH PRIVILEGES"
	echo "Usuario: root"
	echo "Password: "$MYSQL_ROOT_PWD
	echo "El password de root fue cambiado satisfactoriamente" 2>&1 | tee /$SERVERDIRECTORY/installed/$FILE_INSTALLED_NAME
fi

systemctl restart mariadb
systemctl reload apache2