# EAN Expansion Strategy Plan

## Current Status
- **Total EANs**: 149 (149/446 = 33.4% coverage)
- **Fully Verified Categories** (100%): Baby, Cereals, Drinks, Żabka
- **Partially Verified** (82.2%): Chips (37/45)
- **Zero Coverage** (0%): 10 categories with 258 total products

## Categories With Zero EAN Coverage

| Category | Count | Priority | Difficulty | Notes |
|----------|-------|----------|------------|-------|
| Plant-Based & Alternatives | 54 | ⭐⭐⭐ High | Medium | Largest gap, specialty products |
| Frozen & Prepared | 28 | ⭐⭐ Medium | Hard | Previously removed due to quality issues |
| Instant & Frozen | 28 | ⭐⭐ Medium | Hard | Duplicate/overlap category? |
| Dairy | 28 | ⭐⭐⭐ High | Easy | Standardized products, major brands |
| Bread | 28 | ⭐⭐⭐ High | Easy | Standardized products, national brands |
| Meat | 28 | ⭐⭐ Medium | Medium | Polish specialty meats |
| Alcohol | 28 | ⭐⭐ Medium | Easy | Major brands, standard products |
| Sauces | 28 | ⭐ Low | Hard | Regional/specialty items |
| Sweets | 28 | ⭐⭐ Medium | Medium | Major candy brands |
| Seafood & Fish | 27 | ⭐ Low | Hard | Specialty/regional items |
| Nuts, Seeds & Legumes | 27 | ⭐⭐ Medium | Easy | Bulk/commodity products |

## Recommended Sequence

### Phase 1: Quick Wins (Easy, High Impact)
**Priority**: Dairy & Bread (56 products total)
- **Rationale**: Standardized products from major brands (Mlekovita, OSM, Żabka, Lidl, Biedronka)
- **Expected Success Rate**: 90%+ (major PLN brands have international distribution)
- **Effort**: Low - existing successful research approach
- **Timeline**: 1-2 sessions

### Phase 2: Large Gap (High Volume)
**Priority**: Plant-Based & Alternatives (54 products)
- **Rationale**: Largest category without EANs, growing market segment
- **Expected Success Rate**: 70-80% (specialized but established brands)
- **Effort**: Medium - more research, some may be hard to verify
- **Timeline**: 2-3 sessions
- **Risk**: None - remove if can't verify (conservative approach)

### Phase 3: Specialty Categories (Medium Impact)
**Priority**: Meat, Sweets, Alcohol (84 products)
- **Rationale**: Standard distributions through major retailers
- **Expected Success Rate**: 60-70% (regional/specialty items harder)
- **Effort**: Medium to High
- **Timeline**: 2-3 sessions

### Phase 4: Challenging Categories (Low Priority)
**Priority**: Sauces, Seafood, Nuts (83 products)
- **Rationale**: Specialty/regional items, may not have international EANs
- **Expected Success Rate**: 30-50%
- **Effort**: High - extensive research required
- **Timeline**: 3+ sessions

## Success Metrics

- **Target**: Expand from 149 to 250+ EANs (56%+ coverage)
- **Quality**: Maintain 100% valid EAN-13 checksums
- **QA**: All tests pass after each phase
- **Git**: Clear commit history with research methodology

## Research Methodology

1. Use `research_chips_eans.py` as template for category research
2. Query Open Food Facts API with brand + product name
3. Validate all EANs with `validate_eans.py` before database import
4. Create migration file with confirmed EANs only
5. Update EAN_VALIDATION_STATUS.md after each phase
6. Commit with detailed methodology notes

## Risks & Mitigations

- **API Rate Limiting**: Built-in 0.5s delay, respects Open Food Facts policies
- **Data Quality**: Conservative approach - remove unverifiable EANs rather than force
- **Duplicate Categories**: Verify Frozen & Prepared vs Instant & Frozen overlap
- **Polish Market EANs**: Focus on PepsiCo, Nestlé, Carrefour when available

## Next Immediate Steps

1. ✅ **Chips completion**: Research 8 remaining missing Chips products
2. 🔄 **Phase 1 Start**: Begin with Dairy category (28 products, high success rate)
3. 📊 **Track Metrics**: Update dashboard with progress
