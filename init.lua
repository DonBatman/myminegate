
-- Portal Particles
local function parti(pos)
  	minetest.add_particlespawner(50, 0.4,
		{x=pos.x + 0.5, y=pos.y, z=pos.z + 0.5}, {x=pos.x - 0.5, y=pos.y, z=pos.z - 0.5},
		{x=0, y=5, z=0}, {x=0, y=0, z=0},
		{x=0, y=5, z=0}, {x=0, y=0, z=0},
		3, 5,
		3, 5,
		false,
		"myminegate_portal_parti.png")
end

-- Player Particles
local function parti2(pos)
  	minetest.add_particlespawner(50, 0.4,
		{x=pos.x + 0.5, y=pos.y + 10, z=pos.z + 0.5}, {x=pos.x - 0.5, y=pos.y, z=pos.z - 0.5},
		{x=0, y=-5, z=0}, {x=0, y=0, z=0},
		{x=0, y=-5, z=0}, {x=0, y=0, z=0},
		3, 5,
		3, 5,
		false,
		"myminegate_portal_parti.png")
end

-- Portal Formspec
local function show_form(placer)
			minetest.show_formspec(placer:get_player_name(),"portal_fs",
				"size[4.5,6;]"..
				"background[-0.5,-0.5;5.5,7;myminegate_bg.png]"..
				"field[1,1.5;1,1;px;x;]"..
				"field[2,1.5;1,1;py;y;]"..
				"field[3,1.5;1,1;pz;z;]"..
				"label[0.5,2.5;Put a portal at the other location?]"..
				"dropdown[1.25,3;2,1;yn;Yes,No;]"..
				"button_exit[1.25,4;2,1;set;Set]")
end

minetest.register_node("myminegate:portal_placer", {
	description = "Portal Placer",
	tiles = {
		"myminegate_metal.png"
	},
	drawtype = "normal",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2},

	on_place = function(itemstack, placer, pointed_thing)
	local pos = pointed_thing.above
	local meta = minetest.get_meta(pos)
	local par = minetest.get_node(pos).param2
	local schem = minetest.get_modpath("myminegate").."/schems/myminegate_portal.mts"
	local rot = 0
	local dir = minetest.dir_to_facedir(placer:get_look_dir())

-- Sets Schematic in the right place
	local tpos = {}
	local rot = ""
		if dir == 0 then rot = "90" tpos = {x = pos.x - 1, y = pos.y, z = pos.z}
		elseif dir == 1 then rot = "0" tpos = {x = pos.x, y = pos.y, z = pos.z - 1}
		elseif dir == 2 then rot = "90" tpos = {x = pos.x - 1, y = pos.y, z = pos.z}
		elseif dir == 3 then rot = "0" tpos = {x = pos.x, y = pos.y, z = pos.z - 1}
		elseif dir >= 4 then rot = "0" tpos = {x = pos.x, y = pos.y, z = pos.z - 1}
		end

		minetest.place_schematic(tpos,schem,rot, "air", true)
		show_form(placer)

		minetest.register_on_player_receive_fields(function(player, portal_fs, fields)

		if fields["px"]
		and fields["py"]
		and fields["pz"]
		and fields["yn"]
		and fields["set"] then
		
			if fields["set"] then

				if fields["set"] then
						meta:set_string("posx",fields["px"])
						meta:set_string("posy",fields["py"])
						meta:set_string("posz",fields["pz"])
				end

				if fields["yn"] == "Yes" then

					-- checks for number or nil
					local a = fields["px"]
					local b = fields["py"]
					local c = fields["pz"]
					local px = string.match(a,"^(-?%d+)")
					local py = string.match(b,"^(-?%d+)")
					local pz = string.match(c,"^(-?%d+)")

						-- change strings to number
						px = tonumber(px)
						py = tonumber(py)
						pz = tonumber(pz)

					if px and py and pz then

						-- make sure it is in map limits
						if px < -30000 or py < -30000 or pz < -30000 or
							px > 30000 or py > 30000 or pz > 30000 then
							minetest.chat_send_player(placer:get_player_name(),
								"Needs to be numbers between -30000 and 30000")
							show_form(placer)
						end

						local npos = {x = px, y = py, z = pz} -- this is the position of the second portal

						minetest.forceload_block(npos) -- Load block at new location

						-- check to make sure there is a 3 x 3 x 3 air at new location
						local _, counts = minetest.find_nodes_in_area({x=npos.x-1, y=npos.y+1, z=npos.z-1},
											{x = npos.x+1, y=npos.y+3, z = npos.z+1}, {"air","ignore"}) 
						local air_count = counts.ignore + counts.air

						if npos and
						air_count == 27 then

							local mdir = minetest.get_node(pos).param2
							local mpos = {}

							if     mdir == 0 then mpos = {x = npos.x , 		y = npos.y, z = npos.z + 1}
							elseif mdir == 1 then mpos = {x = npos.x + 1, 	y = npos.y, z = npos.z}
							elseif mdir == 2 then mpos = {x = npos.x, 		y = npos.y, z = npos.z + 1}
							elseif mdir == 3 then mpos = {x = npos.x + 1, 	y = npos.y, z = npos.z}
							end 

							minetest.place_schematic(npos,schem,rot, "air", true)
								local m = minetest.get_meta({x = mpos.x , y = mpos.y, z = mpos.z})
								minetest.after(0.5, function()
								m:set_string("posx",tostring(pos.x))
								m:set_string("posy",tostring(pos.y))
								m:set_string("posz",tostring(pos.z))
								meta:set_string("dr",mdir)
								end)

						else 

							minetest.chat_send_player(placer:get_player_name(),
								"not enough  room there")
							show_form(placer)

						end

						return true

					else

						minetest.chat_send_player(placer:get_player_name(),
							"Needs to be numbers between -30000 and 30000")
						show_form(placer)

					end
				end
			end
		end
	end) -- ends recieve_fields
end, -- end on_place
	})

