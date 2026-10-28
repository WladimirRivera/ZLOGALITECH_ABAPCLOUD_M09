CLASS zcl_03_01_conditionals DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS if_elseif_else    IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS check_statement   IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS case_when         IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS cond_expression   IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS switch_expression IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS boolean_functions IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_03_01_conditionals IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== MODULE 1 / 2: IF, CASE, COND, SWITCH, BOOLEAN FUNCTIONS ===' ).
    if_elseif_else( out ).
    check_statement( out ).
    case_when( out ).
    cond_expression( out ).
    switch_expression( out ).
    boolean_functions( out ).
  ENDMETHOD.

  METHOD if_elseif_else.
    out->write( '--- IF / ELSEIF / ELSE ---' ).
    DATA(lv_stock) = 12.
    IF lv_stock = 0.
      out->write( 'Product out of stock' ).
    ELSEIF lv_stock < 5.
      out->write( 'Low stock, reorder soon' ).
    ELSE.
      out->write( |Stock available: { lv_stock }| ).
    ENDIF.
  ENDMETHOD.

  METHOD check_statement.
    out->write( '--- CHECK inside a LOOP: skip rows that do not match ---' ).
    DATA lt_quantities TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    lt_quantities = VALUE #( ( 0 ) ( 5 ) ( -2 ) ( 8 ) ).
    LOOP AT lt_quantities INTO DATA(lv_qty).
      CHECK lv_qty > 0.
      out->write( |Valid quantity: { lv_qty }| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD case_when.
    out->write( '--- CASE / WHEN / WHEN OTHERS ---' ).
    DATA(lv_order_status) = 'P'.

    CASE lv_order_status.
      WHEN 'P'.
        out->write( 'Order pending' ).
      WHEN 'S' OR 'T'.
        out->write( 'Order shipped' ).
      WHEN OTHERS.
        out->write( 'Unknown status' ).
    ENDCASE.
  ENDMETHOD.

  METHOD cond_expression.
    out->write( '--- COND: conditional expression ---' ).
    DATA(lv_stock) = 3.
    DATA(lv_category) = COND string( WHEN lv_stock = 0 THEN 'Out of stock'
                                      WHEN lv_stock < 5 THEN 'Critical stock'
                                      ELSE                   'Normal stock' ).
    out->write( |Stock category: { lv_category }| ).
  ENDMETHOD.

  METHOD switch_expression.
    out->write( '--- SWITCH: conditional expression by case distinction ---' ).
    DATA(lv_order_status) = 'S'.
    DATA(lv_status_text) = SWITCH string( lv_order_status
                                          WHEN 'P' THEN 'Pending'
                                          WHEN 'S' THEN 'Shipped'
                                          WHEN 'D' THEN 'Delivered'
                                          ELSE          'Unknown' ).
    out->write( |Status text: { lv_status_text }| ).
  ENDMETHOD.

  METHOD boolean_functions.
    out->write( '--- BOOLC and XSDBOOL: convert a logical expression to X / space ---' ).
    DATA(lv_stock) = 10.

    DATA(lv_boolc_result) = boolc( lv_stock > 0 ).
    out->write( |boolc( stock > 0 ), technical type STRING -> '{ lv_boolc_result }'| ).

    DATA(lv_xsdbool_result) = xsdbool( lv_stock > 0 ).
    out->write( |xsdbool( stock > 0 ), technical type C(1) -> '{ lv_xsdbool_result }'| ).

    DATA(lv_active) = xsdbool( lv_stock > 0 ).
    IF lv_active = abap_true.
      out->write( 'The product is active for sale' ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
