import type { TrainingRecord, GameType, GameResult } from '@/stores/training'

const db = uniCloud.database()

/** 获取或创建用户 */
export async function getOrCreateUser(openid: string) {
  const res = await db.collection('users').where({ openid }).get()
  if (res.result.data.length > 0) {
    return res.result.data[0]
  }
  const createRes = await db.collection('users').add({
    openid,
    created_at: Date.now(),
  })
  return { _id: createRes.result.id, openid }
}

/** 保存训练记录 */
export async function saveTrainingRecord(params: {
  user_id: string
  game_type: GameType
  score: number
  result: GameResult
}) {
  const d = new Date()
  const date = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  return db.collection('training_records').add({
    ...params,
    date,
    created_at: Date.now(),
  })
}

/** 获取指定月份的训练记录 */
export async function getMonthRecords(year: number, month: number) {
  const startDate = `${year}-${String(month).padStart(2, '0')}-01`
  const nextMonth = month === 12 ? 1 : month + 1
  const nextYear = month === 12 ? year + 1 : year
  const endDate = `${nextYear}-${String(nextMonth).padStart(2, '0')}-01`
  const res = await db.collection('training_records')
    .where({
      date: db.command.gte(startDate).and(db.command.lt(endDate)),
    })
    .orderBy('created_at', 'desc')
    .get()
  return res.result.data as TrainingRecord[]
}

/** 获取今日训练记录 */
export async function getTodayRecords() {
  const d = new Date()
  const date = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  const res = await db.collection('training_records')
    .where({ date })
    .orderBy('created_at', 'desc')
    .get()
  return res.result.data as TrainingRecord[]
}
