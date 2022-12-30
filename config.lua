local r = display.pixelHeight / display.pixelWidth;
local w = 1000;
local h = r * w ;

application =
{
	
	content =
	{
		width = w,
		height = h, 
		scale = "letterbox",
		fps = 30,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
	},
}
