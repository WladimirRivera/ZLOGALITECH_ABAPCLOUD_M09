CLASS zcl_03_11_legacy_features DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

ENDCLASS.

CLASS zcl_03_11_legacy_features IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TYPES: BEGIN OF ty_customer,
      id TYPE string,
      name TYPE string,
      city TYPE string,
    END OF ty_customer.

    DATA: gt_customers TYPE TABLE OF ty_customer.
    DATA: gs_customer TYPE ty_customer.

    out->write( '=== Legacy vs Modern ABAP Features ===' ).
    out->write( ' ' ).

    out->write( '--- Setup: Customer Table ---' ).
    gt_customers = VALUE #(
      ( id = 'CUST-001' name = 'Alice' city = 'New York' )
      ( id = 'CUST-002' name = 'Bob' city = 'Boston' )
      ( id = 'CUST-003' name = 'Carol' city = 'Chicago' )
      ( id = 'CUST-004' name = 'David' city = 'Denver' )
    ).
    out->write( |Customers: { lines( gt_customers ) }| ).
    out->write( ' ' ).

    out->write( '--- Legacy: LOOP + Manual Index ---' ).
    LOOP AT gt_customers INTO gs_customer.
      IF gs_customer-city = 'Chicago'.
        out->write( |Found { gs_customer-name } (legacy loop)| ).
        EXIT.
      ENDIF.
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Modern: READ TABLE with WHERE ---' ).
    READ TABLE gt_customers INTO gs_customer WHERE city = 'Chicago'.
    IF sy-subrc = 0.
      out->write( |Found { gs_customer-name } (modern READ)| ).
    ENDIF.
    out->write( ' ' ).

    out->write( '--- Legacy: Loop + Delete ---' ).
    LOOP AT gt_customers INTO gs_customer.
      IF gs_customer-id = 'CUST-002'.
        DELETE gt_customers.
        EXIT.
      ENDIF.
    ENDLOOP.
    out->write( |Deleted via legacy method| ).
    out->write( ' ' ).

    out->write( '--- Restore Data ---' ).
    gt_customers = VALUE #(
      ( id = 'CUST-001' name = 'Alice' city = 'New York' )
      ( id = 'CUST-002' name = 'Bob' city = 'Boston' )
      ( id = 'CUST-003' name = 'Carol' city = 'Chicago' )
      ( id = 'CUST-004' name = 'David' city = 'Denver' )
    ).
    out->write( ' ' ).

    out->write( '--- Modern: DELETE with WHERE ---' ).
    DELETE gt_customers WHERE id = 'CUST-002'.
    out->write( |Deleted via modern method| ).
    out->write( |Remaining: { lines( gt_customers ) }| ).
    out->write( ' ' ).

    out->write( '--- Modern: ASSIGNING for Direct Modification ---' ).
    FIELD-SYMBOLS: <fs_cust> TYPE ty_customer.
    LOOP AT gt_customers ASSIGNING <fs_cust> WHERE city = 'New York'.
      <fs_cust>-name = 'Alice Updated'.
      out->write( |Modified (modern): { <fs_cust>-name }| ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( 'Conclusion: Modern ABAP syntax is more concise and efficient!' ).

  ENDMETHOD.

ENDCLASS.
