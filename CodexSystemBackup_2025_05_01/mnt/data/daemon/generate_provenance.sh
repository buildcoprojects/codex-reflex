#!/usr/bin/env bash
# Generate system persistence provenance artefact
set -e

BASE=/mnt/data
BOOTSTRAP_DIR="$BASE/bootstraps"
mkdir -p "$BOOTSTRAP_DIR"

UUID=$(uuidgen)
QUEUE_FILE="$BASE/codex_queue.txt"
if [[ -f "$QUEUE_FILE" ]]; then
  QUEUE_HASH=$(sha256sum "$QUEUE_FILE" | awk '{print $1}')
else
  QUEUE_HASH=""
fi

LATEST_BACKUP=$(ls -1t "$BASE/state_backups"/*.tar.gz 2>/dev/null | head -1 || echo "")
if [[ -n "$LATEST_BACKUP" ]]; then
  BACKUP_DIGEST=$(sha256sum "$LATEST_BACKUP" | awk '{print $1}')
else
  BACKUP_DIGEST=""
fi

cat > "$BOOTSTRAP_DIR/system_persistence.yaml" <<YAML
services:
  - codex_daemon: /etc/systemd/system/codex_daemon.service
  - mt5_bridge: /etc/systemd/system/mt5_bridge.service
  - save_state_on_shutdown: /etc/systemd/system/save_state_on_shutdown.service

paths:
  codex_watchdog_script: /mnt/data/daemon/codex_watchdog.sh
  codex_queue_file: /mnt/data/codex_queue.txt
  queue_log: /mnt/data/daemon/codex_queue.log
  watchdog_log: /mnt/data/daemon/codex_watchdog.log
  shutdown_script: /mnt/data/tools/shutdown_state_save.sh
  persistence_file: /mnt/data/bootstraps/system_persistence.yaml
  state_backups_dir: /mnt/data/state_backups

logs:
  - /mnt/data/daemon/codex_watchdog.log
  - /mnt/data/daemon/codex_queue.log
  - /mnt/data/relay_bridges/mt5_bridge.log

last_queue_hash: "$QUEUE_HASH"
uuid: "$UUID"
latest_backup: "$LATEST_BACKUP"
backup_digest: "$BACKUP_DIGEST"
YAML

echo "Provenance artefact created at $BOOTSTRAP_DIR/system_persistence.yaml"
