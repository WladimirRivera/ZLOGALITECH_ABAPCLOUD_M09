CLASS zcl_04_08_field_symbols DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_product,
      ref TYPE string,
      stock TYPE i,
    END OF ty_product.

ENDCLASS.

CLASS zcl_04_08_field_symbols IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA: gt_products TYPE TABLE OF ty_product.
    DATA: gs_product TYPE ty_product.
    FIELD-SYMBOLS: <fs_product> TYPE ty_product.
    FIELD-SYMBOLS: <fs_any> TYPE any.
    DATA: lv_value TYPE i VALUE 99.

    out->write( '=== BLOCK 8: FIELD SYMBOLS - Dynamic References ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Modify Table Row via Field Symbol ---' ).
    gt_products = VALUE #(
      ( ref = 'REF-500' stock = 15 )
      ( ref = 'REF-501' stock = 25 )
      ( ref = 'REF-502' stock = 10 )
    ).
    out->write( |Initial stock for REF-500: 15| ).
    out->write( ' ' ).

    READ TABLE gt_products ASSIGNING <fs_product> INDEX 1.
    IF <fs_product> IS ASSIGNED.
      out->write( |Found via ASSIGNING: { <fs_product>-ref }, Stock: { <fs_product>-stock }| ).
      <fs_product>-stock = <fs_product>-stock + 5.
      out->write( |After modification: Stock = { <fs_product>-stock }| ).
    ENDIF.
    out->write( ' ' ).

    out->write( '--- Example 2: Loop with Field Symbols ---' ).
    LOOP AT gt_products ASSIGNING <fs_product>.
      out->write( |  { <fs_product>-ref }: { <fs_product>-stock } units| ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 3: ANY Type Field Symbol ---' ).
    ASSIGN lv_value TO <fs_any>.
    IF <fs_any> IS ASSIGNED.
    <fs_any> += 1.
      out->write( |Any type symbol points to: { lv_value }| ).
    ENDIF.
    out->write( ' ' ).

    out->write( '--- Example 4: Unassign Field Symbol ---' ).
    UNASSIGN <fs_product>.
    IF <fs_product> IS NOT ASSIGNED.
      out->write( 'Field symbol unassigned (no longer points to data)' ).
    ENDIF.
    out->write( ' ' ).
    out->write( 'Conclusion: Field symbols access without copying!' ).

  ENDMETHOD.

ENDCLASS.
