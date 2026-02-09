CLASS zcl_lineitem_qty_decrease_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_lineitem_quantity_decrease.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_lineitem_qty_decrease_impl IMPLEMENTATION.
  METHOD zif_lineitem_quantity_decrease~decrease_quantity.

     DATA : lt_delete_item TYPE TABLE FOR DELETE ziline_item,
            lt_modify_item TYPE TABLE FOR UPDATE ziline_item.

     LOOP AT it_items INTO DATA(item).
       IF item-Quantity = 1.
         APPEND VALUE #(
             %tky = item-%tky
         ) TO lt_delete_item.
         EXIT.
       ENDIF.

       APPEND VALUE #(
         %tky = item-%tky
         Quantity = item-Quantity - 1
         %control = VALUE #( Quantity = if_abap_behv=>mk-on )
        ) TO lt_modify_item.

    ENDLOOP.

    et_update = lt_modify_item.
    et_delete = lt_delete_item.

  ENDMETHOD.

ENDCLASS.
