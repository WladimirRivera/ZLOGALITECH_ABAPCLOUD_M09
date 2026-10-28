CLASS zcl_03_09_read_table_modern DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_03_09_read_table_modern IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    TYPES: BEGIN OF ty_order,
      order_id TYPE string,
      customer TYPE string,
      amount TYPE i,
    END OF ty_order.

    DATA gt_orders TYPE TABLE OF ty_order WITH EMPTY KEY.

    out->write( '=== Table Expressions - Modern Access Patterns ===' ).
    out->write( ' ' ).

    gt_orders = VALUE #(
      ( order_id = 'ORD-001' customer = 'Alice' amount = 500 )
      ( order_id = 'ORD-002' customer = 'Bob' amount = 1200 )
      ( order_id = 'ORD-003' customer = 'Carol' amount = 800 )
      ( order_id = 'ORD-004' customer = 'David' amount = 350 )
    ).

    out->write( 'Example 1: Direct Row Access by Key (with OPTIONAL)' ).
    DATA(ls_order) = VALUE #( gt_orders[ order_id = 'ORD-002' ] OPTIONAL ).
    IF ls_order IS NOT INITIAL.
      out->write( |Order: { ls_order-order_id }, Customer: { ls_order-customer }| ).
    ENDIF.
    out->write( ' ' ).

    out->write( 'Example 2: Access Single Field from Key' ).
    DATA(lv_customer) = gt_orders[ order_id = 'ORD-003' ]-customer.
    out->write( |ORD-003 Customer: { lv_customer }| ).
    out->write( ' ' ).

    out->write( 'Example 3: Safe Access with LINE_EXISTS' ).
    IF line_exists( gt_orders[ order_id = 'ORD-004' ] ).
      DATA(lv_amount) = gt_orders[ order_id = 'ORD-004' ]-amount.
      out->write( |ORD-004 Amount: { lv_amount }| ).
    ELSE.
      out->write( |Order not found| ).
    ENDIF.
    out->write( ' ' ).

    out->write( 'Example 4: Reference to Table Line' ).
    DATA(lr_order) = REF #( gt_orders[ order_id = 'ORD-001' ] ).
    out->write( |Via reference: { lr_order->customer }| ).
    out->write( ' ' ).

    out->write( 'Table Expressions provide clean, modern access!' ).

  ENDMETHOD.
ENDCLASS.
