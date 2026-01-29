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
            lt_items_to_delete TYPE TABLE FOR DELETE ziline_item,
            lt_keys_read   TYPE TABLE FOR READ IMPORT zi_order_k.
      DATA  lt_result     TYPE zif_lineitem_repo=>item_data.
      DATA: lt_failed TYPE RESPONSE FOR FAILED zi_order_k,
            lt_reported TYPE  RESPONSE FOR REPORTED zi_order_k.

      "fill lt_keys_read
      lt_keys_read = VALUE #( FOR it IN it_items
                       ( %is_draft = it-%is_draft
                         OrderUuid  = it-OrderUuid ) ).
      " call get_oder_item to return the specific line item with this orderuuid
      lineitem->get_order_lineitem(
             EXPORTING  it_keys  = lt_keys_read
             IMPORTING et_items  = lt_result
      ).

      LOOP AT it_items INTO DATA(items).
          DATA(lt_existing_only) = lt_result.
          DELETE lt_existing_only WHERE %tky = items-%tky.
          " fs_existing_item represent a specific line in lt_all_item he contain all existing  info (%tky,Quantity,price...)
          READ TABLE lt_existing_only
            ASSIGNING FIELD-SYMBOL(<fs_existing_item>) " using Assigning, we point directly to the table line
            WITH KEY ProductId = items-ProductId.

          IF sy-subrc = 0.
            APPEND VALUE #(
              %tky = items-%tky
             ) TO lt_items_to_delete.

            APPEND VALUE #(
                  %tky     = <fs_existing_item>-%tky
                  Quantity = <fs_existing_item>-Quantity + items-Quantity
                  %control = VALUE #( Quantity = if_abap_behv=>mk-on )
                ) TO lt_items_to_update.
          ENDIF.
      ENDLOOP.
      et_update = lt_items_to_update.
      et_delete = lt_items_to_delete.
  ENDMETHOD.

ENDCLASS.
