#!/bin/bash

cdo_intfld () {
	##-----------------------------
	## Calculates the globally integrated field
	## using CDO. This preserves other dimensions
	## besides longitude and latitude.
	## argument 1: input file name
	## argument 2: output file name
	##-----------------------------

	cdo gridarea $1 gridarea.nc
	cdo mulc,1 -seltimestep,1 $1 tmp.nc
	cdo div tmp.nc tmp.nc ones.nc
	cdo selname,gpp ones.nc mask.nc
	cdo mul mask.nc gridarea.nc gridarea_masked.nc
	cdo mul gridarea_masked.nc $1 tmp2.nc
	cdo fldsum tmp2.nc tmp3.nc
	cdo mulc,1e-15 tmp3.nc $2

	## remove temporary files
	rm gridarea.nc tmp.nc ones.nc mask.nc gridarea_masked.nc tmp2.nc tmp3.nc

	return 0

}
