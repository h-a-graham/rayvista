
# rayshader<img src="man/figures/hex_HR.png" width="30%" />

## Introduction

**rayvista** is a rayshader extension

## Installation

``` r
# install.packages("devtools")
devtools::install_github("h-a-graham/rayvista")
```

## Examples

``` r
# Make sure to so you can interact with the {rgl} window after running `plot_3d_vista()`
library(rayshader) 
library(rayvista)

plot_3d_vista(lat=55.757338, long=160.526712)

render_snapshot(clear=TRUE)
```

![](man/figures/GoraBolshayaUdina-1.png)<!-- -->

``` r
plot_3d_vista(lat=37.742501, long=-119.558298, zscale=5)

render_snapshot(clear=TRUE)
```

![](man/figures/Yosemite-1.png)<!-- -->
