jasp_estimate_r <- function(jaspResults, dataset = NULL, options, ...) {

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
    jasp_plot_m_prep(
      jaspResults,
      options,
      ready,
      my_variable = "scatterPlot",
      add_citation = FALSE
    )

    jaspResults[["scatterPlot"]]$dependOn(
      c(
        jaspResults[["scatterPlot"]]$dependOn(),
        "show_line",
        "show_line_CI",
        "show_PI",
        "show_residuals",
        "show_mean_lines",
        "plot_as_z",
        "show_r",
        "predict_from_x",
        "x",
        "y"
      )
    )

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

      # myplot <- jasp_plot_correlation_decorate(myplot, options)

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



jasp_estimate_r_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(
      .readDataSetToEnd(
        columns.as.numeric = c(options$x, options$y)
      )
    )
}


jasp_plot_correlation_decorate <- function(myplot, options) {
  self <- list()
  self$options <- options


  # Font sizes
  myplot <- myplot + ggplot2::theme(
    axis.text.y = ggtext::element_markdown(size = options$axis.text.y),
    axis.title.y = ggtext::element_markdown(size = options$axis.title.y),
    axis.text.x = ggtext::element_markdown(size = options$axis.text.x),
    axis.title.x = ggtext::element_markdown(size = options$axis.title.x)
  )

  # Axis options
  if (!(options$ylab %in% c("auto", "Auto", "AUTO", ""))) {
    myplot <- myplot + ggplot2::ylab(options$ylab)
  }

  if (!(options$xlab %in% c("auto", "Auto", "AUTO", ""))) {
    myplot <- myplot + ggplot2::xlab(options$xlab)
  }


  ylim <- c(
    jasp_numeric_fix(options, "ymin", -1),
    jasp_numeric_fix(options, "ymax", 1)
  )

  ybreaks <- jasp_numeric_fix(options, "ybreaks", NULL)

  myplot <- myplot + ggplot2::scale_y_continuous(
    limits = ylim,
    n.breaks = ybreaks
  )


  if (self$options$evaluate_hypotheses) {
    myplot$layers[["null_line"]]$aes_params$colour <- self$options$null_color
    if ( options$null_boundary > 0) {
      divider <- 1
      try(myplot$layers[["null_interval"]]$aes_params$fill <- self$options$null_color, silent = TRUE)
      try(myplot$layers[["ta_CI"]]$aes_params$size <- as.numeric(self$options$size_interval)/divider+1, silent = TRUE)
      try(myplot$layers[["ta_CI"]]$aes_params$alpha <-1 - as.numeric(self$options$alpha_interval), silent = TRUE)
      try(myplot$layers[["ta_CI"]]$aes_params$colour <- self$options$color_interval, silent = TRUE)
      try(myplot$layers[["ta_CI"]]$aes_params$linetype <- self$options$linetype_summary, silent = TRUE)

    }
  }


  # Slab
  # myplot <- myplot + ggplot2::scale_fill_manual(
  #   values = c(
  #     "summary" = self$options$fill_error
  #   ),
  #   aesthetics = "slab_fill"
  # )
  #
  # myplot <- myplot + ggplot2::discrete_scale(
  #   "slab_alpha",
  #   "slab_alpha_d",
  #   function(n) return(c(
  #     "summary" = 1 - as.numeric(self$options$alpha_error)
  #   ))
  # )


  #aesthetics
  myplot <- myplot + ggplot2::scale_shape_manual(
    values = c(
      "raw" = "circle",
      "summary" = self$options$shape_summary
    )
  )

  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "raw" = "black",
      "summary" = self$options$color_summary
    ),
    aesthetics = c("color", "point_color")
  )

  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "raw" = "black",
      "summary" = self$options$fill_summary
    ),
    aesthetics = c("fill", "point_fill")
  )

  myplot <- myplot + ggplot2::discrete_scale(
    c("size", "point_size"),
    "point_size_d",
    function(n) return(c(
      "raw" = 2,
      "summary" = as.numeric(self$options$size_summary)
    ))
  )

  myplot <- myplot + ggplot2::discrete_scale(
    c("alpha", "point_alpha"),
    "point_alpha_d",
    function(n) return(c(
      "raw" = 1,
      "summary" = 1 - as.numeric(self$options$alpha_summary)
    ))
  )

  myplot <- myplot + ggplot2::scale_linetype_manual(
    values = c(
      "summary" = self$options$linetype_summary
    )
  )

  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "summary" = self$options$color_interval
    ),
    aesthetics = "interval_color"
  )
  myplot <- myplot + ggplot2::discrete_scale(
    "interval_alpha",
    "interval_alpha_d",
    function(n) return(c(
      "summary" = 1 - as.numeric(self$options$alpha_interval)
    ))
  )
  myplot <- myplot + ggplot2::discrete_scale(
    "interval_size",
    "interval_size_d",
    function(n) return(c(
      "summary" = as.numeric(self$options$size_interval)
    ))
  )


  return(myplot)

}
