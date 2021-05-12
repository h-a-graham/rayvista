define_extent <- function(lat, long, radius){
  extent_sf <- sf::st_sfc(sf::st_point(c(long, lat))) %>%
    sf::st_set_crs(4326) %>%
    sf::st_transform(3857) %>%
    sf::st_buffer(radius)%>%
    sf::st_bbox()%>%
    sf::st_as_sfc()%>%
    sf::st_sf()

  return(extent_sf)
}

#' Convert degrees coordinates from EPSG 4326 to 3857
#'
#' A helper function that allows for the calculation of pseudo mercator coords
#' which are useful when using functions such as `rayshader::render_label()`
#' because the constructed scene is projected in EPSG 3857.
#'
#' @param lat numeric vecotr - degrees latitude of point (WGS-84)
#' @param ong numeric vecotr - degrees longitude of point (WGS-84)
#' @export
#' @examples
#' .lat <- 57.21956608144513
#' .long <- -6.092690805001252
#' get_coords_3857(lat=.lat, long=.long)
#'
get_coords_3857 <- function(lat, long){
  .point <- sf::st_sfc(sf::st_point(c(long, lat))) %>%
    sf::st_set_crs(4326) %>%
    sf::st_transform(3857) %>%
    unlist()
  return(list(lat=.point[2], long=.point[1]))
}
