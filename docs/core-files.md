# 核心文件职责说明

本文只覆盖当前工程里“值得维护、值得理解”的核心文件，不逐个展开自动生成物和纯导出资源。

## 一、入口与运行骨架

### `table/mapinfo.ini`

- 定义地图的主入口脚本名。
- 决定游戏模式、装备模式和大厅模式分别加载哪个主文件。
- 是排查“为什么没走到某个入口”的第一站。

### `config.ini`

- 定义地图运行时参数。
- 包括游戏阶段时长、玩家槽配置、调试用户和 AI 槽位。
- 当你怀疑测试行为、玩家人数、调试账号或阶段流程异常时，优先看这里。

### `project/map_settings.json`

- 定义工程级元信息。
- 例如工程包名 `p_3b4f`、模板 `single_simple_ts`、触发器模式 `V2`、API 版本。
- 它决定这个地图工程使用哪套编辑器能力和基础模板。

## 二、服务端入口

### `script/main.lua`

- 服务端主入口。
- 负责加载场景、初始化缓存、注册自定义结构体创建器、加载公共库。
- 最后 `require "trigger_module_main_1"` 和 `require "trigger_validator"`，把触发器逻辑挂进运行时。
- 还会调用 `base.game.init_units()` 初始化地编单位。

### `script/equipment_main.lua`

- 服务端装备模式入口。
- 整体结构和 `script/main.lua` 接近，但在加载触发器时先将 `base.trig.add_event_disabled = true`，随后再恢复。
- 当地图存在装备模式或副玩法模式时，应和主模式入口一起排查。

### `script/package.json`

- 服务端脚本目录的构建说明。
- 使用 `typescript-to-lua`，支持 `build` 和 `dev`。
- 说明这里的 TS 文件会被编译成 Lua 运行。

### `script/tsconfig.json`

- 服务端 TSTL 配置。
- 明确参与编译的文件：`lua_declare.d.ts`、`trigger_validator.ts`、`trigger_module_main_1.ts`。
- `types` 中引用了编辑器安装目录里的公共脚本库，包括 `smallcard_store`，这也是当前仓库看不到库内部实现的原因。

### `script/trigger_module_main_1.ts`

- 服务端触发器逻辑的核心 TS 源。
- 当前可见逻辑包括：游戏开始、按键响应、终点区域、血量更新、自定义事件接收。
- 商店重开链路里最关键的一段就在这里：接收到 `客户端点击商店` 后调用 `smallcard_store.打开商店(...)`。

### `script/trigger_module_main_1.lua`

- 上述 TS 文件编译后的 Lua 产物。
- 运行时实际执行，但通常不建议直接改。
- 若这里和 TS 不一致，优先以 TS 和源触发器为准查问题。

## 三、客户端入口与 UI

### `ui/script/main.lua`

- 客户端主入口。
- 负责加载本地图本地化、初始化缓存、加载 GUI 页面包、创建 `MainPage`。
- 同时加载 `smallcard_store`、`smallcard_inventory` 等客户端库，并挂接客户端触发器。

### `ui/script/equipment_main.lua`

- 客户端装备模式入口。
- 结构与 `ui/script/main.lua` 相同，也是装备模式排查的起点。

### `ui/script/gui/page/init.lua`

- GUI 页面注册入口。
- 维护当前地图可加载的页面名列表，如 `MainPage`、物品信息页、自定义拾取页等。
- 想知道某个页面是否属于当前地图 UI，可以从这里查。

### `ui/script/gui/page/MainPage/template.lua`

- 主页面模板。
- 定义整个 `MainPage` 的控件层级、显示状态和点击事件绑定。
- 这里能看到：
  - 全屏 `MainPage` 面板绑定了 `单击商店按钮`
  - `smallcard_store.商店_商店面板` 被直接挂进页面
  - 商店按钮文本和显示面板等控件都在这里
