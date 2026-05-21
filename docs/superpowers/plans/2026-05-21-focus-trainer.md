# 专注力训练小程序 — 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 使用 uniapp-cli (Vue3 + Vite + TS) 构建一个包含 3 个专注力训练游戏、打卡日历、用户系统的微信小程序

**Architecture:** TabBar 3 个 Tab（首页/日历/我的）→ 首页进入游戏选择 → 每个游戏含介绍页+游戏页（组件切换）。Pinia 管理状态，uniCloud 云数据库存储用户和训练记录。

**Tech Stack:** uniapp-cli, Vue 3, Vite, TypeScript, Pinia, uni-ui, uniCloud

---

## Phase 1: 项目初始化与配置

### Task 1: 创建 uniapp-cli 项目

**Files:**
- Create: project root and all scaffold files

- [ ] **Step 1: 使用 uniapp CLI 创建项目**

```bash
cd /Users/chenjingyi/Documents/test/claude/project
npx degit dcloudio/uni-preset-vue#vite-ts focus-trainer
cd focus-trainer
npm install
```

- [ ] **Step 2: 安装依赖**

```bash
npm install pinia @dcloudio/uni-ui
```

- [ ] **Step 3: 验证项目能启动**

```bash
npx uni-app run -p mp-weixin
```

Expected: 编译成功，生成 `dist/dev/mp-weixin` 目录

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "feat: scaffold uniapp-cli project with Vue3+Vite+TS"
```

---

### Task 2: 配置 pages.json（路由 + TabBar）

**Files:**
- Modify: `src/pages.json`

- [ ] **Step 1: 写入完整 pages.json**

```json
{
  "easycom": {
    "autoscan": true,
    "custom": {
      "^uni-(.*)": "@dcloudio/uni-ui/lib/uni-$1/uni-$1.vue"
    }
  },
  "pages": [
    {
      "path": "pages/index/index",
      "style": {
        "navigationBarTitleText": "专注训练"
      }
    },
    {
      "path": "pages/calendar/calendar",
      "style": {
        "navigationBarTitleText": "训练日历"
      }
    },
    {
      "path": "pages/mine/mine",
      "style": {
        "navigationBarTitleText": "我的"
      }
    },
    {
      "path": "pages/game-select/game-select",
      "style": {
        "navigationBarTitleText": "选择训练"
      }
    },
    {
      "path": "pages/game-number/game-number",
      "style": {
        "navigationBarTitleText": "数字顺序点击",
        "navigationBarBackgroundColor": "#C49B8B"
      }
    },
    {
      "path": "pages/game-color/game-color",
      "style": {
        "navigationBarTitleText": "颜色识别挑战",
        "navigationBarBackgroundColor": "#A8B5A0"
      }
    },
    {
      "path": "pages/game-memory/game-memory",
      "style": {
        "navigationBarTitleText": "数字记忆挑战",
        "navigationBarBackgroundColor": "#9BA8C0"
      }
    }
  ],
  "globalStyle": {
    "navigationBarTextStyle": "black",
    "navigationBarTitleText": "专注训练",
    "navigationBarBackgroundColor": "#FFFFFF",
    "backgroundColor": "#F5F5F5"
  },
  "tabBar": {
    "color": "#999999",
    "selectedColor": "#8B6F5E",
    "borderStyle": "black",
    "backgroundColor": "#FFFFFF",
    "list": [
      {
        "pagePath": "pages/index/index",
        "text": "首页",
        "iconPath": "static/tab-home.png",
        "selectedIconPath": "static/tab-home-active.png"
      },
      {
        "pagePath": "pages/calendar/calendar",
        "text": "日历",
        "iconPath": "static/tab-calendar.png",
        "selectedIconPath": "static/tab-calendar-active.png"
      },
      {
        "pagePath": "pages/mine/mine",
        "text": "我的",
        "iconPath": "static/tab-mine.png",
        "selectedIconPath": "static/tab-mine-active.png"
      }
    ]
  }
}
```

- [ ] **Step 2: 创建 TabBar 占位图标（使用 uni-app 自带示例图标或纯色图）**

创建简单的 8x8 纯色 PNG 占位图或跳过（TabBar 缺少图标时会显示文字）

- [ ] **Step 3: Commit**

```bash
git add src/pages.json && git commit -m "feat: configure routes and TabBar"
```

---

### Task 3: 配置 manifest.json（微信小程序）

**Files:**
- Modify: `src/manifest.json`

- [ ] **Step 1: 写入 manifest.json，开启微信小程序配置**

```json
{
  "name": "专注训练",
  "appid": "__UNI__XXXXXXX",
  "description": "专注力训练小程序",
  "versionName": "1.0.0",
  "versionCode": "100",
  "transformPx": false,
  "mp-weixin": {
    "appid": "",
    "setting": {
      "urlCheck": false,
      "es6": true,
      "postcss": true,
      "minified": true
    },
    "usingComponents": true,
    "permission": {
      "scope.userLocation": {
        "desc": "用于记录训练位置"
      }
    }
  },
  "uniStatistics": {
    "enable": false
  },
  "vueVersion": "3"
}
```

- [ ] **Step 2: Commit**

```bash
git add src/manifest.json && git commit -m "feat: configure WeChat mini program manifest"
```

---

### Task 4: 配置全局样式与色彩变量

**Files:**
- Modify: `src/uni.scss`
- Create: `src/styles/colors.scss`

- [ ] **Step 1: 创建色彩常量文件**

File: `src/styles/colors.scss`

```scss
// 游戏主色
$game-number: #C49B8B;
$game-color: #A8B5A0;
$game-memory: #9BA8C0;

// 日历
$calendar-gold-start: #F5EDE3;
$calendar-gold-end: #EDE0D0;
$calendar-date-color: #8B6F5E;

// 通用
$text-primary: #333333;
$text-secondary: #666666;
$bg-page: #F5F5F5;
$bg-white: #FFFFFF;
$border-color: #E5E5E5;
$success-color: #A8B5A0;
$error-color: #C49B8B;
```

- [ ] **Step 2: 更新 uni.scss**

```scss
@import './styles/colors.scss';

/* 全局样式 */
page {
  background-color: $bg-page;
  font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
  color: $text-primary;
}

.flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}

