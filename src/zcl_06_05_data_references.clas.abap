CLASS zcl_06_05_data_references DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES tt_flights     TYPE STANDARD TABLE OF /dmo/flight WITH EMPTY KEY.
    TYPES tt_flight_refs TYPE STANDARD TABLE OF REF TO /dmo/flight WITH EMPTY KEY.

ENDCLASS.


CLASS zcl_06_05_data_references IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA lt_flights TYPE tt_flights.

    SELECT FROM /dmo/flight
      FIELDS *
      WHERE carrier_id = 'LH'
      ORDER BY connection_id, flight_date
      INTO TABLE @lt_flights.

    out->write( '=== CLASS 6.05: DYNAMIC PROGRAMMING - DATA REFERENCES ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Typed reference with REF #( ) and dereferencing ->* ---' ).
    DATA(lv_discount) = 10.
    DATA(lr_discount) = REF #( lv_discount ).
    lr_discount->* = 15.
    out->write( |lv_discount = { lv_discount }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: Reference to a table row (no copy) ---' ).
    READ TABLE lt_flights REFERENCE INTO DATA(lr_flight) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_old_price) = lr_flight->price.
      lr_flight->price = lr_flight->price * ( 100 - lv_discount ) / 100.
      out->write( |{ lr_flight->carrier_id } { lr_flight->connection_id } { lr_flight->flight_date }: price { lv_old_price } -> { lt_flights[ 1 ]-price } { lr_flight->currency_code }| ).
    ENDIF.
    out->write( ' ' ).

    out->write( '--- Example 3: Generic reference TYPE REF TO data ---' ).
    DATA lr_generic TYPE REF TO data.
    FIELD-SYMBOLS <lv_value> TYPE any.

    lr_generic = REF #( lv_discount ).
    ASSIGN lr_generic->* TO <lv_value>.
    out->write( |lr_generic->* = { <lv_value> }| ).

    lr_generic = REF #( lt_flights[ 1 ] ).
    ASSIGN lr_generic->* TO <lv_value>.
    ASSIGN COMPONENT 'PLANE_TYPE_ID' OF STRUCTURE <lv_value> TO FIELD-SYMBOL(<lv_plane>).
    out->write( |lr_generic->* PLANE_TYPE_ID = { <lv_plane> }| ).
    out->write( ' ' ).

    out->write( '--- Example 4: CAST a generic reference back to a typed one ---' ).
    DATA(lr_typed_flight) = CAST /dmo/flight( lr_generic ).
    out->write( |Seats: { lr_typed_flight->seats_occupied } / { lr_typed_flight->seats_max }| ).
    out->write( ' ' ).

    out->write( '--- Example 5: Table of references - sort without copying the rows ---' ).
    DATA(lt_refs) = VALUE tt_flight_refs( FOR i = 1 UNTIL i > lines( lt_flights )
                                          ( REF #( lt_flights[ i ] ) ) ).
    SORT lt_refs BY table_line->seats_occupied DESCENDING.
    LOOP AT lt_refs INTO DATA(lr_ranked) TO 3.
      out->write( |   { lr_ranked->connection_id } { lr_ranked->flight_date }: { lr_ranked->seats_occupied } seats| ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 6: IS BOUND and CLEAR ---' ).
    CLEAR lr_typed_flight.
    out->write( |lr_typed_flight IS BOUND = '{ xsdbool( lr_typed_flight IS BOUND ) }', lines( lt_flights ) = { lines( lt_flights ) }| ).
  ENDMETHOD.

ENDCLASS.