local pwc_box = {
		type = "fixed",
		fixed = {
			{-0.3125,-0.5,-1.5,0.3125,-0.25,1.5},
			{-0.3125,2.25,-1.5,0.3125,2.5,1.5},}}

-- Portal with center
minetest.register_node("myminegate:portal", {
	description = "portal",
	drawtype = "mesh",
	mesh = "myminegate_portal_gate.obj",
	tiles = {"myminegate_portal_gate.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	pointable = false,
	walkable = true,
	drop = "",
	groups = {cracky = 2,not_in_creative_inventory = 0},
	selection_box = pwc_box,
	collision_box = pwc_box,

})

local pnc_box = {
		type = "fixed",
		fixed = {
			{-1.5,-1.5,-0.5,1.5,1.5,0.5},}}

-- Portal without Center
minetest.register_node("myminegate:portal2", {
	description = "portal",
	drawtype = "mesh",
	mesh = "myminegate_portal_gate.obj",
	tiles = {"myminegate_portal_gate.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = true,
	drop = "",
	groups = {cracky = 2,not_in_creative_inventory = 1},
	selection_box = pnc_box,
	collision_box = pnc_box,

})

minetest.register_node("myminegate:center", {
	description = "center",
	tiles = {{name="myminegate_ani_blue.png",
		animation={type="vertical_frames",aspect_w=16, aspect_h=16, length=0.5}}},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	post_effect_color = { r=3, g=42, b=50, a=255 },
	walkable = false,
	drop = "",
	light_source = 14,
	groups = {cracky = 2,not_in_creative_inventory = 0},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.45,		-1.25,	-0.3125,	0.45,	0.5,	0.3125},
			{-1.25,		-0.45,	-0.3125,	1.25,	0.5,	0.3125},
			{-0.9,		-1,		-0.3125,	0.9,	0.5,	0.3125},
			{-0.65,		-1.25,	-0.3125,	0.65,	0.5,	0.3125},
			{-1.15,		-0.75,	-0.3125,	1.15,	0.5,	0.3125},
		}
	},
	selection_box = pnc_box,
	collision_box = pnc_box,

	on_destruct = function(pos)
		local p = minetest.find_nodes_in_area({x=pos.x-2, y=pos.y-2, z=pos.z-2},
				{x=pos.x+2, y=pos.y+2, z=pos.z+2},
				{"myminegate:portal","myminegate:portal2","myminegate:centerb","myminegate:hidden"})
		for _,ps in ipairs(p) do
		minetest.remove_node(ps)
		end
	end,
})

minetest.register_node("myminegate:centerb", {
	description = "center",
	tiles = {{name="myminegate_ani_blue.png",
		animation={type="vertical_frames",aspect_w=16, aspect_h=16, length=0.5}}},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	post_effect_color = { r=3, g=42, b=50, a=250 },
	pointable = false,
	drop = "",
	light_source = 14,
	groups = {cracky = 2,not_in_creative_inventory = 0},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.45,		-0.5,	-0.3125,	0.45,	0.25,	0.3125},
			{-0.9,		-0.5,	-0.3125,	0.9,	0,		0.3125},
			{-0.65,		-0.5,	-0.3125,	0.65,	0.25,	0.3125},
			{-1.15,		-0.5,	-0.3125,	1.15,	-0.25,	0.3125},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1.5, 2.25, -0.3125, 1.5, 2.5, 0.3125},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-1.5, 2.25, -0.3125, 1.5, 2.5, 0.3125},
		}
	},
})

minetest.register_node("myminegate:hidden", {
	description = "hidden",
	tiles = {"myminegate_hidden.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	pointable = false,
	drop = "",
	groups = {cracky = 2,not_in_creative_inventory = 0},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.25, 0.5, 0.5},
		}
	}
})
---[[
minetest.register_abm({
	nodenames = {"myminegate:center"},
	interval = 0.5,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)

		local spawn_spot = {}
		local meta = minetest.get_meta({x = pos.x, y = pos.y - 1, z = pos.z})
		local p1 = tonumber(meta:get_string("posx")) or pos.x
		local p2 = tonumber(meta:get_string("posy")) or pos.y
		local p3 = tonumber(meta:get_string("posz")) or pos.z + 3
		local par = tonumber(meta:get_string("dr")) or 0
		spawn_spot = {x=p1, y=p2, z=p3}

		local objs = minetest.get_objects_inside_radius({x = pos.x, y = pos.y - 1, z = pos.z}, 1)

		for k, player in pairs(objs) do

			if player:get_player_name() then

				if minetest.get_player_privs(player:get_player_name()).interact == true then
				
				if par == 0 or par == 2 then
				spawn_spot.x = spawn_spot.x+2
				elseif par == 1 or par == 3 then
				spawn_spot.z = spawn_spot.z+2
				end
					parti(pos)
					player:setpos(spawn_spot)
					parti2(spawn_spot)

				end
			end
		end
	end
})
--]]
