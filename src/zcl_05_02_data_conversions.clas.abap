CLASS zcl_05_02_data_conversions DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_05_02_data_conversions IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA: lv_string TYPE string VALUE `12345`,
          lv_int    TYPE i.

    DATA: lv_date    TYPE d,
          lv_decimal TYPE p LENGTH 3 DECIMALS 2.

    lv_int = lv_string.
    out->write( lv_int ).

    lv_string = `20230119`.
    lv_date = lv_string.

    out->write( |String value: { lv_string }| ).
    out->write( |Date Value: { lv_date DATE = USER }| ).

    lv_date = cl_abap_context_info=>get_system_date(  ).
    out->write( lv_date ).

  ENDMETHOD.

ENDCLASS.
