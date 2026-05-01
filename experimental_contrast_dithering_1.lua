-- This algorithm is experimental and uses the brightness difference to adjacent pixels rather than compared to the whole picture
experimental_contrast_dithering_1 = {}

local function get_surrounding_pixels(x, y)

	local list = {}
	
	for i=-1,1 do
		for j=-1,1 do
			if x+i >= 0 and x+i < experimental_contrast_dithering_1.get_scaled_width() and 
				y+j >= 0 and y+j < experimental_contrast_dithering_1.get_scaled_height() then
				if not (i==0 and j==0) then
					local tmp_r, tmp_g, tmp_b = experimental_contrast_dithering_1.measure_color(x+i, y+j)
					local brightness_sqr = tmp_r^2 + tmp_g^2 + tmp_b^2
					table.insert(list, brightness_sqr)
				end
			end
		end
	end
	return list
end

local function is_brighter_cmp_to_surrounding(sur_pix_list, pixel_brightness_sq)
	local count = 0

	for _,bright in ipairs(sur_pix_list) do
		if bright < pixel_brightness_sq then
			count = count + 1
		end
	end
	return count
end

function experimental_contrast_dithering_1.mapping_algorithm(x, y, r, g, b, a)

	local surrounding_pixels = get_surrounding_pixels(x, y)

	if(is_brighter_cmp_to_surrounding(surrounding_pixels, r^2 + g^2 + b^2) >= 5) then
		return 1.0, 1.0, 1.0, a
	end

	if(is_brighter_cmp_to_surrounding(surrounding_pixels, r^2 + g^2 + b^2) <= 3) then
		return 0, 0, 0, a
	end

	 local mean_r, mean_g, mean_b = experimental_contrast_dithering_1.get_mean_value()

    if r + g + b > mean_r + mean_g + mean_b then
    	return 1.0, 1.0, 1.0, a
    end

    return 0, 0, 0, a
end

return experimental_contrast_dithering_1
