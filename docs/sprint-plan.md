# DeadW3 Sprint Plan: Phase 1 Mirror

**Goal:** Permanent backup of Archive.org Grateful Dead collection on Arweave  
**Duration:** 8 weeks (56 days)  
**Budget:** $65,000  
**Team:** 1 technical lead + advisors  

## Pre-Sprint (Funding Phase)

**Duration:** 2-4 weeks (parallel to Week 1-2)  
**Deliverable:** $65K secured

### Funding Strategy
- [ ] Gitcoin Grants round application
- [ ] Protocol Labs/Filecoin Foundation grant submission
- [ ] Individual outreach to crypto philanthropy (Vitalik, Naval, etc.)
- [ ] Community crowdfund (Mirror.xyz + Farcaster announcement)

### Acceptance Criteria
- Minimum $60K committed
- Payment schedule established (33% upfront, 33% at week 6, 34% at completion)

---

## Week 1-2: Proof of Concept

**Objective:** Validate technical approach with 50-show sample

### Tasks

#### Download Infrastructure (Week 1)
- [ ] Set up VPS (c6a.2xlarge, us-east-1)
- [ ] Install `internetarchive` Python library
- [ ] Write `fetch_collection.py` with:
  - Parallel downloads (10 concurrent)
  - MD5 verification against Archive.org checksums
  - Progress logging (JSON)
  - Retry logic (3 attempts, exponential backoff)
- [ ] Test on 10 shows, verify integrity
- [ ] Document bandwidth usage (estimate full mirror time)

#### Upload Infrastructure (Week 2)
- [ ] Purchase $1,000 AR tokens (covers 50 shows + buffer)
- [ ] Set up Bundlr node access
- [ ] Write `bundle_to_arweave.ts`:
  - ANS-104 manifest creation
  - Tags: `Artist`, `Date`, `Venue`, `Archive-ID`, `Source`
  - Rate limiting (respect Bundlr limits)
  - Transaction receipt logging
- [ ] Upload 50 shows
- [ ] Verify on ViewBlock (random sampling)

#### Manifest & Viewer (Week 2)
- [ ] Generate `manifest.json`: `{archiveID: arweaveTX}`
- [ ] Build minimal HTML viewer:
  - List of 50 shows
  - Click → open on ar.io gateway
  - Metadata display (date, venue)
- [ ] Deploy to GitHub Pages

### Success Criteria
- [ ] 50 shows uploaded, all playable
- [ ] Actual cost: $500-700 (validate $8/GB estimate)
- [ ] Download speed: ≥50 Mbps average
- [ ] Upload speed: ≥100 shows/day achievable
- [ ] Zero checksum mismatches

### Deliverable
- Public demo: `deadw3-poc.github.io`
- Blog post: "We Archived 50 Grateful Dead Shows Permanently for $700"

---

## Week 3-5: Scale-Up Preparation

**Objective:** Harden scripts for 13,000-show production run

### Enhancements

#### Download (Week 3)
- [ ] Implement chunked downloads (resume support)
- [ ] Add show selection priority:
  1. Most-accessed (from Archive.org stats)
  2. Earliest chronological
  3. Best quality (by metadata)
- [ ] Database for tracking:
```sql
  CREATE TABLE shows (
    archive_id TEXT PRIMARY KEY,
    download_status TEXT, -- pending/downloading/complete/failed
    checksum_verified BOOLEAN,
    upload_status TEXT,
    arweave_tx TEXT
  );
```
- [ ] Multi-region download (if Archive.org throttles)

#### Upload (Week 4)
- [ ] Bulk AR token purchase ($55K → ~7 million AR)
- [ ] Optimize bundle size (test 50/100/200 shows per bundle)
- [ ] Implement upload queue with priority:
  - Early years (1960s-70s) first (historical value)
  - High-access shows (popular dates)
- [ ] Error handling: failed uploads auto-retry after 1hr

#### Monitoring (Week 5)
- [ ] Prometheus + Grafana dashboard:
  - Download rate (GB/hr)
  - Upload rate (shows/hr)
  - AR token balance
  - ETA to completion
- [ ] Alerting: Slack webhook for failures
- [ ] Daily progress reports (automated)

### Success Criteria
- [ ] Scripts can recover from network failures
- [ ] Upload queue can be paused/resumed safely
- [ ] Monitoring shows reliable ETA estimates
- [ ] Cost tracking stays within $65K budget

---

## Week 6-10: Full Production Mirror

**Objective:** Upload entire 13,000-show collection

### Execution Plan

#### Week 6: Early Years (1965-1969)
- ~500 shows, lower audio quality (smaller files)
- Serves as warm-up for pipeline

#### Week 7-8: Peak Years (1970-1979)
- ~5,000 shows, mix of audience/soundboard tapes
- High community interest (these get checked first)

#### Week 9: Late Years (1980-1995)
- ~6,000 shows, better recording quality
- Larger files (may slow down)

#### Week 10: Long Tail + Retries
- Uncommon recordings, compilations, side projects
- Retry all failed uploads from previous weeks
- Final checksum validation pass

### Daily Routine
1. Morning: Check dashboard for overnight failures
2. Spot-check 5 random new uploads (playability)
3. Respond to community feedback (if announced publicly)
4. Evening: Review progress, adjust priorities if needed

### Risk Mitigation
- **AR price volatility:** Already purchased tokens upfront
- **Archive.org throttling:** Respect rate limits, use off-peak hours
- **Arweave network congestion:** Bundlr handles this; may slow upload
- **Corrupted downloads:** Automatic checksum fails trigger re-download

