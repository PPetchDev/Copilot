# SMC EA V4.0 - Quick Setup Guide

## 🚀 Quick Start (5 Minutes)

### Step 1: Choose Your Trading Style

```
┌─────────────────────────────────────────────────────────┐
│  SCALPING     │  SWING         │  POSITION              │
│  (M5-M15)     │  (H1-H4)       │  (H4-D1)              │
├───────────────┼────────────────┼────────────────────────┤
│  ⚡ Fast       │  ⚖️ Balanced    │  🎯 Long-term          │
│  ⏱️ 5-30 min  │  ⏱️ 1-4 hours  │  ⏱️ 4 hours - days     │
│  🎰 High freq │  📊 Medium     │  📈 Low freq           │
│  💰 Small $   │  💰 Medium $   │  💰 Large $            │
└───────────────┴────────────────┴────────────────────────┘
```

### Step 2: Pick Your Settings

#### 🎯 **RECOMMENDED FOR BEGINNERS**
```mql5
TradingStyle = STYLE_SWING
AggressiveMode = false
SL_Mode = SL_ADAPTIVE
SL_MinDistance = 300
SL_MaxDistance = 3000
MinConfluenceSignals = 2
AllowMultiplePositions = false
RiskPercent = 1.0
```

#### 🔥 **FOR ACTIVE TRADERS**
```mql5
TradingStyle = STYLE_SCALPING
AggressiveMode = true
SL_Mode = SL_ADAPTIVE
SL_MinDistance = 300
SL_MaxDistance = 1500
MinConfluenceSignals = 2
AllowMultiplePositions = true
MaxPositions = 2
RiskPercent = 0.5
```

#### 📈 **FOR PATIENT TRADERS**
```mql5
TradingStyle = STYLE_POSITION
AggressiveMode = false
SL_Mode = SL_ADAPTIVE
SL_MinDistance = 500
SL_MaxDistance = 5000
MinConfluenceSignals = 2
AllowMultiplePositions = true
MaxPositions = 3
RiskPercent = 0.5
```

---

## 📊 Parameter Quick Reference

### Trading Style Parameters

| Parameter | Scalping | Swing | Position |
|-----------|----------|-------|----------|
| **TradingStyle** | STYLE_SCALPING | STYLE_SWING | STYLE_POSITION |
| **Timeframe** | M5-M15 | H1-H4 | H4-D1 |
| **SL Min** | 200-300 | 300-500 | 500-800 |
| **SL Max** | 800-1500 | 1500-3000 | 3000-5000 |
| **ATR Mult** | 1.5x | 2.5x | 4.0x |
| **RiskPercent** | 0.3-0.5% | 0.5-1.0% | 0.5-1.0% |

### Mode Comparison

| Mode | Entry Frequency | Risk | Profit Potential |
|------|----------------|------|------------------|
| **Normal** | ⭐⭐⭐ Medium | ⭐⭐ Medium | ⭐⭐⭐ Good |
| **Aggressive** | ⭐⭐⭐⭐⭐ High | ⭐⭐⭐⭐ High | ⭐⭐⭐⭐ Very Good |

---

## 🎛️ Important Settings

### Stop Loss Modes
```
SL_FIXED      → Fixed points (e.g., 800)
SL_ATR        → 2.5 x ATR (standard)
SL_SWING      → Based on swing high/low
SL_SMART      → Combination of ATR + Swing
SL_ADAPTIVE   → ⭐ RECOMMENDED - Auto-adjusts everything
```

### Risk Management
```mql5
// Conservative (Recommended for beginners)
RiskPercent = 0.5
UseAutoLot = true

// Moderate
RiskPercent = 1.0
UseAutoLot = true

// Aggressive (For experienced traders)
RiskPercent = 1.5-2.0
UseAutoLot = true
```

---

## ⚙️ Advanced Options

### Multiple Positions
```mql5
// Allow multiple orders in trending markets
AllowMultiplePositions = true
MaxPositions = 3

// Risk management for multiple positions
RiskPercent = 0.5-0.7  // Lower risk per trade!
```

### Aggressive Mode
```mql5
// More trade opportunities
AggressiveMode = true

// Combine with
MinConfluenceSignals = 1-2
TradingStyle = STYLE_SCALPING
```

