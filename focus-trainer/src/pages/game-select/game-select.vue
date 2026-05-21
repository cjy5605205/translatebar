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
