CLASS zcl_03_09_read_table DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_03_09_read_table IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    TYPES: BEGIN OF ty_product,
             ref   TYPE string,
             stock TYPE i,
             price TYPE p LENGTH 7 DECIMALS 2,
           END OF ty_product.

    DATA: gt_products TYPE TABLE OF ty_product WITH EMPTY KEY,
          gt_products2 TYPE TABLE OF ty_product WITH EMPTY KEY.

    DATA gs_product TYPE ty_product.


*
*    out->write( '=== Table Expressions (ABAP 7.40+) ===' ).
    out->write( ' ' ).
*
    gt_products = VALUE #(
      ( ref = 'ART-001' stock = 10 price = '50.00' )
      ( ref = 'ART-002' stock = 25 price = '75.50' )
      ( ref = 'ART-003' stock = 15 price = '99.99' )
      ( ref = 'ART-004' stock = 30 price = '120.00' )
      ( ref = 'ART-005' stock = 5 price = '200.00' )
    ).

gt_products2 = VALUE #( FOR item IN gt_products
                              WHERE ( ref = 'ART-001' )
                              ( ref   = item-ref
                                stock = item-stock
                                price = item-price ) ).

    out->write( gt_products2 ).
*
*    out->write( |Products loaded: { lines( gt_products ) }| ).
*    out->write( '--- Example 1: Index Access ---' ).
*
**    FREE gt_products.
*
*    TRY.
*        gs_product = gt_products[ 2 ].
*        out->write( |Index 2: { gs_product-ref }, Stock={ gs_product-stock }| ).
*        READ TABLE gt_products INTO DATA(ls_product) INDEX 2.
*        IF sy-subrc EQ 0.
*          out->write( |Index 2: { ls_product-ref }, Stock={ ls_product-stock }| ).
*        ENDIF.
*      CATCH  CX_SY_ITAB_LINE_NOT_FOUND INTO DATA(cx).
*        out->write( cx->get_text( ) ).
*    ENDTRY.
*
*    out->write( '--- Example 2: Key Access with OPTIONAL (safe) ---' ).
*    gs_product = VALUE #( gt_products[ ref = 'ART-003' ] OPTIONAL ).
*    IF gs_product IS NOT INITIAL.
*      out->write( |Found ART-003: Stock={ gs_product-stock }, Price={ gs_product-price }| ).
*    ENDIF.
*    out->write( ' ' ).
*
*    out->write( '--- Example 3: Access Single Field ---' ).
*    DATA(lv_stock) = gt_products[ ref = 'ART-001' ]-stock.
*    out->write( |Stock of ART-001: { lv_stock }| ).
*    out->write( ' ' ).
*
*    out->write( '--- Example 4: LINE_EXISTS to Check Before Access ---' ).
*    IF line_exists( gt_products[ ref = 'ART-005' ] ).
*      DATA(lv_price) = gt_products[ ref = 'ART-005' ]-price.
*      out->write( |ART-005 exists, Price: { lv_price }| ).
*    ENDIF.
*    out->write( ' ' ).
*
*    out->write( '--- Example 5: DEFAULT Value if Not Found ---' ).
*    gs_product = VALUE #( gt_products[ ref = 'UNKNOWN' ] DEFAULT VALUE #( ref = 'N/A' stock = 0 ) ).
*    out->write( |Result: { gs_product-ref }, Stock={ gs_product-stock }| ).

  ENDMETHOD.
ENDCLASS.
