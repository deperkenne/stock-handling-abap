 INTERFACE zif_order_repo
  PUBLIC .
  TYPES: order_data TYPE STANDARD TABLE OF zi_order_k WITH EMPTY KEY.
  TYPES: tt_keys_read TYPE TABLE FOR READ IMPORT zi_order_k,
         keys_order TYPE TABLE FOR READ IMPORT zi_order_k.

  TYPES: t_order_to_update TYPE TABLE FOR UPDATE zi_order_k.

  METHODS getOrders
    IMPORTING
      it_keys TYPE keys_order
    EXPORTING  t_stocks TYPE order_data.

  METHODS  getOrder
     IMPORTING it_keys TYPE tt_keys_read
     EXPORTING et_order_data TYPE order_data.

  METHODS  deleteOrder
     IMPORTING order_id TYPE order_data
     EXPORTING order TYPE order_data.

  METHODS updateOrder
     CHANGING it_order TYPE t_order_to_update.

ENDINTERFACE.
