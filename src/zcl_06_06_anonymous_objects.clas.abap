CLASS zcl_06_06_anonymous_objects DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_06_06_anonymous_objects IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    FIELD-SYMBOLS <lv_value>   TYPE any.
    FIELD-SYMBOLS <lt_table>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_row>     TYPE any.
    FIELD-SYMBOLS <lv_field>   TYPE any.

    out->write( '=== CLASS 6.06: DYNAMIC PROGRAMMING - ANONYMOUS DATA OBJECTS ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: NEW creates a data object without a name ---' ).
    DATA(lr_number)     = NEW i( 100 ).
    DATA(lr_connection) = NEW /dmo/connection( carrier_id      = 'LH'
                                               connection_id   = '0400'
                                               airport_from_id = 'FRA'
                                               airport_to_id   = 'JFK' ).
    out->write( |lr_number->* = { lr_number->* }| ).
    out->write( |lr_connection->* = { lr_connection->carrier_id } { lr_connection->connection_id } { lr_connection->airport_from_id } -> { lr_connection->airport_to_id }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: CREATE DATA with a type name known only at runtime ---' ).
    DATA lr_data TYPE REF TO data.
    DATA(lt_type_names) = VALUE string_table( ( `/DMO/CUSTOMER_ID` )
                                              ( `/DMO/AIRPORT_ID` )
                                              ( `/DMO/FLIGHT_PRICE` )
                                              ( `STRING` ) ).
    LOOP AT lt_type_names INTO DATA(lv_type_name).
      CREATE DATA lr_data TYPE (lv_type_name).
      ASSIGN lr_data->* TO <lv_value>.
      DATA(lo_type) = cl_abap_typedescr=>describe_by_data( <lv_value> ).
      out->write( |{ lv_type_name WIDTH = 20 } -> type kind { lo_type->type_kind }, length { lo_type->length } bytes| ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 3: Internal table of a table chosen at runtime ---' ).
    DATA(lv_table_name) = `/DMO/AIRPORT`.
    CREATE DATA lr_data TYPE STANDARD TABLE OF (lv_table_name).
    ASSIGN lr_data->* TO <lt_table>.
    SELECT FROM (lv_table_name)
      FIELDS *
      ORDER BY PRIMARY KEY
      INTO TABLE @<lt_table>
      UP TO 3 ROWS.
    out->write( data = <lt_table> name = lv_table_name ).
    out->write( ' ' ).

    out->write( '--- Example 4: RTTS - build a brand-new structure type at runtime ---' ).
    DATA(lt_components) = VALUE cl_abap_structdescr=>component_table(
      ( name = 'CARRIER_ID'     type = CAST #( cl_abap_typedescr=>describe_by_name( '/DMO/CARRIER_ID' ) ) )
      ( name = 'FLIGHTS'        type = cl_abap_elemdescr=>get_i( ) )
      ( name = 'SEATS_OCCUPIED' type = cl_abap_elemdescr=>get_i( ) ) ).

    DATA(lo_line_type)  = cl_abap_structdescr=>get( lt_components ).
    DATA(lo_table_type) = cl_abap_tabledescr=>get( p_line_type = lo_line_type ).

    CREATE DATA lr_data TYPE HANDLE lo_table_type.
    ASSIGN lr_data->* TO <lt_table>.

    SELECT FROM /dmo/flight
      FIELDS carrier_id,
             COUNT(*)              AS flights,
             SUM( seats_occupied ) AS seats_occupied
      GROUP BY carrier_id
      ORDER BY carrier_id
      INTO TABLE @DATA(lt_statistics).

    LOOP AT lt_statistics INTO DATA(ls_statistic).
      APPEND INITIAL LINE TO <lt_table> ASSIGNING <ls_row>.
      ASSIGN COMPONENT 'CARRIER_ID' OF STRUCTURE <ls_row> TO <lv_field>.
      <lv_field> = ls_statistic-carrier_id.
      ASSIGN COMPONENT 'FLIGHTS' OF STRUCTURE <ls_row> TO <lv_field>.
      <lv_field> = ls_statistic-flights.
      ASSIGN COMPONENT 'SEATS_OCCUPIED' OF STRUCTURE <ls_row> TO <lv_field>.
      <lv_field> = ls_statistic-seats_occupied.
    ENDLOOP.
    out->write( data = <lt_table> name = 'Runtime-created table' ).
    out->write( ' ' ).

    out->write( '--- Example 5: Anonymous object of a class chosen at runtime ---' ).
    DATA lo_object TYPE REF TO object.
    DATA(lv_class_name) = `ZCL_06_05_DATA_REFERENCES`.
    CREATE OBJECT lo_object TYPE (lv_class_name).
    out->write( |Instance of { cl_abap_typedescr=>describe_by_object_ref( lo_object )->get_relative_name( ) }| ).
    out->write( |IS INSTANCE OF if_oo_adt_classrun = '{ xsdbool( lo_object IS INSTANCE OF if_oo_adt_classrun ) }'| ).
  ENDMETHOD.

ENDCLASS.

