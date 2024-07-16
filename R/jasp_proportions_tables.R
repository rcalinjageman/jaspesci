jasp_pdiff_table_depends_on <- function() {
  return(
    c(
      "outcome_variable",
      "conf_level",
      "show_details",
      "reference_p",
      "switch",
      "cases",
      "not_cases",
      "case_label",
      "not_case_label",
      "outcome_variable_name"
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

  if (levels > 1) {
    overviewTable$addColumnInfo(
      name = "grouping_variable_level",
      title = options$grouping_variable,
      type = "string",
      combine = TRUE
    )
  }

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


# Prep a hypothesis evaluation table
jasp_phe_prep <- function(jaspResults, options, ready, mytest = NULL) {
  # Handles
  is_difference <- if (options$effect_size %in% c("mean_difference", "median_difference")) TRUE else FALSE
  is_mean <- if (options$effect_size %in% c("mean_difference", "mean")) TRUE else FALSE
  is_interval <- if (options$null_boundary > 0) TRUE else FALSE
  from_raw <- options$switch == "from_raw"

  # Title
  overviewTable <- createJaspTable(title = "Hypothesis Evaluation")

  # Depends on
  overviewTable$dependOn(
    c(
      jasp_mdiff_table_depends_on(),
      "null_value",
      "null_boundary",
      "rope_units",
      "evaluate_hypotheses"
    )
  )

  # Columns
  if (is_difference) {
    overviewTable$addColumnInfo(
      name = "outcome_variable_name",
      title = "Outcome variable",
      type = "string",
      combine = FALSE
    )
  }

  overviewTable$addColumnInfo(
    name = "effect",
    title = "Effect",
    type = "string",
    combine = FALSE
  )

  if (is_interval) {
    overviewTable$addColumnInfo(
      name = "rope",
      title = "<i>H</i><sub>0</sub>",
      type = "number"
    )
  } else {
    overviewTable$addColumnInfo(
      name = "null_words",
      title = "<i>H</i><sub>0</sub>",
      type = "string"
    )
  }

  overviewTable$addColumnInfo(
    name = "CI",
    title = "CI",
    type = "string"
  )

  if (is_interval) {
    overviewTable$addColumnInfo(
      name = "rope_compare",
      title = "Compare CI with <i>H</i><sub>0</sub>",
      type = "string"
    )

  } else {
    overviewTable$addColumnInfo(
      name = "CI_compare",
      title = "Compare CI with <i>H</i><sub>0</sub>",
      type = "string"
    )
  }

  if (is_mean & !is_interval) {
    overviewTable$addColumnInfo(
      name = "t",
      title = "<i>t</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "df",
      title = "<i>df</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "p",
      title = "<i>p</i>, two tailed",
      type = "pvalue"
    )

  } else {
    overviewTable$addColumnInfo(
      name = "p_result",
      title = "<i>p</i>, two tailed",
      type = "pvalue"
    )
  }

  if (!is_interval) {
    overviewTable$addColumnInfo(
      name = "null_decision",
      title = "<i>H</i><sub>0</sub> decision",
      type = "string"
    )
  }

  overviewTable$addColumnInfo(
    name = "conclusion",
    title = "Conclusion",
    type = "string"
  )


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready) {
    if (from_raw) {
      overviewTable$setExpectedSize(length(options$outcome_variable))
    } else {
      overviewTable$setExpectedSize(length(1))
    }
  }

  jaspResults[["heTable"]] <- overviewTable



  return()

}


# Prep a pdiff table
jasp_es_p_difference_prep <- function(jaspResults, options, ready, estimate = NULL) {
  # Handles
  from_raw <- options$switch == "from_raw"
  is_mean <- FALSE
  if (options$effect_size == "mean_difference") is_mean <- TRUE


  overviewTable <- createJaspTable(
    title = if (is_mean) "Mean Difference" else "Median Difference"
  )


  overviewTable$dependOn(
    c(
      jasp_mdiff_table_depends_on()
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
    name = "effect",
    title = effect_title,
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = if (is_mean) "<i>M</i>" else "<i>Mdn</i>",
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


  if (options$show_details & is_mean) {
    overviewTable$addColumnInfo(
      name = "moe",
      title = "<i>MoE</i>",
      type = "number"
    )
  }

  if (options$show_details) {
    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE</i>",
      type = "number"
    )
  }

  if (options$show_details & is_mean) {
    overviewTable$addColumnInfo(
      name = "df",
      title = "<i>df</i>",
      type = if (options$assume_equal_variance) "integer" else "number"
    )
  }


  if (options$show_calculations & is_mean & options$assume_equal_variance) {
    overviewTable$addColumnInfo(
      name = "t_multiplier",
      title = "<i>t</i>",
      type = "number",
      overtitle = "Calculation component"
    )

    overviewTable$addColumnInfo(
      name = "s_component",
      title = "Variability",
      type = "number",
      overtitle = "Calculation component"
    )

    overviewTable$addColumnInfo(
      name = "n_component",
      title = "Sample size",
      type = "number",
      overtitle = "Calculation component"
    )

  }

  if (options$effect_size == "mean_difference") {
    if (options$assume_equal_variance) {
      overviewTable$addFootnote(
        "Variances are assumed equal, so <i>s</i><sub>p</sub> was used to calculate each CI."
      )
    } else {
      overviewTable$addFootnote(
        "Variances are not assumed equal, and so the CI was calculated separately for each mean."
      )
    }

  }

  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready) {
    if (from_raw) {
      overviewTable$setExpectedSize(length(options$outcome_variable) * 3)
    } else {
      overviewTable$setExpectedSize(3)
    }
  }

  jaspResults[["es_m_differenceTable"]] <- overviewTable



  return()

}

