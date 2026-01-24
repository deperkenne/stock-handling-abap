CLASS lhc_ZI_STOCK_MANAGED DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_stock_managed RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_stock_managed RESULT result.

    METHODS checkProduct FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_STOCK_MANAGED~checkProduct.

    METHODS setCreatedAt FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_stock_managed~setCreatedAt.
    METHODS checkSku FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_STOCK_MANAGED~checkSku.



ENDCLASS.

CLASS lhc_ZI_STOCK_MANAGED IMPLEMENTATION.


  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD checkProduct.
    " Lecture des stocks
    READ ENTITIES OF zi_stock_managed IN LOCAL MODE
      ENTITY zi_stock_managed
        FIELDS ( ProductId ) WITH CORRESPONDING #( keys )
      RESULT DATA(stocks).

    READ ENTITIES OF zi_stock_managed IN LOCAL MODE
      ENTITY zi_stock_managed BY \_Product
        FIELDS ( ProductName ) WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT stocks INTO DATA(stock).
      " Vérifier si le produit existe
      READ TABLE products INTO DATA(product)
        WITH KEY ProductId = stock-ProductId.

      IF sy-subrc <> 0.
        "** Produit introuvable
        APPEND VALUE #( %tky = stock-%tky ) TO failed-zi_stock_managed.
        APPEND VALUE #( %tky = stock-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text = 'Impossible de créer un Produit : produit introuvable' )
                      ) TO reported-zi_stock_managed.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


   METHOD setCreatedAt.
    " Lecture des données
     READ ENTITIES OF zi_stock_managed IN LOCAL MODE
      ENTITY zi_stock_managed
           FIELDS ( CreatedAt ) WITH CORRESPONDING #( keys )
      RESULT DATA(stocks).

     " Ne traiter que les nouvelles créations
     DELETE stocks WHERE CreatedAt IS NOT INITIAL.

     CHECK stocks IS NOT INITIAL.

     " Calculer le timestamp
     DATA(lv_timestamp) = utclong_current( ).

     " Modifier directement dans le buffer transactionnel
     MODIFY ENTITIES OF zi_stock_managed IN LOCAL MODE
        ENTITY zi_stock_managed
          UPDATE SET FIELDS WITH VALUE #(
            FOR stock IN stocks
              ( %tky = stock-%tky
                CreatedAt = lv_timestamp
                 %control-CreatedAt = if_abap_behv=>mk-on ) ) .
  ENDMETHOD.



  METHOD checkSku.
      " Lecture des stocks
    READ ENTITIES OF zi_stock_managed IN LOCAL MODE
      ENTITY zi_stock_managed
        FIELDS ( SkuId ) WITH CORRESPONDING #( keys )
      RESULT DATA(stocks).

    READ ENTITIES OF zi_stock_managed IN LOCAL MODE
      ENTITY zi_stock_managed BY \_Sku
        FIELDS ( SkuID ) WITH CORRESPONDING #( keys )
      RESULT DATA(skus).


       LOOP AT stocks INTO DATA(stock).
          " Vérifier si le produit existe
          READ TABLE skus INTO DATA(sku)
            WITH KEY SkuId = stock-SkuId.
          IF sy-subrc = 0.
            "** Produit introuvable
            APPEND VALUE #( %tky = stock-%tky ) TO failed-zi_stock_managed.
            APPEND VALUE #( %tky = stock-%tky
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text = 'this SkuId already exist' )
                          ) TO reported-zi_stock_managed.
          ENDIF.
       ENDLOOP.

  ENDMETHOD.

ENDCLASS.
