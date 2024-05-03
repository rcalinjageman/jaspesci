jasp_estimate_mdiff_one <- function(jaspResults, dataset = NULL, options, ...) {


  ready <- (length(options$variables) > 0)

  if (ready) {
    # read dataset
    dataset <- jasp_estimate_mdiff_one_read_data(dataset, options)

    # check for errors
    for (variable in options$variables) {
      .hasErrors(
        dataset = dataset,
        type = "observations",
        observations.target = variable,
        observations.amount  = "< 3",
        exitAnalysisIfErrors = TRUE
      )

    }


    # Run the analysis
    estimate <- esci::estimate_mdiff_one(
      data = dataset,
      outcome_variable = encodeColNames(options$variables),
      reference_mean = if (options$hypothesisEvaluation) options$nullValue else 0,
      conf_level = options$ciLevel,
      save_raw_data = FALSE
    )

   # Some results tweaks
    alpha <- 1 - as.numeric(options$ciLevel)
    estimate$overview$t_multiplier <- stats::qt(1-alpha/2, estimate$overview$df)
    estimate$overview$s_component <- estimate$overview$sd
    estimate$overview$n_component <- 1/sqrt(estimate$overview$n)
    estimate$overview$moe <- (estimate$overview$mean_UL - estimate$overview$mean_LL)/2



    # Define and fill tables
    if (is.null(jaspResults[["overviewTable"]])) {
      jasp_overview_prep(jaspResults, dataset, options, ready)
      jasp_table_fill(jaspResults[["overviewTable"]], estimate$overview)

    }

    if (options$hypothesisEvaluation) {
      # SMD
      estimate$es_smd$reference_value <- options$nullValue
      estimate$es_smd$mean <- estimate$es_smd$numerator + options$nullValue

      if (options$effectSize == "Mean" & is.null(jaspResults[["smdTable"]]) ) {
        jasp_smd_prep(jaspResults, dataset, options, ready)
        jasp_table_fill(jaspResults[["smdTable"]], estimate$es_smd)
      } else {
        jaspResults[["smdTable"]] <- NULL
      }


      # Hypothesis evaluation
      myrope <- c(-1 * options$nullROPE, options$nullROPE)
      myeffectsize <- if (options$effectSize == "Mean") "mean" else "median"

      test_results <- esci::test_mdiff(
        estimate,
        effect_size = myeffectsize,
        rope = myrope,
        rope_units = "raw",
        output_html = TRUE
      )

      if (is.null(jaspResults[["heTable"]]) ) {
        if (options$nullROPE == 0) {
          jasp_he_point_prep(jaspResults, dataset, options, ready)
        } else {
          jasp_he_interval_prep(jaspResults, dataset, options, ready)
        }
        jasp_table_fill(jaspResults[["heTable"]], if (options$nullROPE == 0) test_results$point_null else test_results$interval_null)
      }

    } else {
      jaspResults[["smdTable"]] <- NULL
      jaspResults[["heTable"]] <- NULL
    }

  }  # end of ready

  return()
}



jasp_estimate_mdiff_one_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(.readDataSetToEnd(columns.as.numeric = options$variables))
}


jasp_overview_prep <- function(jaspResults, dataset, options, ready) {
  overviewTable <- createJaspTable(title = "Overview")

  overviewTable$dependOn(c("variables", "ciLevel", "extraDetails", "effectSize", "calculationComponents"))


  overviewTable$addColumnInfo(
    name = "outcome_variable_name",
    title = "Outcome variable",
    type = "string",
    combine = TRUE
  )


  if (options$effectSize == "Mean") {
    overviewTable$addColumnInfo(
      name = "mean",
      title = "<i>M</i>",
      type = "number"
    )


    overviewTable$addColumnInfo(
      name = "mean_LL",
      title = "LL",
      type = "number",
      overtitle = paste0(100 * options$ciLevel, "% CI")
    )
    overviewTable$addColumnInfo(
      name = "mean_UL",
      title = "UL",
      type = "number",
      overtitle = paste0(100 * options$ciLevel, "% CI")
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


  if (options$effectSize == "Median") {
    overviewTable$addColumnInfo(
      name = "median",
      title = "<i>Mdn</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "median_LL",
      title = "LL",
      type = "number",
      overtitle = paste0(100 * options$ciLevel, "% CI")
    )
    overviewTable$addColumnInfo(
      name = "median_UL",
      title = "UL",
      type = "number",
      overtitle = paste0(100 * options$ciLevel, "% CI")
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


  if (options$calculationComponents & options$effectSize == "Mean") {
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
    overviewTable$setExpectedSize(length(options$variables))

  jaspResults[["overviewTable"]] <- overviewTable


  return()

}



jasp_smd_prep <- function(jaspResults, dataset, options, ready) {
  overviewTable <- createJaspTable(title = "Standardized Mean Difference")

  overviewTable$dependOn(c("variables", "ciLevel", "effectSize", "extraDetails", "nullValue", "hypothesisEvaluation"))


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
      overtitle = paste0(100 * options$ciLevel, "% CI")
  )

  overviewTable$addColumnInfo(
    name = "UL",
    title = "UL",
    type = "number",
    overtitle = paste0(100 * options$ciLevel, "% CI")
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
    overviewTable$setExpectedSize(length(options$variables))

  jaspResults[["smdTable"]] <- overviewTable

  return()

}


jasp_he_point_prep <- function(jaspResults, dataset, options, ready) {
  overviewTable <- createJaspTable(title = "Hypothesis Evaluation")

  overviewTable$dependOn(c("variables", "ciLevel", "effectSize", "nullValue", "nullROPE", "hypothesisEvaluation"))


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

  if (options$effectSize == "Mean") {
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
    overviewTable$setExpectedSize(length(options$variables))

  jaspResults[["heTable"]] <- overviewTable

  return()

}


jasp_he_interval_prep <- function(jaspResults, dataset, options, ready) {
  overviewTable <- createJaspTable(title = "Hypothesis Evaluation")

  overviewTable$dependOn(c("variables", "ciLevel", "effectSize", "nullValue", "nullROPE", "hypothesisEvaluation"))


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
    overviewTable$setExpectedSize(length(options$variables))

  jaspResults[["heTable"]] <- overviewTable

  return()

}



jasp_table_fill <- function(overviewTable, overview) {


  for (x in 1:nrow(overview)) {
      overviewTable$addRows(
        as.list(overview[x, ])
      )
  }

  return()
}

