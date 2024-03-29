#' @noRd
get_dataset_dimension = function(dataset){

  insee_sdmx_link_datastructure = Sys.getenv("INSEE_sdmx_link_datastructure")
  link = file.path(insee_sdmx_link_datastructure, dataset)

  dir_creation_fail = try(create_insee_folder(), silent = TRUE)

  insee_local_dir = file.path(rappdirs::user_data_dir(), "R", "insee", "insee")

  if(("try-error" %in% class(dir_creation_fail))|(!file.exists(insee_local_dir))){
    insee_local_dir = tempdir()
  }

  dataset_dim_file_cache = file.path(insee_local_dir,
                                     paste0(openssl::md5(link), ".rds"))

  if(!file.exists(dataset_dim_file_cache)){

    option_mode = Sys.getenv("INSEE_download_option_mode")
    option_method = Sys.getenv("INSEE_download_option_method")
    option_port = Sys.getenv("INSEE_download_option_port")
    option_extra = Sys.getenv("INSEE_download_option_extra")
    option_proxy = Sys.getenv("INSEE_download_option_proxy")
    option_auth = Sys.getenv("INSEE_download_option_auth")

    if(option_extra == ""){
      response = try(httr::GET(link), silent = TRUE)
    }else{

      proxy = httr::use_proxy(url = option_proxy,
                              port = as.numeric(option_port),
                              auth = option_auth)

      response = httr::GET(url = link,
                           config = proxy)
    }

    response_content = try(httr::content(response, encoding = "UTF-8"), silent = TRUE)

    if(!"try-error" %in% class(response_content)){

      content_list = xml2::as_list(response_content)
      data = tibble::as_tibble(content_list)

      l = try(data[[1]][["Structures"]][["DataStructures"]][["DataStructure"]][["DataStructureComponents"]][["DimensionList"]])

      if(!"try-error" %in% class(l)){
        if(!is.null(l)){

          list_dimension = unlist(lapply(1:length(l),
                                         function(i){
                                           dim = attr(l[[i]], 'id')
                                           return(dim)
                                         }))

          list_dimension_cl = unlist(lapply(1:length(l),
                                            function(i){
                                              cl_dim = if_null_na(attr(l[[i]]$LocalRepresentation$Enumeration$Ref, 'id'))
                                              return(cl_dim)
                                            }))

          list_dimension = list_dimension[!is.na(list_dimension_cl)]
          list_dimension_cl = list_dimension_cl[!is.na(list_dimension_cl)]

          attr(list_dimension, 'cl') = list_dimension_cl

          saveRDS(list_dimension, file = dataset_dim_file_cache)

        }else{return(NULL)}
      }else{return(NULL)}
    }else{return(NULL)}
  }else{
    list_dimension = readRDS(file = dataset_dim_file_cache)
  }

  return(list_dimension)
}
