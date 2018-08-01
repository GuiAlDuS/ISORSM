##comparación entre TMax - TMin y TMPsrf

tabla_general_GT75prct_Tmax %>% 
  inner_join(tabla_general_GT75prct_Tmin, by = c("ID.x", "Estacion", "Fecha", "LAT", "LONG")) %>% 
  mutate(diferencias = ValorModelo.x - ValorModelo.y) %>% 
  summarise(max = max(diferencias, na.rm = T), 
            min = min(diferencias, na.rm = T))


### Comando de CDO para extraer datos de esa estación en esos días
# cdo -outputtab,lat,lon,date,name,value -seldate,2007-05-15,2007-05-20 -remapnn,lon=-83.3_lat=9.15 PRATEsfc_07_c.nc

tabla_general_GT75prct_PRATE %>% filter(ID.x == 66, Fecha == "2007-05-17")

3.072e-06 * 10950

#con archivo _c
9.15  -83.3  2007-05-17 pratesfc 0.00601702 
9.15  -83.3  2007-05-17 pratesfc 0.00413542 
9.15  -83.3  2007-05-17 pratesfc 0.0261448 
9.15  -83.3  2007-05-17 pratesfc 0.0166472 
9.15  -83.3  2007-05-17 pratesfc 0.00550298 
9.15  -83.3  2007-05-17 pratesfc 0.010708 
9.15  -83.3  2007-05-17 pratesfc 0.00370893 

test <- c(0.00601702, 0.00413542, 0.0261448, 0.0166472, 0.00550298, 0.010708, 0.00370893)
test*3600 #mm/h
mean(test*86400) #mm/dia

#con archivo raw
9.15  -83.3  2007-05-17 pratesfc 0.0143452 
9.15  -83.3  2007-05-17 pratesfc 0.00196608 
9.15  -83.3  2007-05-17 pratesfc 0.00067584 
9.15  -83.3  2007-05-17 pratesfc 0.0110008 
9.15  -83.3  2007-05-17 pratesfc 0.00243098 
9.15  -83.3  2007-05-17 pratesfc 0.00196813 
9.15  -83.3  2007-05-17 pratesfc 0.00255181 
9.15  -83.3  2007-05-17 pratesfc 0.0019241 

test_raw <- c(0.0143452, 0.00196608, 0.00067584, 0.0110008, 0.00243098, 0.00196813, 0.00255181, 0.0019241)
test_raw*10800/3 #10800 segundos en 3 horas --- operación para convertir a valores por hora
test_raw*3600 #3600 segundos en 1 hora
test_raw*86400 #86400 segundos en 1 dia
mean(test_raw*86400) ##mm/dia ??


#datos TRIMM 
test_trmm <- c(13, 0, 0, 0, 0, 3.5, 6.5, 2.5) #mm/hr
test_trmm/3600 #mm/s
mean(test_trmm/3600*84600) #mm/dia ??



9.15  -83.3  2007-05-17 prate1sfc 0.00592077 
9.15  -83.3  2007-05-17 prate1sfc 0.00408013 
9.15  -83.3  2007-05-17 prate1sfc 0.0257249 
9.15  -83.3  2007-05-17 prate1sfc 0.0163942 
9.15  -83.3  2007-05-17 prate1sfc 0.00544154 
9.15  -83.3  2007-05-17 prate1sfc 0.0105329 
9.15  -83.3  2007-05-17 prate1sfc 0.00364954 

test1 <- c(0.00592077, 0.00408013, 0.0257249, 0.0163942, 0.00544154, 0.0105329, 0.00364954)
sum(test1)
sum(test1*10950)


9.15  -83.3  2007-05-17 prate2sfc 0.00531507 
9.15  -83.3  2007-05-17 prate2sfc 0.0037335 
9.15  -83.3  2007-05-17 prate2sfc 0.0230851 
9.15  -83.3  2007-05-17 prate2sfc 0.0148101 
9.15  -83.3  2007-05-17 prate2sfc 0.00506368 
9.15  -83.3  2007-05-17 prate2sfc 0.00941056 
9.15  -83.3  2007-05-17 prate2sfc 0.00326042 

test2 <- c(0.00531507, 0.0037335, 0.0230851, 0.0148101, 0.00506368, 0.00941056, 0.00326042)
sum(test2)
sum(test2*10950)

#revisar los datos originales(discos de Ana María)


#Revision con datos en Liberia
tabla_general_GT75prct_PRATE %>% 
  filter(ID.x == 33, Fecha >= as.Date("2007-05-10") & Fecha <= as.Date("2007-05-20"))


