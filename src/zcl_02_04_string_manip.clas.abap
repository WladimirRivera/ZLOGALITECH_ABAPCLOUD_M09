*&---------------------------------------------------------------------*
*& ABAP Programacion Estructurada - Class 2
*& Section 5: Professional string manipulation
*& CONCATENATE, SPLIT, SHIFT, FIND, REPLACE, SUBSTRING, OVERLAY
*&---------------------------------------------------------------------*
CLASS zcl_02_04_string_manip DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS concatenate_strings IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS split_string        IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS shift_string        IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS find_substring      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS replace_substring   IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS substring_extract   IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS overlay_string      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_02_04_string_manip IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== SECTION 5: PROFESSIONAL STRING MANIPULATION ===' ).

    concatenate_strings( out ).
    split_string( out ).
    shift_string( out ).
    find_substring( out ).
    replace_substring( out ).
    substring_extract( out ).
    overlay_string( out ).
  ENDMETHOD.


  METHOD concatenate_strings.
    out->write( '--- 5.1 CONCATENATE ---' ).

    DATA: lv_first  TYPE string VALUE 'Hello',
          lv_second TYPE string VALUE 'World',
          lv_result TYPE string.

    CONCATENATE lv_first lv_second INTO lv_result
      SEPARATED BY ' '
      RESPECTING BLANKS.

    out->write( |CONCATENATE ... SEPARATED BY ' ' -> '{ lv_result }'| ).

    " Equivalent, and generally preferred, using a string template:
    DATA(lv_result_template) = |{ lv_first } { lv_second }|.
    out->write( |String template equivalent         -> '{ lv_result_template }'| ).
  ENDMETHOD.


  METHOD split_string.
    out->write( '--- 5.2 SPLIT ---' ).

    DATA: lv_csv_line TYPE string VALUE 'Berlin,Madrid,Paris',
          lt_cities   TYPE TABLE OF string,
          lv_city_1   TYPE string,
          lv_city_2   TYPE string,
          lv_city_3   TYPE string.

    " Split into a fixed number of individual fields
    SPLIT lv_csv_line AT ',' INTO lv_city_1 lv_city_2 lv_city_3.
    out->write( |Fixed fields -> '{ lv_city_1 }' / '{ lv_city_2 }' / '{ lv_city_3 }'| ).

    " Split into an internal table when the number of parts is not known
    SPLIT lv_csv_line AT ',' INTO TABLE lt_cities.
    out->write( 'Split into table:' ).
    out->write( lt_cities ).
  ENDMETHOD.


  METHOD shift_string.
    out->write( '--- 5.3 SHIFT ---' ).

    DATA(lv_code) = ` ABC123 `.
    DATA(lv_code_left) = lv_code.
    SHIFT lv_code_left LEFT DELETING LEADING space.
    out->write( |SHIFT LEFT DELETING LEADING space  -> '{ lv_code_left }'| ).

    DATA(lv_code_right) = lv_code.
    SHIFT lv_code_right RIGHT DELETING TRAILING space.
    out->write( |SHIFT RIGHT DELETING TRAILING space -> '{ lv_code_right }'| ).

    DATA(lv_code_circular) = |ABC123|.
    SHIFT lv_code_circular BY 2 PLACES CIRCULAR.
    out->write( |SHIFT BY 2 PLACES CIRCULAR          -> '{ lv_code_circular }'| ).

        SHIFT lv_code_circular BY 2 PLACES.
    out->write( |SHIFT BY 2 PLACES          -> '{ lv_code_circular }'| ).
  ENDMETHOD.


  METHOD find_substring.
    out->write( '--- 5.4 FIND ---' ).

    DATA: lv_text      TYPE string VALUE 'ABAP Cloud',
          lv_substring TYPE string VALUE 'cloud',
          lv_position  TYPE i.

    FIND lv_substring IN lv_text
      MATCH OFFSET lv_position
      IGNORING CASE.

    out->write( |FIND '{ lv_substring }' IN '{ lv_text }' IGNORING CASE -> offset { lv_position }| ).
  ENDMETHOD.


  METHOD replace_substring.
    out->write( '--- 5.5 REPLACE ---' ).

    DATA(lv_text) = |ABAP is powerful, ABAP is fast|.

    REPLACE ALL OCCURRENCES OF 'ABAP' IN lv_text WITH 'ABAP Cloud'.

    out->write( |After REPLACE ALL OCCURRENCES -> '{ lv_text }'| ).
  ENDMETHOD.


  METHOD substring_extract.
    out->write( '--- 5.6 SUBSTRING ---' ).

    DATA(lv_order_number) = |ORD-2026-000451|.

    DATA(lv_year)   = substring( val = lv_order_number off = 4 len = 4 ).
    DATA(lv_serial) = substring( val = lv_order_number off = 9 len = 6 ).

    out->write( |substring( off = 4 len = 4 ) -> '{ lv_year }'| ).
    out->write( |substring( off = 9 len = 6 ) -> '{ lv_serial }'| ).

    " Offset shorthand notation, equivalent to SUBSTRING
    DATA(lv_year_shorthand) = lv_order_number+4(4).
    out->write( |Offset shorthand +4(4)      -> '{ lv_year_shorthand }'| ).
  ENDMETHOD.


  METHOD overlay_string.
    out->write( '--- 5.7 OVERLAY ---' ).
    out->write( 'Note: the OVERLAY( ) built-in function is not released for ABAP Cloud' ).
    out->write( 'on this system (activation fails with "Method OVERLAY is unknown").' ).
    out->write( 'On-premise / classic ABAP, OVERLAY only replaces the positions covered' ).
    out->write( 'by WITH, leaving the rest of the original value untouched:' ).
    out->write( '  DATA(lv_iso_date) = overlay( val = lv_template with = lv_year' ).
    out->write( '                               starting_at_offset = 0 ).' ).
    out->write( 'In ABAP Cloud, a string template achieves the same fixed-mask result:' ).

    DATA: lv_year  TYPE c LENGTH 4 VALUE '2026',
          lv_month TYPE c LENGTH 2 VALUE '09',
          lv_day   TYPE c LENGTH 2 VALUE '22'.

    DATA(lv_iso_date) = |{ lv_year }-{ lv_month }-{ lv_day }|.

    out->write( |String template mask -> '{ lv_iso_date }'| ).
  ENDMETHOD.

ENDCLASS.
