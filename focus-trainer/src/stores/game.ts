import { defineStore } from 'pinia'
import { ref } from 'vue'

export type GameStatus = 'idle' | 'intro' | 'playing' | 'passed' | 'failed'

export const useGameStore = defineStore('game', () => {
  const currentGame = ref<'number' | 'color' | 'memory' | null>(null)
  const status = ref<GameStatus>('idle')
  const score = ref(0)

  function startIntro(game: 'number' | 'color' | 'memory') {
    currentGame.value = game
    status.value = 'intro'
    score.value = 0
  }

  function startGame() {
    status.value = 'playing'
    score.value = 0
  }

  function endGame(result: 'passed' | 'failed', finalScore: number) {
    status.value = result
    score.value = finalScore
  }

  function reset() {
    currentGame.value = null
    status.value = 'idle'
    score.value = 0
  }

  return { currentGame, status, score, startIntro, startGame, endGame, reset }
})
