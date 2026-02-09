CLASS zcl_order_workflow_sv_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_order_workflow_service.
    METHODS constructor
      IMPORTING io_calculator       TYPE REF TO zif_lineitem_calculator
                io_new_quantity     TYPE REF TO zif_lineitem_new_quantyity
                io_repository       TYPE REF TO zif_lineitem_repo
                io_order_calculator TYPE REF TO zif_order_calculator
                io_order_repo       TYPE REF TO zif_order_repo.


  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: calculator       TYPE REF TO zif_lineitem_calculator,
          new_quantity     TYPE REF TO zif_lineitem_new_quantyity,
          repo_lineitem    TYPE REF TO zif_lineitem_repo,
          order_calculator TYPE REF TO zif_order_calculator,
          repo_order       TYPE REF TO zif_order_repo.
ENDCLASS.



CLASS zcl_order_workflow_sv_impl IMPLEMENTATION.

  METHOD constructor.
    calculator       = io_calculator.
    new_quantity     = io_new_quantity.
    repo_lineitem    = io_repository.
    order_calculator = io_order_calculator.
    repo_order       = io_order_repo.

  ENDMETHOD.

  METHOD zif_order_workflow_service~start_process.

          DATA lt_failed TYPE RESPONSE FOR FAILED zi_order_k.
          DATA lt_reported TYPE RESPONSE FOR REPORTED zi_order_k.
          DATA read_items TYPE TABLE FOR UPDATE ziline_item.


          " read draft instance in Transactional Buffer
          repo_lineitem->getrealtimelineitem(
             EXPORTING it_keys     = it_keys
             IMPORTING et_items    = DATA(lt_initial_items)
                       et_failed   = lt_failed
                       et_reported = lt_reported
          ).


          repo_lineitem->updatecreatedat(
                EXPORTING it_keys = it_keys

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

            " check if new insert item exist
            READ ENTITIES OF zi_order_k IN LOCAL MODE
              ENTITY ziline_item
                FIELDS ( ItemUuid ) WITH CORRESPONDING #( it_keys )
            RESULT DATA(lt_result).

            IF sy-subrc = 0.
            ENDIF.
          ENDIF.

          IF lt_update_qty IS NOT INITIAL.

             repo_lineitem->update( CHANGING it_update_table = lt_update_qty ).

             repo_lineitem->getlineitem(
              EXPORTING it_update_table   = CORRESPONDING #( lt_update_qty )
              IMPORTING et_items          = DATA(lt_items_after_qty)
             ).

             calculator->calculate_gross_amounts(
               EXPORTING it_items  = lt_items_after_qty
               IMPORTING et_update = DATA(lt_update_gross_create)
             ).
             repo_lineitem->update_grossamount(
              CHANGING it_update_table = lt_update_gross_create
            ).

          ELSE.
             read_items = VALUE #( FOR item IN lt_initial_items ( %tky = item-%tky ) ).

             repo_lineitem->getlineitem(
              EXPORTING it_update_table   = CORRESPONDING #( read_items  )
              IMPORTING et_items          = DATA(lt_items_after_decrease_qty)
             ).

             calculator->calculate_gross_amounts(
               EXPORTING it_items  = lt_items_after_decrease_qty
               IMPORTING et_update = DATA(lt_update_gross_delete)
             ).

             repo_lineitem->update_grossamount(
              CHANGING it_update_table = lt_update_gross_delete
            ).

          ENDIF.

         repo_lineitem->get_order_lineitem(

              EXPORTING it_items = lt_initial_items
              IMPORTING et_items = DATA(lt_items_for_order)

           ).

         " update total article amount
         order_calculator->ordertotalamount(
            EXPORTING it_items        = lt_items_for_order
            IMPORTING et_order_update = DATA(lt_update_total)
          ).

         repo_order->update(
             CHANGING it_order = lt_update_total
           ).

  ENDMETHOD.

  METHOD zif_order_workflow_service~totalAmount.


  ENDMETHOD.

ENDCLASS.
