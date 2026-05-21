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
      <button class="btn-wx-login" @tap="handleLogin">微信一键登录</button>
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
          <text class="stat-num">{{ bestNumber }}</text>
          <text class="stat-label">数字顺序最佳</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">{{ bestColor }}</text>
          <text class="stat-label">颜色识别最佳</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">{{ memoryPass }}</text>
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
const memoryPass = ref(0)

async function handleLogin() {
  await user.login()
}
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
