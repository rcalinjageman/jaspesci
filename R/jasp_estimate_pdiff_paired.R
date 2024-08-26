jasp_estimate_pdiff_paired <- function(jaspResults, dataset = NULL, options, ...) {

  # Handles
  from_raw <- options$switch == "from_raw"
  evaluate_h <- options$evaluate_hypotheses

  ready <- FALSE
  if (from_raw) {
    ready <- (options$reference_measure != "") & (options$comparison_measure != "")
  } else {
    # Determine if summary data is ready
    ready <- !is.null(options$cases_consistent) & !is.null(options$cases_inconsistent) & !is.null(options$not_cases_consistent) & !is.null(options$not_cases_inconsistent)
    if (ready) {
      if ((options$cases_consistent + options$cases_inconsistent) <= 0) { ready <- FALSE}
      if ((options$not_cases_consistent + options$not_cases_inconsistent) <= 0) { ready <- FALSE}
    }
  }


  # check for errors
  if (ready) {
    if (from_raw) {
      # read dataset
      dataset <- jasp_estimate_pdiff_paired_read_data(dataset, options)

      mylevels <- levels(dataset[[options$comparison_measure]])
    }
  } else {
    mylevels <- 1
  }


  # Run the analysis
  if (ready) {
    call <- esci::estimate_pdiff_paired
    args <- list()

    args$conf_level <- options$conf_level

    if (from_raw) {
      args$data <- dataset
      args$reference_measure <- options$reference_measure
      args$comparison_measure <- options$comparison_measure

    } else {

      args$comparison_measure_name <- jasp_text_fix(options, "comparison_measure_name", "Outcome variable")
      args$reference_measure_name <- jasp_text_fix(options, "reference_measure_name", "Grouping variable")
      args$case_label <- jasp_text_fix(options, "case_label", "Sick")
      args$not_case_label <- jasp_text_fix(options, "not_case_label", "Well")

      args$cases_consistent <- options$cases_consistent
      args$cases_inconsistent <- options$cases_inconsistent
      args$not_cases_consistent <- options$not_cases_consistent
      args$not_cases_inconsistent <- options$not_cases_inconsistent

    }

    # debugtext <- createJaspHtml(text = paste(args, collapse = "<BR>"))
    # debugtext$dependOn(c("reference_measure", "comparison_measure"))
    # jaspResults[["debugtext"]] <- debugtext
    #

    estimate <- try(do.call(what = call, args = args))

    # debugtext <- createJaspHtml(text = paste(estimate, collapse = "<BR>"))
    # debugtext$dependOn(c("reference_measure", "comparison_measure"))
    # jaspResults[["moredebugtext"]] <- debugtext


    estimate$es_proportion_difference <- jasp_peffect_html(
      estimate$es_proportion_difference
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
      level = 1
    )

    jaspResults[["overviewTable"]]$position <- 1

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
      effect_label = "<i>P</i>",
      show_outcome_variable = FALSE
    )

    jaspResults[["es_proportion_difference"]]$position <- 20

    if (ready) jasp_table_fill(
      jaspResults[["es_proportion_difference"]],
      estimate,
      "es_proportion_difference"
    )
  }


  # Hypothesis evaluation table
  if(evaluate_h & is.null(jaspResults[["heTable"]])) {
    options$effect_size <- "proportion_difference"

    jasp_he_prep(
      jaspResults,
      options,
      ready,
      mytest,
      show_outcome_variable = FALSE
    )

    jaspResults[["heTable"]]$position <- 30

    if (ready) jasp_table_fill(
      jaspResults[["heTable"]],
      mytest,
      "to_fill"
    )
  }

  if (is.null(jaspResults[["mdiffPlot"]])) {
    jasp_plot_m_prep(
      jaspResults,
      options,
      ready
    )


    if (ready) {
      args <- list()
      args$estimate <- estimate

      args$difference_axis_space <- 0.5
      args$difference_axis_breaks <- jasp_numeric_fix(options, "difference_axis_breaks", 5)
      args$simple_contrast_labels <- options$simple_contrast_labels

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

      jaspResults[["mdiffPlot"]]$plotObject <- myplot

      jaspResults[["mdiffPlot"]]$position <- 40

    }  # end plot creation


  }


  return()
}



jasp_estimate_pdiff_paired_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(
      .readDataSetToEnd(
        columns.as.factor = c(options$comparison_measure, options$reference_measure)
      )
    )
}

