INTERFACE zif_stock_scheduled PUBLIC .

 " Utiliser directement le type de la vue CDS
  TYPES: tt_order_keys TYPE STANDARD TABLE OF zi_order_k
                       WITH DEFAULT KEY.
  TYPES: tt_uuid_tab TYPE STANDARD TABLE OF sysuuid_x16 WITH EMPTY KEY.
  TYPES: tt_order_items  TYPE STANDARD TABLE OF ztline_item_d WITH EMPTY KEY.

  METHODS stock_allocation
    IMPORTING
      it_orders TYPE tt_order_keys
    EXPORTING
      et_failed_uuids TYPE tt_uuid_tab. " list of failed id


 METHODS load_data_to_stock_res
    IMPORTING
      lt_order_item TYPE tt_order_items.

ENDINTERFACE.
