 01  SYMED002.
     03  IA-HEAD1.
         05  IA-YY1R.
             07  FILLER               PIC  X(03).
             07  IA-YY1               PIC  9(04).
         05  IA-MM1R.
             07  FILLER               PIC  X(03).
             07  IA-MM1               PIC  9(02).
         05  IA-DD1R.
             07  FILLER               PIC  X(03).
             07  IA-DD1               PIC  9(02).
         05  IA-YY2R.
             07  FILLER               PIC  X(03).
             07  IA-YY2               PIC  9(04).
         05  IA-MM2R.
             07  FILLER               PIC  X(03).
             07  IA-MM2               PIC  9(02).
         05  IA-DD2R.
             07  FILLER               PIC  X(03).
             07  IA-DD2               PIC  9(02).
     03  IA-HEAD2.
         05  IA-TUKI1R.
             07  FILLER               PIC  X(03).
             07  IA-TUKI1             PIC  9(02).
         05  IA-TUKI2R.
             07  FILLER               PIC  X(03).
             07  IA-TUKI2             PIC  9(02).
         05  IA-TUKI3R.
             07  FILLER               PIC  X(03).
             07  IA-TUKI3             PIC  9(02).
         05  IA-TUKI4R.
             07  FILLER               PIC  X(03).
             07  IA-TUKI4             PIC  9(02).
     03  IA-HYOJI1.
         05  IA-ZKIN1R.
             07  IA-ZKIN1RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA-ZKIN1         PIC  S9(07).
         05  IA-ZKIN2R.
             07  IA-ZKIN2RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA-ZKIN2         PIC  S9(07).
         05  IA-ZKIN3R.
             07  IA-ZKIN3RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA-ZKIN3         PIC  S9(07).
         05  IA-ZKIN4R.
             07  IA-ZKIN4RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA-ZKIN4         PIC  S9(07).
         05  IA-ZKIN5R.
             07  IA-ZKIN5RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA-ZKIN5         PIC  S9(07).
     03  IA-HYOJI2.
         05  IA-UKIN1R.
             07  IA-UKIN1RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA-UKIN1          PIC  S9(07).
**       05  IA-UKIN2R.
**           07  IA-UKIN2RR   OCCURS   5.
**               09  FILLER           PIC  X(03).
**               09  IA-UKIN2          PIC  S9(07).
         05  IA-UKIN3R.
             07  IA-UKIN3RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA-UKIN3          PIC  S9(07).
         05  IA-UKIN4R.
             07  IA-UKIN4RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA-UKIN4          PIC  S9(07).
         05  IA-UKIN5R.
             07  IA-UKIN5RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA-UKIN5         PIC  S9(07).
         05  IA-UKIN6R.
             07  IA-UKIN6RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA-UKIN6         PIC  S9(07).
     03  IA1-HYOJI3.
         05  IA1-UKIN1R.
             07  IA1-UKIN1RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA1-UKIN1        PIC  S9(07).
         05  IA1-UKIN2R.
             07  IA1-UKIN2RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA1-UKIN2        PIC  S9(07).
         05  IA1-UKIN3R.
             07  IA1-UKIN3RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA1-UKIN3        PIC  S9(07).
         05  IA1-UKIN4R.
             07  IA1-UKIN4RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA1-UKIN4        PIC  S9(07).
         05  IA1-UKIN5R.
             07  IA1-UKIN5RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA1-UKIN5        PIC  S9(07).
         05  IA1-UKIN6R.
             07  IA1-UKIN6RR   OCCURS   5.
                 09  FILLER           PIC  X(03).
                 09  IA1-UKIN6        PIC  S9(07).
     03  IA-KAKUNINR.
         05  FILLER                   PIC  X(03).
         05  IA-KAKUNIN               PIC  X(01).
     03  IA-MSG2R.
         05  FILLER                   PIC  X(03).
         05  IA-MSG2                  PIC  N(30).
