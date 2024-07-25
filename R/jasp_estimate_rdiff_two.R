jasp_estimate_rdiff_two <- function(jaspResults, dataset = NULL, options, ...) {

  return()

  # Handles
  from_raw <- options$switch == "from_raw"
  evaluate_h <- options$evaluate_hypotheses

  ready <- FALSE
  if (from_raw) {
    ready <- (options$x != "") & (options$y != "")
  } else {
    # Determine if summary data is ready
    ready <- !is.null(options$r) & !is.null(options$n)
    if (ready) {
      if ((options$r) <= -1 | options$r >= 1) { ready <- FALSE}
      if (options$n <= 2) { ready <- FALSE}
    }
  }


  # check for errors
  if (ready) {
    if (from_raw) {
      # read dataset
      dataset <- jasp_estimate_r_read_data(dataset, options)

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
    call <- esci::estimate_r
    args <- list()

    if (from_raw) {
      args$data <- dataset
      args$x <- options$x
      args$y <- options$y

    } else {

      args$r <- options$r
      args$n <- options$n
      args$x_variable_name <- jasp_text_fix(options, "x_variable_name", "X-variable")
      args$y_variable_name <- jasp_text_fix(options, "y_variable_name", "Y-variable")

    }

    args$conf_level <- options$conf_level

    estimate <- try(do.call(what = call, args = args))

    # Things to move into esci ----------------------
    # sxy
    if (!is.null(estimate$properties$lm)) {
      estimate$es_r$syx <- summary(estimate$properties$lm)$sigma
    }
    #
    # Fill in MoE
    estimate$overview$moe <- (estimate$overview$mean_UL - estimate$overview$mean_LL)/2

    # switch regression table to html
    estimate$regression$component <- gsub(
      "(a)",
      "<i>a</i>",
      estimate$regression$component
    )
    estimate$regression$component <- gsub(
      "(b)",
      "<i>b</i>",
      estimate$regression$component
    )

    # --------------------------------------


    if(evaluate_h & is.null(jaspResults[["heTable"]])) {
      mytest <- esci::test_correlation(
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
    jasp_overview_prep(
      jaspResults,
      options,
      ready,
      estimate,
      level = length(levels)
    )

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

    if (ready) jasp_table_fill(
      jaspResults[["es_r"]],
      estimate,
      "es_r"
    )
  }

  # r table
  if(is.null(jaspResults[["regression"]]) & from_raw & options$do_regression) {
    jasp_regression_prep(
      jaspResults = jaspResults,
      options = options,
      ready = ready
    )

    if (ready) jasp_table_fill(
      jaspResults[["regression"]],
      estimate,
      "regression"
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

    scatterplot$dependOn(
      c(
        "show_line",
        "show_line_CI",
        "show_PI",
        "show_residuals",
        "show_mean_lines",
        "plot_as_z",
        "show_r",
        "predict_from_x",
        "x",
        "y",
        "sp_plot_width",
        "sp_plot_height",
        "sp_ylab",
        "sp_axis.text.y",
        "sp_axis.title.y",
        "sp_ymin",
        "sp_ymax",
        "sp_ybreaks",
        "sp_xlab",
        "sp_axis.text.x",
        "sp_axis.title.x",
        "sp_xmin",
        "sp_xmax",
        "sp_xbreaks",
        "show_mean_lines",
        "plot_as_z",
        "show_r",
        "sp_shape_raw_reference",
        "sp_color_raw_reference",
        "sp_fill_raw_reference",
        "sp_size_raw_reference",
        "sp_alpha_raw_reference",
        "sp_linetype_summary_reference",
        "sp_linetype_PI_reference",
        "sp_linetype_residual_reference",
        "sp_size_summary_reference",
        "sp_size_PI_reference",
        "sp_size_residual_reference",
        "sp_color_summary_reference",
        "sp_color_PI_reference",
        "sp_color_residual_reference",
        "sp_alpha_summary_reference",
        "sp_alpha_PI_reference",
        "sp_alpha_residual_reference",
        "sp_prediction_label",
        "sp_prediction_color",
        "sp_linetype_ref",
        "sp_linetype_PI",
        "sp_linetype_CI",
        "sp_size_ref",
        "sp_size_PI",
        "sp_size_CI",
        "sp_color_ref",
        "sp_color_PI",
        "sp_color_CI",
        "sp_alpha_ref",
        "sp_alpha_PI",
        "sp_alpha_CI"
      )
    )

    jaspResults[["scatterPlot"]] <- scatterplot

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

      myplot <- jasp_scatterplot_decorate(myplot, options, r_value = estimate$es_r$effect_size[[1]])

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

      if (evaluate_h) {
        args$rope <- c(
          options$null_value - options$null_boundary,
          options$null_value + options$null_boundary
        )
      }

      myplot <- do.call(
        what = esci::plot_correlation,
        args = args
      )

      myplot <- jasp_plot_correlation_decorate(myplot, options)

      jaspResults[["mdiffPlot"]]$plotObject <- myplot

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
        columns.as.numeric = c(options$x, options$y)
      )
    )
}



