jasp_test_mdiff <- function(jaspResults, options, ready, estimate) {

    # Test results
    effect_size = options$effect_size
    if (effect_size == "mean_difference") effect_size <- "mean"
    if (effect_size == "median_difference") effect_size <- "median"

    rope_upper <- options$null_boundary

    rope_units <- "raw"
    try(rope_units <- options$rope_units, silent = TRUE)

    test_results <- esci::test_mdiff(
      estimate,
      effect_size = effect_size,
      rope = c(rope_upper * -1, rope_upper),
      rope_units = rope_units,
      output_html = FALSE
    )


    jasp_he_prep(jaspResults, options, ready)

    to_fill <- test_results$point_null
    if (rope_upper > 0) to_fill <- test_results$interval_null

    jasp_table_fill(jaspResults[["heTable"]], to_fill)

    return()

}



jasp_plot_m_prep <- function(jaspResults, options) {

  mdiffPlot <- createJaspPlot(
    title = "Estimation Figure",
    width = options$width,
    height = options$height
  )

  mytypes <- c("shape", "size", "color", "fill", "alpha", "linetype")
  myobjs <- c("summary", "raw", "interval", "error")
  mycontrast <- c("reference", "comparison", "difference", "unused")

  mydepends <- apply(expand.grid(mytypes, myobjs, mycontrast), 1, paste, collapse="_")

  mdiffPlot$dependOn(
    c(
      "outcome_variable",
      "grouping_variable",
      "conf_level",
      "assume_equal_variance",
      "effect_size",
      "switch_comparison_order",
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
      "null_color"
    )
  )

  jaspResults[["mdiffPlot"]] <- mdiffPlot

  return()

}
