CLASS lhc_ZI_CUSTOMER_RAP DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_customer_rap RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_customer_rap RESULT result.

    METHODS validateemail FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_customer_rap~validateemail.

    METHODS validatenames FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_customer_rap~validatenames.

ENDCLASS.

CLASS lhc_ZI_CUSTOMER_RAP IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validateEmail.
      READ ENTITIES OF ZI_CUSTOMER_RAP IN LOCAL MODE
      ENTITY ZI_CUSTOMER_RAP
        FIELDS ( Email )
        WITH CORRESPONDING #( keys )
      RESULT DATA(customers).

      LOOP AT customers INTO DATA(customer).
          IF customer-EMAIL IS INITIAL.
                APPEND VALUE #( %tky = customer-%tky ) TO failed-zi_customer_rap.
                APPEND VALUE #( %tky = customer-%tky
                                %msg = new_message_with_text(
                                         severity = if_abap_behv_message=>severity-error
                                         text = 'email is required' )
                                %element-firstname = if_abap_behv=>mk-on )
                  TO reported-zi_customer_rap.

           ENDIF.
        ENDLOOP.

  ENDMETHOD.

  METHOD validateNames.
  ENDMETHOD.

ENDCLASS.
