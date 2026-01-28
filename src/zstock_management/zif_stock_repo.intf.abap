INTERFACE zif_stock_repo
  PUBLIC .


  TYPES: stock_data TYPE STANDARD TABLE OF ztstock WITH EMPTY KEY.
  TYPES: stockuuid  TYPE ztstock-stock_id.

  METHODS getStocks
    IMPORTING
      it_orders TYPE stock_data
    EXPORTING  t_stocks TYPE stock_data.

  METHODS  getStock
     IMPORTING stock_id TYPE stockuuid
     EXPORTING stock TYPE stock_data.

ENDINTERFACE.
