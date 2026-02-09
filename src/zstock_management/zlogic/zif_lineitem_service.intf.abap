INTERFACE zif_lineitem_service
  PUBLIC .
  TYPES et_lineitem TYPE TABLE  OF ziline_item WITH EMPTY KEY.
  TYPES: t_failed  TYPE RESPONSE FOR FAILED zi_order_k,
         t_reported TYPE RESPONSE FOR REPORTED zi_order_k.

  METHODS totalPrice
    IMPORTING
     it_keys TYPE  zif_lineitem_repo=>to_keys_read
     it_items TYPE  zif_lineitem_repo=>item_data
    EXPORTING
          et_update TYPE zif_lineitem_repo=>t_u_items
          et_failed TYPE t_failed
          et_reported TYPE t_reported.

  METHODS calculNewQuantity
        IMPORTING
          it_keys TYPE  zif_lineitem_repo=>to_keys_read
          it_items TYPE  zif_lineitem_repo=>item_data
        EXPORTING
          et_update TYPE zif_lineitem_repo=>t_u_items
          et_failed TYPE t_failed
          et_reported TYPE t_reported.

  METHODS updateQuantity
    IMPORTING
      it_keys TYPE  zif_lineitem_repo=>to_keys_read
      it_items TYPE zif_lineitem_repo=>item_data
    EXPORTING
      et_update TYPE zif_lineitem_repo=>t_u_items
      et_failed TYPE t_failed
      et_reported TYPE t_reported.

ENDINTERFACE.