### Success Criteria
- [ ] ≥98% of shows uploaded (some may be inaccessible on Archive.org)
- [ ] All uploads verified on-chain
- [ ] Comprehensive manifest generated
- [ ] Spend under $62K (leaving buffer)

---

## Week 11: Static Site & Index

**Objective:** Make archive searchable and accessible

### Site Features
```
Homepage:
  - Project mission statement
  - Stats: X shows, Y hours, Z GB preserved
  - Link to full manifest

Browse:
  - Filter by year, venue, source quality
  - Sort by date, popularity (Archive.org plays)
  
Show Page:
  - Metadata (date, venue, setlist if available)
  - Link to Arweave (ar://...)
  - Link to Archive.org (original source)
  - Taper credits

Search:
  - Client-side Lunr.js index
  - Fuzzy matching on venue, date, songs
```

### Implementation
- [ ] Generate static site from manifest (11ty or similar)
- [ ] Deploy to ar.io gateway (entire site on Arweave)
- [ ] Fallback: GitHub Pages with external manifest link
- [ ] Test on mobile, desktop, accessibility

### Documentation
- [ ] README: How to replicate this mirror for other collections
- [ ] Runbook: How to update if Archive.org adds new shows
- [ ] Cost breakdown: Detailed financial report

### Success Criteria
- [ ] Site loads in <3 seconds
- [ ] Search returns results in <500ms
- [ ] All links functional
- [ ] Mobile-responsive

---

## Week 12: Launch & Retrospective

**Objective:** Public announcement, community handoff

### Launch Activities
- [ ] Publish whitepaper + sprint retrospective
- [ ] Medium/Mirror post: "How We Preserved 13,000 Shows Forever"
- [ ] Social announcement (Twitter, Farcaster, Reddit r/gratefuldead)
- [ ] Email Archive.org + GD archivist community
- [ ] Submit to HN, crypto news outlets

### Community Handoff
- [ ] Open-source all scripts (MIT license)
- [ ] Create "Replicate This" guide for other bands/collections
- [ ] Set up GitHub Discussions for:
  - Requesting new shows to add
  - Reporting broken links
  - Proposing Phase 2 features

### Retrospective
- [ ] Document what worked:
  - Script performance benchmarks
  - Cost accuracy (predicted vs. actual)
  - Time accuracy (predicted vs. actual)
- [ ] Document what didn't:
  - Failed approaches
  - Unexpected technical issues
  - Budget overruns (if any)
- [ ] Recommendations for Phase 2

### Success Criteria
- [ ] 1,000+ site visitors in first week
- [ ] Positive response from GD community
- [ ] Zero legal challenges (first 30 days)
- [ ] At least 2 other groups inquire about replicating for their collections

---

## Phase 2 Decision Point

**After Week 12, evaluate:**

### Should we build the token-incentivized platform?

**Proceed if:**
- Community demand for NEW show submissions (not in Archive.org)
- Funding available ($100K+)
- No legal concerns from Phase 1 launch

**Alternative paths:**
- Keep it simple: Just repeat mirror process annually (new shows appear on Archive.org)
- Focus on other collections: Phish, WSP, etc. (same script, new source)
- Build API layer only (no blockchain) for better search/discovery

---

## Budget Breakdown

| Item | Cost | Notes |
|------|------|-------|
| Arweave storage (6.5TB) | $52,000 | Locked in via AR token purchase |
| VPS (8 weeks) | $1,600 | c6a.2xlarge @ $200/week |
| Developer time | $8,000 | 200 hrs @ $40/hr (or volunteer) |
| Legal review (optional) | $2,000 | Compliance check pre-launch |
| Contingency (10%) | $1,400 | Buffer for overage |
| **Total** | **$65,000** | |

---

## Team Roles

### Technical Lead (1 person)
- Scripts development & execution
- Infrastructure monitoring
- Troubleshooting
- **Commitment:** Full-time, weeks 1-11; part-time week 12

### Advisors (As Needed)
- **Archivist:** Validate metadata preservation standards
- **Legal:** Review GD policy compliance
- **Community Liaison:** Interface with r/gratefuldead, Archive.org staff

### Post-Launch Maintainer
- Minimal: Check for new Archive.org shows quarterly
- Upload new content (if <$500/year cost)
- Respond to community issues

---

## Communication Plan

### Weekly Updates (Public)
- Progress: X of 13,000 shows complete
- Costs: $Y spent of $65K budget
- Blockers: Any technical issues
- ETA: Projected completion date

**Platform:** GitHub Discussions, Farcaster

### Monthly Reports (Funders)
- Detailed financials
- Risk register updates
- Go/no-go decision for next phase

---

## Success Definition

**We will consider Phase 1 successful if:**

1. ≥95% of Archive.org GD collection mirrored to Arweave
2. All uploads verified and accessible
3. Cost ≤$70K (within 10% of budget)
4. Completion within 12 weeks
5. Zero legal challenges from GD organization
6. Positive community reception (subjective, but important)
7. Clear documentation enabling replication

**Failure modes:**
- Legal C&D forces takedown → Pivot to non-GD content
- Cost overruns >$80K → Pause, re-evaluate, partial delivery
- Technical blockers (Arweave API changes, etc.) → Seek alternatives (Filecoin, Storj)

---

**Let's ship this.** 🚀