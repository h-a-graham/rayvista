download_overlay <- function(bounds_sf, zoomlevel, cache_dir, image_provider,
                             api_key, dem, overlay_alpha){

  # get bounds and define cache naming
  bounds <- sf::st_bbox(bounds_sf)

  # define cache names.
  over_cache <- file.path(cache_dir, paste0('overlay', bounds[1], '_',
                                            bounds[2], '_', bounds[3],'_',
                                            bounds[4], '_' , zoomlevel, '_',
                                            image_provider,'_',
                                            '.png'))

  bbox_cache <- file.path(cache_dir, paste0('bbox', bounds[1], '_',
                                            bounds[2], '_', bounds[3],'_',
                                            bounds[4], '_' , zoomlevel, '_',
                                            image_provider,'_',
                                            '.rds'))

  # check cache filename and if it doesn't exist download data then save.
  if (file.exists(over_cache) && file.exists(bbox_cache)) {
    message('Retrieving cached overlay data...')

    overlay_img <- png::readPNG(over_cache)

    new_bbox <- readRDS(bbox_cache)
  } else {
    message('Downloading overlay...')
    # dowload tiles and compose raster (SpatRaster)
    # Now with repeat attempts built in - up to 5.
    retrieve_tiles <- function(){
      suppressWarnings(
        if (is.null(api_key)){
        maptiles::get_tiles(x = bounds_sf, provider = image_provider,
                                             crop = TRUE, cachedir = cache_dir,
                                             verbose = F, zoom=zoomlevel)
      } else {
        maptiles::get_tiles(x = bounds_sf, provider = image_provider,
                            crop = TRUE, cachedir = cache_dir,
                            verbose = F, zoom=zoomlevel, apikey = api_key)
      })

    }

    rate <- purrr::rate_backoff(max_times = 5)
    repeat_tile_download <- purrr::insistently(retrieve_tiles, rate, quiet=F)

    nc_esri <- repeat_tile_download()

    if (!is.null(dem)){
      nc_esri <- terra::crop(nc_esri, dem)
    }

    # get bounds in EPSG::3857
    new_bbox <- sf::st_bbox(c(xmin=as.numeric(terra::ext(nc_esri)[1]),
                              ymin=as.numeric(terra::ext(nc_esri)[3]),
                              xmax=as.numeric(terra::ext(nc_esri)[2]),
                              ymax=as.numeric(terra::ext(nc_esri)[4]))) %>%
      sf::st_as_sfc() %>%
      sf::st_sf(crs=terra::crs(nc_esri))

    saveRDS(new_bbox, file=bbox_cache)

    #export the raster overlay as image and read it back.
    suppressWarnings(terra::writeRaster(nc_esri, over_cache, verbose=F))
    overlay_img <- png::readPNG(over_cache) %>%
      scales::rescale(.,to=c(0,1))

  }

  if (overlay_alpha!=1){
    overlay_img[,,4] <- as.integer(overlay_img[,,4]) * overlay_alpha
  }

  return(list(overlay=overlay_img, new_bounds=new_bbox))
}
