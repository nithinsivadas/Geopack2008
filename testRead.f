C
C ############################################################################
C #    TESTING THE ABILITY TO READ AN INPUT FILE                                 #
C ############################################################################
C
      PROGRAM TEST_READ

C Initialize integer that specifies the file name
      integer :: i, in
      real XGEOI(3), ALT_KM, PARMOD(10)

C Open file
      open (in, FILE='inputT.dat',STATUS='OLD')

      Do
        read (in,100,End=1) IYEAR, IDAY, IHOUR, MIN, ISEC,
     *  (XGEOI(L),L=1,3), ALT_KM, (PARMOD(L),L=1,10)

        print 100, IYEAR, IDAY, IHOUR, MIN, ISEC,
     *  (XGEOI(L),L=1,3), ALT_KM, (PARMOD(L),L=1,10)
      end do
 1    print *,'Completed Reading'
 100  FORMAT (I4,1x,I3,3(1x,I2),14(1x,F8.2))
      End Program
