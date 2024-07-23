jasp_test_mdiff <- function(options, estimate) {

    # Test results
    effect_size = options$effect_size
    if (effect_size == "mean_difference") effect_size <- "mean"
    if (effect_size == "median_difference") effect_size <- "median"

    rope_upper <- options$null_boundary

    rope_units <- "raw"
    try(rope_units <- options$rope_units, silent = TRUE)

    mytest <- esci::test_mdiff(
      estimate,
      effect_size = effect_size,
      rope = c(rope_upper * -1, rope_upper),
      rope_units = rope_units,
      output_html = FALSE
    )


    if (rope_upper > 0) {
      mytest$to_fill <- mytest$interval_null
    } else {
      mytest$to_fill <- mytest$point_null
    }

    return(mytest)

}



jasp_plot_m_prep <- function(jaspResults, options, ready, my_variable = "mdiffPlot", add_citation = FALSE) {

  my_title <- if (my_variable == "mdiffPlot") "Estimation Figure" else paste("Estimation Figure", my_variable, sep = " - ")
  if (my_variable == "scatterPlot") my_title <- "Scatterplot"

  mdiffPlot <- createJaspPlot(
    title = my_title,
    width = options$width,
    height = options$height
  )

  mytypes <- c("shape", "size", "color", "fill", "alpha", "linetype")
  myobjs <- c("summary", "raw", "interval", "error")
  mycontrast <- c("reference", "comparison", "difference", "unused")

  mydepends <- apply(expand.grid(mytypes, myobjs, mycontrast), 1, paste, collapse="_")

  mdiffPlot$dependOn(
    c(
      jasp_mdiff_table_depends_on(),
      "null_value",
      "null_boundary",
      "null_color",
      "rope_units",
      "evaluate_hypotheses",
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
      "simple_contrast_labels",
      "ymin",
      "ymax",
      "ybreaks",
      "n.breaks",
      "difference_axis_units",
      "difference_axis_breaks",
      mydepends,
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
      jasp_pdiff_table_depends_on()
    )
  )

  if (add_citation) {
    mdiffPlot$addCitation(
      "Kay, M. (2002). ggdist: Visualizations of Distributions and Uncertainty in the Grammar of Graphics. IEEE Transactions on Visualization and Computer Graphics. 30, 414-424, https://zenodo.org/records/7933524."
    )

  }

  jaspResults[[my_variable]] <- mdiffPlot

  return()

}
