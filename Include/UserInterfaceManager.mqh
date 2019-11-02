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
   ButtonProperties buttonProperties[5];
   int minimizeIndex;
   int sellIndex;
   int buyIndex;
   int clearIndex;
   int closeAllIndex;
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
   virtual bool isCloseAllClicked(const int id, const string &sparam);
   virtual void notifySellFinished();
   virtual void notifyBuyFinished();
   virtual void notifyClearFinished();
   virtual void notifyCloseAllFinished();
  };
  
UserInterfaceManager::UserInterfaceManager()
{
   ButtonProperties minimizeProperties = {"-", 10, 20, 80, 20, clrDarkGray, clrBlack, "-"};
   ButtonProperties sellProperties = {"SELL", 10, 50, 80, 20, clrRed, clrWhite, "SELL"};
   ButtonProperties buyProperties = {"BUY", 10, 80, 80, 20, clrOliveDrab, clrWhite, "BUY"};
   ButtonProperties clearProperties = {"CLEAR", 10, 110, 80, 20, clrDarkGray, clrWhite, "CLEAR"};
   ButtonProperties closeAllProperties = {"CLOSE ALL", 10, 140, 80, 20, clrDarkGray, clrWhite, "CLOSE ALL"};
   
   minimizeIndex = 0;
   sellIndex = 1;
   buyIndex = 2;
   clearIndex = 3;
   closeAllIndex = 4;
   
   chartId = 0;
   
   buttonProperties[minimizeIndex] = minimizeProperties;
   buttonProperties[sellIndex] = sellProperties;
   buttonProperties[buyIndex] = buyProperties;
   buttonProperties[clearIndex] = clearProperties;
   buttonProperties[closeAllIndex] = closeAllProperties;
}

UserInterfaceManager::~UserInterfaceManager()
{
   destroyUI();
}

//Private class functions
void UserInterfaceManager::createButton(ButtonProperties &properties)
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

void UserInterfaceManager::deleteButton(string buttonName)
{
   ObjectDelete(0, buttonName);
}

void UserInterfaceManager::drawUI()
{
   createButton(buttonProperties[minimizeIndex]);
   createButton(buttonProperties[sellIndex]);
   createButton(buttonProperties[buyIndex]);
   createButton(buttonProperties[clearIndex]);
   createButton(buttonProperties[closeAllIndex]);
}

void UserInterfaceManager::destroyUI()
{
   deleteButton(buttonProperties[minimizeIndex].buttonName);
   deleteButton(buttonProperties[sellIndex].buttonName);
   deleteButton(buttonProperties[buyIndex].buttonName);
   deleteButton(buttonProperties[clearIndex].buttonName);
   deleteButton(buttonProperties[closeAllIndex].buttonName);
}

void UserInterfaceManager::hideUI()
{
   deleteButton(buttonProperties[sellIndex].buttonName);
   deleteButton(buttonProperties[buyIndex].buttonName);
   deleteButton(buttonProperties[clearIndex].buttonName);
   deleteButton(buttonProperties[closeAllIndex].buttonName);
}

void UserInterfaceManager::showUI()
{
   createButton(buttonProperties[sellIndex]);
   createButton(buttonProperties[buyIndex]);
   createButton(buttonProperties[clearIndex]);
   createButton(buttonProperties[closeAllIndex]);
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

bool UserInterfaceManager::isCloseAllClicked(const int id,const string &sparam)
{
   string buttonName = buttonProperties[closeAllIndex].buttonName;
   return id == CHARTEVENT_OBJECT_CLICK && sparam == buttonName && ObjectGetInteger(0,buttonName,OBJPROP_STATE) == 1;
}

void UserInterfaceManager::notifySellFinished()
{
   ObjectSetInteger(0,buttonProperties[sellIndex].buttonName, OBJPROP_STATE, 0);
}

void UserInterfaceManager::notifyBuyFinished()
{
   ObjectSetInteger(0,buttonProperties[buyIndex].buttonName, OBJPROP_STATE, 0);
}

void UserInterfaceManager::notifyClearFinished()
{
   ObjectSetInteger(0,buttonProperties[clearIndex].buttonName, OBJPROP_STATE, 0);
}

void UserInterfaceManager::notifyCloseAllFinished(void)
{
   ObjectSetInteger(0,buttonProperties[closeAllIndex].buttonName, OBJPROP_STATE, 0);
}