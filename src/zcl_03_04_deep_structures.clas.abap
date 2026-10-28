CLASS zcl_03_04_deep_structures DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS deep_structure                IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS deep_structure_copy_semantics IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS include_type_component        IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_03_04_deep_structures IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== MODULE 2 / 3-4: DEEP STRUCTURES AND INCLUDE TYPE ===' ).
    deep_structure( out ).
    deep_structure_copy_semantics( out ).
    include_type_component( out ).
  ENDMETHOD.

  METHOD deep_structure.
    out->write( '--- Deep structure: contains a dynamic string and an internal table ---' ).

    TYPES: BEGIN OF ty_order,
             customer TYPE string,
             lines    TYPE TABLE OF string WITH EMPTY KEY,
           END OF ty_order.

    DATA ls_order TYPE ty_order.

    ls_order-customer = 'Rivas Trading Co.'.
    APPEND 'ITEM-1001 x 3' TO ls_order-lines.
    APPEND 'ITEM-2044 x 1' TO ls_order-lines.

    out->write( |Order for { ls_order-customer }, { lines( ls_order-lines ) } line(s):| ).
    out->write( ls_order-lines ).
  ENDMETHOD.

  METHOD deep_structure_copy_semantics.
    out->write( '--- Copying a deep structure copies the table CONTENT in modern ABAP ---' ).
    out->write( 'Note: unlike classic ABAP header-line tables, a plain internal table' ).
    out->write( 'component is a value, so assignment (=) makes an independent copy;' ).
    out->write( 'no shared reference remains between ls_order_1 and ls_order_2.' ).

    TYPES: BEGIN OF ty_order,
             customer TYPE string,
             lines    TYPE TABLE OF string WITH EMPTY KEY,
           END OF ty_order.

    DATA ls_order_1 TYPE ty_order.
    DATA ls_order_2 TYPE ty_order.

    ls_order_1-customer = 'Northgate Hardware'.
    APPEND 'ITEM-3300 x 5' TO ls_order_1-lines.

    ls_order_2 = ls_order_1.
    APPEND 'ITEM-4410 x 2' TO ls_order_2-lines.

    out->write( |Order 1 lines: { lines( ls_order_1-lines ) }| ).
    out->write( |Order 2 lines: { lines( ls_order_2-lines ) }| ).
  ENDMETHOD.

  METHOD include_type_component.
    out->write( '--- Reusing a structure as a named component ---' ).
    out->write( 'Note: the classic INCLUDE (a separate report-level include file) and' ).
    out->write( 'the chained "INCLUDE TYPE ... AS ..." component syntax are not accepted' ).
    out->write( 'in this ABAP Cloud language version. The always-valid, modern way to' ).
    out->write( 'reuse a structure as a substructure is a plain named component:' ).

    TYPES: BEGIN OF ty_address,
             street      TYPE string,
             city        TYPE string,
             postal_code TYPE string,
           END OF ty_address.

    TYPES: BEGIN OF ty_shipping_order,
             order_number TYPE string,
             destination  TYPE ty_address,
             order_date   TYPE d,
           END OF ty_shipping_order.

    DATA(ls_shipping_order) = VALUE ty_shipping_order(
      order_number            = 'ORD-9087'
      order_date              = sy-datum
      destination-street      = 'Av. Libertadores 245'
      destination-city        = 'Bogota'
      destination-postal_code = '110111' ).

    out->write( |Order { ls_shipping_order-order_number } ships to { ls_shipping_order-destination-city }| ).
    out->write( |Street: { ls_shipping_order-destination-street }, ZIP: { ls_shipping_order-destination-postal_code }| ).
  ENDMETHOD.

ENDCLASS.
