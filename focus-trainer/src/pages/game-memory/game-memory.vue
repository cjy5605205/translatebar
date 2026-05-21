<template>
  <view>
    <GameIntro
      v-if="phase === 'intro'"
      icon="🧠"
      title="数字记忆挑战"
      rules="7 个数字将依次展示（每个 2 秒）。记住它们及其顺序，然后在 5×5 网格中按顺序找出它们。全部正确即获胜！"
      abilities="短时记忆、注意力维持、顺序记忆"
      accent-color="#9BA8C0"
      @start="startGame"
    />

    <!-- 展示阶段 -->
    <view v-else-if="phase === 'showing'" class="show-stage">
      <text class="show-num">{{ currentShowNum }}</text>
      <text class="show-progress">{{ showIndex + 1 }} / 7</text>
    </view>

    <!-- 作答阶段 -->
    <view v-else class="game-page">
      <view class="top-bar" style="background: #9BA8C0">
        <text class="top-title">请按顺序选出数字</text>
        <text class="top-progress">第 {{ answerIndex + 1 }} / 7 个</text>
      </view>

      <view class="grid-container">
        <NumberGrid
          :grid="grid"
          :completed-set="completedSet"
          :disabled="phase !== 'answering'"
          accent-color="#9BA8C0"
          @cell-click="onCellClick"
        />
      </view>

      <ResultModal
        :visible="phase === 'passed' || phase === 'failed'"
        :result="phase === 'passed' ? 'passed' : 'failed'"
        :score-text="phase === 'passed' ? '全部正确！' : `第 ${answerIndex + 1} 个数字错误`"
        title-passed="记忆达人！"
        title-failed="再试试！"
        accent-color="#9BA8C0"
        @retry="resetGame"
        @back="goBack"
      />
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { generateMemorySequence, generateOrderedGrid } from '@/utils/game-generator'
import { useTrainingStore } from '@/stores/training'
import { useUserStore } from '@/stores/user'
import GameIntro from '@/components/GameIntro.vue'
import NumberGrid from '@/components/NumberGrid.vue'
import ResultModal from '@/components/ResultModal.vue'

const training = useTrainingStore()
const user = useUserStore()
const phase = ref<'intro' | 'showing' | 'answering' | 'passed' | 'failed'>('intro')
const targetSequence = ref<number[]>([])
const showIndex = ref(0)
const currentShowNum = ref(0)
const answerIndex = ref(0)
const grid = ref<number[][]>([])
const completedSet = ref(new Set<number>())

function startGame() {
  targetSequence.value = generateMemorySequence()
  grid.value = generateOrderedGrid()
  showIndex.value = 0
  answerIndex.value = 0
  completedSet.value = new Set()
  phase.value = 'showing'
  showNext()
}

function showNext() {
  if (showIndex.value >= 7) {
    phase.value = 'answering'
    return
  }
  currentShowNum.value = targetSequence.value[showIndex.value]
  setTimeout(() => {
    currentShowNum.value = 0
    setTimeout(() => {
      showIndex.value++
      showNext()
    }, 500)
  }, 2000)
}

function onCellClick(_row: number, _col: number, value: number) {
  if (phase.value !== 'answering') return
  if (value === targetSequence.value[answerIndex.value]) {
    completedSet.value.add(value)
    answerIndex.value++
    if (answerIndex.value >= 7) {
      phase.value = 'passed'
      saveRecord(true)
    }
  } else {
    phase.value = 'failed'
    saveRecord(false)
  }
}

async function saveRecord(passed: boolean) {
  await training.addRecord({
    user_id: user.openid,
    game_type: 'memory',
    score: passed ? 1 : 0,
    result: passed ? 'pass' : 'fail',
  })
}

function resetGame() { phase.value = 'intro' }
function goBack() { uni.navigateBack() }
</script>

<style scoped>
.show-stage {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
}
.show-num { font-size: 200rpx; font-weight: 900; color: #9BA8C0; }
.show-progress { font-size: 28rpx; color: #999; margin-top: 40rpx; }
.game-page { min-height: 100vh; background: #f5f5f5; }
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20rpx 30rpx;
  color: #fff;
}
.top-title { font-size: 28rpx; }
.top-progress { font-size: 26rpx; }
.grid-container { padding: 30rpx; display: flex; justify-content: center; }
</style>
