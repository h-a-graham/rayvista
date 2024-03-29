define_extent <- function(lat, long, radius, epsg){
  extent_sf <- sf::st_sfc(sf::st_point(c(long, lat))) %>%
    sf::st_set_crs(epsg) %>%
    sf::st_transform(3857) %>%
    sf::st_buffer(radius)%>%
    sf::st_bbox()%>%
    sf::st_as_sfc()%>%
    sf::st_sf()

  return(extent_sf)
}

define_extent_sf <- function(req_area){
  # check if requested area is sf or sf:readable
  if (class(req_area)[1] == "sf"){
    sf_geom <- req_area
  } else {
    sf_geom <- sf::read_sf(req_area)
  }

  if (is.na(sf::st_crs(sf_geom)[1]$input)) {
    stop("Requested area has no valid projection. Please set a valid CRS.")
  }

  req_area <- sf_geom %>%
    sf::st_transform(3857) %>%
    sf::st_bbox() %>%
    sf::st_as_sfc() #%>%
    # sf::st_sf(crs=3857)


  return(req_area)
}

define_extent_dem <- function(dem){
  # check class of dem for now support terra, raster or raster-readable
  if (class(dem)[1] == "RasterLayer"){
    dem_raster <- dem
  } else if (class(dem)[1] == "SpatRaster") {
    dem_raster <- raster::raster(dem)
  } else if (class(dem)[1] == "character"){
    dem_raster <- raster::raster(dem)
  } else {
    stop("the class of argument `dem` is not supported. Use any of the
         following: terra, raster or raster-readable file path")
  }

  dem_raster <- raster::projectRaster(dem_raster, crs=sf::st_crs(3857)$wkt)

  dem_ext <- new_bbox <- sf::st_bbox(c(xmin=raster::extent(dem_raster)[1],
                                       ymin=raster::extent(dem_raster)[3],
                                       xmax=raster::extent(dem_raster)[2],
                                       ymax=raster::extent(dem_raster)[4])) %>%
    sf::st_as_sfc() %>%
    sf::st_sf(crs=3857)

  return(list(dem=dem_raster, dem_extent = dem_ext))
}
