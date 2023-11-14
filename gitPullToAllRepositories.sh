# Se recomienda ejecutarlo desde la consola de "Git Bash".

TOKEN="123"

lRepositorioNoEncontrado=""
lErrorCredenciales=""
lErrorPorInternetVpn=""
lErrorRepositorioEnOtroServidor=""
lNoEsRepositorioDeGit=""
lRepositorioActualizado=""
lErrorDesconocido=""
lRepositorioEnConflictos=""


echo "Se inicia la actualización local de los repositorios, por favor espere..."


for proyecto in */ ; do
    cd $proyecto
    
	# Verifica si es un repositorio Git validando si el subdirectorio contiene un directorio ".git".
	if [ -d .git ]; then
		# OUTPUT=$(git -c "http.extraheader=AUTHORIZATION: bearer $TOKEN" pull 2>&1) # TOKEN para GitHub.
		OUTPUT=$(git -c "http.extraheader=PRIVATE-TOKEN: $TOKEN" pull 2>&1) # TOKEN para GitLab.
		
        EXIT_STATUS=$?
		
        if [ "$EXIT_STATUS" -ne 0 ]; then
			if echo "$OUTPUT" | grep -q 'Authentication failed'; then
				if [ -z "$lErrorCredenciales" ]; then
					lErrorCredenciales="$proyecto"
				else
					lErrorCredenciales+=" $proyecto"
				fi
			elif echo "$OUTPUT" | grep -q 'for could not be found'; then
				if [ -z "$lRepositorioNoEncontrado" ]; then
					lRepositorioNoEncontrado="$proyecto"
				else
					lRepositorioNoEncontrado+=" $proyecto"
				fi
			elif echo "$OUTPUT" | grep -q 'connect to server'; then
				if [ -z "$lErrorRepositorioEnOtroServidor" ]; then
					lErrorRepositorioEnOtroServidor="$proyecto"
				else
					lErrorRepositorioEnOtroServidor+=" $proyecto"
				fi
			elif echo "$OUTPUT" | grep -q 'Could not resolve host'; then
				if [ -z "$lErrorPorInternetVpn" ]; then
					lErrorPorInternetVpn="$proyecto"
				else
					lErrorPorInternetVpn+=" $proyecto"
				fi
			else
				if [ -z "$lRepositorioEnConflictos" ]; then
					lRepositorioEnConflictos="$proyecto"
				else
					lRepositorioEnConflictos+=" $proyecto"
				fi
			fi
		elif echo "$OUTPUT" | grep -q 'Already up to date'; then
			if [ -z "$lRepositorioActualizado" ]; then
				lRepositorioActualizado="$proyecto"
			else
				lRepositorioActualizado+=" $proyecto"
			fi
		else
			if [ -z "$lErrorDesconocido" ]; then
				lErrorDesconocido="$proyecto"
			else
				lErrorDesconocido+=" $proyecto"
			fi
		fi
    else
		if [ -z "$lNoEsRepositorioDeGit" ]; then
			lNoEsRepositorioDeGit="$proyecto"
		else
			lNoEsRepositorioDeGit+=" $proyecto"
		fi
    fi
    
	cd ..
done

if [ -n "$lRepositorioNoEncontrado" ]; then
	echo -e "\n- Repositorios no encontrados:"
	
	for repositorioNoEncontrado in $lRepositorioNoEncontrado; do
		echo "$repositorioNoEncontrado"
	done
fi

if [ -n "$lErrorCredenciales" ]; then
	echo -e "\n* Repositorios con errores de credenciales:"
	
	for errorCredenciales in $lErrorCredenciales; do
		echo "$errorCredenciales"
	done
fi

if [ -n "$lErrorPorInternetVpn" ]; then
	echo -e "\n* No se pudo acceder a los siguientes repositorios por motivo de conexión a Internet o VPN:"
	
	for errorPorInternetVpn in $lErrorPorInternetVpn; do
		echo "$errorPorInternetVpn"
	done
fi

if [ -n "$lErrorRepositorioEnOtroServidor" ]; then
	echo -e "\n* Quizás estos repositorios se encuentren en un servidor distinto o en otra cuenta de usuario:"
	
	for errorRepositorioEnOtroServidor in $lErrorRepositorioEnOtroServidor; do
		echo "$errorRepositorioEnOtroServidor"
	done
fi

if [ -n "$lNoesRepositorioDeGit" ]; then
	echo -e "\n- Las siguientes carpetas no son repositorios de Git:"
	
	for noEsRepositorioDeGit in $lNoEsRepositorioDeGit; do
		echo "$noEsRepositorioDeGit"
	done
fi

if [ -n "$lRepositorioActualizado" ]; then
	echo -e "\n+ Los siguientes repositorios locales se actualizaron correctamente:"
	
	for repositorioActualizado in $lRepositorioActualizado; do
		echo "$repositorioActualizado"
	done
fi

if [ -n "$lErrorDesconocido" ]; then
	echo -e "\n* Error desconocido, verificar los siguientes repositorios:"
	
	for errorDesconocido in $lErrorDesconocido; do
		echo "$errorDesconocido"
	done
fi

if [ -n "$lRepositorioEnConflictos" ]; then
	echo -e "\n* Los siguientes repositorios presentan conflictos:"
	
	for repositorioEnConflictos in $lRepositorioEnConflictos; do
		echo "$repositorioEnConflictos"
	done
fi
