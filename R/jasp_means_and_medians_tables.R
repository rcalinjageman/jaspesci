jasp_mdiff_table_depends_on <- function() {
  return(
    c(
      "outcome_variable",
      "grouping_variable",
      "switch_comparison_order",
      "conf_level",
      "assume_equal_variance",
      "effect_size",
      "switch_comparison_order",
      "show_details",
      "reference_mean",
      "show_calculations",
      "switch",
      "mean",
      "sd",
      "n",
      "comparison_mean",
      "comparison_sd",
      "comparison_n",
      "reference_mean",
      "reference_sd",
      "reference_n",
      "comparison_level_name",
      "reference_level_name",
      "outcome_variable_name",
      "grouping_variable_name"
    )
  )
}

# Prep an overview table
jasp_overview_prep <- function(jaspResults, options, ready, estimate = NULL, levels = 1) {

  # Handles
  from_raw <- FALSE
  if (!is.null(options$switch)) {
    from_raw <- options$switch == "from_raw"
  }

  # Title
  overviewTable <- createJaspTable(title = "Overview")

  # Depends on
  overviewTable$dependOn(
    jasp_mdiff_table_depends_on()
  )

  # Columns
  overviewTable$addColumnInfo(
    name = "outcome_variable_name",
    title = "Outcome variable",
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


  if (options$effect_size %in% c("mean", "mean_difference")) {
    overviewTable$addColumnInfo(
      name = "mean",
      title = "<i>M</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "mean_LL",
      title = "LL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% CI")
    )
    overviewTable$addColumnInfo(
      name = "mean_UL",
      title = "UL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% CI")
    )


    if (options$show_details) {
      overviewTable$addColumnInfo(
        name = "moe",
        title = "<i>MoE</i>",
        type = "number"
      )

      overviewTable$addColumnInfo(
        name = "mean_SE",
        title = "<i>SE</i><sub>Mean</sub>",
        type = "number"
      )
    }

    if (from_raw) {
      overviewTable$addColumnInfo(
        name = "median",
        title = "<i>Mdn</i>",
        type = "number"
      )

    }

  }  # end of mean, mean difference


  if (options$effect_size %in% c("median", "median_difference")) {
    overviewTable$addColumnInfo(
      name = "median",
      title = "<i>Mdn</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "median_LL",
      title = "LL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% CI")
    )
    overviewTable$addColumnInfo(
      name = "median_UL",
      title = "UL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% CI")
    )


    if (options$show_details) {
      overviewTable$addColumnInfo(
        name = "median_SE",
        title = "<i>SE</i><sub>Median</sub>",
        type = "number"
      )
    }

    overviewTable$addColumnInfo(
      name = "mean",
      title = "<i>M</i>",
      type = "number"
    )
  } # end of median, median difference


  overviewTable$addColumnInfo(
    name = "sd",
    title = "<i>s</i>",
    type = "number"
  )


  if (options$show_details & from_raw) {
    overviewTable$addColumnInfo(
      name = "min",
      title = "Minimum",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "max",
      title = "Maximum",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "q1",
      title = "25th",
      type = "number",
      overtitle = "Percentile"
    )

    overviewTable$addColumnInfo(
      name = "q3",
      title = "75th",
      type = "number",
      overtitle = "Percentile"
    )

  } # end of show_details for raw data


  overviewTable$addColumnInfo(
    name = "n",
    title = "<i>N</i>",
    type = "integer"
  )

  if (from_raw) {
    overviewTable$addColumnInfo(
      name = "missing",
      title = "Missing",
      type = "integer"
    )
  }


  if (options$show_details & options$effect_size %in% c("mean", "mean_difference")) {
    mytype <- "integer"
    if (!is.null(options$assume_equal_variance)) {
      mytype <- if (options$assume_equal_variance) "integer" else "number"
    }

    overviewTable$addColumnInfo(
      name = "df",
      title = "<i>df</i>",
      type = mytype
    )

  }

  if (options$effect_size == "mean_difference") {
    if (options$assume_equal_variance) {
      overviewTable$addColumnInfo(
        name = "s_pooled",
        title = "<i>s</i><sub>p</sub>",
        type = "number"
      )
    }
  }


  if (options$show_calculations & options$effect_size %in% c("mean")) {

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
      overviewTable$setExpectedSize(length(options$outcome_variable) * levels)
    } else {
      overviewTable$setExpectedSize(1)
    }
  }

  jaspResults[["overviewTable"]] <- overviewTable



  return()

}


