
jasp_table_fill <- function(jaspTable, esciTable) {

  for (x in 1:nrow(esciTable)) {
    jaspTable$addRows(
      as.list(esciTable[x, ])
    )
  }

  return()
}
