CLASS zcl_lineitem_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_lineitem_repo.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_lineitem_impl IMPLEMENTATION.

  METHOD zif_lineitem_repo~getlineitem.
     READ ENTITIES OF zi_order_k IN LOCAL MODE
      ENTITY ziline_item
      ALL FIELDS WITH CORRESPONDING #( it_keys )
      RESULT DATA(lt_items).
      et_items = CORRESPONDING #( lt_items ).
  ENDMETHOD.

  METHOD zif_lineitem_repo~update.

     MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
            ENTITY ziline_item
               UPDATE FIELDS ( Quantity )
                WITH it_update_table
            FAILED DATA(ls_failed)
            REPORTED DATA(ls_reported)
            MAPPED DATA(ls_mapped).

  ENDMETHOD.

  METHOD zif_lineitem_repo~delete.

    DATA: lt_keys_for_read TYPE TABLE FOR READ IMPORT ziline_item.
    DATA: lt_items_to_delete TYPE TABLE FOR DELETE ziline_item.

    " Puis remplissez-la avec une boucle classique
    LOOP AT it_delete_item INTO DATA(ls_item).
      APPEND VALUE #(
        %is_draft = ls_item-%is_draft
        ItemUuid  = ls_item-ItemUuid
      ) TO lt_keys_for_read.
    ENDLOOP.

    " Ensuite utilisez cette table
    READ ENTITIES OF zi_order_k IN LOCAL MODE
      ENTITY ziline_item
        FROM lt_keys_for_read
      RESULT DATA(lt_existing_items).

      if sy-subrc = 0.
         APPEND ls_item TO lt_items_to_delete.
      ENDIF.

     MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
          ENTITY ziline_item
            DELETE FROM lt_items_to_delete
          FAILED   DATA(ls_failed_del)
          REPORTED DATA(ls_reported_del)
          MAPPED   DATA(ls_mapped_del).

          et_failed = ls_failed_del.
          et_reported = ls_reported_del.

  ENDMETHOD.

  METHOD zif_lineitem_repo~get_order_lineItem.
     READ ENTITIES OF zi_order_k IN LOCAL MODE
        ENTITY zi_order_k BY \_Items
            FIELDS ( ProductId Quantity ) WITH CORRESPONDING #( it_keys )
        RESULT DATA(lt_all_item)
        FAILED DATA(ls_f_items)
        REPORTED DATA(ls_r_items).
        et_items = CORRESPONDING #( lt_all_item ).
   ENDMETHOD.

ENDCLASS.
