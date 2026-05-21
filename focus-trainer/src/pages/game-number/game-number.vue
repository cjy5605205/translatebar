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
  if (phase.value !== 'playing') return
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
    const elapsed = Math.round((Date.now() - startTime.value) / 100) / 10
    saveRecord(elapsed, false)
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