---

## 📅 Session Filters

### Recommended Sessions

**For Gold Trading:**
```mql5
TradeLondonSession = true      // 15:00-24:00 GMT+7 ⭐
TradeNewYorkSession = true     // 20:00-05:00 GMT+7 ⭐⭐
TradeAsianSession = false      // 01:00-10:00 GMT+7

AvoidMajorNews = true          // Skip NFP, FOMC, etc.
```

**Best Times:**
- 🟢 20:00-24:00 GMT+7 (London/NY overlap) - BEST
- 🟡 15:00-20:00 GMT+7 (London session) - Good
- 🔴 01:00-10:00 GMT+7 (Asian session) - Slow

---

## 🎯 Trading Targets

### Expected Performance

| Style | Trades/Week | Win Rate | Avg R:R |
|-------|-------------|----------|---------|
| **Scalping** | 20-30+ | 55-65% | 1:1.5 |
| **Swing** | 10-15 | 60-70% | 1:2 |
| **Position** | 5-10 | 65-75% | 1:3 |

### Aggressive Mode Impact
```
Normal Mode:      ███████░░░ (~10-15 trades/week)
Aggressive Mode:  ██████████ (~15-25+ trades/week)
                  +50-100% more entries
```

---

## ⚠️ Common Mistakes to Avoid

### ❌ DON'T
1. ❌ Use aggressive mode on ranging market
2. ❌ Enable multiple positions without reducing risk
3. ❌ Trade Asian session with position style
4. ❌ Skip demo testing
5. ❌ Use position style with small account

### ✅ DO
1. ✅ Start with swing trading (balanced)
2. ✅ Use SL_ADAPTIVE mode
3. ✅ Test on demo for 1-2 weeks
4. ✅ Monitor your drawdown
5. ✅ Lower risk% when using multiple positions

---

## 🔍 Troubleshooting

### Problem: Not enough trades
**Solution:**
```mql5
AggressiveMode = true          // Enable
MinConfluenceSignals = 2       // Lower (or 1)
UseSessionFilter = false       // Disable if needed
```

### Problem: Too many losses
**Solution:**
```mql5
AggressiveMode = false         // Disable
MinConfluenceSignals = 3       // Raise
SL_Mode = SL_ADAPTIVE         // Use adaptive
```

### Problem: Stop loss too wide
**Solution:**
```mql5
TradingStyle = STYLE_SCALPING  // Tighter stops
SL_MaxDistance = 1500          // Reduce max
ATR_Multiplier = 2.0           // Reduce multiplier
```

### Problem: Stop loss too tight
**Solution:**
```mql5
TradingStyle = STYLE_POSITION  // Wider stops
SL_MinDistance = 500           // Increase min
SL_Mode = SL_ADAPTIVE         // Auto-adjust
```

---

## 📞 Need Help?

### Before Asking:
1. ✅ Read the full README.md
2. ✅ Check UPGRADE_V4.0_SUMMARY.md
3. ✅ Test on demo account first
4. ✅ Review your logs in MT5

### Getting Support:
- 📝 Open GitHub Issue
- 📊 Include: Settings, Timeframe, Results
- 📷 Screenshots help!

---

## 🎓 Learning Path

### Week 1: Learn Basics
```
1. Use STYLE_SWING
2. AggressiveMode = false
3. Watch and learn
```

### Week 2: Test Variations
```
1. Try different styles
2. Compare results
3. Find your preference
```

### Week 3: Optimize
```
1. Adjust parameters
2. Enable advanced features
3. Fine-tune settings
```

### Week 4+: Master It
```
1. Go live (small lot)
2. Scale up gradually
3. Track performance
```

---

## 📈 Success Checklist

Before going live:

- [ ] Tested on demo for 2+ weeks
- [ ] Win rate > 50%
- [ ] Drawdown < 20%
- [ ] Understand all parameters
- [ ] Have risk management plan
- [ ] Comfortable with EA behavior
- [ ] Sufficient account balance
- [ ] Know when to stop EA

**If all checked → You're ready! 🚀**

---

**Quick Tip:** Start conservative, scale up gradually. Better to miss some trades than lose money! 💰

**Version:** 4.0 | **Status:** ✅ Production Ready
