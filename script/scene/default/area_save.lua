--- origin_lua ---
_G.present = _G.present or {}
_G.present['default'] = {point = {}, line = {}, rect = {}, circle = {}, margin = {}, rank = {}, description = {}, invisible = {}, unselectable = {}, link = {}}
local present = _G.present['default']
present.line["第一关路线"] = base.line({base.scene_point(2656.0, 384.0, nil, "default"), base.scene_point(2656.0, 1536.0, nil, "default"), base.scene_point(1664.0, 1536.0, nil, "default"), base.scene_point(1664.0, 2496.0, nil, "default"), base.scene_point(2624.0, 2496.0, nil, "default"), base.scene_point(2624.0, 3648.0, nil, "default")})
present.rect["第一关终点"] = base.rect(base.point(2528.0, 3744.0), base.point(2720.0, 3552.0), "default")
present.rank["rank"] = {["第一关路线"] = "第一关场景/6", ["第一关终点"] = "第一关场景/7", }
present.description["description"] = {["第一关路线"] = "", ["第一关终点"] = "", }
present.invisible["invisible"] = {["第一关路线"] = "", ["第一关终点"] = "", }
present.unselectable["unselectable"] = {["第一关路线"] = "", ["第一关终点"] = "", }
present.link["link"] = {}
