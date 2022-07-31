/************************************************************************************
* Tutorial basado 
"Econometría Espacial usando Stata. Guía Teórico-Aplicada"	 					 
Autor: Marcos Herrera (CONICET-IELDE, UNSa, Argentina)
e-mail: mherreragomez@gmail.com
  
* El tutorial presenta los comandos para generar las siguientes acciones:

1. Análisis exploratorio de datos espaciales:  
	- Representación por medio de Mapas.
	- Creación de matrices de pesos espaciales.
*/
	
global DATA = "C:/Users/Joaquin/Desktop/UdeSA/Maestría en Economía/Herramientas Computacionales Para Investigación/Data Visualization (R)/Tarea-5/Inputs"
cd "$DATA"

********************************************************************************************
/* 					  INSTALACIÓN DE LOS PAQUETES NECESARIOS    						  */
********************************************************************************************

ssc install spmap
ssc install shp2dta
*net install sg162, from(http://www.stata.com/stb/stb60)
*net install st0292, from(http://www.stata-journal.com/software/sj13-2)
net install spwmatrix, from(http://fmwww.bc.edu/RePEc/bocode/s)
*net install splagvar, from(http://fmwww.bc.edu/RePEc/bocode/s)
*ssc install xsmle.pkg
*ssc install xtcsd
*net install st0446.pkg

************************************************************************************
************************************************************************************
/*            CHAPTER 2: ANÁLISIS EXPLORATORIO DE DATOS ESPACIALES  		   	  */
************************************************************************************
************************************************************************************

************************************************************************************
/*                      (1) LECTURA Y MAPAS DE DATOS  	  		                  */
************************************************************************************

* Leer la información shape en Stata

shp2dta using london_sport.shp, database(ls) coord(coord_ls) genc(c) genid(id) replace

/* El comando anterior genera dos nuevos archivos: datos_shp.dta y coord.dta
El primero contiene los atributos (variables) del shape. 
El segundo contiene la información sobre la formas geográficas. 
Se generan en el archivo de datos tres variables:
id: identifica a la región. 
c: genera el centroide por medio de las variables: x_c: longitud, y_c: latitud
*/

use ls, clear
describe

use coord_ls, clear
describe

/* Importamos y transformamos los datos de Excel a formato Stata */
import delimited "$DATA/mps-recordedcrime-borough.csv", clear 
* En Stata necesitamos que la variable tenga el mismo nombre en ambas bases para juntarlas
rename borough name
* preserve 
keep if crimetype == "Theft & Handling"
collapse (sum) crimecount, by(name)
save "crime.dta", replace

describe

/* Uniremos ambas bases: london_sport y crime. Su usa la función merge con la variable name que se encuentra en ambas bases  */

use ls, clear
merge 1:1 name using crime.dta
*merge 1:1 name using crime.dta, keep(3) nogen
*keep if _m==3
drop _m

save london_crime_shp.dta, replace

************************************************************************************
* Representación por medio de mapas

use london_crime_shp.dta, clear

* Mapa de cuantiles:
spmap crimecount using coord_ls, id(id) clmethod(q) cln(6) title("Count of Thefts & Handling") subtitle("London - quantiles - 04/2011-03/2013") legend(size(medium) position(5) xoffset(15.05)) fcolor(YlOrRd) plotregion(margin(b+15)) ndfcolor(gray) name(g1,replace)  
graph export theftspquantile.png, width(605) height(378)

spmap crimecount using coord_ls, id(id) clmethod(e) cln(6) title("Count of Thefts & Handling") subtitle("London - equidistant intervals - 04/2011-03/2013") legend(size(medium) position(5) xoffset(15.05)) fcolor(YlOrRd) plotregion(margin(b+15)) ndfcolor(gray) name(g1,replace)  
graph export theftspequidistant.png, width(605) height(378)