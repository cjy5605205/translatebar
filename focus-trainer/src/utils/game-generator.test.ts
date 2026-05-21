import { shuffle, generateNumberGrid, generateColorQuestion, generateMemorySequence, generateOrderedGrid } from './game-generator'

function test(name: string, fn: () => boolean | void) {
  try {
    fn()
    console.log(`  PASS: ${name}`)
  } catch (e) {
    console.log(`  FAIL: ${name} - ${e}`)
  }
}

console.log('Testing game-generator...')

test('shuffle preserves all elements', () => {
  const original = [1, 2, 3, 4, 5]
  const shuffled = shuffle(original)
  if (shuffled.sort((a, b) => a - b).join(',') !== '1,2,3,4,5') {
    throw new Error('Elements not preserved')
  }
  if (shuffled.length !== original.length) {
    throw new Error('Length mismatch')
  }
})

test('shuffle does not mutate original', () => {
  const original = [1, 2, 3, 4, 5]
  const copy = [...original]
  shuffle(original)
  if (original.join(',') !== copy.join(',')) {
    throw new Error('Original was mutated')
  }
})

test('generateNumberGrid returns 5x5 grid', () => {
  const grid = generateNumberGrid()
  if (grid.length !== 5) throw new Error('Not 5 rows')
  grid.forEach(row => { if (row.length !== 5) throw new Error('Row not length 5') })
})

test('generateNumberGrid contains all numbers 1-25', () => {
  const grid = generateNumberGrid()
  const flat = grid.flat().sort((a, b) => a - b)
  for (let i = 0; i < 25; i++) {
    if (flat[i] !== i + 1) throw new Error(`Missing ${i + 1}`)
  }
})

test('generateColorQuestion returns valid structure', () => {
  const q = generateColorQuestion()
  if (!q.text || !q.color || !q.colorValue || !q.options) throw new Error('Missing fields')
  if (q.text === q.color) throw new Error('Text and color should differ')
  if (q.options.length !== 3) throw new Error('Should have 3 options')
  if (!q.options.includes(q.color)) throw new Error('Correct answer not in options')
})

test('generateMemorySequence returns 7 unique numbers', () => {
  const seq = generateMemorySequence()
  if (seq.length !== 7) throw new Error('Not 7 numbers')
  const set = new Set(seq)
  if (set.size !== 7) throw new Error('Has duplicates')
  seq.forEach(n => { if (n < 1 || n > 25) throw new Error(`Number ${n} out of range`) })
})

test('generateOrderedGrid returns 1-25 in order', () => {
  const grid = generateOrderedGrid()
  const flat = grid.flat()
  for (let i = 0; i < 25; i++) {
    if (flat[i] !== i + 1) throw new Error(`Expected ${i + 1}, got ${flat[i]}`)
  }
})

console.log('Done!')
