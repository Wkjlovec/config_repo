local hyper = { "ctrl", "alt" }

local apps = {
  { key = "1", name = "Google Chrome" },
  { key = "2", name = "iTerm" },
  { key = "3", name = "IntelliJ IDEA" },
  { key = "4", name = "Cursor" },
  { key = "5", name = "Zed" },
}

local function focusOrLaunch(appName)
  local app = hs.application.find(appName)
  if app then
    app:activate()
  else
    hs.application.launchOrFocus(appName)
  end
end

for _, app in ipairs(apps) do
  hs.hotkey.bind(hyper, app.key, function()
    focusOrLaunch(app.name)
  end)
end

local layouts = {
  ["Google Chrome"] = { x = 0, y = 0, w = 0.58, h = 1 },
  ["iTerm"] = { x = 0.58, y = 0, w = 0.42, h = 0.5 },
  ["IntelliJ IDEA"] = { x = 0, y = 0, w = 1, h = 1 },
  ["Cursor"] = { x = 0, y = 0, w = 1, h = 1 },
  ["Zed"] = { x = 0.58, y = 0.5, w = 0.42, h = 0.5 },
}

local function applyLayout()
  local screen = hs.screen.mainScreen()
  if not screen then
    return
  end

  local frame = screen:workarea()
  for appName, unit in pairs(layouts) do
    local app = hs.application.find(appName)
    if app then
      local win = app:mainWindow()
      if win then
        win:setFrame({
          x = frame.x + frame.w * unit.x,
          y = frame.y + frame.h * unit.y,
          w = frame.w * unit.w,
          h = frame.h * unit.h,
        })
      end
    end
  end
end

hs.hotkey.bind(hyper, "0", applyLayout)

hs.alert.show("Hammerspoon config loaded")
