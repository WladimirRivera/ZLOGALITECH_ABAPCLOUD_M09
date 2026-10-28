*&---------------------------------------------------------------------*
*& ABAP Programacion Estructurada - Class 2
*& Section 3: Date, time and timestamp calculations
*&---------------------------------------------------------------------*
CLASS zcl_02_02_date_time_stamp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS date_and_time_basics  IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS timestamp_field       IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS utclong_type          IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS best_practices        IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_02_02_date_time_stamp IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== SECTION 3: DATE, TIME AND TIMESTAMP CALCULATIONS ===' ).

    date_and_time_basics( out ).
    timestamp_field( out ).
    utclong_type( out ).
    best_practices( out ).
  ENDMETHOD.


  METHOD date_and_time_basics.
    out->write( '--- 3.1 The D and T types: basic date arithmetic ---' ).

    DATA: lv_start_date TYPE d VALUE '20260101',
          lv_due_date   TYPE d,
          lv_days_diff  TYPE i.

    lv_due_date  = lv_start_date + 30.          " Add 30 calendar days
    lv_days_diff = lv_due_date - lv_start_date. " Difference in days

    out->write( |Start date:        { lv_start_date DATE = ISO }| ).
    out->write( |Due date (+30):    { lv_due_date DATE = ISO }| ).
    out->write( |Due date (+302):    { lv_due_date  }| ).
    out->write( |Days difference:   { lv_days_diff }| ).

    out->write( '--- SY-DATUM / SY-UZEIT: current server date and time ---' ).
    out->write( |SY-DATUM: { sy-datum DATE = ISO }| ).
    out->write( |SY-UZEIT: { sy-uzeit TIME = ISO }| ).

    IF sy-datum BETWEEN lv_start_date AND lv_due_date.
      out->write( 'Today falls within the validity period.' ).
    ELSE.
      out->write( 'Today falls OUTSIDE the validity period.' ).
    ENDIF.
  ENDMETHOD.


  METHOD timestamp_field.
    out->write( '--- 3.2 TIMESTAMP fields (date + time, 14 characters) ---' ).

    DATA lv_created_at TYPE timestamp.
    GET TIME STAMP FIELD lv_created_at.  " Current UTC timestamp, 14 characters

    out->write( |Current timestamp (AAAAMMDDHHMMSS): { lv_created_at }| ).
    out->write( 'Layout: AAAA(year) MM(month) DD(day) HH(hour) MM(minute) SS(second)' ).
  ENDMETHOD.


  METHOD utclong_type.
    out->write( '--- 3.3 The UTCLONG type: microsecond precision ---' ).

    DATA(lv_utc_now) = utclong_current( ).  " Current UTCLONG, microsecond precision

    out->write( |Current UTCLONG (YYYYMMDDHHMMSSmmmuuu): { lv_utc_now }| ).

    DATA(lv_event_1) = lv_utc_now.
    WAIT UP TO '0.01' SECONDS.
    DATA(lv_event_2) = utclong_current( ).

    IF lv_event_1 < lv_event_2.
      out->write( 'Event 1 happened first (lv_event_1 < lv_event_2).' ).
    ELSE.
      out->write( 'Event 1 happened after or at the same time as Event 2.' ).
    ENDIF.
  ENDMETHOD.


  METHOD best_practices.
    out->write( '--- 3.4 Best practices for temporal calculations ---' ).
    out->write( '- Use TIMESTAMP or UTCLONG (not separate D + T fields) when the exact' ).
    out->write( '  order of events matters, to avoid rounding errors when comparing.' ).
    out->write( '- Prefer GET TIME STAMP FIELD over reading SY-DATUM and SY-UZEIT' ).
    out->write( '  separately, to avoid a race condition where the date changes between' ).
    out->write( '  the two reads.' ).
    out->write( '- When adding/subtracting days from a D field, ABAP adjusts month and' ).
    out->write( '  year automatically; no manual calculation is needed.' ).
  ENDMETHOD.

ENDCLASS.
