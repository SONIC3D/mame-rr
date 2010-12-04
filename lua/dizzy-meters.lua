print("Dizzy/Stun meter viewer")
print("written by Dammit")
print("December 4, 2010")
print("http://code.google.com/p/mame-rr/")
print("Lua hotkey 1: toggle numbers") print()

local color = {
	bar = {
		back          = 0x00000040,
		border        = 0x000000FF,
		level         = 0xFF0000FF,
		long_level    = 0xFFAAAAFF,
		timeout       = 0xFFFF00FF,
		long_timeout  = 0xFFA000FF,
		duration      = 0x00C0FFFF,
		long_duration = 0xA0FFFFFF,
		grace         = 0x00FF00FF,
		long_grace    = 0xFFFFFFFF,
	},
	text = {
		life          = 0x00FF00FF,
		super         = 0xFFFF00FF,
		claw          = 0xFFB0FFFF,
		guard         = 0x00FFFFFF,
	},
	STUN = {
		fill          = 0xF8B000FF,
		shade         = 0xB06000FF,
		border        = 0x500000FF,
	},
}

local HARD_LIMIT        = 1
local PTR_LIMIT         = 2
local PTR_LIMIT_BASE    = 3
local PTR_LIMIT_NO_BASE = 4
local HSF2_LIMIT        = 5
local DIRECT            = 1
local POINTER           = 2
local NORMAL            = 1
local SF2               = 2
local SFA               = 3
local SFA3              = 4
local RINGDEST          = 5
local NO_SUPER          = 1
local DRAW_SUPER        = 2
local MODAL_SUPER       = 3

