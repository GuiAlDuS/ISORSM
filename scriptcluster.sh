#!/bin/bash

for h in {1990..2006}; do
	cd $home

	#crear nuevo directorio
	mkdir nc${h}
	echo "Directorio /nc${h} creado"

	#copiar archivo .ctl a nuevo directorio
	rsync -zvh r_pgb.ctl nc${h}
	echo 'Archivo ctl copiado al nuevo directorio'

	#copiar archivo .gs al nuevo directorio
	rsync -zvh script_grads.gs nc${h}
	echo 'Archivo script gs copiado al nuevo directorio'

	#ir al nuevo directorio
	cd nc${h}

	#editar archivo .ctl y modificar año. VERIFICAR QUE SEA SOLO EN LAS PRIMERAS DOS LINEAS
	sed -i -e "1s/1980/${h}/g; 2s/1980/${h}/g"  r_pgb.ctl
	echo "Archivo ctl actualizado a valores del año ${h}"

	#modificar script de grads y cambiar año por últimos dos números
	sed -i -e "s/80/${h:2:2}/g" script_grads.gs
	echo "Archivo script gs actualizado a valores del año ${h:2:2}"

	#correr grads con script desde la línea de comandos
	grads -bpcx "run script_grads.gs"
	echo 'Procesamiento de GrADS finalizado'

	#https://www.cyberciti.biz/tips/bash-shell-parameter-substitution-2.html

	#script para CDO y sumas/promedios diarios
	declare -a sumas=("CPRAT1sfc_${h:2:2}.nc" "CPRAT2sfc_${h:2:2}.nc" "CPRATsfc_${h:2:2}.nc")

	for files in ./*.nc; do
		if [[ "${sumas[@]}" =~ "$files" ]]; then
			cdo daysum "$files" "${files%.*nc}_d.nc"
		else
			cdo daymean "$files" "${files%.*nc}_d.nc"
		fi &
	done
	wait
	echo 'Procesamiento de CDO finalizado'

	#eliminar archivos intermedios
	shopt -s extglob
	rm !(*_d.nc)
	echo 'Eliminación de archivos temporales lista'
	;
done