## cargar datos para todas las estaciones
PRATEsfc07 <- read_table2("/home/cigefi/Guillermo/ISORSM/PRATEsfc_tests/datosPRATEsfcEstaciones.txt")
#hay que eliminar líneas con encabezado repetido

test_PRATEsfc07 <- PRATEsfc07 %>% 
  select(-X6) %>% 
  na.omit %>% 
  rename(LAT = lat, LONG2 = lon, Fecha = date) %>% 
  mutate(LONG = round(LONG2-360, 4), LAT = round(LAT, 4), LONG2 = round(LONG2, 4)) %>% 
  inner_join(EstCoordNetcdf %>% 
              mutate(LAT = round(LAT, 4), LONG = round(LONG, 4)), by = c("LAT", "LONG")) %>% 
  mutate(mmdia = value*86400) %>% 
  group_by(LAT, LONG, Fecha, ID) %>%
  summarise(ValorModelo = mean(mmdia)) %>% 
  right_join(datosGT75 %>%
               mutate(LAT = round(LAT, 4), LONG = round(LONG, 4)) %>% 
               filter(Variable == "Precip" & aNo == 2007), 
             by = c("LAT", "LONG", "Fecha")) %>% 
  select(ID.x, Estacion, Variable, prctDias, Fecha, aNo, Valor, ValorModelo, LAT, LONG) %>% 
  mutate(diferencia = round(as.numeric(Valor) - ValorModelo, 2),
         prctDif = diferencia*100/as.numeric(Valor))

mean(abs(test_PRATEsfc07$diferencia), na.rm = T)
median(abs(test_PRATEsfc07$diferencia), na.rm = T)

ggplot(test_PRATEsfc07 %>% 
         group_by(ID.x, aNo) %>% 
         summarise(difMedia = median(diferencia, na.rm = T)), 
       aes(x = as.factor(ID.x), y = difMedia)) +
  geom_point()

ggplot(test_PRATEsfc07 %>% 
         group_by(ID.x, aNo) %>% 
         summarise(difPromed = mean(diferencia, na.rm = T)), 
       aes(x = as.factor(ID.x), y = difPromed)) +
  geom_point()


sum(is.infinite(test_PRATEsfc07$prctDif))

PRATEsfc07 %>% filter(!is.na(X6))  
  
datosGT75 %>% filter(Variable == "Precip" & aNo == 2007) %>% 
  anti_join(EstCoordNetcdf %>% mutate(LAT = round(LAT, 2)), by = c("LAT", "LONG"))
  
  
PRATEsfc07 %>% filter(is.na(lat))
 ## https://sebastiansauer.github.io/dplyr_filter/



ggplot(test_PRATEsfc07 %>% filter(diferencia <= 10000), 
       aes(diferencia)) + geom_histogram(bins = 100) + 
  scale_y_log10()

60 *test_PRATEsfc07 %>% filter(diferencia == 0)

#calcular totales por periodo
suma2007 <- test_PRATEsfc07 %>% 
  group_by(ID.x) %>%
  summarise(SumaMed = sum(as.numeric(Valor), na.rm = T), 
            SumaMod = sum(round(ValorModelo,3), na.rm = T),
            SumaDif = abs(SumaMed - SumaMod))

ggplot(suma2007, aes(x=SumaDif)) + 
  geom_histogram(bins = 100)

ggplot(test_PRATEsfc07 %>% 
         mutate(mes = month(Fecha)) %>% 
         group_by(ID.x, mes) %>% 
         summarise(difMedia = median(diferencia, na.rm = T))
         , aes(x=as.factor(ID.x), y =difMedia)) + 
  geom_point() + 
  facet_grid(vars(mes))

ggplot(test_PRATEsfc07 %>% 
         mutate(mes = month(Fecha)) 
       , aes(x=as.factor(ID.x), y=diferencia)) + 
  geom_boxplot() + 
  ylim(NA, 800) +
  facet_grid(vars(mes))



########### Prueba con todos los datos

#recordar quitar el "pound" de primer línea
PRATEsfc <- read_table2("/media/cigefi/ISO_CA/PRATE_TMPsfc_raw/datosMetEstaciones_PRATEsfc_raw.txt")
#PRATEsfc <- read_table2("/media/cigefi/ISO_CA/PRATE_TMPsfc/datosMetEstaciones_prate_corregido.txt")

#comparaciones
corregido <- PRATEsfc %>% 
  select(-X6) %>% 
  mutate(value = replace(value, which(value<0), NA))

raw <- PRATEsfc %>% 
  select(-X6) %>% 
  mutate(value = replace(value, which(value<0), NA))

