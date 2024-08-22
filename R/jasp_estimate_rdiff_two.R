jasp_estimate_rdiff_two <- function(jaspResults, dataset = NULL, options, ...) {

  # Handles
  from_raw <- options$switch == "from_raw"
  evaluate_h <- options$evaluate_hypotheses

  ready <- FALSE
  if (from_raw) {
    ready <- (options$x != "") & (options$y != "") & (options$grouping_variable != "")
  } else {
    # Determine if summary data is ready
    ready <- !is.null(options$comparison_r) & !is.null(options$comparison_n) & !is.null(options$reference_r) & !is.null(options$reference_n)
    if (ready) {
      if ((options$comparison_r) <= -1 | options$comparison_r >= 1) { ready <- FALSE}
      if ((options$reference_r) <= -1 | options$reference_r >= 1) { ready <- FALSE}
      if (options$comparison_n <= 2) { ready <- FALSE}
      if (options$reference_n <= 2) { ready <- FALSE}
    }
  }


  # check for errors
  if (ready) {
    if (from_raw) {
      # read dataset
      dataset <- jasp_estimate_rdiff_two_read_data(dataset, options)

      # check for errors
      # At least 2 observations per variable
      .hasErrors(
        dataset = dataset,
        type = "observations",
        observations.target = c(options$x, options$y),
        observations.amount  = "< 3",
        exitAnalysisIfErrors = TRUE
      )

    }
  }

  # Run the analysis
  if (ready) {
    call <- esci::estimate_rdiff_two
    args <- list()

    if (from_raw) {
      args$data <- dataset
      args$x <- options$x
      args$y <- options$y
      args$grouping_variable <- options$grouping_variable

    } else {

      args$comparison_r <- options$comparison_r
      args$comparison_n <- options$comparison_n
      args$reference_r <- options$reference_r
      args$reference_n <- options$reference_n
      args$x_variable_name <- jasp_text_fix(options, "x_variable_name", "X-variable")
      args$y_variable_name <- jasp_text_fix(options, "y_variable_name", "Y-variable")
      args$grouping_variable_name <- jasp_text_fix(options, "grouping_variable_name", "Grouping variable")
      args$grouping_variable_levels <- c(
        jasp_text_fix(options, "reference_level_name", "Reference level"),
        jasp_text_fix(options, "comparison_level_name", "Comparison level")
      )
    }

    args$conf_level <- options$conf_level

    estimate <- try(do.call(what = call, args = args))

    # Things to move into esci ----------------------
    # Fill in MoE
    estimate$overview$moe <- (estimate$overview$mean_UL - estimate$overview$mean_LL)/2

    # --------------------------------------


    if(evaluate_h & is.null(jaspResults[["heTable"]])) {
      mytest <- esci::test_rdiff(
        estimate,
        rope = c(options$null_value - options$null_boundary, options$null_value + options$null_boundary),
        output_html = TRUE
      )

      mytest$to_fill <- if (options$null_boundary > 0) mytest$interval_null else mytest$point_null
    }
  }


  # Overview
  if (is.null(jaspResults[["overviewTable"]]) & from_raw) {
    options$effect_size <- "r"
    options$show_calculations <- FALSE
    options$assume_equal_variance <- TRUE

    mylevels <- levels(dataset[[options$grouping_variable]])

    jasp_overview_prep(
      jaspResults,
      options,
      ready,
      estimate,
      level = length(mylevels)
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


  # r table
  if(is.null(jaspResults[["es_r"]])) {
    jasp_es_r_prep(
      jaspResults = jaspResults,
      options = options,
      ready = ready
    )

    jaspResults[["es_r"]]$position <- 10


    if (ready) jasp_table_fill(
      jaspResults[["es_r"]],
      estimate,
      "es_r"
    )
  }


  # r_difference table
  if(is.null(jaspResults[["es_r_difference"]])) {
    jasp_es_r_difference_prep(
      jaspResults = jaspResults,
      options = options,
      ready = ready
    )

    jaspResults[["es_r_difference"]]$position <- 20


    if (ready) jasp_table_fill(
      jaspResults[["es_r_difference"]],
      estimate,
      "es_r_difference"
    )
  }

  # Hypothesis evaluation table
  if(evaluate_h & is.null(jaspResults[["heTable"]])) {
    options$effect_size <- "r"

    jasp_he_prep(
      jaspResults,
      options,
      ready,
      mytest
    )

    jaspResults[["heTable"]]$position <- 30


    if (ready) jasp_table_fill(
      jaspResults[["heTable"]],
      mytest,
      "to_fill"
    )
  }

  # scatterplot
  if (is.null(jaspResults[["scatterPlot"]])) {

    scatterplot <- createJaspPlot(
      title = "Scatterplot",
      width = options$sp_plot_width,
      height = options$sp_plot_height
    )

    scatterplot$dependOn(jasp_scatterplot_depends_on())

    jaspResults[["scatterPlot"]] <- scatterplot
    jaspResults[["scatterPlot"]]$position <- 40

    if (ready) {
      args <- list()
      args$estimate <- estimate
      args$show_line <- options$show_line
      args$show_line_CI <- options$show_line_CI
      args$show_PI <- options$show_PI
      args$show_residuals <- options$show_residuals
      args$show_mean_lines <- options$show_mean_lines
      args$plot_as_z <- options$plot_as_z
      args$show_r <- options$show_r
      args$predict_from_x <- jasp_numeric_fix(options, "predict_from_x", NULL)


      myplot <- do.call(
        what = esci::plot_scatter,
        args = args
      )

      myplot <- jasp_scatterplot_decorate(
        myplot,
        options,
        r_value = estimate$es_r$effect_size[[1]],
        rdiff = TRUE,
        scale_title = estimate$es_r$grouping_variable_name[[1]]
      )

      jaspResults[["scatterPlot"]]$plotObject <- myplot

    }  # end scatterplot creation
  } # end scatterplot


  # estimation plot
  if (is.null(jaspResults[["mdiffPlot"]])) {
    jasp_plot_m_prep(
      jaspResults,
      options,
      ready
    )

    if (ready) {
      args <- list()
      args$estimate <- estimate
      args$error_layout <- "none"
      args$ylim <- c(
        jasp_numeric_fix(options, "ymin", -1),
        jasp_numeric_fix(options, "ymax", 1)
      )
      args$ybreaks <- jasp_numeric_fix(options, "ybreaks", NULL)

      if (evaluate_h) {
        args$rope <- c(
          options$null_value - options$null_boundary,
          options$null_value + options$null_boundary
        )
      }

      myplot <- do.call(
        what = esci::plot_rdiff,
        args = args
      )

      myplot <- jasp_plot_correlation_decorate(myplot, options, rdiff = TRUE)

      jaspResults[["mdiffPlot"]]$plotObject <- myplot
      jaspResults[["mdiffPlot"]]$position <- 50

    }  # end estimationplot creation
  } # end estimation plot


  return()
}



jasp_estimate_rdiff_two_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(
      .readDataSetToEnd(
        columns.as.numeric = c(options$x, options$y),
        columns.as.factor = options$grouping_variable
      )
    )
}



