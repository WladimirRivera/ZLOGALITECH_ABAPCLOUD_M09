CLASS zcl_04_01_value_expression DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_product,
      name TYPE string,
      price TYPE p LENGTH 7 DECIMALS 2,
      stock TYPE i,
    END OF ty_product.

    TYPES: BEGIN OF ty_order_line,
      article TYPE string,
      date TYPE d,
      qty TYPE i,
    END OF ty_order_line.

ENDCLASS.

CLASS zcl_04_01_value_expression IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA: gs_product TYPE ty_product.
    DATA: gt_lines TYPE TABLE OF ty_order_line.
    DATA: gt_products TYPE TABLE OF ty_product.
    DATA: lv_total_value TYPE p LENGTH 10 DECIMALS 2 VALUE 0.

    out->write( '=== BLOCK 1: VALUE EXPRESSION - Practical Examples ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Initialize a Structure with VALUE ---' ).
    gs_product = VALUE ty_product(
      name = 'Ergonomic Chair'
      price = '129.90'
      stock = 40
    ).
    out->write( |Product: { gs_product-name }, Price: { gs_product-price }, Stock: { gs_product-stock }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: Initialize Internal Table with VALUE ---' ).
    gt_lines = VALUE #(
      ( article = 'ART-001' date = '20261015' qty = 5 )
      ( article = 'ART-002' date = '20261016' qty = 3 )
      ( article = 'ART-003' date = '20261017' qty = 8 )
    ).
    out->write( |Total lines in table: { lines( gt_lines ) }| ).
    LOOP AT gt_lines INTO DATA(ls_line).
      out->write( |  Line: { ls_line-article }, Date: { ls_line-date }, Qty: { ls_line-qty }| ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 3: Build Complex Table with VALUE ---' ).
    gt_products = VALUE #(
      ( name = 'Desk' price = '249.50' stock = 10 )
      ( name = 'Chair' price = '129.90' stock = 40 )
      ( name = 'Lamp' price = '49.99' stock = 25 )
    ).
    out->write( |Total products: { lines( gt_products ) }| ).
    lv_total_value = 0.
    LOOP AT gt_products INTO gs_product.
      lv_total_value = lv_total_value + ( gs_product-price * gs_product-stock ).
      out->write( |  { gs_product-name }: { gs_product-price } x { gs_product-stock }| ).
    ENDLOOP.
    out->write( |Total Inventory Value: { lv_total_value }| ).
    out->write( ' ' ).
    out->write( 'Conclusion: VALUE expressions make code compact and readable!' ).

  ENDMETHOD.

ENDCLASS.
