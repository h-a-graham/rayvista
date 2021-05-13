calling_dr_ray <- function(overlay, elevation, z_sale, epsg, ...){

  elmat = rayshader::raster_to_matrix(elevation)

  # NOTE WILL NEE TO INCLUDE ARGS TO ESTIMATE Z SCALE AND ALLOW CUTOMS ADJUSTMENT...
  rayshader::plot_3d(overlay, elmat, zscale=z_sale, ...)

  Sys.sleep(0.2)

  #transform raster to get preferred extent coords.
  if (epsg!=3857){
    transRas <- raster::projectRaster(elevation, crs=sf::st_crs(epsg)$wkt)
    attr(elmat, "extent") = raster::extent(transRas)
  } else {
    attr(elmat, "extent") = raster::extent(elevation)
  }

  attr(elmat, "crs") = sf::st_crs(epsg)$wkt
  attr(elmat, "resolution") = raster::xres(elevation)

  return(elmat)
}
