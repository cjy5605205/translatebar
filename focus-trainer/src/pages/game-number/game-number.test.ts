import { generateNumberGrid } from '../../utils/game-generator'

function test(name: string, fn: () => void | boolean) {
  try {
    const result = fn()
    if (result === false) throw new Error('Test returned false')
    console.log(`  PASS: ${name}`)
  } catch (e: any) {
    console.log(`  FAIL: ${name} - ${e.message}`)
  }
}

console.log('Testing Game 1 - Number Sequence Click...')

test('generateNumberGrid returns 5x5 with all numbers 1-25', () => {
  const grid = generateNumberGrid()
  if (grid.length !== 5) return false
  const flat = grid.flat().sort((a, b) => a - b)
  for (let i = 0; i < 25; i++) {
    if (flat[i] !== i + 1) return false
  }
})

test('each number 1-25 appears exactly once', () => {
  const grid = generateNumberGrid()
  const counts = new Map<number, number>()
  grid.flat().forEach(n => counts.set(n, (counts.get(n) || 0) + 1))
  for (let i = 1; i <= 25; i++) {
    if (counts.get(i) !== 1) return false
  }
})

test('grid randomization - two grids are not identical', () => {
  const g1 = generateNumberGrid()
  const g2 = generateNumberGrid()
  // Extremely unlikely two 5x5 random shuffles are identical
  if (g1.flat().join(',') === g2.flat().join(',')) return false
})

test('completed set correctly identifies clicked cells', () => {
  const completed = new Set<number>()
  completed.add(1)
  completed.add(2)
  completed.add(3)
  if (completed.size !== 3) return false
  if (!completed.has(1)) return false
  if (completed.has(4)) return false
})

console.log('Done!')
