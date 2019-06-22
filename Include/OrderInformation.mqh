//+------------------------------------------------------------------+
//|                                      OrderInformationManager.mqh |
//|                                                            jordi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "jordi"
#property link      ""
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderInformation
  {
private:
   int ticket;
   int type;
   double openPrice;
   double stopLossPrice;
   double takeProfitPrice;
   double lots;
   double partialStopLossPrice;
   double partialTakeProfitPrice;
   double partialStopLossBreakEvenPrice;
   double stopLossBreakEvenPrice;
   bool reachedPartialStopLoss;
   bool reachedPartialTakeProfit;
   bool partialOnBreakEven;
   bool stopLossOnBreakEven;
public:
                     OrderInformation(int t, double sl, double tp, double l, int ty, double psl, double ptp, double pslbe, double slbe);
                    ~OrderInformation();
   virtual bool priceReachedPartialStopLoss(double price);
   virtual bool priceReachedPartialTakeProfit(double price);
   virtual bool priceReachedPartialOnBreakEven(double price);
   virtual bool priceReachedStopLossOnBreakEven(double price);
   double getPartialStopLossPrice() {return partialStopLossPrice;}
   double getPartialTakeProfitPrice() {return partialTakeProfitPrice;}
   double getPartialStopLossBreakEvenPrice() {return partialStopLossBreakEvenPrice;}
   double getStopLossBreakEvenPrice() {return stopLossBreakEvenPrice;}
  };

OrderInformation::OrderInformation(int t, double sl, double tp, double l, int ty, double psl, double ptp, double pslbe, double slbe)
{
   ticket = t;
   stopLossPrice = sl;
   takeProfitPrice = tp;
   lots = l;
   type = ty;
   partialStopLossPrice = psl;
   partialTakeProfitPrice = ptp;
   partialStopLossBreakEvenPrice = pslbe;
   stopLossBreakEvenPrice = slbe;
}

bool OrderInformation::priceReachedPartialStopLoss(double price)
{
   if (type == OP_BUY) {
      reachedPartialStopLoss = price <= partialStopLossPrice;
   } else if (type == OP_SELL) {
      reachedPartialStopLoss = price >= partialStopLossPrice;
   }
   
   return reachedPartialStopLoss;
}

bool OrderInformation::priceReachedPartialTakeProfit(double price)
{
   if (type == OP_BUY) {
      reachedPartialTakeProfit = price >= partialTakeProfitPrice;
   } else if (type == OP_SELL) {
      reachedPartialTakeProfit = price <= partialTakeProfitPrice;
   }
   
   return reachedPartialTakeProfit;
}

bool OrderInformation::priceReachedPartialOnBreakEven(double price)
{
   if (type == OP_BUY) {
      partialOnBreakEven = price >= partialStopLossBreakEvenPrice;
   } else if (type == OP_SELL) {
      partialOnBreakEven = price <= partialStopLossBreakEvenPrice;
   }
   
   return partialOnBreakEven;
}

bool OrderInformation::priceReachedStopLossOnBreakEven(double price)
{
   if (type == OP_BUY) {
      stopLossOnBreakEven = price >= stopLossBreakEvenPrice;
   } else if (type == OP_SELL) {
      stopLossOnBreakEven = price <= stopLossBreakEvenPrice;
   }
   
   return stopLossOnBreakEven;
}