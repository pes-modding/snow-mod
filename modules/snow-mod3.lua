--[[
Snow/Rain switcher, version 3.1
idea and content: Ethan2, kilay, Wolves85
artwork: Wolves85, -cRoNoS-
module by: juce

Notes: make sure to register this module ABOVE StadiumServer.lua and BallServer.lua in sider.ini
--]]

local snowroot = ".\\content\\snow-mod3\\"
local snow

local inifile = ".\\snow-mod3.ini"
local ini
local no_lines
local use_orange_ball

local orange_ball = {
    ["\\ball%d%d%d\\ball.*%.model"]  = "common\\render\\model\\ball\\ball103\\ball.model",
    ["\\ball%d%d%d\\ball.*%.mtl"]    = "common\\render\\model\\ball\\ball103\\ball.mtl",
    ["\\ball%d%d%d\\ball.*_c%.dds"]  = "common\\render\\model\\ball\\ball103\\ball_c.dds",
    ["\\ball%d%d%d\\ball.*_n%.dds"]  = "common\\render\\model\\ball\\ball103\\ball_n.dds",
    ["\\ball%d%d%d\\ball.*_sr%.dds"] = "common\\render\\model\\ball\\ball103\\ball_sr.dds",
}

local pitch_files = {
    ["\\turf_w_color.*%.dds"] = "turf_w_color.dds",
    ["\\ground_c.*%.dds"] = "ground_c.dds",
    ["\\pitch_nrm.*%.dds"] = "pitch_nrm.dds",
    ["\\weather_lbm.*%.dds"] = "weather_lbm.dds",
    ["\\turnflen.*%.dds"] = "weather_lbm.dds",
    ["\\pitch_bsm.*%.dds"] = "pitch_bsm.dds",
    ["\\tex_rain_particle_00.dds"] = "tex_snow_particle_00.dds",
    ["\\tex_rain_screen_00.dds"] = "tex_snow_screen_00.dds",
    ["\\tex_rain_particle_01.dds"] = "tex_snow_particle_01.dds",
    ["\\tex_rain_screen_01.dds"] = "tex_snow_screen_01.dds",
}

local lines_pattern = "\\line_alp.*%.dds"
local lines_repl = "line_alp.dds"

local snow_types = {
    light = {
        [0] = "snow-light-day",
        [1] = "snow-light-night",
    },
    heavy = {
        [0] = "snow-heavy-day",
        [1] = "snow-heavy-night",
    },
}

function read_ini(ctx)
    if inifile:sub(1,1) == "." then
        inifile = ctx.sider_dir .. inifile
    end
    local t = {}
    for line in io.lines(inifile) do
        local name, value = string.match(line, "^([-%w_.]+)%s*=%s*([-%d.]+)")
        if name and value then
            t[name] = tonumber(value) or value
            log(string.format("%s: %s", name, t[name]))
        end
    end
    return t
end

function make_key(ctx, filename)
    if snow then
        if use_orange_ball == 1 then
            for pattern,repl in pairs(orange_ball) do
                if string.match(filename, pattern) then
                    return repl
                end
            end
        end
        for pattern,repl in pairs(pitch_files) do
            if string.match(filename, pattern) then
                return string.format("%s\\%s", snow, repl)
            end
        end
        if no_lines == 1 then
            if string.match(filename, lines_pattern) then
                return string.format("%s\\%s", snow, lines_repl)
            end
        end
        return filename
    end
end

function get_filepath(ctx, filename, key)
    if key then
        return snowroot .. key
    end
end

function get_ball_name(ctx, ballname)
    if snow and ini.use_orange_ball == 1 then
        local name = "Adidas Orange Stars"
        log(string.format("switching ball name: %s --> %s", ballname, name))
        return name
    end
end

function after_set_conditions(ctx)
    ini = read_ini(ctx)
    snow = nil
    no_lines = nil
    use_orange_ball = nil
    if ctx.season == 1 and ctx.weather == 1 then
        -- it is winter and bad weather, so choose randomly: snow or rain
        log("======[ WINTER/RAIN ]======")
        local n = math.random()
        if n >= (1 - ini.chance_of_snow) then
            -- it is snow. Now decide: light or heavy
            local m = math.random()
            if m >= (1 - ini.chance_of_heavy_snow) then
                snow = snow_types.heavy[ctx.timeofday] or ""
            else
                snow = snow_types.light[ctx.timeofday] or ""
            end
            no_lines = ini[snow .. ".no_lines"]
            use_orange_ball = ini[snow .. ".no_lines"]
            log(string.format("snow: %s (n=%0.3f, m=%0.3f)", snow, n, m))
            log(string.format("snow settings: no_lines:%s, use_orange_ball:%s", no_lines, use_orange_ball))
        else
            log(string.format("no snow, just rain. (n=%0.3f)", n))
        end
    end
end

function init(ctx)
    if snowroot:sub(1,1) == "." then
        snowroot = ctx.sider_dir .. snowroot
    end
    math.randomseed(os.time())  -- seed random generator
    ctx.register("after_set_conditions", after_set_conditions)
    ctx.register("after_set_conditions_for_replay", after_set_conditions)
    ctx.register("livecpk_make_key", make_key)
    ctx.register("livecpk_get_filepath", get_filepath)
    ctx.register("get_ball_name", get_ball_name)
end

return { init = init }
