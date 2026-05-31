# 星火地图工程总览

## 工程定位

当前目录 `yesicandothistafang` 不是星火编辑器主程序源码，而是一个星火地图工程资源包。

这个工程的运行方式不是常规前端应用，而是由星火引擎加载：

- 服务端 Lua 入口
- 客户端 Lua 入口
- 触发器可视化源数据
- TypeScript to Lua 编译产物
- 编辑器导出的数编与场景资源

## 启动入口

地图主入口由 `table/mapinfo.ini` 指定：

- `CustomMainAsGame = 'main'`
- `CustomMainAsEquipment = 'equipment_main'`
- `CustomMainAsLobby = 'main'`

对应文件如下：

- `script/main.lua`：服务端主入口
- `ui/script/main.lua`：客户端主入口
- `script/equipment_main.lua`：服务端装备模式入口
- `ui/script/equipment_main.lua`：客户端装备模式入口

## 目录分层

### 运行与入口

- `script/`：服务端运行脚本，包含 `main.lua`、触发器编译产物、TSTL 配置。
- `ui/script/`：客户端运行脚本，包含 `main.lua`、GUI 页面、客户端触发器编译产物。
- `scene/`：场景配置、区域、单位保存数据。

### 可维护源

- `src/`：服务端触发器的源数据，核心是 `trigger_module.json` 与 `data/` 下的触发器、变量、方法定义。
- `ui/src/`：客户端触发器与 UI 响应的源数据。
- `project/`：工程级设置，如模板、触发器模式、API 版本。
- `table/`：地图级运行配置，如 `mapinfo.ini`。
- `config.ini`：地图运行时参数，如阶段、玩家槽和调试设置。

### 编辑器导出与资源

- `editor/table/`：编辑器导出的数编数据，包含单位、物品、商店 `loot_pool` 等条目。
- `i18n/`：地图级本地化 JSON。
- `ui/image/`：UI 图片资源元数据。
- `game_hud/`：血条、飘字等 HUD 配置。
- `ref/`：编辑器引用、版本与对象索引信息。

## 文件修改优先级

推荐按下面顺序判断应该改哪里：

1. 先改 `src/` 或 `ui/src/` 里的可视化源数据。
2. 再改 `project/`、`table/`、`config.ini` 这类工程配置。
3. 若是脚本逻辑，优先改明确可维护的 TS/Lua 源，再确认是否需要重新生成。
4. 非必要不要直接改明显由编辑器或编译器产出的文件。

## 哪些文件通常不要直接改

以下文件大多属于自动生成或导出产物，手改后可能被覆盖：

- `ui/script/gui/page/**/template.lua`
- `ui/script/gui/page/init.lua`
- `script/trigger_module_main_1.lua`
- `ui/script/trigger_module_main_1.lua`
- `script/trigger_validator.lua`
- `ui/script/trigger_validator.lua`
- `*.lua.map`
- `*.diagnostic`
- `ui/script/gui/page_bak/`

其中：

- `ui/script/gui/page/**/template.lua` 文件头已明确标注 `WOULD BE OVERWRITTEN BY GUI-EDITOR`。
- `trigger_module_main_1.lua` 与 `trigger_validator.lua` 对应 TS 编译产物，通常应回溯到源头确认是否应改 `src/`、`ui/src/` 或 TS 文件。

## 这个工程的构建方式

服务端与客户端脚本目录都带有独立的 TSTL 配置：

- `script/package.json`
- `ui/script/package.json`
- `script/tsconfig.json`
- `ui/script/tsconfig.json`

它们说明：

- 使用 `typescript-to-lua`
- 入口是 `trigger_module_main.lua`
- `files` 里包含 `trigger_validator.ts` 与 `trigger_module_main_1.ts`
- 依赖的公共库和 `smallcard_store` 等脚本库不在当前地图仓库，而在编辑器安装目录的 `script_libs`

这意味着：当前仓库只包含地图侧接线和数据，不包含 `smallcard_store` 这类库的内部源码。

## 维护时的阅读顺序

建议按下面顺序追问题：

1. `table/mapinfo.ini`：确认主入口和运行模式。
2. `script/main.lua`、`ui/script/main.lua`：确认加载了哪些库、哪些触发器、哪些 GUI 页面。
3. `src/trigger_module.json` 与 `src/data/**`：确认服务端触发器和自定义事件定义。
4. `ui/script/gui/page/**` 与 `ui/src/**`：确认 UI 页面、点击行为和客户端响应。
5. `editor/table/entry_data/**`：确认商店、物品、单位等具体数据源。

## 商店相关的特殊点

当前工程里的商店不是单一文件完成的，而是由四段拼起来：

1. UI 点击入口
2. 客户端事件
3. 服务端接收并调用 `smallcard_store`
4. `editor/table/entry_data/loot_pool/游戏商店/` 提供商店数据

如果只改其中一段，很容易出现“按钮点了没反应”或“商店内容和预期不一致”。
