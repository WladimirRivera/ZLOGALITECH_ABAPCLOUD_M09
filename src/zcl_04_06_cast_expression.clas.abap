CLASS zcl_04_06_cast_expression DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

ENDCLASS.

CLASS zcl_04_06_cast_expression IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TYPES: BEGIN OF ty_vehicle,
      brand TYPE string,
      type TYPE string,
    END OF ty_vehicle.

    TYPES: BEGIN OF ty_car,
      brand TYPE string,
      doors TYPE i,
    END OF ty_car.

    DATA: gs_vehicle TYPE ty_vehicle.
    DATA: gs_car TYPE ty_car.

    out->write( '=== BLOCK 6: CAST - Type Conversion Example ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Initialize Vehicle Structure ---' ).
    gs_vehicle = VALUE ty_vehicle(
      brand = 'Toyota'
      type = 'Sedan'
    ).
    out->write( |Vehicle: { gs_vehicle-brand }, Type: { gs_vehicle-type }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: Convert Vehicle to Car ---' ).
    gs_car = VALUE ty_car(
      brand = gs_vehicle-brand
      doors = 4
    ).
    out->write( |Converted to Car: Brand={ gs_car-brand }, Doors={ gs_car-doors }| ).
    out->write( ' ' ).

    out->write( '--- Example 3: Explicit Type Casting ---' ).
    DATA: lv_count TYPE i.
    DATA: lv_value TYPE p LENGTH 5 DECIMALS 2.
    lv_value = '100.50'.
    lv_count = CONV i( lv_value ).
    out->write( |Decimal { lv_value } converted to Integer: { lv_count }| ).
    out->write( ' ' ).

    out->write( '--- Example 4: Cast with CORRESPONDING ---' ).
    gs_car = CORRESPONDING ty_car( gs_vehicle ).
    out->write( |After CORRESPONDING: Brand={ gs_car-brand }, Doors={ gs_car-doors }| ).
    out->write( ' ' ).

    out->write( 'Conclusion: CAST ensures type-safe conversions!' ).

  ENDMETHOD.

ENDCLASS.
