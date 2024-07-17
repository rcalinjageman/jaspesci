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
    call <- esci::estimate_pdiff_one
    args <- list()


    null_value <- 0
    if (options$evaluate_hypotheses) null_value <- options$null_value
    if (is.null(null_value)) null_value <- 0

    args$conf_level <- options$conf_level
    args$reference_p <- null_value
    args$count_NA <- options$count_NA

    if (from_raw) {
      args$data <- dataset
      args$outcome_variable <- encodeColNames(options$outcome_variable)
    } else {
      outcome_variable_name <- "Outcome variable"
      if (!is.null(options$outcome_variable_name)) {
        if (!(options$outcome_variable_name %in% c("auto", "Auto", "AUTO", ""))) {
          outcome_variable_name <- options$outcome_variable_name
        }
      }
      args$comparison_n <- options$comparison_cases + options$not_cases
      args$case_label <- options$case_label
      args$outcome_variable_name <- outcome_variable_name
    }

    estimate <- try(do.call(what = call, args = args))


    # debugtext <- createJaspHtml(text = paste(estimate, collapse = "<BR>"))
    # debugtext$dependOn(c("outcome_variable", "count_NA"))
    # jaspResults[["debugtext"]] <- debugtext


    if(evaluate_h & is.null(jaspResults[["heTable"]])) {
      options$effect_size <- "pdiff"
      mytest <- jasp_test_pdiff(
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


  # Hypothesis evaluation table and pdiff table
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

  return()


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



