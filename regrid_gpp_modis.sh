#!/bin/bash

## generate weights file (is going to be used for all files to speed up the process)
infil="./2015/MODIS-C06__MOD17A2-8-Daily-GPP__0.05deg__20150509__NTSG-UMT__UHAM-ICDC__fv0.01.nc"
cdo genbil,~/data/landmasks/area_halfdeg.nc ${infil} weights_gpp_modis.nc

## remap all files
list=`find . -name MODIS*.nc`
for infil in ${list}
do
	outfil=${infil/0\.05deg/0\.5deg}
	sudo cdo remap,~/data/landmasks/area_halfdeg.nc,weights_gpp_modis.nc ${infil} ${outfil}
done

for iyr in {2000..2015}
do
	echo $iyr
	
	## combine all 0.5 deg files of each year into a single file
	sudo cdo mergetime ${iyr}/MODIS-C06__MOD17A2-8-Daily-GPP__0.5deg__${iyr}????__NTSG-UMT__UHAM-ICDC__fv0.01.nc ${iyr}/MODIS-C06__MOD17A2-8-Daily-GPP__0.5deg__${iyr}__NTSG-UMT__UHAM-ICDC__fv0.01.nc
	
	## get annual total GPP by summing over time dimension (total GPP in 8-day period is given, in kg C m-2)
	sudo cdo yearsum ${iyr}/MODIS-C06__MOD17A2-8-Daily-GPP__0.5deg__${iyr}__NTSG-UMT__UHAM-ICDC__fv0.01.nc ${iyr}/MODIS-C06__MOD17A2-8-Daily-GPP__0.5deg__${iyr}__NTSG-UMT__UHAM-ICDC__fv0.01_ann.nc 

done

## combine annual files in single file
list=`find . -name MODIS-C06__MOD17A2-8-Daily-GPP__0.5deg__????__NTSG-UMT__UHAM-ICDC__fv0.01_ann.nc`
cdo mergetime $list MODIS-C06__MOD17A2-8-Daily-GPP__0.5deg____NTSG-UMT__UHAM-ICDC__fv0.01_ann.nc