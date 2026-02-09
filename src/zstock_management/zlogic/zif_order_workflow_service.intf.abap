INTERFACE zif_order_workflow_service
  PUBLIC .
  TYPES: et_failed  TYPE RESPONSE FOR FAILED zi_order_k,
         et_reported TYPE RESPONSE FOR REPORTED zi_order_k.

  METHODS start_process
   IMPORTING
     it_keys TYPE  zif_lineitem_repo=>ti_keys_read
   EXPORTING
         et_failed  TYPE  et_failed
         et_reported TYPE et_reported.

   METHODS totalAmount
     IMPORTING
      it_items_keys TYPE zif_lineitem_repo=>t_u_items
      it_read_keys TYPE zif_lineitem_repo=>ti_keys_read.

ENDINTERFACE.
