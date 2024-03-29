% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_idbank_list.R
\name{get_idbank_list}
\alias{get_idbank_list}
\title{Download a full INSEE's series key list}
\usage{
get_idbank_list(..., dataset = NULL, update = FALSE)
}
\arguments{
\item{...}{one or several dataset names}

\item{dataset}{if a dataset name is provided, only a subset of the data is delivered, otherwise
all the data is returned, and column names refer directly to data dimensions}

\item{update}{It is FALSE by default, if it is set to TRUE, it triggers the metadata update. This update is automatically triggered once every 6 months.}
}
\value{
a tibble the idbank dataset
}
\description{
Download a full INSEE's series key list
}
\details{
Download a mapping dataset between INSEE series keys (idbank) and SDMX series names.
Under the hood the get_idbank_list uses download.file function from utils, the user can change the mode argument with the following
command : Sys.getenv(INSEE_download_option_idbank_list = "wb")
If INSEE makes an update, the user can also change the zip file downloaded, the data file contained in the zip and data the separator  :
Sys.setenv(INSEE_idbank_dataset_path = "new_zip_file_link")
Sys.setenv(INSEE_idbank_sep = ",")
Sys.setenv(INSEE_idbank_dataset_file = "new_data_file_name")
}
\examples{
\donttest{
# download datasets list
dt = get_dataset_list()
# use a dataset name to retrieve the series key list related to the dataset
idbank_list = get_idbank_list('CNT-2014-PIB-EQB-RF')
}
}
