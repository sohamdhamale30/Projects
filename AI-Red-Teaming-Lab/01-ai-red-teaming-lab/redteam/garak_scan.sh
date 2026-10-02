#!/usr/bin/env bash
# Runs Garak against the local target chatbot's REST API.
#
# Garak's "rest" generator lets it hit any HTTP endpoint. We map the
# generic {prompt} template var to our /chat request body, and tell it
# where to find the reply in the JSON response.
#
# Prereqs: target/app.py running on :8000, Ollama running with the model
# pulled (see target/app.py docstring).
#
# Usage:
#   ./garak_scan.sh                 # run the default probe set
#   ./garak_scan.sh promptinject    # run one probe family

set -euo pipefail

PROBE="${1:-encoding,promptinject,leakreplay,dan}"
REPORT_DIR="../findings/garak-runs"
mkdir -p "$REPORT_DIR"

cat > rest_target.json <<'EOF'
{
  "rest": {
    "RestGenerator": {
      "name": "northpeak-bot",
      "uri": "http://localhost:8000/chat",
      "method": "post",
      "headers": {"Content-Type": "application/json"},
      "req_template_json_object": {"message": "$INPUT", "conversation_id": "garak"},
      "response_json": true,
      "response_json_field": "reply"
    }
  }
}
EOF

python -m garak \
  --model_type rest \
  --generator_option_file rest_target.json \
  --probes "$PROBE" \
  --report_prefix "$REPORT_DIR/northpeak-$(date +%Y%m%d-%H%M%S)"

echo "Garak run complete. Reports in $REPORT_DIR"
