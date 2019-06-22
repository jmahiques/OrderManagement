//+------------------------------------------------------------------+
//|                                                 OrderKeyOpen.mq4 |
//|                                                            jordi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "jordi"
#property link      ""
#property version   "1.00"
#property strict

#include <UserInterfaceManager.mqh>

const string partialStopLossLineName = "Partial stop loss";
const string partialStopLossToBELineName = "Partial stop loss to BE";
const string stopLossToBELineName = "Stop loss to BE";
const string partialTakeProfitLineName = "Partial Take Profit";
UserInterfaceManager UIManager = new UserInterfaceManager();

input int stop = 10;
input int partialStopLoss = 8;
input int partialTakeProfit = 40;
input int takeProfit = 80;
input int _digits = 4;
input int partialStopLossToBreakEven = 20;
input int stopLossToBreakEven = 30;
input double lots = 0.02;
input double halfLots = 0.01;
input int magicNumber = 1;
input string comment = "Probando ratios";
input int slippage = 3;
input bool retrievePreviouslyOrders = false;

struct OrderInformation
{
   bool reachedPartialStopLoss;
   bool reachedPartialStopLossBE;
   bool reachedStopLossBE;
   bool reachedPartialTakeProfit;
   int ticket;
};

OrderInformation orders[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   UIManager.drawUI();
   if (retrievePreviouslyOrders) {
      setupOrdersPreviouslyOpened();
   }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   for(int i = 0; i < ArraySize(orders); i++) {
      OrderInformation info = orders[i];
      if (!OrderSelect(info.ticket, SELECT_BY_TICKET)){
         Print("Cannot select the order ", GetLastError());
         continue;
      }
      
      //The order reached the stop loss, pop it from the orders array
      if (OrderCloseTime() != 0) {
         Print("The order has been closed due to stop loss");
         orderReachedStopRemoveItFromOrders(info.ticket, i);
         return;
      }
      
      //Price touch partial stop loss
      if (!info.reachedPartialStopLoss && priceReachedPartialStopLoss() && OrderLots() >= lots) {
         closeHalfOrder();
         info.reachedPartialStopLoss = true;
         Print("Price reached Partial Stop Loss");
         continue;
      }
      
      //Price touches the line to put the partial stop loss to breakeven
      if (!info.reachedPartialStopLossBE && priceReachedPartialStopLossToBe()) {
         info.reachedPartialStopLossBE = true;
         Print("Price reached Partial Stop Loss BE line");
         continue;
      }
      
      //Price touches the line to put the stop loss to breakeven
      if (!info.reachedStopLossBE && priceReachedStopLossToBe()) {
         info.reachedStopLossBE = true;
         putStopOnBreakEven();
         Print("Price reached Stop Loss BE line");
         continue;
      }
      
      //Price reaches partial take profit
      if (!info.reachedPartialTakeProfit && priceReachedPartialTakeProfit() && OrderLots() >= lots) {
         info.reachedPartialTakeProfit = true;
         closeHalfOrder();
         Print("Price reached Partial Take Profit");
         continue;
      }
      
      //Price reached the line to put the partial stop loss to breakeven and return to the open price
      if (info.reachedPartialStopLossBE && OrderType() == OP_BUY && Bid < OrderOpenPrice() && OrderLots() >= lots) {
         closeHalfOrder();
         Print("Close the half of the position, the price reached the order price entry");
      } else if(info.reachedPartialStopLossBE && OrderType() == OP_SELL && Ask > OrderOpenPrice() && OrderLots() >= lots) {
         closeHalfOrder();
         Print("Close the half of the position, the price reached the order price entry");
      }
   }
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (UIManager.isSellButtonClicked(id, sparam)) {
      Print("Button sell clicked.");
      clickButtonSell();
   } else if (UIManager.isBuyButtonClicked(id, sparam)) {
      Print("Button buy clicked.");
      clickButtonBuy();
   } else if (UIManager.isMinimizeButtonClicked(id, sparam)) {
      Print("Button toggle ui clicked");
   } else if (UIManager.isClearButtonClicked(id, sparam)) {
      clickButtonClearAll();
      Print("Button clear clicked");
   }
}