local profile = {
	{
		games  = {"hsf2"},
		active = 0xFF836D,
		player = 0xFF833C,
		offset = {
			level       = 0x05E,
			limit       = 0x2B1,
			timeout     = 0x05C,
			duration    = 0x060,
			grace       = 0x1F2,
			dizzy       = 0x1F0,
			countdown   = 0x1F0, --dummy
			char_mode   = 0x32A,
			life        = 0x02B,
			super       = 0x2B4,
			char_id     = 0x391,
			claw_status = 0x14C,
			claw_level  = 0x162,
		},
		read = {
			timeout = memory.readword,
			limit   = memory.readbyte,
			grace   = memory.readword,
		},
		max = {
			timeout  = 180,
			duration = 180,
			grace    = 60,
			super    = 48,
		},
		pos = {
			bar_X      = 0x18,
			bar_Y      = 0x20,
			bar_length = 0x40,
			bar_height = 0x04,
			life_X     = 0x10,
			life_Y     = 0x0E,
			super_X    = 0x64,
			super_Y    = 0xCE,
			claw_Y     = 0xD8,
		},
		super_mode = MODAL_SUPER,
		limit_type = HSF2_LIMIT,
		limit_base_array = {
			[0x06D830] = {"hsf2", "hsf2a", "hsf2d"}, --040202
			[0x06D828] = {"hsf2j"}, --031222
		},
		claw_id = 0xB,
	},
	{
		games  = {"ssf2t"},
		active = 0xFF847F,
		player = 0xFF844E,
		offset = {
			grace       = 0x1F2,
			char_mode   = 0x3B6,
			char_id     = 0x391,
			claw_status = 0x14C,
			claw_level  = 0x162,
		},
		limit_base_array = {
			[0x07F1C6] = {"ssf2t", "ssf2ta", "ssf2tur1", "ssf2xjd", "ssf2xj", "ssf2tu"}, --940223, 940323
		},
		read = {
			limit = memory.readbyte,
			grace = memory.readword,
		},
		max = {super = 48},
		super_mode = MODAL_SUPER,
		claw_id = 0xB,
	},
	{
		games  = {"ssf2"},
		active = 0xFF83FF,
		player = 0xFF83CE,
		offset = {
			grace       = 0x1F2,
			char_id     = 0x391,
			claw_status = 0x14C,
			claw_level  = 0x162,
		},
		read = {grace = memory.readword},
		hard_limit = 0x1F,
		super_mode = NO_SUPER,
		claw_id = 0xB,
	},
	{
		games  = {"sf2ce","sf2hf"},
		active = 0xFF83EF,
		player = 0xFF83BE,
		offset = {
			space       = 0x300,
			grace       = 0x1F0,
			dizzy       = 0x123,
			countdown   = 0x124,
			char_id     = 0x291,
			claw_status = 0x14C,
			claw_level  = 0x162,
		},
		read = {grace = memory.readword},
		hard_limit = 0x1F,
		countdown_check = SF2,
		super_mode = NO_SUPER,
		claw_id = 0xB,
	},
	{
		games  = {"sf2"},
		active = 0xFF83F7,
		player = 0xFF83C6,
		hard_limit = 0x1E,
		offset = {
			space       = 0x300,
			char_id     = 0x291,
			claw_status = 0x14C,
			claw_level  = 0x162,
		},
		countdown_check = SF2,
		super_mode = NO_SUPER,
		claw_id = 0xB,
	},
	{
		games  = {"sfa"},
		active = 0xFF8280,
		player = 0xFF8400,
		offset = {
			level     = 0x137,
			limit     = 0x13A,
			timeout   = 0x136,
			duration  = 0x02C,
			countdown = 0x006,
			dizzy     = 0x13B,
			life      = 0x041,
			super     = 0x0BF,
		},
		read = {timeout  = memory.readbyte},
		max = {timeout = 210},
		pos = {
			bar_X   = 0x0E,
			bar_Y   = 0x26,
			life_Y  = 0x08,
			super_X = 0x20,
			super_Y = 0xD8,
		},
		nplayers = 3,
		countdown_check = SFA,
	},
	{
		games  = {"sfa2","sfz2al"},
		active = 0xFF812D,
		player = 0xFF8400,
		offset = {
			duration  = 0x03A,
			countdown = 0x006,
			life      = 0x051,
			super     = 0x09F,
		},
		pos = {
			bar_X  = 0x10,
			bar_Y  = 0x26,
			life_X = 0x98,
		},
		nplayers = 3,
		countdown_check = SFA,
	},
	{
		games  = {"sfa3"},
		active = 0xFF812D,
		player = 0xFF8400,
		base   = 0xFF8000,
		offset = {
			level       = 0x2CC,
			limit       = 0x2CD,
			timeout     = 0x2CB,
			duration    = 0x03A,
			dizzy       = 0x2CF,
			countdown   = 0x054,
			knockdown   = 0x2CA,
			char_mode   = 0x15E,
			life        = 0x051,
			super       = 0x11F,
			guard_level = 0x24D,
			guard_limit = 0x24C,
			char_id     = 0x102,
			claw_status = 0x06A,
			mask_status = 0x06B,
			claw_ptr    = 0x028,
			mask_ptr    = 0x02A,
			item_level  = 0x6C,
			status      = 0x006,
			combo_count = 0x05E,
			airborne    = 0x031,
			base_flip   = {0x10E, 0x10D, 0x08A},
			player_flip = {0x2CE, 0x26A, 0x26B},
		},
		max = {timeout = 180},
		pos = {
			bar_X         = 0x10,
			bar_Y         = 0x24,
			life_X        = 0x84,
			life_Y        = 0x08,
			super_X       = 0x66,
			super_Y       = 0xCA,
			claw_Y        = 0xB8,
			guard_X       = 0x28,
			guard_Y       = 0x1A,
			pseudocombo_X = 0x88,
			pseudocombo_Y = 0x34,
		},
		nplayers = 4,
		countdown_check = SFA3,
		super_mode = MODAL_SUPER,
		claw_id = 0x1C,
	},
	{
		games  = {"xmcota"},
		active = 0xFF4BA4,
		player = 0xFF4000,
		offset = {
			level     = 0x0B9,
			limit     = 0x050,
			timeout   = 0x0BA,
			duration  = 0x0FC,
			grace     = 0x140,
			dizzy     = 0x13A,
			countdown = 0x0BB,
			life      = 0x191,
			super     = 0x195,
		},
		read = {limit = memory.readword},
		max = {
			grace = 180,
			life  = 143,
			super = 142,
		},
		pos = {
			bar_X   = 0x18,
			bar_Y   = 0xD0,
			life_X  = 0x80,
			life_Y  = 0x08,
			super_X = 0x62,
			super_Y = 0x2A,
		},
		limit_base_array = {
			[0x0B7DF4] = {"xmcotajr"}, --941208
			[0x0C10C2] = {"xmcotaa", "xmcotaj3"}, --941217
			[0x0C125C] = {"xmcotaj2"}, --941219
			[0x0C128A] = {"xmcotaj1"}, --941222
			[0x0C1DAE] = {"xmcota", "xmcotad", "xmcotahr1", "xmcotaj", "xmcotau"}, --950105
			[0x0C1DE4] = {"xmcotah"}, --950331
		},
	},
	{
		games  = {"msh"},
		active = 0xFF8EC3,
		player = 0xFF4000,
		offset = {grace = 0x140},
		read = {limit = memory.readword},
		max = {super = 142},
		pos = {
			life_X  = 0xA4,
			life_Y  = 0x02,
			super_Y = 0x24,
		},
		limit_base_array = {
			[0x09F34A] = {"msh", "msha", "mshjr1", "mshud", "mshu"}, --951024
			[0x09F47C] = {"mshb", "mshh", "mshj"}, --951117
		},
	},
	{
		games  = {"xmvsf"},
		active = 0xFF5400,
		player = 0xFF4000,
		offset = {
			limit    = 0x052,
			grace    = 0x136,
			duration = 0x138,
			dizzy    = 0x135,
			life     = 0x211,
			super    = 0x213,
		},
		read = {limit = memory.readword},
		pos = {
			bar_X        = 0x18,
			bar_Y        = 0x2A,
			super_X      = 0xA4,
			super_Y      = 0xD8,
		},
		limit_base_array = {
			[0x08BAFE] = {"xmvsfjr2"}, --960909
			[0x08BB38] = {"xmvsfar2", "xmvsfr1", "xmvsfjr1"}, --960910
			[0x08BC6C] = {"xmvsf", "xmvsfar1", "xmvsfh", "xmvsfj", "xmvsfu1d", "xmvsfur1"}, --960919, 961004
			[0x08BC9A] = {"xmvsfa", "xmvsfb", "xmvsfu"}, --961023
		},
	},
	{
		games      = {"mshvsf"},
		active     = 0xFF4C00,
		player_ptr = 0xFF48C8,
		offset = {
			space = 0x8,
			limit = 0x052,
			grace = 0x136,
			life  = 0x251,
			super = 0x253,
		},
		read = {limit = memory.readword},
		pos = {
			bar_Y   = 0x24,
			life_X  = 0xA4,
			life_Y  = 0x22,
			super_X = 0x88,
			super_Y = 0xC8,
		},
		limit_base_array = {
			[0x138C3E] = {"mshvsfa1"}, --970620
			[0x138C90] = {"mshvsf", "mshvsfa", "mshvsfb1", "mshvsfh", "mshvsfj2", "mshvsfu1", "mshvsfu1d"}, --970625
			[0x138F06] = {"mshvsfj1"}, --970702
			[0x138F92] = {"mshvsfj"}, --970707
			[0x138F74] = {"mshvsfu", "mshvsfb"}, --970827
		},
	},
	{
		games      = {"mvsc"},
		active     = 0xFF62B7,
		player_ptr = 0xFF40C8,
		offset = {
			space     = 0x8,
			level     = 0x0C9,
			timeout   = 0x0CA,
			duration  = 0x146, --dummy
			grace     = 0x146,
			dizzy     = 0x145,
			countdown = 0x146, --dummy
			life      = 0x271,
			super     = 0x273,
		},
		read = {limit = memory.readword},
		max = {timeout = 60},
		pos = {
			bar_Y  = 0x2E,
			life_Y = 0x08,
		},
		limit_base_array = {
			[0x0E6A8E] = {"mvscur1"}, --971222
			[0x0E6BDC] = {"mvscar1", "mvscr1", "mvscjr1"}, --980112
			[0x0E7CD6] = {"mvsc", "mvsca", "mvscb", "mvsch", "mvscj", "mvscud", "mvscu"}, --980123
		},
	},
	{
		games  = {"sgemf"},
		active = 0xFFCBBC,
		player = 0xFF8400,
		offset = {
			level     = 0x17F,
			limit     = 0x19E,
			timeout   = 0x19F,
			duration  = 0x146,
			grace     = 0x147,
			dizzy     = 0x146, --dummy
			countdown = 0x146, --dummy
			life      = 0x041,
			super     = 0x195,
		},
		read = {duration = memory.readbyte},
		max = {
			timeout = 180,
			super   = 96,
		},
		pos = {
			bar_X   = 0x20,
			bar_Y   = 0x08,
			life_X  = 0xA0,
			life_Y  = 0x0C,
			super_X = 0x74,
			super_Y = 0x28,
		},
	},
	{
		games  = {"ringdest"},
		active = 0xFF72D2,
		player = 0xFF8000,
		offset = {
			level         = 0x0AD,
			limit         = 0x0CD,
			timeout       = 0x0AF,
			duration      = 0x0CE,
			grace         = 0x108,
			dizzy         = 0x0AB,
			countdown     = 0x0CE,
			life          = 0x02C,
			rage          = 0x0B1,
			rage_level    = 0x0B4,
			rage_limit    = 0x0C6,
			rage_timeout  = 0x0B2,
			rage_duration = 0x0B6,
		},
		read = {grace = memory.readword},
		max = {
			timeout       = 80,
			grace         = 360,
			life          = 278,
			rage_timeout  = 1000,
			rage_duration = 450,
		},
		pos = {
			bar_X       = 0x18,
			bar_Y       = 0x0C,
			life_X      = 0xA4,
			life_Y      = 0x30,
			rage_X      = 0x18,
			rage_Y      = 0xCC,
			rage_length = 0x80,
			rage_height = 0x04,
		},
		countdown_check = RINGDEST,
		super_mode = NO_SUPER,
	},
}

