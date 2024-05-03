jasp_estimate_mdiff_one <- function(jaspResults, dataset = NULL, options, ...) {


  esciText <- createJaspHtml(text = "Hello, world")

  jaspResults[["esciText"]] <- esciText


  ready <- (length(options$variables) > 0)

  if (ready) {
    # read dataset
    dataset <- jasp_estimate_mdiff_one_read_data(dataset, options)


    if (is.null(jaspResults[["overviewTable"]]))
        jasp_estimate_mdiff_one_overview(jaspResults, dataset, options, ready)

  }

  return()
}



jasp_estimate_mdiff_one_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(.readDataSetToEnd(columns.as.numeric = options$variables))
}


jasp_estimate_mdiff_one_overview <- function(jaspResults, dataset, options, ready) {
  overviewTable <- createJaspTable(title = "Overview")

  overviewTable$dependOn(c("variables", "ciLevel"))


  overviewTable$addColumnInfo(name = "outcome_variable_name",   title = "Outcome variable",   type = "string", combine = TRUE)
  overviewTable$addColumnInfo(name = "mean",          title = "M",     type = "number")
  overviewTable$addColumnInfo(
    name = "mean_LL",
    title = "LL",
    type = "number",
    format = "sf:4",
    overtitle = paste0(100 * options$ciLevel, "% CI for Proportion")
  )
  overviewTable$addColumnInfo(
    name = "mean_UL",
    title = "UL",
    type = "number",
    format = "sf:4",
    overtitle = paste0(100 * options$ciLevel, "% CI for Proportion")
  )

  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$variables))

  jaspResults[["overviewTable"]] <- overviewTable

  if (!ready)
    return()

  jasp_estimate_mdiff_one_overview_fill(overviewTable, dataset, options)

  return()

}


jasp_estimate_mdiff_one_overview_fill <- function(overviewTable, dataset, options) {

  colnames(dataset) <- decodeColNames(dataset)

  res <- list()
  res$overview <- data.frame(
    outcome_variable_name = c("One", "Two"),
    mean = c(10, 11.1),
    mean_LL = c(8, 9.1),
    mean_UL = c(12, 13.1)
  )

  res <- esci::estimate_mdiff_one(
    data = dataset,
    outcome_variable = options$variables,
    conf_level = options$ciLevel,
    save_raw_data = FALSE
  )


  for (x in 1:nrow(res$overview)) {
      overviewTable$addRows(
        list(
          outcome_variable_name = res$overview$outcome_variable_name[[x]],
          mean = res$overview$mean[[x]],
          mean_LL = res$overview$mean_LL[[x]],
          mean_UL = res$overview$mean_UL[[x]]
        )
      )
  }

  return(overviewTable)
}

