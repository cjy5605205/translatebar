import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export type GameType = 'number' | 'color' | 'memory'
export type GameResult = 'pass' | 'fail'

export interface TrainingRecord {
  _id?: string
  user_id: string
  game_type: GameType
  score: number
  result: GameResult
  date: string
  created_at: number
}

export const useTrainingStore = defineStore('training', () => {
  const todayRecords = ref<TrainingRecord[]>([])
  const calendarData = ref<Record<string, { number: boolean; color: boolean; memory: boolean }>>({})

  const today = computed(() => {
    const d = new Date()
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  })

  const todayStats = computed(() => {
    const recs = todayRecords.value
    return {
      total: recs.length,
      completed: {
        number: recs.some(r => r.game_type === 'number'),
        color: recs.some(r => r.game_type === 'color'),
        memory: recs.some(r => r.game_type === 'memory'),
      },
    }
  })

  async function fetchTodayRecords() {
    try {
      const db = uniCloud.database()
      const res = await db.collection('training_records')
        .where({ date: today.value })
        .get()
      todayRecords.value = (res.result.data || []) as TrainingRecord[]
    } catch {
      todayRecords.value = []
    }
  }

  async function fetchCalendarData(year: number, month: number) {
    try {
      const db = uniCloud.database()
      const startDate = `${year}-${String(month).padStart(2, '0')}-01`
      const nextMonth = month === 12 ? 1 : month + 1
      const nextYear = month === 12 ? year + 1 : year
      const endDate = `${nextYear}-${String(nextMonth).padStart(2, '0')}-01`
      const res = await db.collection('training_records')
        .where({
          date: db.command.gte(startDate).and(db.command.lt(endDate)),
        })
        .get()
      const records = (res.result.data || []) as TrainingRecord[]
      const data: Record<string, { number: boolean; color: boolean; memory: boolean }> = {}
      for (const r of records) {
        if (!data[r.date]) {
          data[r.date] = { number: false, color: false, memory: false }
        }
        data[r.date][r.game_type] = true
      }
      calendarData.value = data
    } catch {
      calendarData.value = {}
    }
  }

  async function addRecord(record: Omit<TrainingRecord, '_id' | 'date' | 'created_at'>) {
    try {
      const db = uniCloud.database()
      await db.collection('training_records').add({
        ...record,
        date: today.value,
        created_at: Date.now(),
      })
      await fetchTodayRecords()
    } catch {
      // silently fail if offline
    }
  }

  return { todayRecords, calendarData, today, todayStats, fetchTodayRecords, fetchCalendarData, addRecord }
})