.card {
  background: $bg-white;
  border-radius: 12rpx;
  padding: 24rpx;
  margin: 20rpx;
}
```

- [ ] **Step 3: Commit**

```bash
git add src/uni.scss src/styles/ && git commit -m "feat: add color system and global styles"
```

---

## Phase 2: 工具函数与状态管理

### Task 5: 创建游戏数据生成工具

**Files:**
- Create: `src/utils/game-generator.ts`

- [ ] **Step 1: 写入游戏生成逻辑**

File: `src/utils/game-generator.ts`

```typescript
/** Fisher-Yates 洗牌 */
export function shuffle<T>(arr: T[]): T[] {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

/** 生成游戏1的 5x5 网格：1~25 随机排列 */
export function generateNumberGrid(): number[][] {
  const nums = shuffle(Array.from({ length: 25 }, (_, i) => i + 1))
  const grid: number[][] = []
  for (let i = 0; i < 5; i++) {
    grid.push(nums.slice(i * 5, (i + 1) * 5))
  }
  return grid
}

const COLOR_WORDS = ['红', '橙', '黄', '绿', '青', '蓝', '紫']
const COLOR_VALUES: Record<string, string> = {
  '红': '#E74C3C',
  '橙': '#E67E22',
  '黄': '#F1C40F',
  '绿': '#2ECC71',
  '青': '#1ABC9C',
  '蓝': '#3498DB',
  '紫': '#9B59B6',
}

/** 生成游戏2的一道题 */
export function generateColorQuestion() {
  const text = COLOR_WORDS[Math.floor(Math.random() * COLOR_WORDS.length)]
  // 颜色不能和文字含义相同
  const availableColors = COLOR_WORDS.filter(c => c !== text)
  const color = availableColors[Math.floor(Math.random() * availableColors.length)]
  // 干扰项：不等于文字含义也不等于实际颜色
  const distractors = COLOR_WORDS.filter(c => c !== text && c !== color)
  const distractor = distractors[Math.floor(Math.random() * distractors.length)]
  return {
    text,
    color,
    colorValue: COLOR_VALUES[color],
    options: shuffle([text, color, distractor]),
  }
}

/** 生成游戏3的目标序列：从 1~25 随机选 7 个不重复数字 */
export function generateMemorySequence(): number[] {
  const nums = shuffle(Array.from({ length: 25 }, (_, i) => i + 1))
  return nums.slice(0, 7)
}

/** 生成 1~25 的有序 5x5 网格（用于游戏3作答） */
export function generateOrderedGrid(): number[][] {
  const grid: number[][] = []
  for (let i = 0; i < 5; i++) {
    grid.push(Array.from({ length: 5 }, (_, j) => i * 5 + j + 1))
  }
  return grid
}

export { COLOR_WORDS, COLOR_VALUES }
```

- [ ] **Step 2: Commit**

```bash
git add src/utils/game-generator.ts && git commit -m "feat: add game data generators"
```

---

### Task 6: 创建 Pinia Store

**Files:**
- Create: `src/stores/user.ts`
- Create: `src/stores/training.ts`
- Create: `src/stores/game.ts`

- [ ] **Step 1: 创建 userStore**

File: `src/stores/user.ts`

```typescript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  const openid = ref('')
  const nickname = ref('')
  const avatar = ref('')
  const phone = ref('')

  const isLogin = computed(() => !!openid.value)

  async function login() {
    return new Promise<void>((resolve) => {
      uni.login({
        provider: 'weixin',
        success: async (res) => {
          // 调用云函数获取 openid
          const result = await uniCloud.callFunction({
            name: 'getOpenid',
            data: { code: res.code },
          })
          const data = result.result as any
          openid.value = data.openid
          await syncUserInfo()
          resolve()
        },
        fail: () => resolve(),
      })
    })
  }

  async function loginByPhone(e: any) {
    // 微信手机号授权
    const { code } = e.detail
    const result = await uniCloud.callFunction({
      name: 'getPhone',
      data: { code },
    })
    const data = result.result as any
    if (data.phone) {
      phone.value = data.phone
    }
  }

  async function syncUserInfo() {
    uni.getUserInfo({
      success: (res) => {
        nickname.value = res.userInfo.nickName
        avatar.value = res.userInfo.avatarUrl
      },
    })
  }

  function logout() {
    openid.value = ''
    nickname.value = ''
    avatar.value = ''
    phone.value = ''
  }

  return { openid, nickname, avatar, phone, isLogin, login, loginByPhone, logout }
})
```

- [ ] **Step 2: 创建 trainingStore**

File: `src/stores/training.ts`

```typescript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export type GameType = 'number' | 'color' | 'memory'
export type GameResult = 'pass' | 'fail'

export interface TrainingRecord {
  _id?: string
  user_id: string
  game_type: GameType
  score: number
  result: GameResult
  date: string
  created_at: number
}

export const useTrainingStore = defineStore('training', () => {
  const todayRecords = ref<TrainingRecord[]>([])
  // calendarData: key = 'YYYY-MM-DD', value = { number, color, memory } 各布尔值
  const calendarData = ref<Record<string, { number: boolean; color: boolean; memory: boolean }>>({})
  const currentMonth = ref(new Date())

  const today = computed(() => {
    const d = new Date()
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  })

  const todayStats = computed(() => {
    const recs = todayRecords.value
    const total = recs.length
    const completed = {
      number: recs.some(r => r.game_type === 'number'),
      color: recs.some(r => r.game_type === 'color'),
      memory: recs.some(r => r.game_type === 'memory'),
    }
    return { total, completed }
  })

  async function fetchTodayRecords() {
    const db = uniCloud.database()
    const res = await db.collection('training_records')
      .where({ date: today.value })
      .get()
    todayRecords.value = res.result.data as TrainingRecord[]
  }

  async function fetchCalendarData(year: number, month: number) {
    const db = uniCloud.database()
    const startDate = `${year}-${String(month).padStart(2, '0')}-01`
    const endDate = `${year}-${String(month).padStart(2, '0')}-31`
    const res = await db.collection('training_records')
      .where({
        date: db.command.gte(startDate).and(db.command.lte(endDate)),
      })
      .get()
    const records = res.result.data as TrainingRecord[]
    const data: Record<string, { number: boolean; color: boolean; memory: boolean }> = {}
    for (const r of records) {
      if (!data[r.date]) {
        data[r.date] = { number: false, color: false, memory: false }
      }
      data[r.date][r.game_type] = true
    }
    calendarData.value = data
  }

  async function addRecord(record: Omit<TrainingRecord, '_id' | 'date' | 'created_at'>) {
    const db = uniCloud.database()
    await db.collection('training_records').add({
      ...record,
      date: today.value,
      created_at: Date.now(),
    })
    await fetchTodayRecords()
  }

  return { todayRecords, calendarData, currentMonth, today, todayStats, fetchTodayRecords, fetchCalendarData, addRecord }
})
```

- [ ] **Step 3: 创建 gameStore**

File: `src/stores/game.ts`

```typescript
import { defineStore } from 'pinia'
import { ref } from 'vue'

export type GameStatus = 'idle' | 'intro' | 'playing' | 'passed' | 'failed'

