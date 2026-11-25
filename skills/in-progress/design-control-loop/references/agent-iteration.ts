#!/usr/bin/env bun

// Shared helper for recurring coding-agent workflows.
//
// `footer` mode appends visible /iterate instructions plus a hidden workflow marker
// to agent-created PR bodies. The marker lets multiple workflows listen for the
// same command while only the workflow that opened the PR continues.
//
// `prompt` mode builds the iteration prompt after the workflow has passed its
// pre-check and checked out the PR branch. It includes PR context and the memory
// file, then asks the agent to update the PR and distill durable guidance.
//
// Usage:
//   bun scripts/agent-iteration.ts --command footer --workflow <id> --memory <path>
//   bun scripts/agent-iteration.ts --command prompt --workflow <id> --memory <path> --repo <owner/repo> --pr-number <number> --comment-body <body>

interface Args {
  command: 'footer' | 'prompt'
  workflow: string
  memory: string
  repo?: string
  prNumber?: string
  commentBody?: string
}

export function renderFooter(workflow: string, memory: string): string {
  if (!/^[a-zA-Z0-9._-]+$/.test(workflow)) throw new Error('workflow id contains unsupported characters')
  if (!/^[a-zA-Z0-9._/-]+$/.test(memory) || memory.startsWith('/') || memory.split('/').includes('..') || memory.split('/').includes('.')) {
    throw new Error('memory path must be a safe repository-relative path')
  }
  return `
---

### Iterating on this agent run

Maintainers can comment:

- \`/iterate <feedback>\` to ask this workflow to update the PR and learn durable guidance for future runs.

The workflow stores durable feedback in its agent memory file and injects that memory into future runs.

<!-- agent-control-loop:workflow=${workflow};memory=${memory};version=1 -->
`.trim()
}

export function stripIterateCommand(body: string): string {
  return body.trim().replace(/^\/iterate\b\s*/i, '').trim() || 'Iterate on this PR using the available feedback.'
}

async function renderIterationPrompt(args: Args): Promise<string> {
  const memory = await readTextIfExists(args.memory)
  const pr = await ghJson(`repos/${args.repo}/pulls/${args.prNumber}`)
  const [issueComments, reviewComments] = await Promise.all([
    ghJson(`repos/${args.repo}/issues/${args.prNumber}/comments`, true),
    ghJson(`repos/${args.repo}/pulls/${args.prNumber}/comments`, true),
  ])

  return `# Iteration Request

${stripIterateCommand(args.commentBody ?? '')}

# Workflow Identity

- Workflow: ${args.workflow}
- Agent memory file: ${args.memory}

# Instructions

You are iterating on an open PR created by this coding-agent workflow.

1. Treat the iteration request as the user's current instruction.
2. Update this PR branch if feedback asks for a code, workflow, prompt, or documentation change.
3. Distill durable feedback into ${args.memory} only when it should influence future runs.
4. Keep memory concise and human-readable. Do not append transcripts or one-off PR details.
5. If feedback is only PR-specific, update the PR but not memory.
6. Commit and push changes only when the workflow and repository policies allow it.
7. Finish with a concise summary of changes and whether memory was updated.

# Current Agent Memory

${memory || '(memory file is empty or missing)'}

# Pull Request

- Number: #${pr.number}
- Title: ${pr.title}
- State: ${pr.state}
- Base: ${pr.base?.ref ?? '(unknown)'}
- Head: ${pr.head?.ref ?? '(unknown)'}

## PR Body

${pr.body ?? '(empty)'}

# PR Issue Comments

${formatComments(issueComments, false)}

# PR Review Comments

${formatComments(reviewComments, true)}
`
}

async function readTextIfExists(path: string): Promise<string> {
  try {
    const file = Bun.file(path)
    if (!(await file.exists())) return ''
    return await file.text()
  } catch {
    return ''
  }
}

async function ghJson(endpoint: string, paginate = false): Promise<any> {
  const args = ['api', ...(paginate ? ['--paginate'] : []), endpoint]
  const proc = Bun.spawn(['gh', ...args], { stdout: 'pipe', stderr: 'pipe' })
  const [stdout, stderr, exitCode] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ])
  if (exitCode !== 0) throw new Error(`gh api failed (${exitCode}): ${stderr.trim()}`)
  const parsed = JSON.parse(stdout)
  if (paginate && !Array.isArray(parsed)) throw new Error(`Expected paginated array from GitHub API: ${endpoint}`)
  return parsed
}

function formatComments(comments: any, review: boolean): string {
  if (!Array.isArray(comments) || comments.length === 0) return '(no comments)'
  return comments.map((comment) => {
    const kind = review ? `Review comment ${comment.id} on ${comment.path ?? 'unknown path'}:${comment.line ?? comment.original_line ?? 'unknown line'}` : `Comment ${comment.id}`
    return `${kind} by ${comment.user?.login ?? 'unknown'} at ${comment.created_at ?? 'unknown time'}:\n\n${comment.body ?? ''}`
  }).join('\n\n---\n\n')
}

function parseArgs(argv: string[]): Args {
  const parsed: Record<string, string> = {}
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i]
    if (!arg?.startsWith('--')) continue
    const key = arg.slice(2)
    const value = argv[i + 1]
    if (!value || value.startsWith('--')) throw new Error(`Missing value for ${arg}`)
    parsed[key] = value
    i += 1
  }

  const command = parsed.command
  if (command !== 'footer' && command !== 'prompt') throw new Error('--command must be footer or prompt')
  if (!parsed.workflow) throw new Error('--workflow is required')
  if (!parsed.memory) throw new Error('--memory is required')
  if (command === 'prompt' && (!parsed.repo || !/^\d+$/.test(parsed['pr-number'] ?? ''))) {
    throw new Error('--repo and numeric --pr-number are required for prompt')
  }

  return {
    command,
    workflow: parsed.workflow,
    memory: parsed.memory,
    repo: parsed.repo,
    prNumber: parsed['pr-number'],
    commentBody: parsed['comment-body'],
  }
}

if (import.meta.main) {
  const args = parseArgs(Bun.argv.slice(2))
  if (args.command === 'footer') process.stdout.write(renderFooter(args.workflow, args.memory))
  else process.stdout.write(await renderIterationPrompt(args))
}
