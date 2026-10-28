CLASS zcl_04_04_ref_expression DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_item,
      id TYPE i,
      name TYPE string,
    END OF ty_item.

ENDCLASS.

CLASS zcl_04_04_ref_expression IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA: lv_stock TYPE i.
    DATA: lv_ref_stock TYPE REF TO i.
    DATA: gs_item TYPE ty_item.
    DATA: lr_item TYPE REF TO ty_item.

    out->write( '=== BLOCK 4: REF EXPRESSION - Data References ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Reference to Simple Variable ---' ).
    lv_stock = 75.
    lv_ref_stock = REF #( lv_stock ).
    out->write( |Original value: { lv_stock }| ).
    out->write( |Via reference: { lv_ref_stock->* }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: Modify via Reference ---' ).
    lv_ref_stock->* = 100.
    out->write( |After modification via reference: { lv_stock }| ).
    out->write( |Reference points to same memory!| ).
    out->write( ' ' ).

    out->write( '--- Example 3: Reference to Structure ---' ).
    gs_item = VALUE ty_item( id = 1 name = 'Widget' ).
    lr_item = REF #( gs_item ).
    out->write( |Structure: ID={ gs_item-id }, Name={ gs_item-name }| ).
    out->write( |Via reference: ID={ lr_item->id }, Name={ lr_item->name }| ).
    out->write( ' ' ).

    out->write( '--- Example 4: Modify Structure via Reference ---' ).
    lr_item->name = 'Updated Widget'.
    out->write( |After modification: { gs_item-name }| ).
    out->write( 'Reference changes affect original data!' ).
    out->write( ' ' ).
    out->write( 'Conclusion: REF creates pointers without copying!' ).

  ENDMETHOD.

ENDCLASS.