# Prep a Cohen's d table
jasp_smd_prep <- function(jaspResults, options, ready, estimate = NULL, one_group = TRUE) {
  # Handles
  has_estimate <- !is.null(estimate)
  from_raw <- options$switch == "from_raw"


  # Title
  overviewTable <- createJaspTable(title = "Standardized Mean Difference")

  # dependOn
  overviewTable$dependOn(
    c(
      jasp_mdiff_table_depends_on(),
      "null_value",
      "null_boundary",
      "rope_units",
      "evaluate_hypotheses"
    )
  )

  if (!one_group) {
    overviewTable$addColumnInfo(
      name = "outcome_variable_name",
      title = "Outcome variable",
      type = "string",
      combine = TRUE
    )

  }

  if (one_group) effect_title <- "Effect" else effect_title <- paste(options$grouping_variable, "Effect", "</BR>")

  overviewTable$addColumnInfo(
    name = "effect",
    title = effect_title,
    type = "string"
  )

  if (one_group) {
    overviewTable$addColumnInfo(
      name = "mean",
      title = "<i>M</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "reference_value",
      title = "Reference value",
      type = "number"
    )
  }

  if (one_group) numerator_title <- "<i>M</i> - Reference" else numerator_title <- "<i>M</i><sub>diff</sub>"

  overviewTable$addColumnInfo(
    name = "numerator",
    title = numerator_title,
    type = "number",
    overtitle = "Numerator"
  )

  overviewTable$addColumnInfo(
    name = "denominator",
    title = if (has_estimate) estimate$es_smd_properties$denominator_name_html else "<i>s</i>",
    type = "number",
    overtitle = "Standardizer"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = if (has_estimate) estimate$es_smd_properties$effect_size_name_html else "<i>d</i>",
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
      name = "df",
      title = "<i>df</i>",
      type = "integer"
    )


  }

  if (has_estimate) {
    to_replace <- '<sub>.biased</sub>'
    if (grepl("biased", estimate$es_smd_properties$effect_size_name_html))
      to_replace <- ""
    mytitle <- paste(
      estimate$es_smd_properties$effect_size_name_html,
      to_replace,
      sep = ""
    )
  } else {
    mytitle <- "<i>d</i><sub>biased</sub>"
  }

  overviewTable$addColumnInfo(
    name = "d_biased",
    title = mytitle,
    type = "number"
  )

  overviewTable$addCitation(
    "Bonett, D.G. (2008). Confidence intervals for standardized linear contrasts of means. Psychological Methods. 13, 99-109, https://psycnet.apa.org/doiLanding?doi=10.1037%2F1082-989X.13.2.99."
  )


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready) {
    if (from_raw) {
      overviewTable$setExpectedSize(length(options$outcome_variable))
    } else {
      overviewTable$setExpectedSize(1)
    }
  }


  jaspResults[["smdTable"]] <- overviewTable



  return(ready)

}


# Prep a hypothesis evaluation table
jasp_he_prep <- function(jaspResults, options, ready, mytest = NULL) {
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


# Prep a mdiff table
jasp_es_m_difference_prep <- function(jaspResults, options, ready, estimate = NULL) {
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


# Prep a mdiff table
jasp_es_m_ratio_prep <- function(jaspResults, options, ready, estimate, levels = c("Comparison", "Reference")) {

  is_mean <- FALSE
  if (options$effect_size == "mean_difference") is_mean <- TRUE

  overviewTable <- createJaspTable(
    title = if (is_mean) "Ratio of Means" else "Ratio of Medians"
  )

  overviewTable$dependOn(
    c(
      jasp_mdiff_table_depends_on(),
      "show_ratio"
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
    name = if (is_mean) "comparison_mean" else "comparison_median",
    title = if (is_mean) "<i>M</i><sub>comparison</sub>" else "<i>Mdn</i><sub>comparison</sub>",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = if (is_mean) "reference_mean" else "reference_median",
    title = if (is_mean) "<i>M</i><sub>reference</sub>" else "<i>Mdn</i><sub>reference</sub>",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = if (is_mean) "<i>M</i>/<i>M</i>" else "<i>Mdn</i>/<i>Mdn</i>",
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


  overviewTable$addFootnote(
    "This effect-size measure is appropriate only for true ratio scales."
  )

  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable) * 1)

  overviewTable$addCitation(
    "Bonett, D.G. & Price, R. M. (2020). Confidence intervals for ratios of means and medians. Journal of Educational and Behavioral Statistics. 45, 750-770, https://journals.sagepub.com/doi/10.3102/1076998620934125."
  )

  jaspResults[["es_m_ratioTable"]] <- overviewTable





  return()

}