sum(corregido$value, na.rm = T)
sum(raw$value, na.rm = T)

corregido %>% filter(lat == 9.15 & date == '2007-05-17') %>% 
  group_by(date) %>% 
  summarise(prom = (mean(value))) %>% 
  mutate(PrecipD = prom * 86400)

raw %>% filter(lat == 9.15 & date == '2007-05-17') %>% 
  group_by(date) %>% 
  summarise(prom = (mean(value))) %>% 
  mutate(PrecipD = prom * 86400)

rm(corregido, raw)

##########

test_PRATEsfc <- PRATEsfc %>% 
  select(-X6) %>% 
  na.omit %>% 
  rename(LAT = lat, LONG2 = lon, Fecha = date) %>% 
  mutate(LONG = round(LONG2-360, 4), LAT = round(LAT, 4), LONG2 = round(LONG2, 4)) %>% 
  inner_join(EstCoordNetcdf %>% 
               mutate(LAT = round(LAT, 4), LONG = round(LONG, 4)), by = c("LAT", "LONG")) %>% 
  mutate(mmdia = value*86400) %>% 
  group_by(LAT, LONG, Fecha, ID) %>%
  summarise(ValorModelo = mean(mmdia)) %>% 
  right_join(datosGT75 %>%
               mutate(LAT = round(LAT, 4), LONG = round(LONG, 4)) %>% 
               filter(Variable == "Precip" & aNo >= 1980 & aNo <= 2012), 
             by = c("LAT", "LONG", "Fecha")) %>% 
  select(ID.x, Estacion, Variable, prctDias, Fecha, aNo, Valor, ValorModelo, LAT, LONG) %>% 
  mutate(diferencia = round(as.numeric(Valor) - ValorModelo, 2),
         prctDif = diferencia*100/as.numeric(Valor))

mean(abs(test_PRATEsfc$diferencia), na.rm = T)
median(abs(test_PRATEsfc$diferencia), na.rm = T)

#grafico punto cada año en diferencia media diaria
ggplot(test_PRATEsfc %>% 
         group_by(ID.x, aNo) %>% 
         summarise(difMedia = median(diferencia, na.rm = T)), 
       aes(x = as.factor(ID.x), y = difMedia)) +
  geom_point()

#grafico punto cada año en diferencia promedio diaria
ggplot(test_PRATEsfc %>% 
         group_by(ID.x, aNo) %>% 
         summarise(difPromed = mean(diferencia, na.rm = T)), 
       aes(x = as.factor(ID.x), y = difPromed)) +
  geom_point()

#revisar valores extremos para cerciorarse que se importaron correctamente
summary(as.numeric(test_PRATEsfc$Valor))
summary(test_PRATEsfc$ValorModelo)
summary(test_PRATEsfc$diferencia)

ggplot(test_PRATEsfc, aes(x = ValorModelo)) + geom_histogram(bins = 100)

#histograma de valores menores a 0
ggplot(test_PRATEsfc %>% 
         filter(ValorModelo < 0),
       aes(x = ValorModelo)) + 
  geom_histogram()

#cambiar valores menores de 0 a NA
test_PRATEsfc_mod <- PRATEsfc %>% 
  select(-X6) %>% 
  mutate(value = replace(value, which(value<0), NA)) %>% 
  na.omit %>% 
  rename(LAT = lat, LONG2 = lon, Fecha = date) %>% 
  mutate(LONG = round(LONG2-360, 4), LAT = round(LAT, 4), LONG2 = round(LONG2, 4)) %>% 
  inner_join(EstCoordNetcdf %>% 
               mutate(LAT = round(LAT, 4), LONG = round(LONG, 4)), by = c("LAT", "LONG")) %>% 
  mutate(mmdia = value*86400) %>% 
  group_by(LAT, LONG, Fecha, ID) %>%
  summarise(ValorModelo = mean(mmdia)) %>% 
  right_join(datosGT75 %>%
               mutate(LAT = round(LAT, 4), LONG = round(LONG, 4)) %>% 
               filter(Variable == "Precip" & aNo >= 1980 & aNo <= 2012), 
             by = c("LAT", "LONG", "Fecha")) %>% 
  select(ID.x, Estacion, Variable, prctDias, Fecha, aNo, Valor, ValorModelo, LAT, LONG) %>% 
  mutate(diferencia = round(as.numeric(Valor) - ValorModelo, 2),
         prctDif = diferencia*100/as.numeric(Valor))

#test_PRATEsfc_mod <- test_PRATEsfc %>% mutate(ValorModelo = replace(ValorModelo, which(ValorModelo<0) , NA))
mean(test_PRATEsfc_mod$ValorModelo, na.rm = T)
median(test_PRATEsfc_mod$ValorModelo, na.rm = T)

