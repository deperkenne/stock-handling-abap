CLASS zcl_lineitem_calculator_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_lineitem_calculator.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_lineitem_calculator_impl IMPLEMENTATION.
  METHOD zif_lineitem_calculator~calculate_gross_amounts.
       DATA lt_update TYPE TABLE FOR UPDATE ziline_item.
       lt_update = VALUE #( FOR it IN it_items
                       ( %tky = it-%tky
                        grossamount = it-Quantity * it-Price ) ).
       et_update = lt_update.
  ENDMETHOD.

ENDCLASS.
