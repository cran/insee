#' @noRd
create_insee_folder = function(){

  insee_folder = file.path(rappdirs::user_data_dir(), "insee")
  list_folders = c(insee_folder, file.path(insee_folder, "insee"))

  for(ifile in 1:length(list_folders)){
    if(!file.exists(list_folders[ifile])){
      dir_creation = dir.create(list_folders[ifile])
    }
  }

  test_file = file.path(insee_folder, "insee", paste0(openssl::md5("test_file"), ".rds"))
  if(!file.exists(test_file)){
    test = 1
    saveRDS(test, file = test_file)
  }


}
