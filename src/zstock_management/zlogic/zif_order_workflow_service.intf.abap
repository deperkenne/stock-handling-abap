INTERFACE zif_order_workflow_service
  PUBLIC .

  METHODS start_process
   IMPORTING
     it_keys TYPE  zif_lineitem_repo=>ti_keys_read.
ENDINTERFACE.