for n, g in ipairs(profile) do
	local last = profile[n-1]
	g.offset = g.offset or {}
	g.offset.space     = g.offset.space     or 0x400
	g.offset.level     = g.offset.level     or last.offset.level
	g.offset.limit     = g.offset.limit     or last.offset.limit
	g.offset.timeout   = g.offset.timeout   or last.offset.timeout
	g.offset.duration  = g.offset.duration  or last.offset.duration
	g.offset.dizzy     = g.offset.dizzy     or last.offset.dizzy
	g.offset.countdown = g.offset.countdown or last.offset.countdown
	g.offset.life      = g.offset.life      or last.offset.life
	g.offset.super     = g.offset.super     or last.offset.super
	g.max = g.max or {}
	g.max.timeout  = g.max.timeout  or last.max.timeout
	g.max.duration = g.max.duration or last.max.duration
	g.max.grace    = g.max.grace    or last.max.grace
	g.max.life     = g.max.life     or 144
	g.max.super    = g.max.super    or 144
	g.read = g.read or {}
	g.read.timeout  = g.read.timeout  or last.read.timeout
	g.read.duration = g.read.duration or memory.readword
	g.read.grace    = g.read.grace    or memory.readbyte
	g.read.life     = g.max.life < 0x100 and memory.readbyte or memory.readword
	g.pos = g.pos or {}
	g.pos.bar_X      = g.pos.bar_X      or last.pos.bar_X
	g.pos.bar_Y      = g.pos.bar_Y      or last.pos.bar_Y
	g.pos.bar_length = g.pos.bar_length or last.pos.bar_length
	g.pos.bar_height = g.pos.bar_height or last.pos.bar_height
	g.pos.life_X     = g.pos.life_X     or last.pos.life_X
	g.pos.life_Y     = g.pos.life_Y     or last.pos.life_Y
	g.pos.super_X    = g.pos.super_X    or last.pos.super_X
	g.pos.super_Y    = g.pos.super_Y    or last.pos.super_Y
	g.pos.claw_Y     = g.pos.claw_Y     or last.pos.claw_Y
	g.countdown_check = g.countdown_check or NORMAL
	g.super_mode      = g.super_mode or DRAW_SUPER
	g.claw_mode       = g.offset.mask_status and SFA or g.offset.claw_status and SF2 or NORMAL
	g.guard_mode      = g.offset.guard_level and true or false
	g.flip_mode       = g.offset.player_flip and true or false
	g.rage_mode       = g.offset.rage and true or false
	g.base_type       = g.nplayers and SFA or g.player_ptr and POINTER or DIRECT
	g.limit_type      = g.limit_type or g.hard_limit and HARD_LIMIT or g.limit_base_array and PTR_LIMIT_BASE or PTR_LIMIT
