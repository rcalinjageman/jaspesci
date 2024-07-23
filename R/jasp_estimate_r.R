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
        "sp_prediction_color"
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


jasp_scatterplot_decorate <- function(myplot, options, r_value) {
  self <- list()
  self$options <- options

  if (self$options$show_r) {

    font_size <- self$options$sp_axis.title.x

    new_label <- paste(
      "<span style='font-size:",
      font_size,
      "pt'>*r* = ",
      format(r_value, digits = 2),
      "</span>",
      sep = ""
    )
    if (!is.null(myplot$layers$r_label)) {
      myplot$layers$r_label$mapping$label<- new_label
    }
  }


  # Axis options
  if (!(options$sp_ylab %in% c("auto", "Auto", "AUTO", ""))) {
    myplot <- myplot + ggplot2::ylab(options$sp_ylab)
  }

  if (!(options$sp_xlab %in% c("auto", "Auto", "AUTO", ""))) {
    myplot <- myplot + ggplot2::xlab(options$sp_xlab)
  }


  xlim <- c(
    jasp_numeric_fix(options, "sp_xmin", myplot$esci_xmin),
    jasp_numeric_fix(options, "sp_xmax", myplot$esci_xmax)
  )

  xbreaks <- jasp_numeric_fix(options, "sp_xbreaks", NULL)

  myplot <- myplot + ggplot2::scale_x_continuous(
    limits = xlim,
    n.breaks = xbreaks,
    expand = c(0, 0)
  )

  ylim <- c(
    jasp_numeric_fix(options, "sp_ymin", myplot$esci_ymin),
    jasp_numeric_fix(options, "sp_ymax", myplot$esci_ymax)
  )

  ybreaks <- jasp_numeric_fix(options, "sp_ybreaks", NULL)

  myplot <- myplot + ggplot2::scale_y_continuous(
    limits = ylim,
    n.breaks = ybreaks,
    expand = c(0, 0)
  )


  myplot <- myplot + ggplot2::theme(
    axis.text.y = ggtext::element_markdown(size = self$options$sp_axis.text.y),
    axis.title.y = ggtext::element_markdown(size = self$options$sp_axis.title.y),
    axis.text.x = ggtext::element_markdown(size = self$options$sp_axis.text.x),
    axis.title.x = ggtext::element_markdown(size = self$options$sp_axis.title.x),
    legend.title = ggtext::element_markdown(),
    legend.text = ggtext::element_markdown()
  )

  myplot$layers$raw_Reference_point$aes_params$fill <- self$options$sp_fill_raw_reference
  myplot$layers$raw_Reference_point$aes_params$colour <- self$options$sp_color_raw_reference
  myplot$layers$raw_Reference_point$aes_params$size <- as.numeric(self$options$sp_size_raw_reference)
  myplot$layers$raw_Reference_point$aes_params$alpha <- 1 - as.numeric(self$options$sp_alpha_raw_reference)
  myplot$layers$raw_Reference_point$aes_params$shape <- self$options$sp_shape_raw_reference
  #

  if (!is.null(myplot$layers$summary_Reference_line) & self$options$show_line) {
    myplot$layers$summary_Reference_line$aes_params$colour <- self$options$sp_color_summary_reference
    #myplot$layers$summary_Reference_line$aes_params$fill <- self$options$sp_color_summary_reference
    #myplot$layers$summary_Reference_line$aes_params$alpha <- as.numeric(self$options$sp_alpha_summary_reference)
    myplot$layers$summary_Reference_line$aes_params$linetype <- self$options$sp_linetype_summary_reference
    myplot$layers$summary_Reference_line$aes_params$size <- as.numeric(self$options$sp_size_summary_reference)/2

  }


  if (!is.null(myplot$layers$summary_Reference_line_CI) & self$options$show_line_CI) {
    #myplot$layers$summary_Reference_line$aes_params$colour <- self$options$sp_color_summary_reference
    myplot$layers$summary_Reference_line_CI$aes_params$fill <- self$options$sp_color_summary_reference
    myplot$layers$summary_Reference_line_CI$aes_params$alpha <- 1 - as.numeric(self$options$sp_alpha_summary_reference)
    #myplot$layers$summary_Reference_line$aes_params$linetype <- self$options$sp_linetype_summary_reference
    #myplot$layers$summary_Reference_line$aes_params$size <- as.numeric(self$options$sp_size_summary_reference)/2
  }

  if (!is.null(myplot$layers$residuals)) {
    myplot$layers$residuals$aes_params$colour <- self$options$sp_color_residual_reference
    myplot$layers$residuals$aes_params$alpha <- 1 - as.numeric(self$options$sp_alpha_residual_reference)
    myplot$layers$residuals$aes_params$linetype <- self$options$sp_linetype_residual_reference
    myplot$layers$residuals$aes_params$size <- as.numeric(self$options$sp_size_residual_reference)/2
  }

  if (!is.null(myplot$layers$prediction_interval_upper)) {
    myplot$layers$prediction_interval_upper$aes_params$colour <- self$options$sp_color_PI_reference
    myplot$layers$prediction_interval_upper$aes_params$alpha <- 1 - as.numeric(self$options$sp_alpha_PI_reference)
    myplot$layers$prediction_interval_upper$aes_params$linetype <- self$options$sp_linetype_PI_reference
    myplot$layers$prediction_interval_upper$aes_params$size <- as.numeric(self$options$sp_size_PI_reference)/2
  }

  if (!is.null(myplot$layers$prediction_interval_lower)) {
    myplot$layers$prediction_interval_lower$aes_params$colour <- self$options$sp_color_PI_reference
    myplot$layers$prediction_interval_lower$aes_params$alpha <- 1 - as.numeric(self$options$sp_alpha_PI_reference)
    myplot$layers$prediction_interval_lower$aes_params$linetype <- self$options$sp_linetype_PI_reference
    myplot$layers$prediction_interval_lower$aes_params$size <- as.numeric(self$options$sp_size_PI_reference)/2
  }

  if (!is.null(myplot$layers$prediction_y_label)) {
    myplot$layers$prediction_y_label$aes_params$size <- as.numeric(self$options$sp_prediction_label)
    myplot$layers$prediction_y_label$aes_params$text.colour <- self$options$sp_prediction_color
  }

  if (!is.null(myplot$layers$prediction_x_label)) {
    myplot$layers$prediction_x_label$aes_params$size <- as.numeric(self$options$sp_prediction_label)
    myplot$layers$prediction_x_label$aes_params$text.colour <- self$options$sp_prediction_color
  }

  if (!is.null(myplot$layers$prediction_prediction_interval)) {
    myplot$layers$prediction_prediction_interval$aes_params$colour <- self$options$sp_color_PI
    myplot$layers$prediction_prediction_interval$aes_params$alpha <- 1 - as.numeric(self$options$sp_alpha_PI)/15
    myplot$layers$prediction_prediction_interval$aes_params$linetype <- self$options$sp_linetype_PI
    myplot$layers$prediction_prediction_interval$aes_params$size <- as.numeric(self$options$sp_size_PI)/2
  }

  if (!is.null(myplot$layers$prediction_confidence_interval)) {
    myplot$layers$prediction_confidence_interval$aes_params$colour <- self$options$sp_color_CI
    myplot$layers$prediction_confidence_interval$aes_params$alpha <- 1 - as.numeric(self$options$sp_alpha_CI)/15
    myplot$layers$prediction_confidence_interval$aes_params$linetype <- self$options$sp_linetype_CI
    myplot$layers$prediction_confidence_interval$aes_params$size <- as.numeric(self$options$sp_size_CI)/2
  }

  if (!is.null(myplot$layers$prediction_vertical_line)) {
    myplot$layers$prediction_vertical_line$aes_params$colour <- self$options$sp_color_ref
    myplot$layers$prediction_vertical_line$aes_params$alpha <- 1 - (as.numeric(self$options$sp_alpha_ref)/15)
    myplot$layers$prediction_vertical_line$aes_params$linetype <- self$options$sp_linetype_ref
    myplot$layers$prediction_vertical_line$aes_params$size <- as.numeric(self$options$sp_size_ref)/2
  }

  if (!is.null(myplot$layers$prediction_horizontal_line)) {
    myplot$layers$prediction_horizontal_line$aes_params$colour <- self$options$sp_color_ref
    myplot$layers$prediction_horizontal_line$aes_params$alpha <- 1 - (as.numeric(self$options$sp_alpha_ref)/15)
    myplot$layers$prediction_horizontal_line$aes_params$linetype <- self$options$sp_linetype_ref
    myplot$layers$prediction_horizontal_line$aes_params$size <- as.numeric(self$options$sp_size_ref)/2
  }


  return(myplot)
}
