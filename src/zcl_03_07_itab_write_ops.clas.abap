CLASS zcl_03_07_itab_write_ops DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS append_variants     IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS insert_variants     IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS collect_rows        IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS modify_variants     IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS delete_variants     IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS find_replace_search IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_03_07_itab_write_ops IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== MODULE 3 / 14-16, 19-21: WRITING TO INTERNAL TABLES ===' ).
    append_variants( out ).
    insert_variants( out ).
    collect_rows( out ).
    modify_variants( out ).
    delete_variants( out ).
    find_replace_search( out ).
  ENDMETHOD.

  METHOD append_variants.
    out->write( '--- APPEND: single row and APPEND LINES OF ---' ).

    TYPES: BEGIN OF ty_article,
             reference TYPE string,
             quantity  TYPE i,
           END OF ty_article.

    DATA lt_articles     TYPE STANDARD TABLE OF ty_article WITH EMPTY KEY.
    DATA lt_new_articles TYPE STANDARD TABLE OF ty_article WITH EMPTY KEY.

    APPEND VALUE #( reference = 'REF-001' quantity = 10 ) TO lt_articles.

    lt_new_articles = VALUE #( ( reference = 'REF-002' quantity = 5 )
                                ( reference = 'REF-003' quantity = 8 ) ).
    APPEND LINES OF lt_new_articles TO lt_articles.

    out->write( |After APPEND and APPEND LINES OF: { lines( lt_articles ) } row(s)| ).
    out->write( lt_articles ).
  ENDMETHOD.

  METHOD insert_variants.
    out->write( '--- INSERT: at a given index, INITIAL LINE, INTO a hashed table ---' ).

    TYPES: BEGIN OF ty_article,
             reference TYPE string,
             quantity  TYPE i,
           END OF ty_article.

    DATA lt_articles TYPE STANDARD TABLE OF ty_article WITH EMPTY KEY.
    lt_articles = VALUE #( ( reference = 'REF-001' quantity = 10 )
                            ( reference = 'REF-003' quantity = 8 ) ).

    INSERT VALUE #( reference = 'REF-002' quantity = 5 ) INTO lt_articles INDEX 2.
    out->write( 'After INSERT at index 2:' ).
    out->write( lt_articles ).

    INSERT INITIAL LINE INTO lt_articles INDEX 1.
    out->write( |After INSERT INITIAL LINE, rows: { lines( lt_articles ) }| ).

    DATA lt_articles_hashed TYPE HASHED TABLE OF ty_article WITH UNIQUE KEY reference.
    INSERT VALUE #( reference = 'REF-010' quantity = 1 ) INTO TABLE lt_articles_hashed.
    out->write( |Hashed table row count after INSERT INTO TABLE: { lines( lt_articles_hashed ) }| ).
  ENDMETHOD.

  METHOD collect_rows.
    out->write( '--- COLLECT: aggregates numeric fields for matching keys ---' ).

    TYPES: BEGIN OF ty_sale,
             zone    TYPE c LENGTH 1,
             channel TYPE c LENGTH 1,
             units   TYPE i,
           END OF ty_sale.

    DATA lt_sales TYPE SORTED TABLE OF ty_sale WITH NON-UNIQUE KEY zone channel.
    DATA ls_sale  TYPE ty_sale.

    ls_sale-zone = 'N'. ls_sale-channel = 'W'. ls_sale-units = 1.
    COLLECT ls_sale INTO lt_sales.

    ls_sale-zone = 'N'. ls_sale-channel = 'W'. ls_sale-units = 1.
    COLLECT ls_sale INTO lt_sales.

    READ TABLE lt_sales INTO ls_sale INDEX 1.
    out->write( |After two COLLECT calls with the same key, units = { ls_sale-units }| ).
  ENDMETHOD.

  METHOD modify_variants.
    out->write( '--- MODIFY: by index, by key (TRANSPORTING), by WHERE condition ---' ).

    TYPES: BEGIN OF ty_article,
             reference TYPE string,
             quantity  TYPE i,
           END OF ty_article.

    DATA lt_articles TYPE STANDARD TABLE OF ty_article WITH NON-UNIQUE KEY reference.
    lt_articles = VALUE #( ( reference = 'REF-001' quantity = 10 )
                            ( reference = 'REF-002' quantity = 5 )
                            ( reference = 'REF-003' quantity = 8 ) ).

    MODIFY lt_articles FROM VALUE ty_article( reference = 'REF-999' quantity = 99 ) INDEX 1.
    out->write( 'After MODIFY by index 1:' ).
    out->write( lt_articles ).

    MODIFY TABLE lt_articles FROM VALUE ty_article( reference = 'REF-002' quantity = 55 ) TRANSPORTING quantity.
    out->write( 'After MODIFY TABLE ... TRANSPORTING quantity (matched by key):' ).
    out->write( lt_articles ).

    MODIFY lt_articles FROM VALUE ty_article( quantity = 0 ) TRANSPORTING quantity WHERE quantity < 10.
    out->write( 'After MODIFY ... WHERE quantity < 10:' ).
    out->write( lt_articles ).
  ENDMETHOD.

  METHOD delete_variants.
    out->write( '--- DELETE: by key, by WHERE, adjacent duplicates ---' ).

    TYPES: BEGIN OF ty_article,
             reference TYPE string,
             quantity  TYPE i,
           END OF ty_article.

    DATA lt_articles TYPE STANDARD TABLE OF ty_article WITH NON-UNIQUE KEY reference.
    lt_articles = VALUE #( ( reference = 'REF-001' quantity = 10 )
                            ( reference = 'REF-002' quantity = 0 )
                            ( reference = 'REF-003' quantity = 8 )
                            ( reference = 'REF-003' quantity = 8 ) ).

    DELETE TABLE lt_articles WITH TABLE KEY reference = 'REF-001'.
    out->write( |After DELETE TABLE ... WITH TABLE KEY: { lines( lt_articles ) } row(s)| ).

    DELETE lt_articles WHERE quantity = 0.
    out->write( |After DELETE ... WHERE quantity = 0: { lines( lt_articles ) } row(s)| ).

    SORT lt_articles BY reference.
    DELETE ADJACENT DUPLICATES FROM lt_articles COMPARING reference.
    out->write( |After DELETE ADJACENT DUPLICATES: { lines( lt_articles ) } row(s)| ).
    out->write( lt_articles ).
  ENDMETHOD.

  METHOD find_replace_search.
    out->write( '--- FIND / REPLACE IN TABLE ---' ).
    out->write( 'Note: the classic SEARCH tabla FOR ''text'' statement is obsolete and' ).
    out->write( 'superseded by FIND; it is not demonstrated here.' ).

    DATA lt_notes TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    lt_notes = VALUE #( ( `Customer requested urgent delivery` )
                        ( `Urgent: missing signature on invoice` )
                        ( `No further action needed` ) ).

    FIND FIRST OCCURRENCE OF 'urgent' IN TABLE lt_notes IGNORING CASE.
    out->write( |FIND FIRST OCCURRENCE 'urgent' -> sy-subrc { sy-subrc }, sy-tabix { sy-tabix }| ).

    DATA(lv_match_count) = 0.
    FIND ALL OCCURRENCES OF 'urgent' IN TABLE lt_notes IGNORING CASE MATCH COUNT lv_match_count.
    out->write( |FIND ALL OCCURRENCES 'urgent' -> { lv_match_count } match(es)| ).

    REPLACE ALL OCCURRENCES OF 'Urgent' IN TABLE lt_notes WITH 'Priority'.
    out->write( 'After REPLACE ALL OCCURRENCES:' ).
    out->write( lt_notes ).
  ENDMETHOD.

ENDCLASS.