test_PRATEsfc_mod <- test_PRATEsfc_mod %>% mutate(diferencia = as.numeric(Valor) - ValorModelo)
mean(test_PRATEsfc_mod$diferencia, na.rm = T)
median(test_PRATEsfc_mod$diferencia, na.rm = T)

summary(test_PRATEsfc_mod$ValorModelo)
summary(as.numeric(test_PRATEsfc_mod$Valor))
summary(test_PRATEsfc_mod$diferencia)
quantile(test_PRATEsfc_mod$ValorModelo, c(.9, .95, .99, .999), na.rm = T)
quantile(as.numeric(test_PRATEsfc_mod$Valor), c(.9, .95, .99, .999), na.rm = T)
quantile(as.numeric(test_PRATEsfc_mod$diferencia), c(.9, .95, .99, .999), na.rm = T)

#histograma de valores modelados -- eliminando valores mayores a 450mm diarios (~ día más lluvioso medido)
ggplot(test_PRATEsfc_mod, aes(x = ValorModelo)) + geom_density() #+ xlim(450,NA)

ggplot(test_PRATEsfc_mod, aes(x = diferencia)) + geom_density() #+ xlim(NA,-100)

test_PRATEsfc_mod %>% 
  filter(diferencia < -450) %>% 
  group_by(LAT, LONG) %>% 
  summarise(n = n())

fechasOutliers <- test_PRATEsfc_mod %>% 
  filter(diferencia < -450) %>% 
  group_by(Fecha) %>% 
  summarise(nDif = n()) %>% 
  mutate(n = 69, PnDif = nDif/n*100)

ggplot(fechasOutliers %>% 
         mutate(aNo = year(Fecha)) %>% 
         group_by(aNo) %>% 
         summarise(NaNo = sum(n)), 
       aes(x = aNo, y = NaNo)) + geom_point()

#ver rango de valores de datos crudos
#cambiar valores menores de 0 a NA
test_PRATEsfc_raw <- PRATEsfc %>% 
  select(-X6) %>% 
  mutate(value = replace(value, which(value<0), NA)) %>% 
  na.omit

ggplot(test_PRATEsfc_raw, aes(x = as.numeric(value))) + geom_histogram() #+ scale_y_log10()

summary(test_PRATEsfc_raw$value)

quantile(as.numeric(test_PRATEsfc_raw$value), c(.9, .95, .99, .999))

library(outliers)
outlier(test_PRATEsfc_mod$ValorModelo)
outlier(test_PRATEsfc_mod$diferencia) #solo un outlier
outlier(test_PRATEsfc_raw$value)


## eliminando el 1% de los datos con valores más altos (valor límite = 0.005mm/s)
#tabla_general_GT75prct_PRATE
test_PRATEsfc_mod_99pct <- PRATEsfc %>% 
  select(-X6) %>% 
  mutate(value = replace(value, which(value<0 | value>0.005), NA)) %>% 
  #na.omit %>% 
  rename(LAT = lat, LONG2 = lon, Fecha = date) %>% 
  mutate(LONG = round(LONG2-360, 4), LAT = round(LAT, 4), LONG2 = round(LONG2, 4)) %>% 
  inner_join(EstCoordNetcdf %>% 
               mutate(LAT = round(LAT, 4), LONG = round(LONG, 4)), by = c("LAT", "LONG")) %>% 
  mutate(mmdia = value*86400, na.rm = T) %>% 
  group_by(LAT, LONG, Fecha, ID) %>%
  summarise(ValorModelo = mean(mmdia, na.rm = T)) %>% 
  right_join(datosGT75 %>%
               mutate(LAT = round(LAT, 4), LONG = round(LONG, 4)) %>% 
               filter(Variable == "Precip" & aNo >= 1980 & aNo <= 2012), 
             by = c("LAT", "LONG", "Fecha")) %>% 
  select(ID.x, Estacion, Variable, prctDias, Fecha, aNo, Valor, ValorModelo, LAT, LONG) %>% 
  mutate(diferencia = round(as.numeric(Valor) - ValorModelo, 2))

colSums(is.na(tabla_general_GT75prct_PRATE))

summary(tabla_general_GT75prct_PRATE$diferencia)
summary(abs(tabla_general_GT75prct_PRATE$diferencia))

ggplot(tabla_general_GT75prct_PRATE, aes(x = diferencia)) + geom_density()


#paso a promedios mensuales y diferencia

