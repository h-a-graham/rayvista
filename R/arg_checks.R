arg_checks <- function(cache_dir, image_provider, api_key){

  # check cache directory and create if needed.
  if (!dir.exists(cache_dir)) dir.create(cache_dir)
  cache_sub <- file.path(cache_dir, 'rayvista_cache')
  if (!dir.exists(cache_sub)) dir.create(cache_sub)

  # check if using THunderforest and then check is API has been provided.
  if (image_provider %in% c("Thunderforest.OpenCycleMap",
                            "Thunderforest.Transport",
                            "Thunderforest.TransportDark",
                            "Thunderforest.SpinalMap",
                            "Thunderforest.Landscape",
                            "Thunderforest.Outdoors",
                            "Thunderforest.Pioneer",
                            "Thunderforest.MobileAtlas",
                            "Thunderforest.Neighbourhood")) {
  if (is.null(api_key)) {stop("A valid API key is required for Thuderforest maps.
  See: https://www.thunderforest.com/docs/apikeys/")}
  }
  return(cache_sub)
}
