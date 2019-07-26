#property copyright "jordi"
#property link      ""
#property version   "1.00"
#property strict

#include <Arrays\ArrayObj.mqh>
#include <PriceNormalizer.mqh>
#include <OrderDrawerHelper.mqh>
#include <OrderInformation.mqh>
#include <OrderExecutionHelper.mqh>

class OrderManager
  {
private:
   string symbol;
   int stop;
   int partialStopLoss;
   int partialTakeProfit;
   int takeProfit;
   int partialStopLossToBreakEven;
   int stopLossToBreakEven;
   double lots;
   double halfLots;
   int magicNumber;
   string comment;
   int slippage;
   PriceNormalizer priceNormalizer;
   OrderDrawerHelper drawerHelper;
   OrderExecutionHelper orderExecution;
   CArrayObj orders;
   virtual OrderInformation *createOrderInformation();
   virtual double computePartialStopLossPrice(int pips, double price, int type);
   virtual double computePartialTakeProfitPrice(int pips, double price, int type);
   virtual double computePartialStopLossToBreakEvenPrice(int pips, double price, int type);
   virtual double computeStopLossToBreakEvenPrice(int pips, double price, int type);
   virtual void closeHalf(OrderInformation &order, color rowColor);
public:
                     OrderManager(){}
                     OrderManager(
                        int digits, string symbol, int stop, int partialStopLoss, int partialTakeProfit, int takeProfit, int partialStopLossToBreakEven, 
                        int stopLossToBreakEven, double lots, double halfLots, int magicNumber, string comment, int slippage
                     );
                    ~OrderManager();
   virtual void retrieveOrders(string symbol, int magicNumber);
   virtual void sell();
   virtual void buy();
   virtual void checkOrders();
   virtual void clearLines();
  };
  
OrderManager::OrderManager(
   int digits,
   string symbol,
   int stop,
   int partialStopLoss,
   int partialTakeProfit,
   int takeProfit,
   int partialStopLossToBreakEven,
   int stopLossToBreakEven,
   double lots,
   double halfLots,
   int magicNumber,
   string comment,
   int slippage
){
   this.symbol = symbol;
   this.stop = stop;
   this.partialStopLoss = partialStopLoss;
   this.partialTakeProfit = partialTakeProfit;
   this.takeProfit = takeProfit;
   this.partialStopLossToBreakEven = partialStopLossToBreakEven;
   this.stopLossToBreakEven = stopLossToBreakEven;
   this.lots = lots;
   this.halfLots = halfLots;
   this.magicNumber = magicNumber;
   this.comment = comment;
   this.slippage = slippage;
   
   priceNormalizer = new PriceNormalizer(digits);
   drawerHelper = new OrderDrawerHelper();
   orders = new CArrayObj();
   orderExecution = new OrderExecutionHelper(true, slippage, magicNumber);
}

OrderManager::~OrderManager()
{
}

OrderManager::retrieveOrders(string symbol,int magicNumber)
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
      
      OrderInformation* order = createOrderInformation();
      drawerHelper.drawLines(order);
   }
}

OrderInformation* OrderManager::createOrderInformation()
{
   OrderInformation* order = new OrderInformation(
      OrderOpenPrice(),
      OrderTicket(),
      OrderStopLoss(),
      OrderTakeProfit(),
      OrderLots(),
      OrderType(),
      computePartialStopLossPrice(this.partialStopLoss, OrderOpenPrice(), OrderType()),
      computePartialTakeProfitPrice(this.partialTakeProfit, OrderOpenPrice(), OrderType()), 
      computePartialStopLossToBreakEvenPrice(this.partialStopLossToBreakEven, OrderOpenPrice(), OrderType()),
      computeStopLossToBreakEvenPrice(this.stopLossToBreakEven, OrderOpenPrice(), OrderType())
   );
   orders.Add(order);
   
   return(order);
}

double OrderManager::computePartialStopLossPrice(int pips, double price, int type)
{
   double partialStopLossPrice = 0.00;
   if (type == OP_BUY) {
      partialStopLossPrice = priceNormalizer.substractAndNormalizePrice(pips, price);
   } else if(type == OP_SELL) {
      partialStopLossPrice = priceNormalizer.addAndNormalizePrice(pips, price);
   }
   
   return partialStopLossPrice;
}

double OrderManager::computePartialTakeProfitPrice(int pips, double price, int type)
{
   double partialTakeProfitPrice = 0.00;
   if (type == OP_BUY) {
      partialTakeProfitPrice = priceNormalizer.addAndNormalizePrice(pips, price);
   } else if(type == OP_SELL) {
      partialTakeProfitPrice = priceNormalizer.substractAndNormalizePrice(pips, price);
   }
   
   return partialTakeProfitPrice;
}

double OrderManager::computePartialStopLossToBreakEvenPrice(int pips, double price, int type)
{
   double partialStopLossToBreakEvenPrice = 0.00;
   if (type == OP_BUY) {
      partialStopLossToBreakEvenPrice = priceNormalizer.addAndNormalizePrice(pips, price);
   } else if(type == OP_SELL) {
      partialStopLossToBreakEvenPrice = priceNormalizer.substractAndNormalizePrice(pips, price);
   }
   
   return partialStopLossToBreakEvenPrice;
}

double OrderManager::computeStopLossToBreakEvenPrice(int pips, double price, int type)
{
   double stopLossToBreakEvenPrice = 0.00;
   if (type == OP_BUY) {
      stopLossToBreakEvenPrice = priceNormalizer.addAndNormalizePrice(pips, price);
   } else if(type == OP_SELL) {
      stopLossToBreakEvenPrice = priceNormalizer.substractAndNormalizePrice(pips, price);
   }
   
   return stopLossToBreakEvenPrice;
}

