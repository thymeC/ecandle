# eCandle · 电子生日蜡烛

没有打火机也能过生日：多平台点燃蛋糕蜡烛，用**麦克风吹灭**，全部熄灭后有庆祝特效；可开关《生日快乐》背景音乐。

仓库布局对齐 **[sudocool / 数独道场](https://github.com/thymeC/sudocool)**：同一产品、多平台在 `app/`，Web 试玩源码在 `web/`，由 **[digital-life](https://github.com/thymeC/digital-life-from-scratch)** 门户嵌入 `/play/ecandle`。

## 目录

| 路径 | 说明 |
|------|------|
| `app/ios/` | SwiftUI，Xcode 15+，iOS 16+ |
| `app/android/` | Android 工程（待补充） |
| `app/harmony/` | HarmonyOS 工程（待补充） |
| `web/` | 静态 Web（麦克风 + 特效） |
| `design/` | 图标 / 截图源（供 digital-life `sync:media`） |
| `docs/monorepo-layout.md` | 与 sudocool、digital-life 的关系 |

## 功能（Web / 原生共用规格）

- **多根蜡烛**或**数字蜡烛**（按年龄，如 25 → 2 和 5）
- 一键点燃，或点击单根蜡烛
- **麦克风吹气**：检测音量，逐根吹灭
- 全部吹灭：**彩纸特效** + 「生日快乐」
- **背景音乐**开关（Web Audio 合成《生日快乐》旋律）

## iOS

1. 打开 `app/ios/Ecandle.xcodeproj`
2. 设置 Signing Team，Run 到真机（吹气需真机麦克风）
3. 补全 `Assets` 中的 App Icon（上架前）

## Web（本地）

```bash
cd web && python3 -m http.server 8080
# http://localhost:8080
```

麦克风需要 **HTTPS** 或 **localhost**。

## 嵌入 digital-life

```bash
pnpm build:web ~/repo/ecandle ecandle   # 产物 → public/embed/ecandle/
pnpm dev                                 # /play/ecandle
```

详见 digital-life 的 `content/apps/ecandle.md` 与 `scripts/build-static-web.sh`。

## 技术说明（Web）

- HTML / CSS / 原生 JavaScript（无构建步骤）
- Web Audio API：音乐与麦克风电平
- Canvas：confetti 粒子

## Support

可参考 [sudocool-support](https://github.com/thymeC/sudocool-support) 单独建 `ecandle-support`（隐私政策、Issue 入口）。
