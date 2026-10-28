CLASS zcl_05_05_object_inst DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    METHODS print_value RETURNING VALUE(rv_value) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_05_05_object_inst IMPLEMENTATION.
  METHOD print_value.
    rv_value = 'Hello World'.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    DATA(lo_class) = NEW zcl_05_05_object_inst( ).
    DATA: lo_class2 TYPE REF TO zcl_05_05_object_inst.
    lo_class2 = NEW #( ).
    out->write( lo_class2->print_value( )  ).

    DATA: lo_class3 TYPE REF TO zcl_05_05_object_inst.
    CREATE OBJECT lo_class3.
    out->write( lo_class3->print_value( )  ).
  ENDMETHOD.

ENDCLASS.
