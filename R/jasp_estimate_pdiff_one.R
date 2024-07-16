jasp_estimate_pdiff_one <- function(jaspResults, dataset = NULL, options, ...) {

  # Handles
  from_raw <- options$switch == "from_raw"
  evaluate_h <- options$evaluate_hypotheses

  ready <- FALSE
  if (from_raw) {
    ready <- (length(options$outcome_variable) > 0)
  } else {
    # Determine if summary data is ready
    ready <- !is.null(options$cases) & !is.null(options$not_cases)
    if (ready) ready <- ready & options$cases >= 0 & options$not_cases >= 0 & ((options$cases + options$not_cases) > 0)

  }


  # check for errors
  if (from_raw & ready) {
    # read dataset
    dataset <- jasp_estimate_pdiff_one_read_data(dataset, options)

    for (variable in options$outcome_variable) {

      # At least 2 levels in outcome variable
      .hasErrors(
        dataset = dataset,
        type = "factorLevels",
        factorLevels.target  = options$outcome_variable,
        factorLevels.amount  = "< 2",
        exitAnalysisIfErrors = TRUE
      )


    }
  }

  # Run the analysis
  if (ready) {
    null_value <- 0
    if (options$evaluate_hypotheses) null_value <- options$null_value
    if (is.null(null_value)) null_value <- 0

    if (from_raw) {
      estimate <- esci::estimate_pdiff_one(
        data = dataset,
        outcome_variable = encodeColNames(options$outcome_variable),
        reference_p = null_value,
        conf_level = options$conf_level,
        count_NA = options$count_NA
      )

    } else {

      outcome_variable_name <- "Outcome variable"
      if (!is.null(options$outcome_variable_name)) {
        if (!(options$outcome_variable_name %in% c("auto", "Auto", "AUTO", ""))) {
          outcome_variable_name <- options$outcome_variable_name
        }
      }

      mysum <- options$cases + options$not_cases

      estimate <- esci::estimate_mdiff_one(
        comparison_cases = options$cases,
        comparison_n = mysum,
#        case_label = c(options$case_label, options$not_case_label),
        outcome_variable_name = outcome_variable_name,
        reference_p = null_value,
        conf_level = options$conf_level
      )

    }


    debugtext <- createJaspHtml(text = paste(estimate, collapse = "<BR>"))
    debugtext$dependOn(c("outcome_variable", "count_NA"))
    jaspResults[["debugtext"]] <- debugtext


    if(evaluate_h & is.null(jaspResults[["heTable"]])) {
      mytest <- jasp_test_mdiff(
        options,
        estimate
      )
    }


  }


  # Overview
  if (is.null(jaspResults[["overviewTable"]])) {
    jasp_poverview_prep(
      jaspResults,
      options,
      ready,
      estimate,
      level = 1
    )

    if (ready) {
      jasp_table_fill(
        jaspResults[["overviewTable"]],
        estimate,
        "overview"
      )
    }
  }

  return()



  # Hypothesis evaluation table and smd table
  if(evaluate_h & is.null(jaspResults[["heTable"]])) {
    jasp_he_prep(
      jaspResults,
      options,
      ready,
      mytest
    )

    if (ready) jasp_table_fill(
      jaspResults[["heTable"]],
      mytest,
      "to_fill"
    )

  }

  # Smd table
  if(evaluate_h & options$effect_size == "mean" & is.null(jaspResults[["smdTable"]])) {
    jasp_smd_prep(
      jaspResults,
      options,
      ready,
      estimate
    )

    if (ready) jasp_table_fill(
      jaspResults[["smdTable"]],
      estimate,
      "es_smd"
    )

  }


  # Figure
  if (is.null(jaspResults[["mdiffPlot"]])) {
    jasp_plot_m_prep(
      jaspResults,
      options,
      ready,
      add_citation = TRUE
    )

    if (ready) {
      args <- list()
      if (from_raw) {
        args$estimate <- estimate_big
      } else {
        args$estimate <- estimate
      }
      args$effect_size <- options$effect_size
      args$data_layout <- options$data_layout
      args$data_spread <- options$data_spread
      args$error_layout <- options$error_layout
      args$error_scale <- options$error_scale
      args$error_nudge <- options$error_nudge
      if (evaluate_h) {
        args$rope <- c(
          options$null_value - options$null_boundary,
          options$null_value + options$null_boundary
        )
      }

      myplot <- do.call(
        what = esci::plot_magnitude,
        args = args
      )

      myplot <- jasp_plot_magnitude_decorate(myplot, options)

      jaspResults[["mdiffPlot"]]$plotObject <- myplot

    }
  }


  return()
}



jasp_estimate_pdiff_one_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(.readDataSetToEnd(columns.as.factor = options$outcome_variable))
}



