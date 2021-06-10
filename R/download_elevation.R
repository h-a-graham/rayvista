download_elevation <- function(bounds_sf, z, dem_src, cache_dir, outlier_filter,
                               fill_holes){
  # get bounds and define cache naming
  bounds <- sf::st_bbox(bounds_sf)

  cachepath <- file.path(cache_dir, paste0('elevation', bounds[1], '_',
                                           bounds[2], '_', bounds[3],
                                        '_', bounds[4], '_' , z, '_',
                                        outlier_filter, '_', dem_src, '.rds'))

  # check cache filename and if it doesn't exist download data then save.
  if (file.exists(cachepath)) {
    message('Retrieving cached data...')
    ras <- readRDS(cachepath)
  } else {

    # download function - insistently request up to 5 times.
    retrieve_dem <- function(){
      elevatr::get_elev_raster(bounds_sf, z=z, clip='bbox',
                               neg_to_na = TRUE, verbose = F, src=dem_src)
    }
    rate <- purrr::rate_backoff(max_times = 5)
    repeat_dem_download <- purrr::insistently(retrieve_dem, rate, quiet=T)
    ras <-repeat_dem_download()

    # fill holes in DEMS
    if (isTRUE(fill_holes)){
      if (length(ras[is.na(ras)])>0) {
        message('Filling NA raster values... If this is very slow use `fill_holes=FALSE`')
        ras <- fill_raster_holes(ras)
      }
    }

    # remove outliers if requested.S
    if (!is.null(outlier_filter)){
      thresh <- raster::quantile(ras, probs = outlier_filter, type=7,names = FALSE)
      ras[ras<thresh] <- NA
    }
    saveRDS(ras, file = cachepath)
  }

  return(ras)
}