export const useGameStore = defineStore('game', () => {
  const currentGame = ref<'number' | 'color' | 'memory' | null>(null)
  const status = ref<GameStatus>('idle')
  const score = ref(0)

  function startIntro(game: 'number' | 'color' | 'memory') {
    currentGame.value = game
    status.value = 'intro'
    score.value = 0
  }

  function startGame() {
    status.value = 'playing'
    score.value = 0
  }

  function endGame(result: 'passed' | 'failed', finalScore: number) {
    status.value = result
    score.value = finalScore
  }

  function reset() {
    currentGame.value = null
    status.value = 'idle'
    score.value = 0
  }

  return { currentGame, status, score, startIntro, startGame, endGame, reset }
})
```

- [ ] **Step 4: 在 main.ts 中注册 Pinia**

Read `src/main.ts` first, then modify to add Pinia:

```typescript
import { createSSRApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

export function createApp() {
  const app = createSSRApp(App)
  app.use(createPinia())
  return { app }
}
```

- [ ] **Step 5: Commit**

```bash
git add src/stores/ src/main.ts && git commit -m "feat: add Pinia stores for user, training, game"
```

---

### Task 7: 创建 uniCloud API 封装

**Files:**
- Create: `src/utils/uniCloud-api.ts`

- [ ] **Step 1: 写入 API 封装**

File: `src/utils/uniCloud-api.ts`

```typescript
import type { TrainingRecord, GameType, GameResult } from '@/stores/training'

const db = uniCloud.database()

/** 获取或创建用户 */
export async function getOrCreateUser(openid: string) {
  const res = await db.collection('users').where({ openid }).get()
  if (res.result.data.length > 0) {
    return res.result.data[0]
  }
  const createRes = await db.collection('users').add({
    openid,
    created_at: Date.now(),
  })
  return { _id: createRes.result.id, openid }
}

/** 保存训练记录 */
export async function saveTrainingRecord(params: {
  user_id: string
  game_type: GameType
  score: number
  result: GameResult
}) {
  const d = new Date()
  const date = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  return db.collection('training_records').add({
    ...params,
    date,
    created_at: Date.now(),
  })
}

/** 获取指定月份的训练记录 */
export async function getMonthRecords(year: number, month: number) {
  const startDate = `${year}-${String(month).padStart(2, '0')}-01`
  const nextMonth = month === 12 ? 1 : month + 1
  const nextYear = month === 12 ? year + 1 : year
  const endDate = `${nextYear}-${String(nextMonth).padStart(2, '0')}-01`
  const res = await db.collection('training_records')
    .where({
      date: db.command.gte(startDate).and(db.command.lt(endDate)),
    })
    .orderBy('created_at', 'desc')
    .get()
  return res.result.data as TrainingRecord[]
}

/** 获取今日训练记录 */
export async function getTodayRecords() {
  const d = new Date()
  const date = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  const res = await db.collection('training_records')
    .where({ date })
    .orderBy('created_at', 'desc')
    .get()
  return res.result.data as TrainingRecord[]
}
```

- [ ] **Step 2: Commit**

```bash
git add src/utils/uniCloud-api.ts && git commit -m "feat: add uniCloud API wrapper"
```

---

## Phase 3: 共享组件

### Task 8: CountdownTimer 组件

**Files:**
- Create: `src/components/CountdownTimer.vue`

- [ ] **Step 1: 实现倒计时组件**

File: `src/components/CountdownTimer.vue`

```vue
<template>
  <view class="countdown" :class="{ warning: remaining <= 5 }">
    <text class="timer-icon">⏱</text>
    <text class="timer-text">{{ formatted }}</text>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, watch, onUnmounted } from 'vue'

const props = defineProps<{
  totalSeconds: number
  running: boolean
}>()

const emit = defineEmits<{
  timeout: []
}>()

const remaining = ref(props.totalSeconds)
let timer: ReturnType<typeof setInterval> | null = null

const formatted = computed(() => {
  const m = Math.floor(remaining.value / 60)
  const s = remaining.value % 60
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
})

watch(() => props.running, (val) => {
  if (val) {
    remaining.value = props.totalSeconds
    timer = setInterval(() => {
      remaining.value--
      if (remaining.value <= 0) {
        if (timer) clearInterval(timer)
        emit('timeout')
      }
    }, 1000)
  } else {
    if (timer) clearInterval(timer)
  }
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})

defineExpose({ remaining })
</script>

<style scoped>
.countdown {
  display: flex;
  align-items: center;
  gap: 8rpx;
}
.timer-text {
  font-size: 36rpx;
  font-weight: bold;
  font-variant-numeric: tabular-nums;
}
.warning .timer-text {
  color: #E74C3C;
  animation: pulse 0.5s infinite alternate;
}
@keyframes pulse {
  from { opacity: 1; }
  to { opacity: 0.5; }
}
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/CountdownTimer.vue && git commit -m "feat: add CountdownTimer component"
```

---

### Task 9: NumberGrid 组件

**Files:**
- Create: `src/components/NumberGrid.vue`

- [ ] **Step 1: 实现 5×5 数字网格组件**

File: `src/components/NumberGrid.vue`

```vue
<template>
  <view class="grid">
    <view v-for="(row, r) in grid" :key="r" class="grid-row">
      <view
        v-for="(num, c) in row"
        :key="c"
        class="grid-cell"
        :class="{
          completed: isCompleted(r, c),
          disabled: disabled,
          active: isActive(r, c),
        }"
        @tap="() => onCellClick(r, c, num)"
      >
        <text class="cell-text">{{ isCompleted(r, c) ? '✓' : num }}</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
const props = defineProps<{
  grid: number[][]
  completedSet: Set<number>
  disabled: boolean
  accentColor?: string
}>()

const emit = defineEmits<{
  cellClick: [row: number, col: number, value: number]
}>()

function isCompleted(row: number, col: number): boolean {
  return props.completedSet.has(props.grid[row]?.[col] ?? 0)
}

function isActive(row: number, col: number): boolean {
  return !isCompleted(row, col) && !props.disabled
}

function onCellClick(row: number, col: number, value: number) {
  if (props.disabled || isCompleted(row, col)) return
  emit('cellClick', row, col, value)
}
</script>

<style scoped>
.grid {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}
.grid-row {
  display: flex;
  gap: 8rpx;
}
.grid-cell {
  width: 120rpx;
  height: 120rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
  border-radius: 12rpx;
  border: 2rpx solid #eee;
  transition: all 0.15s;
}
.grid-cell.active {
  border-color: v-bind(accentColor);
}
.grid-cell.completed {
  background: #eee;
  opacity: 0.4;
}
.cell-text {
  font-size: 36rpx;
  font-weight: 600;
}
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/NumberGrid.vue && git commit -m "feat: add NumberGrid component"
```

---

### Task 10: ResultModal 组件

**Files:**
- Create: `src/components/ResultModal.vue`

- [ ] **Step 1: 实现结果弹窗**

File: `src/components/ResultModal.vue`

```vue
<template>
  <view class="overlay" v-if="visible" @tap="close">
    <view class="modal" @tap.stop>
      <text class="result-icon">{{ result === 'passed' ? '🎉' : '😞' }}</text>
      <text class="result-title">{{ result === 'passed' ? titlePassed : titleFailed }}</text>
      <text class="result-score">{{ scoreText }}</text>
      <view class="actions">
        <button class="btn-retry" :style="{ background: accentColor }" @tap="emit('retry')">再玩一次</button>
        <button class="btn-back" @tap="emit('back')">返回</button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  visible: boolean
  result: 'passed' | 'failed'
  scoreText: string
  titlePassed?: string
  titleFailed?: string
  accentColor?: string
}>()

const emit = defineEmits<{
  retry: []
  back: []
  close: []
}>()

function close() {
  emit('close')
}
</script>

