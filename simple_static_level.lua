simple = {}

function simple.mapping_algorithm(x, y, r, g, b, a)

    local mean_r, mean_g, mean_b = simple.get_mean_value() -- comes from without this file

    if r + g + b > mean_r + mean_g + mean_b then
    	return 1.0, 1.0, 1.0, a
    end

    return 0, 0, 0, a
end


return simple