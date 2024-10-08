#' calcLandHighRes
#'
#' This function performs the downscaling: It calculates a high resolution dataset
#' from the low resolution input dataset and the high resolution target dataset
#' using the given downscaling method.
#'
#' @param input name of an input dataset, currently only "magpie"
#' @param target name of a target dataset, currently only "luh2"
#' @param harmonizationPeriod Two integer values, before the first given
#' year the target dataset is used, after the second given year the input
#' dataset is used, in between harmonize between the two datasets
#' @param downscaling name of downscaling method, currently only "magpieClassic"
#' @return downscaled land use data
#' @author Jan Philipp Dietrich
calcLandHighRes <- function(input = "magpie", target = "luh2mod",
                            harmonizationPeriod = c(2015, 2050), downscaling = "magpieClassic") {
  x <- calcOutput("LandHarmonized", input = input, target = target,
                  harmonizationPeriod = harmonizationPeriod, aggregate = FALSE)

  xTarget <- calcOutput("LandTarget", target = target, aggregate = FALSE)
  stopifnot(harmonizationPeriod[1] %in% terra::time(xTarget))
  xTarget <- as.magpie(xTarget[[terra::time(xTarget) == harmonizationPeriod[1]]])

  mapping <- calcOutput("ResolutionMapping", input = input, target = target, aggregate = FALSE)

  if (downscaling == "magpieClassic") {
    out <- toolDownscaleMagpieClassic(x[, getYears(x, as.integer = TRUE) >= harmonizationPeriod[1], ],
                                      xTarget, mapping)
  } else {
    stop("Unsupported downscaling method \"", downscaling, "\"")
  }

  primSecCategories <- c("primf", "primn", "secdf", "secdn")
  out[, , primSecCategories] <- toolPrimFix(out[, , primSecCategories])

  toolExpectTrue(identical(unname(getSets(out)), c("x", "y", "year", "data")),
                 "Dimensions are named correctly")
  toolExpectTrue(setequal(getItems(out, dim = 3), getItems(x, dim = 3)),
                 "Land categories remain unchanged")
  toolExpectLessDiff(out[, harmonizationPeriod[1], ], xTarget, 10^-5,
                     paste("In", harmonizationPeriod[1], "output equals target"))
  toolExpectTrue(all(out >= 0), "All values are >= 0")

  outSum <- dimSums(out, dim = 3)
  toolExpectLessDiff(outSum, outSum[, 1, ], 10^-5,
                     "Total land area per cell in output stays constant over time")

  globalSumIn <- dimSums(x[, getYears(out), ], dim = 1)
  globalSumOut <- dimSums(out, dim = 1)
  toolExpectLessDiff(dimSums(globalSumIn, 3), dimSums(globalSumOut, 3), 10^-5,
                     "Total global land area remains unchanged")
  toolExpectLessDiff(globalSumIn, globalSumOut, 10^-5,
                     "Global area of each land type remains unchanged")
  toolExpectTrue(all(out[, -1, c("primf", "primn")] <= setYears(out[, -nyears(out), c("primf", "primn")],
                                                                getYears(out)[-1])),
                 "primf and primn are never expanding", falseStatus = "warn")

  return(list(x = out,
              class = "magpie",
              isocountries = FALSE,
              unit = "Mha",
              min = 0,
              description = "Downscaled land use data"))
}
