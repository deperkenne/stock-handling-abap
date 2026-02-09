INTERFACE zif_order_calculator
  PUBLIC .

   METHODS OrderTotalAmount
    IMPORTING
      it_items TYPE zif_lineitem_repo=>item_data
    EXPORTING et_order_update TYPE zif_order_repo=>t_order_to_update.

ENDINTERFACE.
