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
      "r",
      "x",
      "y",
      "comparison_mean",
      "comparison_sd",
      "comparison_n",
      "reference_mean",
      "reference_sd",
      "reference_n",
      "comparison_level_name",
      "reference_level_name",
      "outcome_variable_name",
      "grouping_variable_name",
      "reference_measure",
      "comparison_measure",
      "reference_measure_name",
      "comparison_measure_name",
      "fully_between",
      "mixed",
      "grouping_variable_A",
      "grouping_variable_B",
      "A1_label",
      "A2_label",
      "B1_label",
      "B2_label",
      "B_label",
      "A_label",
      "A1B1_mean",
      "A1B2_mean",
      "A2B1_mean",
      "A2B2_mean",
      "A1B1_sd",
      "A1B2_sd",
      "A2B1_sd",
      "A2B2_sd",
      "A1B1_n",
      "A1B2_n",
      "A2B1_n",
      "A2B2_n",
      "outcome_variable_name_bs",
      "outcome_variable_level1",
      "outcome_variable_level2",
      "repeated_measures_name",
      "design",
      "comparison_labels",
      "reference_labels",
      "means",
      "sds",
      "ns",
      "from_raw",
      "from_summary"
    )
  )
}

# Prep an overview table
jasp_overview_prep <- function(jaspResults, options, ready, estimate = NULL, levels = 1, paired = FALSE) {

  # Handles
  from_raw <- FALSE
  if (!is.null(options$switch)) {
    from_raw <- options$switch == "from_raw"
  }
  show_calculations <- FALSE
  if (!is.null(options$show_calculations)) {
    show_calculations <- options$show_calculations
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

  if (levels > 1 & ready) {
    overviewTable$addColumnInfo(
      name = "grouping_variable_level",
      title = options$grouping_variable,
      type = "string",
      combine = TRUE
    )
  }


  if (options$effect_size %in% c("mean", "mean_difference", "r")) {
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

    if (from_raw & options$effect_size != "r") {
      overviewTable$addColumnInfo(
        name = "median",
        title = "<i>Mdn</i>",
        type = "number"
      )

    }

  }  # end of mean, mean difference


  if (options$effect_size %in% c("median", "median_difference", "r")) {
    overviewTable$addColumnInfo(
      name = "median",
      title = "<i>Mdn</i>",
      type = "number"
    )

    show_ci <- TRUE
    if (options$effect_size == "r" & !options$show_details) show_ci <- FALSE

    if (show_ci) {
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

    }


    if (options$show_details) {
      overviewTable$addColumnInfo(
        name = "median_SE",
        title = "<i>SE</i><sub>Median</sub>",
        type = "number"
      )
    }

    if (options$effect_size != "r") {
      overviewTable$addColumnInfo(
        name = "mean",
        title = "<i>M</i>",
        type = "number"
      )

    }
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


  n_label <- "<i>N</i>"
  if (options$effect_size %in% c("mean_difference", "median_difference")) {
    n_label <- "<i>n</i>"
  }

  if (!paired) {
    overviewTable$addColumnInfo(
      name = "n",
      title = n_label,
      type = "integer"
    )

    if (from_raw) {
      overviewTable$addColumnInfo(
        name = "missing",
        title = "Missing",
        type = "integer"
      )
    }

  }


  if (options$show_details & options$effect_size %in% c("mean", "mean_difference", "r")) {
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
    if (options$assume_equal_variance & is.null(options$reference_labels)) {
      overviewTable$addColumnInfo(
        name = "s_pooled",
        title = "<i>s</i><sub>p</sub>",
        type = "number"
      )
    }
  }


  if (show_calculations & options$effect_size %in% c("mean")) {

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

  if (options$effect_size == "mean_difference" & !paired) {
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
jasp_smd_prep <- function(jaspResults, options, ready, estimate = NULL, one_group = TRUE, is_paired = FALSE) {
  # Handles
  has_estimate <- !is.null(estimate)
  if (has_estimate) has_estimate <- !is.null(estimate$es_smd_properties)

  from_raw <- FALSE
  if (!is.null(options$switch)) {
    from_raw <- options$switch == "from_raw"
  }

  is_mean <- FALSE
  if (!is.null(options$effect_size)) {
    is_mean <- options$effect_size == "mean_difference"
  }

  is_mixed <- FALSE
  if (!is.null(options$design)) {
    is_mixed <- options$design == "mixed"
  }

  show_details <- FALSE
  if (!is.null(options$show_details)) {
    show_details <- options$show_details
  }

  show_calculations <- FALSE
  if (!is.null(options$show_calculations)) {
    show_calculations <- options$show_calculations
  }

  assume_equal_variance <- FALSE
  if (!is.null(options$assume_equal_variance)) {
    assume_equal_variance <- options$assume_equal_variance | is_mixed
  }

  is_complex <- FALSE
  if (!is.null(options$design)) is_complex <- TRUE


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

  if (!one_group & !is_paired) {
    overviewTable$addColumnInfo(
      name = "outcome_variable_name",
      title = "Outcome variable",
      type = "string",
      combine = TRUE
    )

  }


  if (is_complex) {
    overviewTable$addColumnInfo(
      name = "effect_type",
      title = "Effect type",
      type = "string",
      combine = TRUE
    )
  }

  overviewTable$addColumnInfo(
    name = if (is_complex) "effects_complex" else "effect",
    title = if (is_complex | one_group) "Effect" else paste(options$grouping_variable, "Effect", "</BR>"),
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
jasp_he_prep <- function(jaspResults, options, ready, mytest = NULL, show_outcome_variable = TRUE, paired = FALSE) {
  # Handles

  is_difference <- FALSE
  if (!is.null(options$effect_size)) {
    is_difference <- if (options$effect_size %in% c("mean_difference", "median_difference", "proportion_difference")) TRUE else FALSE
  }

  is_interval <- FALSE
  if (!is.null(options$null_boundary)) {
    is_interval <- if (options$null_boundary > 0) TRUE else FALSE
  }

  is_r <- FALSE
  if (!is.null(options$effect_size)) {
    is_r <- if (options$effect_size %in% c("r", "rdiff")) TRUE else FALSE
  }

  is_pdiff <- FALSE
  if (!is.null(options$effect_size)) {
    is_pdiff <- if (options$effect_size %in% c("pdiff", "proportion_difference")) TRUE else FALSE
  }

  from_raw <- FALSE
  if (!is.null(options$switch)) {
    from_raw <- options$switch == "from_raw"
  }

  is_mean <- FALSE
  if (!is.null(options$effect_size)) {
    is_mean <- if (options$effect_size %in% c("mean_difference", "mean")) TRUE else FALSE
  }

  is_mixed <- FALSE
  if (!is.null(options$design)) {
    is_mixed <- options$design == "mixed"
  }

  show_details <- FALSE
  if (!is.null(options$show_details)) {
    show_details <- options$show_details
  }

  show_calculations <- FALSE
  if (!is.null(options$show_calculations)) {
    show_calculations <- options$show_calculations
  }

  assume_equal_variance <- FALSE
  if (!is.null(options$assume_equal_variance)) {
    assume_equal_variance <- options$assume_equal_variance | is_mixed
  }

  is_complex <- FALSE
  if (!is.null(options$design)) is_complex <- TRUE


  # Title
  overviewTable <- createJaspTable(title = "Hypothesis Evaluation")

  # Depends on
  overviewTable$dependOn(
    c(
      jasp_mdiff_table_depends_on(),
      jasp_pdiff_table_depends_on(),
      "null_value",
      "null_boundary",
      "rope_units",
      "evaluate_hypotheses"
    )
  )

  # Columns
  if (is_difference | is_r) {
    if (show_outcome_variable) {
      overviewTable$addColumnInfo(
        name = "outcome_variable_name",
        title = "Outcome variable",
        type = "string",
        combine = FALSE
      )

    }
  }


  if (is_complex) {
    overviewTable$addColumnInfo(
      name = "effect_type",
      title = "Effect type",
      type = "string",
      combine = TRUE
    )
  }

  effect_column <- "effect"
  if (is_complex) effect_column <- "effects_complex"
  if (is_pdiff)  effect_column <- "effect_plus"

  overviewTable$addColumnInfo(
    name = effect_column,
    title = if (is_complex) "Effect" else paste(options$grouping_variable, "Effect", "</BR>"),
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

  if ( (is_mean)  & !is_interval) {
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

    if (is_pdiff & ! is_interval) {
      overviewTable$addColumnInfo(
        name = "t",
        title = "<i>z</i>",
        type = "number"
      )

      overviewTable$addColumnInfo(
        name = "p",
        title = "<i>p</i>, two tailed",
        type = "pvalue"
      )

    } else {

      if (is_r & ! is_interval) {
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

    }
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
jasp_es_m_difference_prep <- function(jaspResults, options, ready, estimate = NULL, paired = FALSE) {
  # Handles

  from_raw <- FALSE
  if (!is.null(options$switch)) {
    from_raw <- options$switch == "from_raw"
  }

  is_mean <- FALSE
  if (!is.null(options$effect_size)) {
    is_mean <- options$effect_size == "mean_difference"
  }

  is_mixed <- FALSE
  if (!is.null(options$design)) {
    is_mixed <- options$design == "mixed"
  }

  show_details <- FALSE
  if (!is.null(options$show_details)) {
    show_details <- options$show_details
  }

  show_calculations <- FALSE
  if (!is.null(options$show_calculations)) {
    show_calculations <- options$show_calculations
  }

  assume_equal_variance <- FALSE
  if (!is.null(options$assume_equal_variance)) {
    assume_equal_variance <- options$assume_equal_variance | is_mixed
  }

  is_complex <- FALSE
  if (!is.null(options$design)) is_complex <- TRUE

  is_paired <- paired
  # if (is.null(options$assume_equal_variance)) {
  #   is_paired <- TRUE
  # }

  overviewTable <- createJaspTable(
    title = if (is_mean) "Mean Difference" else "Median Difference"
  )


  overviewTable$dependOn(
    c(
      jasp_mdiff_table_depends_on()
    )
  )

  if (!is_paired) {
    overviewTable$addColumnInfo(
      name = "outcome_variable_name",
      title = "Outcome variable",
      type = "string",
      combine = TRUE
    )

  }

  if (is_complex) {
    overviewTable$addColumnInfo(
      name = "effect_type",
      title = "Effect type",
      type = "string",
      combine = TRUE
    )
  }

  overviewTable$addColumnInfo(
    name = if (is_complex) "effects_complex" else "effect",
    title = if (is_complex) "Effect" else paste(options$grouping_variable, "Effect", "</BR>"),
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


  if (show_details & is_mean) {
    overviewTable$addColumnInfo(
      name = "moe",
      title = "<i>MoE</i>",
      type = "number"
    )
  }

  if (show_details) {
    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE</i>",
      type = "number"
    )
  }

  if (show_details & is_mean) {
    overviewTable$addColumnInfo(
      name = "df",
      title = "<i>df</i>",
      type = if (assume_equal_variance) "integer" else "number"
    )
  }


  if (show_calculations & is_mean & (assume_equal_variance | paired))  {
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

  if (is_complex & options$effect_size == "mean_difference" & show_details & assume_equal_variance & !is_mixed) {
    overviewTable$addColumnInfo(
      name = "s_component",
      title = "<i>s</i><sub>p</sub>",
      type = "number"
    )
  }

  if (options$effect_size == "mean_difference" & !is_mixed & !is_paired) {
    if (assume_equal_variance) {
      overviewTable$addFootnote(
        "Variances are assumed equal, so <i>s</i><sub>p</sub> was used to calculate each CI."
      )
    } else {
      if (is_complex) {
        overviewTable$addFootnote(
          "Variances are not assumed equal, and so the Welch method was used to calculate each CI on a difference."
        )
      } else {
        overviewTable$addFootnote(
          "Variances are not assumed equal, so the Welch method was used to calculate each CI on a difference."
        )

      }
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
jasp_es_m_ratio_prep <- function(jaspResults, options, ready, estimate, levels = c("Comparison", "Reference"), is_paired = FALSE) {

  if (is.null(levels)) levels <- c("Comparison", "Reference")

  is_mean <- FALSE
  if (options$effect_size == "mean_difference") is_mean <- TRUE

  # is_paired <- FALSE
  # if (is.null(options$assume_equal_variance)) {
  #   is_paired <- TRUE
  # }

  overviewTable <- createJaspTable(
    title = if (is_mean) "Ratio of Means" else "Ratio of Medians"
  )

  overviewTable$dependOn(
    c(
      jasp_mdiff_table_depends_on(),
      "show_ratio"
    )
  )

  if (!is_paired) {
    overviewTable$addColumnInfo(
      name = "outcome_variable_name",
      title = "Outcome variable",
      type = "string",
      combine = TRUE
    )

  }


  effect_title <- paste(options$grouping_variable, "Effect", sep = "</BR>")

  overviewTable$addColumnInfo(
    name = "effect",
    title = effect_title,
    type = "string"
  )

  c_title <- paste(
    if (is_mean) "<i>M</i>" else "<i>Mdn</i>",
    "<sub>", levels[2], "</sub>",
    sep = ""
  )

  r_title <- paste(
    if (is_mean) "<i>M</i>" else "<i>Mdn</i>",
    "<sub>", levels[1], "</sub>",
    sep = ""
  )

  overviewTable$addColumnInfo(
    name = if (is_mean) "comparison_mean" else "comparison_median",
    title = c_title,
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = if (is_mean) "reference_mean" else "reference_median",
    title = r_title,
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = paste(c_title, r_title, sep = "/"),
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




# Prep an overview table
jasp_overview_complex_prep <- function(jaspResults, options, ready, estimate = NULL) {

  # Handles
  from_raw <- FALSE
  if (!is.null(options$switch)) {
    from_raw <- options$switch == "from_raw"
  }

  mixed <- FALSE
  if (!is.null(options$design)) {
    mixed <- options$design == "mixed"
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

  A_name <- ""
  if (mixed) {
    A_name <- options$grouping_variable
  } else {
    A_name <- if (from_raw) options$grouping_variable_A else jasp_text_fix(options, "A_label", "Variable A")
  }

  B_name <- ""
  if (mixed) {
    B_name <- jasp_text_fix(options, "repeated_measures_name", "Time")
  } else {
    B_name <- if (from_raw) options$grouping_variable_B else jasp_text_fix(options, "B_label", "Variable B")
  }

    overviewTable$addColumnInfo(
      name = "grouping_variable_A_level",
      title = A_name,
      type = "string",
      combine = FALSE
    )

    overviewTable$addColumnInfo(
      name = "grouping_variable_B_level",
      title = B_name,
      type = "string",
      combine = FALSE
    )


  if (options$effect_size %in% c("mean", "mean_difference", "r")) {
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


  if (options$effect_size %in% c("median", "median_difference", "r")) {

    overviewTable$addColumnInfo(
      name = "mean",
      title = "<i>M</i>",
      type = "number"
    )


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


  if (options$show_details & options$effect_size %in% c("mean", "mean_difference", "r")) {
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

  overviewTable$showSpecifiedColumnsOnly <- TRUE

  overviewTable$setExpectedSize(4)

  jaspResults[["overviewTable"]] <- overviewTable


  return()

}

