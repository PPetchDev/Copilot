//+------------------------------------------------------------------+
//|                                         Gold_SMC_EA_Pro_V3.mq5   |
//|                              Smart Money Concept Strategy Pro V3 |
//|                                 Enhanced Risk Management Edition  |
//+------------------------------------------------------------------+
#property copyright "Gold Trading EA Pro V3"
#property version   "3.00"
#property strict

// Input Parameters
input group "=== Risk Management Enhanced ==="
input double LotSize = 0.01;                // ขนาด Lot
input double RiskPercent = 1.0;             // % ความเสี่ยงต่อการเทรด
input bool UseAutoLot = true;               // คำนวณ Lot อัตโนมัติ (แนะนำให้เปิด)
input ENUM_SL_MODE SL_Mode = SL_ATR;        // โหมด Stop Loss
input double StopLoss_Fixed = 800;          // Stop Loss แบบคงที่ (points)
input double ATR_Multiplier = 2.5;         // ATR Multiplier สำหรับ SL
input double SL_MinDistance = 400;          // SL ขั้นต่ำ (points)
input double SL_MaxDistance = 1500;        // SL สูงสุด (points)
input double RiskRewardRatio = 2.0;         // Risk:Reward Ratio
input bool UseTrailingStop = true;          // ใช้ Trailing Stop
input double TrailingStop_ATR = 1.5;        // Trailing Stop (ATR multiplier)
input double TrailingStep = 100;            // Trailing Step (points)
input bool UseBreakEven = true;             // ใช้ Break Even
input double BreakEvenTrigger_ATR = 1.0;    // BE Trigger (ATR multiplier)
input double BreakEvenProfit = 100;         // BE Profit (points)
input bool UsePartialClose = true;          // ใช้ Partial Close
input double PartialClose_ATR = 1.5;        // Partial Close Trigger (ATR)
input double PartialClose_Percent = 50.0;   // % ที่จะปิด

// Stop Loss Modes
enum ENUM_SL_MODE {
    SL_FIXED,           // ระยะคงที่
    SL_ATR,             // ตาม ATR
    SL_SWING,           // ตาม Swing High/Low
    SL_SMART            // Smart SL (รวมหลายวิธี)
};

input group "=== OBV Settings Enhanced ==="
input int OBV_Period = 20;                  // OBV MA Period
input ENUM_MA_METHOD OBV_MA_Method = MODE_EMA; // OBV MA Method
input double OBV_Threshold = 0.1;           // OBV ความแรงขั้นต่ำ

input group "=== FVG Settings Enhanced ==="
input int FVG_MinGap = 150;                 // FVG ขั้นต่ำ (points) - เพิ่มขึ้น
input int FVG_Lookback = 100;               // จำนวนแท่งย้อนหลัง - เพิ่มขึ้น
input double FVG_MinSize_ATR = 0.3;         // FVG ขั้นต่ำ (ATR multiplier)
input bool FVG_DrawOnChart = true;          // วาด FVG บนชาร์ต
input color FVG_Bullish_Color = clrLimeGreen;   // สี FVG Bullish
input color FVG_Bearish_Color = clrCrimson;     // สี FVG Bearish

input group "=== Order Block Settings Enhanced ==="
input bool UseOrderBlock = true;            // ใช้ Order Block
input int OB_Lookback = 50;                 // OB Lookback Period - เพิ่มขึ้น
input double OB_MinStrength = 2.0;          // OB Min Strength (ATR multiple)
input double OB_MinVolume = 1.5;            // OB ปริมาณขั้นต่ำ (เฉลี่ย)
input color OB_Bullish_Color = clrDodgerBlue;   // สี OB Bullish
input color OB_Bearish_Color = clrOrangeRed;    // สี OB Bearish

input group "=== Break of Structure Enhanced ==="
input bool UseBOS = true;                   // ใช้ BOS Detection
input int BOS_Lookback = 30;                // BOS Lookback Period - เพิ่มขึ้น
input double BOS_MinStrength = 1.5;         // BOS ความแรงขั้นต่ำ (ATR)
input color BOS_Bullish_Color = clrAqua;    // สี BOS Bullish
input color BOS_Bearish_Color = clrMagenta; // สี BOS Bearish

input group "=== Liquidity Sweep Enhanced ==="
input int SwingLookback = 30;               // Swing High/Low Lookback - เพิ่มขึ้น
input double SweepTolerance = 80;           // Sweep Tolerance (points) - เพิ่มขึ้น
input double LiquidityStrength = 2.0;       // ความแรงของ Liquidity Level
input bool DrawLiquidityLevels = true;      // วาด Liquidity Levels
input int MaxLiquidityLevels = 10;          // จำนวน Liquidity สูงสุด

input group "=== Multi-Timeframe Enhanced ==="
input bool UseHigherTF = true;              // ใช้ Higher Timeframe
input ENUM_TIMEFRAMES HigherTF = PERIOD_H4; // Higher Timeframe
input bool HTF_TrendFilter = true;          // กรอง Trend จาก HTF
input int HTF_TrendPeriod = 50;             // HTF Trend Period
input bool UseMultipleTF = true;            // ใช้หลาย Timeframe

input group "=== Market Structure ==="
input bool UseMarketStructure = true;       // ใช้ Market Structure
input int MS_LookbackPeriod = 100;          // Market Structure Lookback
input double MS_MinBreak = 0.5;             // การเบรคขั้นต่ำ (ATR)

input group "=== Session Filter ==="
input bool UseSessionFilter = true;         // ใช้ Session Filter
input bool TradeLondonSession = true;       // เทรดช่วง London (15:00-24:00 GMT+7)
input bool TradeNewYorkSession = true;      // เทรดช่วง New York (20:00-05:00 GMT+7)
input bool TradeAsianSession = false;       // เทรดช่วง Asian (01:00-10:00 GMT+7)
input bool AvoidMajorNews = true;           // หลีกเลี่ยงข่าวสำคัญ

input group "=== Signal Filtering ==="
input bool UseVolumeFilter = true;          // ใช้ Volume Filter
input double MinVolumeMultiplier = 1.2;     // ปริมาณขั้นต่ำ (เฉลี่ย)
input bool UseMomentumFilter = true;        // ใช้ Momentum Filter
input int MomentumPeriod = 14;              // Momentum Period
input bool UseConfluenceFilter = true;      // ใช้ Confluence Filter
input int MinConfluenceSignals = 3;         // สัญญาณขั้นต่ำที่ต้องมาบรรจบ

input group "=== Trading Days ==="
input bool TradeOnMonday = true;            // เทรดวันจันทร์
input bool TradeOnTuesday = true;           // เทรดวันอังคาร
input bool TradeOnWednesday = true;         // เทรดวันพุธ
input bool TradeOnThursday = true;          // เทรดวันพฤหัสบดี
input bool TradeOnFriday = true;            // เทรดวันศุกร์

input group "=== Alert Settings ==="
input bool EnableAlerts = true;             // เปิดใช้งาน Alert
input bool EnablePushNotification = false;  // ส่ง Push Notification
input bool EnableEmailAlert = false;        // ส่ง Email Alert

input group "=== Dashboard Settings Enhanced ==="
input bool ShowDashboard = true;            // แสดง Dashboard
input bool ShowDetailedInfo = true;         // แสดงข้อมูลละเอียด
input int Dashboard_X = 20;                 // Dashboard X Position
input int Dashboard_Y = 50;                 // Dashboard Y Position
input color Dashboard_Color = clrWhite;     // Dashboard Text Color
input int Dashboard_FontSize = 9;           // Dashboard Font Size

// Global Variables Enhanced
int obvHandle, atrHandle, volumeHandle, rsiHandle;
double obvBuffer[], obvMABuffer[], atrBuffer[], volumeBuffer[], rsiBuffer[];
bool newBar = false;
datetime lastBarTime = 0;
int maxFVGCount = 100;
int maxOBCount = 100;
int maxLiquidityCount = 50;

// Enhanced Structures
struct FVGStruct {
    datetime time;
    double topPrice;
    double bottomPrice;
    bool isBullish;
    bool isValid;
    bool isFilled;
    double strength;        // ความแรงของ FVG
    double atrSize;         // ขนาดเทียบกับ ATR
};

struct OrderBlockStruct {
    datetime time;
    double topPrice;
    double bottomPrice;
    bool isBullish;
    bool isValid;
    double strength;
    double volume;          // ปริมาณการเทรด
    int touches;            // จำนวนครั้งที่ถูกทดสอบ
};

struct LiquidityLevel {
    double price;
    datetime time;
    bool isHigh;
    bool isSwept;
    double strength;        // ความแรงของ Level
    int confirmations;      // การยืนยัน
};

struct MarketStructure {
    datetime time;
    double price;
    bool isHigh;
    bool isBroken;
    double strength;
};

struct SignalComponents {
    bool obvSignal;
    bool fvgSignal;
    bool obSignal;
    bool liquiditySignal;
    bool bosSignal;
    bool volumeSignal;
    bool momentumSignal;
    bool htfSignal;
    bool sessionSignal;
};

// Arrays
FVGStruct fvgList[];
int fvgCount = 0;
OrderBlockStruct obList[];
int obCount = 0;
LiquidityLevel liquidityLevels[];
int liquidityCount = 0;
MarketStructure msLevels[];
int msCount = 0;

// Enhanced Trading Statistics
struct TradingStats {
    int totalTrades;
    int winningTrades;
    int losingTrades;
    double totalProfit;
    double totalLoss;
    double maxDrawdown;
    double maxProfit;
    double winStreak;
    double lossStreak;
    double avgWin;
    double avgLoss;
    double profitFactor;
    double sharpeRatio;
};

