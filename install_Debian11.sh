#!/bin/bash

<<COMMENT
*********************************************************************
[:::::::::::::::DEFINE CONSTANTES:::::::::::DEFINE CONSTANTS::::::::]
*********************************************************************
COMMENT
#	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
DOMAIN=""				#my.domain.com
SERVERDIRECTORY=""		#my_project_folder
MYSQL_USER=""			#my_mysql_user
MYSQL_PWD=""			#my_mysql_pwd
MYSQL_ROOT_PWD=""		#my_root_pwd
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
#	Declaración | Declaration
#	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
declare -a dirs=(
	"/$SERVERDIRECTORY/installed" #	Obligatorio | Mandatary
	"/$SERVERDIRECTORY/dir1"	#Puede eliminarse | can delete
	"/$SERVERDIRECTORY/dir2"	#Puede eliminarse | can delete
)

#	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#	Verificando Directorios | Checking Directories
#	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
for dir in "${dirs[@]}"
do
	# Verificar si el directorio existe
	if [ -d "$dir" ]; then
		echo "Checkeando.... El directorio $dir existe. Continuamos..."
		echo "Checking.... Directory $dir exists. We continue..."
	else
		# Crear el directorio y mostrar un mensaje
		mkdir "$dir"
		chown "www-data:www-data" "$dir"
		echo "El Directorio $dir ha sido creado. Continuamos..."
		echo "The directory $dir has been created. We continue..."
	fi
done