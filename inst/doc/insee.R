## ----setup,echo=FALSE, include=FALSE------------------------------------------
# setup chunk
# Sys.setenv("NOT_CRAN" = "TRUE")
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

