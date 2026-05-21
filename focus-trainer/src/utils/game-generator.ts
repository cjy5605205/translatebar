/** Fisher-Yates 洗牌 */
export function shuffle<T>(arr: T[]): T[] {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

/** 生成游戏1的 5x5 网格：1~25 随机排列 */
export function generateNumberGrid(): number[][] {
  const nums = shuffle(Array.from({ length: 25 }, (_, i) => i + 1))
  const grid: number[][] = []
  for (let i = 0; i < 5; i++) {
    grid.push(nums.slice(i * 5, (i + 1) * 5))
  }
  return grid
}

const COLOR_WORDS = ['红', '橙', '黄', '绿', '青', '蓝', '紫']
const COLOR_VALUES: Record<string, string> = {
  '红': '#E74C3C',
  '橙': '#E67E22',
  '黄': '#F1C40F',
  '绿': '#2ECC71',
  '青': '#1ABC9C',
  '蓝': '#3498DB',
  '紫': '#9B59B6',
}

/** 生成游戏2的一道题 */
export function generateColorQuestion() {
  const text = COLOR_WORDS[Math.floor(Math.random() * COLOR_WORDS.length)]
  // 颜色不能和文字含义相同
  const availableColors = COLOR_WORDS.filter(c => c !== text)
  const color = availableColors[Math.floor(Math.random() * availableColors.length)]
  // 干扰项：不等于文字含义也不等于实际颜色
  const distractors = COLOR_WORDS.filter(c => c !== text && c !== color)
  const distractor = distractors[Math.floor(Math.random() * distractors.length)]
  return {
    text,
    color,
    colorValue: COLOR_VALUES[color],
    options: shuffle([text, color, distractor]),
  }
}

/** 生成游戏3的目标序列：从 1~25 随机选 7 个不重复数字 */
export function generateMemorySequence(): number[] {
  const nums = shuffle(Array.from({ length: 25 }, (_, i) => i + 1))
  return nums.slice(0, 7)
}

/** 生成 1~25 的有序 5x5 网格（用于游戏3作答） */
export function generateOrderedGrid(): number[][] {
  const grid: number[][] = []
  for (let i = 0; i < 5; i++) {
    grid.push(Array.from({ length: 5 }, (_, j) => i * 5 + j + 1))
  }
  return grid
}

export { COLOR_WORDS, COLOR_VALUES }
