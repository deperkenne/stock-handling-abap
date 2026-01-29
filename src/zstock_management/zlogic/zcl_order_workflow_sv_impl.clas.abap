CLASS zcl_order_workflow_sv_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_order_workflow_service.
    METHODS constructor
      IMPORTING io_calculator   TYPE REF TO zif_lineitem_calculator
                io_new_quantity TYPE REF TO zif_lineitem_new_quantyity
                io_repository   TYPE REF TO zif_lineitem_repo.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: calculator   TYPE REF TO zif_lineitem_calculator,
          new_quantity TYPE REF TO zif_lineitem_new_quantyity,
          repo_lineitem  TYPE REF TO zif_lineitem_repo.
ENDCLASS.



CLASS zcl_order_workflow_sv_impl IMPLEMENTATION.

  METHOD constructor.
    calculator   = io_calculator.
    new_quantity = io_new_quantity.
    repo_lineitem   = io_repository.
  ENDMETHOD.

  METHOD zif_order_workflow_service~start_process.

          DATA lt_failed TYPE RESPONSE FOR FAILED zi_order_k.
          DATA lt_reported TYPE RESPONSE FOR REPORTED zi_order_k.


          repo_lineitem->getrealtimelineitem(
             EXPORTING it_keys    = it_keys
             IMPORTING et_items   = DATA(lt_initial_items)
                       et_failed  = lt_failed
                       et_reported = lt_reported
          ).

          CHECK lt_failed IS INITIAL.


          new_quantity->calculator_new_quantity(
            EXPORTING it_items  = lt_initial_items
            IMPORTING et_update = DATA(lt_update_qty)
                      et_delete = DATA(lt_delete_item)
          ).


          IF lt_delete_item IS NOT INITIAL.
            repo_lineitem->delete(
              EXPORTING it_delete_item = lt_delete_item
              IMPORTING et_failed      = lt_failed
                        et_reported    = lt_reported
            ).
          ENDIF.


          IF lt_update_qty IS NOT INITIAL.

            repo_lineitem->update( CHANGING it_update_table = lt_update_qty ).


            repo_lineitem->getlineitem(
              EXPORTING it_update_table   = CORRESPONDING #( lt_update_qty )
              IMPORTING et_items  = DATA(lt_items_after_qty)
            ).


            calculator->calculate_gross_amounts(
               EXPORTING it_items  = lt_items_after_qty
               IMPORTING et_update = DATA(lt_update_gross)
            ).

            repo_lineitem->update_grossamount(
              CHANGING it_update_table = lt_update_gross
            ).
          ENDIF.

  ENDMETHOD.

ENDCLASS.
