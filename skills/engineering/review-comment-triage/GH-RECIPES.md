# gh recipes

Exact invocations for review-comment triage. Encode every comment write as `jq -Rs '{body: .}' <file> | gh api ... --input -` — the `-f body=@file` form posts the literal path instead of the file's content.

Two id systems are in play: REST endpoints take the comment's **databaseId**; the GraphQL mutation takes the thread's **node id**. The query below returns both.

## Fetch unresolved threads

```graphql
query($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          comments(first: 20) {
            nodes {
              databaseId
              author { login }
              path
              line
              body
            }
          }
        }
      }
    }
  }
}
```

```sh
gh api graphql -F owner=<owner> -F name=<repo> -F number=<pr> -F query=@threads.gql
```

Filter to `isResolved == false`; the thread's subject is `comments.nodes[0]`.

## Shell gotchas

- Count a thread's comments as `.comments.nodes | length` — `.comments | length` counts the connection object's keys, not its nodes.
- When piping a captured response into `jq`, use `printf '%s' "$resp"`, never `echo "$resp"` — zsh's `echo` expands `\n` sequences inside the JSON and corrupts it.
- After posting replies, re-fetch the threads and confirm each got exactly one reply from you — a retried POST can double-post (delete the duplicate).

## Post a thread reply

```sh
jq -Rs '{body: .}' reply.txt | gh api \
  repos/<owner>/<repo>/pulls/<pr>/comments/<comment-databaseId>/replies \
  -X POST --input -
```

## Edit a comment

Same encoding, PATCH the comment directly:

```sh
jq -Rs '{body: .}' body.txt | gh api \
  repos/<owner>/<repo>/pulls/comments/<comment-databaseId> \
  -X PATCH --input -
```

## Resolve a thread

```sh
gh api graphql -F threadId=<thread-node-id> -F query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }'
```

## Delete a comment

```sh
gh api repos/<owner>/<repo>/pulls/comments/<comment-databaseId> -X DELETE
```

## Rewrite SHAs after a rebase

A rebase orphans every SHA already posted. Map old → new by commit subject:

```sh
git log --oneline | grep <subject>
```

Then per affected comment: fetch the body, apply one `sed 's|<old-sha>|<commit-url-of-new-sha>|g'` per mapping in a single pass, and PATCH with the edit recipe above.
