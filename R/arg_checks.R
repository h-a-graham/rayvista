arg_checks <- function(cache_dir, image_provider, api_key, req_area, dem,
                       elevation_detail, overlay_detail){

  if (!is.null(req_area) & !is.null(dem)){
    stop('Values provided for both `req_area` and  `dem`. You can only request
         one or the other, not both.')
  }

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

  if (elevation_detail > 14){
    message(sprintf('elevation detail > 14 (the max). 14 will be used instead of %s', 15))
    elevation_detail <- 14
  }

  if (overlay_detail > 16){
    message('overlay_detail > 16! This is risky and may result in an error or funny looking overlays...')
  }



  return(list(cache_sub=cache_sub, elevation_detail=elevation_detail))
}
