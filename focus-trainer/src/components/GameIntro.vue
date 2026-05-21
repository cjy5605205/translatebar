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
