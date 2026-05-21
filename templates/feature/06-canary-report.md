# <Feature Name> — Canary Report

## Canary Summary
- Owner:
- Date:
- Monitoring window:
- Change size: small / standard / major
- Result: HEALTHY / DEGRADED / BROKEN
- Decision: continue / pause / rollback
- Ship source: `docs/features/<name>/05-ship.md`

## Artifact Type
`artifact_type: software`

## Canary Scope
- Environment / region / ring:
- Canary population / traffic percentage:
- Version / commit / artifact:
- Critical user journeys:
- Out of scope:

## Baseline
- Baseline source:
- Baseline collected at:
- Endpoint count:
- Samples per endpoint:
- Baseline owner:

## Health Signals
| Signal | Source | Baseline | Current | Threshold | Status |
|--------|--------|----------|---------|-----------|--------|
| availability / success rate | <metric/query> | <value> | <value> | <min/max> | OK / WARN / FAIL |
| latency p95 / p99 | <metric/query> | <value> | <value> | <min/max> | OK / WARN / FAIL |
| error rate | <metric/query> | <value> | <value> | <min/max> | OK / WARN / FAIL |
| business signal | <metric/query> | <value> | <value> | <min/max> | OK / WARN / FAIL |

## Endpoint Status
| Endpoint | Status | Baseline Response | Current / Average Response | Error Count | Notes |
|----------|--------|-------------------|----------------------------|-------------|-------|
| /health | HEALTHY / DEGRADED / BROKEN | 45ms | 48ms | 0 | <notes> |

## Analysis Policy
- Interval:
- Count / duration:
- Failure threshold:
- Debounce rule:
- Promotion rule:
- Rollback rule:

## Anomalies
| Time | Signal / Endpoint | Severity | Evidence | Action |
|------|-------------------|----------|----------|--------|
| <timestamp> | <signal> | LOW / MEDIUM / HIGH / CRITICAL | <metric/log> | <continue/pause/rollback> |

## Decision
- Final status: HEALTHY / DEGRADED / BROKEN
- Decision: continue / pause / rollback
- Decision reason:
- Decision owner:
- Decision time:

## Baseline Update
- Updated: yes / no
- Reason:
- Previous baseline archived at:

## Follow-up
- Owner:
- Tracking:
- Next check:
- Next command: `/retro` / continue monitoring / rollback / investigate