end

--------------------------------------------------------------------------------

local show_numbers = true
input.registerhotkey(1, function()
	show_numbers = not show_numbers
	print((show_numbers and "showing" or "hiding") .. " numbers")
end)


local game, known_game, active, nplayers, limit_read, center, level, timeout, duration
local player = {}

local get_limit = {
	[HARD_LIMIT] = function(p)
		return game.hard_limit
	end,

	[PTR_LIMIT] = function(p)
		return memory.readbyte(player[p].base + game.offset.limit)
	end,

	[PTR_LIMIT_BASE] = function(p)
		return memory.readword(game.limit_base + game.read.limit(player[p].base + game.offset.limit))
	end,

	[PTR_LIMIT_NO_BASE] = function(p)
		return 64
	end,

	[HSF2_LIMIT] = function(p)
		player[p].opponent = memory.readbyte(game.player + bit.band(p, 1)*game.offset.space + game.offset.char_mode)
		if player[p].opponent == 4 then --WW
			return 0x1E
		elseif player[p].opponent == 6 or player[p].opponent == 8 then --CE or HF
			return 0x1F
		else --Super or ST
			return memory.readword(game.limit_base + game.read.limit(player[p].base + game.offset.limit))
		end
	end,
}

--------------------------------------------------------------------------------

local function load_bar(p, ref)
	local b = {}
	b.val = ref.func(player[p].base + ref.offset)
	b.max = ref.max
	b.outer = b.val%b.max
	b.outer = ref.X + (b.outer == 0 and b.max or b.outer)/b.max*ref.length
	b.outer  = center + b.outer * player[p].side + player[p].tier
	b.inner  = player[p].inner + player[p].tier
	b.top    = player[p].bg[ref.position].top + 1
	b.bottom = player[p].bg[ref.position].bottom - 1
	if b.val > b.max then
		b.color = ref.long_color
		player[p].bg[ref.position].color = ref.normal_color
	else
		b.color = ref.normal_color
		player[p].bg[ref.position].color = color.bar.back
	end
	return b
end


local function set_text_X(base, p, str)
	return base - bit.band(p, 1) * 4 * string.len(str)
end


local get_player_base = {
	[DIRECT] = function(p)
		for p = 1, 2 do
			player[p].base = game.player + (p-1)*game.offset.space
		end
	end,

	[POINTER] = function(p)
		for p = 1, 2 do
			player[p].base = memory.readdword(game.player_ptr + (p-1)*game.offset.space)
		end
	end,

	[SFA] = function(p)
		for p = 1, nplayers do
			player[p].base = game.player + (p-1)*game.offset.space
			player[p].active = memory.readbyte(player[p].base) ~= 0
		end
		if player[3].active then --swap player 2-3 bases and active states for Dramatic Battle
			local temp_base = player[2].base
			player[2].base = player[3].base
			player[3].base = temp_base
			local temp_active = player[2].active
			player[2].active = player[3].active
			player[3].active = temp_active
		end
	end,
}


