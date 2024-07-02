jasp_meta_table_depends_on <- function() {
  return(
    c(
      "means",
      "sds",
      "ns",
      "labels",
      "moderator",
      "ds",
      "conf_level",
      "effect_label",
      "reference_mean",
      "reported_effect_size",
      "show_details",
      "random_effects",
      "include_PIs",
      "switch",
      "from_raw",
      "reference_means",
      "reference_sds",
      "reference_ns",
      "comparison_means",
      "comparison_sds",
      "comparison_ns",
      "assume_equal_variance"
    )
  )
}

# Prep an meta analysis raw_data table
jasp_meta_raw_data_prep <- function(jaspResults, options, ready, estimate = NULL, effect_size = "mean") {
  from_raw <- FALSE
  if (!is.null(options$switch)) {
    from_raw <- options$switch == "from_raw"
  }

  reported_effect_size <- ""
  if (!is.null(options$reported_effect_size)) {
      reported_effect_size <- options$reported_effect_size
  }

  has_moderator <- options$moderator != ""
  has_estimate <- !is.null(estimate)


  overviewTable <- createJaspTable(title = "Table of Studies")


  overviewTable$dependOn(
    jasp_meta_table_depends_on()
  )


  overviewTable$addColumnInfo(
    name = "label",
    title = "Study label",
    type = "string"
  )

  if (has_moderator) {
    overviewTable$addColumnInfo(
      name = "moderator",
      title = "Moderator level",
      type = "string"
    )
  }

  e_title <- if (has_estimate) estimate$properties$effect_size_name_html else "Effect size"

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = e_title,
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "LL",
    title = "LL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )
  overviewTable$addColumnInfo(
    name = "UL",
    title = "UL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )

  if (effect_size == "r") {
    overviewTable$addColumnInfo(
      name = "N",
      title = "<i>N</i>",
      type = "integer"
    )

  }

  if (options$show_details) {
      w_title <- if (options$random_effects == "fixed_effects") "FE weight" else "RE weight"

      overviewTable$addColumnInfo(
        name = "weight",
        title = w_title,
        type = "number"
      )

  } # end show details for all effect sizes


  if (options$show_details & effect_size == "r") {
    overviewTable$addColumnInfo(
      name = "z",
      title = "<i>Z</i><sub><i>r</i></sub>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE</i><sub><i>Z</i></sub>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "sample_variance",
      title = "<i>SE</i><sup>2</sup><sub><i>Z</i></sub>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "t",
      title = "<i>t</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "df",
      title = "<i>df</i>",
      type = "integer"
    )

    overviewTable$addColumnInfo(
      name = "p",
      title = "<i>p</i>, two tailed",
      type = "pvalue"
    )

  }  # end show details for r


  if (options$show_details & effect_size %in% c("mdiff", "mean")) {
    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "sample_variance",
      title = "<i>SE</i><sup>2</sup>",
      type = "number"
    )

  }  # end show details common to mdiff and mean


  if (options$show_details & from_raw & reported_effect_size != "mean difference" & effect_size == "mean") {
          overviewTable$addColumnInfo(
            name = "mean",
            title = "<i>M</i>",
            type = "number"
          )

          overviewTable$addColumnInfo(
            name = "sd",
            title = "<i>s</i>",
            type = "number"
          )

          overviewTable$addColumnInfo(
            name = "n",
            title = "<i>N</i>",
            type = "integer"
          )

          overviewTable$addColumnInfo(
            name = "p",
            title = "<i>p</i>, two tailed",
            type = "pvalue"
          )
   } # end show details for mean when from raw and d reported

   if (options$show_details & effect_size == "mdiff") {
          if (from_raw) {
            overviewTable$addColumnInfo(
              name = "reference_mean",
              title = "<i>M</i><sub>reference</sub>",
              type = "number"
            )

            overviewTable$addColumnInfo(
              name = "reference_sd",
              title = "<i>s</i><sub>reference</sub>",
              type = "number"
            )

          }

          overviewTable$addColumnInfo(
            name = "reference_n",
            title = "<i>n</i><sub>reference</sub>",
            type = "integer"
          )

          if (from_raw) {
            overviewTable$addColumnInfo(
              name = "comparison_mean",
              title = "<i>M</i><sub>comparison</sub>",
              type = "number"
            )

            overviewTable$addColumnInfo(
              name = "comparison_sd",
              title = "<i>s</i><sub>comparison</sub>",
              type = "number"
            )

          }

          overviewTable$addColumnInfo(
            name = "comparison_n",
            title = "<i>n</i><sub>comparison</sub>",
            type = "integer"
          )


          overviewTable$addColumnInfo(
            name = "r",
            title = "<i>r</i>",
            type = "number"
          )

          overviewTable$addColumnInfo(
            name = "df",
            title = "<i>df</i>",
            type = "integer"
          )

          overviewTable$addColumnInfo(
            name = "p",
            title = "<i>p</i>, two tailed",
            type = "pvalue"
          )

  }  # end show details for mdiff



  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready & has_estimate)
    overviewTable$setExpectedSize(nrow(estimate$raw_data))

  jaspResults[["meta_raw_dataTable"]] <- overviewTable

  return()

}


