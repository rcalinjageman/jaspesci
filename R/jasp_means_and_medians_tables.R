# Prep an overview table
jasp_overview_prep <- function(jaspResults, options, ready, levels = 1) {
  overviewTable <- createJaspTable(title = "Overview")

  overviewTable$dependOn(
    c(
      "outcome_variable",
      "grouping_variable",
      "switch_comparison_order",
      "conf_level",
      "assume_equal_variance",
      "effect_size",
      "switch_comparison_order",
      "show_details",
      "show_calculations"
    )
  )


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

    overviewTable$addColumnInfo(
      name = "median",
      title = "<i>Mdn</i>",
      type = "number"
    )

  }


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
  }

  overviewTable$addColumnInfo(
    name = "sd",
    title = "<i>s</i>",
    type = "number"
  )

  if (options$show_details) {
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

  }


  overviewTable$addColumnInfo(
    name = "n",
    title = "<i>N</i>",
    type = "integer"
  )

  overviewTable$addColumnInfo(
    name = "missing",
    title = "Missing",
    type = "integer"
  )

  if (options$show_details & options$effect_size == "mean_difference") {
    overviewTable$addColumnInfo(
      name = "df",
      title = "<i>df</i>",
      type = if (options$assume_equal_variance) "integer" else "number"
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


  if (options$show_calculations & options$effect_size == "mean") {
    overviewTable$addColumnInfo(
      name = "df",
      title = "<i>df</i>",
      type = "integer"
    )

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

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable)) * levels

  jaspResults[["overviewTable"]] <- overviewTable


  return()

}


# Prep a Cohen's d table
jasp_smd_prep <- function(jaspResults, options, ready, properties, one_group = TRUE) {
  overviewTable <- createJaspTable(title = "Standardized Mean Difference")

  overviewTable$dependOn(
    c(
      "outcome_variable",
      "grouping_variable",
      "conf_level",
      "assume_equal_variance",
      "effect_size",
      "switch_comparison_order",
      "show_details",
      "reference_mean",
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
    title = properties$denominator_name_html,
    type = "number",
    overtitle = "Standardizer"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = properties$effect_size_name_html,
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

  to_replace <- '<sub>.biased</sub>'
  if (grepl("biased", properties$effect_size_name_html))
    to_replace <- ""

  overviewTable$addColumnInfo(
    name = "d_biased",
    title = paste(
      properties$effect_size_name_html,
      to_replace,
      sep = ""
    ),
    type = "number"
  )


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable))

  jaspResults[["smdTable"]] <- overviewTable

  return()

}


# Prep a point null table
jasp_he_point_prep <- function(jaspResults, options, ready) {
  overviewTable <- createJaspTable(title = "Hypothesis Evaluation")

  overviewTable$dependOn(c("outcome_variable", "conf_level", "effect_size", "reference_mean", "rope", "evaluate_hypotheses"))


  overviewTable$addColumnInfo(
    name = "effect",
    title = "Effect",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "null_words",
    title = "<i>H</i><sub>0</sub>",
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "CI",
    title = "CI",
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "CI_compare",
    title = "Compare CI with <i>H</i><sub>0</sub>",
    type = "string"
  )

  if (options$effect_size == "mean") {
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

  overviewTable$addColumnInfo(
    name = "null_decision",
    title = "<i>H</i><sub>0</sub> decision",
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "conclusion",
    title = "Conclusion",
    type = "string"
  )



  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable))

  jaspResults[["heTable"]] <- overviewTable

  return()

}


# Prep an interval null table
jasp_he_interval_prep <- function(jaspResults, options, ready) {
  overviewTable <- createJaspTable(title = "Hypothesis Evaluation")

  overviewTable$dependOn(c("outcome_variable", "conf_level", "effect_size", "reference_mean", "rope", "evaluate_hypotheses"))


  overviewTable$addColumnInfo(
    name = "effect",
    title = "Effect",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "rope",
    title = "<i>H</i><sub>0</sub>",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "CI",
    title = "CI",
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "rope_compare",
    title = "Compare CI with <i>H</i><sub>0</sub>",
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "p_result",
    title = "<i>p</i>, two tailed",
    type = "pvalue"
  )

  overviewTable$addColumnInfo(
    name = "conclusion",
    title = "Conclusion",
    type = "string"
  )



  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable))

  jaspResults[["heTable"]] <- overviewTable

  return()

}


# Prep a mdiff table
jasp_es_m_difference_prep <- function(jaspResults, options, ready) {

  is_mean <- FALSE
  if (options$effect_size == "mean_difference") is_mean <- TRUE

  overviewTable <- createJaspTable(
    title = if (is_mean) "Mean Difference" else "Median Difference"
  )


  overviewTable$dependOn(
    c(
      "outcome_variable",
      "grouping_variable",
      "conf_level",
      "assume_equal_variance",
      "effect_size",
      "switch_comparison_order",
      "show_details",
      "show_calculations"
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

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable) * 3)

  jaspResults[["es_m_differenceTable"]] <- overviewTable

  return()

}


# Prep a mdiff table
jasp_es_m_ratio_prep <- function(jaspResults, options, ready, levels = c("Comparison", "Reference")) {

  is_mean <- FALSE
  if (options$effect_size == "mean_difference") is_mean <- TRUE

  overviewTable <- createJaspTable(
    title = if (is_mean) "Ratio of Means" else "Ratio of Medians"
  )

  overviewTable$dependOn(
    c(
      "outcome_variable",
      "grouping_variable",
      "conf_level",
      "effect_size",
      "switch_comparison_order",
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

  jaspResults[["es_m_ratioTable"]] <- overviewTable

  return()

}
