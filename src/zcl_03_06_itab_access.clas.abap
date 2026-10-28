CLASS zcl_03_06_itab_access DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS work_area_vs_field_symbol IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS describe_table_attrs      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS read_table_variants       IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_03_06_itab_access IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== MODULE 3 / 12-13, 17, 11: ACCESSING SINGLE ROWS ===' ).
    work_area_vs_field_symbol( out ).
    describe_table_attrs( out ).
    read_table_variants( out ).
  ENDMETHOD.

  METHOD work_area_vs_field_symbol.
    out->write( '--- Work area vs field symbol access ---' ).

    TYPES: BEGIN OF ty_reservation,
             month TYPE i,
             day   TYPE i,
           END OF ty_reservation.

    DATA lt_reservations TYPE SORTED TABLE OF ty_reservation WITH UNIQUE KEY month.
    DATA ls_reservation  TYPE ty_reservation.

    DO 4 TIMES.
      ls_reservation-month = sy-index.
      ls_reservation-day   = sy-index.
      INSERT ls_reservation INTO TABLE lt_reservations.
    ENDDO.

    FIELD-SYMBOLS <fs_reservation> LIKE LINE OF lt_reservations.

    READ TABLE lt_reservations WITH TABLE KEY month = 2 ASSIGNING <fs_reservation>.
    IF <fs_reservation> IS ASSIGNED.
      out->write( |Assigned via field symbol: month { <fs_reservation>-month }, day { <fs_reservation>-day }| ).
    ENDIF.

    DELETE lt_reservations INDEX 2.

    out->write( 'Remaining rows (looped with a field symbol):' ).
    LOOP AT lt_reservations ASSIGNING <fs_reservation>.
      out->write( |month { <fs_reservation>-month }, day { <fs_reservation>-day }| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD describe_table_attrs.
    out->write( '--- DESCRIBE TABLE is classic ABAP and not allowed in ABAP Cloud ---' ).
    out->write( 'The modern equivalent for the line count is the built-in function lines( ).' ).
    out->write( 'To inspect a table''s kind (standard/sorted/hashed) programmatically,' ).
    out->write( 'use RTTI via cl_abap_tabledescr instead of DESCRIBE TABLE ... KIND.' ).

    DATA lt_numbers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    lt_numbers = VALUE #( ( 1 ) ( 2 ) ( 3 ) ( 4 ) ).

    out->write( |lines( lt_numbers ) -> { lines( lt_numbers ) }| ).

    DATA(lo_table_descr) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( lt_numbers ) ).
    out->write( |Table kind via RTTI: { lo_table_descr->table_kind }| ).
  ENDMETHOD.

  METHOD read_table_variants.
    out->write( '--- READ TABLE: key, binary search, dynamic key, INTO, TRANSPORTING ---' ).

    TYPES: BEGIN OF ty_article,
             reference TYPE string,
             quantity  TYPE i,
           END OF ty_article.

    DATA lt_articles TYPE STANDARD TABLE OF ty_article WITH NON-UNIQUE KEY reference.

    lt_articles = VALUE #( ( reference = 'REF-001' quantity = 10 )
                            ( reference = 'REF-002' quantity = 5 )
                            ( reference = 'REF-003' quantity = 20 ) ).

    READ TABLE lt_articles INTO DATA(ls_by_key) WITH KEY reference = 'REF-002'.
    out->write( |By key: reference { ls_by_key-reference }, quantity { ls_by_key-quantity }, sy-subrc { sy-subrc }| ).

    SORT lt_articles BY reference.
    READ TABLE lt_articles INTO DATA(ls_binary) WITH KEY reference = 'REF-003' BINARY SEARCH.
    out->write( |Binary search: reference { ls_binary-reference }, sy-tabix { sy-tabix }| ).

    DATA(lv_field_name) = 'REFERENCE'.
    READ TABLE lt_articles INTO DATA(ls_dynamic) WITH KEY (lv_field_name) = 'REF-001'.
    out->write( |Dynamic key field '{ lv_field_name }': reference { ls_dynamic-reference }| ).

    READ TABLE lt_articles TRANSPORTING NO FIELDS WITH KEY reference = 'REF-002'.
    out->write( |TRANSPORTING NO FIELDS: sy-subrc { sy-subrc }, sy-tabix { sy-tabix }| ).
  ENDMETHOD.

ENDCLASS.
