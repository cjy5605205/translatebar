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
    timer = null
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
