//+------------------------------------------------------------------+
//|                                                  LevelDrawer.mqh |
//|                                                            jordi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "jordi"
#property link      ""
#property version   "1.00"
#property strict

#include <OrderInformation.mqh>

class OrderLevelDrawer
{
   public:
      static void drawPartialStopLoss(OrderInformation &order);
      static void drawPartialTakeProfit(OrderInformation &order);
      static void removePartialStopLoss(OrderInformation &order);
      static void removePartialTakeProfit(OrderInformation &order);
      static void drawLevels(OrderInformation &order);
      static void removeLevels(OrderInformation &order);
      static void getPartialStopLossPrice(OrderInformation &order);
      static double getPriceLevel(string name);
      static bool isPriceLevel(string name);
      static int getTicket(string name);
      
      OrderLevelDrawer(){}
      ~OrderLevelDrawer(){}
};

static void OrderLevelDrawer::drawPartialStopLoss(OrderInformation &order)
{
   ObjectCreate(0, "STOP"+IntegerToString(order.getTicket()), OBJ_HLINE, 0, 0, order.getPartialStopLossPrice());
   ObjectSetInteger(0, "STOP"+IntegerToString(order.getTicket()), OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "STOP"+IntegerToString(order.getTicket()), OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "STOP"+IntegerToString(order.getTicket()), OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, "STOP"+IntegerToString(order.getTicket()), OBJPROP_SELECTED, true);
}

static void OrderLevelDrawer::drawPartialTakeProfit(OrderInformation &order)
{
   ObjectCreate(0, "PROFIT"+IntegerToString(order.getTicket()), OBJ_HLINE, 0, 0, order.getPartialTakeProfitPrice());
   ObjectSetInteger(0, "PROFIT"+IntegerToString(order.getTicket()), OBJPROP_COLOR, clrOlive);
   ObjectSetInteger(0, "PROFIT"+IntegerToString(order.getTicket()), OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "PROFIT"+IntegerToString(order.getTicket()), OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, "PROFIT"+IntegerToString(order.getTicket()), OBJPROP_SELECTED, true);
}

static void OrderLevelDrawer::removePartialStopLoss(OrderInformation &order)
{
   ObjectDelete(0, "STOP"+IntegerToString(order.getTicket()));
}

static void OrderLevelDrawer::removePartialTakeProfit(OrderInformation &order)
{
   ObjectDelete(0, "PROFIT"+IntegerToString(order.getTicket()));
}

static void OrderLevelDrawer::drawLevels(OrderInformation &order)
{
   OrderLevelDrawer::drawPartialStopLoss(order);
   OrderLevelDrawer::drawPartialTakeProfit(order);
}

static void OrderLevelDrawer::removeLevels(OrderInformation &order)
{
   OrderLevelDrawer::removePartialStopLoss(order);
   OrderLevelDrawer::removePartialTakeProfit(order);
}

static double OrderLevelDrawer::getPriceLevel(string name)
{
   return ObjectGetDouble(0, name, OBJPROP_PRICE);
}

static bool OrderLevelDrawer::isPriceLevel(string name)
{
   return StringFind(name, "PROFIT") >= 0 || StringFind(name, "STOP") >= 0;
}

static int OrderLevelDrawer::getTicket(string name)
{
   if (!OrderLevelDrawer::isPriceLevel(name)) {
      return -1;
   }

   return StringToInteger(StringSubstr(name, StringFind(name, "PROFIT") >= 0 ? 5 : 4));
}