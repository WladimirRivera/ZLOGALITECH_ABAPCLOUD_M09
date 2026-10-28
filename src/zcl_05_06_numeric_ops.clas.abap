CLASS zcl_05_06_numeric_ops DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_05_06_numeric_ops IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

       DATA: lv_num_a TYPE i VALUE 20,
          lv_num_b TYPE i VALUE 8,
          lv_total TYPE p LENGTH 6 DECIMALS 2.

****ADD
    "+
    lv_total = lv_num_a + lv_num_b.
    out->write( | Number a { lv_num_a }  Number b { lv_num_b } Total: { lv_total }  |    ).
    "ADD
    ADD 5 TO lv_total.
    out->write( | Total: { lv_total } | ).
    "+=
    lv_total += 5. "lv_total = lv_total + 5.
    out->write( | Total: { lv_total } | ).
    lv_total = lv_num_a + lv_num_b + lv_total.
    out->write( | Total: { lv_total } | ).
    CLEAR lv_total.
    out->write( | Total: { lv_total } | ).

****RESTA
    lv_total = lv_num_a - lv_num_b.
    out->write( | Number a: { lv_num_a }  Number b: { lv_num_b } Total: { lv_total }  |    ).
    "SUBTRACT
    SUBTRACT 2 FROM lv_total.
    out->write( | Total: { lv_total } | ).
    lv_total -= 7.
    out->write( | Total: { lv_total } | ).
    lv_total = lv_num_a - 1.
    out->write( | Total: { lv_total } | ).

***MULTIPLY
    lv_total = lv_num_a * lv_num_b.
    out->write( | Number a: { lv_num_a }  Number b: { lv_num_b } Total: { lv_total }  |    ).
    MULTIPLY lv_total BY 5.
    out->write( | Total: { lv_total }  |    ).
    MULTIPLY lv_total BY lv_num_a.
    out->write( | Total: { lv_total }  |    ).
    lv_total = lv_total * 2.
    out->write( | Total: { lv_total }  |    ).

****DIVIDE
    lv_total = lv_num_a / lv_num_b.
    out->write( | Number a: { lv_num_a }  Number b: { lv_num_b } Total: { lv_total }  |    ).
    DIVIDE lv_total BY 2.
    out->write( | Total: { lv_total } | ).
    CLEAR lv_total.
    lv_total = ( lv_num_a + lv_num_b ) / 3.
    out->write( | Total: { lv_total } | ).

*****DIV
    lv_num_a = 18.
    lv_num_b = 8.
    lv_total = lv_num_a / lv_num_b.
    out->write( | Total: { lv_total } | ).
    lv_total = lv_num_a DIV lv_num_b.
    out->write( | Total: { lv_total } | ).

******MOD
    lv_total = lv_num_a / lv_num_b.
    out->write( | Total: { lv_total } | ).
    lv_total = lv_num_a MOD lv_num_b.
    out->write( | Total: { lv_total } | ).

****EXP
    lv_num_a = 3.
    out->write( | Number a: { lv_num_a } | ).
    lv_num_a = lv_num_a ** 2.
    out->write( | Number a: { lv_num_a } | ).
    CLEAR lv_num_a.
    lv_num_a = 3.
    DATA(lv_exp) = 3.
    lv_num_a = lv_num_a ** lv_exp.
    out->write( | Number a: { lv_num_a } | ).
    " ipow
    DATA(lv_result) = ipow( base = 2 exp = 3 ).
    out->write( lv_result ).

****SQRT
    lv_num_a = sqrt( 25 ).
    out->write( | Total SQRT: { lv_num_a } | ).
    lv_num_a = 9.
    lv_num_a = sqrt( lv_num_a ).
    out->write( | Total SQRT: { lv_num_a } | ).



  ENDMETHOD.

ENDCLASS.
