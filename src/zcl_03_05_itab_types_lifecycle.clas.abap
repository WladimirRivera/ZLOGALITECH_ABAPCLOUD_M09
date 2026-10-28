CLASS zcl_03_05_itab_types_lifecycle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
*    METHODS table_types_and_keys  IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
*-    METHODS lifecycle_and_compare IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS sort_variants         IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_03_05_itab_types_lifecycle IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== MODULE 3 / 1-9: INTERNAL TABLE TYPES, KEYS AND LIFECYCLE ===' ).
*    table_types_and_keys( out ).
*    lifecycle_and_compare( out ).
    sort_variants( out ).
  ENDMETHOD.



  METHOD sort_variants.
    out->write( '--- SORT: BY one field, DESCENDING, dynamic field name ---' ).

    TYPES: BEGIN OF ty_article,
             reference TYPE string,
             quantity  TYPE i,
           END OF ty_article.

    DATA lt_articles TYPE STANDARD TABLE OF ty_article WITH EMPTY KEY.

    lt_articles = VALUE #( ( reference = 'REF-003' quantity = 7 )
                            ( reference = 'REF-001' quantity = 20 )
                            ( reference = 'REF-002' quantity = 3 ) ).

    " 1. Ordenar por reference ascendente
    SORT lt_articles BY reference ASCENDING.
    out->write( 'Sorted by reference ascending:' ).
    LOOP AT lt_articles INTO DATA(ls_article).
      out->write( |  Ref: { ls_article-reference }  Qty: { ls_article-quantity }| ).
    ENDLOOP.

    " 2. Ordenar por quantity descendente
    SORT lt_articles BY quantity DESCENDING.
    out->write( 'Sorted by quantity descending:' ).
    LOOP AT lt_articles INTO ls_article.
      out->write( |  Ref: { ls_article-reference }  Qty: { ls_article-quantity }| ).
    ENDLOOP.

    " 3. Ordenación dinámica
    DATA lv_dynamic_field TYPE string VALUE 'REFERENCE'.
    SORT lt_articles BY (lv_dynamic_field).
    out->write( |Sorted dynamically by field '{ lv_dynamic_field }':| ).
    LOOP AT lt_articles INTO ls_article.
      out->write( |  Ref: { ls_article-reference }  Qty: { ls_article-quantity }| ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
