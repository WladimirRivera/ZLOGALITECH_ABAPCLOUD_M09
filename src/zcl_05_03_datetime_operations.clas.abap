CLASS zcl_05_03_datetime_operations DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_05_03_datetime_operations IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.


    DATA(lv_date) = '20250101'. "mostrar asi en el depurador e imprimir
    out->write( lv_date ).

    DATA(lv_date2) = CONV d( '20250101' ).
    out->write( lv_date2 ).

    "Date and Time
    DATA: lv_date4  TYPE d,
          lv_time  TYPE t,
          lv_time2 TYPE c LENGTH 6.

    lv_date4  = cl_abap_context_info=>get_system_date(  ).
    lv_time  = cl_abap_context_info=>get_system_time(  ). "hora del sistema
    lv_time2 = cl_abap_context_info=>get_user_time_zone(  ). "Obtiene la zona horaria del usuario determinado.
    "Si no se proporciona ningún nombre de usuario,
    "se utiliza el usuario actual.
    out->write( lv_date4 ).
    out->write( lv_time ).
    out->write( lv_time2 ). " UTC (Universal Time Coordinated) significa en español “Tiempo Coordinado Universal”.

* Date and Time
    DATA: lv_date5  TYPE d,
          lv_date6 TYPE d,
          lv_time3  TYPE t,
          lv_time4 TYPE c LENGTH 6.

    "calculos de fecha y hora
    lv_date5 = '20250101'.
    lv_date6 = '20250622'.

    DATA(lv_days) = lv_date6 - lv_date. "probar también con resultado solo de 30 días
    out->write( lv_days ).

    "Offset
    DATA(lv_month) = lv_date6+4(2). "mes
    out->write( lv_month ).
    lv_month = lv_date6+4(2) + 2. "mes
    out->write( lv_month ).
    DATA(lv_year) = lv_date6(4).
    out->write( lv_year ). "año
    DATA(lv_day) = lv_date6+6(2).
    out->write( lv_day ).  "día

    lv_date  = cl_abap_context_info=>get_system_date(  ) + 10.
    out->write( lv_date ).

    " utclong
    DATA: lv_time1 TYPE utclong,
          lv_time5 TYPE utclong.

    lv_time1 = utclong_current( ).
    out->write( lv_time1  ).

    lv_time1 = utclong_add( val = lv_time1 days = 1 hours = -1 ).
    out->write( lv_time1  ).

    "para sacar la diferencia entre dos fechas
    lv_time1 = utclong_current( ).
    out->write( lv_time1  ).
    lv_time5 = utclong_current( ).
    out->write( lv_time5  ).

    lv_time5 = utclong_add( val = lv_time1  hours = -5 ). "menos 5 horas
    out->write( lv_time5  ).

    DATA(lv_total) = utclong_diff( high = lv_time1 low = lv_time5 ).
    out->write( lv_total  ).

 " utclong
    DATA: lv_time6 TYPE utclong,
          lv_time7 TYPE utclong,
          lv_date7  TYPE d,
          lv_time9 TYPE t.

    lv_time1 = utclong_current( ).

    CONVERT UTCLONG lv_time1
    TIME ZONE cl_abap_context_info=>get_user_time_zone(  )
    INTO DATE lv_date4
    TIME lv_time9.

    out->write( lv_date7  ).
    out->write( lv_time9  ).

  ENDMETHOD.

ENDCLASS.
