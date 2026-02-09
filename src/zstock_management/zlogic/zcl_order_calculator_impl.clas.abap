CLASS zcl_order_calculator_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES zif_order_calculator.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_order_calculator_impl IMPLEMENTATION.


  METHOD zif_order_calculator~ordertotalamount.

      CLEAR et_order_update.

      " Utilisation de FOR GROUPS pour agréger les données par commande
      et_order_update = VALUE #(
            FOR GROUPS order_grp OF item IN it_items
            GROUP BY ( orderuuid = item-OrderUuid
                       is_draft  = item-%is_draft )
            (
              " Clé technique (Transmises via le groupe)
              %tky-OrderUuid = order_grp-orderuuid
              %tky-%is_draft = order_grp-is_draft

              " Calcul du montant total pour ce groupe spécifique
              TotalAmount    = REDUCE #( INIT val =  0
                                         FOR m IN GROUP order_grp
                                         NEXT val = val + m-GrossAmount )
              " Activation du flag de modification pour le framework RAP
              %control-TotalAmount = if_abap_behv=>mk-on
            )
      ).
ENDMETHOD.

ENDCLASS.