<style scoped>
.overlay {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0,0,0,0.5);
  z-index: 100;
}
.modal {
  background: #fff;
  border-radius: 24rpx;
  padding: 60rpx 40rpx;
  width: 560rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
}
.result-icon { font-size: 80rpx; }
.result-title { font-size: 40rpx; font-weight: bold; }
.result-score { font-size: 28rpx; color: #666; }
.actions { display: flex; gap: 20rpx; margin-top: 20rpx; }
.btn-retry, .btn-back {
  padding: 20rpx 48rpx;
  border-radius: 40rpx;
  font-size: 28rpx;
  border: none;
}
.btn-retry { color: #fff; }
.btn-back { background: #f0f0f0; color: #333; }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/ResultModal.vue && git commit -m "feat: add ResultModal component"
```

---

### Task 11: GameIntro 通用介绍页组件

**Files:**
- Create: `src/components/GameIntro.vue`

- [ ] **Step 1: 实现通用游戏介绍页**

File: `src/components/GameIntro.vue`

```vue
<template>
  <view class="intro">
    <text class="intro-icon">{{ icon }}</text>
    <text class="intro-title">{{ title }}</text>
    <view class="intro-section">
      <text class="section-title">游戏规则</text>
      <text class="section-text">{{ rules }}</text>
    </view>
    <view class="intro-section">
      <text class="section-title">训练能力</text>
      <text class="section-text">{{ abilities }}</text>
    </view>
    <button class="btn-start" :style="{ background: accentColor }" @tap="emit('start')">
      开始训练
    </button>
  </view>
</template>

<script setup lang="ts">
defineProps<{
  icon: string
  title: string
  rules: string
  abilities: string
  accentColor: string
}>()

const emit = defineEmits<{ start: [] }>()
</script>

<style scoped>
.intro {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 60rpx 40rpx;
  gap: 32rpx;
}
.intro-icon { font-size: 96rpx; }
.intro-title { font-size: 44rpx; font-weight: bold; }
.intro-section {
  width: 100%;
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx;
}
.section-title { font-size: 30rpx; font-weight: bold; display: block; margin-bottom: 12rpx; }
.section-text { font-size: 28rpx; color: #666; line-height: 1.6; }
.btn-start {
  width: 400rpx;
  height: 88rpx;
  border-radius: 44rpx;
  font-size: 32rpx;
  color: #fff;
  border: none;
  margin-top: 20rpx;
}
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/GameIntro.vue && git commit -m "feat: add GameIntro component"
```

---

## Phase 4: TabBar 页面

### Task 12: 首页

**Files:**
- Create: `src/pages/index/index.vue`

- [ ] **Step 1: 实现首页**

File: `src/pages/index/index.vue`

```vue
<template>
  <view class="page">
    <!-- 顶部用户信息 -->
    <view class="header">
      <image class="avatar" :src="user.avatar || '/static/default-avatar.png'" mode="aspectFill" />
      <text class="nickname">{{ user.nickname || '专注训练者' }}</text>
    </view>

    <!-- 统计卡片 -->
    <view class="stats-row">
      <view class="stat-card">
        <text class="stat-num">{{ streak }}</text>
        <text class="stat-label">累计训练(天)</text>
      </view>
      <view class="stat-card">
        <text class="stat-num">{{ todayMinutes }}</text>
        <text class="stat-label">今日训练(分钟)</text>
      </view>
    </view>

    <!-- 开始训练按钮 -->
    <button class="btn-train" @tap="goToGameSelect">开始训练</button>

    <!-- 今日记录 -->
    <view class="section">
      <text class="section-title">今日训练</text>
      <view v-if="training.todayRecords.length === 0" class="empty">
        <text>今天还没有训练，快来打卡吧！</text>
      </view>
      <view v-for="r in training.todayRecords" :key="r._id" class="record-item">
        <text class="record-game">{{ gameLabel(r.game_type) }}</text>
        <text class="record-result" :class="r.result">{{ r.result === 'pass' ? '✓' : '✗' }}</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onShow } from 'vue'
import { useUserStore } from '@/stores/user'
import { useTrainingStore } from '@/stores/training'

const user = useUserStore()
const training = useTrainingStore()
const streak = ref(0)
const todayMinutes = computed(() => training.todayRecords.length * 1) // 简单估算每个游戏约1分钟

const gameLabelMap: Record<string, string> = { number: '数字顺序点击', color: '颜色识别挑战', memory: '数字记忆挑战' }
function gameLabel(type: string) { return gameLabelMap[type] || type }

function goToGameSelect() {
  uni.navigateTo({ url: '/pages/game-select/game-select' })
}

onShow(async () => {
  if (!user.isLogin) {
    await user.login()
  }
  await training.fetchTodayRecords()
})
</script>

<style scoped>
.page { padding-bottom: 40rpx; }
.header {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 40rpx;
}
.avatar { width: 80rpx; height: 80rpx; border-radius: 50%; background: #eee; }
.nickname { font-size: 36rpx; font-weight: bold; }
.stats-row { display: flex; gap: 20rpx; padding: 0 40rpx; }
.stat-card {
  flex: 1;
  background: #fff;
  border-radius: 16rpx;
  padding: 32rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.stat-num { font-size: 56rpx; font-weight: bold; color: #8B6F5E; }
.stat-label { font-size: 24rpx; color: #999; margin-top: 8rpx; }
.btn-train {
  margin: 40rpx;
  height: 96rpx;
  background: linear-gradient(135deg, #C49B8B, #A8B5A0);
  color: #fff;
  border-radius: 48rpx;
  font-size: 36rpx;
  font-weight: bold;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
}
.section { margin: 0 40rpx; }
.section-title { font-size: 30rpx; font-weight: bold; margin-bottom: 16rpx; }
.empty { padding: 60rpx 0; text-align: center; color: #999; }
.record-item {
  display: flex;
  justify-content: space-between;
  padding: 20rpx;
  background: #fff;
  border-radius: 8rpx;
  margin-bottom: 8rpx;
}
.record-game { font-size: 28rpx; }
.record-result.pass { color: #A8B5A0; }
.record-result.fail { color: #C49B8B; }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/index/ && git commit -m "feat: add home page"
```

---

### Task 13: 日历页

**Files:**
- Create: `src/pages/calendar/calendar.vue`

- [ ] **Step 1: 实现日历页**

File: `src/pages/calendar/calendar.vue`

```vue
<template>
  <view class="page">
    <!-- 月份选择器 -->
    <view class="month-header">
      <text class="month-arrow" @tap="prevMonth">‹</text>
      <text class="month-label">{{ year }}年{{ month }}月</text>
      <text class="month-arrow" @tap="nextMonth">›</text>
    </view>

    <!-- 星期头部 -->
    <view class="weekday-row">
      <text v-for="w in weekdays" :key="w" class="weekday">{{ w }}</text>
    </view>

    <!-- 日期网格 -->
    <view class="date-grid">
      <view
        v-for="(cell, i) in calendarCells"
        :key="i"
        class="date-cell"
        :class="{
          'other-month': !cell.isCurrentMonth,
          'all-done': cell.isCurrentMonth && cell.games && cell.games.number && cell.games.color && cell.games.memory,
        }"
        @tap="cell.isCurrentMonth && onDateTap(cell.date)"
      >
        <text class="date-num">{{ cell.day }}</text>
        <view v-if="cell.isCurrentMonth" class="dots">
          <view class="dot" :class="{ done: cell.games?.number }" style="--color: #C49B8B" />
          <view class="dot" :class="{ done: cell.games?.color }" style="--color: #A8B5A0" />
          <view class="dot" :class="{ done: cell.games?.memory }" style="--color: #9BA8C0" />
        </view>
      </view>
    </view>

    <!-- 选中日期的训练详情 -->
    <view v-if="selectedDate" class="detail-card">
      <text class="detail-title">{{ selectedDate }} 训练记录</text>
      <view v-if="selectedRecords.length === 0" class="empty">暂无训练记录</view>
      <view v-for="r in selectedRecords" :key="r._id" class="record-item">
        <text>{{ gameLabel(r.game_type) }}</text>
        <text :class="r.result">{{ r.result === 'pass' ? '通过' : '未通过' }}</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useTrainingStore } from '@/stores/training'
import { getMonthRecords } from '@/utils/uniCloud-api'

const training = useTrainingStore()
const weekdays = ['日', '一', '二', '三', '四', '五', '六']
const year = ref(new Date().getFullYear())
const month = ref(new Date().getMonth() + 1)
const selectedDate = ref('')
const selectedRecords = ref<any[]>([])

const calendarCells = computed(() => {
  const y = year.value
  const m = month.value
  const firstDay = new Date(y, m - 1, 1).getDay()
  const daysInMonth = new Date(y, m, 0).getDate()
  const daysInPrevMonth = new Date(y, m - 1, 0).getDate()
  const cells: any[] = []

  // 上月末尾
  for (let i = firstDay - 1; i >= 0; i--) {
    cells.push({ day: daysInPrevMonth - i, isCurrentMonth: false })
  }
  // 当月
  for (let d = 1; d <= daysInMonth; d++) {
    const dateKey = `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`
    cells.push({
      day: d,
      isCurrentMonth: true,
      date: dateKey,
      games: training.calendarData[dateKey] || { number: false, color: false, memory: false },
    })
  }
  // 下月开头
  const remaining = 7 - (cells.length % 7)
  if (remaining < 7) {
    for (let d = 1; d <= remaining; d++) {
      cells.push({ day: d, isCurrentMonth: false })
    }
  }
  return cells
})

async function loadCalendar() {
  await getMonthRecords(year.value, month.value).then(records => {
    const data: Record<string, any> = {}
    for (const r of records) {
      if (!data[r.date]) data[r.date] = { number: false, color: false, memory: false }
      data[r.date][r.game_type] = true
    }
    training.calendarData = data
  })
}

function prevMonth() {
  if (month.value === 1) { year.value--; month.value = 12 }
  else month.value--
  loadCalendar()
}

function nextMonth() {
  if (month.value === 12) { year.value++; month.value = 1 }
  else month.value++
  loadCalendar()
}

async function onDateTap(date: string) {
  selectedDate.value = date
  const db = uniCloud.database()
  const res = await db.collection('training_records').where({ date }).get()
  selectedRecords.value = res.result.data as any[]
}

const gameLabelMap: Record<string, string> = { number: '数字顺序', color: '颜色识别', memory: '数字记忆' }
function gameLabel(type: string) { return gameLabelMap[type] || type }

onMounted(() => loadCalendar())
</script>

<style scoped>
.page { padding: 20rpx; }
.month-header {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 40rpx;
  padding: 30rpx 0;
}
.month-label { font-size: 36rpx; font-weight: bold; }
.month-arrow { font-size: 48rpx; color: #8B6F5E; padding: 0 20rpx; }
.weekday-row { display: flex; }
.weekday { flex: 1; text-align: center; font-size: 26rpx; color: #999; padding: 16rpx 0; }
.date-grid { display: flex; flex-wrap: wrap; }
.date-cell {
  width: calc(100% / 7);
  aspect-ratio: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  box-sizing: border-box;
}
.date-num { font-size: 28rpx; }
.other-month .date-num { color: #ddd; }
.dots { display: flex; gap: 6rpx; margin-top: 4rpx; }
.dot {
  width: 10rpx;
  height: 10rpx;
  border-radius: 50%;
  background: #e0e0e0;
}
.dot.done { background: var(--color); }
.all-done {
  background: linear-gradient(135deg, #F5EDE3, #EDE0D0);
  border-radius: 12rpx;
  animation: shimmer 2s infinite;
}
.all-done .date-num { color: #8B6F5E; font-weight: bold; }
@keyframes shimmer {
  0%, 100% { box-shadow: inset 0 0 0 rgba(255,255,255,0); }
  50% { box-shadow: inset 0 0 20rpx rgba(255,255,255,0.6); }
}
.detail-card {
  margin-top: 30rpx;
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx;
}
.detail-title { font-size: 30rpx; font-weight: bold; }
.empty { padding: 40rpx; text-align: center; color: #999; }
.record-item { display: flex; justify-content: space-between; padding: 16rpx 0; border-bottom: 1rpx solid #f0f0f0; }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/calendar/ && git commit -m "feat: add calendar page"
```

---

### Task 14: 我的页面

**Files:**
- Create: `src/pages/mine/mine.vue`

- [ ] **Step 1: 实现我的页面**

File: `src/pages/mine/mine.vue`

```vue
<template>
  <view class="page">
    <!-- 用户信息 -->
    <view class="profile">
      <image class="avatar" :src="user.avatar || '/static/default-avatar.png'" mode="aspectFill" />
      <view class="profile-info">
        <text class="nickname">{{ user.nickname || '未登录' }}</text>
        <text class="phone">{{ user.phone || '未绑定手机号' }}</text>
      </view>
    </view>

    <!-- 登录按钮 -->
    <view v-if="!user.isLogin" class="login-section">
      <button class="btn-wx-login" open-type="getPhoneNumber" @getphonenumber="user.loginByPhone">
        微信一键登录
      </button>
    </view>

    <!-- 统计 -->
    <view class="stats-section">
      <text class="section-title">训练统计</text>
      <view class="stats-grid">
        <view class="stat-item">
          <text class="stat-num">{{ totalCount }}</text>
          <text class="stat-label">总训练次数</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">{{ bestNumber }}s</text>
          <text class="stat-label">数字顺序最佳</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">{{ bestColor }}</text>
          <text class="stat-label">颜色识别最佳</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">{{ totalFails }}</text>
          <text class="stat-label">记忆挑战通过</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useUserStore } from '@/stores/user'

const user = useUserStore()
const totalCount = ref(0)
const bestNumber = ref('--')
const bestColor = ref('--')
const totalFails = ref(0)
</script>

<style scoped>
.page { padding: 20rpx; }
.profile {
  display: flex;
  align-items: center;
  gap: 24rpx;
  padding: 40rpx;
  background: #fff;
  border-radius: 16rpx;
}
.avatar { width: 100rpx; height: 100rpx; border-radius: 50%; background: #eee; }
.nickname { font-size: 34rpx; font-weight: bold; display: block; }
.phone { font-size: 26rpx; color: #999; }
.login-section { margin: 30rpx 0; }
.btn-wx-login {
  background: #07C160;
  color: #fff;
  border: none;
  border-radius: 48rpx;
  height: 88rpx;
  font-size: 32rpx;
}
.stats-section { margin-top: 30rpx; }
.section-title { font-size: 30rpx; font-weight: bold; margin-bottom: 16rpx; }
.stats-grid { display: flex; flex-wrap: wrap; gap: 16rpx; }
.stat-item {
  width: calc(50% - 8rpx);
  background: #fff;
  border-radius: 16rpx;
  padding: 32rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.stat-num { font-size: 44rpx; font-weight: bold; color: #8B6F5E; }
.stat-label { font-size: 24rpx; color: #999; margin-top: 8rpx; }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/mine/ && git commit -m "feat: add mine/profile page"
```

---

### Task 15: 游戏选择页

**Files:**
- Create: `src/pages/game-select/game-select.vue`

- [ ] **Step 1: 实现游戏选择页**

File: `src/pages/game-select/game-select.vue`

```vue
<template>
  <view class="page">
    <text class="page-title">选择训练游戏</text>
    <view
      v-for="game in games"
      :key="game.type"
      class="game-card"
      :style="{ borderColor: game.color }"
      @tap="selectGame(game.type)"
    >
      <text class="game-icon">{{ game.icon }}</text>
      <view class="game-info">
        <text class="game-name">{{ game.name }}</text>
        <text class="game-desc">{{ game.desc }}</text>
      </view>
      <text class="game-arrow" :style="{ color: game.color }">›</text>
    </view>
  </view>
</template>

<script setup lang="ts">
const games = [
  { type: 'number', name: '数字顺序点击', desc: '5×5网格，从小到大依次点击', icon: '🎯', color: '#C49B8B' },
  { type: 'color', name: '颜色识别挑战', desc: 'Stroop干扰，判断文字颜色', icon: '🌈', color: '#A8B5A0' },
  { type: 'memory', name: '数字记忆挑战', desc: '7位数字序列记忆', icon: '🧠', color: '#9BA8C0' },
]

function selectGame(type: string) {
  const routes: Record<string, string> = {
    number: '/pages/game-number/game-number',
    color: '/pages/game-color/game-color',
    memory: '/pages/game-memory/game-memory',
  }
  uni.navigateTo({ url: routes[type] })
}
</script>

<style scoped>
.page { padding: 30rpx; }
.page-title { font-size: 40rpx; font-weight: bold; display: block; margin-bottom: 30rpx; }
.game-card {
  display: flex;
  align-items: center;
  gap: 24rpx;
  background: #fff;
  border-radius: 16rpx;
  padding: 32rpx;
  margin-bottom: 20rpx;
  border-left: 8rpx solid;
}
.game-icon { font-size: 56rpx; }
.game-info { flex: 1; }
.game-name { font-size: 32rpx; font-weight: bold; display: block; }
.game-desc { font-size: 24rpx; color: #999; }
.game-arrow { font-size: 48rpx; }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/game-select/ && git commit -m "feat: add game select page"
```

---

## Phase 5: 游戏页面

### Task 16: 游戏 1 — 数字顺序点击

**Files:**
- Create: `src/pages/game-number/game-number.vue`

- [ ] **Step 1: 实现游戏 1（介绍页 + 游戏页组件切换）**

File: `src/pages/game-number/game-number.vue`

```vue
<template>
  <view>
    <!-- 介绍页 -->
    <GameIntro
      v-if="phase === 'intro'"
      icon="🎯"
      title="数字顺序点击"
      rules="1~25 随机排列在 5×5 网格中，按从小到大顺序（1→2→3...→25）依次点击。点错立即失败！30 秒内完成全部 25 个数字。"
      abilities="视觉搜索速度、信息筛选能力、决策速度"
      accent-color="#C49B8B"
      @start="startGame"
    />

    <!-- 游戏页 -->
    <view v-else class="game-page">
      <view class="top-bar" style="background: #C49B8B">
        <CountdownTimer ref="timerRef" :total-seconds="30" :running="phase === 'playing'" @timeout="onTimeout" />
        <text class="target-text">目标: {{ target }}</text>
      </view>

      <view class="grid-container">
        <NumberGrid
          :grid="grid"
          :completed-set="completedSet"
          :disabled="phase !== 'playing'"
          accent-color="#C49B8B"
          @cell-click="onCellClick"
        />
      </view>

      <ResultModal
        :visible="phase === 'passed' || phase === 'failed'"
        :result="phase === 'passed' ? 'passed' : 'failed'"
        :score-text="resultText"
        title-passed="太棒了！"
        :title-failed="failedReason === 'wrong' ? '点错了！' : '时间到！'"
        accent-color="#C49B8B"
        @retry="resetGame"
        @back="goBack"
      />
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { generateNumberGrid } from '@/utils/game-generator'
import { useTrainingStore } from '@/stores/training'
import { useUserStore } from '@/stores/user'
import GameIntro from '@/components/GameIntro.vue'
import CountdownTimer from '@/components/CountdownTimer.vue'
import NumberGrid from '@/components/NumberGrid.vue'
import ResultModal from '@/components/ResultModal.vue'

const training = useTrainingStore()
const user = useUserStore()
const phase = ref<'intro' | 'playing' | 'passed' | 'failed'>('intro')
const target = ref(1)
const grid = ref<number[][]>([])
const completedSet = reactive(new Set<number>())
const timerRef = ref()
const startTime = ref(0)
const failedReason = ref<'wrong' | 'timeout'>('wrong')
const resultText = ref('')

function startGame() {
  grid.value = generateNumberGrid()
  target.value = 1
  completedSet.clear()
  startTime.value = Date.now()
  failedReason.value = 'wrong'
  phase.value = 'playing'
}

function onCellClick(_row: number, _col: number, value: number) {
  if (value === target.value) {
    completedSet.add(value)
    if (value === 25) {
      const elapsed = Math.round((Date.now() - startTime.value) / 100) / 10
      const passed = elapsed < 20
      phase.value = passed ? 'passed' : 'failed'
      resultText.value = `耗时 ${elapsed} 秒`
      saveRecord(elapsed, passed)
    } else {
      target.value++
    }
  } else {
    failedReason.value = 'wrong'
    phase.value = 'failed'
    resultText.value = `止步于数字 ${target.value}`
    saveRecord(Math.round((Date.now() - startTime.value) / 100) / 10, false)
  }
}

function onTimeout() {
  if (phase.value === 'playing') {
    failedReason.value = 'timeout'
    phase.value = 'failed'
    resultText.value = `止步于数字 ${target.value}`
    saveRecord(30, false)
  }
}

async function saveRecord(score: number, passed: boolean) {
  await training.addRecord({
    user_id: user.openid,
    game_type: 'number',
    score,
    result: passed ? 'pass' : 'fail',
  })
}

function resetGame() {
  phase.value = 'intro'
}

function goBack() {
  uni.navigateBack()
}
</script>

<style scoped>
.game-page { min-height: 100vh; background: #f5f5f5; }
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20rpx 30rpx;
  color: #fff;
}
.target-text { font-size: 32rpx; font-weight: bold; }
.grid-container { padding: 30rpx; display: flex; justify-content: center; }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/game-number/ && git commit -m "feat: add game 1 - number sequence click"
```

---

### Task 17: 游戏 2 — 颜色 Stroop

**Files:**
- Create: `src/pages/game-color/game-color.vue`

- [ ] **Step 1: 实现游戏 2**

File: `src/pages/game-color/game-color.vue`

```vue
<template>
  <view>
    <GameIntro
      v-if="phase === 'intro'"
      icon="🌈"
      title="颜色识别挑战"
      rules="判断屏幕中央文字的显示颜色（不是文字含义）。每题 2 秒倒计时，1 分钟内尽可能多答对！"
      abilities="抗干扰能力、反应速度、选择性注意"
      accent-color="#A8B5A0"
      @start="startGame"
    />

    <view v-else class="game-page">
      <view class="top-bar" style="background: #A8B5A0">
        <CountdownTimer ref="gameTimerRef" :total-seconds="60" :running="phase === 'playing'" @timeout="onGameTimeout" />
        <text class="score-text">正确: {{ correctCount }}</text>
      </view>

      <view class="content">
        <!-- 大字显示 -->
        <text class="big-char" :style="{ color: currentQ?.colorValue }">{{ currentQ?.text }}</text>

        <!-- 选项 -->
        <view class="options">
          <button
            v-for="(opt, i) in currentQ?.options"
            :key="i"
            class="option-btn"
            @tap="() => answer(opt)"
          >{{ opt }}</button>
        </view>

        <!-- 2秒进度条 -->
        <view class="progress-bar">
          <view class="progress-fill" :style="{ width: progressPct + '%' }" />
        </view>
      </view>

      <ResultModal
        :visible="phase === 'passed' || phase === 'failed'"
        :result="phase === 'passed' ? 'passed' : 'failed'"
        :score-text="`1 分钟内答对 ${correctCount} 题`"
        title-passed="挑战完成！"
        title-failed="时间到！"
        accent-color="#A8B5A0"
        @retry="resetGame"
        @back="goBack"
      />
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onUnmounted } from 'vue'
import { generateColorQuestion } from '@/utils/game-generator'
import { useTrainingStore } from '@/stores/training'
import { useUserStore } from '@/stores/user'
import GameIntro from '@/components/GameIntro.vue'
import CountdownTimer from '@/components/CountdownTimer.vue'
import ResultModal from '@/components/ResultModal.vue'

const training = useTrainingStore()
const user = useUserStore()
const phase = ref<'intro' | 'playing' | 'passed' | 'failed'>('intro')
const correctCount = ref(0)
const currentQ = ref(generateColorQuestion())
const progressPct = ref(100)
let questionTimer: ReturnType<typeof setInterval> | null = null
let progressInterval: ReturnType<typeof setInterval> | null = null

function startGame() {
  correctCount.value = 0
  phase.value = 'playing'
  nextQuestion()
}

function nextQuestion() {
  if (questionTimer) clearInterval(questionTimer)
  if (progressInterval) clearInterval(progressInterval)

  currentQ.value = generateColorQuestion()
  progressPct.value = 100

  const start = Date.now()
  progressInterval = setInterval(() => {
    const elapsed = Date.now() - start
    progressPct.value = Math.max(0, 100 - (elapsed / 2000) * 100)
  }, 50)

  questionTimer = setTimeout(() => {
    if (phase.value === 'playing') nextQuestion()
  }, 2000)
}

function answer(selected: string) {
  if (phase.value !== 'playing') return
  if (selected === currentQ.value.color) {
    correctCount.value++
  }
  nextQuestion()
}

function onGameTimeout() {
  phase.value = 'failed'
  cleanup()
  saveRecord()
}

async function saveRecord() {
  await training.addRecord({
    user_id: user.openid,
    game_type: 'color',
    score: correctCount.value,
    result: 'pass',
  })
}

function cleanup() {
  if (questionTimer) clearTimeout(questionTimer)
  if (progressInterval) clearInterval(progressInterval)
}

function resetGame() { phase.value = 'intro' }
function goBack() { uni.navigateBack() }

onUnmounted(cleanup)
</script>

<style scoped>
.game-page { min-height: 100vh; background: #f5f5f5; }
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20rpx 30rpx;
  color: #fff;
}
.score-text { font-size: 28rpx; }
.content {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 120rpx;
  gap: 60rpx;
}
.big-char { font-size: 160rpx; font-weight: 900; }
.options { display: flex; gap: 24rpx; }
.option-btn {
  width: 160rpx;
  height: 80rpx;
  background: #fff;
  border-radius: 40rpx;
  font-size: 32rpx;
  border: 2rpx solid #ddd;
  display: flex;
  align-items: center;
  justify-content: center;
}
.progress-bar {
  width: 500rpx;
  height: 8rpx;
  background: #eee;
  border-radius: 4rpx;
  overflow: hidden;
}
.progress-fill {
  height: 100%;
  background: #A8B5A0;
  transition: width 0.05s linear;
}
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/game-color/ && git commit -m "feat: add game 2 - color Stroop"
```

---

### Task 18: 游戏 3 — 数字记忆

**Files:**
- Create: `src/pages/game-memory/game-memory.vue`

- [ ] **Step 1: 实现游戏 3**

File: `src/pages/game-memory/game-memory.vue`

```vue
<template>
  <view>
    <GameIntro
      v-if="phase === 'intro'"
      icon="🧠"
      title="数字记忆挑战"
      rules="7 个数字将依次展示（每个 2 秒）。记住它们及其顺序，然后在 5×5 网格中按顺序找出它们。全部正确即获胜！"
      abilities="短时记忆、注意力维持、顺序记忆"
      accent-color="#9BA8C0"
      @start="startGame"
    />

    <!-- 展示阶段 -->
    <view v-else-if="phase === 'showing'" class="show-stage">
      <text class="show-num">{{ currentShowNum }}</text>
      <text class="show-progress">{{ showIndex + 1 }} / 7</text>
    </view>

    <!-- 作答阶段 -->
    <view v-else class="game-page">
      <view class="top-bar" style="background: #9BA8C0">
        <text class="top-title">请按顺序选出数字</text>
        <text class="top-progress">第 {{ answerIndex + 1 }} / 7 个</text>
      </view>

      <view class="grid-container">
        <NumberGrid
          :grid="grid"
          :completed-set="completedSet"
          :disabled="false"
          accent-color="#9BA8C0"
          @cell-click="onCellClick"
        />
      </view>

      <ResultModal
        :visible="phase === 'passed' || phase === 'failed'"
        :result="phase === 'passed' ? 'passed' : 'failed'"
        :score-text="phase === 'passed' ? '全部正确！' : `第 ${answerIndex + 1} 个数字错误`"
        title-passed="记忆达人！"
        title-failed="再试试！"
        accent-color="#9BA8C0"
        @retry="resetGame"
        @back="goBack"
      />
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { generateMemorySequence, generateOrderedGrid } from '@/utils/game-generator'
import { useTrainingStore } from '@/stores/training'
import { useUserStore } from '@/stores/user'
import GameIntro from '@/components/GameIntro.vue'
import NumberGrid from '@/components/NumberGrid.vue'
import ResultModal from '@/components/ResultModal.vue'

const training = useTrainingStore()
const user = useUserStore()
const phase = ref<'intro' | 'showing' | 'answering' | 'passed' | 'failed'>('intro')
const targetSequence = ref<number[]>([])
const showIndex = ref(0)
const currentShowNum = ref(0)
const answerIndex = ref(0)
const grid = ref<number[][]>([])
const completedSet = ref(new Set<number>())

function startGame() {
  targetSequence.value = generateMemorySequence()
  grid.value = generateOrderedGrid()
  showIndex.value = 0
  answerIndex.value = 0
  completedSet.value = new Set()
  phase.value = 'showing'
  showNext()
}

function showNext() {
  if (showIndex.value >= 7) {
    phase.value = 'answering'
    return
  }
  currentShowNum.value = targetSequence.value[showIndex.value]
  setTimeout(() => {
    currentShowNum.value = 0
    setTimeout(() => {
      showIndex.value++
      showNext()
    }, 500)
  }, 2000)
}

function onCellClick(_row: number, _col: number, value: number) {
  if (phase.value !== 'answering') return
  if (value === targetSequence.value[answerIndex.value]) {
    completedSet.value.add(value)
    answerIndex.value++
    if (answerIndex.value >= 7) {
      phase.value = 'passed'
      saveRecord(true)
    }
  } else {
    phase.value = 'failed'
    saveRecord(false)
  }
}

async function saveRecord(passed: boolean) {
  await training.addRecord({
    user_id: user.openid,
    game_type: 'memory',
    score: passed ? 1 : 0,
    result: passed ? 'pass' : 'fail',
  })
}

function resetGame() { phase.value = 'intro' }
function goBack() { uni.navigateBack() }
</script>

<style scoped>
.show-stage {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
}
.show-num { font-size: 200rpx; font-weight: 900; color: #9BA8C0; }
.show-progress { font-size: 28rpx; color: #999; margin-top: 40rpx; }
.game-page { min-height: 100vh; background: #f5f5f5; }
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20rpx 30rpx;
  color: #fff;
}
.top-title { font-size: 28rpx; }
.top-progress { font-size: 26rpx; }
.grid-container { padding: 30rpx; display: flex; justify-content: center; }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/game-memory/ && git commit -m "feat: add game 3 - number memory"
```

---

## Phase 6: uniCloud 后端

### Task 19: 配置 uniCloud 数据库与云函数

**Files:**
- Create: `uniCloud-aliyun/database/users.schema.json`
- Create: `uniCloud-aliyun/database/training_records.schema.json`
- Create: `uniCloud-aliyun/cloudfunctions/getOpenid/index.js`
- Create: `uniCloud-aliyun/cloudfunctions/getOpenid/package.json`

- [ ] **Step 1: 创建 uniCloud 服务空间**

在微信开发者工具中或通过 uni-app 控制台创建 uniCloud 服务空间，然后在项目中关联。

- [ ] **Step 2: 创建 users 表 schema**

File: `uniCloud-aliyun/database/users.schema.json`

```json
{
  "bsonType": "object",
  "required": ["openid"],
  "permission": {
    "read": "doc._id == auth.uid",
    "create": true,
    "update": "doc._id == auth.uid",
    "delete": false
  },
  "properties": {
    "_id": { "bsonType": "string" },
    "openid": { "bsonType": "string", "description": "微信openid" },
    "nickname": { "bsonType": "string", "description": "微信昵称" },
    "avatar": { "bsonType": "string", "description": "头像URL" },
    "phone": { "bsonType": "string", "description": "手机号" },
    "created_at": { "bsonType": "timestamp", "description": "注册时间" }
  }
}
```

- [ ] **Step 3: 创建 training_records 表 schema**

File: `uniCloud-aliyun/database/training_records.schema.json`

```json
{
  "bsonType": "object",
  "required": ["user_id", "game_type", "score", "result", "date"],
  "permission": {
    "read": true,
    "create": true,
    "update": false,
    "delete": false
  },
  "properties": {
    "_id": { "bsonType": "string" },
    "user_id": { "bsonType": "string", "description": "关联users._id" },
    "game_type": { "bsonType": "string", "enum": ["number", "color", "memory"], "description": "游戏类型" },
    "score": { "bsonType": "int", "description": "成绩" },
    "result": { "bsonType": "string", "enum": ["pass", "fail"], "description": "结果" },
    "date": { "bsonType": "string", "description": "训练日期 YYYY-MM-DD" },
    "created_at": { "bsonType": "timestamp", "description": "创建时间" }
  }
}
```

- [ ] **Step 4: 创建 getOpenid 云函数**

File: `uniCloud-aliyun/cloudfunctions/getOpenid/index.js`

```javascript
'use strict'
exports.main = async (event, context) => {
  const { code } = event
  const res = await uniCloud.httpclient.request(
    `https://api.weixin.qq.com/sns/jscode2session?appid=${context.APPID}&secret=${context.APPSECRET}&js_code=${code}&grant_type=authorization_code`,
    { dataType: 'json' }
  )
  return { openid: res.data.openid }
}
```

File: `uniCloud-aliyun/cloudfunctions/getOpenid/package.json`

```json
{
  "name": "getOpenid",
  "version": "1.0.0",
  "main": "index.js"
}
```

- [ ] **Step 5: Commit**

```bash
git add uniCloud-aliyun/ && git commit -m "feat: add uniCloud database schemas and cloud functions"
```

---

## Phase 7: 收尾

### Task 20: App.vue 与入口文件

**Files:**
- Modify: `src/App.vue`
- Verify: `src/main.ts`

- [ ] **Step 1: 更新 App.vue**

```vue
<script setup lang="ts">
import { onLaunch } from '@dcloudio/uni-app'

onLaunch(async () => {
  // 静默登录
  const { useUserStore } = await import('@/stores/user')
  const userStore = useUserStore()
  try {
    await userStore.login()
  } catch {
    // 静默登录失败，用户可稍后手动登录
  }
})
</script>

<style>
/* 全局样式已在 uni.scss 中定义 */
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/App.vue && git commit -m "feat: add silent login on app launch"
```

---

### Task 21: 最终验证与测试

- [ ] **Step 1: 编译验证**

```bash
cd /Users/chenjingyi/Documents/test/claude/project/focus-trainer
npx uni-app run -p mp-weixin
```

Expected: 无编译错误

- [ ] **Step 2: 在微信开发者工具中导入 `dist/dev/mp-weixin` 目录，验证所有页面和TabBar正常显示**

- [ ] **Step 3: 提交最终版本**

```bash
git add -A && git commit -m "feat: complete focus training mini program"
```