void OrderManager::sell(void)
{
   double price = Bid;
   double sl = priceNormalizer.addAndNormalizePrice(stop, price);
   double tp = priceNormalizer.substractAndNormalizePrice(takeProfit, price);
   int ticket = orderExecution.sell(this.symbol, this.lots, sl, tp, this.comment);
   
   if (ticket > 0){
      if (OrderSelect(ticket, SELECT_BY_TICKET)) {
         OrderInformation* order = createOrderInformation();
         drawerHelper.drawLines(order);
         return;
      }
      Print("Cannot open the order ", GetLastError());
   } else {
      PrintFormat("Cannot open the order with SL: %f TP: %.4f Market Price: %.4f", sl, tp, price);
   }
}

void OrderManager::buy(void)
{
   double price = Ask;
   double sl = priceNormalizer.substractAndNormalizePrice(stop, price);
   double tp = priceNormalizer.addAndNormalizePrice(takeProfit, price);
   int ticket = orderExecution.buy(this.symbol, this.lots, sl, tp, this.comment);
   
   if (ticket > 0){
      if (OrderSelect(ticket, SELECT_BY_TICKET)) {
         OrderInformation* order = createOrderInformation();
         drawerHelper.drawLines(order);
         return;
      }
      Print("Cannot open the order ", GetLastError());
   } else {
      PrintFormat("Cannot open the order with SL: %.4f TP: %.4f Market Price: %.4f", sl, tp, price);
   }
}

void OrderManager::checkOrders()
{
   for(int i = 0; i < orders.Total(); i++) {
      OrderInformation* order = orders.At(i);
      
      if (!OrderSelect(order.getTicket(), SELECT_BY_TICKET)){
         Print("Cannot select the order ", GetLastError());
         continue;
      }
      
      //The order reached the stop loss, pop it from the orders array
      if (OrderCloseTime() != 0) {
         Print("The order has been closed due to stop loss");
         drawerHelper.clearLines(order);
         orders.Delete(i);
         return;
      }
      
      double price = OrderType() == OP_BUY ? Bid : Ask;
      
      //Price touch partial stop loss
      if (order.priceReachedPartialStopLoss(price) && !order.executedPartialStopLoss) {
         drawerHelper.removePartialStopLossLine(order);
         drawerHelper.removePartialStopLossBreakEvenLine(order);
         
         closeHalf(order, clrRed);
         order.executedPartialStopLoss = true;
         
         Print("Price reached Partial Stop Loss");
         continue;
      }
      
      //Price touches the line to put the partial stop loss to breakeven
      if (order.priceReachedPartialStopOnBreakEven(price) && !order.executedPartialStopOnBreakEven) {
         order.executedPartialStopOnBreakEven = true;
         
         double partialStopLossLinePrice = order.getType() == OP_BUY 
            ? priceNormalizer.addAndNormalizePrice(1, price) 
            : priceNormalizer.substractAndNormalizePrice(1, price);
         
         drawerHelper.removePartialStopLossLine(order);
         drawerHelper.removeStopLossBreakEvenLine(order);   
         drawerHelper.drawPartialStopLossOnBreakEven(order, partialStopLossLinePrice);
         
         Print("Price reached Partial Stop Loss BE line");
         continue;
      }
      
      //Price touches the line to put the stop loss to breakeven
      if (order.priceReachedStopLossOnBreakEven(price) && !order.executedStopLossOnBreakEven) {
         drawerHelper.removeStopLossBreakEvenLine(order);
         
         orderExecution.putStopOnBreakEven(order);
         order.executedStopLossOnBreakEven = true;
         
         Print("Price reached Stop Loss BE line");
         continue;
      }
      
      //Price reaches partial take profit
      if (order.priceReachedPartialTakeProfit(price) && !order.executedPartialTakeProfit) {
         drawerHelper.removePartialTakeProfitLine(order);
         
         closeHalf(order, clrOliveDrab);
         order.executedPartialTakeProfit = true;
         
         Print("Price reached Partial Take Profit");
         continue;
      }
      
      //Price reached the line to put the partial stop loss to breakeven and return to the open price
      if (order.priceReachedPartialStopLoss(price) && !order.executedPartialStopLoss && order.getType() == OP_BUY && price < order.getOpenPrice()) {
         drawerHelper.removePartialStopLossOnBreakEven(order);
         
         closeHalf(order, clrRed);
         order.executedPartialStopLoss = true;
         
         Print("Close the half of the position, the price reached the order price entry");
      } else if(order.priceReachedPartialStopLoss(price) && !order.executedPartialStopLoss && order.getType() == OP_SELL && price > order.getOpenPrice()) {
         drawerHelper.removePartialStopLossOnBreakEven(order);
         
         closeHalf(order, clrRed);
         order.executedPartialStopLoss = true;
         
         Print("Close the half of the position, the price reached the order price entry");
      }
   }
}

void OrderManager::clearLines(void)
{
   for(int i = 0; i < orders.Total(); i++) {
      OrderInformation* order = orders.At(i);
      drawerHelper.clearLines(order);
   }
}

void OrderManager::closeHalf(OrderInformation &order, color rowColor)
{
   if (!orderExecution.closeHalfOrder(order, rowColor)) {
      Print("Error while closing the half of the order", GetLastError());
      return;
   }
   if (!OrderSelect(OrdersTotal()-1, SELECT_BY_POS)){
      Print("Error while selecting the last order", GetLastError());
      return;
   }
   order.updateInfoAfterCloseHalf(OrderLots(), OrderOpenPrice(), OrderTicket());
   Print("Closed half position correctly, new ticket ", OrderTicket());
}