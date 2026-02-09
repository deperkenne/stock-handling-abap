CLASS zcl_lineitem_service_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES zif_lineitem_service .
  PROTECTED SECTION.
  PRIVATE SECTION.
   " Dependencies injection
   DATA: i_line_item TYPE REF TO zif_lineitem_repo,
         order_service TYPE REF TO zif_order_calculator.

   DATA lt_items_to_update TYPE TABLE FOR UPDATE ziline_item.
   DATA lt_items_to_delete TYPE TABLE FOR DELETE ziline_item.
   DATA line_items TYPE  zif_lineitem_repo=>item_data.
   DATA t_result  TYPE zif_lineitem_repo=>item_data.

ENDCLASS.



CLASS zcl_lineitem_service_impl IMPLEMENTATION.

  METHOD zif_lineitem_service~totalprice.
      " stark kupplung depending on concrete class
      order_service = NEW zcl_order_calculator_impl(  ).

      DATA lt_to_update TYPE TABLE FOR UPDATE ziline_item.
      DATA lt_keys_to_read TYPE TABLE FOR READ  IMPORT ziline_item.

      " call internal updateQuantity method dependency 1
      zif_lineitem_service~updateQuantity(

          EXPORTING
          it_keys = it_keys
          it_items = it_items
          IMPORTING
           et_update = lt_to_update

      ).

    " mapping from table lt_to_update to table  lt_keys_to_read reason is we need to read data not update or delete
    lt_keys_to_read = VALUE #( FOR wa IN lt_to_update (
        %is_draft = wa-%is_draft
        ItemUuid  = wa-ItemUuid
    ) ).

    READ ENTITIES OF zi_order_k IN LOCAL MODE
      ENTITY ziline_item
        FROM lt_keys_to_read
      RESULT DATA(lt_items).


      MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
        ENTITY ziline_item
          UPDATE FIELDS (  grossamount )
            WITH VALUE #( FOR it IN lt_items
                       ( %tky = it-%tky
                        grossamount = it-Quantity * it-Price ) )

      REPORTED DATA(ls_reported)
      FAILED DATA(ls_failed).

      " call method "order total amount" from order_service class dependency 2
      IF ls_failed IS INITIAL.

        order_service->ordertotalamount(
           EXPORTING it_items = it_items
        ).

      ENDIF.

 ENDMETHOD.



 METHOD  zif_lineitem_service~updateQuantity.


     DATA: lt_failed TYPE RESPONSE FOR FAILED zi_order_k,
           lt_reported TYPE  RESPONSE FOR REPORTED zi_order_k.

     i_line_item = NEW zcl_lineitem_impl(  ).

     i_line_item->get_order_lineitem(
        EXPORTING it_keys = it_keys
        IMPORTING et_items = t_result
      ).

     LOOP AT it_items INTO DATA(items).
          " delete current instance in interne table

          DATA(lt_existing_only) = t_result.
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


    IF lt_items_to_delete IS NOT INITIAL.
       i_line_item->delete(
         EXPORTING
         it_delete_item = lt_items_to_delete
         IMPORTING
            et_failed = lt_failed
            et_reported = lt_reported
        ).
    ENDIF.

    IF lt_items_to_update IS NOT INITIAL.
           i_line_item->update(
             CHANGING  it_update_table = lt_items_to_update
            ).
    ENDIF.

    " return
    et_update = lt_items_to_update.

 ENDMETHOD.




ENDCLASS.
