//+------------------------------------------------------------------+
//|                                         OrderExecutionHelper.mqh |
//|                                                            jordi |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "jordi"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <OrderInformation.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderExecutionHelper
  {
private:
   bool floorProtection;
   int slippage;
   int magicNumber;
   virtual double getHalfLots(double lots);
public:
                     OrderExecutionHelper(bool fp = true, int s = 3, int mn = 123): floorProtection(fp), slippage(s), magicNumber(mn){};
                    ~OrderExecutionHelper();
   virtual int buy(string symbol, int type, double lots, double sl, double tp, string comment);
   virtual int sell(string symbol, int type, double lots, double sl, double tp, string comment);
   virtual bool closeHalfOrder(OrderInformation &order);
   virtual bool putStopOnBreakEven(OrderInformation &order);
  };
  
double OrderExecutionHelper::getHalfLots(double lots)
{
   return lots/2;
}

int OrderExecutionHelper::sell(string symbol, int type, double lots, double sl, double tp, string comment)
{
   return OrderSend(symbol, type, lots, Bid, slippage, sl, tp, comment, magicNumber, 0, clrRed);
}

int OrderExecutionHelper::buy(string symbol, int type, double lots, double sl, double tp, string comment)
{
   return OrderSend(symbol, type, lots, Ask, slippage, sl, tp, comment, magicNumber, 0, clrBlue);
}

bool OrderExecutionHelper::closeHalfOrder(OrderInformation &order)
{
   return OrderClose(order.getTicket(), getHalfLots(order.getLots()), order.getType() == OP_BUY ? Bid : Ask, slippage);
}

bool OrderExecutionHelper::putStopOnBreakEven(OrderInformation &order)
{
   return OrderModify(order.getTicket(), order.getOpenPrice(), order.getOpenPrice(), order.getTakeProfitPrice(), 0);
}