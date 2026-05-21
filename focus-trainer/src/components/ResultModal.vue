<template>
  <view class="overlay" v-if="visible" @tap="emit('close')">
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
defineProps<{
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
