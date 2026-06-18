.PHONY: test smoke data check-reproducible audit

# Real unit tests. Must exit non-zero on any failure (no swallowing).
test:
	python -m pytest -v --tb=short

# Fast end-to-end check that the core programs run. Should write to a
# scratch location so it never touches committed artifacts.
smoke:
	### FILL ME: a quick run of the main entry point, e.g.
	### python main.py --help >/dev/null
	@echo "TODO: define a real smoke check" && exit 1

# Regenerate EVERY committed result/artifact from scratch. Deterministic
# given fixed seeds, so a fresh run reproduces the committed files.
data:
	### FILL ME: the command(s) that regenerate data/, e.g.
	### python experiments.py all
	@echo "TODO: define how data/ is regenerated" && exit 1

# The wall fabricated numbers cannot pass: regenerate, then fail if the
# working tree differs from what's committed.
check-reproducible: data
	git diff --exit-code -- data/ || \
	  (echo "ERROR: regenerated data differs from committed data — not reproducible" && exit 1)

# Heuristic integrity audit. Expects audit.sh in the repo (copied by install.sh)
# or run the standalone Auditor Claude script.
audit:
	bash scripts/audit.sh
