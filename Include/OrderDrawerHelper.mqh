#property copyright "jordi"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <OrderInformation.mqh>

class OrderDrawerHelper
  {
private:
   string partialStopLossName;
   string partialTakeProfitName;
   string partialStopLossToBreakEvenName;
   string stopLossToBreakEvenName;
   virtual string getObjectName(int ticket, string name);
   virtual void drawPartialStopLoss(OrderInformation &order);
   virtual void drawPartialTakeProfit(OrderInformation &order);
   virtual void drawPartialStopLossToBreakEven(OrderInformation &order);
   virtual void drawStopLossToBreakEven(OrderInformation &order);
   string getPartialStopLossName(int ticket){return getObjectName(ticket, partialStopLossName);}
   string getPartialTakeProfitName(int ticket){return getObjectName(ticket, partialTakeProfitName);}
   string getPartialStopLossToBreakEvenName(int ticket){return getObjectName(ticket, partialStopLossToBreakEvenName);}
   string getStopLossToBreakEvenName(int ticket){return getObjectName(ticket, stopLossToBreakEvenName);}
public:
                     OrderDrawerHelper();
                    ~OrderDrawerHelper(){};
   virtual void clearLines(OrderInformation &order);
   virtual void drawLines(OrderInformation &order);
   virtual void removePartialStopLossLine(OrderInformation &order);
   virtual void removePartialStopLossBreakEvenLine(OrderInformation &order);
   virtual void removeStopLossBreakEvenLine(OrderInformation &order);
   virtual void removePartialTakeProfitLine(OrderInformation &order);
   virtual void drawPartialStopLossOnBreakEven(OrderInformation &order, float price);
   virtual void removePartialStopLossOnBreakEven(OrderInformation &order);
  };

OrderDrawerHelper::OrderDrawerHelper()
{
   partialStopLossName = "Partial Stop Loss";
   partialTakeProfitName = "Partial Take Profit";
   partialStopLossToBreakEvenName = "Partial Stop Loss to BreakEven";
   stopLossToBreakEvenName = "Stop Loss to BreakEven";
}

string OrderDrawerHelper::getObjectName(int ticket, string name)
{
   return name + "#" + IntegerToString(ticket);
}

OrderDrawerHelper::drawPartialStopLoss(OrderInformation &order)
{
   string name = this.getObjectName(order.getTicket(), partialStopLossName);
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, order.getPartialStopLossPrice());
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}

OrderDrawerHelper::drawPartialTakeProfit(OrderInformation &order)
{
   string name = this.getObjectName(order.getTicket(), partialTakeProfitName);
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, order.getPartialTakeProfitPrice());
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrOlive);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}

OrderDrawerHelper::drawPartialStopLossToBreakEven(OrderInformation &order)
{
   string name = this.getObjectName(order.getTicket(), partialStopLossToBreakEvenName);
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, order.getPartialStopLossBreakEvenPrice());
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
}

OrderDrawerHelper::drawStopLossToBreakEven(OrderInformation &order)
{
   string name = this.getObjectName(order.getTicket(), stopLossToBreakEvenName);
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, order.getStopLossBreakEvenPrice());
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
}

OrderDrawerHelper::clearLines(OrderInformation &order)
{
   ObjectDelete(0, this.getObjectName(order.getTicket(), partialStopLossName));
   ObjectDelete(0, this.getObjectName(order.getTicket(), partialTakeProfitName));
   ObjectDelete(0, this.getObjectName(order.getTicket(), partialStopLossToBreakEvenName));
   ObjectDelete(0, this.getObjectName(order.getTicket(), stopLossToBreakEvenName));
}

OrderDrawerHelper::drawLines(OrderInformation &order)
{
   this.drawPartialStopLoss(order);
   this.drawPartialTakeProfit(order);
   this.drawPartialStopLossToBreakEven(order);
   this.drawStopLossToBreakEven(order);
}

OrderDrawerHelper::removePartialStopLossLine(OrderInformation &order)
{
   ObjectDelete(0, this.getObjectName(order.getTicket(), partialStopLossName));
}

OrderDrawerHelper::removePartialStopLossBreakEvenLine(OrderInformation &order)
{
   ObjectDelete(0, this.getObjectName(order.getTicket(), partialStopLossToBreakEvenName));
}

OrderDrawerHelper::removeStopLossBreakEvenLine(OrderInformation &order)
{
   ObjectDelete(0, this.getObjectName(order.getTicket(), stopLossToBreakEvenName));
}

OrderDrawerHelper::removePartialTakeProfitLine(OrderInformation &order)
{
   ObjectDelete(0, this.getObjectName(order.getTicket(), partialTakeProfitName));
}

OrderDrawerHelper::drawPartialStopLossOnBreakEven(OrderInformation &order, float price)
{
   string name = this.getObjectName(order.getTicket(), partialStopLossName);
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}

OrderDrawerHelper::removePartialStopLossOnBreakEven(OrderInformation &order)
{
   ObjectDelete(0, this.getObjectName(order.getTicket(), partialStopLossName));
}