TradingStats stats;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // สร้าง Indicators
    obvHandle = iOBV(_Symbol, PERIOD_CURRENT, VOLUME_TICK);
    atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
    volumeHandle = iVolumes(_Symbol, PERIOD_CURRENT, VOLUME_TICK);
    rsiHandle = iRSI(_Symbol, PERIOD_CURRENT, MomentumPeriod, PRICE_CLOSE);
    
    if(obvHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE || 
       volumeHandle == INVALID_HANDLE || rsiHandle == INVALID_HANDLE)
    {
        Print("Error creating indicators");
        return(INIT_FAILED);
    }
    
    // Initialize Arrays
    ArraySetAsSeries(obvBuffer, true);
    ArraySetAsSeries(obvMABuffer, true);
    ArraySetAsSeries(atrBuffer, true);
    ArraySetAsSeries(volumeBuffer, true);
    ArraySetAsSeries(rsiBuffer, true);
    
    ArrayResize(fvgList, maxFVGCount);
    ArrayResize(obList, maxOBCount);
    ArrayResize(liquidityLevels, maxLiquidityCount);
    ArrayResize(msLevels, 200);
    
    // Initialize Statistics
    ZeroMemory(stats);
    
    // Create Dashboard
    if(ShowDashboard)
        CreateEnhancedDashboard();
    
    Print("═══════════════════════════════════════");
    Print("Gold SMC EA Pro V3.0 Initialized");
    Print("Enhanced Risk Management Edition");
    Print("Symbol: ", _Symbol);
    Print("Timeframe: ", EnumToString(PERIOD_CURRENT));
    Print("SL Mode: ", EnumToString(SL_Mode));
    Print("═══════════════════════════════════════");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Enhanced UpdateIndicators function                               |
//+------------------------------------------------------------------+
void UpdateIndicators()
{
    int copySize = MathMax(OBV_Period + 20, 100);
    
    // Resize arrays
    ArrayResize(obvBuffer, copySize);
    ArrayResize(obvMABuffer, copySize);
    ArrayResize(atrBuffer, 50);
    ArrayResize(volumeBuffer, copySize);
    ArrayResize(rsiBuffer, 50);
    
    // Copy indicator buffers
    if(CopyBuffer(obvHandle, 0, 0, copySize, obvBuffer) <= 0 ||
       CopyBuffer(atrHandle, 0, 0, 50, atrBuffer) <= 0 ||
       CopyBuffer(volumeHandle, 0, 0, copySize, volumeBuffer) <= 0 ||
       CopyBuffer(rsiHandle, 0, 0, 50, rsiBuffer) <= 0)
    {
        Print("Error copying indicator buffers: ", GetLastError());
        return;
    }
    
    // Calculate OBV Moving Average with validation
    if(ArraySize(obvBuffer) >= OBV_Period)
    {
        ArrayResize(obvMABuffer, ArraySize(obvBuffer));
        
        if(OBV_MA_Method == MODE_SMA)
        {
            for(int i = 0; i < ArraySize(obvBuffer) - OBV_Period + 1; i++)
            {
                double sum = 0;
                for(int j = 0; j < OBV_Period; j++)
                    sum += obvBuffer[i + j];
                obvMABuffer[i] = sum / OBV_Period;
            }
        }
        else if(OBV_MA_Method == MODE_EMA)
        {
            double multiplier = 2.0 / (OBV_Period + 1.0);
            double sum = 0;
            int startIdx = ArraySize(obvBuffer) - 1;
            
            // Calculate initial SMA for first EMA value
            for(int j = 0; j < OBV_Period && startIdx - j >= 0; j++)
                sum += obvBuffer[startIdx - j];
            obvMABuffer[startIdx] = sum / OBV_Period;
            
            // Calculate EMA
            for(int i = startIdx - 1; i >= 0; i--)
                obvMABuffer[i] = (obvBuffer[i] - obvMABuffer[i + 1]) * multiplier + obvMABuffer[i + 1];
        }
    }
}

//+------------------------------------------------------------------+
//| Enhanced Calculate Stop Loss                                     |
//+------------------------------------------------------------------+
double CalculateStopLoss(bool isBuy, double entryPrice = 0)
{
    if(entryPrice == 0)
        entryPrice = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 0;
    double slDistance = 0;
    
    switch(SL_Mode)
    {
        case SL_FIXED:
            slDistance = StopLoss_Fixed * _Point;
            break;
            
        case SL_ATR:
            if(atr > 0)
                slDistance = atr * ATR_Multiplier;
            else
                slDistance = StopLoss_Fixed * _Point;
            break;
            
        case SL_SWING:
            slDistance = CalculateSwingSL(isBuy, entryPrice);
            break;
            
        case SL_SMART:
            slDistance = CalculateSmartSL(isBuy, entryPrice);
            break;
    }
    
    // Apply min/max limits
    double minSL = SL_MinDistance * _Point;
    double maxSL = SL_MaxDistance * _Point;
    slDistance = MathMax(minSL, MathMin(maxSL, slDistance));
    
    return isBuy ? entryPrice - slDistance : entryPrice + slDistance;
}

//+------------------------------------------------------------------+
//| Calculate Swing-based Stop Loss                                  |
//+------------------------------------------------------------------+
double CalculateSwingSL(bool isBuy, double entryPrice)
{
    double swingLevel = 0;
    double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 1000 * _Point;
    
    // Find recent swing level
    for(int i = 5; i < 50; i++)
    {
        if(isBuy)
        {
            // Find swing low
            bool isSwingLow = true;
            double low = iLow(_Symbol, PERIOD_CURRENT, i);
            
            for(int j = i - 3; j <= i + 3; j++)
            {
                if(j == i) continue;
                if(j >= 0 && iLow(_Symbol, PERIOD_CURRENT, j) < low)
                {
                    isSwingLow = false;
                    break;
                }
            }
            
            if(isSwingLow && low < entryPrice)
            {
                swingLevel = low - (atr * 0.5); // Add buffer
                break;
            }
        }
        else
        {
            // Find swing high
            bool isSwingHigh = true;
            double high = iHigh(_Symbol, PERIOD_CURRENT, i);
            
            for(int j = i - 3; j <= i + 3; j++)
            {
                if(j == i) continue;
                if(j >= 0 && iHigh(_Symbol, PERIOD_CURRENT, j) > high)
                {
                    isSwingHigh = false;
                    break;
                }
            }
            
            if(isSwingHigh && high > entryPrice)
            {
                swingLevel = high + (atr * 0.5); // Add buffer
                break;
            }
        }
    }
    
    if(swingLevel == 0)
        return atr * ATR_Multiplier; // Fallback to ATR
    
    return MathAbs(entryPrice - swingLevel);
}

//+------------------------------------------------------------------+
//| Calculate Smart Stop Loss (Combined method)                      |
//+------------------------------------------------------------------+
double CalculateSmartSL(bool isBuy, double entryPrice)
{
    double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 1000 * _Point;
    double atrSL = atr * ATR_Multiplier;
    double swingSL = CalculateSwingSL(isBuy, entryPrice);
    
    // ใช้ค่าที่เหมาะสมระหว่าง ATR และ Swing
    double smartSL = (atrSL + swingSL) / 2.0;
    
    // ปรับตามสภาพตลาด
    double volatility = CalculateVolatility();
    if(volatility > 1.5) // ตลาดผันผวนสูง
        smartSL *= 1.3;
    else if(volatility < 0.5) // ตลาดเงียบ
        smartSL *= 0.8;
    
    return smartSL;
}

//+------------------------------------------------------------------+
//| Calculate Market Volatility                                      |
//+------------------------------------------------------------------+
double CalculateVolatility()
{
    if(ArraySize(atrBuffer) < 20) return 1.0;
    
    double currentATR = atrBuffer[0];
    double avgATR = 0;
    
    for(int i = 0; i < 20; i++)
        avgATR += atrBuffer[i];
    avgATR /= 20;
    
    return (avgATR > 0) ? currentATR / avgATR : 1.0;
}

//+------------------------------------------------------------------+
//| Enhanced Trade Signal with Confluence                            |
//+------------------------------------------------------------------+
int GetEnhancedTradeSignal()
{
    if(ArraySize(obvBuffer) < 1 || ArraySize(obvMABuffer) < 1) return 0;
    
    double currentClose = iClose(_Symbol, PERIOD_CURRENT, 1);
    if(currentClose <= 0) return 0;
    
    SignalComponents bullish = {false}, bearish = {false};
    
    // 1. OBV Signal
    double obvDiff = obvBuffer[0] - obvMABuffer[0];
    double obvNormalized = (ArraySize(obvBuffer) > 1) ? obvDiff / MathAbs(obvMABuffer[0]) : 0;
    
    bullish.obvSignal = obvNormalized > OBV_Threshold;
    bearish.obvSignal = obvNormalized < -OBV_Threshold;
    
    // 2. FVG Signal
    CheckFVGSignals(currentClose, bullish.fvgSignal, bearish.fvgSignal);
    
    // 3. Order Block Signal
    if(UseOrderBlock)
        CheckOBSignals(currentClose, bullish.obSignal, bearish.obSignal);
    
    // 4. Liquidity Signal
    CheckLiquiditySignals(bullish.liquiditySignal, bearish.liquiditySignal);
    
    // 5. BOS Signal
    if(UseBOS)
        CheckBOSSignals(bullish.bosSignal, bearish.bosSignal);
    
    // 6. Volume Filter
    if(UseVolumeFilter)
        CheckVolumeSignals(bullish.volumeSignal, bearish.volumeSignal);
    
    // 7. Momentum Filter
    if(UseMomentumFilter)
        CheckMomentumSignals(bullish.momentumSignal, bearish.momentumSignal);
    
    // 8. Higher Timeframe Signal
    if(UseHigherTF && HTF_TrendFilter)
        CheckHTFSignals(bullish.htfSignal, bearish.htfSignal);
    
    // 9. Session Filter
    if(UseSessionFilter)
    {
        bool sessionOK = IsGoodTradingSession();
        bullish.sessionSignal = sessionOK;
        bearish.sessionSignal = sessionOK;
    }
    else
    {
        bullish.sessionSignal = true;
        bearish.sessionSignal = true;
    }
    
    // Count confluence signals
    int bullishCount = CountSignals(bullish);
    int bearishCount = CountSignals(bearish);
    
    // Decision logic
    if(UseConfluenceFilter)
    {
        if(bullishCount >= MinConfluenceSignals && bullishCount > bearishCount)
            return 1;
        if(bearishCount >= MinConfluenceSignals && bearishCount > bullishCount)
            return -1;
    }
    else
    {
        // Traditional logic with some confluence
        if(bullish.obvSignal && bullish.sessionSignal && 
           (bullish.fvgSignal || bullish.obSignal) && bullishCount >= 3)
            return 1;
        if(bearish.obvSignal && bearish.sessionSignal && 
           (bearish.fvgSignal || bearish.obSignal) && bearishCount >= 3)
            return -1;
    }
    
    return 0;
}

