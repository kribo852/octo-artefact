raster = {}

local function mod(a, b)
    return a - (math.floor(a/b)*b)
end

function raster.mapping_algorithm(x, y, r, g, b, a)

    local mean_r, mean_g, mean_b = raster.get_mean_value() -- comes from without this file

    local scale = (r+g+b)/(mean_r + mean_g + mean_b)

    local activation_levels = {{0.3, 1.3, 1.5},{0.6, 0.7, 1.4},{0.1, 1.8, 0.6}} -- I selected these values "at random", between 0 and 2. But som below and other above 1

    if activation_levels[mod(x,3)+1][mod(y,3)+1] < scale then
      return 1.0, 1.0, 1.0, a
    end

    return 0, 0, 0, a
end

return raster