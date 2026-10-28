CLASS zcl_05_07_rounding DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_05_07_rounding IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA: lv_string TYPE string VALUE `LOGALI TEACH`,
          lv_char   TYPE c LENGTH 2, "tipo incompleto
          lv_int    TYPE i.
    DATA: lv_date    TYPE d,
          lv_decimal TYPE p LENGTH 5 DECIMALS 3.

    "Truncamiento, se pierden caracteres
    lv_char = lv_string.
    out->write( lv_char ).

    "Redondeo
    lv_decimal = 1 / 6.
    out->write( lv_decimal ). "ampliar longitu de decimales y length

    lv_decimal = 1 / 12.
    out->write( |1 / 12 is rounded to { lv_decimal }| ).


    "Declaraciones en línea
    DATA(lv_mult) = 8 * 16. "ver el tipo que toma en el depurador
    out->write( lv_mult ). "numero entero

    DATA(lv_div) = 8 / 16.
    out->write( lv_div ).  "ver el tipo que toma en el depurador
                           "Se redondea el número
    DATA(lv_text) = 'ABAP I - 2026'.
    out->write( lv_text ).

  ENDMETHOD.

ENDCLASS.
