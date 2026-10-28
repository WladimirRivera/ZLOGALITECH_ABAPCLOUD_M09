CLASS zcl_05_04_field_symbols DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_05_04_field_symbols IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA lt_flights TYPE STANDARD TABLE OF /dmo/flight.

    SELECT FROM /dmo/flight
            FIELDS *
            WHERE carrier_id IS NOT INITIAL
            INTO TABLE @lt_flights
            UP TO 10 ROWS.

    LOOP AT lt_flights ASSIGNING FIELD-SYMBOL(<fs_flights>).
      <fs_flights>-carrier_id = 'EE'.
      <fs_flights>-flight_date = cl_abap_context_info=>get_system_date( ).

      out->write( |flight: { <fs_flights>-carrier_id }-{ <fs_flights>-flight_date }| ).
    ENDLOOP.

    READ TABLE lt_flights ASSIGNING FIELD-SYMBOL(<fs_flight_first>) INDEX 1.

    IF <fs_flight_first> IS ASSIGNED.
      out->write( <fs_flight_first> ).
      <fs_flight_first>-carrier_id = 'EE'.
      <fs_flight_first>-flight_date = cl_abap_context_info=>get_system_date( ).
      out->write( <fs_flight_first> ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
