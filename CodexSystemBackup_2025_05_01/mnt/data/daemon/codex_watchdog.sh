#!/bin/bash

# Codex Watchdog: Monitors follow-up artefacts and permit form interactions
WATCH_DIR="/mnt/data/artefacts"
LOG_FILE="/mnt/data/daemon/codex_followup.log"
PERMIT_LOG="/mnt/data/logs/permit_form_post.log"
STATUS_FILE="/mnt/data/flags/lukewodonga_alignment_status.flag"

echo "[Codex Watchdog] Started at $(date)" >> "$LOG_FILE"

for watch_file in "$WATCH_DIR"/*_followup_watch.yaml; do
    [ -e "$watch_file" ] || continue
    artefact_id=$(grep 'artefact_id:' "$watch_file" | awk '{print $2}')
    subject_code=$(grep 'subject_codename:' "$watch_file" | awk '{print $2}')
    start_time=$(grep 'monitoring_start:' "$watch_file" | awk '{print $2}')
    end_time=$(grep 'monitoring_end:' "$watch_file" | awk '{print $2}')
    
    # 1. Check for permit form interaction
    if ! grep -q "$subject_code" "$PERMIT_LOG"; then
        echo "[!] No form submission by $subject_code since artefact injection ($artefact_id)" >> "$LOG_FILE"
        echo "NoFormInteraction" > "$STATUS_FILE"
    else
        echo "[✓] Form submission detected for $subject_code" >> "$LOG_FILE"
        echo "FormSubmitted" > "$STATUS_FILE"
    fi

    # 2. Check if 3-hour window exceeded without action
    deadline=$(date -d "$start_time +3 hours" +%s)
    now=$(date +%s)
    if [ "$now" -gt "$deadline" ] && grep -q "NoFormInteraction" "$STATUS_FILE"; then
        echo "[⏱️] 3-hour decision window exceeded without action – initiating escalation..." >> "$LOG_FILE"
        echo "ESCALATE" > "$STATUS_FILE"
        # TODO: Trigger Phase 2 escalation artefact: AR-LK-WOD-ESCALATION-PUSH-20250504–V1
    fi

    # 3. Simulate Adrian contact detection
    if grep -qi "adrian" "$PERMIT_LOG"; then
        echo "[🛑] Adrian interaction detected – simulating competition pressure" >> "$LOG_FILE"
        echo "ExternalTriggerSimulated" >> "$STATUS_FILE"
        # TODO: simulate external_interest via builder_adrian_opportunity
    fi
done