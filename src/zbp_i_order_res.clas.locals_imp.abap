CLASS lhc_ZI_ORDER_RES DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_order_res RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_order_res RESULT result.



ENDCLASS.

CLASS lhc_ZI_ORDER_RES IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.



  METHOD get_global_authorizations.
  ENDMETHOD.

ENDCLASS.
