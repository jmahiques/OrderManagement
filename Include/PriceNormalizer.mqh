//+------------------------------------------------------------------+
//|                                              PriceNormalizer.mqh |
//|                                                            jordi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "jordi"
#property link      ""
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PriceNormalizer
  {
private:
   int _digits;
public:
                     PriceNormalizer(int d = 4): _digits(d){};
                    ~PriceNormalizer();
   virtual double addAndNormalizePrice(int pips, double price);
   virtual double substractAndNormalizePrice(int pips, double price);
  };

double PriceNormalizer::addAndNormalizePrice(int pips, double price)
{
   return NormalizeDouble(price+pips/MathPow(10, _digits),_digits);
}

double PriceNormalizer::substractAndNormalizePrice(int pips, double price)
{
   return NormalizeDouble(price-pips/MathPow(10, _digits),_digits);
}