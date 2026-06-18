# <PROJECT NAME>

### FILL ME: one-paragraph description of what this project is and does.

## Integrity rules (non-negotiable)

These apply to every contributor and every AI coding tool used on this repo.

1. **Every reported number is reproducible.** Any value in a README, paper,
   report, or committed data file must be the literal output of a committed,
   deterministic script. No hardcoded "results", no numbers typed by hand.
2. **CI regenerates and compares.** `make data && git diff --exit-code` must
   pass. If a regenerated artifact differs from what's committed, CI fails.
3. **CI never swallows failures.** No `|| true`, no `|| echo "skip"`, no
   `continue-on-error` on test/build steps. A broken build must go red.
4. **Tests assert real behaviour.** No no-op or always-true tests. Prefer
   checking properties (determinism, invariances, known exact values,
   oracles). A green CI with zero real tests is a bug.
5. **Honesty over impressiveness.** If something cannot be honestly
   reproduced, say so or remove it — never invent or approximate-and-hide.
   A weaker real result beats a strong fabricated one.
6. **Document methodology in code.** Experimental choices (sizes, seeds,
   thresholds, budgets) are named constants with comments, not implicit
   magic numbers.

## Reproduce everything

```bash
make test               # real unit tests
make smoke              # fast end-to-end check
make data               # regenerate every committed result/artifact
make check-reproducible # data must match what's committed
make audit              # heuristic integrity audit
```

### FILL ME: project-specific build/run notes.
