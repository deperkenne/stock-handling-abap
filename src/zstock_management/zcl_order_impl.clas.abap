CLASS zcl_order_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_order_repo.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_order_impl IMPLEMENTATION.

  METHOD zif_order_repo~deleteorder.

  ENDMETHOD.

  METHOD zif_order_repo~getorder.
    READ ENTITIES OF zi_order_k IN LOCAL MODE
      ENTITY zi_order_k
      ALL FIELDS WITH CORRESPONDING #( it_keys )
      RESULT DATA(lt_orders).
      et_order_data = CORRESPONDING #( lt_orders ).

  ENDMETHOD.

  METHOD zif_order_repo~getorders.


  ENDMETHOD.

  METHOD zif_order_repo~update.

     MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
          ENTITY zi_order_k
           UPDATE FIELDS ( TotalAmount )
            WITH it_order.
  ENDMETHOD.

ENDCLASS.
