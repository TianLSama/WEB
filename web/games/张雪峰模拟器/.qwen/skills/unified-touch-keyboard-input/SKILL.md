---
name: unified-touch-keyboard-input
description: 触屏按钮映射键盘key-state，让游戏逻辑与输入源解耦，一套update处理所有输入
source: auto-skill
extracted_at: '2026-06-07T08:02:59.269Z'
---

# 统一触屏/键盘输入——key-state 映射

## 核心思路

不让游戏逻辑感知输入来源（键盘还是触屏）。HTML按钮通过 `pointerdown/pointerup/pointerleave` 事件直接写入全局 `keys` 对象，键盘事件也写入同一对象。游戏逻辑只读 `keys` 和 `keyJustPressed`。

## 实现

### 1. 全局 key-state

```javascript
let keys = {};
let keyJustPressed = {};

// 键盘事件
window.addEventListener('keydown', e => { keys[e.key] = true; keys[e.code] = true; e.preventDefault(); });
window.addEventListener('keyup',   e => { keys[e.key] = false; keys[e.code] = false; });
```

### 2. 每帧检测"刚按下"

```javascript
const prevKeys = {};
function updateInput() {
    for (const k in keys) {
        keyJustPressed[k] = (keys[k] && !prevKeys[k]);
    }
    for (const k in keys) prevKeys[k] = keys[k];
}
```

### 3. 触屏按钮直接写 keys

```javascript
// ▲ 跳跃按钮 → 映射 Space/ArrowUp
btnJump.addEventListener('pointerdown',  e => { e.preventDefault(); keys[' '] = true; keys['Space'] = true; });
btnJump.addEventListener('pointerup',    e => { e.preventDefault(); keys[' '] = false; keys['Space'] = false; });
btnJump.addEventListener('pointerleave', e => { keys[' '] = false; keys['Space'] = false; });

// ▼ 低头按钮 → 映射 Shift
btnDuck.addEventListener('pointerdown',  e => { e.preventDefault(); keys['Shift'] = true; });
btnDuck.addEventListener('pointerup',    e => { e.preventDefault(); keys['Shift'] = false; });
btnDuck.addEventListener('pointerleave', e => { keys['Shift'] = false; });
```

### 4. 游戏逻辑只读 keys

```javascript
// 跳跃（只读，不关心来源）
if (keyJustPressed[' '] && !playerJumping) {
    playerVY = JUMP_FORCE;
    playerJumping = true;
}
// 低头（持续按住）
if (keys['Shift'] && !playerJumping) {
    playerDucking = true;
} else if (!playerJumping) {
    playerDucking = false;
}
```

## 关键细节

- `pointerleave` 必须处理：手指滑出按钮区域时需释放按键，避免"卡键"
- 一个按钮可映射多个 key（如 `keys[' ']` + `keys['Space']` + `keys['ArrowUp']`），兼容不同键盘布局
- 按钮样式用 `pointer-events: auto` 嵌套在 `pointer-events: none` 容器中，避免遮挡Canvas点击
- CSS `touch-action: manipulation` 消除移动端300ms延迟

## CSS 按钮容器

```css
#touch-controls {
    position: fixed;
    bottom: 10px;
    left: 0; right: 0;
    display: flex;
    justify-content: center;
    gap: 12px;
    z-index: 10;
    pointer-events: none;  /* 容器穿透，按钮不穿透 */
}
#touch-controls button {
    pointer-events: auto;
    width: 50px; height: 50px;
    border-radius: 50%;
    touch-action: manipulation;
}
```
