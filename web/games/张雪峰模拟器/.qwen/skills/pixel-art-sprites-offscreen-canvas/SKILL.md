---
name: pixel-art-sprites-offscreen-canvas
description: 使用离屏Canvas绘制像素精灵，缩放后以imageSmoothingEnabled=false渲染，实现纯代码像素风美术
source: auto-skill
extracted_at: '2026-06-07T08:02:59.269Z'
---

# 离屏Canvas像素精灵生成

## 核心思路

不用外部图片，在极小离屏Canvas上用 `fillRect` 逐像素绘制精灵，然后通过 `drawImage` 按整数倍缩放绘制到主Canvas，配合 `imageSmoothingEnabled = false` 获得清晰像素块效果。

## 工具函数

```javascript
function makeSprite(w, h, drawFn) {
    const c = document.createElement('canvas');
    c.width = w; c.height = h;
    const cx = c.getContext('2d');
    cx.imageSmoothingEnabled = false;
    drawFn(cx, w, h);
    return c;
}
```

## 使用方式

```javascript
// 1. 定义精灵（如 16×24 像素）
const playerStand = makeSprite(16, 24, (cx, w, h) => {
    // 头发
    cx.fillStyle = '#1a1a2e';
    cx.fillRect(4, 0, 7, 2);
    // 脸
    cx.fillStyle = '#f0c8a0';
    cx.fillRect(4, 2, 7, 6);
    // ...更多像素
});

// 2. 在主Canvas缩放渲染
const SCALE = 3;
ctx.imageSmoothingEnabled = false;
ctx.drawImage(playerStand, x, y, 16 * SCALE, 24 * SCALE);
```

## 关键细节

- **精灵分辨率**：16×24 对人物角色是合适的基础尺寸，3倍缩放后为 48×72 可辨识
- **调色板**：建议定义 `const palette = { hair: '#...', skin: '#...', ... }` 集中管理颜色
- **动画帧**：创建多个离屏Canvas（如 `playerRun1`, `playerRun2`），在主循环中交替切换
- **红色叠加警告**：使用 `globalCompositeOperation = 'source-atop'` 对已绘制精灵叠加半透明红色

```
ctx.globalCompositeOperation = 'source-atop';
ctx.fillStyle = 'rgba(255, 0, 0, 0.4)';
ctx.fillRect(x, y, w, h);
ctx.globalCompositeOperation = 'source-over';
```

## CSS 配合

```css
canvas {
    image-rendering: pixelated;
    image-rendering: crisp-edges;
}
```
