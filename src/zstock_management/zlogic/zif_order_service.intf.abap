INTERFACE zif_order_service
  PUBLIC .

   METHODS OrderTotalAmount
    IMPORTING
      it_items TYPE zif_lineitem_repo=>item_data.

ENDINTERFACE.