local get_countdown_status = {
	[NORMAL] = function(p)
		return player[p].dizzy and memory.readbyte(player[p].base + game.offset.countdown) ~= 0
	end,

	[SF2] = function(p)
		return memory.readbyte(player[p].base + game.offset.countdown) ~= 0
	end,

	[SFA] = function(p)
		return memory.readbyte(player[p].base + game.offset.countdown) == 0x12
	end,

	[SFA3] = function(p)
		local countdown = memory.readbyte(player[p].base + game.offset.countdown) == 0x0C
		if memory.readbyte(player[p].base + game.offset.knockdown) == 0 then
			countdown = false
			memory.writebyte(player[p].base + game.offset.dizzy, 0) --hack for R.Mika's 720+P
		end
		return countdown
	end,

	[RINGDEST] = function(p)
		return player[p].dizzy and memory.readbyte(player[p].base + game.offset.countdown) == 0
	end,
}


local get_super = {
	[NO_SUPER] = function(p)
		return ""
	end,

	[DRAW_SUPER] = function(p)
		return memory.readbyte(player[p].base + game.offset.super) .. "/" .. game.max.super
	end,

	[MODAL_SUPER] = function(p)
		player[p].super.active = memory.readbyte(player[p].base + game.offset.char_mode) == 0
		return player[p].super.active and memory.readbyte(player[p].base + game.offset.super) .. "/" .. game.max.super or ""
	end,
}


local get_claw = {
	[NORMAL] = function(p)
	end,

	[SF2] = function(p)
		if memory.readbyte(player[p].base + game.offset.char_id) ~= game.claw_id then
			player[p].claw_val = ""
		else
			if memory.readbyte(player[p].base + game.offset.claw_status) == 0 then
				player[p].claw_val = "-"
			else
				player[p].claw_val = 8 - memory.readbyte(player[p].base + game.offset.claw_level)
			end
			player[p].claw_val = "claw: " .. player[p].claw_val .. "/8"
		end
		player[p].claw_text_X = bit.band(p+1, 1) * (emu.screenwidth() - 4 * string.len(player[p].claw_val)) - 4 * player[p].side
	end,

	[SFA] = function(p)
		if memory.readbyte(player[p].base + game.offset.char_id) ~= game.claw_id then
			player[p].claw_val, player[p].mask_val = "", ""
		else
			if memory.readbyte(player[p].base + game.offset.claw_status) == 0 then
				player[p].claw_val = "-"
			else
				player[p].claw_val = 0xFF0000 + memory.readword(player[p].base + game.offset.claw_ptr)
				player[p].claw_val = memory.readbyte(player[p].claw_val + game.offset.item_level)
			end
			player[p].claw_val = "claw: " .. player[p].claw_val .. "/8"
			if memory.readbyte(player[p].base + game.offset.mask_status) == 0 then
				player[p].mask_val = "-"
			else
				player[p].mask_val = 0xFF0000 + memory.readword(player[p].base + game.offset.mask_ptr)
				player[p].mask_val = memory.readbyte(player[p].mask_val + game.offset.item_level)
			end
			player[p].mask_val = "mask: " .. player[p].mask_val .. "/32"
		end
		player[p].claw_text_X = bit.band(p+1, 1) * (emu.screenwidth() - 4 * string.len(player[p].claw_val)) - 4 * player[p].side
		player[p].claw_text_Y = bit.band(p-1, 2)/2 * -16 + game.pos.claw_Y
		player[p].mask_text_X = bit.band(p+1, 1) * (emu.screenwidth() - 4 * string.len(player[p].mask_val)) - 4 * player[p].side
		player[p].mask_text_Y = bit.band(p-1, 2)/2 * -16 + game.pos.claw_Y + 8
	end,
}


local get_guard = {
	[false] = function(p)
	end,

	[true] = function(p)
		player[p].guard_limit = memory.readbyte(player[p].base + game.offset.guard_limit)
		player[p].guard_val =
			player[p].guard_limit - memory.readbyte(player[p].base + game.offset.guard_level) .. "/" .. player[p].guard_limit
		player[p].guard_text_X =
			set_text_X(player[p].guard_X + math.floor(player[p].guard_limit/0x4)*0x4 * player[p].side, p, player[p].guard_val)
		player[p].guard_val = (not player[p].super.active or player[3].active or player[4].active) and "" or player[p].guard_val
	end,
}


local function get_player_flip(player)
	for _, v in ipairs({
		player.combo < 1,
		memory.readword(player.base + game.offset.status) ~= 0x0202,
		memory.readbyte(player.base + game.offset.countdown) > 0x08,
		memory.readbyte(player.base + game.offset.airborne) == 0x00,
	}) do
		if v then
			return false
		end
	end
	for _, v in ipairs(game.offset.player_flip) do
		if memory.readbyte(player.base + v) > 0 then
			return false
		end
	end
	for _, v in ipairs(game.offset.base_flip) do
		if memory.readbyte(game.base + v) > 0 then
			return false
		end
	end
	return true
