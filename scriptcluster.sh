#!/bin/bash

shopt -s extglob
start=`date +%s`

declare -a bisiestos=("1980" "1984" "1988" "1992" "1996" "2000" "2004" "2008" "2012" "2016")

for h in {1980..2006}; do
	cd /home1/guillermo/

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
	sed -i -e "1s/1980/${h}/g; 2s/1980/${h}/g; 44s/1980/${h}/g"  r_pgb.ctl
	echo "Archivo ctl actualizado a valores del año ${h}"

	#modificar script de grads y cambiar año por últimos dos números
	sed -i -e "s/80/${h:2:2}/g" script_grads.gs
	echo "Archivo script gs actualizado a valores del año ${h:2:2}"

	#correr grads con script desde la línea de comandos
	grads -bpcx "run script_grads.gs"
	echo 'Procesamiento de GrADS finalizado'

	#correr CDO para modificar periodos de tiempo
	if [[ "${bisiestos[@]}" =~ ${h} ]]; then
		for files in ./*.nc; do
		cdo settaxis,"${h}-01-01",00:00:00,10950seconds "${files}" "${files%.*nc}_c.nc"
		done
	else
		for files in ./*.nc; do
		cdo settaxis,"${h}-01-01",00:00:00,10920seconds "${files}" "${files%.*nc}_c.nc"
		done
	fi	
	
	rm -v !(*_c.nc)
	echo 'Eliminación de archivos temporales iniciales lista'; 

	#https://www.cyberciti.biz/tips/bash-shell-parameter-substitution-2.html

	#script para CDO y sumas/promedios diarios
	declare -a sumas=("CPRAT1sfc_${h:2:2}.nc" "CPRAT2sfc_${h:2:2}.nc" "CPRATsfc_${h:2:2}.nc")

	for files in *.nc; do
		if [[ "${sumas[@]}" =~ "$files" ]]; then
			cdo daysum "$files" "${files%.*nc}_d.nc"
		else
			cdo daymean "$files" "${files%.*nc}_d.nc"
		fi &
	done
	wait
	echo 'Procesamiento de CDO finalizado'

	#eliminar archivos intermedios
	rm -v !(*_d.nc)
	echo 'Eliminación de archivos temporales lista';

	#copia de archivos a directorio final en disco duro externo
	mkdir /media/guillermo/ISO_CA/nc${h}
	rsync -vh *.nc /media/guillermo/ISO_CA/nc${h}
	rm -rv /home1/guillermo/nc${h}
done

end=`date +%s`
echo runtime=$((end-start))
