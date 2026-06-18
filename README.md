# 毕业音乐会邀请函 H5

校园合唱团毕业音乐会移动端 H5 邀请函，核心体验为“云端毕业邀请函 / 一个信封打开，里面是一场毕业音乐会”。使用原生 HTML、CSS 和 JavaScript 实现，适配微信内置浏览器和主流手机竖屏。

## 文件结构

```text
.
├── index.html
├── styles.css
├── app.js
├── full_scale_poster.jpg
├── assets/
│   ├── cloud-far-left.png
│   ├── cloud-far-right.png
│   ├── cloud-front-bottom.png
│   ├── cloud-mid-main.png
│   ├── cloud-small-right.png
│   ├── poster-cloud-cap.jpg
│   ├── poster-cloud-clean.jpg
│   ├── poster-letter-bg.jpg
│   ├── poster-logo.jpg
│   ├── poster-preview.jpg
│   └── poster-sky.jpg
├── scripts/
│   └── export-poster-assets.ps1
└── README.md
```

`full_scale_poster.jpg` 是本地高清海报源文件，不会被页面直接加载。H5 实际加载的是 `assets/` 中的压缩裁切资源。
首屏白云 PNG 由脚本从高清海报裁切并按天空蓝抠图生成，用于封面的远景、中景和前景云层。

## 本地运行

这是零依赖静态页面，可直接打开 `index.html` 预览。

如需模拟线上环境，可在当前目录启动任意静态服务器：

```bash
python -m http.server 8080
```

然后访问：

```text
http://localhost:8080
```

## 部署

部署时上传 `index.html`、`styles.css`、`app.js`、`assets/` 和 `README.md` 即可。`full_scale_poster.jpg` 是 189MB 左右的源文件，不建议上传到线上静态目录。入口文件为 `index.html`。

## 交互能力

- 开场为专属云端信封，点击后信封打开，信纸抽出并展开。
- 使用 CSS animation 实现云朵漂浮、学士帽轻微浮动、金色飘带摆动、音乐开关动效。
- 使用 IntersectionObserver 实现滚动进入视口时的淡入上浮。
- “复制活动信息”由用户点击触发，优先使用 Clipboard API，降级到 `textarea + document.execCommand('copy')`。
- “查看地点”提供腾讯地图和高德地图网页搜索链接，并提供复制地址兜底。
- “添加到日历”不会承诺直接写入系统日历，弹窗内提供复制日历信息和尝试下载 `.ics` 文件。
- “生成分享海报”弹出海报预览层，提示用户长按图片保存或转发给朋友。
- 所有底部按钮均按普通 H5 能力实现，不依赖公众号签名、小程序权限、微信 JS-SDK 或服务号接口。

## 重新导出海报资源

如果替换了高清海报源文件，可保持文件名为 `full_scale_poster.jpg`，然后运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\export-poster-assets.ps1
```

## 活动信息

- 活动名称：毕业音乐会
- 演出团体：咏恒合唱团 Cantare Sempre
- 日期：2026.06.21
- 时间：周日 13:30-14:30
- 地点：北院学生活动中心（情人坡东南侧）
- 主办：清华大学咏恒合唱团
- 入场方式：演出面向全校师生开放，无需领票，可直接前往观看
