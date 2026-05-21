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
        <text class="big-char" :style="{ color: currentQ?.colorValue }">{{ currentQ?.text }}</text>

        <view class="options">
          <button
            v-for="(opt, i) in currentQ?.options"
            :key="i"
            class="option-btn"
            @tap="() => answer(opt)"
          >{{ opt }}</button>
        </view>

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
let questionTimer: ReturnType<typeof setTimeout> | null = null
let progressInterval: ReturnType<typeof setInterval> | null = null

function startGame() {
  correctCount.value = 0
  phase.value = 'playing'
  nextQuestion()
}

function nextQuestion() {
  if (questionTimer) clearTimeout(questionTimer)
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
