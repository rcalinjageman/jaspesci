# Prep an overview table
jasp_overview_prep <- function(jaspResults, options, ready) {
  overviewTable <- createJaspTable(title = "Overview")

  overviewTable$dependOn(c("outcome_variable", "conf_level", "extraDetails", "effect_size", "calculationComponents"))


  overviewTable$addColumnInfo(
    name = "outcome_variable_name",
    title = "Outcome variable",
    type = "string",
    combine = TRUE
  )


  if (options$effect_size == "mean") {
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

    if (options$extraDetails) {

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


  if (options$effect_size == "median") {
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


    if (options$extraDetails) {
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

  if (options$extraDetails) {
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


  if (options$calculationComponents & options$effect_size == "mean") {
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


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable))

  jaspResults[["overviewTable"]] <- overviewTable


  return()

}


# Prep a Cohen's d table
jasp_smd_prep <- function(jaspResults, options, ready) {
  overviewTable <- createJaspTable(title = "Standardized Mean Difference")

  overviewTable$dependOn(c("outcome_variable", "conf_level", "effect_size", "extraDetails", "reference_mean", "hypothesis_evaluation"))


  overviewTable$addColumnInfo(
    name = "effect",
    title = "Effect",
    type = "string",
    combine = TRUE
  )

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

  overviewTable$addColumnInfo(
    name = "numerator",
    title = "<i>M</i> - Reference",
    type = "number",
    overtitle = "Numerator"
  )

  overviewTable$addColumnInfo(
    name = "denominator",
    title = "<i>s</i>",
    type = "number",
    overtitle = "Standardizer"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = "<i>d</i><sub>1</i>",
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

  overviewTable$addColumnInfo(
    name = "d_biased",
    title = "<i>d</i><sub>1.biased</i>",
    type = "number"
  )

  if (options$extraDetails) {

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


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable))

  jaspResults[["smdTable"]] <- overviewTable

  return()

}


# Prep a point null table
jasp_he_point_prep <- function(jaspResults, options, ready) {
  overviewTable <- createJaspTable(title = "Hypothesis Evaluation")

  overviewTable$dependOn(c("outcome_variable", "conf_level", "effect_size", "reference_mean", "rope", "hypothesis_evaluation"))


  overviewTable$addColumnInfo(
    name = "effect",
    title = "Effect",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "null_words",
    title = "<i>H</i><sub>0</sub>",
    type = "number"
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

  overviewTable$dependOn(c("outcome_variable", "conf_level", "effect_size", "reference_mean", "rope", "hypothesis_evaluation"))


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
