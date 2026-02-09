CLASS zcl_decrease_item_workflow_imp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES zif_decrease_item_workflow.
    METHODS constructor
      IMPORTING io_decrease_item    TYPE REF TO zif_lineitem_quantity_decrease
                io_repository       TYPE REF TO zif_lineitem_repo.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:  decrease_item            TYPE REF TO zif_lineitem_quantity_decrease,
           repo_lineitem            TYPE REF TO zif_lineitem_repo.

ENDCLASS.

CLASS zcl_decrease_item_workflow_imp IMPLEMENTATION.
  METHOD constructor.
     decrease_item = io_decrease_item.
     repo_lineitem = io_repository.
  ENDMETHOD.




  METHOD zif_decrease_item_workflow~start_process.

      repo_lineitem->getrealtimelineitem(
         EXPORTING it_keys     = it_keys
         IMPORTING et_items    = DATA(lt_read_data)
                   et_failed   = DATA(lt_failed)
                   et_reported = DATA(lt_reported)
      ).

      CHECK lt_failed IS  INITIAL.

      decrease_item->decrease_quantity(
          EXPORTING it_items = lt_read_data
          IMPORTING et_delete = DATA(lt_delete_item)
                    et_update = DATA(lt_update_item)
      ).

      IF lt_delete_item IS NOT INITIAL.

         repo_lineitem->delete(
            EXPORTING it_delete_item = lt_delete_item
            IMPORTING et_failed = DATA(lt_failed_by_delete)
                      et_reported = DATA(lt_reported_by_delete)
         ).

      ENDIF.

      IF lt_update_item IS NOT INITIAL.
         repo_lineitem->update(
           CHANGING it_update_table = lt_update_item
         ).

      ENDIF.

  ENDMETHOD.

ENDCLASS.
