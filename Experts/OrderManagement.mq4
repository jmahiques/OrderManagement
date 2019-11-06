#property copyright "jordi"
#property link      ""
#property version   "1.00"
#property strict

#include <UserInterfaceManager.mqh>
#include <OrderManager.mqh>
#include <OrderLevelDrawer.mqh>

UserInterfaceManager *UIManager = new UserInterfaceManager();
OrderManager *orderManager;

input int stop = 10;
input int partialStopLoss = 8;
input int partialTakeProfit = 40;
input int takeProfit = 80;
input int _digits = 4;
input double lots = 0.02;
input double halfLots = 0.01;
input int magicNumber = 1;
input string comment = "Probando ratios";
input int slippage = 3;
input bool retrievePreviouslyOrders = true;
input bool useOwndigits = false;

int OnInit()
  {
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);
   UIManager.drawUI();
   orderManager = new OrderManager(useOwndigits ? _digits : Digits, Symbol(), stop, partialStopLoss, partialTakeProfit, takeProfit, lots, halfLots, magicNumber, comment, slippage);
   if (retrievePreviouslyOrders) {
      orderManager.retrieveOrders(Symbol(), magicNumber);
   }

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   UIManager.destroyUI();
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
   } else if(UIManager.isCloseAllClicked(id, sparam) && MessageBox("Cerrar posiciones", "Cerrar posiciones", MB_YESNO) == 6) {
      Print("Close all positions clicked");
      orderManager.closeAllOrders();
   } else if (id == CHARTEVENT_OBJECT_DRAG && OrderLevelDrawer::isPriceLevel(sparam)) {
      orderManager.updatePartial(sparam);
   } else if (id == CHARTEVENT_OBJECT_DELETE && OrderLevelDrawer::isPriceLevel(sparam)) {
      orderManager.removeLevel(sparam);
   }
   UIManager.notifyCloseAllFinished();
}