#!/usr/bin/env bash
# Reruns the exact same Garak probe set against the hardened target
# (port 8001) so the before/after is a controlled comparison, not a
# vibes-based "looks better now."
#
# Prereqs: mitigations/hardened_app.py running on :8001
#   uvicorn hardened_app:app --port 8001

set -euo pipefail

sed 's/localhost:8000/localhost:8001/' rest_target.json > rest_target_hardened.json

python -m garak \
  --model_type rest \
  --generator_option_file rest_target_hardened.json \
  --probes "encoding,promptinject,leakreplay,dan" \
  --report_prefix "../findings/garak-runs/hardened-retest-$(date +%Y%m%d-%H%M%S)"

echo "Retest complete. Compare pass rates against the baseline run in findings/garak-runs/"
