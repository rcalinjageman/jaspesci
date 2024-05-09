jasp_estimate_mdiff_one <- function(jaspResults, dataset = NULL, options, ...) {


  ready <- (length(options$outcome_variable) > 0)

  if (ready) {
    # read dataset
    dataset <- jasp_estimate_mdiff_one_read_data(dataset, options)


    # check for errors
    for (variable in options$outcome_variable) {
      .hasErrors(
        dataset = dataset,
        type = "observations",
        observations.target = variable,
        observations.amount  = "< 3",
        exitAnalysisIfErrors = TRUE
      )

    }

    # Run the analysis
    my_reference_mean <- 0
    if (options$hypothesis_evaluation) my_reference_mean <- options$reference_mean

    estimate <- esci::estimate_mdiff_one(
      data = dataset,
      outcome_variable = encodeColNames(options$outcome_variable),
      reference_mean = my_reference_mean,
      conf_level = options$conf_level,
      save_raw_data = TRUE
    )

    # Some results tweaks - future updates to esci will do these calcs within esci rather than here
    alpha <- 1 - as.numeric(options$conf_level)
    estimate$overview$t_multiplier <- stats::qt(1-alpha/2, estimate$overview$df)
    estimate$overview$s_component <- estimate$overview$sd
    estimate$overview$n_component <- 1/sqrt(estimate$overview$n)
    estimate$overview$moe <- (estimate$overview$mean_UL - estimate$overview$mean_LL)/2


    # Define and fill the overview table
    if (is.null(jaspResults[["overviewTable"]])) {
      jasp_overview_prep(jaspResults, options, ready)
      jasp_table_fill(jaspResults[["overviewTable"]], estimate$overview)
    }


    # Hypothesis evaluation
    hypothesis_evaluation <- options$hypothesis_evaluation
    interval_null <- options$rope > 0

    if (hypothesis_evaluation) {
      # Define and fill the smd table
      # Two additional calculation tweaks that esci will soon handle on its own
      estimate$es_smd$reference_value <- options$reference_mean
      estimate$es_smd$mean <- estimate$es_smd$numerator + options$reference_mean

      if (options$effect_size == "mean" & is.null(jaspResults[["smdTable"]]) ) {
        jasp_smd_prep(jaspResults, options, ready)
        jasp_table_fill(jaspResults[["smdTable"]], estimate$es_smd)
      } else {
        jaspResults[["smdTable"]] <- NULL
      }

      my_rope <- c(-1 * options$rope, options$rope)

      test_results <- esci::test_mdiff(
        estimate,
        effect_size = options$effect_size,
        rope = my_rope,
        rope_units = "raw",
        output_html = TRUE
      )

      # Define and fill the hypothesis evaluation table
      if (is.null(jaspResults[["heTable"]]) ) {
        if (options$rope == 0) {
          jasp_he_point_prep(jaspResults, options, ready)
        } else {
          jasp_he_interval_prep(jaspResults, options, ready)
        }

        to_fill <- test_results$point_null
        if (options$rope >0) to_fill <- test_results$interval_null

        jasp_table_fill(jaspResults[["heTable"]], to_fill)
      }
    } else {

      # No Hypothesis eval, clear tables
      jaspResults[["smdTable"]] <- NULL
      jaspResults[["heTable"]] <- NULL

    } # end of hypothesis evalu


    # Now prep and fill the plot
    if (is.null(jaspResults[["mdiffPlot"]])) {
      jasp_plot_magnitude_prep(jaspResults, options)

      args <- list()
      args$estimate <- estimate
      args$effect_size <- options$effect_size
      args$data_layout <- options$data_layout
      args$data_spread <- options$data_spread
      args$error_layout <- options$error_layout
      args$error_scale <- options$error_scale
      args$error_nudge <- options$error_nudge
      if (hypothesis_evaluation) {
        args$rope <- c(
          options$reference_mean - options$rope,
          options$reference_mean + options$rope
        )
      }

      myplot <- do.call(
        what = esci::plot_magnitude,
        args = args
      )

      myplot <- jasp_plot_magnitude_decorate(myplot, options)

      jaspResults[["mdiffPlot"]]$plotObject <- myplot


    }


  }  # end of ready

  return()
}



jasp_estimate_mdiff_one_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(.readDataSetToEnd(columns.as.numeric = options$outcome_variable))
}


# Prep a magnitude plot
jasp_plot_magnitude_prep <- function(jaspResults, options) {

  mdiffPlot <- createJaspPlot(
    title = "Estimation Figure",
    width = options$width,
    height = options$height
  )

  mdiffPlot$dependOn(
    c(
      "outcome_variable",
      "conf_level",
      "effect_size",
      "reference_mean",
      "rope",
      "hypothesis_evaluation",
      "width",
      "height",
      "data_layout",
      "data_spread",
      "error_layout",
      "error_scale",
      "error_nudge",
      "ylab",
      "xlab",
      "axis.text.y",
      "axis.title.y",
      "axis.text.x",
      "axis.title.x",
      "ymin",
      "ymax",
      "n.breaks",
      "shape_summary",
      "size_summary",
      "color_summary",
      "fill_summary",
      "alpha_summary",
      "linetype_summary",
      "size_interval",
      "color_interval",
      "alpha_interval",
      "fill_error",
      "alpha_error",
      "shape_raw",
      "size_raw",
      "color_raw",
      "fill_raw",
      "alpha_raw",
      "null_color"
    )
  )

  jaspResults[["mdiffPlot"]] <- mdiffPlot

  return()

}