jasp_es_meta_data_prep <- function(jaspResults, options, ready, estimate = NULL) {

  from_raw <- options$switch == "from_raw"
  has_moderator <- options$moderator != ""
  has_estimate <- !is.null(estimate)


  overviewTable <- createJaspTable(title = "Meta-Analytic Effect Sizes")

  overviewTable$dependOn(
    jasp_meta_table_depends_on()
  )


  overviewTable$addColumnInfo(
    name = "effect_label",
    title = "Effect",
    type = "string",
    combine = TRUE
  )

  if (has_moderator) {
    overviewTable$addColumnInfo(
      name = "moderator_variable_name",
      title = "Moderator",
      type = "string",
      combine = TRUE
    )

    overviewTable$addColumnInfo(
      name = "moderator_variable_level",
      title = paste(options$moderator, "Level"),
      type = "string"
    )

  }


  e_title <- if (has_estimate) estimate$properties$effect_size_name_html else "Effect size"

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = e_title,
    type = "number"
  )


  overviewTable$addColumnInfo(
    name = "LL",
    title = "LL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )
  overviewTable$addColumnInfo(
    name = "UL",
    title = "UL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )

  if (options$show_details) {
    w_title <- if (options$random_effects == "fixed_effects") "FE weight" else "RE weight"

    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE</i>",
      type = "number"
    )

  }

  overviewTable$addColumnInfo(
    name = "k",
    title = "<i>k</i>",
    type = "integer"
  )

  if (options$include_PIs & options$random_effects == "random_effects") {
    overviewTable$addColumnInfo(
      name = "PI_LL",
      title = "LL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% PI")
    )
    overviewTable$addColumnInfo(
      name = "PI_UL",
      title = "UL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% PI")
    )
  }

  if (options$show_details) {
    overviewTable$addColumnInfo(
      name = "p",
      title = "<i>p</i>, two tailed",
      type = "pvalue"
    )
  }

  if (options$random_effects == "compare" | options$show_details) {
      overviewTable$addColumnInfo(
        name = "FE_CI_width",
        title = "FE CI length",
        type = "number"
      )

      overviewTable$addColumnInfo(
        name = "RE_CI_width",
        title = "RE CI length",
        type = "number"
      )


  }


  if (options$random_effects == "compare") {
    overviewTable$addColumnInfo(
      name = "FE_effect_size",
      title = "FE effect size",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "RE_effect_size",
      title = "RE effect size",
      type = "number"
    )


  }


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready & has_estimate)
    overviewTable$setExpectedSize(nrow(estimate$es_meta))

  jaspResults[["es_metaTable"]] <- overviewTable


  return()

}


jasp_es_heterogeneity_data_prep <- function(jaspResults, options, ready, levels = 1) {

  from_raw <- options$switch == "from_raw"
  has_moderator <- options$moderator != ""


  overviewTable <- createJaspTable(title = "Effect Size Heterogeneity")


  overviewTable$dependOn(
    jasp_meta_table_depends_on()
  )


  overviewTable$addColumnInfo(
    name = "measure",
    title = "Measure",
    type = "string",
    combine = TRUE
  )

  if (has_moderator) {
      overviewTable$addColumnInfo(
      name = "moderator_level",
      title = paste(options$moderator, "Level"),
      type = "string",
      combine = TRUE
    )

  }

  overviewTable$addColumnInfo(
    name = "estimate",
    title = "Estimate",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "LL",
    title = "LL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )
  overviewTable$addColumnInfo(
    name = "UL",
    title = "UL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )

  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready) overviewTable$setExpectedSize(levels)

  jaspResults[["es_heterogeneityTable"]] <- overviewTable


  return()

}


jasp_es_meta_difference_prep <- function(jaspResults, options, ready, estimate) {

  from_raw <- options$switch == "from_raw"
  has_moderator <- options$moderator != ""
  has_estimate <- !is.null(estimate)


  overviewTable <- createJaspTable(title = "Moderator Analysis")

  overviewTable$dependOn(
    jasp_meta_table_depends_on()
  )


  overviewTable$addColumnInfo(
    name = "effect_label",
    title = "Effect",
    type = "string",
    combine = TRUE
  )

  if (has_moderator) {
    overviewTable$addColumnInfo(
      name = "moderator_variable_name",
      title = "Moderator",
      type = "string",
      combine = TRUE
    )

    overviewTable$addColumnInfo(
      name = "moderator_level",
      title = "Level",
      type = "string"
    )

  }


  e_title <- if (has_estimate) estimate$properties$effect_size_name_html else "Effect size"

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = e_title,
    type = "number"
  )


  overviewTable$addColumnInfo(
    name = "LL",
    title = "LL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )
  overviewTable$addColumnInfo(
    name = "UL",
    title = "UL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )

  if (options$show_details) {
    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "p",
      title = "<i>p</i>, two tailed",
      type = "pvalue"
    )


  }


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(nrow(estimate$es_meta_difference))

  jaspResults[["es_meta_differenceTable"]] <- overviewTable


  return()

}
