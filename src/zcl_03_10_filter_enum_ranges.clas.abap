CLASS zcl_03_10_filter_enum_ranges DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_03_10_filter_enum_ranges IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA gt_numbers TYPE TABLE OF i.
    DATA gt_filtered TYPE TABLE OF i.

    out->write( '=== Filtering and Ranges ===' ).
    out->write( ' ' ).

    gt_numbers = VALUE #( ( 1 ) ( 2 ) ( 3 ) ( 4 ) ( 5 ) ( 6 ) ( 7 ) ( 8 ) ( 9 ) ( 10 ) ).

    out->write( 'Filter numbers > 5' ).
    LOOP AT gt_numbers INTO DATA(lv_num).
      IF lv_num > 5.
        INSERT lv_num INTO TABLE gt_filtered.
      ENDIF.
    ENDLOOP.
    out->write( |Filtered: { lines( gt_filtered ) } items| ).
    out->write( ' ' ).

    out->write( 'Filtering simplifies data processing!' ).

  ENDMETHOD.
ENDCLASS.