//Market functions
int sell()
{
   return OrderSend(Symbol(), OP_SELL, lots, Bid, slippage, getStopLoss(OP_SELL), getTakeProfit(OP_SELL), comment, magicNumber, 0, clrRed);
}

int buy()
{
   return OrderSend(Symbol(), OP_BUY, lots, Ask, slippage, getStopLoss(OP_BUY), getTakeProfit(OP_BUY), comment, magicNumber, 0, clrBlue);
}

void closeHalfOrder()
{
   if (OrderClose(OrderTicket(), halfLots, OrderType() == OP_BUY ? Bid : Ask, slippage)) {
      Print("Closed the half of the order. Reached partial stop loss.");
   } else {
      Print("Error closing the half of the order. ", GetLastError());
   }
}

void putStopOnBreakEven()
{
   if (OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0)) {
      Print("Modified ",OrderTicket()," stop to Breakeven");
   } else {
      Print("Cannot modify order stop to Breakeven ",GetLastError());
   }
}

//Utility functions
double getTakeProfit(int cmd)
{
   double price = 0.00;
   if (cmd == OP_BUY) {
      price = NormalizeDouble(Bid+takeProfit/MathPow(10, _digits),_digits);
   } else if(cmd == OP_SELL) {
      price = NormalizeDouble(Ask-takeProfit/MathPow(10, _digits),_digits);
   }
   Print("Take Profit price: ", DoubleToStr(price));
   return price;
}

double getStopLoss(int cmd)
{
   double price = 0.00;
   if (cmd == OP_BUY) {
      price = NormalizeDouble(Bid-(stop/MathPow(10, _digits)),_digits);
   } else if(cmd == OP_SELL) {
      price = NormalizeDouble(Ask+(stop/MathPow(10, _digits)),_digits);
   }
   Print("Stop Loss price: ", DoubleToStr(price));
   return price;
}

double getPartialStopLossPrice(int cmd)
{
   if (cmd == OP_BUY) {
      return NormalizeDouble(OrderOpenPrice()-partialStopLoss/MathPow(10, _digits),_digits);
   } else if(cmd == OP_SELL) {
      return NormalizeDouble(OrderOpenPrice()+partialStopLoss/MathPow(10, _digits),_digits);
   }
   return 0.00;
}

double getLineToBreakEvenPrice(int cmd, int pips)
{
   if (cmd == OP_BUY) {
      return NormalizeDouble(OrderOpenPrice()+pips/MathPow(10, _digits),_digits);
   } else if(cmd == OP_SELL) {
      return NormalizeDouble(OrderOpenPrice()-pips/MathPow(10, _digits),_digits);
   }
   return 0.00;
}

void createOrderInfo(int ticket)
{
   OrderInformation info = {false, false, false, false};
   info.ticket = ticket;
   
   ArrayResize(orders, ArraySize(orders)+1);
   orders[ArraySize(orders)-1] = info;
}

void orderReachedStopRemoveItFromOrders(int ticket, int index)
{
   Print("Removing order from index ", index);
   removeIndexFromOrderInformationArray(index);
   Print("Order ", ticket, " removed, because the price reached the stop. Órdenes abiertas: ", IntegerToString(ArraySize(orders)));
}

void removeIndexFromOrderInformationArray(int index)
{
   OrderInformation tempArray[];
   //Lets copy index 0-4 as the input index is to remove index 5
   ArrayCopy(tempArray,orders,0,0,index);
   //Now Copy index 6-9, start from 6  as the input index is to remove index 5
   ArrayCopy(tempArray,orders,index,(index+1));
   
   //copy Array back
   ArrayFree(orders);
   ArrayCopy(orders,tempArray,0,0);
}

string getName(string name)
{
   return name + "#" + IntegerToString(OrderTicket());
}

//Management of the operation
bool priceReachedPartialStopLoss()
{
   double price = ObjectGetDouble(0, getName(partialStopLossLineName), OBJPROP_PRICE1);
   if (OrderType() == OP_BUY) {
      return Bid < price;
   } else if(OrderType() == OP_SELL) {
      return Ask > price;
   }
   return false;
}

bool priceReachedPartialStopLossToBe()
{
   double price = ObjectGetDouble(0, getName(partialStopLossToBELineName), OBJPROP_PRICE1);
   if (OrderType() == OP_BUY) {
      return Bid > price;
   } else if(OrderType() == OP_SELL) {
      return Ask < price;
   }
   return false;
}

