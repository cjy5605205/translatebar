import { generateColorQuestion, COLOR_WORDS } from '../../utils/game-generator'

let passed = 0
let failed = 0
function test(name: string, fn: () => void | boolean) {
  try {
    const r = fn()
    if (r === false) throw new Error('false')
    passed++
    console.log(`  PASS: ${name}`)
  } catch (e: any) {
    failed++
    console.log(`  FAIL: ${name} - ${e.message}`)
  }
}

console.log('Testing Game 2 - Color Stroop...')

test('question text and color differ', () => {
  for (let i = 0; i < 50; i++) {
    const q = generateColorQuestion()
    if (q.text === q.color) return false
  }
})

test('question returns 3 options including correct answer', () => {
  for (let i = 0; i < 50; i++) {
    const q = generateColorQuestion()
    if (q.options.length !== 3) return false
    if (!q.options.includes(q.color)) return false
  }
})

test('options always contain the text word', () => {
  for (let i = 0; i < 50; i++) {
    const q = generateColorQuestion()
    if (!q.options.includes(q.text)) return false
  }
})

test('distractor differs from both text and color', () => {
  for (let i = 0; i < 50; i++) {
    const q = generateColorQuestion()
    const distractor = q.options.find(o => o !== q.text && o !== q.color)
    if (!distractor) return false
    if (distractor === q.text || distractor === q.color) return false
  }
})

test('colorValue is a valid hex color', () => {
  const q = generateColorQuestion()
  if (!q.colorValue) return false
  if (!q.colorValue.startsWith('#')) return false
})

console.log(`\n${passed} passed, ${failed} failed`)
if (failed > 0) process.exit(1)