end


local get_flip = {
	[false] = function(p)
	end,

	[true] = function(p)
		player[p].combo = memory.readbyte(player[p].base + game.offset.combo_count)
		if player[p].combo > player[p].combo_old then
			player[p].pseudocombo = player[p].pseudocombo or (player[p].combo > 1 and player[p].flip)
		elseif player[p].combo == 0 then
			player[p].pseudocombo = false
		end
		player[p].pseudocombo_text_X = player[p].pseudocombo_X + string.len(player[p].combo) * 8
		player[p].flip = get_player_flip(player[p])
		player[p].combo_old = player[p].combo
	end,
}


local get_rage = {
	[false] = function(p)
	end,

	[true] = function(p)
		rage_level.max = rage_level.func(player[p].base + game.offset.rage_limit)
		player[p].rage_level = load_bar(p, rage_level)
		if memory.readbyte(player[p].base + game.offset.rage) > 0 then
			player[p].rage_timeout = load_bar(p, rage_duration)
			player[p].rage_level.outer = center + (game.pos.rage_X + game.pos.rage_length) * player[p].side
			player[p].rage_level.val = "-"
		else
			player[p].rage_timeout = load_bar(p, rage_timeout)
		end

		player[p].rage_level.text_X = set_text_X(player[p].rage_text_X, p, player[p].rage_level.val .. "/" .. player[p].rage_level.max)
		player[p].rage_timeout.text_X = set_text_X(player[p].rage_text_X, p, player[p].rage_timeout.val)
	end,
}


local update_dizzy = {
	[false] = function()
	end,

	[true] = function()
		active = memory.readword(game.active) > 0
		get_player_base[game.base_type]()
		for p = 1, nplayers do
			player[p].dizzy = memory.readbyte(player[p].base + game.offset.dizzy) ~= 0
			player[p].countdown = get_countdown_status[game.countdown_check](p)
			player[p].grace = game.offset.grace and game.read.grace(player[p].base + game.offset.grace) > 0

			level.max = limit_read(p)
			player[p].level = load_bar(p, level)
			if player[p].countdown then
				player[p].timeout = load_bar(p, duration)
			elseif player[p].grace then
				player[p].timeout = load_bar(p, grace)
				player[p].timeout.val = player[p].opponent == 4 and 0 or player[p].timeout.val --Opponents of WW chars get no grace
			else
				player[p].timeout = load_bar(p, timeout)
			end

			if player[p].dizzy or player[p].countdown then
				player[p].level.outer = center + (game.pos.bar_X + game.pos.bar_length) * player[p].side + player[p].tier
				player[p].level.val = "-"
			end

			player[p].level.text_X = set_text_X(player[p].text_X, p, player[p].level.val .. "/" .. player[p].level.max)
			player[p].timeout.text_X = set_text_X(player[p].text_X, p, player[p].timeout.val)

			player[p].life.val = game.read.life(player[p].base + game.offset.life)
			player[p].life.val = (player[p].life.val > game.max.life and "-" or player[p].life.val) .. "/" .. game.max.life
			player[p].life.text_X = set_text_X(player[p].life_X, p, player[p].life.val)

			player[p].super.val = get_super[game.super_mode](p)
			player[p].super.text_X = set_text_X(player[p].super_X, p, player[p].super.val)

			get_claw[game.claw_mode](p)
			get_guard[game.guard_mode](p)
			get_flip[game.flip_mode](p)
			get_rage[game.rage_mode](p)
		end
	end,
}

emu.registerafter( function()
	update_dizzy[known_game]()
end)

--------------------------------------------------------------------------------

local function pixel(x1, y1, color, dx, dy)
	gui.pixel(x1 + dx, y1 + dy, color)
end

local function line(x1, y1, x2, y2, color, dx, dy)
	gui.line(x1 + dx, y1 + dy, x2 + dx, y2 + dy, color)
end

local function box(x1, y1, x2, y2, color, dx, dy)
	gui.box(x1 + dx, y1 + dy, x2 + dx, y2 + dy, color)
end

local draw_stun = {
	[false] = function(x, y)
	end,

	[true] = function(x, y)
		local f, s, b = color.STUN.fill, color.STUN.shade, color.STUN.border
		box(0,1,6,6, b, x, y)
		line(7,3,7,5, b, x, y)
		box(1,0,28,2, b, x, y)
		box(9,3,12,6, b, x, y)
		box(14,3,28,6, b, x, y)
		box(1,1,6,5, f, x, y)
		line(3,2,6,2, b, x, y)
		line(1,4,4,4, b, x, y)
		pixel(1,1, s, x, y)
		pixel(1,3, s, x, y)
		pixel(6,3, s, x, y)
		pixel(6,5, s, x, y)
		line(8,1,13,1, f, x, y)
		box(10,2,11,5, f, x, y)
		box(15,1,20,5, f, x, y)
		box(17,1,18,4, b, x, y)
		pixel(15,5, s, x, y)
		pixel(20,5, s, x, y)
		box(22,1,23,5, f, x, y)
		box(26,1,27,5, f, x, y)
		line(24,2,25,3, f, x, y)
		line(24,3,25,4, f, x, y)
	end,
}


