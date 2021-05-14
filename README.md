
# rayvista

<p align="center">
<img src="man/figures/hex_HR.png" width="30%" />
</p>

## Introduction

**rayvista** is an R package providing a small plugin for the fabulous
[{rayshader}](https://github.com/tylermorganwall/rayshader) package. It
provides a single main function `plot_3d_vista` which allows the user to
create a 3D visualisation of any location on earth. It is reliant on two
other brilliant packages:
[{maptiles}](https://github.com/riatelab/maptiles) and
[{elevatr}](https://github.com/jhollist/elevatr). The many available map
styles from {maptiles} can be easily overlaid on top of elevation data
from {elevatr} to create the 3D scene or vista :wink:

An [{rgl}](https://github.com/cran/rgl) window is opened which displays
the vista and the user may then interact with it using a selection of
functions provided by {rayshader} including: `render_snapshot`,
`render_highquality`, `render_compass`, etc. see the [rayshader function
reference](https://www.rayshader.com/reference/index.html) for more
details…

You can access the data attribution from the returned matrix object.

This package is in its early days so there will no doubt be some issues.
Please feel free to submit an
[issue](https://github.com/h-a-graham/rayvista/issues) or start up a
[discussion]()

## Installation

``` r
# install.packages("devtools")
devtools::install_github("h-a-graham/rayvista")
```

## Examples

``` r
# Make sure to lod rayshader so you can interact with the {rgl} window after 
# running `plot_3d_vista()`
library(rayshader) 
library(rayvista)

.lat <- 57.21956608144513
.long <- -6.092690805001252

cuillins <- plot_3d_vista(lat = .lat, long = .long, phi=30)

render_label(heightmap= cuillins, text='Bla Bheinn: 928 m', lat = .lat,
             long=.long, extent = attr(cuillins, 'extent'),altitude=600,
             clear_previous = T, zscale = 2)

render_compass()

render_scalebar(limits=c(
  round(dim(cuillins)[2]*attr(cuillins, 'resolution')/1000,1)),
  label_unit = 'km')

render_snapshot(clear=TRUE)
```

![](man/figures/BlaBheinn-1.png)<!-- -->

``` r
GoraBolshayaUdina <- plot_3d_vista(lat=55.757338, long=160.526712, zscale=4, phi=20)

render_depth(focus=0.4, focallength = 30, clear=TRUE)
```

![](man/figures/GoraBolshayaUdina-1.png)<!-- -->

``` r
Yosemite <- plot_3d_vista(lat=37.742501, long=-119.558298, zscale=5, zoom=0.5, theta=-65,
              phi=25)

render_highquality(clear=TRUE)
```

![](man/figures/Yosemite-1.png)<!-- -->

``` r
HopkinsNZ <- plot_3d_vista(lat=-44.042238, long=169.860985, radius=5000, overlay_detail = 14,
             elevation_detail=13, zscale=5, img_provider = 'OpenStreetMap',
             cache_dir = 'testing',theta=25, phi=25, zoom=0.5,
             windowsize =1200, solid=T, background='grey10')

render_highquality(lightdirection = c(60,120, 240),
                   lightaltitude=c(90,25, 12),
                   lightintensity=c(100, 500, 450),
                   lightcolor = c("white", "#FF9956", "#FF79E7"),
                   clear=TRUE)
```

![](man/figures/HopkinsNZ-1.png)<!-- -->