bool priceReachedStopLossToBe()
{
   double price = ObjectGetDouble(0, getName(stopLossToBELineName), OBJPROP_PRICE1);
   if (OrderType() == OP_BUY) {
      return Bid > price;
   } else if(OrderType() == OP_SELL) {
      return Ask < price;
   }
   return false;
}

bool priceReachedPartialTakeProfit()
{
   double price = ObjectGetDouble(0, getName(partialTakeProfitLineName), OBJPROP_PRICE1);
   if (OrderType() == OP_BUY) {
      return Bid > price;
   } else if(OrderType() == OP_SELL) {
      return Ask < price;
   }
   return false;
}

//Draw lines related to the order levels
void drawPartialStopLoss(int cmd)
{
   string name = getName(partialStopLossLineName);
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, getPartialStopLossPrice(cmd));
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}

void drawLinePartialStopLossToBreakEven(int cmd)
{
   string name = getName(partialStopLossToBELineName);
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, getLineToBreakEvenPrice(cmd, partialStopLossToBreakEven));
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
}

void drawLineStopLossToBreakEven(int cmd)
{
   string name = getName(stopLossToBELineName);
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, getLineToBreakEvenPrice(cmd, stopLossToBreakEven));
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
}

void drawPartialTakeProfit(int cmd)
{
   string name = getName(partialTakeProfitLineName);
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, getLineToBreakEvenPrice(cmd, partialTakeProfit));
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrOlive);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}

//Click handlers
void clickButtonSell()
{
   if (MarketInfo(Symbol(), MODE_TRADEALLOWED) <= 0) {
      Print("The market is closed");
      UIManager.notifyBuyFinished();
      return;
   }

   int ticket = sell();
   
   if (ticket < 0){
      Print("Error opening the order", GetLastError());
   } else if (OrderSelect(ticket, SELECT_BY_TICKET)) {
      createOrderInfo(ticket);
      drawPartialStopLoss(OP_SELL);
      drawLinePartialStopLossToBreakEven(OP_SELL);
      drawLineStopLossToBreakEven(OP_SELL);
      drawPartialTakeProfit(OP_SELL);
   } else {
      Print("Error selected the order with ticket ", ticket, " with error ", GetLastError());
   }
   UIManager.notifySellFinished();
}

void clickButtonBuy()
{
   if (MarketInfo(Symbol(), MODE_TRADEALLOWED) <= 0) {
      Print("The market is closed");
      UIManager.notifyBuyFinished();
      return;
   }
   
   int ticket = buy();
   if (ticket < 0) {
      Print("Error opening the order", GetLastError());
   } else if(OrderSelect(ticket, SELECT_BY_TICKET)) {
      createOrderInfo(ticket);
      drawPartialStopLoss(OP_BUY);
      drawLinePartialStopLossToBreakEven(OP_BUY);
      drawLineStopLossToBreakEven(OP_BUY);
      drawPartialTakeProfit(OP_BUY);
   } else {
      Print("Error selected the order with ticket ", ticket, " with error ", GetLastError());
   }
   UIManager.notifyBuyFinished();
}

void clickButtonClearAll()
{
   Print("Button clear clicked.");
   ObjectDelete(0, partialStopLossLineName+"#"+IntegerToString(OrderTicket()));
   ObjectDelete(0, partialStopLossToBELineName+"#"+IntegerToString(OrderTicket()));
   ObjectDelete(0, stopLossToBELineName+"#"+IntegerToString(OrderTicket()));
   ObjectDelete(0, partialTakeProfitLineName+"#"+IntegerToString(OrderTicket()));
}

//Enhancements
void setupOrdersPreviouslyOpened()
{
   for(int i = 0; i < OrdersTotal(); i++) {
      if (!OrderSelect(i, SELECT_BY_POS)) {
         continue;
      }

      if (OrderCloseTime() != 0) {
         continue;
      }
      
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magicNumber) {
         continue;
      }
      
      createOrderInfo(OrderTicket());
      drawPartialStopLoss(OrderType());
      drawLinePartialStopLossToBreakEven(OrderType());
      drawLineStopLossToBreakEven(OrderType());
      drawPartialTakeProfit(OrderType());
   }
}