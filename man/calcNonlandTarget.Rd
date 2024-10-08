% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calcNonlandTarget.R
\name{calcNonlandTarget}
\alias{calcNonlandTarget}
\title{calcNonlandTarget}
\usage{
calcNonlandTarget(
  target = "luh2mod",
  years = seq(1995, 2015, 5),
  timestepLength = years[2] - years[1]
)
}
\arguments{
\item{target}{name of the target dataset, currently only "luh2" and "luh2mod" are supported}

\item{years}{years to aggregate to/to return}

\item{timestepLength}{length of the timestep in years, determines the
first year that is read: min(years) - timestepLength + 1}
}
\value{
nonland target data
}
\description{
Prepare the high resolution nonland target dataset for
harmonization and downscaling, checking data for consistency before returning.
Reads in yearly data and aggregates according to the given timestep length.
}
\author{
Pascal Sauer
}
