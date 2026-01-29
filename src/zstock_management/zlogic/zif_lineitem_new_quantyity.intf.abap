INTERFACE zif_lineitem_new_quantyity
  PUBLIC .

  METHODS calculator_new_quantity
    IMPORTING
      it_items       TYPE zif_lineitem_repo=>item_data
    EXPORTING
      et_update      TYPE zif_lineitem_repo=>t_u_items
      et_delete      TYPE zif_lineitem_repo=>t_d_items.

ENDINTERFACE.
