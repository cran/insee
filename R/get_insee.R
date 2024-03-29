#' Get data from INSEE BDM database with a SDMX query link
#'
#' @details Get data from INSEE BDM database with a SDMX query link.
#' This function is mainly for package internal use.
#' It is used by the functions get_insee_dataset, get_insee_idbank and get_dataset_list.
#' The data is cached, hence all queries are only run once per R session.
#' The user can disable the download display in the console with the following command :
#' Sys.setenv(INSEE_download_verbose = "FALSE").
#' The use of cached data can be disabled with : Sys.setenv(INSEE_no_cache_use = "TRUE").
#' All queries are printed in the console with this command: Sys.setenv(INSEE_print_query = "TRUE").
#' @param link SDMX query link
#' @param step argument used only for internal package purposes to tweak download display
#' @return a tibble containing the data
#' @examples
#' \donttest{
#' insee_link = "http://www.bdm.insee.fr/series/sdmx/data/SERIES_BDM"
#' insee_query = file.path(insee_link, paste0("010539365","?", "firstNObservations=1"))
#' data = get_insee(insee_query)
#' }
#' @export
get_insee = function(link, step = "1/1"){

  if(missing(link)){
    warning("link is missing")
    return(NULL)
  }

  insee_download_verbose = if(Sys.getenv("INSEE_download_verbose") == "TRUE"){TRUE}else{FALSE}
  insee_value_as_numeric = if(Sys.getenv("INSEE_value_as_numeric") == "TRUE"){TRUE}else{FALSE}
  insee_print_query = if(Sys.getenv("INSEE_print_query") == "TRUE"){TRUE}else{FALSE}
  insee_no_cache_use = if(Sys.getenv("INSEE_no_cache_use") == "TRUE"){TRUE}else{FALSE}

  if(insee_download_verbose){
    if(insee_print_query == TRUE) {
      msg = sprintf("Query : %s", link)
      message(crayon::style(msg, "black"))
    }
  }

  insee_data_dir = tempdir()

  file_cache = file.path(insee_data_dir, paste0(openssl::md5(link), ".rds"))

  if((!file.exists(file_cache)) | insee_no_cache_use){

    data_final = read_sdmx_slow(link, step)

    if(!is.null(data_final)){

      s = try(saveRDS(data_final, file = file_cache), silent = TRUE)

      if(!"try-error" %in% class(s)){
        if(insee_download_verbose){
          msg = sprintf("Data cached : %s\n", file_cache)

          message(crayon::style(msg, "green"))
        }
      }

    }else{
      msg = "An error occurred"
      msg = paste0(msg, "\n\nIf a work computer is used, a proxy server may prevent this package from accessing the internet")
      msg = paste0(msg, "\nIn this case, please ask your IT support team to provide you with the proxy server settings")
      msg = paste0(msg, "\nThen, have a look at the following tutorial to use these settings:\n")
      msg = paste0(msg, "https://cran.r-project.org/web/packages/insee/vignettes/insee.html")
      message(crayon::style(msg, "red"))
    }
  }else{

    if(insee_download_verbose){
      msg = "Cached data has been used"
      message(crayon::style(msg, "green"))
    }

    data_final = readRDS(file_cache)
  }

  return(data_final)
}
