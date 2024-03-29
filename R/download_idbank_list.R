#' @noRd
download_idbank_list = function(dataset = NULL, label = FALSE){

  insee_data_dir = tempdir()
  dir_creation_fail = try(create_insee_folder(), silent = TRUE)

  insee_local_dir = file.path(rappdirs::user_data_dir(), "R", "insee", "insee")

  if(("try-error" %in% class(dir_creation_fail))|(!file.exists(insee_local_dir))){
    insee_local_dir = tempdir()
  }

  file_to_dwn = Sys.getenv("INSEE_idbank_dataset_path")
  
  idbank_list_file_cache = file.path(insee_data_dir,
                                 paste0(openssl::md5(file_to_dwn), ".rds"))

 if(!file.exists(idbank_list_file_cache)){

   mapping = dwn_idbank_files()

   mapping = mapping[,c(1:3)]
   names(mapping) = c("nomflow", "idbank", "cleFlow")

   saveRDS(mapping, file = idbank_list_file_cache)
 }else{
   mapping = readRDS(idbank_list_file_cache)
 }

  # filter data
  idbank_list_defaul_value = FALSE

  if(!is.null(dataset)){
    dataset_list = unique(mapping[, "nomflow"])

    dataset_param_in_list = which(dataset %in% dataset_list)

    if(length(dataset_param_in_list) > 0){

      dataset_in_list = dataset[dataset_param_in_list]

      mapping = mapping[which(mapping[, "nomflow"] %in% dataset_in_list),]

      dot_vector = stringr::str_count(mapping$cleFlow, pattern = "\\.")
      n_col = max(dot_vector) + 1
      mapping = separate_col(df = mapping, col = "cleFlow",
                             sep = "\\.", into = paste0("dim", 1:n_col))

      if(length(dataset_in_list) > 1){
        pb = utils::txtProgressBar(min = 1, max = length(dataset_in_list), initial = 1, style = 3)
      }

      mapping_final =
        dplyr::bind_rows(
          lapply(1:length(dataset_in_list),
                 function(j){

                   dataset_name = dataset_in_list[j]

                   new_col_names = get_dataset_dimension(dataset = dataset_name)
                   mapping_dataset = dplyr::filter(.data = mapping, .data$nomflow == dataset_name)

                   if(!is.null(new_col_names)){

                     mapping_dataset_sep =
                       separate_col(df = mapping_dataset, col = "cleFlow",
                                    sep = "\\.", into = new_col_names)

                     if(label == TRUE){
                       for(new_col_name in new_col_names){

                         i_col = which(new_col_names == new_col_name)
                         cl_col = attr(new_col_names,'cl')[i_col]

                         dimension_labels = get_dimension_values(dimension = cl_col, col_name = new_col_name)

                         if(!is.null(dimension_labels)){
                           mapping_dataset_sep = dplyr::left_join(mapping_dataset_sep, dimension_labels, by = new_col_name)
                         }

                       }

                     }

                     mapping_dataset_sep = clean_table(set_metadata_col(mapping_dataset_sep))

                     dataset_metadata_file_cache = file.path(insee_local_dir,
                                                             paste0(openssl::md5(sprintf("%s_metadata_file", dataset_name)), ".rds"))

                     saveRDS(mapping_dataset_sep, file = dataset_metadata_file_cache)

                     if(length(dataset_in_list) > 1){
                       utils::setTxtProgressBar(pb, j)
                     }

                     return(mapping_dataset_sep)
                   }else{
                     return(mapping_dataset)
                   }


                 }))

    }else{
      idbank_list_defaul_value = TRUE
      warning("Dataset names do not exist, the table by default is provided")
    }
  }else{
    idbank_list_defaul_value = TRUE
  }

  if(idbank_list_defaul_value == TRUE){
    dot_vector = stringr::str_count(mapping$cleFlow, pattern = "\\.")
    n_col = max(dot_vector) + 1

    mapping_final = separate_col(df = mapping, col = "cleFlow",
                                 sep = "\\.", into = paste0("dim", 1:n_col))

    if(label == TRUE){
      warning("Dataset names are missing, labels will not be provided")
    }
  }

  mapping_final = set_metadata_col(mapping_final)

  return(mapping_final)
}

