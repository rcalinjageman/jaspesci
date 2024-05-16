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
      "from_raw"
    )
  )
}

# Prep an meta analysis raw_data table
jasp_meta_raw_data_prep <- function(jaspResults, options, ready, levels = 1, effect_size_title = "<i>M</i>") {
  overviewTable <- createJaspTable(title = "Table of Studies")

  from_raw <- options$switch == "from_raw"
  has_moderator <- options$moderator != ""

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


  # e_title <- "<i>M</i>"
  # if (from_raw & options$reported_effect_size != "mean_difference") e_title <- "<i>d</i><sub>1</sub>"
  # if (!from_raw)  e_title <- "<i>d</i><sub>1</sub>"

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = effect_size_title,
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
        name = "weight",
        title = w_title,
        type = "number"
      )

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

      if(from_raw & options$reported_effect_size != "mean difference") {
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
      }

  }


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(levels)

  jaspResults[["meta_raw_dataTable"]] <- overviewTable


  return()

}


jasp_es_meta_data_prep <- function(jaspResults, options, ready, levels = 1, effect_size_title = "<i>M</i>") {
  overviewTable <- createJaspTable(title = "Meta-Analytic Effect Sizes")

  from_raw <- options$switch == "from_raw"
  has_moderator <- options$moderator != ""

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


  # effect_size_title <- "<i>M</i>"
  # if (from_raw & options$reported_effect_size != "mean_difference") e_title <- "<i>d</i><sub>1</sub>"
  # if (!from_raw)  e_title <- "<i>d</i><sub>1</sub>"

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = effect_size_title,
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

  if (ready)
    overviewTable$setExpectedSize(levels)

  jaspResults[["es_metaTable"]] <- overviewTable


  return()

}




jasp_es_heterogeneity_data_prep <- function(jaspResults, options, ready, levels = 0) {
  overviewTable <- createJaspTable(title = "Effect Size Heterogeneity")

  from_raw <- options$switch == "from_raw"
  has_moderator <- options$moderator != ""

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
    # overviewTable$addColumnInfo(
    #   name = "moderator_variable_name",
    #   title = "Moderator",
    #   type = "string",
    #   combine = TRUE
    # )

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

  if (ready)
    overviewTable$setExpectedSize(5 * (levels + 1))

  jaspResults[["es_heterogeneityTable"]] <- overviewTable


  return()

}




jasp_es_meta_difference_prep <- function(jaspResults, options, ready, levels = 3, effect_size_title = "<i>M</i>") {
  overviewTable <- createJaspTable(title = "Moderator Analysis")

  from_raw <- options$switch == "from_raw"
  has_moderator <- options$moderator != ""

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

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = effect_size_title,
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
    overviewTable$setExpectedSize(levels)

  jaspResults[["es_meta_differenceTable"]] <- overviewTable


  return()

}
