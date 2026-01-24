CLASS zc_stock_scheduled_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_stock_scheduled.
  PROTECTED SECTION.

  PRIVATE SECTION.
  ClASS-DATA status TYPE c.

ENDCLASS.



CLASS zc_stock_scheduled_impl IMPLEMENTATION.



 METHOD zif_stock_scheduled~load_data_to_stock_res.
     DATA lt_create_res TYPE TABLE FOR CREATE zi_order_res.
     LOOP AT   lt_order_item INTO DATA(item).
        APPEND VALUE #(
           %cid        = |CID_{ item-ItemUuid }|
           OrderUuid = item-OrderUuid
           ItemUuid = item-ItemUuid
           ProductId = item-ProductId
           ResQuantity = item-Quantity
           Unit = item-Unit
           " On active les champs pour RAP
           %control-OrderUuid   = if_abap_behv=>mk-on
           %control-ItemUuid    = if_abap_behv=>mk-on
           %control-ProductId   = if_abap_behv=>mk-on
           %control-ResQuantity = if_abap_behv=>mk-on
         ) TO  lt_create_res.
     ENDLOOP.

     IF  lt_create_res IS NOT INITIAL.

       MODIFY ENTITIES OF zi_order_res " Ton entité de réservation
          ENTITY zi_order_res
            CREATE FIELDS ( OrderUuid ItemUuid ProductId ResQuantity )
            WITH  lt_create_res
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported).
     ENDIF.

     IF ls_failed IS NOT INITIAL.
        COMMIT ENTITIES
        RESPONSE OF zi_order_res
        FAILED DATA(ls_commit_failed)
        REPORTED DATA(ls_commit_reported).

     ENDIF.

 ENDMETHOD.

 METHOD zif_stock_scheduled~stock_allocation.


         " saved stock data in memory or draft table or redis cache we muss load this data only ontime for all request
         DATA(lt_stocks) = zc_stock_manager_buffer=>get_all_stock(  ).

          " 2. Récupérer les lignes de commande correspondantes
          READ ENTITIES OF zi_order_k IN LOCAL MODE
            ENTITY zi_order_k BY \_Items
              ALL FIELDS WITH
                VALUE #( FOR <new_order> IN it_orders ( OrderUuid = <new_order>-OrderUuid ) )
            RESULT DATA(lt_order_items)
            FAILED DATA(ls_failed_items)
            REPORTED DATA(ls_reported_items).

       " IF ls_failed_items-zi_order_k IS NOT INITIAL.
            " On extrait les UUIDs depuis le composant qui porte le nom de l'entité
         "   et_failed_uuids = VALUE #( FOR <f> IN ls_failed_items-zi_order_k ( <f>-OrderUuid ) ).
          "  RETURN.
      "  ENDIF.


          " initialise interne  table
          DATA: scheduled_table TYPE STANDARD TABLE OF zi_stock_scheduled,
                final_stock_table TYPE STANDARD TABLE OF zi_stock_current,
                lt_stock_updates TYPE TABLE OF zi_stock_managed.


          " start stock allocation process in interne table
          LOOP AT lt_order_items INTO DATA(items).



                     DATA(lv_needed_qty) = items-Quantity.
                     " On cherche le stock correspondant pour ce produit dans la table récupérée précédemment
                     LOOP AT lt_stocks INTO DATA(ls_stock_line) WHERE ProductId = items-ProductId.

                            IF lv_needed_qty <= 0. EXIT. ENDIF. " Commande déjà satisfaite

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
                                        StockId     = ls_stock_line-StockId
                                        ProductId   = ls_stock_line-ProductId
                                        Quantity     = lv_Allocatable_qty     " Quantité en stock
                                        UnitPrice   = ls_stock_line-UnitPrice
                                        currency     = ls_stock_line-Currency
                                    ) TO scheduled_table.



                                    IF lv_needed_qty <= 0.

                                        APPEND VALUE #(
                                            StockId     = ls_stock_line-StockId
                                            ProductId   = ls_stock_line-ProductId
                                            Remaining    = 0     " Quantité en stock
                                            UnitPrice   = ls_stock_line-UnitPrice
                                            currency     = ls_stock_line-Currency
                                            " createdAt  = ... (à mapper si dispo dans ls_stoc)
                                        ) TO final_stock_table.

                                        EXIT.

                                    ELSE.
                                      APPEND VALUE #(
                                            StockId     = ls_stock_line-StockId
                                            ProductId   = ls_stock_line-ProductId
                                            Remaining    =  ls_stock_line-Quantity
                                            UnitPrice   = ls_stock_line-UnitPrice
                                            currency     = ls_stock_line-Currency
                                            " createdAt  = ... (à mapper si dispo dans ls_stoc)
                                        ) TO final_stock_table.
                                     ENDIF.
                               ENDIF.
                        ENDLOOP.

                        IF lv_needed_qty > 0.
                           " insert to table restqty_table the partial delivery line-item.
                           " we need to create this table a two phase (interne and persist) and persist the data into
                        ENDIF .

           ENDLOOP.

           " as i work with RAP Framework it's important to use MODIFY Entity
          IF lt_stock_updates IS NOT INITIAL.

               MODIFY ENTITIES OF zi_stock_managed
                  ENTITY zi_stock_managed
                    UPDATE FIELDS ( Quantity )
                    WITH VALUE #( FOR s IN lt_stock_updates ( " Correction du nom de la table
                        %tky     = VALUE #( StockId = s-stockid )
                        Quantity = s-quantity
                        %control-Quantity = if_abap_behv=>mk-on ) )
                  FAILED   DATA(ls_failed_stock)
                  REPORTED DATA(ls_reported_stock).

        ENDIF.

 ENDMETHOD.


ENDCLASS.
