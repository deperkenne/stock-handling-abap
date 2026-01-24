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

    "DATA(lo_stock_service) = zcl_stock_factory=>get_instance( 'STOCK_CHECKER' ).

    READ ENTITIES OF zi_order_k IN LOCAL MODE
      ENTITY  ziline_item " On lit l'entité ITEM
        FIELDS ( OrderUuid Quantity Price )
        WITH CORRESPONDING #( keys ) " keys read current evenement
      RESULT DATA(lt_items).

    " Load stock data from buffer
    DATA(lt_stocks) = zc_stock_manager_buffer=>get_all_stock(  ).

    DATA: scheduled_table TYPE STANDARD TABLE OF zi_stock_scheduled,
           final_stock_table TYPE STANDARD TABLE OF zi_stock_current,
           lt_stock_updates TYPE TABLE OF zi_stock_managed.

      " start stock allocation process in interne table
      LOOP AT lt_items INTO DATA(item).

             DATA(lv_needed_qty) = item-Quantity.
             DATA(lv_total_qty) = REDUCE #(
                INIT sum = 0
                FOR ls_stock IN lt_stocks
                WHERE ( ProductId = item-ProductId )
                NEXT sum = sum + ls_stock-Quantity
            ).

            IF lv_total_qty < lv_needed_qty.

                " fill reported table to screen error message to client (postman or web client)
                APPEND VALUE #( %tky = item-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'stock insuffisant.' )
                    ) TO reported-ziline_item.
             ENDIF.

             " On cherche le stock correspondant pour ce produit dans la table récupérée précédemment
             LOOP AT lt_stocks INTO DATA(ls_stock_line) WHERE ProductId = item-ProductId.

                    IF lv_needed_qty <= 0. EXIT. ENDIF.

                    DATA(lv_allocatable_qty) = nmin( val1 = ls_stock_line-Quantity
                                         val2 = lv_needed_qty ).

                    IF lv_Allocatable_qty > 0.

                         " update memory table
                         ls_stock_line-Quantity -= lv_allocatable_qty.

                         lv_needed_qty   -= lv_allocatable_qty.

                         " On prépare l'enregistrement pour la mise à jour DB finale
                         APPEND VALUE #( Stockid = ls_stock_line-Stockid
                                Quantity = lv_Allocatable_qty ) TO lt_stock_updates.

                          APPEND VALUE #(

                                ItemUuid    = item-ItemUuid
                                StockId     = ls_stock_line-StockId
                                ProductId   = ls_stock_line-ProductId
                                Quantity     = lv_Allocatable_qty     " Quantité en stock
                                UnitPrice   = ls_stock_line-UnitPrice
                                currency     = ls_stock_line-Currency
                            ) TO scheduled_table.

                            IF lv_needed_qty <= 0.

                                EXIT.

                            ENDIF.
                       ENDIF.
                ENDLOOP.
   ENDLOOP.

   " update stock cache
   zc_stock_manager_buffer=>set_stock_cahe( lt_stocks ).

   " read updated stock cache
   DATA(lt_stocks_update) = zc_stock_manager_buffer=>get_all_stock(  ).


    " calculate total price and total amount
    DATA lt_order_keys TYPE TABLE FOR READ IMPORT zi_order_k.
    lt_order_keys = VALUE #( FOR my_item IN lt_items
                             ( %tky-OrderUuid = my_item-OrderUuid
                               %is_draft      = my_item-%is_draft ) ).

    DELETE ADJACENT DUPLICATES FROM lt_order_keys COMPARING OrderUuid.

    READ ENTITIES OF zi_order_k IN LOCAL MODE
        ENTITY zi_order_k BY \_Items
            FIELDS ( ProductId Quantity ) WITH CORRESPONDING #( lt_order_keys )
        RESULT DATA(lt_all_item)
        FAILED DATA(ls_f_items)
        REPORTED DATA(ls_r_items).


    " those two table labels(UPDATE and DELETE) is very important
    DATA lt_items_to_update TYPE TABLE FOR UPDATE ziline_item.
    DATA lt_items_to_delete TYPE TABLE FOR DELETE ziline_item.

    LOOP AT lt_items INTO DATA(items).
          " delete current instance in interne table
          DATA(lt_existing_only) = lt_all_item.
          DELETE lt_existing_only WHERE %tky = items-%tky.
          " fs_existing_item represent a specific line in lt_all_item he contain all existing  info (%tky,Quantity,price...)
          READ TABLE lt_existing_only
            ASSIGNING FIELD-SYMBOL(<fs_existing_item>) " using Assigning, we point directly to the table line
            WITH KEY ProductId = items-ProductId.


          IF sy-subrc = 0.
            APPEND VALUE #(
              %tky =  items-%tky
             ) TO lt_items_to_delete.


            APPEND VALUE #(
                  %tky     = <fs_existing_item>-%tky  " ✅ Utilise le %tky de l'EXISTANT
                  Quantity = <fs_existing_item>-Quantity + items-Quantity  " ✅ Additionne
                  %control = VALUE #( Quantity = if_abap_behv=>mk-on )  " Indique qu'on modifie Quantity
                ) TO lt_items_to_update.

          ENDIF.


    ENDLOOP.

    IF lt_items_to_delete IS NOT INITIAL.
        MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
          ENTITY ziline_item
            DELETE FROM lt_items_to_delete
          FAILED   DATA(ls_failed_del)
          REPORTED DATA(ls_reported_del)
          MAPPED   DATA(ls_mapped_del).
    ENDIF.

    IF lt_items_to_update IS NOT INITIAL.

        MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
            ENTITY ziline_item
               UPDATE FIELDS ( Quantity )
                WITH  lt_items_to_update
            FAILED DATA(ls_failed)
            REPORTED DATA(ls_reported)
            MAPPED DATA(ls_mapped).
    ENDIF.

    " Recalcul pour chaque item
    MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
        ENTITY ziline_item
          UPDATE FIELDS ( GrossAmount )
          WITH VALUE #(
            FOR it IN lt_items
            ( %tky = it-%tky " using to identify a instance load in RAP Buffer during request execution
              GrossAmount = it-Quantity * item-Price ) ).

          READ ENTITIES OF zi_order_k IN LOCAL MODE
           ENTITY ziline_item
            ALL FIELDS
            WITH CORRESPONDING #( keys ) " ou juste %tky si tu as les clés
          RESULT DATA(lt_current_table).


    DATA lt_order_to_update TYPE TABLE FOR UPDATE zi_order_k.

    LOOP AT lt_order_keys INTO DATA(order_keys).
          " read concerned parent
            READ ENTITIES OF zi_order_k IN LOCAL MODE
              ENTITY zi_order_k  BY \_Items
                ALL FIELDS
                "WITH VALUE #( ( %tky-OrderUuid = order_keys-OrderUuid ) )" read intern table with particular keys
                WITH CORRESPONDING #( lt_order_keys )
            RESULT DATA(lt_all_items).

            DATA(lv_total_amount) = VALUE zi_order_k-TotalAmount(  ).
            LOOP AT lt_all_items INTO DATA(ls_item).
               lv_total_amount += ( ls_item-Quantity * ls_item-Price ).
            ENDLOOP.

            APPEND VALUE #(

                  %tky     = order_keys-%tky  " ✅ Utilise le %tky de l'EXISTANT
                  TotalAmount =  lv_total_amount
                  %control = VALUE #( TotalAmount = if_abap_behv=>mk-on )  " Indique qu'on modifie Quantity

            ) TO lt_order_to_update.

    ENDLOOP.

    MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
          ENTITY zi_order_k
             UPDATE FIELDS ( TotalAmount )
             WITH lt_order_to_update.

   " read updated order afted making update
   READ ENTITIES OF zi_order_k IN LOCAL MODE
         ENTITY zi_order_k
         ALL FIELDS WITH CORRESPONDING #( lt_order_keys ) " read all modified order
         RESULT DATA(lt_order_update).

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