local draw_bar = {
	[false] = function(bar)
	end,

	[true] = function(bar)
		gui.box(bar.inner, bar.top, bar.outer, bar.bottom, bar.color, bar.border)
	end,
}


local draw_claw = {
	[NORMAL] = function(p)
	end,

	[SF2] = function(p)
		gui.text(player[p].claw_text_X, game.pos.claw_Y, player[p].claw_val, color.text.claw)
	end,

	[SFA] = function(p)
		gui.text(player[p].claw_text_X, player[p].claw_text_Y, player[p].claw_val, color.text.claw)
		gui.text(player[p].mask_text_X, player[p].mask_text_Y, player[p].mask_val, color.text.claw)
	end,
}


local draw_guard = {
	[false] = function(p)
	end,

	[true] = function(p)
		gui.text(player[p].guard_text_X, game.pos.guard_Y, player[p].guard_val, color.text.guard)
	end,
}


local draw_flip = {
	[false] = function(p)
	end,

	[true] = function(p)
		if player[p].flip then
			gui.text(player[p].flip_text_X, player[p].life.text_Y, "!")
		end
		if player[p].pseudocombo then
			gui.text(player[p].pseudocombo_text_X, game.pos.pseudocombo_Y, "*")
		end
	end,
}


local draw_rage = {
	[false] = function(p)
	end,

	[true] = function(p)
		draw_bar[true](player[p].bg[3])
		draw_bar[true](player[p].bg[4])
		draw_bar[player[p].rage_level.val ~= 0](player[p].rage_level)
		draw_bar[player[p].rage_timeout.val ~= 0](player[p].rage_timeout)
		if show_numbers then
			gui.text(player[p].rage_level.text_X, game.pos.rage_Y - 2, player[p].rage_level.val .. "/" .. player[p].rage_level.max)
			gui.text(player[p].rage_timeout.text_X, game.pos.rage_Y + 6, player[p].rage_timeout.val)
		end
	end,
}


local draw_player_bars = {
	[false] = function(p)
	end,

	[true] = function(p)
		draw_bar[true](player[p].bg[1])
		draw_bar[true](player[p].bg[2])
		draw_bar[player[p].level.val ~= 0](player[p].level)
		draw_bar[player[p].timeout.val ~= 0](player[p].timeout)
		draw_stun[(player[p].dizzy or player[p].countdown) and bit.band(emu.framecount(), 2) > 0](player[p].stun_X, player[p].stun_Y)
		draw_rage[game.rage_mode](p)
	end,
}


local draw_player_text = {
	[false] = function(p)
	end,

	[true] = function(p)
		gui.text(player[p].level.text_X, game.pos.bar_Y - 2, player[p].level.val .. "/" .. player[p].level.max)
		gui.text(player[p].timeout.text_X, game.pos.bar_Y + 6, player[p].timeout.val)
		gui.text(player[p].life.text_X, player[p].life.text_Y, player[p].life.val, color.text.life)
		gui.text(player[p].super.text_X, game.pos.super_Y, player[p].super.val, color.text.super)
		draw_guard[game.guard_mode](p)
		draw_flip[game.flip_mode](p)
		draw_claw[game.claw_mode](p)
	end,
}


local draw_dizzy = {
	[false] = function()
	end,

	[true] = function()
		for p = 1, nplayers do
			draw_player_bars[player[p].active](p)
		end
		for p = 1, nplayers do
			draw_player_text[show_numbers and player[p].active](p)
		end
	end,
}


gui.register(function()
	gui.clearuncommitted()
	draw_dizzy[known_game and active]()
end)

--------------------------------------------------------------------------------

local function whatversion(game)
	for base,version_set in pairs(game.limit_base_array) do
		for _,version in ipairs(version_set) do
			if emu.romname() == version then
				return base
			end
		end
	end
	print("unrecognized version (" .. emu.romname() .. "): limits will be wrong")
	limit_read = get_limit[PTR_LIMIT_NO_BASE]
	return nil
end


