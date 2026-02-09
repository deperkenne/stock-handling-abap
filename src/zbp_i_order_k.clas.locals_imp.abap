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


    DATA: lo_item_repo        TYPE REF TO zif_lineitem_repo,
          lo_items_service    TYPE REF TO zif_lineitem_service,
          lo_items_calculator TYPE REF TO zif_lineitem_calculator,
          lo_new_quantity     TYPE REF TO zif_lineitem_new_quantyity,
          lo_order_calculator TYPE REF TO zif_order_calculator,
          lo_order_repo       TYPE REF TO zif_order_repo,
          lo_workflow_service TYPE REF TO zif_order_workflow_service.

    lo_item_repo            = NEW zcl_lineitem_impl(  ).
    lo_items_calculator     = NEW zcl_lineitem_calculator_impl(  ).
    lo_new_quantity         = NEW zcl_lineitem_new_quantity_impl( io_lineitem_repo = lo_item_repo ).
    lo_order_calculator     = NEW zcl_order_calculator_impl(  ).
    lo_order_repo           = NEW zcl_order_impl(  ).

    lo_workflow_service     = NEW zcl_order_workflow_sv_impl(
        io_calculator       = lo_items_calculator
        io_new_quantity     = lo_new_quantity
        io_repository       = lo_item_repo
        io_order_calculator = lo_order_calculator
        io_order_repo       =  lo_order_repo
    ).

    DATA: lt_keys TYPE zif_lineitem_repo=>ti_keys_read.

    lt_keys = VALUE #( FOR key IN keys ( %tky = key-%tky ) ).


     DATA: lt_failed   TYPE RESPONSE FOR FAILED zi_order_k,
          lt_reported TYPE RESPONSE FOR REPORTED zi_order_k.

     lo_workflow_service->start_process(
         EXPORTING it_keys =  lt_keys
         IMPORTING et_failed = lt_failed
                   et_reported = lt_reported
     ).

  DATA(failed) = lt_failed .
  DATA(reported_o) = lt_reported .

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD delete_item_orders.

    DATA: lo_item_repo              TYPE REF TO zif_lineitem_repo,
          lo_item_quantity          TYPE REF TO zif_lineitem_quantity_decrease,
          lo_decrease_item_workflow TYPE REF TO zif_decrease_item_workflow.


    DATA: lt_keys TYPE zif_lineitem_repo=>ti_keys_read.

    lt_keys = VALUE #( FOR key IN keys ( %tky = key-%tky ) ).



    lo_item_repo              = NEW zcl_lineitem_impl(  ).
    lo_item_quantity          = NEW zcl_lineitem_qty_decrease_impl( ) .
    lo_decrease_item_workflow = NEW zcl_decrease_item_workflow_imp(
         io_repository    = lo_item_repo
         io_decrease_item = lo_item_quantity
    ).


    DATA: lt_failed   TYPE RESPONSE FOR FAILED zi_order_k,
          lt_reported TYPE RESPONSE FOR REPORTED zi_order_k.

    lo_decrease_item_workflow->start_process(
         EXPORTING it_keys = lt_keys
         IMPORTING et_failed = lt_failed
                   et_reported = lt_reported
    ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_ORDER_K DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_order_k RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_order_k RESULT result.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE zi_order_k.

    METHODS precheck_update FOR PRECHECK
       IMPORTING entities FOR UPDATE zi_order_k.

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


  METHOD precheck_create.
    " Appelé AVANT la création et avant determine action Prepare
    LOOP AT entities INTO DATA(entity).
        SELECT SINGLE * FROM ztorder_d
            WHERE CustomerID = @entity-CustomerId
            INTO @DATA(ls_customer).
      IF entity-OrderId IS INITIAL .
        APPEND VALUE #(
          %key = entity-%key
        ) TO failed-zi_order_k.

         " On remplit la table REPORTED pour afficher le message dans Fiori/Postman
         APPEND VALUE #( %key = entity-%key
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Une commande doit contenir au moins un article.' )
                    ) TO reported-zi_order_K.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    " Appelé AVANT la mise à jour et avant determine action Prepare
    LOOP AT entities INTO DATA(entity).
      IF entity-OrderUuid IS INITIAL.
        APPEND VALUE #(
          %key = entity-%key
        ) TO failed-zi_order_k.

        " On remplit la table REPORTED pour afficher le message dans Fiori/Postman
         APPEND VALUE #( %key = entity-%key
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Order status fail' )
                    ) TO reported-zi_order_K.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD updateStock.

     READ ENTITIES OF zi_order_k IN LOCAL MODE
          ENTITY ziline_item
            FIELDS ( CreatedAt )
            WITH CORRESPONDING #( keys )
          RESULT DATA(lineitems).

      " update createdAt for a new items
      MODIFY ENTITIES OF zi_order_k IN LOCAL MODE
        ENTITY ziline_item
          UPDATE FIELDS ( CreatedAt )
          WITH VALUE #( FOR lineitem IN lineitems WHERE ( CreatedAt IS INITIAL )
                          ( %tky = lineitem-%tky
                            CreatedAt = utclong_current( ) ) ).

    DATA test TYPE i.
    test = 0.
    IF test = 0 .

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

              SELECT FROM ztorder
                FIELDS order_uuid
                INTO TABLE @DATA(lt_all_orders).

              IF lt_all_orders IS NOT INITIAL.


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
