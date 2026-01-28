CLASS lhc_ziline_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    METHODS TotalPrice_1 FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZILINE_ITEM~TotalPrice_1.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZILINE_ITEM RESULT result.

    METHODS delete_item_orders FOR MODIFY
      IMPORTING keys FOR ACTION ZILINE_ITEM~delete_item_orders RESULT result.
ENDCLASS.

CLASS lhc_ziline_item IMPLEMENTATION.

  METHOD TotalPrice_1.

    DATA: lo_item_repo TYPE REF TO  zif_lineitem_repo,
          lo_items_service TYPE REF TO zif_lineitem_service.
    DATA: lt_keys       TYPE zif_lineitem_repo=>ti_keys_read,
          lt_keys_o     TYPE zif_lineitem_repo=>to_keys_read,
          lt_results    TYPE zif_lineitem_repo=>item_data.
    DATA items_keys TYPE TABLE FOR READ IMPORT ziline_item.

    lo_item_repo  = NEW zcl_lineitem_impl(  ).
    lo_items_service = NEW zcl_lineitem_service_impl(  ).

    " retrieve all keys during execution  request in realtime
    lt_keys = VALUE #( FOR key IN keys ( %tky = key-%tky ) ).

    lo_item_repo->getlineitem(
          EXPORTING it_keys =  lt_keys
          IMPORTING et_items = lt_results
      ).

    " prepare keys
    lt_keys_o = VALUE #( FOR item_r in lt_results
                         ( %tky-OrderUuid = item_r-OrderUuid
                            %is_draft = item_r-%is_draft ) ).

    " make total price calculation
    lo_items_service->totalprice(
           EXPORTING
            it_keys =  lt_keys_o
            it_items = lt_results
     ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD delete_item_orders.

    READ ENTITIES OF zi_order_k IN LOCAL MODE
      ENTITY ziline_item
        FIELDS ( Quantity OrderUuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA lt_modify_item TYPE TABLE FOR UPDATE ziline_item.
    DATA lt_delete_item TYPE TABLE FOR DELETE ziline_item.



    LOOP AT lt_items INTO DATA(item).
       IF item-Quantity = 1.
         APPEND VALUE #(
             %tky = item-%tky
         ) TO lt_delete_item.
         EXIT.
       ENDIF.

       APPEND VALUE #(
         %tky = item-%tky
         Quantity = item-Quantity - 1
         %control = VALUE #( Quantity = if_abap_behv=>mk-on )
        ) TO lt_modify_item.

    ENDLOOP.


    IF lt_modify_item IS NOT INITIAL.
        MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
              ENTITY ziline_item
                UPDATE FIELDS ( Quantity )
                WITH lt_modify_item.
    ENDIF.

    IF lt_delete_item IS NOT INITIAL.
       MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
              ENTITY ziline_item
                DELETE FROM lt_delete_item
                REPORTED DATA(lt_delete).
    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_ORDER_K DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_order_k RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_order_k RESULT result.
    METHODS updatestock FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_order_k~updatestock.
    METHODS delete_all_orders FOR MODIFY
      IMPORTING keys FOR ACTION zi_order_k~delete_all_orders
      RESULT result.
    METHODS setstatustonew FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_order_k~setstatustonew.



    METHODS setid FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_order_k~setid.
    METHODS checkemptyorder FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_order_k~checkemptyorder.

ENDCLASS.

CLASS lhc_ZI_ORDER_K IMPLEMENTATION.




  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD updateStock.
    DATA test TYPE i.
    test = 0.
    IF test <> 0 .

            DATA(lv_message) = 'Début de la méthode CREATE'.
                DATA: lt_failed TYPE zif_stock_scheduled=>tt_uuid_tab.
                DATA(lo_stock_service) = zcl_stock_factory=>get_instance( 'STOCK_CHECKER' ).

                READ  ENTITIES OF zi_order_k IN LOCAL MODE
                ENTITY zi_order_k
                 ALL FIELDS WITH CORRESPONDING #( keys )
                 RESULT DATA(lt_orders).

                lo_stock_service->stock_allocation(
                   EXPORTING
                    it_orders = CORRESPONDING #( lt_orders ) " correspond allow to convert technique table to business table
                   IMPORTING
                    et_failed_uuids = lt_failed
                ).
     ENDIF.
  ENDMETHOD.

 METHOD delete_all_orders.
    DATA test TYPE i.
    test = 0.
    IF test <> 0 .
              " 1. Lire TOUTES les commandes existantes
              SELECT FROM ztorder
                FIELDS order_uuid
                INTO TABLE @DATA(lt_all_orders).

              IF lt_all_orders IS NOT INITIAL.

                " 2. Supprimer les commandes via RAP (les items seront supprimés en cascade)
                MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
                  ENTITY zi_order_k
                    DELETE FROM VALUE #( FOR order IN lt_all_orders
                                         ( %key-OrderUuid = order-order_uuid ) )
                  REPORTED DATA(lt_reported)
                  FAILED DATA(lt_failed).

                " 4. Vérifier les erreurs
                IF lt_failed IS INITIAL .
                  APPEND VALUE #(
                    %msg = new_message_with_text(
                             severity = if_abap_behv_message=>severity-success
                             text = |All orders have been deleted successfully.| )
                  ) TO reported-zi_order_k.
                ELSE.
                  " Gérer les erreurs
                  APPEND VALUE #(
                    %msg = new_message_with_text(
                             severity = if_abap_behv_message=>severity-error
                             text = |Some orders could not be deleted.| )
                  ) TO reported-zi_order_k.
                ENDIF.

              ELSE.

                APPEND VALUE #(
                  %msg = new_message_with_text(
                           severity = if_abap_behv_message=>severity-information
                           text = |No orders found to delete.| )
                ) TO reported-zi_order_k.
              ENDIF.

              result = VALUE #( ).
   ENDIF.
ENDMETHOD.

  METHOD setStatustoNew.
     " Lecture des commandes créées
      READ ENTITIES OF zi_order_k IN LOCAL MODE
        ENTITY zi_order_k
          ALL FIELDS
          WITH CORRESPONDING #( keys )
        RESULT DATA(sales_orders).

      " Mise à jour du statut
      MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
        ENTITY zi_order_k
          UPDATE FIELDS ( Status )
          WITH VALUE #( FOR order IN sales_orders
                        ( %tky = order-%tky
                          Status = 'NEW' ) ).
  ENDMETHOD.



  METHOD setID.
  ENDMETHOD.

  METHOD checkEmptyOrder.
    READ ENTITIES OF  zi_order_k IN LOCAL MODE
      ENTITY zi_order_k BY \_Items
        FIELDS ( ItemUuid ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_order).

    IF lt_order IS INITIAL.
       LOOP AT keys INTO DATA(ls_key).
         " On remplit la table REPORTED pour afficher le message dans Fiori/Postman
         APPEND VALUE #( %tky = ls_key-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Une commande doit contenir au moins un article.' )
                    ) TO reported-zi_order_K.

         APPEND VALUE #(
             %tky = ls_key-%tky
          ) TO failed-zi_order_K.

       ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
