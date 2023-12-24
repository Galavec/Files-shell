# Version: 2.2.0
# Nota, se recomienda ejecutarlo desde la consola de "Git Bash" con versión de Bash "4.0".

TOKEN="123"

declare -A listas

echo "Se inicia la actualización local de los repositorios, por favor espere..."

imprimir_list() {
    local list=$1
    local mensaje=$2

    if [ -n "${!list}" ]; then
        echo -e "\n$mensaje"
        for repositorio in ${!list}; do
            echo "$repositorio"
        done
    fi
}

for proyecto in */ ; do
    cd $proyecto
	
	echo "Trabajando en $proyecto ..."
    
    # Verifica si es un repositorio Git validando si el subdirectorio contiene un directorio ".git".
    if [ -d .git ]; then
		# OUTPUT=$(git -c "http.extraheader=AUTHORIZATION: bearer $TOKEN" pull 2>&1) # GitHub con TOKEN y mediante HTTPS
		# OUTPUT=$(git pull 2>&1) # GitHub/GitLab usando clave SSH. Vincula la clave en el 'Agente SSH' de tu sistema operativo para que no te la vuelva a solicitar.
        OUTPUT=$(git -c "http.extraheader=PRIVATE-TOKEN: $TOKEN" pull 2>&1) # TOKEN para GitLab.
        EXIT_STATUS=$?
        
        if [ "$EXIT_STATUS" -ne 0 ]; then
            if echo "$OUTPUT" | grep -q 'Authentication failed'; then
                listas["lErrorCredenciales"]+="$proyecto "
            elif echo "$OUTPUT" | grep -q 'for could not be found'; then
                listas["lRepositorioNoEncontrado"]+="$proyecto "
            elif echo "$OUTPUT" | grep -q 'connect to server'; then
                listas["lErrorRepositorioEnOtroServidor"]+="$proyecto "
            elif echo "$OUTPUT" | grep -q 'Could not resolve host'; then
                listas["lErrorPorInternetVpn"]+="$proyecto "
            else
                listas["lRepositorioEnConflictos"]+="$proyecto "
            fi
        elif echo "$OUTPUT" | grep -Eq 'Already up to date|files changed|insertions|deletions'; then
			listas["lRepositorioActualizado"]+="$proyecto "
		else
			listas["lErrorDesconocido"]+="$proyecto "
        fi
    else
        listas["lNoEsRepositorioDeGit"]+="$proyecto "
    fi
    
    cd ..
done

imprimir_list listas[lNoEsRepositorioDeGit] "- Las siguientes carpetas no son repositorios de Git:"
imprimir_list listas[lErrorCredenciales] "* Repositorios con errores de credenciales:"
imprimir_list listas[lRepositorioNoEncontrado] "- Repositorios no encontrados:"
imprimir_list listas[lErrorRepositorioEnOtroServidor] "* Quizás estos repositorios se encuentren en un servidor distinto o en otra cuenta de usuario:"
imprimir_list listas[lErrorPorInternetVpn] "* No se pudo acceder a los siguientes repositorios por motivo de conexión a Internet o VPN:"
imprimir_list listas[lRepositorioEnConflictos] "* Los siguientes repositorios presentan conflictos:"
imprimir_list listas[lRepositorioActualizado] "+ Los siguientes repositorios locales se actualizaron correctamente:"
imprimir_list listas[lErrorDesconocido] "* Error desconocido, verificar los siguientes repositorios:"
