# fill data gaps:
fill_raster_holes <- function(ras, width = 9) {

  fill.na <- function(x) {
    center = 0.5 + (width*width/2)
    if( is.na(x)[center] ) {
      return( round(mean(x, na.rm=TRUE),0) )
    } else {
      return( round(x[center],0) )
    }
  }

  while (length(ras[is.na(ras)]) != 0) {
    ras <- raster::focal(ras, w = matrix(1,width,width), fun = fill.na,
                      pad = TRUE, na.rm = FALSE, NAonly=T)
    # message(length(ras[is.na(ras)]))
  }
  return(ras)
}
