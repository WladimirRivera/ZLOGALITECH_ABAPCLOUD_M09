CLASS zcl_04_02_new_expression DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_04_02_new_expression IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TYPES: BEGIN OF ty_product,
      name TYPE string,
      price TYPE p LENGTH 7 DECIMALS 2,
    END OF ty_product.

    DATA: gs_product TYPE ty_product.
    DATA: gt_products TYPE TABLE OF ty_product.

    out->write( '=== BLOCK 2: NEW EXPRESSION - Object Instantiation ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Create Structure with NEW ---' ).
    gs_product = VALUE ty_product(
      name = 'Ergonomic Lamp'
      price = '24.50'
    ).
    out->write( |Created: { gs_product-name }, Price: { gs_product-price }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: Create Table with NEW Rows ---' ).
    gt_products = VALUE #(
      ( name = 'Chair' price = '129.90' )
      ( name = 'Desk' price = '249.50' )
      ( name = 'Monitor' price = '199.99' )
    ).
    out->write( |Total products: { lines( gt_products ) }| ).
    LOOP AT gt_products INTO DATA(lo_item).
      out->write( |  - { lo_item-name }: { lo_item-price }| ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 3: Modify Structure After Creation ---' ).
    gs_product = VALUE ty_product(
      name = 'Original Product'
      price = '100.00'
    ).
    out->write( |Before: { gs_product-name }, Price: { gs_product-price }| ).
    gs_product-name = 'Updated Name'.
    out->write( |After: { gs_product-name }, Price: { gs_product-price }| ).
    out->write( ' ' ).
    out->write( 'Conclusion: NEW creates objects and structures in one expression!' ).

  ENDMETHOD.

ENDCLASS.
