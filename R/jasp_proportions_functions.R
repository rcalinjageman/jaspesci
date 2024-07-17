jasp_test_pdiff <- function(options, estimate) {
  self <- list()
  self$options <- options

  evaluate_h <- self$options$evaluate_hypotheses

    # Test results
    rope_upper <- self$options$null_boundary

    mytest <- esci::test_pdiff(
      estimate,
      rope = c(rope_upper * -1, rope_upper),
      output_html = TRUE
    )


    if (rope_upper > 0) {
      mytest$to_fill <- jasp_peffect_html(mytest$interval_null)
    } else {
      mytest$to_fill <- jasp_peffect_html(mytest$point_null)
    }

  return(mytest)

}



jasp_peffect_html <- function(tfix) {

  if (is.null(tfix)) return(NULL)
  if (nrow(tfix) == 0) return(tfix)

  tfix$case_label <- gsub("P_", "<i>P</i><sub>", tfix$case_label)

  tfix$effect_plus <- paste(
    tfix$case_label,
    "</sub>: ",
    tfix$effect,
    sep = ""
  )

  return(tfix)

}




