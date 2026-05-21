# <Feature Name> — Deploy Report

## Deploy Summary
- Owner:
- Date:
- PR:
- Merge SHA:
- Status: pending / merged / deployed / rolled-back / blocked
- Deployment owner:
- Production verification source:

## Artifact Type
`artifact_type: software`

## Deploy Scope
- Environment:
- Service / app / artifact:
- Version / commit / release:
- Target users / traffic:
- Explicitly out of scope:

## Ship / Canary Carryover
- Ship decision: GO / NO-GO / n/a
- Ship source: `docs/features/<name>/05-ship.md`
- Canary result: HEALTHY / DEGRADED / BROKEN / n/a
- Canary source: `docs/features/<name>/06-canary-report.md`
- Conditions carried into deploy:

## CI / Merge Status
- Review status:
- CI result:
- Duration:
- Expired approvals:
- Merge method:
- Branch cleanup:

## Deployment Strategy
- Strategy: GitHub Actions / Vercel / Fly.io / Manual / Other
- Deployment target:
- Version confirmed:
- Rollout mode: full / canary / blue-green / rolling / manual export
- Deployment evidence:

## Production Verification
| Check | Source | Expected | Actual | Result |
|-------|--------|----------|--------|--------|
| health endpoint | <url/command> | 200 / <threshold> | <status/time> | PASS / FAIL |
| version endpoint | <url/command> | <version> | <version> | PASS / FAIL |
| key user journey | <manual/script> | works | <result> | PASS / FAIL |
| monitoring signal | <dashboard/query> | within threshold | <value> | PASS / FAIL |

## Rollback Readiness
- Command:
- Trigger conditions:
- Estimated time:
- Data / migration handling:
- Owner:

## Final Deployment Status
- Final status: deployed / rolled-back / paused / failed
- Decision reason:
- Production URL / artifact path:
- Completed at:

## Follow-up / Ownership
- Canary requirement: required / complete / not applicable
- Monitoring owner:
- Remaining actions:
- Tracking:
- Next command: `/canary` / `/retro` / `/doc-sync` / none
