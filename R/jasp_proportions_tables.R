jasp_pdiff_table_depends_on <- function() {
  return(
    c(
      "outcome_variable",
      "grouping_variable",
      "conf_level",
      "show_details",
      "reference_p",
      "switch",
      "cases",
      "not_cases",
      "comparison_cases",
      "comparison_not_cases",
      "reference_cases",
      "reference_not_cases",
      "case_label",
      "not_case_label",
      "outcome_variable_name",
      "grouping_variable_name",
      "grouping_variable_level1",
      "grouping_variable_level2",
      "count_NA"
    )
  )
}

# Prep an overview table
jasp_poverview_prep <- function(jaspResults, options, ready, estimate = NULL, levels = 1) {

  # Handles
  from_raw <- FALSE
  if (!is.null(options$switch)) {
    from_raw <- options$switch == "from_raw"
  }

  # Title
  overviewTable <- createJaspTable(title = "Overview")

  # Depends on
  overviewTable$dependOn(
    jasp_pdiff_table_depends_on()
  )

  if (levels > 1) {
    overviewTable$addColumnInfo(
      name = "grouping_variable_name",
      title = "Grouping variable",
      type = "string",
      combine = TRUE
    )

    overviewTable$addColumnInfo(
      name = "grouping_variable_level",
      title = options$grouping_variable,
      type = "string",
      combine = TRUE
    )
  }


  # Columns
  overviewTable$addColumnInfo(
    name = "outcome_variable_name",
    title = "Outcome variable",
    type = "string",
    combine = TRUE
  )

  # Columns
  overviewTable$addColumnInfo(
    name = "outcome_variable_level",
    title = "Level",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "cases",
    title = "Cases",
    type = "integer"
  )

  overviewTable$addColumnInfo(
    name = "n",
    title = "<i>N</i>",
    type = "integer"
  )

  overviewTable$addColumnInfo(
    name = "P",
    title = "<i>P</i>",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "P_LL",
    title = "LL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )
  overviewTable$addColumnInfo(
    name = "P_UL",
    title = "UL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )

  if (options$show_details) {

    overviewTable$addColumnInfo(
      name = "P_SE",
      title = "<i>SE</i><sub>Proportion</sub>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "P_adjusted",
      title = "<i>P</i><sub>adjusted</sub>",
      type = "number"
    )


  }


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready) {
    if (from_raw) {
      overviewTable$setExpectedSize(length(options$outcome_variable) * 2)
    } else {
      overviewTable$setExpectedSize(2)
    }
  }

  jaspResults[["overviewTable"]] <- overviewTable


  return()

}


# Prep a pdiff table
jasp_es_proportion_difference_prep <- function(jaspResults, options, ready) {
  # Handles
  from_raw <- options$switch == "from_raw"

  overviewTable <- createJaspTable(title = "Proportion Difference")

  overviewTable$dependOn(
    c(
      jasp_pdiff_table_depends_on()
    )
  )

  overviewTable$addColumnInfo(
    name = "outcome_variable_name",
    title = "Outcome variable",
    type = "string",
    combine = TRUE
  )


  effect_title <- paste(options$grouping_variable, "Effect", "</BR>")

  overviewTable$addColumnInfo(
    name = "effect_plus",
    title = effect_title,
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = "<i>P</i>",
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


  if (options$show_details) {
    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "effect_size_adjusted",
      title = "<i>P</i><sub>adjusted</sub>",
      type = "number"
    )
  }

  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready) {
    if (from_raw) {
      overviewTable$setExpectedSize(length(options$outcome_variable) * 2)
    } else {
      overviewTable$setExpectedSize(2)
    }
  }

  jaspResults[["es_proportion_difference"]] <- overviewTable



  return()

}



jasp_es_proportion_prep <- function(jaspResults, options, ready, table_name, table_title, effect_label = "<i>P</i>") {
  # Handles
  from_raw <- options$switch == "from_raw"


  overviewTable <- createJaspTable(title = table_title)

  overviewTable$dependOn(
    c(
      jasp_pdiff_table_depends_on(),
      if (table_name == "es_phi") "show_phi" else NULL,
      if (table_name == "es_odds_ratio") "show_ratio" else NULL
    )
  )

  if (table_name != "es_phi") {
    overviewTable$addColumnInfo(
      name = "outcome_variable_name",
      title = "Outcome variable",
      type = "string",
      combine = TRUE
    )

  }


  effect_title <- paste(options$grouping_variable, "Effect", "</BR>")

  overviewTable$addColumnInfo(
    name = if (table_name != "es_phi") "effect_plus" else "effect",
    title = effect_title,
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = effect_label,
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


  if (options$show_details & table_name %in% c("es_proportion_difference", "es_phi")) {
    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE</i>",
      type = "number"
    )

  }

  if (options$show_details & table_name == "es_proportion_difference") {

    overviewTable$addColumnInfo(
      name = "effect_size_adjusted",
      title = "<i>P</i><sub>adjusted</sub>",
      type = "number"
    )
  }


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  multiplier <- 1
  if (table_name == "es_proportion_difference") multiplier <- 3
  oc_multiplier <- 1
  if (table_name == "es_proportion_difference") oc_mutiplier <- length(options$outcome_variable)

  if (ready) {
    if (from_raw) {
      overviewTable$setExpectedSize(1 * oc_multiplier * multiplier)
    } else {
      overviewTable$setExpectedSize(1 * mutliplier)
    }
  }

  jaspResults[[table_name]] <- overviewTable



  return()

}

