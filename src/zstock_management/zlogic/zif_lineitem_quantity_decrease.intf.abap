INTERFACE zif_lineitem_quantity_decrease
  PUBLIC .
  TYPES: tt_to_read   TYPE TABLE FOR READ RESULT ziline_item.
  TYPES: tt_to_update TYPE TABLE FOR UPDATE   ziline_item,
         tt_to_delete TYPE TABLE FOR DELETE   ziline_item.

  METHODS decrease_quantity
     IMPORTING
       it_items  TYPE tt_to_read
     EXPORTING
       et_update TYPE tt_to_update
       et_delete TYPE tt_to_delete.

ENDINTERFACE.
