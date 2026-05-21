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

const weekdays = ['日', '一', '二', '三', '四', '五', '六']
const year = ref(new Date().getFullYear())
const month = ref(new Date().getMonth() + 1)
const selectedDate = ref('')
const selectedRecords = ref<any[]>([])
const calendarData = ref<Record<string, { number: boolean; color: boolean; memory: boolean }>>({})

const calendarCells = computed(() => {
  const y = year.value
  const m = month.value
  const firstDay = new Date(y, m - 1, 1).getDay()
  const daysInMonth = new Date(y, m, 0).getDate()
  const daysInPrevMonth = new Date(y, m - 1, 0).getDate()
  const cells: any[] = []

  for (let i = firstDay - 1; i >= 0; i--) {
    cells.push({ day: daysInPrevMonth - i, isCurrentMonth: false })
  }
  for (let d = 1; d <= daysInMonth; d++) {
    const dateKey = `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`
    cells.push({
      day: d,
      isCurrentMonth: true,
      date: dateKey,
      games: calendarData.value[dateKey] || { number: false, color: false, memory: false },
    })
  }
  const remaining = 7 - (cells.length % 7)
  if (remaining < 7) {
    for (let d = 1; d <= remaining; d++) {
      cells.push({ day: d, isCurrentMonth: false })
    }
  }
  return cells
})

async function loadCalendar() {
  try {
    const db = uniCloud.database()
    const startDate = `${year.value}-${String(month.value).padStart(2, '0')}-01`
    const nextMonth = month.value === 12 ? 1 : month.value + 1
    const nextYear = month.value === 12 ? year.value + 1 : year.value
    const endDate = `${nextYear}-${String(nextMonth).padStart(2, '0')}-01`
    const res = await db.collection('training_records')
      .where({
        date: db.command.gte(startDate).and(db.command.lt(endDate)),
      })
      .get()
    const records = (res.result.data || []) as any[]
    const data: Record<string, { number: boolean; color: boolean; memory: boolean }> = {}
    for (const r of records) {
      if (!data[r.date]) data[r.date] = { number: false, color: false, memory: false }
      data[r.date][r.game_type] = true
    }
    calendarData.value = data
  } catch {
    calendarData.value = {}
  }
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
  try {
    const db = uniCloud.database()
    const res = await db.collection('training_records').where({ date }).get()
    selectedRecords.value = (res.result.data || []) as any[]
  } catch {
    selectedRecords.value = []
  }
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
.detail-title { font-size: 30rpx; font-weight: bold; display: block; margin-bottom: 16rpx; }
.empty { padding: 40rpx; text-align: center; color: #999; }
.record-item { display: flex; justify-content: space-between; padding: 16rpx 0; border-bottom: 1rpx solid #f0f0f0; }
</style>
