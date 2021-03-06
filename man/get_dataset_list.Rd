% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_dataset_list.R
\name{get_dataset_list}
\alias{get_dataset_list}
\title{Download a full INSEE's dataset list}
\usage{
get_dataset_list()
}
\value{
a tibble with 5 columns :  id, Name.fr, Name.en, url, n_series
}
\description{
Download a full INSEE's dataset list
}
\details{
the datasets returned are the ones available through a SDMX query
}
\examples{
\donttest{insee_dataset = get_dataset_list()}

}
