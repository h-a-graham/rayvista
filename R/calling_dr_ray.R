calling_dr_ray <- function(overlay, elevation, z_sale, epsg, mt_provider, ...){

  elmat = rayshader::raster_to_matrix(elevation)

  # NOTE WILL NEE TO INCLUDE ARGS TO ESTIMATE Z SCALE AND ALLOW CUTOMS ADJUSTMENT...
  rayshader::plot_3d(overlay, elmat, zscale=z_sale, ...)

  Sys.sleep(0.2)

  #transform raster to get preferred extent coords.
  if (epsg!=3857){
    transRasEXT <- raster::projectExtent(elevation, crs=sf::st_crs(epsg)$wkt)
    attr(elmat, "extent") = raster::extent(transRasEXT)
    # attr(elmat, "resolution") = raster::xres(transRas)
  } else {
    attr(elmat, "extent") = raster::extent(elevation)
  }

  attr(elmat, "crs") = sf::st_crs(epsg)$wkt

  #approximate cell size
  ras_wgs <- raster::projectExtent(elevation, crs=sf::st_crs(4326)$wkt) %>%
    raster::extent()

  p1<-c(ras_wgs[1],ras_wgs[3])
  p2<-c(ras_wgs[1],ras_wgs[4])
  attr(elmat, "resolution") = geosphere::distGeo(p1, p2)/dim(elmat)[2]

  #get attribution for data
  attr(elmat, "attribution") = attribution(mt_provider)

  return(elmat)
}

