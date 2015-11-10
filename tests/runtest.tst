
msglvl +verbose +emsgloc
msglvl +time +usecs

* ----------------------------------------------------------------------------
*Testcase runtest#1: all cpus 0 seconds
* ----------------------------------------------------------------------------
*
numcpu      4           #  Total CPUs needed for this test...
*
* ----------------------------------------------------------------------------
*
defsym  secs0     0     #  Loop duration in seconds for each CPU...
defsym  secs1     0
defsym  secs2     0
defsym  secs3     0
*
defsym  maxdur   0.4    #  Expected test duration, give or take.
*
* ----------------------------------------------------------------------------
*
defsym  asec0     400   #  Address of "SECONDSn" fields...
defsym  asec1     410
defsym  asec2     420
defsym  asec3     430
*
* ----------------------------------------------------------------------------
*
defsym  anow0     900   #  Address of "NOWTIMEn" and "ENDTIMEn" fields...
defsym  aend0     910
*
defsym  anow1     920
defsym  aend1     930
*
defsym  anow2     940
defsym  aend2     950
*
defsym  anow3     960
defsym  aend3     970
*
* ----------------------------------------------------------------------------
* Must be contiguous!
*
defsym  flag0     a00   #  Address of "FLAGn" fields...
defsym  flag1     a01
defsym  flag2     a02
defsym  flag3     a03
*
* ----------------------------------------------------------------------------
*
sysclear                #  Clear the world
archmode z/Arch         #  Set z/Arch mode
*
r 1a0=0000000180000000  #  z/Arch RESTART PSW - part 1
r 1a8=0000000000000200  #  z/Arch RESTART PSW - part 2 (address)
*
r 1d0=0002000180000000  #  z/Arch PGM NEW PSW - part 1
r 1d8=00000000DEADDEAD  #  z/Arch PGM NEW PSW - part 2 (address)
*
* ----------------------------------------------------------------------------
*
r 200=1f00              #          SLR   R0,R0        Start clean
r 202=41100001          #          LA    R1,1         Request z/Arch mode
r 206=1f22              #          SLR   R2,R2        Start clean
r 208=1f33              #          SLR   R3,R3        Start clean
r 20a=ae020012          #          SIGP  R0,R2,X'12'  Request z/Arch mode
r 20e=1f11              #          SLR   R1,R1        Start clean
*
r 210=41200000          #          LA    R2,0         Get our CPU number
r 214=41400500          #          LA    R4,BEGIN0    Point to our loop
r 218=404001ae          #          STH   R4,X'1AE'    Update restart PSW
r 21c=ae020006          #          SIGP  R0,R2,X'6'   Restart our CPU
r 220=b2b20310          #          LPSWE FAILPSW      How did we get here?!
*
* ----------------------------------------------------------------------------
*
r 300=0002000180000000  # GOODPSW  DC    0D'0',X'...  Success wait PSW part 1
r 308=0000000000000000  #          DC    0D'0',X'...  Success wait PSW part 2
r 310=0002000180000000  # FAILPSW  DC    0D'0',X'...  Failure wait PSW part 1
r 318=00000000EEEEEEEE  #          DC    0D'0',X'...  Failure wait PSW part 2
*
* ----------------------------------------------------------------------------
*
r $(asec0)=0000000$(secs0)  # SECONDS0 DC    F'n'     Seconds CPU should loop
r $(asec1)=0000000$(secs1)  # SECONDS1 DC    F'n'     Seconds CPU should loop
r $(asec2)=0000000$(secs2)  # SECONDS2 DC    F'n'     Seconds CPU should loop
r $(asec3)=0000000$(secs3)  # SECONDS3 DC    F'n'     Seconds CPU should loop
*
* ----------------------------------------------------------------------------
*
r 500=41200001          # BEGIN0   LA    R2,1         Get next CPU number
r 504=41400600          #          LA    R4,BEGIN1    Point to next loop
r 508=404001ae          #          STH   R4,X'1AE'    Update restart PSW
r 50c=ae020006          #          SIGP  R0,R2,X'6'   Restart the next CPU
*
r 510=b2050$(aend0)     #          STCK     ENDTIME0  Current TOD clock value
r 514=58100$(aend0)     #          L     R1,ENDTIME0  High word = approx. secs
r 518=5e100$(asec0)     #          AL    R1,SECONDS0  Add seconds we're to loop
r 51c=50100$(aend0)     #          ST    R1,ENDTIME0  Save ending clock value
r 520=b2050$(anow0)     # LOOP0    STCK     NOWTIME0  Current TOD clock value
r 524=58100$(anow0)     #          L     R1,NOWTIME0  High word = approx. secs
r 528=55100$(aend0)     #          CL    R1,ENDTIME0  Reached ending TOD yet?
r 52c=47400520          #          BL          LOOP0  Not yet. Keep looping...
r 530=92ff0$(flag0)     #          MVI   X'FF',FLAG0  Indicate our loop ended
r 534=b2b20300          #          LPSWE GOODPSW      Our CPU is now finished
*
* ----------------------------------------------------------------------------
*
r 600=41200002          # BEGIN1   LA    R2,2         Get next CPU number
r 604=41400700          #          LA    R4,BEGIN2    Point to next loop
r 608=404001ae          #          STH   R4,X'1AE'    Update restart PSW
r 60c=ae020006          #          SIGP  R0,R2,X'6'   Restart the next CPU
*  
r 610=b2050$(aend1)     #          STCK     ENDTIME1  Current TOD clock value
r 614=58100$(aend1)     #          L     R1,ENDTIME1  High word = approx. secs
r 618=5e100$(asec1)     #          AL    R1,SECONDS1  Add seconds we're to loop
r 61c=50100$(aend1)     #          ST    R1,ENDTIME1  Save ending clock value
r 620=b2050$(anow1)     # LOOP1    STCK     NOWTIME1  Current TOD clock value
r 624=58100$(anow1)     #          L     R1,NOWTIME1  High word = approx. secs
r 628=55100$(aend1)     #          CL    R1,ENDTIME1  Reached ending TOD yet?
r 62c=47400620          #          BL          LOOP1  Not yet. Keep looping...
r 630=92ff0$(flag1)     #          MVI   X'FF',FLAG1  Indicate our loop ended
r 634=b2b20300          #          LPSWE GOODPSW      Our CPU is now finished
*
* ----------------------------------------------------------------------------
*
r 700=41200003          # BEGIN2   LA    R2,3         Get next CPU number
r 704=41400800          #          LA    R4,BEGIN3    Point to next loop
r 708=404001ae          #          STH   R4,X'1AE'    Update restart PSW
r 70c=ae020006          #          SIGP  R0,R2,X'6'   Restart the next CPU
*  
r 710=b2050$(aend2)     #          STCK     ENDTIME2  Current TOD clock value
r 714=58100$(aend2)     #          L     R1,ENDTIME2  High word = approx. secs
r 718=5e100$(asec2)     #          AL    R1,SECONDS2  Add seconds we're to loop
r 71c=50100$(aend2)     #          ST    R1,ENDTIME2  Save ending clock value
r 720=b2050$(anow2)     # LOOP2    STCK     NOWTIME2  Current TOD clock value
r 724=58100$(anow2)     #          L     R1,NOWTIME2  High word = approx. secs
r 728=55100$(aend2)     #          CL    R1,ENDTIME2  Reached ending TOD yet?
r 72c=47400720          #          BL          LOOP2  Not yet. Keep looping...
r 730=92ff0$(flag2)     #          MVI   X'FF',FLAG2  Indicate our loop ended
r 734=b2b20300          #          LPSWE GOODPSW      Our CPU is now finished
*
* ----------------------------------------------------------------------------
*
r 800=b2050$(aend3)     # BEGIN3   STCK     ENDTIME3  Current TOD clock value
r 804=58100$(aend3)     #          L     R1,ENDTIME3  High word = approx. secs
r 808=5e100$(asec3)     #          AL    R1,SECONDS3  Add seconds we're to loop
r 80c=50100$(aend3)     #          ST    R1,ENDTIME3  Save ending clock value
r 810=b2050$(anow3)     # LOOP3    STCK     NOWTIME3  Current TOD clock value
r 814=58100$(anow3)     #          L     R1,NOWTIME3  High word = approx. secs
r 818=55100$(aend3)     #          CL    R1,ENDTIME3  Reached ending TOD yet?
r 81c=47400810          #          BL          LOOP3  Not yet. Keep looping...
r 820=92ff0$(flag3)     #          MVI   X'FF',FLAG3  Indicate our loop ended
r 824=b2b20300          #          LPSWE GOODPSW      Our CPU is now finished
*
* ----------------------------------------------------------------------------
*
r $(anow0)=0123456789abcdef00000000  # NOWTIME0 DC    D'0',F'0'
r $(aend0)=0123456789abcdef00000000  # ENDTIME0 DC    D'0',F'0'
*
r $(anow1)=0123456789abcdef00000001  # NOWTIME1 DC    D'0',F'1'
r $(aend1)=0123456789abcdef00000001  # ENDTIME1 DC    D'0',F'1'
*
r $(anow2)=0123456789abcdef00000002  # NOWTIME2 DC    D'0',F'2'
r $(aend2)=0123456789abcdef00000002  # ENDTIME2 DC    D'0',F'2'
*
r $(anow3)=0123456789abcdef00000003  # NOWTIME3 DC    D'0',F'3'
r $(aend3)=0123456789abcdef00000003  # ENDTIME3 DC    D'0',F'3'
*
* ----------------------------------------------------------------------------
* Must be contiguous!
*
r $(flag0)=f0           # FLAG0   DC   X'F0'           Silly test ended flag
r $(flag1)=f1           # FLAG1   DC   X'F1'           Silly test ended flag
r $(flag2)=f2           # FLAG2   DC   X'F2'           Silly test ended flag
r $(flag3)=f3           # FLAG3   DC   X'F3'           Silly test ended flag
*
* ----------------------------------------------------------------------------
* Start the test and wait for completion...
*
runtest $(maxdur)
*
* ----------------------------------------------------------------------------
*
r $(anow0).c            # Show CPU 0 actual ending  TOD
r $(aend0).c            # Show CPU 0 ending compare TOD
*
r $(anow1).c            # Show CPU 1 actual ending  TOD
r $(aend1).c            # Show CPU 1 ending compare TOD
*
r $(anow2).c            # Show CPU 2 actual ending  TOD
r $(aend2).c            # Show CPU 2 ending compare TOD
*
r $(anow3).c            # Show CPU 3 actual ending  TOD
r $(aend3).c            # Show CPU 3 ending compare TOD
*
* ----------------------------------------------------------------------------
*
*Compare
r $(flag0)-$(flag3)
*Want FFFFFFFF
*
* ----------------------------------------------------------------------------
*
*Done
*
* ----------------------------------------------------------------------------
*Testcase runtest#2: all cpus 1-4 seconds
* ----------------------------------------------------------------------------
*
defsym  secs0     1     #  Loop duration in seconds for each CPU...
defsym  secs1     2
defsym  secs2     3
defsym  secs3     4
*
defsym  maxdur   4.5    #  Expected test duration, give or take.
*
* ----------------------------------------------------------------------------
*
sysclear                #  Clear the world
archmode z/Arch         #  Set z/Arch mode
*
r 1a0=0000000180000000  #  z/Arch RESTART PSW - part 1
r 1a8=0000000000000200  #  z/Arch RESTART PSW - part 2 (address)
*
r 1d0=0002000180000000  #  z/Arch PGM NEW PSW - part 1
r 1d8=00000000DEADDEAD  #  z/Arch PGM NEW PSW - part 2 (address)
*
* ----------------------------------------------------------------------------
*
r 200=1f00              #          SLR   R0,R0        Start clean
r 202=41100001          #          LA    R1,1         Request z/Arch mode
r 206=1f22              #          SLR   R2,R2        Start clean
r 208=1f33              #          SLR   R3,R3        Start clean
r 20a=ae020012          #          SIGP  R0,R2,X'12'  Request z/Arch mode
r 20e=1f11              #          SLR   R1,R1        Start clean
*
r 210=41200000          #          LA    R2,0         Get our CPU number
r 214=41400500          #          LA    R4,BEGIN0    Point to our loop
r 218=404001ae          #          STH   R4,X'1AE'    Update restart PSW
r 21c=ae020006          #          SIGP  R0,R2,X'6'   Restart our CPU
r 220=b2b20310          #          LPSWE FAILPSW      How did we get here?!
*
* ----------------------------------------------------------------------------
*
r 300=0002000180000000  # GOODPSW  DC    0D'0',X'...  Success wait PSW part 1
r 308=0000000000000000  #          DC    0D'0',X'...  Success wait PSW part 2
r 310=0002000180000000  # FAILPSW  DC    0D'0',X'...  Failure wait PSW part 1
r 318=00000000EEEEEEEE  #          DC    0D'0',X'...  Failure wait PSW part 2
*
* ----------------------------------------------------------------------------
*
r $(asec0)=0000000$(secs0)  # SECONDS0 DC    F'n'     Seconds CPU should loop
r $(asec1)=0000000$(secs1)  # SECONDS1 DC    F'n'     Seconds CPU should loop
r $(asec2)=0000000$(secs2)  # SECONDS2 DC    F'n'     Seconds CPU should loop
r $(asec3)=0000000$(secs3)  # SECONDS3 DC    F'n'     Seconds CPU should loop
*
* ----------------------------------------------------------------------------
*
r 500=41200001          # BEGIN0   LA    R2,1         Get next CPU number
r 504=41400600          #          LA    R4,BEGIN1    Point to next loop
r 508=404001ae          #          STH   R4,X'1AE'    Update restart PSW
r 50c=ae020006          #          SIGP  R0,R2,X'6'   Restart the next CPU
*
r 510=b2050$(aend0)     #          STCK     ENDTIME0  Current TOD clock value
r 514=58100$(aend0)     #          L     R1,ENDTIME0  High word = approx. secs
r 518=5e100$(asec0)     #          AL    R1,SECONDS0  Add seconds we're to loop
r 51c=50100$(aend0)     #          ST    R1,ENDTIME0  Save ending clock value
r 520=b2050$(anow0)     # LOOP0    STCK     NOWTIME0  Current TOD clock value
r 524=58100$(anow0)     #          L     R1,NOWTIME0  High word = approx. secs
r 528=55100$(aend0)     #          CL    R1,ENDTIME0  Reached ending TOD yet?
r 52c=47400520          #          BL          LOOP0  Not yet. Keep looping...
r 530=92ff0$(flag0)     #          MVI   X'FF',FLAG0  Indicate our loop ended
r 534=b2b20300          #          LPSWE GOODPSW      Our CPU is now finished
*
* ----------------------------------------------------------------------------
*
r 600=41200002          # BEGIN1   LA    R2,2         Get next CPU number
r 604=41400700          #          LA    R4,BEGIN2    Point to next loop
r 608=404001ae          #          STH   R4,X'1AE'    Update restart PSW
r 60c=ae020006          #          SIGP  R0,R2,X'6'   Restart the next CPU
*  
r 610=b2050$(aend1)     #          STCK     ENDTIME1  Current TOD clock value
r 614=58100$(aend1)     #          L     R1,ENDTIME1  High word = approx. secs
r 618=5e100$(asec1)     #          AL    R1,SECONDS1  Add seconds we're to loop
r 61c=50100$(aend1)     #          ST    R1,ENDTIME1  Save ending clock value
r 620=b2050$(anow1)     # LOOP1    STCK     NOWTIME1  Current TOD clock value
r 624=58100$(anow1)     #          L     R1,NOWTIME1  High word = approx. secs
r 628=55100$(aend1)     #          CL    R1,ENDTIME1  Reached ending TOD yet?
r 62c=47400620          #          BL          LOOP1  Not yet. Keep looping...
r 630=92ff0$(flag1)     #          MVI   X'FF',FLAG1  Indicate our loop ended
r 634=b2b20300          #          LPSWE GOODPSW      Our CPU is now finished
*
* ----------------------------------------------------------------------------
*
r 700=41200003          # BEGIN2   LA    R2,3         Get next CPU number
r 704=41400800          #          LA    R4,BEGIN3    Point to next loop
r 708=404001ae          #          STH   R4,X'1AE'    Update restart PSW
r 70c=ae020006          #          SIGP  R0,R2,X'6'   Restart the next CPU
*  
r 710=b2050$(aend2)     #          STCK     ENDTIME2  Current TOD clock value
r 714=58100$(aend2)     #          L     R1,ENDTIME2  High word = approx. secs
r 718=5e100$(asec2)     #          AL    R1,SECONDS2  Add seconds we're to loop
r 71c=50100$(aend2)     #          ST    R1,ENDTIME2  Save ending clock value
r 720=b2050$(anow2)     # LOOP2    STCK     NOWTIME2  Current TOD clock value
r 724=58100$(anow2)     #          L     R1,NOWTIME2  High word = approx. secs
r 728=55100$(aend2)     #          CL    R1,ENDTIME2  Reached ending TOD yet?
r 72c=47400720          #          BL          LOOP2  Not yet. Keep looping...
r 730=92ff0$(flag2)     #          MVI   X'FF',FLAG2  Indicate our loop ended
r 734=b2b20300          #          LPSWE GOODPSW      Our CPU is now finished
*
* ----------------------------------------------------------------------------
*
r 800=b2050$(aend3)     # BEGIN3   STCK     ENDTIME3  Current TOD clock value
r 804=58100$(aend3)     #          L     R1,ENDTIME3  High word = approx. secs
r 808=5e100$(asec3)     #          AL    R1,SECONDS3  Add seconds we're to loop
r 80c=50100$(aend3)     #          ST    R1,ENDTIME3  Save ending clock value
r 810=b2050$(anow3)     # LOOP3    STCK     NOWTIME3  Current TOD clock value
r 814=58100$(anow3)     #          L     R1,NOWTIME3  High word = approx. secs
r 818=55100$(aend3)     #          CL    R1,ENDTIME3  Reached ending TOD yet?
r 81c=47400810          #          BL          LOOP3  Not yet. Keep looping...
r 820=92ff0$(flag3)     #          MVI   X'FF',FLAG3  Indicate our loop ended
r 824=b2b20300          #          LPSWE GOODPSW      Our CPU is now finished
*
* ----------------------------------------------------------------------------
*
r $(anow0)=0123456789abcdef00000000  # NOWTIME0 DC    D'0',F'0'
r $(aend0)=0123456789abcdef00000000  # ENDTIME0 DC    D'0',F'0'
*
r $(anow1)=0123456789abcdef00000001  # NOWTIME1 DC    D'0',F'1'
r $(aend1)=0123456789abcdef00000001  # ENDTIME1 DC    D'0',F'1'
*
r $(anow2)=0123456789abcdef00000002  # NOWTIME2 DC    D'0',F'2'
r $(aend2)=0123456789abcdef00000002  # ENDTIME2 DC    D'0',F'2'
*
r $(anow3)=0123456789abcdef00000003  # NOWTIME3 DC    D'0',F'3'
r $(aend3)=0123456789abcdef00000003  # ENDTIME3 DC    D'0',F'3'
*
* ----------------------------------------------------------------------------
* Must be contiguous!
*
r $(flag0)=f0           # FLAG0   DC   X'F0'           Silly test ended flag
r $(flag1)=f1           # FLAG1   DC   X'F1'           Silly test ended flag
r $(flag2)=f2           # FLAG2   DC   X'F2'           Silly test ended flag
r $(flag3)=f3           # FLAG3   DC   X'F3'           Silly test ended flag
*
* ----------------------------------------------------------------------------
* Start the test and wait for completion...
*
runtest $(maxdur)
*
* ----------------------------------------------------------------------------
*
r $(anow0).c            # Show CPU 0 actual ending  TOD
r $(aend0).c            # Show CPU 0 ending compare TOD
*
r $(anow1).c            # Show CPU 1 actual ending  TOD
r $(aend1).c            # Show CPU 1 ending compare TOD
*
r $(anow2).c            # Show CPU 2 actual ending  TOD
r $(aend2).c            # Show CPU 2 ending compare TOD
*
r $(anow3).c            # Show CPU 3 actual ending  TOD
r $(aend3).c            # Show CPU 3 ending compare TOD
*
* ----------------------------------------------------------------------------
*
*Compare
r $(flag0)-$(flag3)
*Want FFFFFFFF
*
* ----------------------------------------------------------------------------
*
*Done
*
* ----------------------------------------------------------------------------
