 01  SYMED001.
     03  I-HEAD1.
         05  I-YY1R.
             07  FILLER               PIC  X(03).
             07  I-YY1                PIC  9(04).
         05  I-MM1R.
             07  FILLER               PIC  X(03).
             07  I-MM1                PIC  9(02).
         05  I-DD1R.
             07  FILLER               PIC  X(03).
             07  I-DD1                PIC  9(02).
         05  I-YY2R.
             07  FILLER               PIC  X(03).
             07  I-YY2                PIC  9(04).
         05  I-MM2R.
             07  FILLER               PIC  X(03).
             07  I-MM2                PIC  9(02).
         05  I-DD2R.
             07  FILLER               PIC  X(03).
             07  I-DD2                PIC  9(02).
     03  I-HEAD2.
         05  I-TUKI1R.
             07  FILLER               PIC  X(03).
             07  I-TUKI1              PIC  9(02).
         05  I-TUKI2R.
             07  FILLER               PIC  X(03).
             07  I-TUKI2              PIC  9(02).
         05  I-TUKI3R.
             07  FILLER               PIC  X(03).
             07  I-TUKI3              PIC  9(02).
         05  I-TUKI4R.
             07  FILLER               PIC  X(03).
             07  I-TUKI4              PIC  9(02).
         05  I-TUKI5R.
             07  FILLER               PIC  X(03).
             07  I-TUKI5              PIC  9(02).
     03  I-HYOJI1.
         05  I-ZKIN1R.
             07  I-ZKIN1RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I-ZKIN1          PIC  S9(07).
         05  I-ZKIN2R.
             07  I-ZKIN2RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I-ZKIN2          PIC  S9(07).
         05  I-ZKIN3R.
             07  I-ZKIN3RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I-ZKIN3          PIC  S9(07).
         05  I-ZKIN4R.
             07  I-ZKIN4RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I-ZKIN4          PIC  S9(07).
         05  I-ZKIN5R.
             07  I-ZKIN5RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I-ZKIN5          PIC  S9(07).
     03  I-HYOJI2.
         05  I-UKIN1R.
             07  I-UKIN1RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I-UKIN1          PIC  S9(07).
**       05  I-UKIN2R.
**           07  I-UKIN2RR   OCCURS   6.
**               09  FILLER           PIC  X(03).
**               09  I-UKIN2          PIC  S9(07).
         05  I-UKIN3R.
             07  I-UKIN3RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I-UKIN3          PIC  S9(07).
         05  I-UKIN4R.
             07  I-UKIN4RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I-UKIN4          PIC  S9(07).
         05  I-UKIN5R.
             07  I-UKIN5RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I-UKIN5          PIC  S9(07).
         05  I-UKIN6R.
             07  I-UKIN6RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I-UKIN6          PIC  S9(07).
     03  I1-HYOJI3.
         05  I1-UKIN1R.
             07  I1-UKIN1RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I1-UKIN1         PIC  S9(07).
         05  I1-UKIN2R.
             07  I1-UKIN2RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I1-UKIN2         PIC  S9(07).
         05  I1-UKIN3R.
             07  I1-UKIN3RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I1-UKIN3         PIC  S9(07).
         05  I1-UKIN4R.
             07  I1-UKIN4RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I1-UKIN4         PIC  S9(07).
         05  I1-UKIN5R.
             07  I1-UKIN5RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I1-UKIN5         PIC  S9(07).
         05  I1-UKIN6R.
             07  I1-UKIN6RR   OCCURS   6.
                 09  FILLER           PIC  X(03).
                 09  I1-UKIN6         PIC  S9(07).
     03  I-KAKUNINR.
         05  FILLER                   PIC  X(03).
         05  I-KAKUNIN                PIC  X(01).
     03  I-MSG2R.
         05  FILLER                   PIC  X(03).
         05  I-MSG2                   PIC  N(30).
