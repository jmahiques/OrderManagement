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
   bool reachedPartialStopLoss;
   bool reachedPartialTakeProfit;
public:
                     OrderInformation(double p, int t, double sl, double tp, double l, int ty, double psl, double ptp);
                    ~OrderInformation(){};
   bool executedPartialStopLoss;
   bool executedPartialTakeProfit;
   virtual bool priceReachedPartialStopLoss(double price);
   virtual bool priceReachedPartialTakeProfit(double price);
   double getPartialStopLossPrice() {return partialStopLossPrice;}
   void setPartialStopLoss(double price){this.partialStopLossPrice = price;}
   double getPartialTakeProfitPrice() {return partialTakeProfitPrice;}
   void setPartialTakeProfit(double price){this.partialTakeProfitPrice = price;}
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
   void updateInfoAfterCloseHalf(double lots, double openPrice, int ticket){
      this.lots = lots;
      this.openPrice = openPrice;
      this.ticket = ticket;
   };
  };

OrderInformation::OrderInformation(double p, int t, double sl, double tp, double l, int ty, double psl, double ptp)
{
   this.openPrice = p;
   this.ticket = t;
   this.stopLossPrice = sl;
   this.takeProfitPrice = tp;
   this.lots = l;
   this.type = ty;
   this.partialStopLossPrice = psl;
   this.partialTakeProfitPrice = ptp;
   this.executedPartialStopLoss = false;
   this.executedPartialTakeProfit = false;
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