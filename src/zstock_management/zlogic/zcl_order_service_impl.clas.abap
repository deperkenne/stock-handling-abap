CLASS zcl_order_service_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES zif_order_service.
  PROTECTED SECTION.
  PRIVATE SECTION.
    " dependency injection
    DATA: lineitem_repo TYPE REF TO zif_order_repo.
ENDCLASS.



CLASS zcl_order_service_impl IMPLEMENTATION.


  METHOD zif_order_service~ordertotalamount.

       lineitem_repo = NEW zcl_order_impl(  ).

       DATA(lv_total_amount) = VALUE zi_order_k-TotalAmount(  ).
       DATA lt_order_update TYPE TABLE FOR UPDATE zi_order_k.
       DATA lt_order_keys  TYPE  TABLE FOR READ IMPORT zi_order_k.

       lt_order_keys = VALUE #( FOR my_item IN it_items
                             ( %tky-OrderUuid = my_item-OrderUuid
                               %is_draft      = my_item-%is_draft ) ).

       LOOP AT it_items INTO DATA(ls_item).
               lv_total_amount += ( ls_item-Quantity * ls_item-Price ).
       ENDLOOP.
       LOOP AT lt_order_keys INTO DATA(order_keys).
           APPEND VALUE #(

                %tky   = order_keys-%tky
                TotalAmount =  lv_total_amount
                %control = VALUE #( TotalAmount = if_abap_behv=>mk-on )

           ) TO lt_order_update.
      ENDLOOP.

      lineitem_repo->updateorder(
        CHANGING  it_order =  lt_order_update

      ).

  ENDMETHOD.

ENDCLASS.