//+------------------------------------------------------------------+
//| Check FVG Signals                                               |
//+------------------------------------------------------------------+
void CheckFVGSignals(double currentPrice, bool &bullSignal, bool &bearSignal)
{
    for(int i = 0; i < fvgCount; i++)
    {
        if(!fvgList[i].isValid || fvgList[i].isFilled) continue;
        
        // Check if price is in FVG zone
        if(currentPrice >= fvgList[i].bottomPrice && currentPrice <= fvgList[i].topPrice)
        {
            if(fvgList[i].isBullish)
                bullSignal = true;
            else
                bearSignal = true;
        }
        
        // Check if price is approaching FVG
        double distance = MathMin(MathAbs(currentPrice - fvgList[i].topPrice), 
                                 MathAbs(currentPrice - fvgList[i].bottomPrice));
        double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 1000 * _Point;
        
        if(distance < atr * 0.5)
        {
            if(fvgList[i].isBullish && currentPrice < fvgList[i].bottomPrice)
                bullSignal = true;
            else if(!fvgList[i].isBullish && currentPrice > fvgList[i].topPrice)
                bearSignal = true;
        }
    }
}

//+------------------------------------------------------------------+
//| Check Order Block Signals                                        |
//+------------------------------------------------------------------+
void CheckOBSignals(double currentPrice, bool &bullSignal, bool &bearSignal)
{
    for(int i = 0; i < obCount; i++)
    {
        if(!obList[i].isValid) continue;
        
        if(currentPrice >= obList[i].bottomPrice && currentPrice <= obList[i].topPrice)
        {
            if(obList[i].isBullish)
                bullSignal = true;
            else
                bearSignal = true;
        }
    }
}

//+------------------------------------------------------------------+
//| Check Liquidity Signals                                         |
//+------------------------------------------------------------------+
void CheckLiquiditySignals(bool &bullSignal, bool &bearSignal)
{
    // Check recent liquidity sweeps
    datetime recentTime = TimeCurrent() - PeriodSeconds(PERIOD_CURRENT) * 10;
    
    for(int i = 0; i < liquidityCount; i++)
    {
        if(!liquidityLevels[i].isSwept || liquidityLevels[i].time < recentTime) continue;
        
        if(!liquidityLevels[i].isHigh) // Swept low = bullish
            bullSignal = true;
        else // Swept high = bearish
            bearSignal = true;
    }
}

