---
name: todo
description: Queue a new item into my todo list — preempts the running task when it's urgent enough, otherwise slots it in by priority.
disable-model-invocation: true
---

Queue a new item into your todo list. Weigh it against the running task: **preempt** when the item's cost of waiting beats the switch tax, otherwise **place** it at the slot its urgency earns.

1. **Take the item.** Capture what the user wants queued. If they didn't already state the urgency signals — deadline, what it unblocks, what breaks if it waits — ask in one exchange. Done when you can judge the item's cost of waiting.

2. **Lay out the field.** Name the running task and how close to done it is, the queued items, and where the item's urgency sits against them. Done when you can name what a switch costs and where the item lands.

3. **Weigh it.** Apply the rubric below. Done when the verdict is stated — preempt, or the slot it lands in — with the rubric's reasoning.

4. **Enact it.** Preempt: make the item the running task, keep the suspended task directly beneath it, state the switch and the deferred work, do the item, then restore the suspended task. Place: insert the item at its slot and leave the running task untouched. Done when the list shows the verdict and you have stated it.

## The preempt/place call

Your todo list is a priority queue — one running task, the rest waiting. A new item either **preempts** the running task or **places** into the queue. Two costs decide:

- **Cost of waiting** — what the item loses by sitting in the queue: a deadline, a blocked person or pipeline, work that compounds while it waits.
- **Switch tax** — what the running task loses by pausing: accumulated context, half-done state, its own deadline. A fixed cost, paid in full however short the pause.

**Preempt** when the cost of waiting clearly outweighs the switch tax. With no running task, the item simply becomes the running task.

**Place** otherwise, ranked by cost of waiting: urgent-but-not-now high, routine low, anything flagged "later" near the bottom.

**Finish the nearly-done task first.** When the running task is one clear push from done — roughly under an hour of work — finish it, then start the item. The switch tax is fixed; the remaining work is not.
