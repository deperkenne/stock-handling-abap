INTERFACE zif_lineitem_repo
  PUBLIC .
  TYPES item_data TYPE TABLE FOR READ RESULT ziline_item.
  TYPES ti_keys_read TYPE TABLE FOR READ IMPORT ziline_item.
  TYPES to_keys_read TYPE TABLE FOR READ IMPORT zi_order_k.
  TYPES t_u_items TYPE TABLE FOR UPDATE ziline_item.
  TYPES: t_d_item  TYPE TABLE FOR DELETE ziline_item,
         t_failed  TYPE RESPONSE FOR FAILED zi_order_k,
         t_reported TYPE RESPONSE FOR REPORTED zi_order_k.



  METHODS getLineItem
    IMPORTING
     it_keys TYPE ti_keys_read
    EXPORTING  et_items TYPE item_data.


  METHODS update
    CHANGING
     it_update_table TYPE  t_u_items.

  METHODS delete
    IMPORTING
     it_delete_item TYPE t_d_item
    EXPORTING
      et_failed      TYPE t_failed
      et_reported    TYPE t_reported.

  METHODS get_order_lineItem
    IMPORTING
     it_keys TYPE to_keys_read
    EXPORTING
        et_items TYPE item_data.


ENDINTERFACE.
