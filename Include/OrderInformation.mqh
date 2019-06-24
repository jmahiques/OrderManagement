//+------------------------------------------------------------------+
//|                                      OrderInformationManager.mqh |
//|                                                            jordi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "jordi"
#property link      ""
#property version   "1.00"
#property strict

#include <Object.mqh>

class OrderInformation: public CObject
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
                    ~OrderInformation(){};
   bool executedPartialStopLoss;
   bool executedPartialTakeProfit;
   bool executedPartialStopOnBreakEven;
   bool executedStopLossOnBreakEven;
   virtual bool priceReachedPartialStopLoss(double price);
   virtual bool priceReachedPartialTakeProfit(double price);
   virtual bool priceReachedPartialStopOnBreakEven(double price);
   virtual bool priceReachedStopLossOnBreakEven(double price);
   double getPartialStopLossPrice() {return partialStopLossPrice;}
   double getPartialTakeProfitPrice() {return partialTakeProfitPrice;}
   double getPartialStopLossBreakEvenPrice() {return partialStopLossBreakEvenPrice;}
   double getStopLossBreakEvenPrice() {return stopLossBreakEvenPrice;}
   int getTicket(){return ticket;}
   int getType(){return type;}
   double getOpenPrice(){return openPrice;}
   double getStopLossPrice(){return stopLossPrice;}
   double getTakeProfitPrice(){return takeProfitPrice;}
   double getLots(){return lots;}
   int Type(){return(1);}
   int Compare(const CObject *node,const int mode=0){
      if (this.ticket > ((OrderInformation*)node).getTicket()) {return(1);}
      if (this.ticket < ((OrderInformation*)node).getTicket()) {return(-1);}
      return(0);
   };
  };

OrderInformation::OrderInformation(int t, double sl, double tp, double l, int ty, double psl, double ptp, double pslbe, double slbe)
{
   this.ticket = t;
   this.stopLossPrice = sl;
   this.takeProfitPrice = tp;
   this.lots = l;
   this.type = ty;
   this.partialStopLossPrice = psl;
   this.partialTakeProfitPrice = ptp;
   this.partialStopLossBreakEvenPrice = pslbe;
   this.stopLossBreakEvenPrice = slbe;
   this.executedPartialStopLoss = false;
   this.executedPartialStopOnBreakEven = false;
   this.executedPartialTakeProfit = false;
   this.executedStopLossOnBreakEven = false;
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

bool OrderInformation::priceReachedPartialStopOnBreakEven(double price)
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