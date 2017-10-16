-- Gameplay changer, version 3.0
-- Notes: make sure to register this module AFTER(BELOW) snow-mod3.lua in sider.ini

local gameplay_default = "gameplay-default.ini"
local gameplay_files_map = {
    ["snow-light-day"] = "gameplay-snow-light-day.ini",
    ["snow-light-night"] = "gameplay-snow-light-night.ini",
    ["snow-heavy-day"] = "gameplay-snow-heavy-day.ini",
    ["snow-heavy-night"] = "gameplay-snow-heavy-night.ini",
}

function load_gameplay_settings(ctx, filename)
    local t = {}
    log("Using gameplay preset: " .. filename)
    for line in io.lines(ctx.sider_dir .. "\\" .. filename) do
        local name, value = string.match(line, "^([%w_]+)%s*=%s*([-%d.]+)")
        if name and value then
            t[name] = tonumber(value)
        end
    end
    return t
end

function set_gameplay(ctx, filename)
    local settings = load_gameplay_settings(ctx, filename)
    for k,v in pairs(settings) do
        local old_v = gameplay[k]
        gameplay[k] = v
        log(string.format("%s: %s --> %s", k, old_v, gameplay[k]))
    end
end

function after_set_conditions(ctx, options)
    if ctx.snow then
        set_gameplay(ctx, gameplay_files_map[ctx.snow])
    else
        set_gameplay(ctx, gameplay_default)
    end
end

function init(ctx)
    ctx.register("after_set_conditions", after_set_conditions)
    ctx.register("after_set_conditions_for_replay", after_set_conditions)
end

return { init = init }
