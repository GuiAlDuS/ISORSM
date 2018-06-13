#!/bin/bash

#mostrar fecha y hora de inicio de script
echo date

#crear nuevo directorio
mkdir nc${1}
echo "Directorio /nc${1} creado"

#copiar archivo .ctl a nuevo directorio
rsync -zvh r_pgb.ctl nc${1}
echo 'Archivo ctl copiado al nuevo directorio'

#copiar archivo .gs al nuevo directorio
rsync -zvh script_grads.gs nc${1}
echo 'Archivo script gs copiado al nuevo directorio'

#ir al nuevo directorio
cd nc${1}

#editar archivo .ctl y modificar año. VERIFICAR QUE SEA SOLO EN LAS PRIMERAS DOS LINEAS
sed -i -e "1s/1980/${1}/g; 2s/1980/${1}/g"  r_pgb.ctl
echo "Archivo ctl actualizado a valores del año ${1}"

#modificar script de grads y cambiar año por últimos dos números
sed -i -e "s/80/${1:2:2}/g" script_grads.gs
echo "Archivo script gs actualizado a valores del año ${1:2:2}"

echo date
#correr grads con script desde la línea de comandos
grads -bpcx "run script_grads.gs"
echo 'Procesamiento de GrADS finalizado'
echo date
#https://www.cyberciti.biz/tips/bash-shell-parameter-substitution-2.html

echo date
#script para CDO y sumas/promedios diarios
declare -a sumas=("CPRAT1sfc_${1:2:2}.nc" "CPRAT2sfc_${1:2:2}.nc" "CPRATsfc_${1:2:2}.nc")

for files in ./*.nc; do
	if [[ "${sumas[@]}" =~ "$files" ]]; then
		cdo daysum "$files" "${files%.*nc}_d.nc"
	else
		cdo daymean "$files" "${files%.*nc}_d.nc"
	fi &
done
wait
echo 'Procesamiento de CDO finalizado'

echo date
#eliminar archivos intermedios
shopt -s extglob
rm !(*_d.nc)
echo 'Eliminación de archivos temporales lista'

#mostrar fecha y hora de finalizaación de script
echo date
