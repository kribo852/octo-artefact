cmp_to_radius = {}

function cmp_to_radius.mapping_algorithm(x, y, r, g, b, a)

    local mean_r, mean_g, mean_b = 0,0,0
    local sum_length = 0

    for i=-5,5 do
        for j=-5,5 do
            if i^2 + j^2 < 25 then
                if not (i==0 and j==0) then --iterate over 100 pixels, take the ones inside the ring, but not at 0,0
                    if x + i >= 0 and x + i < cmp_to_radius.get_scaled_width() and y + j >= 0 and y + j < cmp_to_radius.get_scaled_height() then 
                        local inv_distance = 1/math.sqrt(i^2 + j^2)
                        sum_length = sum_length + inv_distance -- is decreasing by distance, a less lazy way would be to use the normal distribution
                        local tmp_r, tmp_g, tmp_b = cmp_to_radius.measure_color(x+i, y+j)

                        mean_r = mean_r + tmp_r*inv_distance
                        mean_g = mean_g + tmp_g*inv_distance
                        mean_b = mean_b + tmp_b*inv_distance
                    end
                end
            end    
        end     
    end

    mean_r = mean_r/sum_length
    mean_g = mean_g/sum_length
    mean_b = mean_b/sum_length

    if math.abs(math.sqrt(r^2 + g^2 + b^2) - math.sqrt(mean_r^2 + mean_g^2 + mean_b^2)) > 0.0125 then --i don't really like this random cutoff constant, but what can one do :)
        if math.sqrt(r^2 + g^2 + b^2) > math.sqrt(mean_r^2 + mean_g^2 + mean_b^2) then -- compare to the pixels in the ring near the current pixel
    	   return 1.0, 1.0, 1.0, a
        end
        return 0, 0, 0, a
    end

    whole_pic_mean_r, whole_pic_mean_g, whole_pic_mean_b = cmp_to_radius.get_mean_value() 

    if r + g + b > whole_pic_mean_r + whole_pic_mean_g + whole_pic_mean_b then
        return 1.0, 1.0, 1.0, a
    end

    return 0, 0, 0, a
end


return cmp_to_radius