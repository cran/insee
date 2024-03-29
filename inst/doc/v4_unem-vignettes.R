## ----setup,echo=FALSE, include=FALSE------------------------------------------
# setup chunk
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")),"true")
knitr::opts_chunk$set(purl = NOT_CRAN)
library(insee)
library(tidyverse)

embed_png <- function(path, dpi = NULL) {
  meta <- attr(png::readPNG(path, native = TRUE, info = TRUE), "info")
  if (!is.null(dpi)) meta$dpi <- rep(dpi, 2)
  knitr::asis_output(paste0(
    "<img src='", path, "'",
    " width=", round(meta$dim[1] / (meta$dpi[1] / 96)),
    " height=", round(meta$dim[2] / (meta$dpi[2] / 96)),
    " />"
  ))}

## ----message=FALSE, warning=FALSE, include=FALSE------------------------------
library(kableExtra)
library(magrittr)
library(htmltools)
library(prettydoc)

## ---- echo = FALSE------------------------------------------------------------
embed_png("unem.png")

## ----message=FALSE, warning = FALSE, eval = FALSE-----------------------------
#  
#  library(tidyverse)
#  library(insee)
#  
#  dataset_list = get_dataset_list()
#  
#  df_idbank_list_selected =
#    get_idbank_list("CHOMAGE-TRIM-NATIONAL") %>% #Unemployment dataset
#    add_insee_title() %>%
#    filter(INDICATEUR == "CTTXC") %>% #unemployment rate based on ILO standards
#    filter(REF_AREA == "FM") %>%  # all France excluding overseas departements
#    filter(SEXE == 0) # men and women
#  
#  list_idbank = df_idbank_list_selected %>% pull(idbank)
#  
#  data = get_insee_idbank(list_idbank, startPeriod = "2000-01") %>% split_title()
#  
#  ggplot(data, aes(x = DATE, y = OBS_VALUE, colour = TITLE_EN2)) +
#    geom_line() +
#    geom_point() +
#    ggtitle("French unemployment rate, by age") +
#    labs(subtitle = sprintf("Last updated : %s", data$TIME_PERIOD[1]))
#  

