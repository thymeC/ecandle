# Web · eCandle

纯静态页面：`index.html` + `css/` + `js/`，无构建步骤。

- 相对路径资源，可部署到任意静态主机
- 嵌入 digital-life 时使用 `base-href=/embed/ecandle/` 的拷贝（由 `build-static-web.sh` 生成）

本地：`python3 -m http.server 8080`（需 localhost 或 HTTPS 才能用麦克风）。
