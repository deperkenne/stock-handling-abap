INTERFACE zif_decrease_item_workflow
  PUBLIC .

  TYPES:
         et_failed  TYPE RESPONSE FOR FAILED zi_order_k,
         et_reported TYPE RESPONSE FOR REPORTED zi_order_k.
  METHODS start_process
   IMPORTING
     it_keys TYPE  zif_lineitem_repo=>ti_keys_read
   EXPORTING
         et_failed  TYPE  et_failed
         et_reported TYPE et_reported.

ENDINTERFACE.
