#property copyright "jordi"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <OrderInformation.mqh>

class OrderExecutionHelper
  {
private:
   bool floorProtection;
   int slippage;
   int magicNumber;
   virtual double getHalfLots(double _lots);
public:
                     OrderExecutionHelper(bool fp = true, int s = 3, int mn = 123): floorProtection(fp), slippage(s), magicNumber(mn){};
                    ~OrderExecutionHelper(){};
   virtual int sell(string symbol, double lots, double sl, double tp, string comment, color arrowColor = clrBlue);
   virtual int buy(string symbol, double lots, double sl, double tp, string comment, color arrowColor = clrBlue);
   virtual bool closeHalfOrder(OrderInformation &order, color arrowColor);
   virtual bool putStopOnBreakEven(OrderInformation &order);
  };
  
double OrderExecutionHelper::getHalfLots(double _lots)
{
   return _lots/2;
}

int OrderExecutionHelper::sell(string symbol, double _lots, double sl, double tp, string _comment, color arrowColor = clrBlue)
{
   return OrderSend(symbol, OP_SELL, _lots, Bid, slippage, sl, tp, _comment, magicNumber, 0, arrowColor);
}

int OrderExecutionHelper::buy(string symbol, double _lots, double sl, double tp, string _comment, color arrowColor = clrBlue)
{
   return OrderSend(symbol, OP_BUY, _lots, Ask, slippage, sl, tp, _comment, magicNumber, 0, arrowColor);
}

bool OrderExecutionHelper::closeHalfOrder(OrderInformation &order, color arrowColor)
{
   return OrderClose(order.getTicket(), getHalfLots(order.getLots()), order.getType() == OP_BUY ? Bid : Ask, slippage, arrowColor);
}

bool OrderExecutionHelper::putStopOnBreakEven(OrderInformation &order)
{
   return OrderModify(order.getTicket(), order.getOpenPrice(), order.getOpenPrice(), order.getTakeProfitPrice(), 0);
}