#promedio de número de días por mes para periodo 80-13
diasmes <- tabla_general_GT75prct_PRATE %>% 
  group_by(Fecha, aNo) %>% 
  summarise(n = n()) %>% 
  mutate(mes = month(Fecha)) %>% 
  group_by(mes, aNo) %>% 
  summarise(diasMes = mean(n())) %>% 
  group_by(mes) %>% 
  summarise(promDiasMes = mean(diasMes))

#acumulado mensual
library(DescTools)
difMensualPRATE <- tabla_general_GT75prct_PRATE %>% 
  mutate (mes = month(Fecha)) %>% 
  group_by(LAT, LONG, mes, aNo) %>% 
  summarise(MesValor = sum(as.numeric(Valor), na.rm = T), 
            MesValorModelo = sum(ValorModelo, na.rm = T)) %>%
  group_by(LAT, LONG, mes) %>% 
  summarise(promMesValor = mean(MesValor, na.rm = T),
            promMesValorModelo = mean(MesValorModelo, na.rm = T),
            RMSEmensual = RMSE(MesValorModelo, MesValor, na.rm = T),
            MAEmensual = MAE(MesValorModelo, MesValor, na.rm = T)) %>% 
  mutate(difMensual = (promMesValor - promMesValorModelo))

difMensualPRATE %>% group_by(mes) %>% summarise(promedio = abs(mean(difMensual, na.rm = T)))

#acumulado anual
difAnualPRATE <- tabla_general_GT75prct_PRATE %>% 
  group_by(LAT, LONG, aNo) %>% 
  summarise(AcumValor = sum(as.numeric(Valor), na.rm = T), 
            AcumValorModelo = sum(ValorModelo, na.rm = T)) %>%
  mutate(AcumValor = na_if(AcumValor, 0)) %>% 
  group_by(LAT, LONG) %>% 
  summarise(PromAcumValor = mean(AcumValor, na.rm =T),
            PromAcumValorModelo = mean(AcumValorModelo, na.rm = T),
            DifAnual = mean(AcumValor - AcumValorModelo, na.rm = T),
            RMSEanual = RMSE(AcumValorModelo, AcumValor, na.rm = T),
            MAEanual = MAE(AcumValorModelo, AcumValor, na.rm = T))

difAnualPRATE %>% arrange(desc(abs(DifAnual)))


mean(difAnualPRATE$DifAnual)

library(sf)
library(tmap)
library(rmapshaper)
celdasEstaciones <- st_read("/home/cigefi/Guillermo/ISORSM/shapes/celdas_estaciones.shp")
bordeCR <- st_read("/home/cigefi/Guillermo/ISORSM/shapes/ExtCostaRica.gpkg")
elevacionCR <- st_read("/home/cigefi/Guillermo/ISORSM/shapes/ElevacionCR.gpkg")
elevacionCR <- ms_simplify(elevacionCR)
elevacionCR <- ms_simplify(elevacionCR)

tm_shape(elevacionCR) + 
  tm_polygons("ELEVACION", 
              palette = "Greys",
              n = 5, 
              border.col="transparent",
              title = "Elevation (MASL)") +
  tm_shape(st_as_sf(difMensualPRATE, 
                    coords = c("LONG", "LAT"), 
                    crs = 4326)) +
  tm_bubbles("MAEmensual", 
             title.size = "Mean absolute error (mm/month)",
             alpha = 0.5) +
  tm_facets(by = "mes", 
            nrow = 4) +
  tm_style("gray")


tm_shape(elevacionCR) + 
  tm_polygons("ELEVACION", 
              palette = "Greys",
              n = 5, 
              border.col="transparent",
              title = "Elevation (MASL)") +
  tm_shape(st_as_sf(difAnualPRATE,
                    coords = c("LONG", "LAT"),
                    crs = 4326)) +
  tm_bubbles("MAEanual",
             title.size = "Mean absolute error (mm/year)",
             alpha = 0.5) +
  tm_style("gray")
  

library(plotrix)
taylor.diagram(as.numeric(tabla_general_GT75prct_PRATE$Valor), tabla_general_GT75prct_PRATE$ValorModelo)
taylor.diagram(as.numeric(tabla_general_GT75prct_Tmax$Valor), tabla_general_GT75prct_Tmax$ValorModelo)
taylor.diagram(as.numeric(tabla_general_GT75prct_Tmin$Valor), tabla_general_GT75prct_Tmin$ValorModelo)

taylor.diagram(difMensualPRATE$promMesValor, difMensualPRATE$promMesValorModelo)

taylor.diagram(difAnualPRATE$promMesValor, difMensualPRATE$promMesValorModelo)
