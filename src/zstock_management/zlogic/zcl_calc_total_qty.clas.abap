CLASS zcl_calc_total_qty DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_calc_total_qty IMPLEMENTATION.

 METHOD if_sadl_exit_calc_element_read~calculate.

  DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
  DATA lt_items TYPE STANDARD TABLE OF ZC_LINE_ITEM WITH DEFAULT KEY.

  lt_items =  CORRESPONDING #( it_original_data ) .

  CHECK lt_items IS NOT INITIAL.

  " Test simple : affecter la Quantity directement
  LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<item>).
    <item>-TotalProductQty = <item>-Quantity.
  ENDLOOP.


  ct_calculated_data = CORRESPONDING #( lt_items ).
ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF line_exists( it_requested_calc_elements[ table_line = 'TOTALPRODUCTQTY' ] ).

        APPEND 'ITEMUUID' TO et_requested_orig_elements.
        APPEND 'ORDERUUID' TO et_requested_orig_elements.
        APPEND 'PRODUCTID' TO et_requested_orig_elements.
        APPEND 'QUANTITY' TO et_requested_orig_elements.
     ENDIF.
  ENDMETHOD.

ENDCLASS.
