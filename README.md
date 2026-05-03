A little project for making dithering effects and other, on pictures

This project is made with LOVE 2D

Select an image, and an algorithm to run with, for example:
$ love . train.jpg random_noise
$ love . room.jpg pseudorandom_with_contrast

All example images in this project are free to use.

You can implement and test your own dithering algorithms, it's only a few lines of code for a simple implementation, check out the existing algorithms for some guidance: 
* random_noise.lua
* simple_static_level.lua
* budget_raster.lua
* pseudorandom_with_contrast
* compare_with_radius


In the dithering algorithms, there might be a need to do other more advanced calculations, than the api can handle. I will try to inject useful functions into the running algorithms, from the main file, for more advanced calculations.


