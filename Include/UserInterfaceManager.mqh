#property copyright "jordi"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

struct ButtonProperties
{
   string buttonName;
   int buttonX;
   int buttonY;
   int buttonWidth;
   int buttonHeight;
   color buttonBackground;
   color buttonColor;
   string buttonText;
};

class UserInterfaceManager
  {
private:
   ButtonProperties buttonProperties[4];
   int minimizeIndex;
   int sellIndex;
   int buyIndex;
   int clearIndex;
   int chartId;
   virtual void createButton(ButtonProperties &properties);
   virtual void deleteButton(string name);
   virtual void hideUI();
   virtual void showUI();
public:
                     UserInterfaceManager();
                    ~UserInterfaceManager();
   virtual void drawUI();
   virtual void destroyUI();
   virtual bool isSellButtonClicked(const int id, const string &sparam);
   virtual bool isBuyButtonClicked(const int id, const string &sparam);
   virtual bool isMinimizeButtonClicked(const int id, const string &sparam);
   virtual bool isClearButtonClicked(const int id, const string &sparam);
   virtual void notifySellFinished();
   virtual void notifyBuyFinished();
   virtual void notifyClearFinished();
  };
  
UserInterfaceManager::UserInterfaceManager()
{
   ButtonProperties minimizeProperties = {"-", 10, 20, 50, 20, clrDarkGray, clrBlack, "-"};
   ButtonProperties sellProperties = {"SELL", 10, 50, 50, 20, clrRed, clrWhite, "SELL"};
   ButtonProperties buyProperties = {"BUY", 10, 80, 50, 20, clrOliveDrab, clrWhite, "BUY"};
   ButtonProperties clearProperties = {"CLEAR", 10, 110, 50, 20, clrDarkGray, clrWhite, "CLEAR"};
   
   minimizeIndex = 0;
   sellIndex = 1;
   buyIndex = 2;
   clearIndex = 3;
   
   chartId = 0;
   
   buttonProperties[minimizeIndex] = minimizeProperties;
   buttonProperties[sellIndex] = sellProperties;
   buttonProperties[buyIndex] = buyProperties;
   buttonProperties[clearIndex] = clearProperties;
}

UserInterfaceManager::~UserInterfaceManager()
{
   destroyUI();
}

//Private class functions
UserInterfaceManager::createButton(ButtonProperties &properties)
{
   ObjectCreate(chartId, properties.buttonName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(chartId, properties.buttonName, OBJPROP_XDISTANCE, properties.buttonX);
   ObjectSetInteger(chartId, properties.buttonName, OBJPROP_YDISTANCE, properties.buttonY);
   ObjectSetInteger(chartId, properties.buttonName, OBJPROP_XSIZE, properties.buttonWidth);
   ObjectSetInteger(chartId, properties.buttonName, OBJPROP_YSIZE, properties.buttonHeight);
   ObjectSetInteger(chartId, properties.buttonName, OBJPROP_BGCOLOR, properties.buttonBackground);
   ObjectSetInteger(chartId, properties.buttonName, OBJPROP_COLOR, properties.buttonColor);
   ObjectSetString(chartId, properties.buttonName, OBJPROP_TEXT, properties.buttonText);
}

UserInterfaceManager::deleteButton(string buttonName)
{
   ObjectDelete(0, buttonName);
}

UserInterfaceManager::drawUI()
{
   createButton(buttonProperties[minimizeIndex]);
   createButton(buttonProperties[sellIndex]);
   createButton(buttonProperties[buyIndex]);
   createButton(buttonProperties[clearIndex]);
}

UserInterfaceManager::destroyUI()
{
   deleteButton(buttonProperties[minimizeIndex].buttonName);
   deleteButton(buttonProperties[sellIndex].buttonName);
   deleteButton(buttonProperties[buyIndex].buttonName);
   deleteButton(buttonProperties[clearIndex].buttonName);
}

UserInterfaceManager::hideUI()
{
   deleteButton(buttonProperties[sellIndex].buttonName);
   deleteButton(buttonProperties[buyIndex].buttonName);
   deleteButton(buttonProperties[clearIndex].buttonName);
}

UserInterfaceManager::showUI()
{
   createButton(buttonProperties[sellIndex]);
   createButton(buttonProperties[buyIndex]);
   createButton(buttonProperties[clearIndex]);
}

bool UserInterfaceManager::isSellButtonClicked(const int id, const string &sparam)
{
   string buttonName = buttonProperties[sellIndex].buttonName;
   return id == CHARTEVENT_OBJECT_CLICK && sparam == buttonName && ObjectGetInteger(0,buttonName,OBJPROP_STATE) == 1;
}

bool UserInterfaceManager::isBuyButtonClicked(const int id, const string &sparam)
{
   string buttonName = buttonProperties[buyIndex].buttonName;
   return id == CHARTEVENT_OBJECT_CLICK && sparam == buttonName && ObjectGetInteger(0,buttonName,OBJPROP_STATE) == 1;
}

bool UserInterfaceManager::isMinimizeButtonClicked(const int id, const string &sparam)
{
   string buttonName = buttonProperties[minimizeIndex].buttonName;
   if (id == CHARTEVENT_OBJECT_CLICK && sparam == buttonName && ObjectGetInteger(0,buttonName,OBJPROP_STATE) == 1) {
      hideUI();
      return true;
   } else if(id == CHARTEVENT_OBJECT_CLICK && sparam == buttonName && ObjectGetInteger(0,buttonName,OBJPROP_STATE) == 0) {
      showUI();
      return true;
   }
   
   return false;
}

bool UserInterfaceManager::isClearButtonClicked(const int id, const string &sparam)
{
   string buttonName = buttonProperties[clearIndex].buttonName;
   return id == CHARTEVENT_OBJECT_CLICK && sparam == buttonName && ObjectGetInteger(0,buttonName,OBJPROP_STATE) == 1;
}

UserInterfaceManager::notifySellFinished()
{
   ObjectSetInteger(0,buttonProperties[sellIndex].buttonName, OBJPROP_STATE, 0);
}

UserInterfaceManager::notifyBuyFinished()
{
   ObjectSetInteger(0,buttonProperties[buyIndex].buttonName, OBJPROP_STATE, 0);
}

UserInterfaceManager::notifyClearFinished()
{
   ObjectSetInteger(0,buttonProperties[clearIndex].buttonName, OBJPROP_STATE, 0);
}