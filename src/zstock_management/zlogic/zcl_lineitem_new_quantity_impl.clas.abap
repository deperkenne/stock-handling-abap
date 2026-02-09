CLASS zcl_lineitem_new_quantity_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES zif_lineitem_new_quantyity.
   METHODS constructor
      IMPORTING io_lineitem_repo TYPE REF TO zif_lineitem_repo.

  PROTECTED SECTION.
  PRIVATE SECTION.
      DATA: lineitem TYPE REF TO zif_lineitem_repo.
ENDCLASS.



CLASS zcl_lineitem_new_quantity_impl IMPLEMENTATION.

  METHOD constructor.
    lineitem = io_lineitem_repo.
  ENDMETHOD.


  METHOD zif_lineitem_new_quantyity~calculator_new_quantity.

      DATA: lt_items_to_update TYPE TABLE FOR UPDATE ziline_item,
            lt_items_to_delete TYPE TABLE FOR DELETE ziline_item.

      DATA  lt_result     TYPE zif_lineitem_repo=>item_data.
      DATA: lt_failed TYPE RESPONSE FOR FAILED zi_order_k,
            lt_reported TYPE  RESPONSE FOR REPORTED zi_order_k.

      " call get_oder_item to return the specific line item with this orderuuid
      lineitem->get_order_lineitem(
             EXPORTING  it_items  = it_items
             IMPORTING et_items  = lt_result
      ).

      SORT lt_result BY ProductId ASCENDING CreatedAt ASCENDING.

      LOOP AT it_items INTO DATA(ls_new_item).
          READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<fs_old_item>)
          WITH KEY ProductId = ls_new_item-ProductId.

        " Si trouvé ET que ce n'est pas la même ligne (UUID différent)
        IF sy-subrc = 0 AND <fs_old_item>-%tky <> ls_new_item-%tky.

               APPEND VALUE #( %tky = ls_new_item-%tky ) TO lt_items_to_delete.

               <fs_old_item>-Quantity += ls_new_item-Quantity.

                APPEND VALUE #(
                      %tky     =  <fs_old_item>-%tky
                      Quantity =  <fs_old_item>-Quantity
                      %control = VALUE #( Quantity = if_abap_behv=>mk-on )
                    ) TO lt_items_to_update.
          ENDIF.




      ENDLOOP.
      et_update = lt_items_to_update.
      et_delete = lt_items_to_delete.
  ENDMETHOD.

ENDCLASS.
