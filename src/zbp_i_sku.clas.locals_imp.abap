CLASS lhc_ZI_SKU DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_sku RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_sku RESULT result.
    METHODS checkproduct FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_sku~checkproduct.

ENDCLASS.

CLASS lhc_ZI_SKU IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD checkProduct.

     READ ENTITIES OF zi_sku IN LOCAL MODE
      ENTITY zi_sku
        FIELDS ( ProductId ) WITH CORRESPONDING #( keys )
      RESULT DATA(skus).

    " Lecture des produits associés
    READ ENTITIES OF zi_sku IN LOCAL MODE
      ENTITY zi_sku BY \_Product
        FIELDS ( ProductName ) WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT skus INTO DATA(sku).
      " Vérifier si le produit existe
      READ TABLE products INTO DATA(product)
        WITH KEY ProductId = sku-ProductId.

      IF sy-subrc <> 0.
        "** Produit introuvable
        APPEND VALUE #( %tky = sku-%tky ) TO failed-zi_sku.
        APPEND VALUE #( %tky = sku-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text = 'Impossible de créer un SKU : produit introuvable' )
                      ) TO reported-zi_sku.
      ELSE.
        " Vérifier si le produit est actif
        IF product-ProductName = abap_false.
          APPEND VALUE #( %tky = sku-%tky ) TO failed-zi_sku.
          APPEND VALUE #( %tky = sku-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text = 'Impossible de créer un SKU : produit inactif' )
                        ) TO reported-zi_sku.
        ENDIF.

        " Vérifier si le ProductName est vide ou invalide
        IF product-ProductName IS INITIAL.
          APPEND VALUE #( %tky = sku-%tky ) TO failed-zi_sku.
          APPEND VALUE #( %tky = sku-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text = 'Impossible de créer un SKU : le nom du produit est vide' )
                        ) TO reported-zi_sku.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
