download_elevation <- function(bounds_sf, z, cache_dir){
  # get bounds and define cache naming
  bounds <- sf::st_bbox(bounds_sf)

  cachepath <- file.path(cache_dir, paste0('elevation', bounds[1], '_',
                                           bounds[2], '_', bounds[3],
                                        '_', bounds[4], '_' , z, '.rds'))

  # check cache filename and if it doesn't exist download data then save.
  if (file.exists(cachepath)) {
    message('Retrieving cached data...')
    ras <- readRDS(cachepath)
  } else {
    ras <- elevatr::get_elev_raster(bounds_sf, z=z, clip='bbox', neg_to_na = TRUE,
                                    verbose = F)
    saveRDS(ras, file = cachepath)
  }

  return(ras)
}
