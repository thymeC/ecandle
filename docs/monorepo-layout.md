# 仓库布局（对齐 sudocool）

本仓库与 **数独道场 / sudocool** 采用相同思路：**一个产品仓库 + 门户 digital-life 展示与 Web 试玩**。

```
ecandle/
├── app/
│   ├── ios/          # Xcode（SwiftUI），已可运行
│   ├── android/      # 待你补充
│   └── harmony/      # 待你补充
├── web/              # 静态 Web 试玩（嵌入 digital-life /embed/ecandle/）
├── design/           # 图标与截图源（sync 到 digital-life）
└── docs/
```

| 平台 | 仓库路径 | 门户 / 试玩 |
|------|-----------|-------------|
| iOS | `app/ios/Ecandle.xcodeproj` | digital-life 详情页 + App Store（上架后） |
| Android | `app/android/` | 同上 |
| HarmonyOS | `app/harmony/` | 同上 |
| Web | `web/` | digital-life：`pnpm build:web ~/repo/ecandle ecandle` → `/play/ecandle` |

Support / 隐私政策可仿照 [sudocool-support](https://github.com/thymeC/sudocool-support) 单独建 `ecandle-support` 仓库（可选）。
