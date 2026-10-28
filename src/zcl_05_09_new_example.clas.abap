CLASS zcl_05_09_new_example DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! <p class="shorttext synchronized" lang="en"></p>
    "! Hola Mundo
    "! @parameter rv_value | <p class="shorttext synchronized" lang="en"></p>
    METHODS print_value RETURNING VALUE(rv_value) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_05_09_new_example IMPLEMENTATION.
  METHOD print_value.
    rv_value = 'Hola mundo'.
  ENDMETHOD.
ENDCLASS.
