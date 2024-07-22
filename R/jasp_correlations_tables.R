jasp_correlation_table_depends_on <- function() {
  return(
    c(
      "x",
      "y",
      "r",
      "n",
      "conf_level",
      "x_variable_name",
      "y_variable_name",
      "show_details",
      "switch"
    )
  )
}



jasp_es_r_prep <- function(jaspResults, options, ready) {
  # Handles
  from_raw <- options$switch == "from_raw"

  overviewTable <- createJaspTable(title = "Linear correlation")

  overviewTable$dependOn(jasp_correlation_table_depends_on())

  overviewTable$addColumnInfo(
    name = "x_variable_name",
    title = "<i>X</i> variable",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "y_variable_name",
    title = "<i>Y</i> variable",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "effect",
    title = "Effect",
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = "<i>r</i>",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "LL",
    title = "LL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )

  overviewTable$addColumnInfo(
    name = "UL",
    title = "UL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )

  if (from_raw) {
    overviewTable$addColumnInfo(
      name = "sxy",
      title = "<i>s<sub>Y.X</sub></i>",
      type = "number"
    )

  }

  if (options$show_details) {
    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE<sub>r</sub></i>",
      type = "number"
    )

  }

  overviewTable$addColumnInfo(
    name = "n",
    title = "<i>N</i><sub>pairs</sub>",
    type = "integer"
  )

  overviewTable$addColumnInfo(
    name = "df",
    title = "<i>df</i>",
    type = "integer"
  )


  overviewTable$showSpecifiedColumnsOnly <- TRUE


  if (ready) {
      overviewTable$setExpectedSize(1)
  }

  jaspResults[["es_r"]] <- overviewTable



  return()

}




jasp_regression_prep <- function(jaspResults, options, ready) {
  # Handles

  overviewTable <- createJaspTable(title = "Regression")

  overviewTable$dependOn(jasp_correlation_table_depends_on())

  overviewTable$addColumnInfo(
    name = "component",
    title = "Component",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "values",
    title = "Value",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "LL",
    title = "LL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )

  overviewTable$addColumnInfo(
    name = "UL",
    title = "UL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )


  overviewTable$showSpecifiedColumnsOnly <- TRUE


  if (ready) {
    overviewTable$setExpectedSize(1)
  }

  jaspResults[["regression"]] <- overviewTable



  return()

}