//+------------------------------------------------------------------+
//| Check BOS Signals                                               |
//+------------------------------------------------------------------+
void CheckBOSSignals(bool &bullSignal, bool &bearSignal)
{
    if(msCount == 0) return;
    
    // Check recent BOS
    datetime recentTime = TimeCurrent() - PeriodSeconds(PERIOD_CURRENT) * 5;
    
    for(int i = msCount - 1; i >= 0; i--)
    {
        if(msLevels[i].time < recentTime) break;
        
        if(msLevels[i].isBroken)
        {
            if(!msLevels[i].isHigh) // Broke above high = bullish
                bullSignal = true;
            else // Broke below low = bearish
                bearSignal = true;
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Check Volume Signals                                            |
//+------------------------------------------------------------------+
void CheckVolumeSignals(bool &bullSignal, bool &bearSignal)
{
    if(ArraySize(volumeBuffer) < 20) return;
    
    double currentVolume = volumeBuffer[0];
    double avgVolume = 0;
    
    for(int i = 1; i < 20; i++)
        avgVolume += volumeBuffer[i];
    avgVolume /= 19;
    
    if(currentVolume > avgVolume * MinVolumeMultiplier)
    {
        bullSignal = true;
        bearSignal = true; // Volume confirmation for both directions
    }
}

//+------------------------------------------------------------------+
//| Check Momentum Signals                                          |
//+------------------------------------------------------------------+
void CheckMomentumSignals(bool &bullSignal, bool &bearSignal)
{
    if(ArraySize(rsiBuffer) < 2) return;
    
    double currentRSI = rsiBuffer[0];
    double prevRSI = rsiBuffer[1];
    
    // RSI momentum
    if(currentRSI > prevRSI && currentRSI > 50)
        bullSignal = true;
    else if(currentRSI < prevRSI && currentRSI < 50)
        bearSignal = true;
    
    // Avoid overbought/oversold
    if(currentRSI > 80)
        bullSignal = false;
    else if(currentRSI < 20)
        bearSignal = false;
}

//+------------------------------------------------------------------+
//| Check Higher Timeframe Signals                                  |
//+------------------------------------------------------------------+
void CheckHTFSignals(bool &bullSignal, bool &bearSignal)
{
    if(HigherTF <= PERIOD_CURRENT) return;
    
    double htfClose1 = iClose(_Symbol, HigherTF, 1);
    double htfClose10 = iClose(_Symbol, HigherTF, HTF_TrendPeriod/5);
    double htfClose20 = iClose(_Symbol, HigherTF, HTF_TrendPeriod/2);
    
    if(htfClose1 <= 0 || htfClose10 <= 0 || htfClose20 <= 0) return;
    
    // HTF trend confirmation
    if(htfClose1 > htfClose10 && htfClose10 > htfClose20)
        bullSignal = true;
    else if(htfClose1 < htfClose10 && htfClose10 < htfClose20)
        bearSignal = true;
}

//+------------------------------------------------------------------+
//| Count Signals                                                   |
//+------------------------------------------------------------------+
int CountSignals(const SignalComponents &signals)
{
    int count = 0;
    if(signals.obvSignal) count++;
    if(signals.fvgSignal) count++;
    if(signals.obSignal) count++;
    if(signals.liquiditySignal) count++;
    if(signals.bosSignal) count++;
    if(signals.volumeSignal) count++;
    if(signals.momentumSignal) count++;
    if(signals.htfSignal) count++;
    if(signals.sessionSignal) count++;
    return count;
}

//+------------------------------------------------------------------+
//| Check Trading Session                                           |
//+------------------------------------------------------------------+
bool IsGoodTradingSession()
{
    MqlDateTime tm;
    TimeToStruct(TimeCurrent(), tm);
    
    // GMT+7 (Thailand time) session times
    int hour = tm.hour;
    
    bool inSession = false;
    
    // London Session (15:00-24:00 GMT+7)
    if(TradeLondonSession && hour >= 15 && hour < 24)
        inSession = true;
    
    // New York Session (20:00-05:00 GMT+7) - overlaps with London
    if(TradeNewYorkSession && (hour >= 20 || hour < 5))
        inSession = true;
    
    // Asian Session (01:00-10:00 GMT+7)
    if(TradeAsianSession && hour >= 1 && hour < 10)
        inSession = true;
    
    // Avoid major news times
    if(AvoidMajorNews && IsNewsTime())
        inSession = false;
    
    return inSession;
}

//+------------------------------------------------------------------+
//| Enhanced News Time Check                                         |
//+------------------------------------------------------------------+
bool IsNewsTime()
{
    MqlDateTime tm;
    TimeToStruct(TimeCurrent(), tm);
    
    // Major news times in GMT+7
    // NFP (First Friday) - 20:30
    if(tm.hour == 20 && tm.min >= 15 && tm.min <= 45)
        return true;
    
    // FOMC, GDP, CPI - usually 20:30 or 21:30
    if((tm.hour == 20 || tm.hour == 21) && tm.min >= 15 && tm.min <= 45)
        return true;
    
    // European session major news - 15:30-16:30
    if(tm.hour >= 15 && tm.hour <= 16 && tm.min >= 15 && tm.min <= 45)
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Enhanced Order Management                                        |
//+------------------------------------------------------------------+
void ManageEnhancedPositions()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        
        ulong ticket = PositionGetInteger(POSITION_TICKET);
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double currentSL = PositionGetDouble(POSITION_SL);
        double currentTP = PositionGetDouble(POSITION_TP);
        bool isBuy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
        double currentPrice = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 1000 * _Point;
        
        // Enhanced Trailing Stop
        if(UseTrailingStop)
        {
            double trailDistance = atr * TrailingStop_ATR;
            double minMove = TrailingStep * _Point;
            
            if(isBuy)
            {
                double newSL = currentPrice - trailDistance;
                if(currentPrice > openPrice + trailDistance && newSL > currentSL + minMove)
                    ModifyPosition(ticket, newSL, currentTP);
            }
            else
            {
                double newSL = currentPrice + trailDistance;
                if(currentPrice < openPrice - trailDistance && (newSL < currentSL - minMove || currentSL == 0))
                    ModifyPosition(ticket, newSL, currentTP);
            }
        }
        
        // Enhanced Break Even
        if(UseBreakEven)
        {
            double beTrigger = atr * BreakEvenTrigger_ATR;
            double beLevel = openPrice + (isBuy ? BreakEvenProfit : -BreakEvenProfit) * _Point;
            
            if(isBuy && currentPrice > openPrice + beTrigger && currentSL < beLevel)
                ModifyPosition(ticket, beLevel, currentTP);
            else if(!isBuy && currentPrice < openPrice - beTrigger && (currentSL > beLevel || currentSL == 0))
                ModifyPosition(ticket, beLevel, currentTP);
        }
        
        // Partial Close
        if(UsePartialClose)
        {
            double partialTrigger = atr * PartialClose_ATR;
            bool shouldPartialClose = false;
            
            if(isBuy && currentPrice > openPrice + partialTrigger)
                shouldPartialClose = true;
            else if(!isBuy && currentPrice < openPrice - partialTrigger)
                shouldPartialClose = true;
            
            if(shouldPartialClose && !IsPositionPartiallyClased(ticket))
                PartialClosePosition(ticket, PartialClose_Percent);
        }
    }
}

//+------------------------------------------------------------------+
//| Check if position was partially closed                          |
//+------------------------------------------------------------------+
bool IsPositionPartiallyClased(ulong ticket)
{
    string comment = PositionGetString(POSITION_COMMENT);
    return StringFind(comment, "Partial") >= 0;
}

//+------------------------------------------------------------------+
//| Partial Close Position                                           |
//+------------------------------------------------------------------+
void PartialClosePosition(ulong ticket, double percent)
{
    if(!PositionSelectByTicket(ticket)) return;
    
    double volume = PositionGetDouble(POSITION_VOLUME);
    double closeVolume = NormalizeDouble(volume * percent / 100.0, 2);
    double minVolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    
    if(closeVolume < minVolume) return;
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.position = ticket;
    request.volume = closeVolume;
    request.type = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
    request.price = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                   SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    request.comment = "Partial Close " + DoubleToString(percent, 0) + "%";
    
    if(OrderSend(request, result))
        Print("✅ Partial close executed: ", percent, "% of position ", ticket);
    else
        Print("❌ Partial close failed: ", GetLastError());
}

//+------------------------------------------------------------------+
//| Modify Position                                                  |
//+------------------------------------------------------------------+
void ModifyPosition(ulong ticket, double sl, double tp)
{
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_SLTP;
    request.symbol = _Symbol;
    request.position = ticket;
    request.sl = sl;
    request.tp = tp;
    
    if(!OrderSend(request, result))
        Print("❌ Position modify failed: ", GetLastError());
}

//+------------------------------------------------------------------+
//| Enhanced Open Buy with dynamic SL/TP                            |
//+------------------------------------------------------------------+
void OpenEnhancedBuy()
{
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double sl = CalculateStopLoss(true, ask);
    double slDistance = ask - sl;
    double tp = ask + (slDistance * RiskRewardRatio);
    double lot = CalculateEnhancedLotSize(slDistance);
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = lot;
    request.type = ORDER_TYPE_BUY;
    request.price = ask;
    request.sl = sl;
    request.tp = tp;
    request.deviation = 30;
    request.magic = 123456;
    request.comment = StringFormat("SMC Buy V3 - SL:%.0f", slDistance/_Point);
    
    if(!OrderSend(request, result))
    {
        Print("❌ Enhanced Buy Order Failed: Error ", GetLastError());
        Print("Retcode: ", result.retcode);
        Print("Ask: ", ask, " | SL: ", sl, " | SL Distance: ", slDistance/_Point, " points");
    }
    else
    {
        stats.totalTrades++;
        Print("✅ Enhanced Buy Order Opened - Ticket: ", result.order);
        Print("Entry: ", ask, " | SL: ", sl, " (", DoubleToString(slDistance/_Point, 0), " points)");
        Print("TP: ", tp, " | Risk/Reward: 1:", RiskRewardRatio, " | Lot: ", lot);
    }
}

//+------------------------------------------------------------------+
//| Enhanced Open Sell with dynamic SL/TP                           |
//+------------------------------------------------------------------+
void OpenEnhancedSell()
{
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double sl = CalculateStopLoss(false, bid);
    double slDistance = sl - bid;
    double tp = bid - (slDistance * RiskRewardRatio);
    double lot = CalculateEnhancedLotSize(slDistance);
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = lot;
    request.type = ORDER_TYPE_SELL;
    request.price = bid;
    request.sl = sl;
    request.tp = tp;
    request.deviation = 30;
    request.magic = 123456;
    request.comment = StringFormat("SMC Sell V3 - SL:%.0f", slDistance/_Point);
    
    if(!OrderSend(request, result))
    {
        Print("❌ Enhanced Sell Order Failed: Error ", GetLastError());
        Print("Retcode: ", result.retcode);
        Print("Bid: ", bid, " | SL: ", sl, " | SL Distance: ", slDistance/_Point, " points");
    }
    else
    {
        stats.totalTrades++;
        Print("✅ Enhanced Sell Order Opened - Ticket: ", result.order);
        Print("Entry: ", bid, " | SL: ", sl, " (", DoubleToString(slDistance/_Point, 0), " points)");
        Print("TP: ", tp, " | Risk/Reward: 1:", RiskRewardRatio, " | Lot: ", DoubleToString(lot, 2));
    }
}

//+------------------------------------------------------------------+
//| Enhanced Lot Size Calculation                                    |
//+------------------------------------------------------------------+
double CalculateEnhancedLotSize(double slDistance)
{
    if(!UseAutoLot)
        return LotSize;
    
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountBalance * RiskPercent / 100.0;
    
    // คำนวณค่า Tick Value
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double pointValue = (tickValue * _Point) / tickSize;
    
    // คำนวณ Lot Size
    double lotSize = riskAmount / (slDistance / _Point * pointValue);
    
    // ปรับตามข้อจำกัดของ Broker
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    lotSize = MathFloor(lotSize / lotStep) * lotStep;
    lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
    
    // Additional safety check for cent accounts
    double maxRiskLot = accountBalance / 10000.0; // Max 1 lot per $100 in cent account
    lotSize = MathMin(lotSize, maxRiskLot);
    
    Print("💰 Lot Calculation: Risk=", riskAmount, " | SL Distance=", slDistance/_Point, 
          " points | Calculated Lot=", DoubleToString(lotSize, 2));
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Create Enhanced Dashboard                                        |
//+------------------------------------------------------------------+
void CreateEnhancedDashboard()
{
    int y = Dashboard_Y;
    int lineHeight = Dashboard_FontSize + 3;
    
    // Title
    CreateLabel("DASH_Title", Dashboard_X, y, "══════ GOLD SMC EA PRO V3.0 ══════", Dashboard_FontSize + 2, clrGold);
    y += lineHeight * 2;
    CreateLabel("DASH_Subtitle", Dashboard_X, y, "Enhanced Risk Management Edition", Dashboard_FontSize, clrYellow);
    y += lineHeight * 2;
    
    // System Status
    CreateLabel("DASH_SystemStatus", Dashboard_X, y, "System Status: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_SignalStrength", Dashboard_X, y, "Signal Strength: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_SessionInfo", Dashboard_X, y, "Session: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight * 2;
    
    // Position Info
    CreateLabel("DASH_PositionInfo", Dashboard_X, y, "═══ POSITION INFO ═══", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_OpenPositions", Dashboard_X, y, "Open Positions: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_TodaysPnL", Dashboard_X, y, "Today's P&L: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight * 2;
    
    // Enhanced Statistics
    CreateLabel("DASH_StatsTitle", Dashboard_X, y, "═══ ENHANCED STATISTICS ═══", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_TotalTrades", Dashboard_X, y, "Total Trades: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_WinRate", Dashboard_X, y, "Win Rate: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_ProfitFactor", Dashboard_X, y, "Profit Factor: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_MaxDrawdown", Dashboard_X, y, "Max Drawdown: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_AvgWin", Dashboard_X, y, "Avg Win/Loss: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight * 2;
    
    // Market Analysis
    CreateLabel("DASH_MarketTitle", Dashboard_X, y, "═══ MARKET ANALYSIS ═══", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_Volatility", Dashboard_X, y, "Volatility: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_OBVStatus", Dashboard_X, y, "OBV: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_FVGCount", Dashboard_X, y, "FVG Zones: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_OBCount", Dashboard_X, y, "Order Blocks: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    CreateLabel("DASH_LiquidityStatus", Dashboard_X, y, "Liquidity: ", Dashboard_FontSize, Dashboard_Color);
    y += lineHeight;
    
    if(ShowDetailedInfo)
    {
        y += lineHeight;
        CreateLabel("DASH_DetailTitle", Dashboard_X, y, "═══ DETAILED INFO ═══", Dashboard_FontSize, Dashboard_Color);
        y += lineHeight;
        CreateLabel("DASH_ATRInfo", Dashboard_X, y, "ATR: ", Dashboard_FontSize, Dashboard_Color);
        y += lineHeight;
        CreateLabel("DASH_SLMode", Dashboard_X, y, "SL Mode: ", Dashboard_FontSize, Dashboard_Color);
        y += lineHeight;
        CreateLabel("DASH_NextSLDistance", Dashboard_X, y, "Next SL Distance: ", Dashboard_FontSize, Dashboard_Color);
        y += lineHeight;
        CreateLabel("DASH_RiskInfo", Dashboard_X, y, "Risk per Trade: ", Dashboard_FontSize, Dashboard_Color);
    }
}

//+------------------------------------------------------------------+
//| Enhanced Dashboard Update                                        |
//+------------------------------------------------------------------+
void UpdateEnhancedDashboard()
{
    if(ArraySize(obvBuffer) < 1 || ArraySize(obvMABuffer) < 1) return;
    
    // System Status
    string systemStatus = "🔴 Offline";
    color systemColor = clrRed;
    
    if(IsTradeAllowed())
    {
        if(IsGoodTradingSession())
        {
            systemStatus = "🟢 Active";
            systemColor = clrLime;
        }
        else
        {
            systemStatus = "🟡 Standby";
            systemColor = clrYellow;
        }
    }
    
    ObjectSetString(0, "DASH_SystemStatus", OBJPROP_TEXT, "System Status: " + systemStatus);
    ObjectSetInteger(0, "DASH_SystemStatus", OBJPROP_COLOR, systemColor);
    
    // Signal Strength
    int signalStrength = GetSignalStrength();
    string strengthText = StringFormat("Signal Strength: %d/9", signalStrength);
    color strengthColor = clrGray;
    if(signalStrength >= 6) strengthColor = clrLime;
    else if(signalStrength >= 4) strengthColor = clrYellow;
    else if(signalStrength >= 2) strengthColor = clrOrange;
    
    ObjectSetString(0, "DASH_SignalStrength", OBJPROP_TEXT, strengthText);
    ObjectSetInteger(0, "DASH_SignalStrength", OBJPROP_COLOR, strengthColor);
    
    // Session Info
    string sessionInfo = GetCurrentSessionInfo();
    ObjectSetString(0, "DASH_SessionInfo", OBJPROP_TEXT, "Session: " + sessionInfo);
    
    // Position Info
    int buyPos = CountOpenPositions(POSITION_TYPE_BUY);
    int sellPos = CountOpenPositions(POSITION_TYPE_SELL);
    ObjectSetString(0, "DASH_OpenPositions", OBJPROP_TEXT, 
                   StringFormat("Open Positions: Buy=%d | Sell=%d", buyPos, sellPos));
    
    // Today's P&L
    double todayPnL = GetTodaysPnL();
    color pnlColor = (todayPnL >= 0) ? clrLime : clrRed;
    ObjectSetString(0, "DASH_TodaysPnL", OBJPROP_TEXT, 
                   StringFormat("Today's P&L: %.2f USD", todayPnL));
    ObjectSetInteger(0, "DASH_TodaysPnL", OBJPROP_COLOR, pnlColor);
    
    // Enhanced Statistics
    UpdateEnhancedStatistics();
    
    double winRate = (stats.totalTrades > 0) ? (stats.winningTrades * 100.0 / stats.totalTrades) : 0;
    ObjectSetString(0, "DASH_TotalTrades", OBJPROP_TEXT, 
                   StringFormat("Total Trades: %d", stats.totalTrades));
    ObjectSetString(0, "DASH_WinRate", OBJPROP_TEXT, 
                   StringFormat("Win Rate: %.1f%% (%d/%d)", winRate, stats.winningTrades, stats.totalTrades));
    
    ObjectSetString(0, "DASH_ProfitFactor", OBJPROP_TEXT, 
                   StringFormat("Profit Factor: %.2f", stats.profitFactor));
    
    color pfColor = (stats.profitFactor >= 1.5) ? clrLime : (stats.profitFactor >= 1.0) ? clrYellow : clrRed;
    ObjectSetInteger(0, "DASH_ProfitFactor", OBJPROP_COLOR, pfColor);
    
    ObjectSetString(0, "DASH_MaxDrawdown", OBJPROP_TEXT, 
                   StringFormat("Max Drawdown: %.2f%%", stats.maxDrawdown));
    
    ObjectSetString(0, "DASH_AvgWin", OBJPROP_TEXT, 
                   StringFormat("Avg Win/Loss: %.2f / %.2f", stats.avgWin, stats.avgLoss));
    
    // Market Analysis
    double volatility = CalculateVolatility();
    string volText = (volatility > 1.5) ? "High" : (volatility > 0.8) ? "Normal" : "Low";
    ObjectSetString(0, "DASH_Volatility", OBJPROP_TEXT, 
                   StringFormat("Volatility: %s (%.2f)", volText, volatility));
    
    bool obvBullish = obvBuffer[0] > obvMABuffer[0];
    string obvStatus = obvBullish ? "🟢 Bullish" : "🔴 Bearish";
    ObjectSetString(0, "DASH_OBVStatus", OBJPROP_TEXT, "OBV: " + obvStatus);
    
    ObjectSetString(0, "DASH_FVGCount", OBJPROP_TEXT, 
                   StringFormat("FVG Zones: %d active", GetActiveFVGCount()));
    ObjectSetString(0, "DASH_OBCount", OBJPROP_TEXT, 
                   StringFormat("Order Blocks: %d active", GetActiveOBCount()));
    
    int sweptCount = GetSweptLiquidityCount();
    ObjectSetString(0, "DASH_LiquidityStatus", OBJPROP_TEXT, 
                   StringFormat("Liquidity: %d swept / %d total", sweptCount, liquidityCount));
    
    // Detailed Info
    if(ShowDetailedInfo)
    {
        double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 0;
        ObjectSetString(0, "DASH_ATRInfo", OBJPROP_TEXT, 
                       StringFormat("ATR: %.1f points", atr/_Point));
        
        ObjectSetString(0, "DASH_SLMode", OBJPROP_TEXT, 
                       "SL Mode: " + EnumToString(SL_Mode));
        
        double nextSL = CalculateStopLoss(true);
        double slDistance = MathAbs(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - nextSL);
        ObjectSetString(0, "DASH_NextSLDistance", OBJPROP_TEXT, 
                       StringFormat("Next SL Distance: %.0f points", slDistance/_Point));
        
        double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        double riskAmount = accountBalance * RiskPercent / 100.0;
        ObjectSetString(0, "DASH_RiskInfo", OBJPROP_TEXT, 
                       StringFormat("Risk per Trade: %.2f USD (%.1f%%)", riskAmount, RiskPercent));
    }
}

//+------------------------------------------------------------------+
//| Get Signal Strength (0-9)                                       |
//+------------------------------------------------------------------+
int GetSignalStrength()
{
    if(ArraySize(obvBuffer) < 1) return 0;
    
    bool bullSignals[9] = {false};
    bool bearSignals[9] = {false};
    
    double currentClose = iClose(_Symbol, PERIOD_CURRENT, 1);
    
    // Count all signal components
    CheckFVGSignals(currentClose, bullSignals[0], bearSignals[0]);
    CheckOBSignals(currentClose, bullSignals[1], bearSignals[1]);
    CheckLiquiditySignals(bullSignals[2], bearSignals[2]);
    CheckBOSSignals(bullSignals[3], bearSignals[3]);
    CheckVolumeSignals(bullSignals[4], bearSignals[4]);
    CheckMomentumSignals(bullSignals[5], bearSignals[5]);
    CheckHTFSignals(bullSignals[6], bearSignals[6]);
    
    bullSignals[7] = obvBuffer[0] > obvMABuffer[0];
    bearSignals[7] = obvBuffer[0] < obvMABuffer[0];
    
    bullSignals[8] = IsGoodTradingSession();
    bearSignals[8] = IsGoodTradingSession();
    
    int bullCount = 0, bearCount = 0;
    for(int i = 0; i < 9; i++)
    {
        if(bullSignals[i]) bullCount++;
        if(bearSignals[i]) bearCount++;
    }
    
    return MathMax(bullCount, bearCount);
}

//+------------------------------------------------------------------+
//| Get Current Session Info                                         |
//+------------------------------------------------------------------+
string GetCurrentSessionInfo()
{
    MqlDateTime tm;
    TimeToStruct(TimeCurrent(), tm);
    int hour = tm.hour;
    
    if(hour >= 15 && hour < 20)
        return "🇬🇧 London Open";
    else if(hour >= 20 || hour < 2)
        return "🇺🇸 NY Session";
    else if(hour >= 2 && hour < 10)
        return "🇯🇵 Asian Session";
    else
        return "🌙 Low Activity";
}

//+------------------------------------------------------------------+
//| Get Today's P&L                                                 |
//+------------------------------------------------------------------+
double GetTodaysPnL()
{
    double pnl = 0;
    datetime todayStart = iTime(_Symbol, PERIOD_D1, 0);
    
    // Add open positions P&L
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionSelectByTicket(PositionGetTicket(i)))
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
                pnl += PositionGetDouble(POSITION_PROFIT);
        }
    }
    
    // Add closed positions P&L for today
    if(HistorySelect(todayStart, TimeCurrent()))
    {
        for(int i = 0; i < HistoryDealsTotal(); i++)
        {
            ulong ticket = HistoryDealGetTicket(i);
            if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol)
            {
                if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY ||
                   HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_SELL)
                {
                    pnl += HistoryDealGetDouble(ticket, DEAL_PROFIT);
                }
            }
        }
    }
    
    return pnl;
}

//+------------------------------------------------------------------+
//| Update Enhanced Statistics                                       |
//+------------------------------------------------------------------+
void UpdateEnhancedStatistics()
{
    stats.winningTrades = 0;
    stats.losingTrades = 0;
    stats.totalProfit = 0;
    stats.totalLoss = 0;
    stats.maxDrawdown = 0;
    stats.maxProfit = 0;
    
    double runningBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double peakBalance = runningBalance;
    double totalWinAmount = 0;
    double totalLossAmount = 0;
    
    if(HistorySelect(0, TimeCurrent()))
    {
        for(int i = 0; i < HistoryDealsTotal(); i++)
        {
            ulong ticket = HistoryDealGetTicket(i);
            if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol)
            {
                double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                if(profit != 0)
                {
                    runningBalance += profit;
                    
                    if(profit > 0)
                    {
                        stats.winningTrades++;
                        totalWinAmount += profit;
                        stats.totalProfit += profit;
                        if(profit > stats.maxProfit)
                            stats.maxProfit = profit;
                    }
                    else if(profit < 0)
                    {
                        stats.losingTrades++;
                        totalLossAmount += MathAbs(profit);
                        stats.totalLoss += MathAbs(profit);
                    }
                    
                    // Calculate drawdown
                    if(runningBalance > peakBalance)
                        peakBalance = runningBalance;
                    
                    double currentDrawdown = (peakBalance - runningBalance) / peakBalance * 100;
                    if(currentDrawdown > stats.maxDrawdown)
                        stats.maxDrawdown = currentDrawdown;
                }
            }
        }
    }
    
    stats.totalTrades = stats.winningTrades + stats.losingTrades;
    
    // Calculate averages
    stats.avgWin = (stats.winningTrades > 0) ? totalWinAmount / stats.winningTrades : 0;
    stats.avgLoss = (stats.losingTrades > 0) ? totalLossAmount / stats.losingTrades : 0;
    
    // Calculate profit factor
    stats.profitFactor = (stats.totalLoss > 0) ? stats.totalProfit / stats.totalLoss : 
                        (stats.totalProfit > 0) ? 999.99 : 0;
}

//+------------------------------------------------------------------+
//| Get Active FVG Count                                            |
//+------------------------------------------------------------------+
int GetActiveFVGCount()
{
    int count = 0;
    for(int i = 0; i < fvgCount; i++)
    {
        if(fvgList[i].isValid && !fvgList[i].isFilled)
            count++;
    }
    return count;
}

//+------------------------------------------------------------------+
//| Get Active Order Block Count                                    |
//+------------------------------------------------------------------+
int GetActiveOBCount()
{
    int count = 0;
    for(int i = 0; i < obCount; i++)
    {
        if(obList[i].isValid)
            count++;
    }
    return count;
}

//+------------------------------------------------------------------+
//| Get Swept Liquidity Count                                       |
//+------------------------------------------------------------------+
int GetSweptLiquidityCount()
{
    int count = 0;
    for(int i = 0; i < liquidityCount; i++)
    {
        if(liquidityLevels[i].isSwept)
            count++;
    }
    return count;
}

//+------------------------------------------------------------------+
//| Enhanced OnTick Function                                         |
//+------------------------------------------------------------------+
void OnTick()
{
    // Update Dashboard
    if(ShowDashboard)
        UpdateEnhancedDashboard();
    
    // Check for new bar
    if(IsNewBar())
    {
        newBar = true;
        
        // Update all indicators
        UpdateIndicators();
        
        // Detect market structure
        DetectEnhancedFVG();
        
        if(UseOrderBlock)
            DetectEnhancedOrderBlock();
        
        if(UseBOS)
            DetectEnhancedBOS();
        
        DetectEnhancedLiquidity();
        
        if(UseMarketStructure)
            DetectMarketStructure();
        
        CleanupOldData();
        
        // Check trading signals
        if(IsTradeAllowed())
        {
            int signal = GetEnhancedTradeSignal();
            
            if(signal == 1 && CountOpenPositions(POSITION_TYPE_BUY) == 0)
            {
                OpenEnhancedBuy();
                SendAlert("🟢 Enhanced Buy Signal Detected! 📈");
            }
            else if(signal == -1 && CountOpenPositions(POSITION_TYPE_SELL) == 0)
            {
                OpenEnhancedSell();
                SendAlert("🔴 Enhanced Sell Signal Detected! 📉");
            }
        }
    }
    
    // Enhanced position management
    ManageEnhancedPositions();
}

//+------------------------------------------------------------------+
//| Enhanced FVG Detection                                          |
//+------------------------------------------------------------------+
void DetectEnhancedFVG()
{
    double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 1000 * _Point;
    double minGapATR = atr * FVG_MinSize_ATR;
    double minGapPoints = FVG_MinGap * _Point;
    double minGap = MathMax(minGapATR, minGapPoints);
    
    for(int i = 2; i < FVG_Lookback; i++)
    {
        double high1 = iHigh(_Symbol, PERIOD_CURRENT, i-1);
        double low1 = iLow(_Symbol, PERIOD_CURRENT, i-1);
        double high3 = iHigh(_Symbol, PERIOD_CURRENT, i+1);
        double low3 = iLow(_Symbol, PERIOD_CURRENT, i+1);
        
        // Enhanced Bullish FVG
        if(low1 > high3)
        {
            double gap = low1 - high3;
            if(gap >= minGap)
            {
                double strength = gap / atr;
                AddEnhancedFVG(iTime(_Symbol, PERIOD_CURRENT, i), low1, high3, true, strength);
            }
        }
        
        // Enhanced Bearish FVG
        if(high1 < low3)
        {
            double gap = low3 - high1;
            if(gap >= minGap)
            {
                double strength = gap / atr;
                AddEnhancedFVG(iTime(_Symbol, PERIOD_CURRENT, i), low3, high1, false, strength);
            }
        }
    }
    
    // Check FVG fill status
    CheckFVGFillStatus();
}

//+------------------------------------------------------------------+
//| Add Enhanced FVG                                                |
//+------------------------------------------------------------------+
void AddEnhancedFVG(datetime time, double top, double bottom, bool isBullish, double strength)
{
    // Check if FVG already exists
    for(int i = 0; i < fvgCount; i++)
    {
        if(fvgList[i].time == time)
            return;
    }
    
    if(fvgCount >= ArraySize(fvgList))
        ArrayResize(fvgList, fvgCount + 50);
    
    fvgList[fvgCount].time = time;
    fvgList[fvgCount].topPrice = top;
    fvgList[fvgCount].bottomPrice = bottom;
    fvgList[fvgCount].isBullish = isBullish;
    fvgList[fvgCount].isValid = true;
    fvgList[fvgCount].isFilled = false;
    fvgList[fvgCount].strength = strength;
    fvgList[fvgCount].atrSize = strength;
    
    if(FVG_DrawOnChart)
        DrawEnhancedFVG(fvgCount);
    
    fvgCount++;
    
    Print("🎯 Enhanced FVG Detected: ", (isBullish ? "Bullish" : "Bearish"), 
          " | Strength: ", DoubleToString(strength, 2), " ATR");
}

//+------------------------------------------------------------------+
//| Draw Enhanced FVG                                               |
//+------------------------------------------------------------------+
void DrawEnhancedFVG(int index)
{
    string name = "FVG_" + IntegerToString(index) + "_" + TimeToString(fvgList[index].time);
    
    ObjectCreate(0, name, OBJ_RECTANGLE, 0, 
                 fvgList[index].time, fvgList[index].topPrice,
                 TimeCurrent() + PeriodSeconds(PERIOD_CURRENT) * 100, fvgList[index].bottomPrice);
    
    color fvgColor = fvgList[index].isBullish ? FVG_Bullish_Color : FVG_Bearish_Color;
    ObjectSetInteger(0, name, OBJPROP_COLOR, fvgColor);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, (fvgList[index].strength > 2.0) ? 2 : 1);
    ObjectSetInteger(0, name, OBJPROP_FILL, true);
    ObjectSetInteger(0, name, OBJPROP_BACK, true);
    
    // Add strength label
    string labelName = name + "_Label";
    ObjectCreate(0, labelName, OBJ_TEXT, 0, fvgList[index].time, 
                 (fvgList[index].topPrice + fvgList[index].bottomPrice) / 2);
    ObjectSetString(0, labelName, OBJPROP_TEXT, 
                   StringFormat("FVG %.1f", fvgList[index].strength));
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, fvgColor);
}

