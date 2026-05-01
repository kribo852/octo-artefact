random = {}

function random.mapping_algorithm(x, y, r, g, b, a)

    local mean_r, mean_g, mean_b = random.get_mean_value() -- comes from without this file

    if love.math.random() * (mean_r + mean_g + mean_b) * 2 < r + g + b then
    	return 1.0, 1.0, 1.0, a
    end

    return 0, 0, 0, a
end


return random