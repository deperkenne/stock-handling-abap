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
  METHOD zif_lineitem_repo~getrealtimelineitem.
     READ ENTITIES OF zi_order_k IN LOCAL MODE
          ENTITY ziline_item
          ALL FIELDS WITH CORRESPONDING #( it_keys )
          RESULT DATA(lt_items)
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported).
     et_items    = lt_items.
     et_failed   = ls_failed.
     et_reported = ls_reported.
  ENDMETHOD.

  METHOD zif_lineitem_repo~getlineitem.
     DATA  lt_keys_to_read TYPE TABLE FOR READ IMPORT ziline_item.
     " mapping updated table to read table
     lt_keys_to_read = VALUE #( FOR wa IN it_update_table (
        %is_draft = wa-%is_draft
        ItemUuid  = wa-ItemUuid
      ) ).

     READ ENTITIES OF zi_order_k IN LOCAL MODE
          ENTITY ziline_item
            FROM lt_keys_to_read
          RESULT DATA(lt_items)
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported).
     et_items    = lt_items.
     et_failed   = ls_failed.
     et_reported = ls_reported.
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

  METHOD zif_lineitem_repo~updateCreatedAt.
      DATA update_date_with_keys TYPE TABLE FOR UPDATE ziline_item.
      LOOP AT it_keys INTO DATA(keys).
          APPEND VALUE #(
             %tky = keys-%tky
             CreatedAt = utclong_current( )
           ) TO update_date_with_keys .

      ENDLOOP.
       " update createdAt for a new items
      MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
        ENTITY ziline_item
          UPDATE FIELDS ( CreatedAt )
          WITH update_date_with_keys.

  ENDMETHOD.


  METHOD zif_lineitem_repo~update_grossamount.
     MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
            ENTITY ziline_item
               UPDATE FIELDS ( grossamount )
                WITH it_update_table
            FAILED DATA(ls_failed)
            REPORTED DATA(ls_reported)
            MAPPED DATA(ls_mapped).
  ENDMETHOD.

  METHOD zif_lineitem_repo~delete.
     MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
          ENTITY ziline_item
            DELETE FROM it_delete_item
          FAILED   DATA(ls_failed_del)
          REPORTED DATA(ls_reported_del)
          MAPPED   DATA(ls_mapped_del).
    et_failed   = ls_failed_del.
    et_reported = ls_reported_del.
  ENDMETHOD.

  METHOD zif_lineitem_repo~get_order_lineItem.

     DATA lt_keys_read   TYPE TABLE FOR READ IMPORT zi_order_k.

     "fill lt_keys_read
     lt_keys_read = VALUE #( FOR it IN it_items
                       ( %is_draft = it-%is_draft
                         OrderUuid  = it-OrderUuid ) ).
     READ ENTITIES OF zi_order_k IN LOCAL MODE
        ENTITY zi_order_k BY \_Items
            ALL FIELDS  WITH CORRESPONDING #( lt_keys_read )
        RESULT DATA(lt_all_item)
        FAILED DATA(ls_f_items)
        REPORTED DATA(ls_r_items).
        et_items = CORRESPONDING #( lt_all_item ). " see this again for performence
   ENDMETHOD.
ENDCLASS.
