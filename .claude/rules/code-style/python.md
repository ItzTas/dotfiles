---
paths:
  - "**/*.{py,pyi}"
---

# Python code style

Rules specific to Python, on top of my general code style rules. Each section below is independent;
read the ones that apply to what you're writing.

## Inline constructs

- **Inline forms are allowed.** Conditional expressions (`x if cond else y`), comprehensions
  (list/dict/set/generator), `lambda`, the walrus operator (`:=`), and short one-line bodies are
  fine when the logic is simple and reads at a glance.

  ```python
  label = "active" if user.is_active else "inactive"
  names = [u.name for u in users if u.is_active]
  by_id = {u.id: u for u in users}
  ```

- **Prefer not to inline when it hurts readability.** When the logic is complex, write it out:
  a normal `if` block, a `for` loop, a named function, or intermediate variables with good names.
  Signs that an inline form went too far:

  - nested conditional expressions (`a if x else b if y else c`);
  - a comprehension with more than one `for`, several `if` filters, or a transformation that
    needs a second read to understand;
  - a `lambda` with branching or anything beyond a short expression;
  - a walrus buried in a condition that already does other work;
  - a line you have to split across several lines just to fit, or that needs a comment to explain
    what it does.

  ```python
  # Hard to read
  result = [transform(x) if x.kind == "a" else fallback(x) for group in groups for x in group.items if x.enabled and not x.deleted]

  # Better
  def resolve(item: Item) -> Value:
      if item.kind == "a":
          return transform(item)
      return fallback(item)

  result = []
  for group in groups:
      for item in group.items:
          if not item.enabled or item.deleted:
              continue
          result.append(resolve(item))
  ```

  The goal is readability, not the fewest lines. If the inline version and the expanded version
  are equally clear, either is fine.
