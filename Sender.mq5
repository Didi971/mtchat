//+------------------------------------------------------------------+
//|                                                       Sender.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//----------------Include---------------------------------------------
#include <Telegram.mqh>
#include <GestionnaireMsg.mqh>
//----------------Class-----------------------------------------------

GestionnaireMsg bot;

//----------------Variable--------------------------------------------

bool premierTp  = false;
int position;
int dealsHistorique;
int ordersHistorique;
input string TgrToken = "6228473798:AAFh1l2gnFkTIKpncpd3I8j_SMNdSYbS1Z4"; //Traderyouyoubot
long channel    = -1001846930803;
long idDiego   = 1353114129;
long idYouyou =0;
long idJeremy =0;
string pill[1000];
int countMessage = 0;
int countAction =0;
int limiteur= 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetMillisecondTimer(1);
   Initialisation();
   position = PositionsTotal();
   UpdateHistorique();
   bot.SendMessage(channel,"yo");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
//
   CheckOpen();
   CheckClose();
   CheckModif();
   limiteur ==0;
   limiteur++;
   UpdateTelegram();
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---


  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---

  }
//+------------------------------------------------------------------+
void Initialisation()
  {
   bot.Token(TgrToken);
   int Result = bot.GetMe();
   if(Result != 0)
     {
      Print("Erreur :");

     }
   else
     {
      bot.SendMessage(idDiego, "Bot initialisé");
     }
   Print("Bot name: "+bot.Name());
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void CheckOpen()
  {
   if(position < PositionsTotal())
     {

      Print(PositionGetTicket(position));
      string sy = PositionGetString(POSITION_SYMBOL);
      Print(sy);
      string msg = "";
      string type;
      long posId = PositionGetInteger(POSITION_IDENTIFIER);
      int digits = SymbolInfoInteger(sy,SYMBOL_DIGITS);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      double lot = PositionGetDouble(POSITION_VOLUME);
      double op = PositionGetDouble(POSITION_PRICE_OPEN);
      double capital = AccountInfoDouble(ACCOUNT_BALANCE);

      if(PositionGetInteger(POSITION_TYPE) == 0)
        {
         type = "Achat";
        }
      else
        {
         type = "Vente";
        }
      msg = "Trade " + type
            + "\nTicket = " + IntegerToString(posId)
            + "\nSymbol = " + sy
            + "\nPrice = " + DoubleToString(op, digits)
            + "\nLot = " + DoubleToString(lot,2)
            + "\nStopLoss = " + DoubleToString(sl, digits)
            + "\nTakeProfit = " + DoubleToString(tp, digits)
            + "\nCapital = " + DoubleToString(capital, 2)
            ;
      UpdatePill(msg);
      position++;
      GlobaleVariableSet(posId);
      UpdateHistorique();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckClose()
  {
   if(HistorySelect(TimeCurrent() - 86400, TimeCurrent()))
     {
      if(ordersHistorique < HistoryOrdersTotal())
        {

         if(position == PositionsTotal())
           {
            for(int i = 0; i < PositionsTotal(); i++)
              {
               Print("Partielle");
               if(PositionGetTicket(i) == HistoryOrderGetInteger(HistoryOrderGetTicket(ordersHistorique),ORDER_POSITION_ID))
                 {
                  long posId = PositionGetInteger(POSITION_IDENTIFIER);
                  double sl = PositionGetDouble(POSITION_SL);
                  double tp = PositionGetDouble(POSITION_TP);
                  double op = PositionGetDouble(POSITION_PRICE_OPEN);
                  double lot = PositionGetDouble(POSITION_VOLUME);
                  double slRef = GlobalVariableGet("sl " + posId);
                  double tpRef = GlobalVariableGet("tp " + posId);
                  double opRef = GlobalVariableGet("op " + posId);
                  double lotRef = GlobalVariableGet("lot " + posId);
                  double idRef = GlobalVariableGet("id " + posId);
                  double capital = AccountInfoDouble(ACCOUNT_BALANCE);
                  double type;
                  if(PositionGetInteger(POSITION_TYPE) == 0)
                    {
                     type = "Achat";
                    }
                  else
                    {
                     type = "Vente";
                    }
                  string sy = PositionGetString(POSITION_SYMBOL);
                  string msg;
                  int digits = SymbolInfoInteger(sy,SYMBOL_DIGITS);
                  if(lotRef != lot)
                    {
                     msg = "Close Partielle " + type + " @ " + DoubleToString(PositionGetDouble(POSITION_PRICE_CURRENT), digits)
                           + "\nLot = " + DoubleToString(lotRef - lot,2)
                           + "\nNumero magic = " + IntegerToString(posId)
                           + "\nCapital = " + DoubleToString(capital,2) + "\n"
                           ;
                     UpdatePill(msg);
                     GlobaleVariableSet(posId);
                     UpdateHistorique();

                    }
                 }

              }
           }
         else
            if(PositionsTotal() < position)
              {
               Print(HistoryOrderGetInteger(HistoryOrderGetTicket(ordersHistorique),ORDER_POSITION_ID));
               long posId = HistoryOrderGetInteger(HistoryOrderGetTicket(ordersHistorique),ORDER_POSITION_ID);
               double sl = HistoryOrderGetDouble(HistoryOrderGetTicket(ordersHistorique),ORDER_SL);
               double tp = HistoryOrderGetDouble(HistoryOrderGetTicket(ordersHistorique),ORDER_TP);
               double op = HistoryOrderGetDouble(HistoryOrderGetTicket(ordersHistorique),ORDER_PRICE_OPEN);
               double lot = HistoryOrderGetDouble(HistoryOrderGetTicket(ordersHistorique),ORDER_VOLUME_CURRENT);
               double slRef = GlobalVariableGet("sl " + posId);
               double tpRef = GlobalVariableGet("tp " + posId);
               double opRef = GlobalVariableGet("op " + posId);
               double lotRef = GlobalVariableGet("lot " + posId);
               double idRef = GlobalVariableGet("id " + posId);
               double capital = AccountInfoDouble(ACCOUNT_BALANCE);
               string type;
               if(PositionGetInteger(POSITION_TYPE) == 0)
                 {
                  type = "Achat";
                 }
               else
                 {
                  type = "Vente";
                 }
               string sy = HistoryOrderGetString(HistoryOrderGetTicket(ordersHistorique),ORDER_SYMBOL);
               string msg;
               int digits = SymbolInfoInteger(sy,SYMBOL_DIGITS);
               msg = "Close Total " + type + " @ " + DoubleToString(op, digits)
                     + "\nLot = " + DoubleToString(lotRef,2)
                     + "\nNumero magic = " + IntegerToString(HistoryOrderGetInteger(HistoryOrderGetTicket(ordersHistorique),ORDER_POSITION_ID))
                     + "\nCapital = " + DoubleToString(capital,2) + "\n"
                     ;
               UpdatePill(msg);
               GlobaleVariableDel(HistoryOrderGetInteger(HistoryOrderGetTicket(ordersHistorique),ORDER_POSITION_ID));
               position--;
               UpdateHistorique();
              }

         //if(lot)
         //

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateHistorique()
  {
   if(HistorySelect(TimeCurrent() - 86400, TimeCurrent()))
     {
      dealsHistorique = HistoryDealsTotal();
      ordersHistorique = HistoryOrdersTotal();
      Print(dealsHistorique);
      Print(ordersHistorique);
     }
  }
//+------------------------------------------------------------------+
void CheckModif()
  {
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetTicket(i) > 0)
        {
         long posId = PositionGetInteger(POSITION_IDENTIFIER);
         double sl = PositionGetDouble(POSITION_SL);
         double tp = PositionGetDouble(POSITION_TP);
         double op = PositionGetDouble(POSITION_PRICE_OPEN);
         double lot = PositionGetDouble(POSITION_VOLUME);
         double slRef = GlobalVariableGet("sl " + posId);
         double tpRef = GlobalVariableGet("tp " + posId);
         double opRef = GlobalVariableGet("op " + posId);
         double lotRef = GlobalVariableGet("lot " + posId);
         double idRef = GlobalVariableGet("id " + posId);
         double capital = AccountInfoDouble(ACCOUNT_BALANCE);
         double type;
         if(PositionGetInteger(POSITION_TYPE) == 0)
           {
            type = "Achat";
           }
         else
           {
            type = "Vente";
           }
         string sy = PositionGetString(POSITION_SYMBOL);
         string msg;
         int digits = (int)SymbolInfoInteger(sy,SYMBOL_DIGITS);
         //         if(lotRef != lot)
         //           {
         //            msg = "Close Partielle " + type + " @ " + DoubleToString(PositionGetDouble(POSITION_PRICE_CURRENT), digits)
         //                  + "\nLot = " + DoubleToString(lotRef - lot,2)
         //                  + "\nNumero magic = " + IntegerToString(posId)
         //                  + "\nCapital = " + DoubleToString(capital,2) + "\n"
         //                  ;
         //            bot.SendMessage(idDiego,msg);
         //
         //           }
         if(sl != 0 ||
            tp != 0)
           {
            if(slRef != sl
               || tpRef != tp
               || opRef != op
              )
              {
               msg = "OrderModify " + "\n" +
                     "OpenPrice = " + DoubleToString(op,digits) + "\n" +
                     "Stoploss = " + DoubleToString(sl,digits) + "\n" +
                     "TakeProfit = " + DoubleToString(tp,digits) + "\n" +
                     "Numero magic = " + IntegerToString(posId);
               UpdatePill(msg);
               GlobaleVariableSet(posId);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
void GlobaleVariableSet(long ticket)
  {
   if(PositionSelectByTicket(ticket))
     {
      string sy = PositionGetString(POSITION_SYMBOL);
      int digits = (int)SymbolInfoInteger(sy,SYMBOL_DIGITS);

      GlobalVariableSet("id " + IntegerToString(ticket), ticket);
      GlobalVariableSet("sl " + IntegerToString(ticket), NormalizeDouble(PositionGetDouble(POSITION_SL), digits));
      GlobalVariableSet("tp " + IntegerToString(ticket), NormalizeDouble(PositionGetDouble(POSITION_TP),digits));
      GlobalVariableSet("lot " + IntegerToString(ticket), NormalizeDouble(PositionGetDouble(POSITION_VOLUME),digits));
      GlobalVariableSet("op " + IntegerToString(ticket), NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),digits));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GlobaleVariableDel(long ticket)
  {
   if(HistorySelectByPosition(ticket))
     {
      GlobalVariableDel("id " + IntegerToString(ticket));
      GlobalVariableDel("sl " + IntegerToString(ticket));
      GlobalVariableDel("tp " + IntegerToString(ticket));
      GlobalVariableDel("lot " + IntegerToString(ticket));
      GlobalVariableDel("op " + IntegerToString(ticket));
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void UpdateTelegram()
  {
   if(countMessage < countAction)
     {
      bot.SendMessage(idDiego, pill[countMessage]);
      bot.SendMessage(idYouyou, pill[countMessage]);
      bot.SendMessage(idJeremy, pill[countMessage]);
      bot.SendMessage(channel, pill[countMessage]);
      countMessage++;
      if(countMessage == 999)
        {
         countMessage=0;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdatePill(string message)
  {
   pill[countAction] = message;
   countAction++;
   if(countAction == 999)
     {countAction = 0;}
  }
//+------------------------------------------------------------------+
void PillInitalyzz()
  {
   for(int i = 0; i < ArraySize(pill); i++)
     {
      pill[i] = "";
     }
  }
//+------------------------------------------------------------------+
