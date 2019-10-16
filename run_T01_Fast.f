C
C ############################################################################
C #    THE MAIN PROGRAMS BELOW GIVE TWO EXAMPLES OF TRACING FIELD LINES      #
C #      USING THE GEOPACK-2008 SOFTWARE  (release of Feb 08, 2008)              #
C ############################################################################
C
      PROGRAM RUN_T01

C   INPUT
C   IYEAR, IDAY, IHOUR, IMIN, ISEC,
C   XIGEO, YIGEO, ZIGEO [RE],
C   STOP_ALT [KM],
C   SOLAR WIND RAM PRESSURE (NANOPASCALS)
C   DST-INDEX (NANOTESLA)
C   IMF By (NANOTESLA)
C   IMF Bz (NANOTESLA)
C
C   OUTPUT
C   XGEO, YGEO, ZGEO [in RE], BXGEO, BYGEO, BR(GSW) [in nT]

C
C   IN THIS EXAMPLE IT IS ASSUMED THAT WE KNOW GEOGRAPHIC COORDINATES OF A
C   FIELD LINE < 60 RE FROM THE EARTH'S SURFACE AND TRACE THAT LINE FOR A SPECIFIED
C   MOMENT OF UNIVERSAL TIME, USING A FULL IGRF EXPANSION FOR THE INTERNAL FIELD
C
      PARAMETER (LMAX=1000)
C      PARAMETER (LMAXH=500)
C
C  LMAX IS THE UPPER LIMIT ON THE NUMBER OF FIELD LINE POINTS RETURNED BY THE TRACER.
C  IT CAN BE SET ARBITRARILY LARGE, DEPENDING ON THE SPECIFICS OF A PROBLEM UNDER STUDY.
C  IN THIS EXAMPLE, LMAX IS TENTATIVELY SET EQUAL TO 1000.
C
      DIMENSION XX(LMAX),YY(LMAX),ZZ(LMAX), PARMOD(10)
      DIMENSION XXN(LMAX),YYN(LMAX),ZZN(LMAX)
      DIMENSION XXS(LMAX),YYS(LMAX),ZZS(LMAX)
      DIMENSION XXGEO(LMAX),YYGEO(LMAX),ZZGEO(LMAX)
      DIMENSION BX(LMAX),BY(LMAX),BZ(LMAX), B(LMAX)
      DIMENSION BXGEO(LMAX),BYGEO(LMAX),BZGEO(LMAX)
      DIMENSION BR(LMAX),BTHETA(LMAX),BPHI(LMAX),BRNORM(LMAX)
      real :: XGEO(3), ALT_KM, DIR, R0
      integer :: i, EQL, FOOTNUM
      character(80) :: argv

c    Be sure to include an EXTERNAL statement in your codes, specifying the names
c    of external and internal field model subroutines in the package, as shown below.
c    In this example, the external and internal field models are T01_01 and IGRF_GSW_08,
c    respectively. Any other models can be used, provided they have the same format
c    and the same meaning of the input/output parameters.
c
      EXTERNAL T01_01,IGRF_GSW_08

C  IN THE ABSENCE OF RELIABLE MEASURMENTS - DOCUMENTATION INSTRUCTS TO USE THE ABOVE
C  SOLAR WIND VELOCITY IN GSE
      VGSEX=-430.0
      VGSEY= 29.8
      VGSEZ= 0.0
C  NOTE THAT 29.8 IS THE ABERRATION CORRECTION IN THE SOLAR WIND DATA.
C  VGSEY=VGSEY+29.78

C   DEFINE THE UNIVERSAL TIME AND PREPARE THE COORDINATE TRANSFORMATION PARAMETERS
C   BY INVOKING THE SUBROUTINE RECALC_08: IN THIS PARTICULAR CASE WE TRACE A LINE
C
      call get_command_argument(1,argv)
      read(argv,*) IYEAR
      call get_command_argument(2,argv)
      read(argv,*) IDAY
      call get_command_argument(3,argv)
      read(argv,*) IHOUR
      call get_command_argument(4,argv)
      read(argv,*) MIN
      call get_command_argument(5,argv)
      read(argv,*) ISEC

C   GET GEO (X,Y,Z) COORDINATES OF THE POINT
      DO 222 i=6,8
      call get_command_argument(i,argv)
      read(argv,*) XGEO(i-5)
 222  CONTINUE

C    GET ALTITUDE OF TERMINATION OF THE TRACING
C
      call get_command_argument(9,argv)
      read(argv,*) ALT_KM

C     PARAMOD: 1: SOLAR WIND RAM PRESSURE (NANOPASCALS)
C     PARAMOD: 2: DST-INDEX
C     PARAMOD: 3: IMF By (NANOTESLA)
C     PARAMOD: 4: IMF Bz (NANOTESLA)
C     PARAMOD: 5: G1 Index
C     PARAMOD: 6: G2 Index
      DO 223 i=10,15
      call get_command_argument(i,argv)
      read(argv,*) PARMOD(i-9)
 223  CONTINUE

C
      CALL RECALC_08 (IYEAR,IDAY,IHOUR,MIN,ISEC,VGSEX,VGSEY,VGSEZ)

