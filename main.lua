
function love.load(program_arguments)
	if program_arguments[1] and program_arguments[2] then
		picture_name = program_arguments[1]
		algorithm_name = program_arguments[2]
		load_image()
		run_algorithm()
	else
		love.event.quit(1)
	end
end

function love.update(delta_time)
	
end

function love.draw(delta_time)
	love.graphics.draw(image)
end

function love.keypressed(key)
	if key == "escape" then
      love.event.quit()
   end
end

function load_image()
	local image_data = love.image.newImageData(picture_name)
	local tmp_image = love.graphics.newImage(image_data)

	local height_scale = image_data:getHeight()/screen_height
	local width_scale = image_data:getWidth()/screen_width

	local max_scale = math.max(height_scale, width_scale);
	print("down scale: "..max_scale)

	canvas = love.graphics.newCanvas(image_data:getWidth()/max_scale, image_data:getHeight()/max_scale)
	love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.draw(tmp_image, 0, 0, 0, 1/max_scale, 1/max_scale)
    love.graphics.setCanvas()
end

function run_algorithm()
	local unmapped_image_data = canvas:newImageData()
	local mapped_image_data = unmapped_image_data:clone()
	local algorithm = require(algorithm_name)

	set_helper_functions_on_algorithm(algorithm, unmapped_image_data)

	mapped_image_data:mapPixel(algorithm.mapping_algorithm)
	image = love.graphics.newImage(mapped_image_data)
end

function set_helper_functions_on_algorithm(algorithm, image_data)
	algorithm.get_mean_value = get_mean_value_calculator(image_data) -- this runs before the algorithm
	algorithm.measure_color = function(x, y) return image_data:getPixel(x, y) end -- this uses the scaled picture, so that it will be easy to get adjacent pixels, to the pixel being transformed
	algorithm.get_scaled_height = function() return image_data:getHeight() end
	algorithm.get_scaled_width = function() return image_data:getWidth() end
end

function get_mean_value_calculator(image_data) -- this uses the unscaled picture
	local mean_r = 0
	local mean_g = 0
	local mean_b = 0

	for i=1,100 do
		local x = love.math.random(image_data:getWidth()) - 1
		local y = love.math.random(image_data:getHeight()) - 1
		local tmp_r, tmp_g, tmp_b = image_data:getPixel(x, y)

		mean_r = mean_r + tmp_r
		mean_g = mean_g + tmp_g
		mean_b = mean_b + tmp_b
	end

	mean_r = mean_r/100
	mean_g = mean_g/100
	mean_b = mean_b/100

	return function() return mean_r, mean_g, mean_b end
end

--ImageData:encode //save to file