//+------------------------------------------------------------------+
//| Check FVG Fill Status                                           |
//+------------------------------------------------------------------+
void CheckFVGFillStatus()
{
    double currentPrice = (iHigh(_Symbol, PERIOD_CURRENT, 0) + iLow(_Symbol, PERIOD_CURRENT, 0)) / 2;
    
    for(int i = 0; i < fvgCount; i++)
    {
        if(!fvgList[i].isValid || fvgList[i].isFilled) continue;
        
        bool isFilled = false;
        
        if(fvgList[i].isBullish)
        {
            // Bullish FVG is filled when price moves above the top
            if(currentPrice > fvgList[i].topPrice)
                isFilled = true;
        }
        else
        {
            // Bearish FVG is filled when price moves below the bottom
            if(currentPrice < fvgList[i].bottomPrice)
                isFilled = true;
        }
        
        if(isFilled)
        {
            fvgList[i].isFilled = true;
            string objName = "FVG_" + IntegerToString(i) + "_" + TimeToString(fvgList[i].time);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
        }
    }
}

//+------------------------------------------------------------------+
//| Enhanced Order Block Detection                                   |
//+------------------------------------------------------------------+
void DetectEnhancedOrderBlock()
{
    double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 1000 * _Point;
    
    for(int i = 10; i < OB_Lookback; i++)
    {
        double open = iOpen(_Symbol, PERIOD_CURRENT, i);
        double close = iClose(_Symbol, PERIOD_CURRENT, i);
        double high = iHigh(_Symbol, PERIOD_CURRENT, i);
        double low = iLow(_Symbol, PERIOD_CURRENT, i);
        double range = high - low;
        double volume = (ArraySize(volumeBuffer) > i) ? volumeBuffer[i] : 0;
        
        // Calculate average volume
        double avgVolume = 0;
        int volCount = 0;
        for(int j = i + 1; j < i + 21 && j < ArraySize(volumeBuffer); j++)
        {
            avgVolume += volumeBuffer[j];
            volCount++;
        }
        avgVolume = (volCount > 0) ? avgVolume / volCount : 1;
        
        // Enhanced Bullish Order Block Detection
        if(close < open && range > atr * 0.5) // Red candle with significant range
        {
            bool strongFollowThrough = false;
            double maxMove = 0;
            
            for(int j = 1; j <= 5; j++)
            {
                if(i - j < 0) break;
                double moveSize = iClose(_Symbol, PERIOD_CURRENT, i-j) - low;
                if(moveSize > maxMove) maxMove = moveSize;
                
                if(moveSize > atr * OB_MinStrength)
                {
                    strongFollowThrough = true;
                    break;
                }
            }
            
            if(strongFollowThrough && volume > avgVolume * OB_MinVolume)
            {
                double strength = maxMove / atr;
                AddEnhancedOrderBlock(iTime(_Symbol, PERIOD_CURRENT, i), high, low, 
                                    true, strength, volume / avgVolume);
            }
        }
        
        // Enhanced Bearish Order Block Detection
        if(close > open && range > atr * 0.5) // Green candle with significant range
        {
            bool strongFollowThrough = false;
            double maxMove = 0;
            
            for(int j = 1; j <= 5; j++)
            {
                if(i - j < 0) break;
                double moveSize = high - iClose(_Symbol, PERIOD_CURRENT, i-j);
                if(moveSize > maxMove) maxMove = moveSize;
                
                if(moveSize > atr * OB_MinStrength)
                {
                    strongFollowThrough = true;
                    break;
                }
            }
            
            if(strongFollowThrough && volume > avgVolume * OB_MinVolume)
            {
                double strength = maxMove / atr;
                AddEnhancedOrderBlock(iTime(_Symbol, PERIOD_CURRENT, i), high, low, 
                                    false, strength, volume / avgVolume);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Add Enhanced Order Block                                         |
//+------------------------------------------------------------------+
void AddEnhancedOrderBlock(datetime time, double top, double bottom, bool isBullish, 
                          double strength, double volumeRatio)
{
    // Check if Order Block already exists
    for(int i = 0; i < obCount; i++)
    {
        if(obList[i].time == time)
            return;
    }
    
    if(obCount >= ArraySize(obList))
        ArrayResize(obList, obCount + 50);
    
    obList[obCount].time = time;
    obList[obCount].topPrice = top;
    obList[obCount].bottomPrice = bottom;
    obList[obCount].isBullish = isBullish;
    obList[obCount].isValid = true;
    obList[obCount].strength = strength;
    obList[obCount].volume = volumeRatio;
    obList[obCount].touches = 0;
    
    DrawEnhancedOrderBlock(obCount);
    obCount++;
    
    Print("🏗️ Enhanced Order Block: ", (isBullish ? "Bullish" : "Bearish"), 
          " | Strength: ", DoubleToString(strength, 2), " | Volume: ", DoubleToString(volumeRatio, 2));
}

//+------------------------------------------------------------------+
//| Draw Enhanced Order Block                                        |
//+------------------------------------------------------------------+
void DrawEnhancedOrderBlock(int index)
{
    string name = "OB_" + IntegerToString(index) + "_" + TimeToString(obList[index].time);
    
    ObjectCreate(0, name, OBJ_RECTANGLE, 0,
                 obList[index].time, obList[index].topPrice,
                 TimeCurrent() + PeriodSeconds(PERIOD_CURRENT) * 150, obList[index].bottomPrice);
    
    color obColor = obList[index].isBullish ? OB_Bullish_Color : OB_Bearish_Color;
    ObjectSetInteger(0, name, OBJPROP_COLOR, obColor);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, (obList[index].strength > 3.0) ? 3 : 2);
    ObjectSetInteger(0, name, OBJPROP_FILL, false);
    ObjectSetInteger(0, name, OBJPROP_BACK, true);
    
    // Add strength and volume label
    string labelName = name + "_Label";
    ObjectCreate(0, labelName, OBJ_TEXT, 0, obList[index].time, obList[index].topPrice);
    ObjectSetString(0, labelName, OBJPROP_TEXT, 
                   StringFormat("OB S:%.1f V:%.1f", obList[index].strength, obList[index].volume));
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, obColor);
}

//+------------------------------------------------------------------+
//| Enhanced BOS Detection                                           |
//+------------------------------------------------------------------+
void DetectEnhancedBOS()
{
    double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 1000 * _Point;
    double minBreakSize = atr * BOS_MinStrength;
    
    // Find significant swing highs and lows
    for(int i = BOS_Lookback; i < BOS_Lookback * 2; i++)
    {
        bool isSwingHigh = true;
        bool isSwingLow = true;
        double high = iHigh(_Symbol, PERIOD_CURRENT, i);
        double low = iLow(_Symbol, PERIOD_CURRENT, i);
        
        // Check if it's a swing point
        for(int j = i - BOS_Lookback/2; j <= i + BOS_Lookback/2; j++)
        {
            if(j == i || j < 0) continue;
            
            if(iHigh(_Symbol, PERIOD_CURRENT, j) > high)
                isSwingHigh = false;
            if(iLow(_Symbol, PERIOD_CURRENT, j) < low)
                isSwingLow = false;
        }
        
        // Check for breaks
        if(isSwingHigh)
        {
            // Check if recent price broke above this high
            for(int k = 1; k < i; k++)
            {
                if(iHigh(_Symbol, PERIOD_CURRENT, k) > high + minBreakSize)
                {
                    AddMarketStructure(iTime(_Symbol, PERIOD_CURRENT, i), high, true, true);
                    break;
                }
            }
        }
        
        if(isSwingLow)
        {
            // Check if recent price broke below this low
            for(int k = 1; k < i; k++)
            {
                if(iLow(_Symbol, PERIOD_CURRENT, k) < low - minBreakSize)
                {
                    AddMarketStructure(iTime(_Symbol, PERIOD_CURRENT, i), low, false, true);
                    break;
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Enhanced Liquidity Detection                                     |
//+------------------------------------------------------------------+
void DetectEnhancedLiquidity()
{
    // Clear old liquidity levels if too many
    if(liquidityCount > MaxLiquidityLevels)
    {
        // Remove oldest levels
        int toRemove = liquidityCount - MaxLiquidityLevels;
        for(int i = 0; i < liquidityCount - toRemove; i++)
            liquidityLevels[i] = liquidityLevels[i + toRemove];
        liquidityCount = MaxLiquidityLevels;
    }
    
    double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 1000 * _Point;
    
    for(int i = SwingLookback; i < SwingLookback * 2; i++)
    {
        bool isSwingHigh = true;
        bool isSwingLow = true;
        double highPrice = iHigh(_Symbol, PERIOD_CURRENT, i);
        double lowPrice = iLow(_Symbol, PERIOD_CURRENT, i);
        
        // Enhanced swing detection with volume confirmation
        int confirmations = 0;
        double avgVolume = 0;
        
        for(int j = i - SwingLookback; j <= i + SwingLookback; j++)
        {
            if(j == i || j < 0) continue;
            
            if(iHigh(_Symbol, PERIOD_CURRENT, j) > highPrice)
                isSwingHigh = false;
            if(iLow(_Symbol, PERIOD_CURRENT, j) < lowPrice)
                isSwingLow = false;
                
            if(ArraySize(volumeBuffer) > j)
                avgVolume += volumeBuffer[j];
        }
        
        avgVolume /= (SwingLookback * 2);
        double currentVolume = (ArraySize(volumeBuffer) > i) ? volumeBuffer[i] : avgVolume;
        double volumeStrength = (avgVolume > 0) ? currentVolume / avgVolume : 1.0;
        
        if(isSwingHigh && volumeStrength > LiquidityStrength)
        {
            AddEnhancedLiquidityLevel(highPrice, iTime(_Symbol, PERIOD_CURRENT, i), 
                                    true, volumeStrength);
        }
        
        if(isSwingLow && volumeStrength > LiquidityStrength)
        {
            AddEnhancedLiquidityLevel(lowPrice, iTime(_Symbol, PERIOD_CURRENT, i), 
                                    false, volumeStrength);
        }
    }
    
    CheckEnhancedLiquiditySweep();
}

//+------------------------------------------------------------------+
//| Add Enhanced Liquidity Level                                     |
//+------------------------------------------------------------------+
void AddEnhancedLiquidityLevel(double price, datetime time, bool isHigh, double strength)
{
    // Check if level already exists nearby
    for(int i = 0; i < liquidityCount; i++)
    {
        if(MathAbs(liquidityLevels[i].price - price) < 50 * _Point)
            return; // Too close to existing level
    }
    
    if(liquidityCount >= ArraySize(liquidityLevels))
        ArrayResize(liquidityLevels, liquidityCount + 20);
    
    liquidityLevels[liquidityCount].price = price;
    liquidityLevels[liquidityCount].time = time;
    liquidityLevels[liquidityCount].isHigh = isHigh;
    liquidityLevels[liquidityCount].isSwept = false;
    liquidityLevels[liquidityCount].strength = strength;
    liquidityLevels[liquidityCount].confirmations = 1;
    
    if(DrawLiquidityLevels)
        DrawEnhancedLiquidity(liquidityCount);
    
    liquidityCount++;
}

//+------------------------------------------------------------------+
//| Draw Enhanced Liquidity                                          |
//+------------------------------------------------------------------+
void DrawEnhancedLiquidity(int index)
{
    string name = "LIQ_" + IntegerToString(index) + "_" + TimeToString(liquidityLevels[index].time);
    
    ObjectCreate(0, name, OBJ_HLINE, 0, 0, liquidityLevels[index].price);
    
    color liquColor = liquidityLevels[index].isHigh ? clrRed : clrLime;
    ObjectSetInteger(0, name, OBJPROP_COLOR, liquColor);
    ObjectSetInteger(0, name, OBJPROP_STYLE, liquidityLevels[index].isSwept ? STYLE_SOLID : STYLE_DOT);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, (liquidityLevels[index].strength > 2.0) ? 2 : 1);
    
    // Add strength label
    string labelName = name + "_Label";
    ObjectCreate(0, labelName, OBJ_TEXT, 0, TimeCurrent(), liquidityLevels[index].price);
    ObjectSetString(0, labelName, OBJPROP_TEXT, 
                   StringFormat("LIQ %.1f", liquidityLevels[index].strength));
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, liquColor);
    ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT);
}

//+------------------------------------------------------------------+
//| Check Enhanced Liquidity Sweep                                   |
//+------------------------------------------------------------------+
void CheckEnhancedLiquiditySweep()
{
    double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, 1);
    double currentLow = iLow(_Symbol, PERIOD_CURRENT, 1);
    double tolerance = SweepTolerance * _Point;
    
    for(int i = 0; i < liquidityCount; i++)
    {
        if(liquidityLevels[i].isSwept) continue;
        
        bool wasSwept = false;
        
        if(liquidityLevels[i].isHigh)
        {
            if(currentHigh >= liquidityLevels[i].price - tolerance && 
               currentHigh <= liquidityLevels[i].price + tolerance)
            {
                wasSwept = true;
            }
        }
        else
        {
            if(currentLow <= liquidityLevels[i].price + tolerance && 
               currentLow >= liquidityLevels[i].price - tolerance)
            {
                wasSwept = true;
            }
        }
        
        if(wasSwept)
        {
            liquidityLevels[i].isSwept = true;
            string objName = "LIQ_" + IntegerToString(i) + "_" + TimeToString(liquidityLevels[i].time);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 3);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
            
            Print("💧 Liquidity Swept: ", (liquidityLevels[i].isHigh ? "High" : "Low"), 
                  " at ", DoubleToString(liquidityLevels[i].price, _Digits), 
                  " | Strength: ", DoubleToString(liquidityLevels[i].strength, 2));
        }
    }
}

//+------------------------------------------------------------------+
//| Market Structure Detection                                        |
//+------------------------------------------------------------------+
void DetectMarketStructure()
{
    double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 1000 * _Point;
    double minBreak = atr * MS_MinBreak;
    
    for(int i = 5; i < MS_LookbackPeriod; i++)
    {
        double high = iHigh(_Symbol, PERIOD_CURRENT, i);
        double low = iLow(_Symbol, PERIOD_CURRENT, i);
        
        // Check for significant highs and lows
        bool isSignificantHigh = true;
        bool isSignificantLow = true;
        
        for(int j = i - 5; j <= i + 5; j++)
        {
            if(j == i || j < 0) continue;
            
            if(iHigh(_Symbol, PERIOD_CURRENT, j) > high)
                isSignificantHigh = false;
            if(iLow(_Symbol, PERIOD_CURRENT, j) < low)
                isSignificantLow = false;
        }
        
        if(isSignificantHigh)
        {
            double strength = 0;
            for(int k = 1; k < i; k++)
            {
                if(iHigh(_Symbol, PERIOD_CURRENT, k) > high + minBreak)
                {
                    strength = (iHigh(_Symbol, PERIOD_CURRENT, k) - high) / atr;
                    AddMarketStructure(iTime(_Symbol, PERIOD_CURRENT, i), high, true, true);
                    break;
                }
            }
        }
        
        if(isSignificantLow)
        {
            double strength = 0;
            for(int k = 1; k < i; k++)
            {
                if(iLow(_Symbol, PERIOD_CURRENT, k) < low - minBreak)
                {
                    strength = (low - iLow(_Symbol, PERIOD_CURRENT, k)) / atr;
                    AddMarketStructure(iTime(_Symbol, PERIOD_CURRENT, i), low, false, true);
                    break;
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Add Market Structure                                             |
//+------------------------------------------------------------------+
void AddMarketStructure(datetime time, double price, bool isHigh, bool isBroken)
{
    if(msCount >= ArraySize(msLevels))
        ArrayResize(msLevels, msCount + 50);
    
    msLevels[msCount].time = time;
    msLevels[msCount].price = price;
    msLevels[msCount].isHigh = isHigh;
    msLevels[msCount].isBroken = isBroken;
    msLevels[msCount].strength = 1.0;
    
    msCount++;
}

//+------------------------------------------------------------------+
//| Send Enhanced Alert                                              |
//+------------------------------------------------------------------+
void SendAlert(string message)
{
    if(!EnableAlerts) return;
    
    string fullMessage = StringFormat("[GOLD SMC V3] %s - %s | %s", 
                                     _Symbol, 
                                     TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES),
                                     message);
    
    // Terminal Alert
    Alert(fullMessage);
    
    // Console log with emoji
    Print("🔔 ", fullMessage);
    
    // Push Notification for Exness mobile app
    if(EnablePushNotification)
    {
        string pushMsg = StringFormat("GOLD SMC: %s", message);
        SendNotification(pushMsg);
    }
    
    // Email Alert
    if(EnableEmailAlert)
    {
        string emailSubject = "Gold SMC EA V3 - " + _Symbol + " Alert";
        string emailBody = fullMessage + "\n\n";
        emailBody += "Account: " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\n";
        emailBody += "Balance: $" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "\n";
        emailBody += "Equity: $" + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2);
        
        SendMail(emailSubject, emailBody);
    }
}

//+------------------------------------------------------------------+
//| Exness Cent Account Optimization                                 |
//+------------------------------------------------------------------+
double OptimizeForCentAccount(double lotSize)
{
    // Exness Cent account has different lot sizes
    // 1 lot in cent account = 0.01 lot in standard account
    
    string accountServer = AccountInfoString(ACCOUNT_SERVER);
    
    // Check if it's a cent account (usually contains "cent" in server name)
    if(StringFind(accountServer, "cent", 0) >= 0 || 
       StringFind(accountServer, "Cent", 0) >= 0)
    {
        // For cent accounts, we can use larger lot sizes
        lotSize *= 100;
        
        // But still respect broker limits
        double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
        double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        
        lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
        
        Print("💰 Cent Account Detected - Adjusted Lot Size: ", DoubleToString(lotSize, 2));
    }
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Gold Specific Settings for Exness                               |
//+------------------------------------------------------------------+
void OptimizeForGoldTrading()
{
    // Gold specific optimizations for Exness
    string symbol = _Symbol;
    
    if(StringFind(symbol, "GOLD", 0) >= 0 || StringFind(symbol, "XAU", 0) >= 0)
    {
        // Gold typically has higher spreads during certain hours
        // Adjust trading parameters accordingly
        
        MqlDateTime tm;
        TimeToStruct(TimeCurrent(), tm);
        
        // During high spread periods (typically between sessions)
        if((tm.hour >= 23 || tm.hour <= 1) || (tm.hour >= 11 && tm.hour <= 13))
        {
            // Increase minimum profit requirements
            Print("⚠️ High spread period detected for Gold - Adjusting parameters");
        }
    }
}

//+------------------------------------------------------------------+
//| Enhanced IsTradeAllowed for Exness conditions                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
{
    // Basic time and day checks
    MqlDateTime tm;
    TimeToStruct(TimeCurrent(), tm);
    
    // Day filter
    bool dayAllowed = false;
    switch(tm.day_of_week)
    {
        case 1: dayAllowed = TradeOnMonday; break;
        case 2: dayAllowed = TradeOnTuesday; break;
        case 3: dayAllowed = TradeOnWednesday; break;
        case 4: dayAllowed = TradeOnThursday; break;
        case 5: dayAllowed = TradeOnFriday; break;
        case 0: case 6: dayAllowed = false; break; // Weekend
    }
    
    // Session filter
    bool sessionAllowed = true;
    if(UseSessionFilter)
        sessionAllowed = IsGoodTradingSession();
    
    // Check account conditions
    double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    double minMargin = 100; // Minimum $1 for cent account
    bool marginOK = freeMargin >= minMargin;
    
    // Check spread conditions (important for Gold on Exness)
    double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
    double maxSpread = 50 * _Point; // Max 5 points spread for Gold
    bool spreadOK = spread <= maxSpread;
    
    // News filter
    bool newsOK = true;
    if(AvoidMajorNews)
        newsOK = !IsNewsTime();
    
    // Connection check
    bool connectionOK = TerminalInfoInteger(TERMINAL_CONNECTED) && 
                       TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
    
    if(!dayAllowed)
        Print("❌ Trading not allowed today");
    if(!sessionAllowed)
        Print("❌ Outside trading session");
    if(!marginOK)
        Print("❌ Insufficient margin: ", freeMargin);
    if(!spreadOK)
        Print("❌ Spread too high: ", spread/_Point, " points");
    if(!newsOK)
        Print("❌ News time - trading paused");
    if(!connectionOK)
        Print("❌ Connection or trading issues");
    
    return dayAllowed && sessionAllowed && marginOK && spreadOK && newsOK && connectionOK;
}

//+------------------------------------------------------------------+
//| Enhanced OnDeinit                                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Release indicators
    if(obvHandle != INVALID_HANDLE) IndicatorRelease(obvHandle);
    if(atrHandle != INVALID_HANDLE) IndicatorRelease(atrHandle);
    if(volumeHandle != INVALID_HANDLE) IndicatorRelease(volumeHandle);
    if(rsiHandle != INVALID_HANDLE) IndicatorRelease(rsiHandle);
    
    // Clean up objects
    ObjectsDeleteAll(0, "FVG_");
    ObjectsDeleteAll(0, "OB_");
    ObjectsDeleteAll(0, "LIQ_");
    ObjectsDeleteAll(0, "BOS_");
    ObjectsDeleteAll(0, "DASH_");
    ObjectsDeleteAll(0, "MS_");
    
    // Print final statistics
    Print("═══════════════════════════════════════");
    Print("Gold SMC EA Pro V3 Terminated");
    Print("Reason: ", GetUninitReasonText(reason));
    Print("Total Trades: ", stats.totalTrades);
    if(stats.totalTrades > 0)
    {
        double winRate = stats.winningTrades * 100.0 / stats.totalTrades;
        Print("Win Rate: ", DoubleToString(winRate, 1), "%");
        Print("Profit Factor: ", DoubleToString(stats.profitFactor, 2));
        Print("Max Drawdown: ", DoubleToString(stats.maxDrawdown, 2), "%");
    }
    Print("═══════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| Create Label for Dashboard                                       |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, int fontSize, color clr)
{
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetString(0, name, OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
}

//+------------------------------------------------------------------+
//| Count Open Positions by Type                                     |
//+------------------------------------------------------------------+
int CountOpenPositions(ENUM_POSITION_TYPE posType)
{
    int count = 0;
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionSelectByTicket(PositionGetTicket(i)))
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
               PositionGetInteger(POSITION_TYPE) == posType)
            {
                count++;
            }
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Check for New Bar                                                |
//+------------------------------------------------------------------+
bool IsNewBar()
{
    datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    if(currentBarTime != lastBarTime)
    {
        lastBarTime = currentBarTime;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Cleanup Old Data                                                 |
//+------------------------------------------------------------------+
void CleanupOldData()
{
    datetime oldTime = TimeCurrent() - PeriodSeconds(PERIOD_CURRENT) * 500;
    
    // Cleanup old FVG
    for(int i = 0; i < fvgCount; i++)
    {
        if(fvgList[i].time < oldTime && fvgList[i].isFilled)
        {
            fvgList[i].isValid = false;
            string objName = "FVG_" + IntegerToString(i) + "_" + TimeToString(fvgList[i].time);
            ObjectDelete(0, objName);
            ObjectDelete(0, objName + "_Label");
        }
    }
    
    // Cleanup old Order Blocks
    for(int i = 0; i < obCount; i++)
    {
        if(obList[i].time < oldTime)
        {
            obList[i].isValid = false;
            string objName = "OB_" + IntegerToString(i) + "_" + TimeToString(obList[i].time);
            ObjectDelete(0, objName);
            ObjectDelete(0, objName + "_Label");
        }
    }
    
    // Cleanup old Liquidity Levels
    for(int i = 0; i < liquidityCount; i++)
    {
        if(liquidityLevels[i].time < oldTime && liquidityLevels[i].isSwept)
        {
            string objName = "LIQ_" + IntegerToString(i) + "_" + TimeToString(liquidityLevels[i].time);
            ObjectDelete(0, objName);
            ObjectDelete(0, objName + "_Label");
        }
    }
}

//+------------------------------------------------------------------+
//| Get Uninitialize Reason Text                                     |
//+------------------------------------------------------------------+
string GetUninitReasonText(int reason)
{
    switch(reason)
    {
        case REASON_ACCOUNT: return "Account changed";
        case REASON_CHARTCHANGE: return "Chart changed";
        case REASON_CHARTCLOSE: return "Chart closed";
        case REASON_PARAMETERS: return "Parameters changed";
        case REASON_RECOMPILE: return "EA recompiled";
        case REASON_REMOVE: return "EA removed";
        case REASON_TEMPLATE: return "Template changed";
        default: return "Unknown reason";
    }
}
//+------------------------------------------------------------------+