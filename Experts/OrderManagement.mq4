#property copyright "jordi"
#property link      ""
#property version   "1.00"
#property strict

#include <UserInterfaceManager.mqh>
#include <OrderManager.mqh>

const string partialStopLossLineName = "Partial stop loss";
const string partialStopLossToBELineName = "Partial stop loss to BE";
const string stopLossToBELineName = "Stop loss to BE";
const string partialTakeProfitLineName = "Partial Take Profit";
UserInterfaceManager UIManager = new UserInterfaceManager();
OrderManager orderManager;

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

int OnInit()
  {

   UIManager.drawUI();
   orderManager = new OrderManager(_digits, Symbol(), stop, partialStopLoss, partialTakeProfit, takeProfit, partialStopLossToBreakEven, stopLossToBreakEven, lots, halfLots, magicNumber, comment, slippage);
   if (retrievePreviouslyOrders) {
      orderManager.retrieveOrders(Symbol(), magicNumber);
   }

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

  }

void OnTick()
  {
   orderManager.checkOrders();
  }

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (UIManager.isSellButtonClicked(id, sparam)) {
      Print("Button sell clicked.");
      orderManager.sell();
      UIManager.notifySellFinished();
   } else if (UIManager.isBuyButtonClicked(id, sparam)) {
      Print("Button buy clicked.");
      orderManager.buy();
      UIManager.notifyBuyFinished();
   } else if (UIManager.isMinimizeButtonClicked(id, sparam)) {
      Print("Button toggle ui clicked");
   } else if (UIManager.isClearButtonClicked(id, sparam)) {
      orderManager.clearLines();
      Print("Button clear clicked");
      UIManager.notifyClearFinished();
   }
}