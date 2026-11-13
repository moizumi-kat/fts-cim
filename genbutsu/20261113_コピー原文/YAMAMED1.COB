 01  YAMAMED1.
     03  I-MSG1                  PIC  N(10).
     03  I-HEAD1.
         05  I-HEAD1R.
             07  I-ZMM           PIC  9(06)    OCCURS  5.
             07  I-ZKINGAKU      PIC  S9(08)   OCCURS  5.
         05  I-HEAD1RX.
             07  I-ZMMX          PIC  9(06)    OCCURS  4.
             07  I-ZKINGAKUX     PIC  S9(08)   OCCURS  4.
         05  I-ZGOKEI            PIC  S9(08).
     03  I-HEAD2.
         05  I-HEAD2R.
             07  I-KMM           PIC  9(06)    OCCURS  5.
             07  I-KKINGAKU      PIC  S9(08)   OCCURS  5.
         05  I-HEAD2RX.
             07  I-KMMX          PIC  9(06)    OCCURS  4.
             07  I-KKINGAKUX     PIC  S9(08)   OCCURS  4.
         05  I-KGOKEI            PIC  S9(08).
     03  I-MSG2                  PIC  N(25).
     03  I-KAKUNIN               PIC  X(01).
*
