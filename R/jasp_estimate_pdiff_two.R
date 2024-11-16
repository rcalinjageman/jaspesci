jasp_estimate_pdiff_two <- function(jaspResults, dataset = NULL, options, ...) {

  # Handles
  from_raw <- options$switch == "from_raw"
  evaluate_h <- options$evaluate_hypotheses

  ready <- FALSE
  if (from_raw) {
    ready <- (length(options$outcome_variable) > 0) & (options$grouping_variable != "")
  } else {
    jasp_summary_dirty(options$summary_dirty, jaspResults)

    # Determine if summary data is ready
    ready <- !is.null(options$reference_cases) & !is.null(options$reference_not_cases) & !is.null(options$comparison_cases) & !is.null(options$comparison_not_cases)
    if (ready) {
      if ((options$reference_cases + options$reference_not_cases) <= 0) { ready <- FALSE}
      if ((options$comparison_cases + options$comparison_not_cases) <= 0) { ready <- FALSE}
    }
  }

  mylevels <- 1
  # check for errors
  if (ready) {
    if (from_raw) {
      # read dataset
      dataset <- jasp_estimate_pdiff_two_read_data(dataset, options)

      # check for errors
      # At least 2 levels in grouping variable
      .hasErrors(
        dataset = dataset,
        type = "factorLevels",
        factorLevels.target  = options$grouping_variable,
        factorLevels.amount  = "< 2",
        exitAnalysisIfErrors = TRUE
      )

      mylevels <- levels(dataset[[options$grouping_variable]])

      for (variable in options$outcome_variable) {

        # At least 2 levels in outcome variable
        .hasErrors(
          dataset = dataset,
          type = "factorLevels",
          factorLevels.target  = variable,
          factorLevels.amount  = "< 2",
          exitAnalysisIfErrors = TRUE
        )


        # at least 2 observations in each level of each outcome variable
        .hasErrors(
          dataset = dataset,
          type = c("observations", "variance", "infinity"),
          all.grouping = options$grouping_variable,
          all.target = variable,
          observations.amount  = "< 3",
          exitAnalysisIfErrors = TRUE
        )

      }
    }
  } else {
    mylevels <- 1
  }


  # Run the analysis
  if (ready) {
    call <- esci::estimate_pdiff_two
    args <- list()

    args$conf_level <- options$conf_level

    if (from_raw) {
      args$data <- dataset
      args$outcome_variable <- options$outcome_variable
      args$grouping_variable <- options$grouping_variable
      args$count_NA <- options$count_NA

    } else {

      args$outcome_variable_name <- jasp_text_fix(options, "outcome_variable_name", "Outcome variable")
      args$grouping_variable_name <- jasp_text_fix(options, "grouping_variable_name", "Grouping variable")
      args$grouping_variable_levels <- c(
        jasp_text_fix(options, "grouping_variable_level1", "Control"),
        jasp_text_fix(options, "grouping_variable_level2", "Treated")
      )
      args$case_label <- jasp_text_fix(options, "case_label", "Sick")
      args$not_case_label <- jasp_text_fix(options, "not_case_label", "Well")

      args$comparison_cases <- options$comparison_cases
      args$comparison_n <- options$comparison_cases + options$comparison_not_cases

      args$reference_cases <- options$reference_cases
      args$reference_n <- options$reference_cases + options$reference_not_cases
    }

    estimate <- try(do.call(what = call, args = args))

    # debugtext <- createJaspHtml(text = paste(names(args), args, collapse = "<BR>"))
    # debugtext$dependOn(c("reference_measure", "comparison_measure"))
    # jaspResults[["debugtext"]] <- debugtext
    #
    # debugtext <- createJaspHtml(text = paste(names(estimate), estimate, collapse = "<BR>"))
    # debugtext$dependOn(c("reference_measure", "comparison_measure"))
    # jaspResults[["moredebugtext"]] <- debugtext


    if (!from_raw) {
      ov_name <- jasp_text_fix(
        options,
        "outcome_variable_name",
        "Outcome variable"
      )

      estimate[[ov_name]] <- estimate
      options$outcome_variable <- ov_name
    } else {
      if (length(options$outcome_variable) == 1) {
        estimate[[options$outcome_variable[[1]]]] <- estimate
      }
    }

    estimate$es_proportion_difference <- jasp_peffect_html(
      estimate$es_proportion_difference
    )

    estimate$es_odds_ratio <- jasp_peffect_html(
      estimate$es_odds_ratio
    )


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
      level = length(mylevels)
    )

    jaspResults[["overviewTable"]]$position <- 10

    if (ready) {
      jasp_table_fill(
        jaspResults[["overviewTable"]],
        estimate,
        "overview"
      )
    }
  }

  # pdiff table
  if(is.null(jaspResults[["es_proportion_difference"]])) {
    jasp_es_proportion_prep(
      jaspResults = jaspResults,
      options = options,
      ready = ready,
      table_name = "es_proportion_difference",
      table_title = "Proportion Difference",
      effect_label = "<i>P</i>"
    )

    jaspResults[["es_proportion_difference"]]$position <- 20

    if (ready) jasp_table_fill(
      jaspResults[["es_proportion_difference"]],
      estimate,
      "es_proportion_difference"
    )
  }


  # odds ratio table
  if(options$show_ratio & is.null(jaspResults[["es_odds_ratio"]])) {
    jasp_es_proportion_prep(
      jaspResults = jaspResults,
      options = options,
      ready = ready,
      table_name = "es_odds_ratio",
      table_title = "Odds Ratio",
      effect_label = "<i>OR</i>"
    )

    jaspResults[["es_odds_ratio"]]$position <- 30

    if (ready) jasp_table_fill(
      jaspResults[["es_odds_ratio"]],
      estimate,
      "es_odds_ratio"
    )
  }

  # chi square table
  if (options$show_chi_square & ready & is.null(jaspResults[["chi_square"]])  ) {
    self <- list()
    self$options <- options
    jamovi_contingency_table(self, estimate, jaspResults)

    jaspResults[["chi_square"]]$position <- 40

  }


  # correlation table
  if(options$show_phi & is.null(jaspResults[["es_phi"]])) {
    jasp_es_proportion_prep(
      jaspResults = jaspResults,
      options = options,
      ready = ready,
      table_name = "es_phi",
      table_title = "Correlation",
      effect_label = "&#981;"
    )

    jaspResults[["es_phi"]]$position <- 50

    if (ready) jasp_table_fill(
      jaspResults[["es_phi"]],
      estimate,
      "es_phi"
    )
  }



  # Hypothesis evaluation table
  if(evaluate_h & is.null(jaspResults[["heTable"]])) {
    options$effect_size <- "proportion_difference"

    jasp_he_prep(
      jaspResults,
      options,
      ready,
      mytest
    )

    jaspResults[["heTable"]]$position <- 60

    if (ready) jasp_table_fill(
      jaspResults[["heTable"]],
      mytest,
      "to_fill"
    )
  }


  # Figure
  # Now prep and fill the plot
  x <- 0
  for (my_variable in options$outcome_variable) {
    x <- x + 1

    # debugtext <- createJaspHtml(text = paste(my_variable, " - </BR>"))
    # debugtext$dependOn(c("outcome_variable", "count_NA"))
    # jaspResults[[paste(my_variable, "debugtext", sep = "")]] <- debugtext


    if (is.null(jaspResults[[my_variable]])) {
      jasp_plot_m_prep(
        jaspResults,
        options,
        ready,
        my_variable = my_variable,
        add_citation = FALSE
      )

      jaspResults[[my_variable]]$position <- 70+x

      if (ready) {
        args <- list()
        args$estimate <- estimate[[my_variable]]

        args$difference_axis_space <- 0.5

        args$difference_axis_breaks <- jasp_numeric_fix(options, "difference_axis_breaks", 5)

        args$ylim <- c(
          jasp_numeric_fix(options, "ymin", NA),
          jasp_numeric_fix(options, "ymax", NA)
        )

        args$ybreaks <- jasp_numeric_fix(options, "ybreaks", NULL)


        if (evaluate_h) {
          args$rope <- c(
            options$null_value - options$null_boundary,
            options$null_value + options$null_boundary
          )
        }

        myplot <- do.call(
          what = esci::plot_pdiff,
          args = args
        )

        myplot <- jasp_plot_pdiff_decorate(myplot, options)

        jaspResults[[my_variable]]$plotObject <- myplot

      }  # end plot creation


    } # end check if plot is null
  } # end loop through outcome variables


  return()
}



jasp_estimate_pdiff_two_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(
      .readDataSetToEnd(
        columns.as.factor = c(options$outcome_variable, options$grouping_variable)
      )
    )
}