# Apply all plot customizations
jasp_plot_magnitude_decorate <- function(myplot, options) {

  # Divider used for CI linewidth
  divider <- 1
  if (options$effect_size == "median") divider <- 4

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

  limits <- c(NA, NA)

  if (!(options$ymin %in% c("auto", "Auto", "AUTO", ""))) {
    try(limits[[1]] <- as.numeric(options$ymin))
  }

  if (!(options$ymax %in% c("auto", "Auto", "AUTO", ""))) {
    try(limits[[2]] <- as.numeric(options$ymax))
  }

  n.breaks <- NULL
  if (!(options$n.breaks %in% c("auto", "Auto", "AUTO", ""))) {
    try(n.breaks <- as.numeric(options$n.breaks))
    if (is.na(n.breaks)) n.breaks <- NULL
  }


  myplot <- myplot + ggplot2::scale_y_continuous(
    limits = limits,
    n.breaks = n.breaks
  )


  # Aesthetics -------------------

  # Raw and summary marker - Shape
  myplot <- myplot + ggplot2::scale_shape_manual(
    values = c(
      "raw" = options$shape_raw,
      "summary" = options$shape_summary
    )
  )

  # Raw and summary marker - Outline
  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "raw" = options$color_raw,
      "summary" = options$color_summary
    ),
    aesthetics = c("color", "point_color")
  )

  # Raw and summary marker - Fill
  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "raw" = options$fill_raw,
      "summary" = options$fill_summary
    ),
    aesthetics = c("fill", "point_fill")
  )

  # Raw and summary marker - Size
  myplot <- myplot + ggplot2::discrete_scale(
    c("size", "point_size"),
    "point_size_d",
    function(n) return(c(
      "raw" = as.numeric(options$size_raw),
      "summary" = as.numeric(options$size_summary)/divider
    ))
  )

  # Raw and summary marker - Alpha
  myplot <- myplot + ggplot2::discrete_scale(
    c("alpha", "point_alpha"),
    "point_alpha_d",
    function(n) return(c(
      "raw" = 1 - options$alpha_raw,
      "summary" = 1 - options$alpha_summary
    ))
  )

  # CI - linetype
  myplot <- myplot + ggplot2::scale_linetype_manual(
    values = c(
      "summary" = options$linetype_summary
    )
  )

  # CI - color
  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "summary" = options$color_interval
    ),
    aesthetics = "interval_color"
  )

  # CI - alpha
  myplot <- myplot + ggplot2::discrete_scale(
    "interval_alpha",
    "interval_alpha_d",
    function(n) return(c(
      "summary" = 1 - options$alpha_interval
    ))
  )

  # CI - line thickness
  myplot <- myplot + ggplot2::discrete_scale(
    "interval_size",
    "interval_size_d",
    function(n) return(c(
      "summary" = as.numeric(options$size_interval)/divider
    ))
  )

  # Error distribution fill
  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "summary" = options$fill_error
    ),
    aesthetics = "slab_fill"
  )

  # Error distribution alpha
  myplot <- myplot + ggplot2::discrete_scale(
    "slab_alpha",
    "slab_alpha_d",
    function(n) return(c(
      "summary" = 1 - options$alpha_error
    ))
  )

  # Hypothesis evaluation aesthetics
  hypothesis_evaluation <- options$hypothesis_evaluation
  interval_null <- options$rope > 0

  if (hypothesis_evaluation ) {
    # Null line color
    myplot$layers[["null_line"]]$aes_params$colour <- options$null_color

    if (interval_null) {
      try(myplot$layers[["null_interval"]]$aes_params$fill <- options$null_color)
      try(myplot$layers[["ta_CI"]]$aes_params$size <- as.numeric(options$size_interval)/divider+1)
      try(myplot$layers[["ta_CI"]]$aes_params$alpha <- as.numeric(options$alpha_interval))
      try(myplot$layers[["ta_CI"]]$aes_params$colour <- options$color_interval)
      try(myplot$layers[["ta_CI"]]$aes_params$linetype <- options$linetype_summary)

      if (options$effect_size == "median") {
        try(myplot$layers[["ta_CI"]]$aes_params$colour <- options$color_summary)
        try(myplot$layers[["ta_CI"]]$aes_params$size <- as.numeric(options$size_summary)/divider*2)
        try(myplot$layers[["ta_CI"]]$aes_params$alpha <- as.numeric(options$alpha_summary))
        try(myplot$layers[["ta_CI"]]$aes_params$linetype <- options$linetype_summary)
      }

    }
  }



  return(myplot)
}


