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
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useUserStore } from '@/stores/user'
import { useTrainingStore } from '@/stores/training'

const user = useUserStore()
const training = useTrainingStore()
const streak = ref(0)

const todayMinutes = computed(() => training.todayRecords.length * 1)

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
