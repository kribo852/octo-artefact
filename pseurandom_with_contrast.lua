pseudorandom = {}

local function mod(a, b)
    return a - (math.floor(a/b)*b)
end

local function vector_length(r, g, b)
    return math.sqrt(r^2 + g^2 + b^2)
end

local function get_min_rgb()
    if not pseudorandom.min_r then
        pseudorandom.min_r = 1
        pseudorandom.min_g = 1
        pseudorandom.min_b = 1

        for x = 0,pseudorandom.get_scaled_width() - 1 do
            for y = 0,pseudorandom.get_scaled_height() - 1 do
                local tmp_r, tmp_g, tmp_b = pseudorandom.measure_color(x, y)
                pseudorandom.min_r = math.min(pseudorandom.min_r, tmp_r)
                pseudorandom.min_g = math.min(pseudorandom.min_g, tmp_g)
                pseudorandom.min_b = math.min(pseudorandom.min_b, tmp_b)
            end
        end
    end

    return pseudorandom.min_r, pseudorandom.min_g, pseudorandom.min_b
end

local function get_max_rgb()
    if not pseudorandom.max_r then
        pseudorandom.max_r = 0
        pseudorandom.max_g = 0
        pseudorandom.max_b = 0

        for x = 0,pseudorandom.get_scaled_width() - 1 do
            for y = 0,pseudorandom.get_scaled_height() - 1 do
                local tmp_r, tmp_g, tmp_b = pseudorandom.measure_color(x, y)
                pseudorandom.max_r = math.max(pseudorandom.max_r, tmp_r)
                pseudorandom.max_g = math.max(pseudorandom.max_g, tmp_g)
                pseudorandom.max_b = math.max(pseudorandom.max_b, tmp_b)
            end
        end
    end
    return pseudorandom.max_r, pseudorandom.max_g, pseudorandom.max_b
end

local function calc_x_contrast(x, y)
    local contrast = 0
    local tmp_r, tmp_g, tmp_b = pseudorandom.measure_color(x, y)

    if x-1 >= 0 then
        local tmp_r_minus, tmp_g_minus, tmp_b_minus = pseudorandom.measure_color(x-1, y)
        contrast = math.abs( tmp_r - tmp_r_minus ) + math.abs( tmp_g - tmp_g_minus ) + math.abs( tmp_b + tmp_b_minus )
    end

    if x+1 < pseudorandom.get_scaled_width() then
        local tmp_r_plus, tmp_g_plus, tmp_b_plus = pseudorandom.measure_color(x+1, y)
        contrast = contrast + math.abs( tmp_r - tmp_r_plus ) + math.abs( tmp_g - tmp_g_plus ) + math.abs( tmp_b + tmp_b_plus )
    end

    return contrast
end

local function calc_y_contrast(x, y)
    local contrast = 0
    local tmp_r, tmp_g, tmp_b = pseudorandom.measure_color(x, y)

    if y-1 >= 0 then
        local tmp_r_minus, tmp_g_minus, tmp_b_minus = pseudorandom.measure_color(x, y-1)
        contrast = math.abs( tmp_r - tmp_r_minus ) + math.abs( tmp_g - tmp_g_minus ) + math.abs( tmp_b + tmp_b_minus )
    end

    if y+1 < pseudorandom.get_scaled_height() then
        local tmp_r_plus, tmp_g_plus, tmp_b_plus = pseudorandom.measure_color(x, y+1)
        contrast = contrast + math.abs( tmp_r - tmp_r_plus ) + math.abs( tmp_g - tmp_g_plus ) + math.abs( tmp_b + tmp_b_plus )
    end

    return contrast
end
--calculate the contrast thresholds for different random functions 
local function calculate_contrast_tresholds()
    if pseudorandom.threshold then
        return
    end

    local samples = {}

    for i=1,10000 do
        local x_contrast = calc_x_contrast(love.math.random(pseudorandom.get_scaled_width())-1,love.math.random(pseudorandom.get_scaled_height())-1)
        local y_contrast = calc_y_contrast(love.math.random(pseudorandom.get_scaled_width())-1,love.math.random(pseudorandom.get_scaled_height())-1)
        table.insert(samples, (x_contrast + y_contrast)/2)
    end

    table.sort(samples)

    pseudorandom.threshold = {}
    pseudorandom.threshold[1] = samples[2500]
    pseudorandom.threshold[2] = samples[5000]
    pseudorandom.threshold[3] = samples[7500]
end

local function calc_rng_constants(x, y) -- calculate from contrast to neighbouring pixels
    local rng_constants = {{61,447},{83,127},{129,51}}
    local y_rng_constant = 131
    local x_rng_constant = 223
    local x_contrast = calc_x_contrast(x,y)
    local y_contrast = calc_y_contrast(x,y)

    for i,val in ipairs(pseudorandom.threshold) do
        if x_contrast > val then
            x_rng_constant = rng_constants[i][1]
        end
        if y_contrast > val then
            y_rng_constant = rng_constants[i][2]
        end
    end

    return x_rng_constant, y_rng_constant
end

function pseudorandom.mapping_algorithm(x, y, r, g, b, a)

    --get min values rgb, calculate max rgb values, do this in a singleton
    local min_r, min_g, min_b = get_min_rgb()
    local max_r, max_g, max_b = get_max_rgb()

    calculate_contrast_tresholds()
    
    --calculate constants for the random function, which depends on how much contrast/frequency there is
    local x_rng_constant, y_rng_constant = calc_rng_constants(x, y) 

    local pseudo_random_number = mod((x_rng_constant*x + y_rng_constant*y), 301)/301

    --if the measured value is more than the random number between 0-1 times the max vector length, then light the pixel
    if pseudo_random_number*vector_length(max_r-min_r, max_g-min_g, max_b-min_b) < 
        vector_length(r-min_r, g-min_g, b-min_b) then
    	return 1.0, 1.0, 1.0, a
    end

    return 0, 0, 0, a
end

return pseudorandom
