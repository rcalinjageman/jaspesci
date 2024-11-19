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

    mytest$interval_null$rope_compare <- gsub("H_0", "<i>H</i><sub>0</sub>", mytest$interval_null$rope_compare)
    mytest$point_null$CI_compare <- gsub("H_0", "<i>H</i><sub>0</sub>", mytest$point_null$CI_compare)
    mytest$point_null$null_decision <- gsub("H_0", "<i>H</i><sub>0</sub>", mytest$point_null$null_decision)
    mytest$point_null$conclusion <- gsub("_diff", "<sub>diff</sub>", mytest$point_null$conclusion)
    mytest$interval_null$conclusion <- gsub("_diff", "<sub>diff</sub>", mytest$interval_null$conclusion)


    if (rope_upper > 0) {
      mytest$to_fill <- mytest$interval_null
    } else {
      mytest$to_fill <- mytest$point_null
    }

    return(mytest)

}


jasp_plot_depend_on <- function() {
  mytypes <- c("shape", "size", "color", "fill", "alpha", "linetype")
  myobjs <- c("summary", "raw", "interval", "error")
  mycontrast <- c("reference", "comparison", "difference", "unused")

  mydepends <- apply(expand.grid(mytypes, myobjs, mycontrast), 1, paste, collapse="_")

  return(mydepends)
}


jasp_plot_m_prep <- function(jaspResults, options, ready, my_variable = "mdiffPlot", add_citation = FALSE, my_title = NULL) {

  if (is.null(my_title)) {
    my_title <- if (my_variable == "mdiffPlot") "Estimation Figure" else paste("Estimation Figure", my_variable, sep = " - ")
    if (my_variable == "scatterPlot") my_title <- "Scatterplot"
  }

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


# This helper function checks if a contrast is valid
jamovi_check_contrast <- function(
    labels,
    valid_levels,
    level_source,
    group_type,
    error_string = NULL,
    sequential = FALSE
) {

  run_analysis <- TRUE

  if(nchar(labels)>=1 & labels != ' ') {
    # Verify list of reference groups
    # Split by comma, then trim ws while also
    #  reducing the list returned by split to a vector
    refgs <- strsplit(
      as.character(labels), ","
    )
    refgs <- trimws(refgs[[1]], which = "both")


    # Now cycle through each item in the list to check it
    #   is a valid factor within the grouping variable

    for (tlevel in refgs) {
      if (!tlevel %in% valid_levels) {
        error_string <- paste(error_string, glue::glue(
          "<b>{group_type} error</b>:
The group {tlevel} does not exist in {level_source}.
Group labels in {level_source} are: {paste(valid_levels, collapse = ', ')}.
Use commas to separate labels.
"
        )
        )
        return(list(
          labels = NULL,
          run_analysis = FALSE,
          error_string = error_string
        )
        )
      }
    }
  } else {
    if (sequential) {
      error_string <- paste(error_string, glue::glue(
        "
<b>{group_type} subset</b>:
Do the same for this subset.  No group can belong to both subsets.
"
      ))
    } else {
      error_string <- paste(error_string, glue::glue(
        "
<b>{group_type} subset</b>:
Type one or more group labels, separated by commas,
to form the {group_type} subset.
Group labels in {level_source} are: {paste(valid_levels, collapse = ', ')}.
"
      ))
    }
    return(list(
      label = NULL,
      run_analysis = FALSE,
      error_string = error_string
    )
    )
  }


  return(list(
    label = refgs,
    run_analysis = TRUE,
    error_string = error_string
  )
  )
}




jamovi_create_contrast <- function(reference, comparison) {
  ref_n <- length(reference)
  comp_n <- length(comparison)
  ref_vector <- rep(-1/ref_n, times = ref_n)
  comp_vector <- rep(1/comp_n, times = comp_n)
  contrast <- c(ref_vector, comp_vector)
  names(contrast) <- c(reference, comparison)
  return(contrast)
}

