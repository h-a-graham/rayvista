download_overlay <- function(bounds_sf, zoomlevel, cache_dir, image_provider){

  # dowload tiles and compose raster (SpatRaster)
  nc_esri <- maptiles::get_tiles(x = bounds_sf, provider = image_provider,
                                 crop = TRUE, cachedir = cache_dir,
                                 verbose = TRUE, zoom=zoomlevel)
  # return(nc_esri)
  tile_dim <- dim(nc_esri)

  # vsp <- as(bounds_sf, "Spatial")
  # v <- terra::vect(vsp)
  # nc_esri <- terra::crop(nc_esri, v, snap="out")

  new_bbox <- sf::st_bbox(c(xmin=terra::bbox(nc_esri)[1],
                            ymin=terra::bbox(nc_esri)[2],
                            xmax=terra::bbox(nc_esri)[3],
                            ymax=terra::bbox(nc_esri)[4])) %>%
    sf::st_as_sfc() %>%
    sf::st_sf(crs=terra::crs(nc_esri, proj4=T))

  ### NOTE - DO WE NEED THIS PNG EPORT - CHECK CLASSES ETC...
  file_name<-tempfile(fileext = '.png')
  png(file_name, width = tile_dim[2], height = tile_dim[1])
  print({
    maptiles::plot_tiles(nc_esri)
  })
  dev.off()

  overlay_img <- png::readPNG(file_name)
  overlay_img_contrast <-scales::rescale(overlay_img,to=c(0,1))

  return(list(overlay=overlay_img_contrast, new_bounds=new_bbox))
}
