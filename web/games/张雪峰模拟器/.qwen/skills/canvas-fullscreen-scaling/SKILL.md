---
name: canvas-fullscreen-scaling
description: 固定内部分辨率的Canvas游戏全屏缩放策略——从等比适配到拉伸填充的取舍
source: auto-skill
extracted_at: '2026-06-07T08:02:59.269Z'
---

# Canvas 固定分辨率全屏缩放

## 两种策略

### 策略A：等比缩放（保留黑边）

保持内部分辨率不变，取 min(scaleX, scaleY) 缩放，居中显示。适合对画面比例有严格要求的游戏。

```javascript
function resizeCanvas() {
    const scaleX = window.innerWidth / W;
    const scaleY = window.innerHeight / H;
    const scale = Math.min(scaleX, scaleY);
    canvas.style.width  = Math.floor(W * scale) + 'px';
    canvas.style.height = Math.floor(H * scale) + 'px';
}
```

### 策略B：拉伸填充（无黑边）

直接拉伸到窗口尺寸。配合 `image-rendering: pixelated` 时像素风格游戏可接受轻微变形。

```javascript
function resizeCanvas() {
    canvas.style.width  = window.innerWidth + 'px';
    canvas.style.height = window.innerHeight + 'px';
}
```

## 选择依据

- **策略A** 适合：画面元素对比例敏感、需要精确定位的游戏
- **策略B** 适合：像素风游戏（pixelated 渲染掩盖拉伸痕迹）、用户明确要求无黑边
- 从策略A切换到策略B的典型触发条件：用户反馈"上下/左右有黑边"

## CSS 配合

```css
canvas {
    display: block;
    position: absolute;
    top: 0; left: 0;
    image-rendering: pixelated;
    image-rendering: crisp-edges;
}
#game-container {
    position: fixed;
    inset: 0;
}
body {
    background: #000;  /* canvas外的背景色，策略A时作为黑边 */
}
```

## 注意事项

- 内部游戏逻辑始终使用固定坐标（如 `W=800, H=300`），不受缩放影响
- `window.innerWidth/innerHeight` 在移动端需配合 `viewport-fit=cover` 和 `100dvh`
- 移动端 meta：`maximum-scale=1.0, user-scalable=no` 防止意外缩放