- 文件头已标记会被 GUI 编辑器覆盖，不适合作为手改首选。

### `ui/script/gui/ui_response/单击商店按钮.lua`

- 商店按钮点击的 Lua 转发层。
- 内容很薄，只是把点击回调转给 `validator.validator_34975774`。
- 若点击没反应，这里是 UI 事件链路里的中间节点。

### `ui/script/trigger_validator.ts`

- 客户端 validator 逻辑集合。
- 既包含一些显示/属性读取逻辑，也包含 UI 点击触发的行为函数。
- `validator_34975774` 是商店按钮点击逻辑，目前只看到创建 `客户端点击商店` 事件对象。

### `ui/script/trigger_module_main_1.ts`

- 客户端触发器逻辑核心 TS 源。
- 当前可见内容主要包括：
  - 监听 `更新显示血量` 事件并刷新界面文本
  - 定义客户端事件 `客户端点击商店`
- 这里的 `客户端点击商店.autoForward = true`，和服务端同名事件定义需要一起看。

## 四、触发器源与数据源

### `src/trigger_module.json`

- 服务端触发器模块的总清单。
- 用来描述这个地图工程有哪些触发器、变量、方法和自定义事件。
- 适合在宏观上确认“这个工程到底实现了哪些服务端逻辑”。

### `src/data/triggers/接收客户端打开商店.json`

- 服务端“接收客户端打开商店”触发器的可视化源文件。
- 它注册 `客户端点击商店` 事件，并调用 `smallcard_store` 的“打开商店”函数。
- 如果想判断编译后的 TS/Lua 是否可靠，应该回到这里核对源数据。

### `ui/src/gui/ui_response/单击商店按钮.lua`

- 客户端商店按钮响应的可视化源定义。
- 这里能看到 GUI 编辑器实际保存的动作：当前主要是构造 `客户端点击商店` 事件对象。
- 它是 `ui/script/gui/ui_response/单击商店按钮.lua` 的源头之一。

## 五、商店与本地化数据

### `editor/table/entry_data/loot_pool/游戏商店/entry_data.ini`

- 当前地图商店内容的真实数据源。
- 定义了：
  - 商店页签
  - 货币类型与图标
  - 商品列表
  - 物品类型和价格
- 当前工程里运行时打开的商店就是这份 `游戏商店` 数据，而不是库自带示例。

### `ui/script/obj/localization/localization.lua`

- 地图侧本地化编译产物。
- 包含项目自身条目文本，也能看到 `smallcard_store` 相关本地化键值。
- 当你感觉“商店名字、页签、文案和编辑器里不一致”时，这里是辅助排查点。

## 六、怎么用这份清单排问题

### 入口没生效

按这个顺序查：

1. `table/mapinfo.ini`
2. `script/main.lua` / `ui/script/main.lua`
3. `src/trigger_module.json`

### UI 按钮没反应

按这个顺序查：

1. `ui/script/gui/page/MainPage/template.lua`
2. `ui/script/gui/ui_response/单击商店按钮.lua`
3. `ui/script/trigger_validator.ts`
4. `ui/script/trigger_module_main_1.ts`
5. `script/trigger_module_main_1.ts`

### 商店内容不对

按这个顺序查：

1. `script/trigger_module_main_1.ts` 里实际传入的 `loot_pool`
2. `editor/table/entry_data/loot_pool/游戏商店/entry_data.ini`
3. `ui/script/obj/localization/localization.lua`

## 七、最常见的误区

- 只改 `ui/script/gui/page/MainPage/template.lua`，却忘了它会被 GUI 编辑器覆盖。
- 只看 `trigger_module_main_1.lua`，没回到 `src/data/triggers/*.json` 找源头。
- 把库自带的 `smallcard_store` 示例商店当成当前地图实际打开的商店。
- 以为当前仓库包含 `smallcard_store` 内部实现，实际上 `tsconfig.json` 显示它来自编辑器安装目录。
