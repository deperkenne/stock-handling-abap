CLASS zc_stock_manager_buffer DEFINITION PUBLIC FINAL CREATE PRIVATE .

  PUBLIC SECTION.
    TYPES: tt_stock TYPE STANDARD TABLE OF zi_stock_managed WITH EMPTY KEY.
    CLASS-METHODS get_all_stock  RETURNING VALUE(rt_stock) TYPE  tt_stock.
    CLASS-METHODS set_stock_cahe IMPORTING update_stock TYPE tt_stock.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLaSS-DATA get_instance TYPE REF TO zc_stock_manager_buffer.
    CLASS-DATA mt_stock_cache    TYPE tt_stock.
ENDCLASS.



CLASS zc_stock_manager_buffer IMPLEMENTATION.
  METHOD get_all_stock.
     IF get_instance IS INITIAL.
        get_instance = NEW #(  ).

        SELECT FROM zi_stock_managed
        FIELDS StockId, ProductId,SkuId, ProductName, Quantity, QuantityReserved,AvailableQuantity, Unit, UnitPrice, Currency
        INTO TABLE @mt_stock_cache.

     ENDIF.
     rt_stock = mt_stock_cache. " return value
  ENDMETHOD.

  METHOD set_stock_cahe.
    mt_stock_cache = update_stock.
  ENDMETHOD.

ENDCLASS.
