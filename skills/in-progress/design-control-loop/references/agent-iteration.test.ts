import { describe, expect, test } from 'bun:test'
import { renderFooter, stripIterateCommand } from './agent-iteration'

describe('agent iteration helper', () => {
  test('strips /iterate prefix and preserves feedback', () => {
    expect(stripIterateCommand('/iterate fix the second issue')).toBe('fix the second issue')
  })

  test('uses a default request when feedback is empty', () => {
    expect(stripIterateCommand('/iterate   ')).toBe('Iterate on this PR using the available feedback.')
  })

  test('renders a marker with a safe relative memory path', () => {
    expect(renderFooter('agent-loop', '.github/agent-memory/task.md')).toContain(
      '<!-- agent-control-loop:workflow=agent-loop;memory=.github/agent-memory/task.md;version=1 -->',
    )
  })

  test('rejects unsafe workflow identifiers and paths', () => {
    expect(() => renderFooter('../oops', 'memory.md')).toThrow()
    expect(() => renderFooter('agent-loop', '../secrets')).toThrow()
    expect(() => renderFooter('agent-loop', '/tmp/memory.md')).toThrow()
  })
})
