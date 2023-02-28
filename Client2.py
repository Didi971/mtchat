# Copyright 2023, MetaQuotes Ltd.
# https://www.mql5.com

import MetaTrader5 as mt5

mt5.initialize()
login = 65987066
password = "Furiculi1986"
server = "XMGlobal-MT5 2"
mt5.login(login, password, server)

account_info = mt5.account_info()
orders = mt5.orders_total()
while True:
    

    # you code here
    # 
    if orders != mt5.orders_total() :
        print("hello")
        orders = mt5.orders_total()
mt5.shutdown() 