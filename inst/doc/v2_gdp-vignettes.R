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
embed_png("gdp.png")

## ----message=FALSE, warning=FALSE, eval=FALSE---------------------------------
#  library(tidyverse)
#  library(insee)
#  
#  df_idbank_list_selected =
#    get_idbank_list("CNT-2014-PIB-EQB-RF") %>% # Gross domestic product balance
#    filter(FREQ == "T") %>% #quarter
#    add_insee_title() %>% #add titles
#    filter(OPERATION == "PIB") %>% #GDP
#    filter(NATURE == "TAUX") %>% #rate
#    filter(CORRECTION == "CVS-CJO") #SA-WDA, seasonally adjusted, working day adjusted
#  
#  idbank = df_idbank_list_selected %>% pull(idbank)
#  
#  data = get_insee_idbank(idbank)
#  
#  #plot
#  ggplot(data, aes(x = DATE, y = OBS_VALUE)) +
#    geom_col() +
#    ggtitle("French GDP growth rate, quarter-on-quarter, sa-wda") +
#    labs(subtitle = sprintf("Last updated : %s", data$TIME_PERIOD[1]))
#  

