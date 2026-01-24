CLASS zcl_stock_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  CLASS-METHODS get_instance
      IMPORTING iv_type TYPE string
      RETURNING VALUE(ro_instance) TYPE REF TO zif_stock_scheduled.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_stock_factory IMPLEMENTATION.
   METHOD get_instance.
      CASE iv_type.
        WHEN 'STOCK_CHECKER'.
        ro_instance = NEW zc_stock_scheduled_impl(  ).
      ENDCASE.

   ENDMETHOD.

ENDCLASS.
