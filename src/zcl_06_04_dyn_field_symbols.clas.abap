CLASS zcl_06_04_dyn_field_symbols DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_date_parts,
        year  TYPE n LENGTH 4,
        month TYPE n LENGTH 2,
        day   TYPE n LENGTH 2,
      END OF ty_date_parts.

ENDCLASS.


CLASS zcl_06_04_dyn_field_symbols IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    FIELD-SYMBOLS <lv_any>    TYPE any.
    FIELD-SYMBOLS <ls_any>    TYPE any.
    FIELD-SYMBOLS <lt_any>    TYPE ANY TABLE.
    FIELD-SYMBOLS <lv_field>  TYPE any.
    FIELD-SYMBOLS <ls_date>   TYPE ty_date_parts.

    SELECT FROM /dmo/connection
      FIELDS *
      ORDER BY carrier_id, connection_id
      INTO TABLE @DATA(lt_connections)
      UP TO 3 ROWS.

    out->write( '=== CLASS 6.04: DYNAMIC PROGRAMMING - FIELD SYMBOLS ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: One generic field symbol, different types ---' ).
    DATA(lv_counter) = 42.
    DATA(lv_text)    = `ABAP Cloud`.
    DATA(ls_first)   = lt_connections[ 1 ].

    ASSIGN lv_counter TO <lv_any>.
    out->write( |<LV_ANY> -> { cl_abap_typedescr=>describe_by_data( <lv_any> )->absolute_name } = { <lv_any> }| ).
    ASSIGN lv_text TO <lv_any>.
    out->write( |<LV_ANY> -> { cl_abap_typedescr=>describe_by_data( <lv_any> )->absolute_name } = { <lv_any> }| ).
    ASSIGN ls_first TO <lv_any>.
    out->write( |<LV_ANY> -> { cl_abap_typedescr=>describe_by_data( <lv_any> )->absolute_name }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: ASSIGN COMPONENT by name ---' ).
    DATA(lt_field_names) = VALUE string_table( ( `AIRPORT_FROM_ID` ) ( `AIRPORT_TO_ID` ) ( `DISTANCE` ) ).
    LOOP AT lt_connections ASSIGNING <ls_any>.
      DATA(lv_line) = ``.
      LOOP AT lt_field_names INTO DATA(lv_field_name).
        ASSIGN COMPONENT lv_field_name OF STRUCTURE <ls_any> TO <lv_field>.
        IF sy-subrc = 0.
          lv_line = |{ lv_line }{ lv_field_name }={ <lv_field> }  |.
        ENDIF.
      ENDLOOP.
      out->write( lv_line ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 3: ASSIGN COMPONENT by position + names from RTTS ---' ).
    DATA(lo_structure) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_first ) ).
    DATA(lv_position) = 0.
    LOOP AT lo_structure->components INTO DATA(ls_component).
      lv_position += 1.
      ASSIGN COMPONENT lv_position OF STRUCTURE ls_first TO <lv_field>.
      out->write( |{ lv_position WIDTH = 3 } { ls_component-name WIDTH = 20 } { <lv_field> }| ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 4: Generic table field symbol (TYPE ANY TABLE) ---' ).
    ASSIGN lt_connections TO <lt_any>.
    DATA(lv_long_routes) = 0.
    LOOP AT <lt_any> ASSIGNING <ls_any>.
      ASSIGN COMPONENT 'DISTANCE' OF STRUCTURE <ls_any> TO <lv_field>.
      IF sy-subrc = 0 AND <lv_field> > 1000.
        lv_long_routes += 1.
      ENDIF.
    ENDLOOP.
    out->write( |Rows: { lines( <lt_any> ) }, distance > 1000: { lv_long_routes }| ).
    out->write( ' ' ).

    out->write( '--- Example 5: CASTING - view the same memory with another type ---' ).
    SELECT SINGLE FROM /dmo/flight
      FIELDS flight_date
      INTO @DATA(lv_flight_date).
    ASSIGN lv_flight_date TO <ls_date> CASTING.
    out->write( |Flight date { lv_flight_date } -> year { <ls_date>-year }, month { <ls_date>-month }, day { <ls_date>-day }| ).
    out->write( ' ' ).

    out->write( '--- Example 6: Always check sy-subrc after a dynamic ASSIGN ---' ).
    ASSIGN COMPONENT 'CARRIER_ID' OF STRUCTURE ls_first TO <lv_field>.
    ASSIGN COMPONENT 'NOT_EXISTING_FIELD' OF STRUCTURE ls_first TO <lv_field>.
    out->write( |sy-subrc = { sy-subrc }, <lv_field> = '{ <lv_field> }'| ).
  ENDMETHOD.

ENDCLASS.

