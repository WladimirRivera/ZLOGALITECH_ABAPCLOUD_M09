CLASS zcl_03_03_structures_nested DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS basic_structure       IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS inline_data_structure IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS nested_structure      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS reusable_substructure IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_03_03_structures_nested IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== MODULE 2 / 1: STRUCTURES - BASIC AND NESTED ===' ).
    basic_structure( out ).
    inline_data_structure( out ).
    nested_structure( out ).
    reusable_substructure( out ).
  ENDMETHOD.

  METHOD basic_structure.
    out->write( '--- Structure defined with TYPES, instantiated with DATA ---' ).

    TYPES: BEGIN OF ty_product,
             name  TYPE string,
             price TYPE p LENGTH 7 DECIMALS 2,
             stock TYPE i,
           END OF ty_product.

    DATA ls_product TYPE ty_product.

    ls_product-name  = 'Mechanical keyboard'.
    ls_product-price = '49.90'.
    ls_product-stock = 120.

    out->write( |Product: { ls_product-name }, price { ls_product-price }, stock { ls_product-stock }| ).
  ENDMETHOD.

  METHOD inline_data_structure.
    out->write( '--- Structure declared directly with DATA (no separate TYPES) ---' ).

    DATA: BEGIN OF ls_product,
            name  TYPE string,
            price TYPE p LENGTH 7 DECIMALS 2,
            stock TYPE i,
          END OF ls_product.

    ls_product-name  = 'USB-C Hub'.
    ls_product-price = '25.50'.
    ls_product-stock = 60.

    ls_product = VALUE #( name = 'USB-v Hub'
                          price = '100'
                          stock = '10' ).

    out->write( |Product: { ls_product-name }, price { ls_product-price }, stock { ls_product-price }| ).
  ENDMETHOD.

  METHOD nested_structure.
    out->write( '--- Nested structure: product with a manufacturer substructure ---' ).

    TYPES: BEGIN OF ty_manufacturer,
             company_name TYPE string,
             country      TYPE string,
             contact      TYPE string,
           END OF ty_manufacturer.

    TYPES: BEGIN OF ty_product,
             name         TYPE string,
             price        TYPE p LENGTH 7 DECIMALS 2,
             stock        TYPE i,
             manufacturer TYPE ty_manufacturer,
           END OF ty_product.

    DATA ls_product TYPE ty_product.

    ls_product-name                      = '27-inch Monitor'.
    ls_product-price                     = '219.00'.
    ls_product-stock                     = 45.
    ls_product-manufacturer-company_name = 'Northern Displays Ltd.'.
    ls_product-manufacturer-country      = 'Germany'.
    ls_product-manufacturer-contact      = 'sales@northerndisplays.com'.

    out->write( |{ ls_product-name } made by { ls_product-manufacturer-company_name } ({ ls_product-manufacturer-country })| ).
  ENDMETHOD.

  METHOD reusable_substructure.
    out->write( '--- Reusable substructure defined independently with TYPES ---' ).

    TYPES: BEGIN OF ty_manufacturer,
             company_name TYPE string,
             country      TYPE string,
             contact      TYPE string,
           END OF ty_manufacturer.

    TYPES: BEGIN OF ty_product,
             name         TYPE string,
             price        TYPE p LENGTH 7 DECIMALS 2,
             stock        TYPE i,
             manufacturer TYPE ty_manufacturer,
           END OF ty_product.

    DATA(ls_product) = VALUE ty_product(
      name  = 'Wireless Mouse'
      price = '15.99'
      stock = 300
      manufacturer = VALUE #( company_name = 'ClickWorks Inc.' country = 'USA' contact = 'support@clickworks.com' ) ).

    out->write( |{ ls_product-name } - manufacturer: { ls_product-manufacturer-company_name }| ).
  ENDMETHOD.

ENDCLASS.
