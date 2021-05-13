download_elevation <- function(bounds_sf, z, cache_dir, outlier_filter){
  # get bounds and define cache naming
  bounds <- sf::st_bbox(bounds_sf)

  cachepath <- file.path(cache_dir, paste0('elevation', bounds[1], '_',
                                           bounds[2], '_', bounds[3],
                                        '_', bounds[4], '_' , z, '_',
                                        outlier_filter, '.rds'))

  # check cache filename and if it doesn't exist download data then save.
  if (file.exists(cachepath)) {
    message('Retrieving cached data...')
    ras <- readRDS(cachepath)
  } else {
    ras <- elevatr::get_elev_raster(bounds_sf, z=z, clip='bbox', neg_to_na = TRUE,
                                    verbose = F)

    # if (epsg!=3857){
    #   ras <- raster::projectRaster(ras, crs=sf::st_crs(epsg)$wkt)
    # }


    if (!is.null(outlier_filter)){
      thresh <- raster::quantile(ras, probs = outlier_filter, type=7,names = FALSE)
      ras[ras<thresh] <- NA
    }
    saveRDS(ras, file = cachepath)
  }

  return(ras)
}
