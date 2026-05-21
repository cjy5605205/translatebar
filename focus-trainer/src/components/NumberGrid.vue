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
