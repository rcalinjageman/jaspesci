jasp_describe <- function(jaspResults, dataset = NULL, options, ...) {


  ready <- if (options$outcome_variable != "") TRUE else FALSE

  # check for errors
  if (ready) {
    # read dataset
    dataset <- jasp_describe_read_data(dataset, options)

    for (variable in options$outcome_variable) {
      .hasErrors(
        dataset = dataset,
        type = "observations",
        observations.target = variable,
        observations.amount  = "< 3",
        exitAnalysisIfErrors = TRUE
      )

    }
  }

  # Run the analysis
  if (ready) {

    args <- list()
    args$data <- dataset
    args$outcome_variable <- options$outcome_variable

    call <- esci::estimate_magnitude

    estimate <- try(do.call(what = call, args = args))

    # Some results tweaks - future updates to esci will do these calcs within esci rather than here
    estimate$overview$moe <- (estimate$overview$mean_UL - estimate$overview$mean_LL)/2

  }


  # Overview
  if (is.null(jaspResults[["overviewTable"]])) {

    jasp_describe_prep(
      jaspResults,
      options,
      ready
    )

    if (ready) {
      jasp_table_fill(
        jaspResults[["overviewTable"]],
        estimate,
        "overview"
      )
    }
  }

  # Histogram and dotplot
  if (is.null(jaspResults[["histogram"]])) {
    jasp_histogram_create(jaspResults, options, ready, estimate, "histogram")

  }

  if (is.null(jaspResults[["dotplot"]])) {
    jasp_histogram_create(jaspResults, options, ready, estimate, "dotplot")

  }


  return()

}



jasp_describe_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(.readDataSetToEnd(columns.as.numeric = options$outcome_variable))
}




# Prep an overview table
jasp_describe_prep <- function(jaspResults, options, ready) {

  # Title
  overviewTable <- createJaspTable(title = "Overview")

  # Depends on
  overviewTable$dependOn(
    c("outcome_variable", "show_details")
  )

  # Columns
  overviewTable$addColumnInfo(
    name = "outcome_variable_name",
    title = "Outcome variable",
    type = "string",
    combine = TRUE
  )

    overviewTable$addColumnInfo(
      name = "mean",
      title = "<i>M</i>",
      type = "number"
    )

    if (options$show_details) {
      overviewTable$addColumnInfo(
        name = "mean_LL",
        title = "LL",
        type = "number",
        overtitle = paste0(100 * options$conf_level, "% CI")
      )
      overviewTable$addColumnInfo(
        name = "mean_UL",
        title = "UL",
        type = "number",
        overtitle = paste0(100 * options$conf_level, "% CI")
      )
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


      if (options$show_details) {
        overviewTable$addColumnInfo(
          name = "median_LL",
          title = "LL",
          type = "number",
          overtitle = paste0(100 * options$conf_level, "% CI")
        )
        overviewTable$addColumnInfo(
          name = "median_UL",
          title = "UL",
          type = "number",
          overtitle = paste0(100 * options$conf_level, "% CI")
        )

      }


  overviewTable$addColumnInfo(
    name = "sd",
    title = "<i>s</i>",
    type = "number"
  )

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

    mytype <- "integer"

    if (options$show_details) {
      overviewTable$addColumnInfo(
        name = "df",
        title = "<i>df</i>",
        type = mytype
      )
    }


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready) {
      overviewTable$setExpectedSize(1)
  }

  jaspResults[["overviewTable"]] <- overviewTable


  return()

}


#histogram or dotplot
jasp_histogram_create <- function(jaspResults, options, ready, estimate, plot_type = "histogram") {

  my_title <- if (plot_type == "histogram") "Histogram" else "Dotplot"

  h_multiplier <- if (plot_type == "histogram") 1 else 0.66

  scatterplot <- createJaspPlot(
    title = my_title,
    width = options$sp_plot_width,
    height = options$sp_plot_height * h_multiplier
  )

  scatterplot$dependOn(
    c(
      "outcome_variable",
      "show_details",
      "mark_mean",
      "mark_median",
      "mark_sd",
      "mark_quartiles",
      "mark_z_lines",
      "mark_percentile",
      "sp_ymin",
      "sp_ymax",
      "sp_xmin",
      "sp_xmax",
      "sp_ybreaks",
      "sp_xbreaks",
      "fill_regular",
      "fill_highlighted",
      "color",
      "marker_size",
      "histogram_bins",
      "sp_plot_width",
      "sp_plot_height",
      "sp_ylab",
      "sp_axis.text.y",
      "sp_axis.title.y",
      "sp_xlab",
      "sp_axis.text.x",
      "sp_axis.title.x"
    )
  )

  jaspResults[[plot_type]] <- scatterplot

  if (ready) {
    args <- list()
    args$estimate <- estimate
    args$type <- plot_type

    args$mark_mean <- options$mark_mean
    args$mark_median <- options$mark_median
    args$mark_sd <- options$mark_sd
    args$mark_quartiles <- options$mark_quartiles
    args$mark_z_lines <- options$mark_z_lines
    args$mark_percentile <- jasp_numeric_fix(options, "mark_percentile", 0)
    args$histogram_bins <- options$histogram_bins

    args$ylim <- c(
      jasp_numeric_fix(options, "sp_ymin", NA),
      jasp_numeric_fix(options, "sp_ymax", NA)
    )

    args$ybreaks <- jasp_numeric_fix(options, "sp_ybreaks", NULL)


    args$xlim <- c(
      jasp_numeric_fix(options, "sp_xmin", NA),
      jasp_numeric_fix(options, "sp_xmax", NA)
    )

    args$xbreaks <- jasp_numeric_fix(options, "sp_xbreaks", NULL)

    args$fill_regular <- options$fill_regular
    args$fill_highlighted <- options$fill_highlighted
    args$color <- options$color
    args$marker_size <- as.numeric(options$marker_size)


    if (plot_type == "dotplot") {
      args$type <- "histogram"
      hplot <- do.call(
        what = esci::plot_describe,
        args = args
      )
      args$type <- "dotplot"
      args$xlim <- ggplot2::ggplot_build(hplot)$layout$panel_params[[1]]$x.range
    }


    myplot <- do.call(
      what = esci::plot_describe,
      args = args
    )



    # Axis options
    if (!(options$sp_ylab %in% c("auto", "Auto", "AUTO", ""))) {
      myplot <- myplot + ggplot2::ylab(options$sp_ylab)
    }

    if (!(options$sp_xlab %in% c("auto", "Auto", "AUTO", ""))) {
      myplot <- myplot + ggplot2::xlab(options$sp_xlab)
    }

    myplot <- myplot + ggplot2::theme(
      axis.text.y = ggtext::element_markdown(size = options$sp_axis.text.y),
      axis.title.y = ggtext::element_markdown(size = options$sp_axis.title.y),
      axis.text.x = ggtext::element_markdown(size = options$sp_axis.text.x),
      axis.title.x = ggtext::element_markdown(size = options$sp_axis.title.x),
      legend.title = ggtext::element_markdown(),
      legend.text = ggtext::element_markdown()
    )

    jaspResults[[plot_type]]$plotObject <- myplot

  }  # end scatterplot creation
}