local function whatgame()
	game = nil
	for _, module in ipairs(profile) do
		for _, shortname in ipairs(module.games) do
			if emu.romname() == shortname or emu.parentname() == shortname then
				print("drawing " .. emu.romname() .. " dizzy meters")
				game = module
				nplayers = game.nplayers or 2
				center = emu.screenwidth and emu.screenwidth()/2 or 128
				limit_read = get_limit[game.limit_type]
				if game.limit_base_array then
					game.limit_base = whatversion(game)
				end
				for p = 1, nplayers do
					player[p] = {bg = {}, timeout = {}, level = {}, duration = {}, life = {}, super = {}}
					player[p].active = true
					player[p].side = p%2 == 1 and -1 or 1
					player[p].tier = bit.band(p-1, 2)/2 * ((game.pos.bar_X + game.pos.bar_length) * player[p].side)
					player[p].inner = center + game.pos.bar_X * player[p].side
					for n = 1, 2 do
						player[p].bg[n] = {
							inner  = center + (game.pos.bar_X - 1) * player[p].side + player[p].tier,
							top    = game.pos.bar_Y + game.pos.bar_height*(n-1),
							outer  = center + (game.pos.bar_X + game.pos.bar_length + 1) * player[p].side + player[p].tier,
							bottom = game.pos.bar_Y + game.pos.bar_height*n,
							X      = game.pos.bar_X,
							length = game.pos.bar_length,
							border = color.bar.border,
						}
					end
					player[p].stun_X = player[p].inner + game.pos.bar_length/2 * player[p].side + player[p].tier - 13
					player[p].stun_Y = player[p].bg[1].top - 1
					player[p].text_X = center + (game.pos.bar_X + game.pos.bar_length + 4) * player[p].side + player[p].tier
					player[p].life_X = center + game.pos.life_X * player[p].side
					player[p].life.text_Y = game.pos.life_Y - bit.band(p-1, 2)/2*8
					player[p].super_X = center + game.pos.super_X * player[p].side
					player[p].guard_X = game.guard_mode and center + game.pos.guard_X * player[p].side
					if game.flip_mode then
						player[p].pseudocombo_X = center + game.pos.pseudocombo_X * -player[p].side + 0x14
						player[p].flip_text_X = player[p].life_X - bit.band(p, 1) * 4 - player[p].side * 8
						player[p].combo_old = 0
					end
				end
				level = {
					offset       = game.offset.level,
					func         = game.read.timeout,
					X            = game.pos.bar_X,
					length       = game.pos.bar_length,
					position     = 1,
					normal_color = color.bar.level,
					long_color   = color.bar.long_level,
				}
				timeout = {
					max          = game.max.timeout,
					offset       = game.offset.timeout,
					func         = game.read.timeout,
					X            = game.pos.bar_X,
					length       = game.pos.bar_length,
					position     = 2,
					normal_color = color.bar.timeout,
					long_color   = color.bar.long_timeout,
				}
				duration = {
					max          = game.max.duration,
					offset       = game.offset.duration,
					func         = game.read.duration,
					X            = game.pos.bar_X,
					length       = game.pos.bar_length,
					position     = 2,
					normal_color = color.bar.duration,
					long_color   = color.bar.long_duration,
				}
				grace = {
					max          = game.max.grace,
					offset       = game.offset.grace,
					func         = game.read.grace,
					X            = game.pos.bar_X,
					length       = game.pos.bar_length,
					position     = 2,
					normal_color = color.bar.grace,
					long_color   = color.bar.long_grace,
				}
				if game.rage_mode then
					for p = 1, nplayers do
						player[p].rage_level, player[p].rage_timeout = {}, {}
						for n = 3, 4 do
							player[p].bg[n] = {
								inner  = center + (game.pos.rage_X - 1) * player[p].side,
								top    = game.pos.rage_Y + game.pos.rage_height*(n-3),
								outer  = center + (game.pos.rage_X + game.pos.rage_length + 1) * player[p].side,
								bottom = game.pos.rage_Y + game.pos.rage_height*(n-2),
								color  = color.bar.back,
								border = color.bar.border,
							}
						end
						player[p].rage_text_X = center + (game.pos.rage_X + game.pos.rage_length + 8) * player[p].side
					end
					rage_level = {
						offset       = game.offset.rage_level,
						func         = memory.readword,
						X            = game.pos.rage_X,
						length       = game.pos.rage_length,
						position     = 3,
						normal_color = color.bar.level,
						long_color   = color.bar.long_level,
					}
					rage_timeout = {
						max          = game.max.rage_timeout,
						offset       = game.offset.rage_timeout,
						func         = memory.readword,
						X            = game.pos.rage_X,
						length       = game.pos.rage_length,
						position     = 4,
						normal_color = color.bar.timeout,
						long_color   = color.bar.long_timeout,
					}
					rage_duration = {
						max          = game.max.rage_duration,
						offset       = game.offset.rage_duration,
						func         = game.read.duration,
						X            = game.pos.rage_X,
						length       = game.pos.rage_length,
						position     = 4,
						normal_color = color.bar.duration,
						long_color   = color.bar.long_duration,
					}
				end
				known_game = true
				update_dizzy[known_game]()
				return
			end
		end
	end
	print("not prepared for " .. emu.romname() .. " dizzy bars")
	known_game = false
end


emu.registerstart( function()
	whatgame()
end)