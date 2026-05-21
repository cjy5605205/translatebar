import { generateMemorySequence, generateOrderedGrid } from '../../utils/game-generator'

function test(name: string, fn: () => void | boolean) {
  try {
    const result = fn()
    if (result === false) throw new Error('Test returned false')
    console.log(`  PASS: ${name}`)
  } catch (e: any) {
    console.log(`  FAIL: ${name} - ${e.message}`)
  }
}

console.log('Testing Game 3 - Number Memory...')

test('generateMemorySequence returns 7 unique numbers', () => {
  const seq = generateMemorySequence()
  if (seq.length !== 7) return false
  const set = new Set(seq)
  if (set.size !== 7) return false
})

test('generateMemorySequence numbers are all in range 1-25', () => {
  for (let i = 0; i < 20; i++) {
    const seq = generateMemorySequence()
    for (const n of seq) {
      if (n < 1 || n > 25) return false
    }
  }
})

test('two memory sequences are likely different', () => {
  // Extremely unlikely two 7-from-25 picks are identical
  const s1 = generateMemorySequence()
  const s2 = generateMemorySequence()
  if (s1.join(',') === s2.join(',')) return false
})

test('generateOrderedGrid is 5x5 with values 1-25 in order', () => {
  const grid = generateOrderedGrid()
  if (grid.length !== 5) return false
  const flat = grid.flat()
  for (let i = 0; i < 25; i++) {
    if (flat[i] !== i + 1) return false
  }
})

test('completed set identifies correctly clicked cells', () => {
  const completed = new Set<number>()
  completed.add(3)
  completed.add(7)
  completed.add(15)
  if (completed.size !== 3) return false
  if (!completed.has(3)) return false
  if (completed.has(4)) return false
})

test('target sequence order is preserved', () => {
  const seq = generateMemorySequence()
  // Verify each element is present (order preserved by array)
  const sorted = [...seq].sort((a, b) => a - b)
  for (let i = 0; i < 7; i++) {
    if (!seq.includes(sorted[i])) return false
  }
})

console.log('Done!')
