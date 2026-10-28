CLASS zcl_06_07_dynamic_assign DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    CONSTANTS gc_default_country TYPE land1 VALUE 'DE'.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_query,
        table_name TYPE string,
        fields     TYPE string,
        where      TYPE string,
      END OF ty_query,
      tt_queries TYPE STANDARD TABLE OF ty_query WITH EMPTY KEY.

    DATA mv_carrier_id TYPE /dmo/carrier_id VALUE 'LH'.
    DATA mv_max_rows   TYPE i VALUE 3.

    METHODS run_dynamic_query
      IMPORTING is_query TYPE ty_query
                io_out   TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.


CLASS zcl_06_07_dynamic_assign IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    FIELD-SYMBOLS <lv_value> TYPE any.

    out->write( '=== CLASS 6.07: DYNAMIC PROGRAMMING - DYNAMIC ASSIGN AND DYNAMIC SQL ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: ASSIGN an attribute whose name is in a variable ---' ).
    DATA(lt_attribute_names) = VALUE string_table( ( `MV_CARRIER_ID` ) ( `MV_MAX_ROWS` ) ( `MV_UNKNOWN` ) ).
    LOOP AT lt_attribute_names INTO DATA(lv_attribute).
      ASSIGN me->(lv_attribute) TO <lv_value>.
      IF sy-subrc = 0.
        out->write( |me->{ lv_attribute } = { <lv_value> }| ).
      ELSE.
        out->write( |me->{ lv_attribute }: sy-subrc = { sy-subrc }| ).
      ENDIF.
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 2: ASSIGN a static attribute: (class)=>(attribute) ---' ).
    DATA(lv_class_name)       = `ZCL_06_07_DYNAMIC_ASSIGN`.
    DATA(lv_static_attribute) = `GC_DEFAULT_COUNTRY`.
    ASSIGN (lv_class_name)=>(lv_static_attribute) TO <lv_value>.
    IF sy-subrc = 0.
      out->write( |{ lv_class_name }=>{ lv_static_attribute } = { <lv_value> }| ).
    ENDIF.
    out->write( ' ' ).

    out->write( '--- Example 3: ASSIGN a structure component with struc-(name) ---' ).
    SELECT SINGLE FROM /dmo/airport
      FIELDS *
      WHERE airport_id = 'FRA'
      INTO @DATA(ls_airport).
    DATA(lt_components) = VALUE string_table( ( `AIRPORT_ID` ) ( `NAME` ) ( `CITY` ) ( `COUNTRY` ) ).
    LOOP AT lt_components INTO DATA(lv_component).
      ASSIGN ls_airport-(lv_component) TO <lv_value>.
      IF sy-subrc = 0.
        out->write( |ls_airport-{ lv_component WIDTH = 12 } = { <lv_value> }| ).
      ENDIF.
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 4: Dynamic SELECT - table, fields and WHERE in variables ---' ).
    DATA(lt_queries) = VALUE tt_queries(
      ( table_name = `/DMO/AIRPORT`    fields = `AIRPORT_ID, NAME, CITY`                  where = |COUNTRY = '{ gc_default_country }'| )
      ( table_name = `/DMO/CONNECTION` fields = `CARRIER_ID, CONNECTION_ID, AIRPORT_TO_ID` where = `AIRPORT_FROM_ID = 'FRA'` )
      ( table_name = `/DMO/CUSTOMER`   fields = `CUSTOMER_ID, LAST_NAME, CITY`            where = `COUNTRY_CODE = 'AT'` ) ).
    LOOP AT lt_queries INTO DATA(ls_query).
      run_dynamic_query( is_query = ls_query io_out = out ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 5: Protecting dynamic SQL ---' ).
    run_dynamic_query( is_query = VALUE #( table_name = `/DMO/TRAVEL` fields = `*` where = `1 = 1` ) io_out = out ).
    run_dynamic_query( is_query = VALUE #( table_name = `/DMO/AIRPORT` fields = `AIRPORT_ID` where = `NOT_A_FIELD = 'X'` ) io_out = out ).
  ENDMETHOD.


  METHOD run_dynamic_query.
    FIELD-SYMBOLS <lt_result> TYPE STANDARD TABLE.

    DATA(lt_allowed_tables) = VALUE string_table( ( `/DMO/AIRPORT` ) ( `/DMO/CONNECTION` ) ( `/DMO/CUSTOMER` ) ).
    IF NOT line_exists( lt_allowed_tables[ table_line = is_query-table_name ] ).
      io_out->write( |Rejected: { is_query-table_name }| ).
      RETURN.
    ENDIF.

    DATA lr_result TYPE REF TO data.
    CREATE DATA lr_result TYPE STANDARD TABLE OF (is_query-table_name).
    ASSIGN lr_result->* TO <lt_result>.

    TRY.
        SELECT FROM (is_query-table_name)
          FIELDS (is_query-fields)
          WHERE (is_query-where)
          INTO CORRESPONDING FIELDS OF TABLE @<lt_result>
          UP TO @mv_max_rows ROWS.
        io_out->write( |SELECT { is_query-fields } FROM { is_query-table_name } WHERE { is_query-where }: { lines( <lt_result> ) } rows| ).
        io_out->write( <lt_result> ).
      CATCH cx_sy_dynamic_osql_error INTO DATA(lx_sql).
        io_out->write( |SQL error ({ is_query-table_name }): { lx_sql->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

