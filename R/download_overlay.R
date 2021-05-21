download_overlay <- function(bounds_sf, zoomlevel, cache_dir, image_provider){
  # get bounds and define cache naming
  bounds <- sf::st_bbox(bounds_sf)

  over_cache <- file.path(cache_dir, paste0('overlay', bounds[1], '_',
                                            bounds[2], '_', bounds[3],'_',
                                            bounds[4], '_' , zoomlevel, '_',
                                            image_provider,'.png'))

  bbox_cache <- file.path(cache_dir, paste0('bbox', bounds[1], '_',
                                            bounds[2], '_', bounds[3],'_',
                                            bounds[4], '_' , zoomlevel, '_',
                                            image_provider, '.png'))

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
      maptiles::get_tiles(x = bounds_sf, provider = image_provider,
                          crop = TRUE, cachedir = cache_dir,
                          verbose = F, zoom=zoomlevel)
    }

    rate <- purrr::rate_backoff(max_times = 10)
    repeat_tile_download <- purrr::insistently(retrieve_tiles, rate, quiet=T)

    nc_esri <- repeat_tile_download()

    # get bounds in EPSG::3857
    new_bbox <- sf::st_bbox(c(xmin=terra::bbox(nc_esri)[1],
                              ymin=terra::bbox(nc_esri)[2],
                              xmax=terra::bbox(nc_esri)[3],
                              ymax=terra::bbox(nc_esri)[4])) %>%
      sf::st_as_sfc() %>%
      sf::st_sf(crs=terra::crs(nc_esri, proj4=T))

    saveRDS(new_bbox, file=bbox_cache)

    tile_dim <- dim(nc_esri)

    #export the raster overlay as image.
    png(over_cache, width = tile_dim[2], height = tile_dim[1])
    print({
      maptiles::plot_tiles(nc_esri)
    })
    dev.off()

    overlay_img <- png::readPNG(over_cache)
  }

  overlay_img <-scales::rescale(overlay_img,to=c(0,1))


  return(list(overlay=overlay_img, new_bounds=new_bbox))
}
