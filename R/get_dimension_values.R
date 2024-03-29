#' @noRd
get_dimension_values = function(dimension, col_name ,name = FALSE){

  dir_creation_fail = try(create_insee_folder(), silent = TRUE)
  insee_local_dir = file.path(rappdirs::user_data_dir(), "R", "insee", "insee")

  if(("try-error" %in% class(dir_creation_fail))|(!file.exists(insee_local_dir))){
    insee_local_dir = tempdir()
  }

  insee_sdmx_link_codelist =  Sys.getenv("INSEE_sdmx_link_codelist")
  link = sprintf("%s/%s", insee_sdmx_link_codelist, dimension)

  dimension_file_cache = file.path(insee_local_dir,
                                   paste0(openssl::md5(link), ".rds"))

  dimension_name_file_cache = file.path(insee_local_dir,
                                        paste0(openssl::md5(paste0(link, "Name")), ".rds"))

  if(name){
    if(file.exists(dimension_name_file_cache)){
      dimension_name = readRDS(dimension_name_file_cache)
      return(dimension_name)
    }
  }

  if(!file.exists(dimension_file_cache)){

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

    if(!"try-error" %in% class(response)){

        response_content = try(httr::content(response, encoding = "UTF-8"), silent = TRUE)

        if(!"try-error" %in% class(response_content)){

          content_list = xml2::as_list(response_content)
          data = tibble::as_tibble(content_list)
          data_code = try(data[[1]][[2]][["Codelists"]][["Codelist"]], silent = TRUE)

          if(!"try-error" %in% class(data_code)){

            code_element = which(names(data_code) == "Code")
            name_element = which(names(data_code) == "Name")

            if(!file.exists(dimension_name_file_cache)){
              if(length(name_element) > 0){
                data_name = data_code[name_element]


                if(attr(data_name[[1]], "lang") == "fr"){
                  dimension_label_fr = try(data_name[[1]][[1]], silent = TRUE)
                  dimension_label_en = try(data_name[[2]][[1]], silent = TRUE)
                }else{
                  dimension_label_fr = try(data_name[[2]][[1]], silent = TRUE)
                  dimension_label_en = try(data_name[[1]][[1]], silent = TRUE)
                }
                if("try-error" %in% class(dimension_label_fr)){
                  dimension_label_fr = "Missing"
                }
                if("try-error" %in% class(dimension_label_en)){
                  dimension_label_en = "Missing"
                }
                dimension_name = data.frame(dimension = col_name,
                                            label_fr = dimension_label_fr,
                                            label_en = dimension_label_en,
                                            stringsAsFactors = F)

                saveRDS(dimension_name, file = dimension_name_file_cache)

              }
            }else{
              dimension_name = readRDS(dimension_name_file_cache)
            }
            if(name){
              return(dimension_name)
            }

            if(!name){
              if(length(code_element) > 0){

                data_code = data_code[code_element]

                labels = dplyr::bind_rows(lapply(1:length(data_code), function(i){

                  if(attr(data_code[[i]][[1]], "lang") == "fr"){
                    label_fr = try(data_code[[i]][[1]][[1]], silent = TRUE)
                    label_en = try(data_code[[i]][[2]][[1]], silent = TRUE)
                  }else{
                    label_fr = try(data_code[[i]][[2]][[1]], silent = TRUE)
                    label_en = try(data_code[[i]][[1]][[1]], silent = TRUE)
                  }

                  if("try-error" %in% class(label_fr)){
                    label_fr = "Missing"
                  }
                  if("try-error" %in% class(label_en)){
                    label_en = "Missing"
                  }

                  df = data.frame(code = attr(data_code[[i]], "id"),
                                  label_fr = label_fr,
                                  label_en = label_en,
                                  stringsAsFactors = F)

                  return(df)
                }))

                names(labels) = c(col_name, paste0(col_name, "_label_fr"), paste0(col_name, "_label_en"))

                saveRDS(labels, file = dimension_file_cache)

                return(labels)

              }else{return(NULL)}
            }

          }else{return(NULL)}

        }else{return(NULL)}

    }else{return(NULL)}

  }else{

    labels = readRDS(dimension_file_cache)
    return(labels)
  }
}
