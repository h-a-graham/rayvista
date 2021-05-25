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

  if (is.na(sf::st_crs(req_area)[1]$input)) {
    stop("Requested area has no valid projection. Please set a valid CRS.")
  }

  req_area <- req_area %>%
    sf::st_transform(3857) %>%
    sf::st_bbox() %>%
    sf::st_as_sfc() #%>%
    # sf::st_sf(crs=3857)


  return(req_area)
}
