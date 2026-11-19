# App Store Connect 粘贴清单 · 电子蜡烛 1.0

API Key 无「写元数据」权限，请在网页 Distribution 按下面逐项粘贴。  
控制台：https://appstoreconnect.apple.com/apps/6823395340  

素材已推到 `main`：

- 文案源：`design/app-store/promo-copy.md`
- 截图：`design/app-store/screenshots/`（1320×2868，iPhone 6.7"）
- 隐私：https://github.com/thymeC/ecandle/blob/main/PRIVACY.md
- 图标：`design/app_icon_1024.png`（已去透明；新包需再传一次才刷新侧栏图标）

---

## 1. App 信息（左侧 General → App Information）

| 字段 | 值 |
|------|-----|
| 名称 | 电子蜡烛 |
| 副标题 | 对着手机吹气，过一个没有打火机的生日 |
| 隐私政策 URL | https://github.com/thymeC/ecandle/blob/main/PRIVACY.md |
| 类别（主） | 娱乐 |
| 内容版权 | 2026 JING CHEN |

## 2. iOS 1.0 版本页（Distribution → 1.0 Prepare for Submission）

### 选构建

选择 Build **`202611190850`**（1.0.0）。

### 推广文本

```
没有打火机也能过生日：点燃蛋糕蜡烛，对着 iPhone 吹灭，彩纸与生日快乐一起响起。支持多根蜡烛与数字造型蜡烛。
```

### 描述

```
电子蜡烛 —— 没有打火机，也能郑重许愿。

点亮蛋糕上的蜡烛，对着 iPhone 底部麦克风轻轻吹气，火焰会一根根熄灭。全部吹灭后，彩纸飞舞，「生日快乐」响起。

■ 多根蜡烛或数字蜡烛
按数量摆放，或按年龄显示成数字造型蜡烛（例如 25 → 「2」和「5」）。

■ 麦克风吹气
点燃后自动进入沉浸模式并开启吹气检测。安静环境下对着话筒吹，强度够了就会熄灭。

■ 生日快乐背景音乐
可开关的合成版经典《生日快乐》旋律，点燃时响起，吹灭后停止。

■ 再吹一次
庆祝结束后可一键重新布置、再点亮，适合连着给好几个人过生日。

麦克风仅用于检测吹气音量，音频不会上传。无需账号，完全离线可用。
```

### 关键词

```
生日,蜡烛,吹蜡烛,生日快乐,生日蛋糕,派对,愿望,麦克风,趣味,庆祝
```

### 技术支持 URL

```
https://github.com/thymeC/ecandle/issues
```

### 营销 URL（可选）

```
https://github.com/thymeC/ecandle
```

### What’s New

```
首发：点燃、吹灭、数字蜡烛、生日快乐音乐与庆祝特效。
```

### 截图（iPhone 6.7"）

按顺序拖入 `design/app-store/screenshots/`：

1. `01-setup.png` — 设置页  
2. `02-digits.png` — 数字蜡烛 25  
3. `03-lit.png` — 点燃沉浸  

### App 审核信息 → 备注

```
本应用使用麦克风检测用户吹气音量以熄灭蜡烛，不录音、不联网上传音频。测试步骤：打开 App → 点燃蜡烛 → 允许麦克风 → 对着话筒吹气。
```

### 年龄分级

全部选无 / None；不涉及赌博、用户生成内容、不受限网页。目标 **4+**。

---

## 3. 侧栏图标仍是占位？

正常：要给 1.0 **选中 Build** 并保存后才会用构建里的图标。  
若仍不对，用已去透明的 `app_icon_1024.png` 再打一包上传即可。