C   TRANSFORM GEOGRAPHICAL GEOCENTRIC COORDS INTO SOLAR WIND MAGNETOSPHERIC ONES:
C
      CALL GEOGSW_08 (XGEO(1),XGEO(2),XGEO(3),XGSW,YGSW,ZGSW,1)
C
c   SPECIFY TRACING PARAMETERS:
C
      DSMAX=1.0
C               (MAXIMAL SPACING BETWEEN THE FIELD LINE POINTS SET EQUAL TO 1 RE)
C
      ERR=0.0001
C                 (PERMISSIBLE STEP ERROR SET AT ERR=0.0001)
      RLIM=60.
C            (LIMIT THE TRACING REGION WITHIN R=60 Re)
C
      R0=1.+ALT_KM/6378.1
C            (LANDING POINT WILL BE CALCULATED ON THE SPHERE R=1,
C                   I.E. ON THE EARTH'S SURFACE)
      IOPT=0
C           (IN THIS EXAMPLE IOPT IS JUST A DUMMY PARAMETER,
C                 WHOSE VALUE DOES NOT MATTER)
C

C   TRACE THE FIELD LINE:
C    (TRACE THE LINE WITH A FOOTPOINT PARALLEL (-1) - SOUTHERN HEMISPHERE
C     OR ANTIPARALLEL (+1) - NORTHERN HEMISPHERE TO THE MAGNETIC FIELD )

C     NORTHERN TRACE
      CALL TRACE_08 (XGSW,YGSW,ZGSW,+1.0,DSMAX,ERR,RLIM,R0,IOPT,
     * PARMOD,T01_01,IGRF_GSW_08,XFN,YFN,ZFN,XXN,YYN,ZZN,MN,LMAX)

C     SOUTHERN TRACE
      CALL TRACE_08 (XGSW,YGSW,ZGSW,-1.0,DSMAX,ERR,RLIM,R0,IOPT,
     * PARMOD,T01_01,IGRF_GSW_08,XFS,YFS,ZFS,XXS,YYS,ZZS,MS,LMAX)

      RFS = SQRT(XFS**2+YFS**2+ZFS**2)
      RFN = SQRT(XFN**2+YFN**2+ZFN**2)

C   CREATE FULL TRACE
      DO 226 L=1,MN
      XX(L)=XXN(MN-L+1)
      YY(L)=YYN(MN-L+1)
      ZZ(L)=ZZN(MN-L+1)
 226  CONTINUE

      DO 227 L=1,MS
      XX(MN+L)=XXS(L+1)
      YY(MN+L)=YYS(L+1)
      ZZ(MN+L)=ZZS(L+1)
 227  CONTINUE

      M=MN+MS-1

C   CALCULATE RADIAL B CHANGE
      DO 225 L =1,M
      CALL BVALUE (XX(L),YY(L),ZZ(L),BX(L),BY(L),BZ(L),B(L),
     * IOPT,PARMOD,T01_01,IGRF_GSW_08)
      CALL BCARSP_08 (XX(L),YY(L),ZZ(L),BX(L),BY(L),BZ(L),
     * BR(L),BTHETA(L),BPHI(L))
      BRNORM(L) = BR(L)/B(L)
 225  CONTINUE

      DO 228 L =1,M-1
      IF (BRNORM(L)*BRNORM(L+1) .LT. 0.0) THEN
            EQL = L
      END IF
 228  CONTINUE

C   CONVERT BACK TO GEO COORINDATES
      DO 224 L=1,M
      CALL GEOGSW_08 (XXGEO(L),YYGEO(L),ZZGEO(L),XX(L),YY(L),ZZ(L),-1)
      CALL GEOGSW_08 (BXGEO(L),BYGEO(L),BZGEO(L),BX(L),BY(L),BZ(L),-1)
 224  CONTINUE

      FOOTNUM = 0

      IF (RFN .LT. R0+ALT_KM/6378.1) THEN
          IF (RFN .GT. 1.0) THEN
            FOOTNUM = FOOTNUM+1
          END IF
      END IF

      IF (RFS .LT. R0+ALT_KM/6378.1) THEN
          IF (RFS .GT. 1.0) THEN
            FOOTNUM = FOOTNUM+1
          END IF
      END IF

C   OUTPUT THE RESULTS
C   XGEO, YGEO, ZGEO [in RE], BXGEO, BYGEO, BR(GSW) [in nT]
       PRINT '(I2,16F20.5)',FOOTNUM, XXGEO(1), YYGEO(1), ZZGEO(1),
     *  XXGEO(M), YYGEO(M), ZZGEO(M),
     *  0.5*(XXGEO(EQL)+XXGEO(EQL+1)),
     * (YYGEO(EQL)+YYGEO(EQL+1))*0.5, (ZZGEO(EQL)+ZZGEO(EQL+1))*0.5,
     * (BXGEO(EQL)+BXGEO(EQL+1))*0.5,(BYGEO(EQL)+BYGEO(EQL+1))*0.5,
     * (BZGEO(EQL)+BZGEO(EQL+1))*0.5,(BRNORM(EQL)+BRNORM(EQL+1))*0.5,
     * BXGEO(MN),BYGEO(MN),BZGEO(MN)
C       PRINT '(7F20.5)',(XXGEO(L),YYGEO(L),ZZGEO(L),
C     * BXGEO(L),BYGEO(L),BZGEO(L),BR(L),L=1,M)

      END
