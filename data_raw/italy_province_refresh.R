# Pulling raw data
update_italy_province <- function(){
`%>%` <- magrittr::`%>%`

df1 <- read.csv("https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-province/dpc-covid19-ita-province.csv", stringsAsFactors = FALSE) %>%
  stats::setNames(c("date_temp", "state", "region_code", "region_name", "province_code",
                    "province_name", "province_abb", "lat", "long", "total_cases",
                    "notes_it", "notes_en")) %>%
  dplyr::mutate(date = lubridate::ymd(substr(date_temp, 1, 10))) %>%
  dplyr::select(-date_temp, -state, - notes_it, -notes_en) %>%
  dplyr::select(date, dplyr::everything()) %>%
  dplyr::arrange(date)

head(df1)


df2 <- df1 %>% dplyr::mutate(date = date + lubridate::days(1)) %>%
  dplyr::mutate(total_cases_lag = total_cases) %>%
  dplyr::select(-total_cases)

head(df1)
head(df2)

italy_province <- df1 %>% dplyr::left_join(df2,
                                           by = c("date",
                                                  "region_code", "region_name",
                                                  "province_code", "province_name",
                                                  "province_abb",
                                                  "lat", "long")) %>%
  dplyr::mutate(new_cases = total_cases - total_cases_lag)  %>%
  dplyr::select(-total_cases_lag) %>%
  dplyr::mutate(new_cases = ifelse(is.na(new_cases), total_cases, new_cases)) %>%
  dplyr::mutate(province_spatial = province_name)

italy_province$province_spatial <- ifelse(italy_province$province_spatial == "Aosta", "Aoste", italy_province$province_spatial)
italy_province$province_spatial <- ifelse(italy_province$province_spatial == "Bolzano", "Bozen", italy_province$province_spatial)
italy_province$province_spatial <- ifelse(italy_province$province_spatial == "Crotone", "Crotene", italy_province$province_spatial)
italy_province$province_spatial <- ifelse(italy_province$province_spatial == "Massa Carrara", "Massa-Carrara", italy_province$province_spatial)
italy_province$province_spatial <- ifelse(italy_province$province_spatial == "Monza e della Brianza", "Monza e Brianza", italy_province$province_spatial)
italy_province$province_spatial <- ifelse(italy_province$province_spatial == "Oristano", "Oristrano", italy_province$province_spatial)
italy_province$province_spatial <- ifelse(italy_province$province_spatial == "Reggio di Calabria", "Reggio Calabria", italy_province$province_spatial)
italy_province$province_spatial <- ifelse(italy_province$province_spatial == "Reggio nell'Emilia", "Reggio Emilia", italy_province$province_spatial)
italy_province$province_spatial <- ifelse(italy_province$province_spatial == "Torino", "Turin", italy_province$province_spatial)
italy_province$province_spatial <- ifelse(italy_province$province_spatial == "Barletta-Andria-Trani", "Barletta-Andria Trani", italy_province$province_spatial)



if(ncol(italy_province) != 11){
  stop("The number of columns is invalid")
} else if(nrow(italy_province)< 6900){
  stop("The number of raws does not match the minimum number of rows")
} else if(min(italy_province$date) != as.Date("2020-02-24")){
  stop("The starting date is invalid")
}

italy_province_csv <- read.csv("https://raw.githubusercontent.com/Covid19R/covid19italy/master/csv/italy_province.csv", stringsAsFactors = FALSE) %>%
  dplyr::mutate(date = as.Date(date))

if(ncol(italy_province_csv) != 11){
  stop("The number of columns is invalid")
} else if(nrow(italy_province_csv)< 6900){
  stop("The number of raws does not match the minimum number of rows")
} else if(min(italy_province_csv$date) != as.Date("2020-02-24")){
  stop("The starting date is invalid")
}


if(nrow(italy_province) > nrow(italy_province_csv)){
  print("Updates available")
  usethis::use_data(italy_province, overwrite = TRUE)
  write.csv(italy_province, "csv/italy_province.csv", row.names = FALSE)
  print("The region dataset was updated")
} else {
  print("Updates are not available")
}

return(print("Done..."))

}


update_italy_province()


