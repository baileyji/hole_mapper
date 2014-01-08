      SUBROUTINE sla_ADDET (RM, DM, EQ, RC, DC)
!+
!     - - - - - -
!      A D D E T
!     - - - - - -
!
!  Add the E-terms (elliptic component of annual aberration)
!  to a pre IAU 1976 mean place to conform to the old
!  catalogue convention (double precision)
!
!  Given:
!     RM,DM     dp     RA,Dec (radians) without E-terms
!     EQ        dp     Besselian epoch of mean equator and equinox
!
!  Returned:
!     RC,DC     dp     RA,Dec (radians) with E-terms included
!
!  Note:
!
!     Most star positions from pre-1984 optical catalogues (or
!     derived from astrometry using such stars) embody the
!     E-terms.  If it is necessary to convert a formal mean
!     place (for example a pulsar timing position) to one
!     consistent with such a star catalogue, then the RA,Dec
!     should be adjusted using this routine.
!
!  Reference:
!     Explanatory Supplement to the Astronomical Ephemeris,
!     section 2D, page 48.
!
!  Called:  sla_ETRMS, sla_DCS2C, sla_DCC2S, sla_DRANRM, sla_DRANGE
!
!  P.T.Wallace   Starlink   18 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RM,DM,EQ,RC,DC

      DOUBLE PRECISION sla_DRANRM

      DOUBLE PRECISION A(3),V(3)

      INTEGER I



!  E-terms vector
      CALL sla_ETRMS(EQ,A)

!  Spherical to Cartesian
      CALL sla_DCS2C(RM,DM,V)

!  Include the E-terms
      DO I=1,3
         V(I)=V(I)+A(I)
      END DO

!  Cartesian to spherical
      CALL sla_DCC2S(V,RC,DC)

!  Bring RA into conventional range
      RC=sla_DRANRM(RC)

      END
      SUBROUTINE sla_AFIN (STRING, IPTR, A, J)
!+
!     - - - - -
!      A F I N
!     - - - - -
!
!  Sexagesimal character string to angle (single precision)
!
!  Given:
!     STRING  c*(*)   string containing deg, arcmin, arcsec fields
!     IPTR      i     pointer to start of decode (1st = 1)
!
!  Returned:
!     IPTR      i     advanced past the decoded angle
!     A         r     angle in radians
!     J         i     status:  0 = OK
!                             +1 = default, A unchanged
!                             -1 = bad degrees      )
!                             -2 = bad arcminutes   )  (note 3)
!                             -3 = bad arcseconds   )
!
!  Example:
!
!    argument    before                           after
!
!    STRING      '-57 17 44.806  12 34 56.7'      unchanged
!    IPTR        1                                16 (points to 12...)
!    A           ?                                -1.00000
!    J           ?                                0
!
!    A further call to sla_AFIN, without adjustment of IPTR, will
!    decode the second angle, 12deg 34min 56.7sec.
!
!  Notes:
!
!     1)  The first three "fields" in STRING are degrees, arcminutes,
!         arcseconds, separated by spaces or commas.  The degrees field
!         may be signed, but not the others.  The decoding is carried
!         out by the DFLTIN routine and is free-format.
!
!     2)  Successive fields may be absent, defaulting to zero.  For
!         zero status, the only combinations allowed are degrees alone,
!         degrees and arcminutes, and all three fields present.  If all
!         three fields are omitted, a status of +1 is returned and A is
!         unchanged.  In all other cases A is changed.
!
!     3)  Range checking:
!
!           The degrees field is not range checked.  However, it is
!           expected to be integral unless the other two fields are
!           absent.
!
!           The arcminutes field is expected to be 0-59, and integral if
!           the arcseconds field is present.  If the arcseconds field
!           is absent, the arcminutes is expected to be 0-59.9999...
!
!           The arcseconds field is expected to be 0-59.9999...
!
!     4)  Decoding continues even when a check has failed.  Under these
!         circumstances the field takes the supplied value, defaulting
!         to zero, and the result A is computed and returned.
!
!     5)  Further fields after the three expected ones are not treated
!         as an error.  The pointer IPTR is left in the correct state
!         for further decoding with the present routine or with DFLTIN
!         etc.  See the example, above.
!
!     6)  If STRING contains hours, minutes, seconds instead of degrees
!         etc, or if the required units are turns (or days) instead of
!         radians, the result A should be multiplied as follows:
!
!           for        to obtain    multiply
!           STRING     A in         A by
!
!           d ' "      radians      1       =  1.0
!           d ' "      turns        1/2pi   =  0.1591549430918953358
!           h m s      radians      15      =  15.0
!           h m s      days         15/2pi  =  2.3873241463784300365
!
!  Called:  sla_DAFIN
!
!  P.T.Wallace   Starlink   13 September 1990
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) STRING
      INTEGER IPTR
      REAL A
      INTEGER J

      DOUBLE PRECISION AD



!  Call the double precision version
      CALL sla_DAFIN(STRING,IPTR,AD,J)
      IF (J.LE.0) A=REAL(AD)

      END
      DOUBLE PRECISION FUNCTION sla_AIRMAS (ZD)
!+
!     - - - - - - -
!      A I R M A S
!     - - - - - - -
!
!  Air mass at given zenith distance (double precision)
!
!  Given:
!     ZD     d     Observed zenith distance (radians)
!
!  The result is an estimate of the air mass, in units of that
!  at the zenith.
!
!  Notes:
!
!  1)  The "observed" zenith distance referred to above means "as
!      affected by refraction".
!
!  2)  Uses Hardie's (1962) polynomial fit to Bemporad's data for
!      the relative air mass, X, in units of thickness at the zenith
!      as tabulated by Schoenberg (1929). This is adequate for all
!      normal needs as it is accurate to better than 0.1% up to X =
!      6.8 and better than 1% up to X = 10. Bemporad's tabulated
!      values are unlikely to be trustworthy to such accuracy
!      because of variations in density, pressure and other
!      conditions in the atmosphere from those assumed in his work.
!
!  3)  The sign of the ZD is ignored.
!
!  4)  At zenith distances greater than about ZD = 87 degrees the
!      air mass is held constant to avoid arithmetic overflows.
!
!  References:
!     Hardie, R.H., 1962, in "Astronomical Techniques"
!        ed. W.A. Hiltner, University of Chicago Press, p180.
!     Schoenberg, E., 1929, Hdb. d. Ap.,
!        Berlin, Julius Springer, 2, 268.
!
!  Original code by P.W.Hill, St Andrews
!
!  P.T.Wallace   Starlink   18 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION ZD

      DOUBLE PRECISION SECZM1


      SECZM1 = 1D0/(COS(MIN(1.52D0,ABS(ZD))))-1D0
      sla_AIRMAS = 1D0 + SECZM1*(0.9981833D0 &
                  - SECZM1*(0.002875D0 + 0.0008083D0*SECZM1))

      END
      SUBROUTINE sla_ALTAZ (HA, DEC, PHI, &
                           AZ, AZD, AZDD, EL, ELD, ELDD, PA, PAD, PADD)
!+
!     - - - - - -
!      A L T A Z
!     - - - - - -
!
!  Positions, velocities and accelerations for an altazimuth
!  telescope mount.
!
!  (double precision)
!
!  Given:
!     HA      d     hour angle
!     DEC     d     declination
!     PHI     d     observatory latitude
!
!  Returned:
!     AZ      d     azimuth
!     AZD     d        "    velocity
!     AZDD    d        "    acceleration
!     EL      d     elevation
!     ELD     d         "     velocity
!     ELDD    d         "     acceleration
!     PA      d     parallactic angle
!     PAD     d         "      "   velocity
!     PADD    d         "      "   acceleration
!
!  Notes:
!
!  1)  Natural units are used throughout.  HA, DEC, PHI, AZ, EL
!      and ZD are in radians.  The velocities and accelerations
!      assume constant declination and constant rate of change of
!      hour angle (as for tracking a star);  the units of AZD, ELD
!      and PAD are radians per radian of HA, while the units of AZDD,
!      ELDD and PADD are radians per radian of HA squared.  To
!      convert into practical degree- and second-based units:
!
!        angles * 360/2pi -> degrees
!        velocities * (2pi/86400)*(360/2pi) -> degree/sec
!        accelerations * ((2pi/86400)**2)*(360/2pi) -> degree/sec/sec
!
!      Note that the seconds here are sidereal rather than SI.  One
!      sidereal second is about 0.99727 SI seconds.
!
!      The velocity and acceleration factors assume the sidereal
!      tracking case.  Their respective numerical values are (exactly)
!      1/240 and (approximately) 1/3300236.9.
!
!  2)  Azimuth is returned in the range 0-2pi;  north is zero,
!      and east is +pi/2.  Elevation and parallactic angle are
!      returned in the range +/-pi.  Position angle is +ve
!      for a star west of the meridian and is the angle NP-star-zenith.
!
!  3)  The latitude is geodetic as opposed to geocentric.  The
!      hour angle and declination are topocentric.  Refraction and
!      deficiencies in the telescope mounting are ignored.  The
!      purpose of the routine is to give the general form of the
!      quantities.  The details of a real telescope could profoundly
!      change the results, especially close to the zenith.
!
!  4)  No range checking of arguments is carried out.
!
!  5)  In applications which involve many such calculations, rather
!      than calling the present routine it will be more efficient to
!      use inline code, having previously computed fixed terms such
!      as sine and cosine of latitude, and (for tracking a star)
!      sine and cosine of declination.
!
!  P.T.Wallace   Starlink   3 May 2000
!
!  Copyright (C) 2000 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!

      IMPLICIT NONE

      DOUBLE PRECISION HA,DEC,PHI,AZ,AZD,AZDD,EL,ELD,ELDD,PA,PAD,PADD

      DOUBLE PRECISION DPI,D2PI,TINY
      PARAMETER (DPI=3.1415926535897932384626433832795D0, &
                D2PI=6.283185307179586476925286766559D0, &
                TINY=1D-30)

      DOUBLE PRECISION SH,CH,SD,CD,SP,CP,CHCD,SDCP,X,Y,Z,RSQ,R,A,E,C,S, &
                      Q,QD,AD,ED,EDR,ADD,EDD,QDD


!  Useful functions
      SH=SIN(HA)
      CH=COS(HA)
      SD=SIN(DEC)
      CD=COS(DEC)
      SP=SIN(PHI)
      CP=COS(PHI)
      CHCD=CH*CD
      SDCP=SD*CP
      X=-CHCD*SP+SDCP
      Y=-SH*CD
      Z=CHCD*CP+SD*SP
      RSQ=X*X+Y*Y
      R=SQRT(RSQ)

!  Azimuth and elevation
      IF (RSQ.EQ.0D0) THEN
         A=0D0
      ELSE
         A=ATAN2(Y,X)
      END IF
      IF (A.LT.0D0) A=A+D2PI
      E=ATAN2(Z,R)

!  Parallactic angle
      C=CD*SP-CH*SDCP
      S=SH*CP
      IF (C*C+S*S.GT.0) THEN
         Q=ATAN2(S,C)
      ELSE
         Q=DPI-HA
      END IF

!  Velocities and accelerations (clamped at zenith/nadir)
      IF (RSQ.LT.TINY) THEN
         RSQ=TINY
         R=SQRT(RSQ)
      END IF
      QD=-X*CP/RSQ
      AD=SP+Z*QD
      ED=CP*Y/R
      EDR=ED/R
      ADD=EDR*(Z*SP+(2D0-RSQ)*QD)
      EDD=-R*QD*AD
      QDD=EDR*(SP+2D0*Z*QD)

!  Results
      AZ=A
      AZD=AD
      AZDD=ADD
      EL=E
      ELD=ED
      ELDD=EDD
      PA=Q
      PAD=QD
      PADD=QDD

      END
      SUBROUTINE sla_AMP (RA, DA, DATE, EQ, RM, DM)
!+
!     - - - -
!      A M P
!     - - - -
!
!  Convert star RA,Dec from geocentric apparent to mean place
!
!  The mean coordinate system is the post IAU 1976 system,
!  loosely called FK5.
!
!  Given:
!     RA       d      apparent RA (radians)
!     DA       d      apparent Dec (radians)
!     DATE     d      TDB for apparent place (JD-2400000.5)
!     EQ       d      equinox:  Julian epoch of mean place
!
!  Returned:
!     RM       d      mean RA (radians)
!     DM       d      mean Dec (radians)
!
!  References:
!     1984 Astronomical Almanac, pp B39-B41.
!     (also Lederle & Schwan, Astron. Astrophys. 134,
!      1-6, 1984)
!
!  Notes:
!
!  1)  The distinction between the required TDB and TT is always
!      negligible.  Moreover, for all but the most critical
!      applications UTC is adequate.
!
!  2)  Iterative techniques are used for the aberration and light
!      deflection corrections so that the routines sla_AMP (or
!      sla_AMPQK) and sla_MAP (or sla_MAPQK) are accurate inverses;
!      even at the edge of the Sun's disc the discrepancy is only
!      about 1 nanoarcsecond.
!
!  3)  Where multiple apparent places are to be converted to mean
!      places, for a fixed date and equinox, it is more efficient to
!      use the sla_MAPPA routine to compute the required parameters
!      once, followed by one call to sla_AMPQK per star.
!
!  4)  The accuracy is sub-milliarcsecond, limited by the
!      precession-nutation model (IAU 1976 precession, Shirai &
!      Fukushima 2001 forced nutation and precession corrections).
!
!  5)  The accuracy is further limited by the routine sla_EVP, called
!      by sla_MAPPA, which computes the Earth position and velocity
!      using the methods of Stumpff.  The maximum error is about
!      0.3 mas.
!
!  Called:  sla_MAPPA, sla_AMPQK
!
!  P.T.Wallace   Starlink   17 September 2001
!
!  Copyright (C) 2001 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RA,DA,DATE,EQ,RM,DM

      DOUBLE PRECISION AMPRMS(21)



      CALL sla_MAPPA(EQ,DATE,AMPRMS)
      CALL sla_AMPQK(RA,DA,AMPRMS,RM,DM)

      END
      SUBROUTINE sla_AMPQK (RA, DA, AMPRMS, RM, DM)
!+
!     - - - - - -
!      A M P Q K
!     - - - - - -
!
!  Convert star RA,Dec from geocentric apparent to mean place
!
!  The mean coordinate system is the post IAU 1976 system,
!  loosely called FK5.
!
!  Use of this routine is appropriate when efficiency is important
!  and where many star positions are all to be transformed for
!  one epoch and equinox.  The star-independent parameters can be
!  obtained by calling the sla_MAPPA routine.
!
!  Given:
!     RA       d      apparent RA (radians)
!     DA       d      apparent Dec (radians)
!
!     AMPRMS   d(21)  star-independent mean-to-apparent parameters:
!
!       (1)      time interval for proper motion (Julian years)
!       (2-4)    barycentric position of the Earth (AU)
!       (5-7)    heliocentric direction of the Earth (unit vector)
!       (8)      (grav rad Sun)*2/(Sun-Earth distance)
!       (9-11)   ABV: barycentric Earth velocity in units of c
!       (12)     sqrt(1-v**2) where v=modulus(ABV)
!       (13-21)  precession/nutation (3,3) matrix
!
!  Returned:
!     RM       d      mean RA (radians)
!     DM       d      mean Dec (radians)
!
!  References:
!     1984 Astronomical Almanac, pp B39-B41.
!     (also Lederle & Schwan, Astron. Astrophys. 134,
!      1-6, 1984)
!
!  Note:
!
!     Iterative techniques are used for the aberration and
!     light deflection corrections so that the routines
!     sla_AMP (or sla_AMPQK) and sla_MAP (or sla_MAPQK) are
!     accurate inverses;  even at the edge of the Sun's disc
!     the discrepancy is only about 1 nanoarcsecond.
!
!  Called:  sla_DCS2C, sla_DIMXV, sla_DVDV, sla_DVN, sla_DCC2S,
!           sla_DRANRM
!
!  P.T.Wallace   Starlink   7 May 2000
!
!  Copyright (C) 2000 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RA,DA,AMPRMS(21),RM,DM

      INTEGER I,J

      DOUBLE PRECISION GR2E,AB1,EHN(3),ABV(3),P3(3),P2(3), &
                      AB1P1,P1DV,P1DVP1,P1(3),W,PDE,PDEP1,P(3)

      DOUBLE PRECISION sla_DVDV,sla_DRANRM



!  Unpack scalar and vector parameters
      GR2E = AMPRMS(8)
      AB1 = AMPRMS(12)
      DO I=1,3
         EHN(I) = AMPRMS(I+4)
         ABV(I) = AMPRMS(I+8)
      END DO

!  Apparent RA,Dec to Cartesian
      CALL sla_DCS2C(RA,DA,P3)

!  Precession and nutation
      CALL sla_DIMXV(AMPRMS(13),P3,P2)

!  Aberration
      AB1P1 = AB1+1D0
      DO I=1,3
         P1(I) = P2(I)
      END DO
      DO J=1,2
         P1DV = sla_DVDV(P1,ABV)
         P1DVP1 = 1D0+P1DV
         W = 1D0+P1DV/AB1P1
         DO I=1,3
            P1(I) = (P1DVP1*P2(I)-W*ABV(I))/AB1
         END DO
         CALL sla_DVN(P1,P3,W)
         DO I=1,3
            P1(I) = P3(I)
         END DO
      END DO

!  Light deflection
      DO I=1,3
         P(I) = P1(I)
      END DO
      DO J=1,5
         PDE = sla_DVDV(P,EHN)
         PDEP1 = 1D0+PDE
         W = PDEP1-GR2E*PDE
         DO I=1,3
            P(I) = (PDEP1*P1(I)-GR2E*EHN(I))/W
         END DO
         CALL sla_DVN(P,P2,W)
         DO I=1,3
            P(I) = P2(I)
         END DO
      END DO

!  Mean RA,Dec
      CALL sla_DCC2S(P,RM,DM)
      RM = sla_DRANRM(RM)

      END
      SUBROUTINE sla_AOP (RAP, DAP, DATE, DUT, ELONGM, PHIM, HM, &
                         XP, YP, TDK, PMB, RH, WL, TLR, &
                         AOB, ZOB, HOB, DOB, ROB)
!+
!     - - - -
!      A O P
!     - - - -
!
!  Apparent to observed place, for optical sources distant from
!  the solar system.
!
!  Given:
!     RAP    d      geocentric apparent right ascension
!     DAP    d      geocentric apparent declination
!     DATE   d      UTC date/time (Modified Julian Date, JD-2400000.5)
!     DUT    d      delta UT:  UT1-UTC (UTC seconds)
!     ELONGM d      mean longitude of the observer (radians, east +ve)
!     PHIM   d      mean geodetic latitude of the observer (radians)
!     HM     d      observer's height above sea level (metres)
!     XP     d      polar motion x-coordinate (radians)
!     YP     d      polar motion y-coordinate (radians)
!     TDK    d      local ambient temperature (DegK; std=273.15D0)
!     PMB    d      local atmospheric pressure (mB; std=1013.25D0)
!     RH     d      local relative humidity (in the range 0D0-1D0)
!     WL     d      effective wavelength (micron, e.g. 0.55D0)
!     TLR    d      tropospheric lapse rate (DegK/metre, e.g. 0.0065D0)
!
!  Returned:
!     AOB    d      observed azimuth (radians: N=0,E=90)
!     ZOB    d      observed zenith distance (radians)
!     HOB    d      observed Hour Angle (radians)
!     DOB    d      observed Declination (radians)
!     ROB    d      observed Right Ascension (radians)
!
!  Notes:
!
!   1)  This routine returns zenith distance rather than elevation
!       in order to reflect the fact that no allowance is made for
!       depression of the horizon.
!
!   2)  The accuracy of the result is limited by the corrections for
!       refraction.  Providing the meteorological parameters are
!       known accurately and there are no gross local effects, the
!       predicted apparent RA,Dec should be within about 0.1 arcsec
!       for a zenith distance of less than 70 degrees.  Even at a
!       topocentric zenith distance of 90 degrees, the accuracy in
!       elevation should be better than 1 arcmin;  useful results
!       are available for a further 3 degrees, beyond which the
!       sla_REFRO routine returns a fixed value of the refraction.
!       The complementary routines sla_AOP (or sla_AOPQK) and sla_OAP
!       (or sla_OAPQK) are self-consistent to better than 1 micro-
!       arcsecond all over the celestial sphere.
!
!   3)  It is advisable to take great care with units, as even
!       unlikely values of the input parameters are accepted and
!       processed in accordance with the models used.
!
!   4)  "Apparent" place means the geocentric apparent right ascension
!       and declination, which is obtained from a catalogue mean place
!       by allowing for space motion, parallax, precession, nutation,
!       annual aberration, and the Sun's gravitational lens effect.  For
!       star positions in the FK5 system (i.e. J2000), these effects can
!       be applied by means of the sla_MAP etc routines.  Starting from
!       other mean place systems, additional transformations will be
!       needed;  for example, FK4 (i.e. B1950) mean places would first
!       have to be converted to FK5, which can be done with the
!       sla_FK425 etc routines.
!
!   5)  "Observed" Az,El means the position that would be seen by a
!       perfect theodolite located at the observer.  This is obtained
!       from the geocentric apparent RA,Dec by allowing for Earth
!       orientation and diurnal aberration, rotating from equator
!       to horizon coordinates, and then adjusting for refraction.
!       The HA,Dec is obtained by rotating back into equatorial
!       coordinates, using the geodetic latitude corrected for polar
!       motion, and is the position that would be seen by a perfect
!       equatorial located at the observer and with its polar axis
!       aligned to the Earth's axis of rotation (n.b. not to the
!       refracted pole).  Finally, the RA is obtained by subtracting
!       the HA from the local apparent ST.
!
!   6)  To predict the required setting of a real telescope, the
!       observed place produced by this routine would have to be
!       adjusted for the tilt of the azimuth or polar axis of the
!       mounting (with appropriate corrections for mount flexures),
!       for non-perpendicularity between the mounting axes, for the
!       position of the rotator axis and the pointing axis relative
!       to it, for tube flexure, for gear and encoder errors, and
!       finally for encoder zero points.  Some telescopes would, of
!       course, exhibit other properties which would need to be
!       accounted for at the appropriate point in the sequence.
!
!   7)  This routine takes time to execute, due mainly to the
!       rigorous integration used to evaluate the refraction.
!       For processing multiple stars for one location and time,
!       call sla_AOPPA once followed by one call per star to sla_AOPQK.
!       Where a range of times within a limited period of a few hours
!       is involved, and the highest precision is not required, call
!       sla_AOPPA once, followed by a call to sla_AOPPAT each time the
!       time changes, followed by one call per star to sla_AOPQK.
!
!   8)  The DATE argument is UTC expressed as an MJD.  This is,
!       strictly speaking, wrong, because of leap seconds.  However,
!       as long as the delta UT and the UTC are consistent there
!       are no difficulties, except during a leap second.  In this
!       case, the start of the 61st second of the final minute should
!       begin a new MJD day and the old pre-leap delta UT should
!       continue to be used.  As the 61st second completes, the MJD
!       should revert to the start of the day as, simultaneously,
!       the delta UTC changes by one second to its post-leap new value.
!
!   9)  The delta UT (UT1-UTC) is tabulated in IERS circulars and
!       elsewhere.  It increases by exactly one second at the end of
!       each UTC leap second, introduced in order to keep delta UT
!       within +/- 0.9 seconds.
!
!  10)  IMPORTANT -- TAKE CARE WITH THE LONGITUDE SIGN CONVENTION.
!       The longitude required by the present routine is east-positive,
!       in accordance with geographical convention (and right-handed).
!       In particular, note that the longitudes returned by the
!       sla_OBS routine are west-positive, following astronomical
!       usage, and must be reversed in sign before use in the present
!       routine.
!
!  11)  The polar coordinates XP,YP can be obtained from IERS
!       circulars and equivalent publications.  The maximum amplitude
!       is about 0.3 arcseconds.  If XP,YP values are unavailable,
!       use XP=YP=0D0.  See page B60 of the 1988 Astronomical Almanac
!       for a definition of the two angles.
!
!  12)  The height above sea level of the observing station, HM,
!       can be obtained from the Astronomical Almanac (Section J
!       in the 1988 edition), or via the routine sla_OBS.  If P,
!       the pressure in millibars, is available, an adequate
!       estimate of HM can be obtained from the expression
!
!             HM ~ -29.3D0*TSL*LOG(P/1013.25D0).
!
!       where TSL is the approximate sea-level air temperature in
!       deg K (see Astrophysical Quantities, C.W.Allen, 3rd edition,
!       section 52).  Similarly, if the pressure P is not known,
!       it can be estimated from the height of the observing
!       station, HM as follows:
!
!             P ~ 1013.25D0*EXP(-HM/(29.3D0*TSL)).
!
!       Note, however, that the refraction is proportional to the
!       pressure and that an accurate P value is important for
!       precise work.
!
!  13)  The azimuths etc produced by the present routine are with
!       respect to the celestial pole.  Corrections to the terrestrial
!       pole can be computed using sla_POLMO.
!
!  Called:  sla_AOPPA, sla_AOPQK
!
!  P.T.Wallace   Starlink   23 May 2002
!
!  Copyright (C) 2002 P.T.Wallace and CCLRC
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RAP,DAP,DATE,DUT,ELONGM,PHIM,HM, &
                      XP,YP,TDK,PMB,RH,WL,TLR,AOB,ZOB,HOB,DOB,ROB

      DOUBLE PRECISION AOPRMS(14)


      CALL sla_AOPPA(DATE,DUT,ELONGM,PHIM,HM,XP,YP,TDK,PMB,RH,WL,TLR, &
                    AOPRMS)
      CALL sla_AOPQK(RAP,DAP,AOPRMS,AOB,ZOB,HOB,DOB,ROB)

      END
      SUBROUTINE sla_AOPPA (DATE, DUT, ELONGM, PHIM, HM, &
                           XP, YP, TDK, PMB, RH, WL, TLR, AOPRMS)
!+
!     - - - - - -
!      A O P P A
!     - - - - - -
!
!  Precompute apparent to observed place parameters required by
!  sla_AOPQK and sla_OAPQK.
!
!  Given:
!     DATE   d      UTC date/time (modified Julian Date, JD-2400000.5)
!     DUT    d      delta UT:  UT1-UTC (UTC seconds)
!     ELONGM d      mean longitude of the observer (radians, east +ve)
!     PHIM   d      mean geodetic latitude of the observer (radians)
!     HM     d      observer's height above sea level (metres)
!     XP     d      polar motion x-coordinate (radians)
!     YP     d      polar motion y-coordinate (radians)
!     TDK    d      local ambient temperature (DegK; std=273.15D0)
!     PMB    d      local atmospheric pressure (mB; std=1013.25D0)
!     RH     d      local relative humidity (in the range 0D0-1D0)
!     WL     d      effective wavelength (micron, e.g. 0.55D0)
!     TLR    d      tropospheric lapse rate (DegK/metre, e.g. 0.0065D0)
!
!  Returned:
!     AOPRMS d(14)  star-independent apparent-to-observed parameters:
!
!       (1)      geodetic latitude (radians)
!       (2,3)    sine and cosine of geodetic latitude
!       (4)      magnitude of diurnal aberration vector
!       (5)      height (HM)
!       (6)      ambient temperature (TDK)
!       (7)      pressure (PMB)
!       (8)      relative humidity (RH)
!       (9)      wavelength (WL)
!       (10)     lapse rate (TLR)
!       (11,12)  refraction constants A and B (radians)
!       (13)     longitude + eqn of equinoxes + sidereal DUT (radians)
!       (14)     local apparent sidereal time (radians)
!
!  Notes:
!
!   1)  It is advisable to take great care with units, as even
!       unlikely values of the input parameters are accepted and
!       processed in accordance with the models used.
!
!   2)  The DATE argument is UTC expressed as an MJD.  This is,
!       strictly speaking, improper, because of leap seconds.  However,
!       as long as the delta UT and the UTC are consistent there
!       are no difficulties, except during a leap second.  In this
!       case, the start of the 61st second of the final minute should
!       begin a new MJD day and the old pre-leap delta UT should
!       continue to be used.  As the 61st second completes, the MJD
!       should revert to the start of the day as, simultaneously,
!       the delta UTC changes by one second to its post-leap new value.
!
!   3)  The delta UT (UT1-UTC) is tabulated in IERS circulars and
!       elsewhere.  It increases by exactly one second at the end of
!       each UTC leap second, introduced in order to keep delta UT
!       within +/- 0.9 seconds.
!
!   4)  IMPORTANT -- TAKE CARE WITH THE LONGITUDE SIGN CONVENTION.
!       The longitude required by the present routine is east-positive,
!       in accordance with geographical convention (and right-handed).
!       In particular, note that the longitudes returned by the
!       sla_OBS routine are west-positive, following astronomical
!       usage, and must be reversed in sign before use in the present
!       routine.
!
!   5)  The polar coordinates XP,YP can be obtained from IERS
!       circulars and equivalent publications.  The maximum amplitude
!       is about 0.3 arcseconds.  If XP,YP values are unavailable,
!       use XP=YP=0D0.  See page B60 of the 1988 Astronomical Almanac
!       for a definition of the two angles.
!
!   6)  The height above sea level of the observing station, HM,
!       can be obtained from the Astronomical Almanac (Section J
!       in the 1988 edition), or via the routine sla_OBS.  If P,
!       the pressure in millibars, is available, an adequate
!       estimate of HM can be obtained from the expression
!
!             HM ~ -29.3D0*TSL*LOG(P/1013.25D0).
!
!       where TSL is the approximate sea-level air temperature in
!       deg K (see Astrophysical Quantities, C.W.Allen, 3rd edition,
!       section 52).  Similarly, if the pressure P is not known,
!       it can be estimated from the height of the observing
!       station, HM as follows:
!
!             P ~ 1013.25D0*EXP(-HM/(29.3D0*TSL)).
!
!       Note, however, that the refraction is proportional to the
!       pressure and that an accurate P value is important for
!       precise work.
!
!   7)  Repeated, computationally-expensive, calls to sla_AOPPA for
!       times that are very close together can be avoided by calling
!       sla_AOPPA just once and then using sla_AOPPAT for the subsequent
!       times.  Fresh calls to sla_AOPPA will be needed only when
!       changes in the precession have grown to unacceptable levels or
!       when anything affecting the refraction has changed.
!
!  Called:  sla_GEOC, sla_REFCO, sla_EQEQX, sla_AOPPAT
!
!  P.T.Wallace   Starlink   24 October 2003
!
!  Copyright (C) 2003 P.T.Wallace and CCLRC
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,DUT,ELONGM,PHIM,HM,XP,YP,TDK,PMB, &
                      RH,WL,TLR,AOPRMS(14)

      DOUBLE PRECISION sla_EQEQX

!  2Pi
      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=6.283185307179586476925287D0)

!  Seconds of time to radians
      DOUBLE PRECISION S2R
      PARAMETER (S2R=7.272205216643039903848712D-5)

!  Speed of light (AU per day)
      DOUBLE PRECISION C
      PARAMETER (C=173.14463331D0)

!  Ratio between solar and sidereal time
      DOUBLE PRECISION SOLSID
      PARAMETER (SOLSID=1.00273790935D0)

      DOUBLE PRECISION CPHIM,XT,YT,ZT,XC,YC,ZC,ELONG,PHI,UAU,VAU



!  Observer's location corrected for polar motion
      CPHIM = COS(PHIM)
      XT = COS(ELONGM)*CPHIM
      YT = SIN(ELONGM)*CPHIM
      ZT = SIN(PHIM)
      XC = XT-XP*ZT
      YC = YT+YP*ZT
      ZC = XP*XT-YP*YT+ZT
      IF (XC.EQ.0D0.AND.YC.EQ.0D0) THEN
         ELONG = 0D0
      ELSE
         ELONG = ATAN2(YC,XC)
      END IF
      PHI = ATAN2(ZC,SQRT(XC*XC+YC*YC))
      AOPRMS(1) = PHI
      AOPRMS(2) = SIN(PHI)
      AOPRMS(3) = COS(PHI)

!  Magnitude of the diurnal aberration vector
      CALL sla_GEOC(PHI,HM,UAU,VAU)
      AOPRMS(4) = D2PI*UAU*SOLSID/C

!  Copy the refraction parameters and compute the A & B constants
      AOPRMS(5) = HM
      AOPRMS(6) = TDK
      AOPRMS(7) = PMB
      AOPRMS(8) = RH
      AOPRMS(9) = WL
      AOPRMS(10) = TLR
      CALL sla_REFCO(HM,TDK,PMB,RH,WL,PHI,TLR,1D-10, &
                    AOPRMS(11),AOPRMS(12))

!  Longitude + equation of the equinoxes + sidereal equivalent of DUT
!  (ignoring change in equation of the equinoxes between UTC and TDB)
      AOPRMS(13) = ELONG+sla_EQEQX(DATE)+DUT*SOLSID*S2R

!  Sidereal time
      CALL sla_AOPPAT(DATE,AOPRMS)

      END
      SUBROUTINE sla_AOPPAT (DATE, AOPRMS)
!+
!     - - - - - - -
!      A O P P A T
!     - - - - - - -
!
!  Recompute the sidereal time in the apparent to observed place
!  star-independent parameter block.
!
!  Given:
!     DATE   d      UTC date/time (modified Julian Date, JD-2400000.5)
!                   (see AOPPA source for comments on leap seconds)
!
!     AOPRMS d(14)  star-independent apparent-to-observed parameters
!
!       (1-12)   not required
!       (13)     longitude + eqn of equinoxes + sidereal DUT
!       (14)     not required
!
!  Returned:
!     AOPRMS d(14)  star-independent apparent-to-observed parameters:
!
!       (1-13)   not changed
!       (14)     local apparent sidereal time (radians)
!
!  For more information, see sla_AOPPA.
!
!  Called:  sla_GMST
!
!  P.T.Wallace   Starlink   1 July 1993
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,AOPRMS(14)

      DOUBLE PRECISION sla_GMST



      AOPRMS(14) = sla_GMST(DATE)+AOPRMS(13)

      END
      SUBROUTINE sla_AOPQK (RAP, DAP, AOPRMS, AOB, ZOB, HOB, DOB, ROB)
!+
!     - - - - - -
!      A O P Q K
!     - - - - - -
!
!  Quick apparent to observed place (but see note 8, below, for
!  remarks about speed).
!
!  Given:
!     RAP    d      geocentric apparent right ascension
!     DAP    d      geocentric apparent declination
!     AOPRMS d(14)  star-independent apparent-to-observed parameters:
!
!       (1)      geodetic latitude (radians)
!       (2,3)    sine and cosine of geodetic latitude
!       (4)      magnitude of diurnal aberration vector
!       (5)      height (HM)
!       (6)      ambient temperature (T)
!       (7)      pressure (P)
!       (8)      relative humidity (RH)
!       (9)      wavelength (WL)
!       (10)     lapse rate (TLR)
!       (11,12)  refraction constants A and B (radians)
!       (13)     longitude + eqn of equinoxes + sidereal DUT (radians)
!       (14)     local apparent sidereal time (radians)
!
!  Returned:
!     AOB    d      observed azimuth (radians: N=0,E=90)
!     ZOB    d      observed zenith distance (radians)
!     HOB    d      observed Hour Angle (radians)
!     DOB    d      observed Declination (radians)
!     ROB    d      observed Right Ascension (radians)
!
!  Notes:
!
!   1)  This routine returns zenith distance rather than elevation
!       in order to reflect the fact that no allowance is made for
!       depression of the horizon.
!
!   2)  The accuracy of the result is limited by the corrections for
!       refraction.  Providing the meteorological parameters are
!       known accurately and there are no gross local effects, the
!       observed RA,Dec predicted by this routine should be within
!       about 0.1 arcsec for a zenith distance of less than 70 degrees.
!       Even at a topocentric zenith distance of 90 degrees, the
!       accuracy in elevation should be better than 1 arcmin;  useful
!       results are available for a further 3 degrees, beyond which
!       the sla_REFRO routine returns a fixed value of the refraction.
!       The complementary routines sla_AOP (or sla_AOPQK) and sla_OaAP
!       (or sla_OAPQK) are self-consistent to better than 1 micro-
!       arcsecond all over the celestial sphere.
!
!   3)  It is advisable to take great care with units, as even
!       unlikely values of the input parameters are accepted and
!       processed in accordance with the models used.
!
!   4)  "Apparent" place means the geocentric apparent right ascension
!       and declination, which is obtained from a catalogue mean place
!       by allowing for space motion, parallax, precession, nutation,
!       annual aberration, and the Sun's gravitational lens effect.  For
!       star positions in the FK5 system (i.e. J2000), these effects can
!       be applied by means of the sla_MAP etc routines.  Starting from
!       other mean place systems, additional transformations will be
!       needed;  for example, FK4 (i.e. B1950) mean places would first
!       have to be converted to FK5, which can be done with the
!       sla_FK425 etc routines.
!
!   5)  "Observed" Az,El means the position that would be seen by a
!       perfect theodolite located at the observer.  This is obtained
!       from the geocentric apparent RA,Dec by allowing for Earth
!       orientation and diurnal aberration, rotating from equator
!       to horizon coordinates, and then adjusting for refraction.
!       The HA,Dec is obtained by rotating back into equatorial
!       coordinates, using the geodetic latitude corrected for polar
!       motion, and is the position that would be seen by a perfect
!       equatorial located at the observer and with its polar axis
!       aligned to the Earth's axis of rotation (n.b. not to the
!       refracted pole).  Finally, the RA is obtained by subtracting
!       the HA from the local apparent ST.
!
!   6)  To predict the required setting of a real telescope, the
!       observed place produced by this routine would have to be
!       adjusted for the tilt of the azimuth or polar axis of the
!       mounting (with appropriate corrections for mount flexures),
!       for non-perpendicularity between the mounting axes, for the
!       position of the rotator axis and the pointing axis relative
!       to it, for tube flexure, for gear and encoder errors, and
!       finally for encoder zero points.  Some telescopes would, of
!       course, exhibit other properties which would need to be
!       accounted for at the appropriate point in the sequence.
!
!   7)  The star-independent apparent-to-observed-place parameters
!       in AOPRMS may be computed by means of the sla_AOPPA routine.
!       If nothing has changed significantly except the time, the
!       sla_AOPPAT routine may be used to perform the requisite
!       partial recomputation of AOPRMS.
!
!   8)  At zenith distances beyond about 76 degrees, the need for
!       special care with the corrections for refraction causes a
!       marked increase in execution time.  Moreover, the effect
!       gets worse with increasing zenith distance.  Adroit
!       programming in the calling application may allow the
!       problem to be reduced.  Prepare an alternative AOPRMS array,
!       computed for zero air-pressure;  this will disable the
!       refraction corrections and cause rapid execution.  Using
!       this AOPRMS array, a preliminary call to the present routine
!       will, depending on the application, produce a rough position
!       which may be enough to establish whether the full, slow
!       calculation (using the real AOPRMS array) is worthwhile.
!       For example, there would be no need for the full calculation
!       if the preliminary call had already established that the
!       source was well below the elevation limits for a particular
!       telescope.
!
!  9)   The azimuths etc produced by the present routine are with
!       respect to the celestial pole.  Corrections to the terrestrial
!       pole can be computed using sla_POLMO.
!
!  Called:  sla_DCS2C, sla_REFZ, sla_REFRO, sla_DCC2S, sla_DRANRM
!
!  P.T.Wallace   Starlink   24 October 2003
!
!  Copyright (C) 2003 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RAP,DAP,AOPRMS(14),AOB,ZOB,HOB,DOB,ROB

!  Breakpoint for fast/slow refraction algorithm:
!  ZD greater than arctan(4), (see sla_REFCO routine)
!  or vector Z less than cosine(arctan(Z)) = 1/sqrt(17)
      DOUBLE PRECISION ZBREAK
      PARAMETER (ZBREAK=0.242535625D0)

      INTEGER I

      DOUBLE PRECISION SPHI,CPHI,ST,V(3),XHD,YHD,ZHD,DIURAB,F, &
                      XHDT,YHDT,ZHDT,XAET,YAET,ZAET,AZOBS, &
                      ZDT,REFA,REFB,ZDOBS,DZD,DREF,CE, &
                      XAEO,YAEO,ZAEO,HMOBS,DCOBS,RAOBS

      DOUBLE PRECISION sla_DRANRM



!  Sin, cos of latitude
      SPHI = AOPRMS(2)
      CPHI = AOPRMS(3)

!  Local apparent sidereal time
      ST = AOPRMS(14)

!  Apparent RA,Dec to Cartesian -HA,Dec
      CALL sla_DCS2C(RAP-ST,DAP,V)
      XHD = V(1)
      YHD = V(2)
      ZHD = V(3)

!  Diurnal aberration
      DIURAB = AOPRMS(4)
      F = (1D0-DIURAB*YHD)
      XHDT = F*XHD
      YHDT = F*(YHD+DIURAB)
      ZHDT = F*ZHD

!  Cartesian -HA,Dec to Cartesian Az,El (S=0,E=90)
      XAET = SPHI*XHDT-CPHI*ZHDT
      YAET = YHDT
      ZAET = CPHI*XHDT+SPHI*ZHDT

!  Azimuth (N=0,E=90)
      IF (XAET.EQ.0D0.AND.YAET.EQ.0D0) THEN
         AZOBS = 0D0
      ELSE
         AZOBS = ATAN2(YAET,-XAET)
      END IF

!  Topocentric zenith distance
      ZDT = ATAN2(SQRT(XAET*XAET+YAET*YAET),ZAET)

!
!  Refraction
!  ----------

!  Fast algorithm using two constant model
      REFA = AOPRMS(11)
      REFB = AOPRMS(12)
      CALL sla_REFZ(ZDT,REFA,REFB,ZDOBS)

!  Large zenith distance?
      IF (COS(ZDOBS).LT.ZBREAK) THEN

!     Yes: use rigorous algorithm

!     Initialize loop (maximum of 10 iterations)
         I = 1
         DZD = 1D1
         DO WHILE (ABS(DZD).GT.1D-10.AND.I.LE.10)

!        Compute refraction using current estimate of observed ZD
            CALL sla_REFRO(ZDOBS,AOPRMS(5),AOPRMS(6),AOPRMS(7), &
                          AOPRMS(8),AOPRMS(9),AOPRMS(1), &
                          AOPRMS(10),1D-8,DREF)

!        Remaining discrepancy
            DZD = ZDOBS+DREF-ZDT

!        Update the estimate
            ZDOBS = ZDOBS-DZD

!        Increment the iteration counter
            I = I+1
         END DO
      END IF

!  To Cartesian Az/ZD
      CE = SIN(ZDOBS)
      XAEO = -COS(AZOBS)*CE
      YAEO = SIN(AZOBS)*CE
      ZAEO = COS(ZDOBS)

!  Cartesian Az/ZD to Cartesian -HA,Dec
      V(1) = SPHI*XAEO+CPHI*ZAEO
      V(2) = YAEO
      V(3) = -CPHI*XAEO+SPHI*ZAEO

!  To spherical -HA,Dec
      CALL sla_DCC2S(V,HMOBS,DCOBS)

!  Right Ascension
      RAOBS = sla_DRANRM(ST+HMOBS)

!  Return the results
      AOB = AZOBS
      ZOB = ZDOBS
      HOB = -HMOBS
      DOB = DCOBS
      ROB = RAOBS

      END
      SUBROUTINE sla_ATMDSP (TDK, PMB, RH, WL1, A1, B1, WL2, A2, B2)
!+
!     - - - - - - -
!      A T M D S P
!     - - - - - - -
!
!  Apply atmospheric-dispersion adjustments to refraction coefficients.
!
!  Given:
!     TDK       d       ambient temperature, degrees K
!     PMB       d       ambient pressure, millibars
!     RH        d       ambient relative humidity, 0-1
!     WL1       d       reference wavelength, micrometre (0.4D0 recommended)
!     A1        d       refraction coefficient A for wavelength WL1 (radians)
!     B1        d       refraction coefficient B for wavelength WL1 (radians)
!     WL2       d       wavelength for which adjusted A,B required
!
!  Returned:
!     A2        d       refraction coefficient A for wavelength WL2 (radians)
!     B2        d       refraction coefficient B for wavelength WL2 (radians)
!
!  Notes:
!
!  1  To use this routine, first call sla_REFCO specifying WL1 as the
!     wavelength.  This yields refraction coefficients A1,B1, correct
!     for that wavelength.  Subsequently, calls to sla_ATMDSP specifying
!     different wavelengths will produce new, slightly adjusted
!     refraction coefficients which apply to the specified wavelength.
!
!  2  Most of the atmospheric dispersion happens between 0.7 micrometre
!     and the UV atmospheric cutoff, and the effect increases strongly
!     towards the UV end.  For this reason a blue reference wavelength
!     is recommended, for example 0.4 micrometres.
!
!  3  The accuracy, for this set of conditions:
!
!        height above sea level    2000 m
!                      latitude    29 deg
!                      pressure    793 mB
!                   temperature    17 degC
!                      humidity    50%
!                    lapse rate    0.0065 degC/m
!          reference wavelength    0.4 micrometre
!                star elevation    15 deg
!
!     is about 2.5 mas RMS between 0.3 and 1.0 micrometres, and stays
!     within 4 mas for the whole range longward of 0.3 micrometres
!     (compared with a total dispersion from 0.3 to 20.0 micrometres
!     of about 11 arcsec).  These errors are typical for ordinary
!     conditions and the given elevation;  in extreme conditions values
!     a few times this size may occur, while at higher elevations the
!     errors become much smaller.
!
!  4  If either wavelength exceeds 100 micrometres, the radio case
!     is assumed and the returned refraction coefficients are the
!     same as the given ones.  Note that radio refraction coefficients
!     cannot be turned into optical values using this routine, nor
!     vice versa.
!
!  5  The algorithm consists of calculation of the refractivity of the
!     air at the observer for the two wavelengths, using the methods
!     of the sla_REFRO routine, and then scaling of the two refraction
!     coefficients according to classical refraction theory.  This
!     amounts to scaling the A coefficient in proportion to (n-1) and
!     the B coefficient almost in the same ratio (see R.M.Green,
!     "Spherical Astronomy", Cambridge University Press, 1985).
!
!  P.T.Wallace   Starlink   1 April 2002
!
!  Copyright (C) 2002 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION TDK,PMB,RH,WL1,A1,B1,WL2,A2,B2

      DOUBLE PRECISION F,TDKOK,PMBOK,RHOK, &
                      PSAT,PWO,W1,WLOK,WLSQ,W2,DN1,DN2


!  Check for radio wavelengths
      IF (WL1.GT.100D0.OR.WL2.GT.100D0) THEN

!     Radio: no dispersion
         A2 = A1
         B2 = B1
      ELSE

!     Optical: keep arguments within safe bounds
         TDKOK = MIN(MAX(TDK,100D0),500D0)
         PMBOK = MIN(MAX(PMB,0D0),10000D0)
         RHOK = MIN(MAX(RH,0D0),1D0)

!     Atmosphere parameters at the observer
         PSAT = 10D0**(-8.7115D0+0.03477D0*TDKOK)
         PWO = RHOK*PSAT
         W1 = 11.2684D-6*PWO

!     Refractivity at the observer for first wavelength
         WLOK = MAX(WL1,0.1D0)
         WLSQ = WLOK*WLOK
         W2 = 77.5317D-6+(0.43909D-6+0.00367D-6/WLSQ)/WLSQ
         DN1 = (W2*PMBOK-W1)/TDKOK

!     Refractivity at the observer for second wavelength
         WLOK = MAX(WL2,0.1D0)
         WLSQ = WLOK*WLOK
         W2 = 77.5317D-6+(0.43909D-6+0.00367D-6/WLSQ)/WLSQ
         DN2 = (W2*PMBOK-W1)/TDKOK

!     Scale the refraction coefficients (see Green 4.31, p93)
         IF (DN1.NE.0D0) THEN
            F = DN2/DN1
            A2 = A1*F
            B2 = B1*F
            IF (DN1.NE.A1) B2=B2*(1D0+DN1*(DN1-DN2)/(2D0*(DN1-A1)))
         ELSE
            A2 = A1
            B2 = B1
         END IF
      END IF

      END
      SUBROUTINE sla__ATMS (RT, TT, DNT, GAMAL, R, DN, RDNDR)
!+
!     - - - - -
!      A T M S
!     - - - - -
!
!  Internal routine used by REFRO
!
!  Refractive index and derivative with respect to height for the
!  stratosphere.
!
!  Given:
!    RT      d    height of tropopause from centre of the Earth (metre)
!    TT      d    temperature at the tropopause (deg K)
!    DNT     d    refractive index at the tropopause
!    GAMAL   d    constant of the atmospheric model = G*MD/R
!    R       d    current distance from the centre of the Earth (metre)
!
!  Returned:
!    DN      d    refractive index at R
!    RDNDR   d    R * rate the refractive index is changing at R
!
!  P.T.Wallace   Starlink   14 July 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RT,TT,DNT,GAMAL,R,DN,RDNDR

      DOUBLE PRECISION B,W


      B = GAMAL/TT
      W = (DNT-1D0)*EXP(-B*(R-RT))
      DN = 1D0+W
      RDNDR = -R*B*W

      END
      SUBROUTINE sla__ATMT (R0, T0, ALPHA, GAMM2, DELM2, &
                           C1, C2, C3, C4, C5, C6, R, T, DN, RDNDR)
!+
!     - - - - -
!      A T M T
!     - - - - -
!
!  Internal routine used by REFRO
!
!  Refractive index and derivative with respect to height for the
!  troposphere.
!
!  Given:
!    R0      d    height of observer from centre of the Earth (metre)
!    T0      d    temperature at the observer (deg K)
!    ALPHA   d    alpha          )
!    GAMM2   d    gamma minus 2  ) see HMNAO paper
!    DELM2   d    delta minus 2  )
!    C1      d    useful term  )
!    C2      d    useful term  )
!    C3      d    useful term  ) see source
!    C4      d    useful term  ) of sla_REFRO
!    C5      d    useful term  )
!    C6      d    useful term  )
!    R       d    current distance from the centre of the Earth (metre)
!
!  Returned:
!    T       d    temperature at R (deg K)
!    DN      d    refractive index at R
!    RDNDR   d    R * rate the refractive index is changing at R
!
!  Note that in the optical case C5 and C6 are zero.
!
!  P.T.Wallace   Starlink   30 May 1997
!
!  Copyright (C) 1997 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION R0,T0,ALPHA,GAMM2,DELM2,C1,C2,C3,C4,C5,C6, &
                      R,T,DN,RDNDR

      DOUBLE PRECISION TT0,TT0GM2,TT0DM2


      T = MAX(MIN(T0-ALPHA*(R-R0),320D0),100D0)
      TT0 = T/T0
      TT0GM2 = TT0**GAMM2
      TT0DM2 = TT0**DELM2
      DN = 1D0+(C1*TT0GM2-(C2-C5/T)*TT0DM2)*TT0
      RDNDR = R*(-C3*TT0GM2+(C4-C6/TT0)*TT0DM2)

      END
      SUBROUTINE sla_AV2M (AXVEC, RMAT)
!+
!     - - - - -
!      A V 2 M
!     - - - - -
!
!  Form the rotation matrix corresponding to a given axial vector.
!
!  (single precision)
!
!  A rotation matrix describes a rotation about some arbitrary axis.
!  The axis is called the Euler axis, and the angle through which the
!  reference frame rotates is called the Euler angle.  The axial
!  vector supplied to this routine has the same direction as the
!  Euler axis, and its magnitude is the Euler angle in radians.
!
!  Given:
!    AXVEC  r(3)     axial vector (radians)
!
!  Returned:
!    RMAT   r(3,3)   rotation matrix
!
!  If AXVEC is null, the unit matrix is returned.
!
!  The reference frame rotates clockwise as seen looking along
!  the axial vector from the origin.
!
!  P.T.Wallace   Starlink   June 1989
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE
      REAL AXVEC(3),RMAT(3,3)
      REAL X,Y,Z,PHI,S,C,W



!  Euler angle - magnitude of axial vector - and functions
      X = AXVEC(1)
      Y = AXVEC(2)
      Z = AXVEC(3)
      PHI = SQRT(X*X+Y*Y+Z*Z)
      S = SIN(PHI)
      C = COS(PHI)
      W = 1.0-C

!  Euler axis - direction of axial vector (perhaps null)
      IF (PHI.NE.0.0) THEN
         X = X/PHI
         Y = Y/PHI
         Z = Z/PHI
      END IF

!  Compute the rotation matrix
      RMAT(1,1) = X*X*W+C
      RMAT(1,2) = X*Y*W+Z*S
      RMAT(1,3) = X*Z*W-Y*S
      RMAT(2,1) = X*Y*W-Z*S
      RMAT(2,2) = Y*Y*W+C
      RMAT(2,3) = Y*Z*W+X*S
      RMAT(3,1) = X*Z*W+Y*S
      RMAT(3,2) = Y*Z*W-X*S
      RMAT(3,3) = Z*Z*W+C

      END
      REAL FUNCTION sla_BEAR (A1, B1, A2, B2)
!+
!     - - - - -
!      B E A R
!     - - - - -
!
!  Bearing (position angle) of one point on a sphere relative to another
!  (single precision)
!
!  Given:
!     A1,B1    r    spherical coordinates of one point
!     A2,B2    r    spherical coordinates of the other point
!
!  (The spherical coordinates are RA,Dec, Long,Lat etc, in radians.)
!
!  The result is the bearing (position angle), in radians, of point
!  A2,B2 as seen from point A1,B1.  It is in the range +/- pi.  If
!  A2,B2 is due east of A1,B1 the bearing is +pi/2.  Zero is returned
!  if the two points are coincident.
!
!  P.T.Wallace   Starlink   23 March 1991
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL A1,B1,A2,B2

      REAL DA,X,Y


      DA=A2-A1
      Y=SIN(DA)*COS(B2)
      X=SIN(B2)*COS(B1)-COS(B2)*SIN(B1)*COS(DA)
      IF (X.NE.0.0.OR.Y.NE.0.0) THEN
         sla_BEAR=ATAN2(Y,X)
      ELSE
         sla_BEAR=0.0
      END IF

      END
      SUBROUTINE sla_CAF2R (IDEG, IAMIN, ASEC, RAD, J)
!+
!     - - - - - -
!      C A F 2 R
!     - - - - - -
!
!  Convert degrees, arcminutes, arcseconds to radians
!  (single precision)
!
!  Given:
!     IDEG        int       degrees
!     IAMIN       int       arcminutes
!     ASEC        real      arcseconds
!
!  Returned:
!     RAD         real      angle in radians
!     J           int       status:  0 = OK
!                                    1 = IDEG outside range 0-359
!                                    2 = IAMIN outside range 0-59
!                                    3 = ASEC outside range 0-59.999...
!
!  Notes:
!
!  1)  The result is computed even if any of the range checks
!      fail.
!
!  2)  The sign must be dealt with outside this routine.
!
!  P.T.Wallace   Starlink   23 August 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER IDEG,IAMIN
      REAL ASEC,RAD
      INTEGER J

!  Arc seconds to radians
      REAL AS2R
      PARAMETER (AS2R=0.484813681109535994E-5)



!  Preset status
      J=0

!  Validate arcsec, arcmin, deg
      IF (ASEC.LT.0.0.OR.ASEC.GE.60.0) J=3
      IF (IAMIN.LT.0.OR.IAMIN.GT.59) J=2
      IF (IDEG.LT.0.OR.IDEG.GT.359) J=1

!  Compute angle
      RAD=AS2R*(60.0*(60.0*REAL(IDEG)+REAL(IAMIN))+ASEC)

      END
      SUBROUTINE sla_CALDJ (IY, IM, ID, DJM, J)
!+
!     - - - - - -
!      C A L D J
!     - - - - - -
!
!  Gregorian Calendar to Modified Julian Date
!
!  (Includes century default feature:  use sla_CLDJ for years
!   before 100AD.)
!
!  Given:
!     IY,IM,ID     int    year, month, day in Gregorian calendar
!
!  Returned:
!     DJM          dp     modified Julian Date (JD-2400000.5) for 0 hrs
!     J            int    status:
!                           0 = OK
!                           1 = bad year   (MJD not computed)
!                           2 = bad month  (MJD not computed)
!                           3 = bad day    (MJD computed)
!
!  Acceptable years are 00-49, interpreted as 2000-2049,
!                       50-99,     "       "  1950-1999,
!                       100 upwards, interpreted literally.
!
!  Called:  sla_CLDJ
!
!  P.T.Wallace   Starlink   November 1985
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE
      INTEGER IY,IM,ID
      DOUBLE PRECISION DJM
      INTEGER J

      INTEGER NY




!  Default century if appropriate
      IF (IY.GE.0.AND.IY.LE.49) THEN
         NY=IY+2000
      ELSE IF (IY.GE.50.AND.IY.LE.99) THEN
         NY=IY+1900
      ELSE
         NY=IY
      END IF

!  Modified Julian Date
      CALL sla_CLDJ(NY,IM,ID,DJM,J)

      END
      SUBROUTINE sla_CALYD (IY, IM, ID, NY, ND, J)
!+
!     - - - - - -
!      C A L Y D
!     - - - - - -
!
!  Gregorian calendar date to year and day in year (in a Julian
!  calendar aligned to the 20th/21st century Gregorian calendar).
!
!  (Includes century default feature:  use sla_CLYD for years
!   before 100AD.)
!
!  Given:
!     IY,IM,ID   int    year, month, day in Gregorian calendar
!                       (year may optionally omit the century)
!  Returned:
!     NY         int    year (re-aligned Julian calendar)
!     ND         int    day in year (1 = January 1st)
!     J          int    status:
!                         0 = OK
!                         1 = bad year (before -4711)
!                         2 = bad month
!                         3 = bad day (but conversion performed)
!
!  Notes:
!
!  1  This routine exists to support the low-precision routines
!     sla_EARTH, sla_MOON and sla_ECOR.
!
!  2  Between 1900 March 1 and 2100 February 28 it returns answers
!     which are consistent with the ordinary Gregorian calendar.
!     Outside this range there will be a discrepancy which increases
!     by one day for every non-leap century year.
!
!  3  Years in the range 50-99 are interpreted as 1950-1999, and
!     years in the range 00-49 are interpreted as 2000-2049.
!
!  Called:  sla_CLYD
!
!  P.T.Wallace   Starlink   23 November 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE
      INTEGER IY,IM,ID,NY,ND,J
      INTEGER I



!  Default century if appropriate
      IF (IY.GE.0.AND.IY.LE.49) THEN
         I=IY+2000
      ELSE IF (IY.GE.50.AND.IY.LE.99) THEN
         I=IY+1900
      ELSE
         I=IY
      END IF

!  Perform the conversion
      CALL sla_CLYD(I,IM,ID,NY,ND,J)

      END
      SUBROUTINE sla_CC2S (V, A, B)
!+
!     - - - - -
!      C C 2 S
!     - - - - -
!
!  Direction cosines to spherical coordinates (single precision)
!
!  Given:
!     V     r(3)   x,y,z vector
!
!  Returned:
!     A,B   r      spherical coordinates in radians
!
!  The spherical coordinates are longitude (+ve anticlockwise
!  looking from the +ve latitude pole) and latitude.  The
!  Cartesian coordinates are right handed, with the x axis
!  at zero longitude and latitude, and the z axis at the
!  +ve latitude pole.
!
!  If V is null, zero A and B are returned.
!  At either pole, zero A is returned.
!
!  P.T.Wallace   Starlink   July 1989
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL V(3),A,B

      REAL X,Y,Z,R


      X = V(1)
      Y = V(2)
      Z = V(3)
      R = SQRT(X*X+Y*Y)

      IF (R.EQ.0.0) THEN
         A = 0.0
      ELSE
         A = ATAN2(Y,X)
      END IF

      IF (Z.EQ.0.0) THEN
         B = 0.0
      ELSE
         B = ATAN2(Z,R)
      END IF

      END
      SUBROUTINE sla_CC62S (V, A, B, R, AD, BD, RD)
!+
!     - - - - - -
!      C C 6 2 S
!     - - - - - -
!
!  Conversion of position & velocity in Cartesian coordinates
!  to spherical coordinates (single precision)
!
!  Given:
!     V      r(6)   Cartesian position & velocity vector
!
!  Returned:
!     A      r      longitude (radians)
!     B      r      latitude (radians)
!     R      r      radial coordinate
!     AD     r      longitude derivative (radians per unit time)
!     BD     r      latitude derivative (radians per unit time)
!     RD     r      radial derivative
!
!  P.T.Wallace   Starlink   28 April 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL V(6),A,B,R,AD,BD,RD

      REAL X,Y,Z,XD,YD,ZD,RXY2,RXY,R2,XYP



!  Components of position/velocity vector
      X=V(1)
      Y=V(2)
      Z=V(3)
      XD=V(4)
      YD=V(5)
      ZD=V(6)

!  Component of R in XY plane squared
      RXY2=X*X+Y*Y

!  Modulus squared
      R2=RXY2+Z*Z

!  Protection against null vector
      IF (R2.EQ.0.0) THEN
         X=XD
         Y=YD
         Z=ZD
         RXY2=X*X+Y*Y
         R2=RXY2+Z*Z
      END IF

!  Position and velocity in spherical coordinates
      RXY=SQRT(RXY2)
      XYP=X*XD+Y*YD
      IF (RXY2.NE.0.0) THEN
         A=ATAN2(Y,X)
         B=ATAN2(Z,RXY)
         AD=(X*YD-Y*XD)/RXY2
         BD=(ZD*RXY2-Z*XYP)/(R2*RXY)
      ELSE
         A=0.0
         IF (Z.NE.0.0) THEN
            B=ATAN2(Z,RXY)
         ELSE
            B=0.0
         END IF
         AD=0.0
         BD=0.0
      END IF
      R=SQRT(R2)
      IF (R.NE.0.0) THEN
         RD=(XYP+Z*ZD)/R
      ELSE
         RD=0.0
      END IF

      END
      SUBROUTINE sla_CD2TF (NDP, DAYS, SIGN, IHMSF)
!+
!     - - - - - -
!      C D 2 T F
!     - - - - - -
!
!  Convert an interval in days into hours, minutes, seconds
!
!  (single precision)
!
!  Given:
!     NDP       int      number of decimal places of seconds
!     DAYS      real     interval in days
!
!  Returned:
!     SIGN      char     '+' or '-'
!     IHMSF     int(4)   hours, minutes, seconds, fraction
!
!  Notes:
!
!     1)  NDP less than zero is interpreted as zero.
!
!     2)  The largest useful value for NDP is determined by the size of
!         DAYS, the format of REAL floating-point numbers on the target
!         machine, and the risk of overflowing IHMSF(4).  For example,
!         on the VAX, for DAYS up to 1.0, the available floating-point
!         precision corresponds roughly to NDP=3.  This is well below
!         the ultimate limit of NDP=9 set by the capacity of the 32-bit
!         integer IHMSF(4).
!
!     3)  The absolute value of DAYS may exceed 1.0.  In cases where it
!         does not, it is up to the caller to test for and handle the
!         case where DAYS is very nearly 1.0 and rounds up to 24 hours,
!         by testing for IHMSF(1)=24 and setting IHMSF(1-4) to zero.
!
!  Called:  sla_DD2TF
!
!  P.T.Wallace   Starlink   12 December 1993
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER NDP
      REAL DAYS
      CHARACTER SIGN*(*)
      INTEGER IHMSF(4)



!  Call double precision version
      CALL sla_DD2TF(NDP,DBLE(DAYS),SIGN,IHMSF)

      END
      SUBROUTINE sla_CLDJ (IY, IM, ID, DJM, J)
!+
!     - - - - -
!      C L D J
!     - - - - -
!
!  Gregorian Calendar to Modified Julian Date
!
!  Given:
!     IY,IM,ID     int    year, month, day in Gregorian calendar
!
!  Returned:
!     DJM          dp     modified Julian Date (JD-2400000.5) for 0 hrs
!     J            int    status:
!                           0 = OK
!                           1 = bad year   (MJD not computed)
!                           2 = bad month  (MJD not computed)
!                           3 = bad day    (MJD computed)
!
!  The year must be -4699 (i.e. 4700BC) or later.
!
!  The algorithm is derived from that of Hatcher 1984
!  (QJRAS 25, 53-55).
!
!  P.T.Wallace   Starlink   11 March 1998
!
!  Copyright (C) 1998 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-
      IMPLICIT NONE
      INTEGER IY,IM,ID
      DOUBLE PRECISION DJM
      INTEGER J

!  Month lengths in days
      INTEGER MTAB(12)
      DATA MTAB / 31,28,31,30,31,30,31,31,30,31,30,31 /



!  Preset status
      J=0

!  Validate year
      IF (IY.LT.-4699) THEN
         J=1
      ELSE

!     Validate month
         IF (IM.GE.1.AND.IM.LE.12) THEN

!        Allow for leap year
            IF (MOD(IY,4).EQ.0) THEN
               MTAB(2)=29
            ELSE
               MTAB(2)=28
            END IF
            IF (MOD(IY,100).EQ.0.AND.MOD(IY,400).NE.0) &
              MTAB(2)=28

!        Validate day
            IF (ID.LT.1.OR.ID.GT.MTAB(IM)) J=3

!        Modified Julian Date
            DJM=DBLE((1461*(IY-(12-IM)/10+4712))/4 &
                    +(306*MOD(IM+9,12)+5)/10 &
                    -(3*((IY-(12-IM)/10+4900)/100))/4 &
                    +ID-2399904)

!        Bad month
         ELSE
            J=2
         END IF

      END IF

      END
      SUBROUTINE sla_CLYD (IY, IM, ID, NY, ND, JSTAT)
!+
!     - - - - -
!      C L Y D
!     - - - - -
!
!  Gregorian calendar to year and day in year (in a Julian calendar
!  aligned to the 20th/21st century Gregorian calendar).
!
!  Given:
!     IY,IM,ID   i    year, month, day in Gregorian calendar
!
!  Returned:
!     NY         i    year (re-aligned Julian calendar)
!     ND         i    day in year (1 = January 1st)
!     JSTAT      i    status:
!                       0 = OK
!                       1 = bad year (before -4711)
!                       2 = bad month
!                       3 = bad day (but conversion performed)
!
!  Notes:
!
!  1  This routine exists to support the low-precision routines
!     sla_EARTH, sla_MOON and sla_ECOR.
!
!  2  Between 1900 March 1 and 2100 February 28 it returns answers
!     which are consistent with the ordinary Gregorian calendar.
!     Outside this range there will be a discrepancy which increases
!     by one day for every non-leap century year.
!
!  3  The essence of the algorithm is first to express the Gregorian
!     date as a Julian Day Number and then to convert this back to
!     a Julian calendar date, with day-in-year instead of month and
!     day.  See 12.92-1 and 12.95-1 in the reference.
!
!  Reference:  Explanatory Supplement to the Astronomical Almanac,
!              ed P.K.Seidelmann, University Science Books (1992),
!              p604-606.
!
!  P.T.Wallace   Starlink   26 November 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER IY,IM,ID,NY,ND,JSTAT

      INTEGER I,J,K,L,N

!  Month lengths in days
      INTEGER MTAB(12)
      DATA MTAB/31,28,31,30,31,30,31,31,30,31,30,31/



!  Preset status
      JSTAT=0

!  Validate year
      IF (IY.GE.-4711) THEN

!     Validate month
         IF (IM.GE.1.AND.IM.LE.12) THEN

!        Allow for (Gregorian) leap year
            IF (MOD(IY,4).EQ.0.AND. &
              (MOD(IY,100).NE.0.OR.MOD(IY,400).EQ.0)) THEN
               MTAB(2)=29
            ELSE
               MTAB(2)=28
            END IF

!        Validate day
            IF (ID.LT.1.OR.ID.GT.MTAB(IM)) JSTAT=3

!        Perform the conversion
            I=(14-IM)/12
            K=IY-I
            J=(1461*(K+4800))/4+(367*(IM-2+12*I))/12 &
             -(3*((K+4900)/100))/4+ID-30660
            K=(J-1)/1461
            L=J-1461*K
            N=(L-1)/365-L/1461
            J=((80*(L-365*N+30))/2447)/11
            I=N+J
            ND=59+L-365*I+((4-N)/4)*(1-J)
            NY=4*K+I-4716

!        Bad month
         ELSE
            JSTAT=2
         END IF
      ELSE

!     Bad year
         JSTAT=1
      END IF

      END
      SUBROUTINE sla_COMBN ( NSEL, NCAND, LIST, J )
!+
!     - - - - - -
!      C O M B N
!     - - - - - -
!
!  Generate the next combination, a subset of a specified size chosen
!  from a specified number of items.
!
!  Given:
!     NSEL     i        number of items (subset size)
!     NCAND    i        number of candidates (set size)
!
!  Given and returned:
!     LIST     i(NSEL)  latest combination, LIST(1)=0 to initialize
!
!  Returned:
!     J        i        status: -1 = illegal NSEL or NCAND
!                                0 = OK
!                               +1 = no more combinations available
!
!  Notes:
!
!  1) NSEL and NCAND must both be at least 1, and NSEL must be less
!     than or equal to NCAND.
!
!  2) This routine returns, in the LIST array, a subset of NSEL integers
!     chosen from the range 1 to NCAND inclusive, in ascending order.
!     Before calling the routine for the first time, the caller must set
!     the first element of the LIST array to zero (any value less than 1
!     will do) to cause initialization.
!
!  2) The first combination to be generated is:
!
!        LIST(1)=1, LIST(2)=2, ..., LIST(NSEL)=NSEL
!
!     This is also the combination returned for the "finished" (J=1)
!     case.
!
!     The final permutation to be generated is:
!
!        LIST(1)=NCAND, LIST(2)=NCAND-1, ..., LIST(NSEL)=NCAND-NSEL+1
!
!  3) If the "finished" (J=1) status is ignored, the routine
!     continues to deliver combinations, the pattern repeating
!     every NCAND!/(NSEL!*(NCAND-NSEL)!) calls.
!
!  4) The algorithm is by R.F.Warren-Smith (private communication).
!
!  P.T.Wallace   Starlink   25 August 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER NSEL,NCAND,LIST(NSEL),J

      INTEGER I,LISTI,NMAX,M
      LOGICAL MORE


!  Validate, and set status.
      IF (NSEL.LT.1.OR.NCAND.LT.1.OR.NSEL.GT.NCAND) THEN
         J = -1
         GO TO 9999
      ELSE
         J = 0
      END IF

!  Just starting?
      IF (LIST(1).LT.1) THEN

!     Yes: return 1,2,3...
         DO I=1,NSEL
            LIST(I) = I
         END DO

      ELSE

!     No: find the first selection that we can increment.

!     Start with the first list item.
         I = 1

!     Loop.
         MORE = .TRUE.
         DO WHILE (MORE)

!        Current list item.
            LISTI = LIST(I)

!        Is this the final list item?
            IF (I.GE.NSEL) THEN

!           Yes:  comparison value is number of candidates plus one.
               NMAX = NCAND+1
            ELSE

!           No:  comparison value is next list item.
               NMAX = LIST(I+1)
            END IF

!        Can the current item be incremented?
            IF (NMAX-LISTI.GT.1) THEN

!           Yes:  increment it.
               LIST(I) = LISTI+1

!           Reinitialize the preceding items.
               DO M=1,I-1
                  LIST(M) = M
               END DO

!           Break.
               MORE = .FALSE.
            ELSE

!           Can't increment the current item:  is it the final one?
               IF (I.GE.NSEL) THEN

!              Yes:  set the status.
                  J = 1

!              Restart the sequence.
                  DO I=1,NSEL
                     LIST(I) = I
                  END DO

!              Break.
                  MORE = .FALSE.
               ELSE

!              No:  next list item.
                  I = I+1
               END IF
            END IF
         END DO
      END IF
 9999 CONTINUE

      END
      SUBROUTINE sla_CR2AF (NDP, ANGLE, SIGN, IDMSF)
!+
!     - - - - - -
!      C R 2 A F
!     - - - - - -
!
!  Convert an angle in radians into degrees, arcminutes, arcseconds
!  (single precision)
!
!  Given:
!     NDP       int      number of decimal places of arcseconds
!     ANGLE     real     angle in radians
!
!  Returned:
!     SIGN      char     '+' or '-'
!     IDMSF     int(4)   degrees, arcminutes, arcseconds, fraction
!
!  Notes:
!
!     1)  NDP less than zero is interpreted as zero.
!
!     2)  The largest useful value for NDP is determined by the size of
!         ANGLE, the format of REAL floating-point numbers on the target
!         machine, and the risk of overflowing IDMSF(4).  For example,
!         on the VAX, for ANGLE up to 2pi, the available floating-point
!         precision corresponds roughly to NDP=3.  This is well below
!         the ultimate limit of NDP=9 set by the capacity of the 32-bit
!         integer IHMSF(4).
!
!     3)  The absolute value of ANGLE may exceed 2pi.  In cases where it
!         does not, it is up to the caller to test for and handle the
!         case where ANGLE is very nearly 2pi and rounds up to 360 deg,
!         by testing for IDMSF(1)=360 and setting IDMSF(1-4) to zero.
!
!  Called:  sla_CD2TF
!
!  P.T.Wallace   Starlink   18 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER NDP
      REAL ANGLE
      CHARACTER SIGN*(*)
      INTEGER IDMSF(4)

!  Hours to degrees * radians to turns
      REAL F
      PARAMETER (F=15.0/6.283185307179586476925287)



!  Scale then use days to h,m,s routine
      CALL sla_CD2TF(NDP,ANGLE*F,SIGN,IDMSF)

      END
      SUBROUTINE sla_CR2TF (NDP, ANGLE, SIGN, IHMSF)
!+
!     - - - - - -
!      C R 2 T F
!     - - - - - -
!
!  Convert an angle in radians into hours, minutes, seconds
!  (single precision)
!
!  Given:
!     NDP       int      number of decimal places of seconds
!     ANGLE     real     angle in radians
!
!  Returned:
!     SIGN      char     '+' or '-'
!     IHMSF     int(4)   hours, minutes, seconds, fraction
!
!  Notes:
!
!  1)  NDP less than zero is interpreted as zero.
!
!  2)  The largest useful value for NDP is determined by the size of
!      ANGLE, the format of REAL floating-point numbers on the target
!      machine, and the risk of overflowing IHMSF(4).  For example,
!      on the VAX, for ANGLE up to 2pi, the available floating-point
!      precision corresponds roughly to NDP=3.  This is well below
!      the ultimate limit of NDP=9 set by the capacity of the 32-bit
!      integer IHMSF(4).
!
!  3)  The absolute value of ANGLE may exceed 2pi.  In cases where it
!      does not, it is up to the caller to test for and handle the
!      case where ANGLE is very nearly 2pi and rounds up to 24 hours,
!      by testing for IHMSF(1)=24 and setting IHMSF(1-4) to zero.
!
!  Called:  sla_CD2TF
!
!  P.T.Wallace   Starlink   18 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER NDP
      REAL ANGLE
      CHARACTER SIGN*(*)
      INTEGER IHMSF(4)

!  Turns to radians
      REAL T2R
      PARAMETER (T2R=6.283185307179586476925287)



!  Scale then use days to h,m,s routine
      CALL sla_CD2TF(NDP,ANGLE/T2R,SIGN,IHMSF)

      END
      SUBROUTINE sla_CS2C (A, B, V)
!+
!     - - - - -
!      C S 2 C
!     - - - - -
!
!  Spherical coordinates to direction cosines (single precision)
!
!  Given:
!     A,B      real      spherical coordinates in radians
!                        (RA,Dec), (Long,Lat) etc
!
!  Returned:
!     V        real(3)   x,y,z unit vector
!
!  The spherical coordinates are longitude (+ve anticlockwise
!  looking from the +ve latitude pole) and latitude.  The
!  Cartesian coordinates are right handed, with the x axis
!  at zero longitude and latitude, and the z axis at the
!  +ve latitude pole.
!
!  P.T.Wallace   Starlink   October 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL A,B,V(3)

      REAL COSB



      COSB=COS(B)

      V(1)=COS(A)*COSB
      V(2)=SIN(A)*COSB
      V(3)=SIN(B)

      END
      SUBROUTINE sla_CS2C6 (A, B, R, AD, BD, RD, V)
!+
!     - - - - - -
!      C S 2 C 6
!     - - - - - -
!
!  Conversion of position & velocity in spherical coordinates
!  to Cartesian coordinates (single precision)
!
!  Given:
!     A     r      longitude (radians)
!     B     r      latitude (radians)
!     R     r      radial coordinate
!     AD    r      longitude derivative (radians per unit time)
!     BD    r      latitude derivative (radians per unit time)
!     RD    r      radial derivative
!
!  Returned:
!     V     r(6)   Cartesian position & velocity vector
!
!  P.T.Wallace   Starlink   November 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL A,B,R,AD,BD,RD,V(6)

      REAL SA,CA,SB,CB,RCB,X,Y,RBD,CBRD,W



!  Useful functions
      SA=SIN(A)
      CA=COS(A)
      SB=SIN(B)
      CB=COS(B)
      RCB=R*CB
      X=RCB*CA
      Y=RCB*SA
      RBD=R*BD
      CBRD=CB*RD
      W=RBD*SB-CB*RD

!  Position
      V(1)=X
      V(2)=Y
      V(3)=R*SB

!  Velocity
      V(4)=-Y*AD-W*CA
      V(5)=X*AD-W*SA
      V(6)=RBD*CB+SB*RD

      END
      SUBROUTINE sla_CTF2D (IHOUR, IMIN, SEC, DAYS, J)
!+
!     - - - - - -
!      C T F 2 D
!     - - - - - -
!
!  Convert hours, minutes, seconds to days (single precision)
!
!  Given:
!     IHOUR       int       hours
!     IMIN        int       minutes
!     SEC         real      seconds
!
!  Returned:
!     DAYS        real      interval in days
!     J           int       status:  0 = OK
!                                    1 = IHOUR outside range 0-23
!                                    2 = IMIN outside range 0-59
!                                    3 = SEC outside range 0-59.999...
!
!  Notes:
!
!  1)  The result is computed even if any of the range checks
!      fail.
!
!  2)  The sign must be dealt with outside this routine.
!
!  P.T.Wallace   Starlink   November 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER IHOUR,IMIN
      REAL SEC,DAYS
      INTEGER J

!  Seconds per day
      REAL D2S
      PARAMETER (D2S=86400.0)



!  Preset status
      J=0

!  Validate sec, min, hour
      IF (SEC.LT.0.0.OR.SEC.GE.60.0) J=3
      IF (IMIN.LT.0.OR.IMIN.GT.59) J=2
      IF (IHOUR.LT.0.OR.IHOUR.GT.23) J=1

!  Compute interval
      DAYS=(60.0*(60.0*REAL(IHOUR)+REAL(IMIN))+SEC)/D2S

      END
      SUBROUTINE sla_CTF2R (IHOUR, IMIN, SEC, RAD, J)
!+
!     - - - - - -
!      C T F 2 R
!     - - - - - -
!
!  Convert hours, minutes, seconds to radians (single precision)
!
!  Given:
!     IHOUR       int       hours
!     IMIN        int       minutes
!     SEC         real      seconds
!
!  Returned:
!     RAD         real      angle in radians
!     J           int       status:  0 = OK
!                                    1 = IHOUR outside range 0-23
!                                    2 = IMIN outside range 0-59
!                                    3 = SEC outside range 0-59.999...
!
!  Called:
!     sla_CTF2D
!
!  Notes:
!
!  1)  The result is computed even if any of the range checks
!      fail.
!
!  2)  The sign must be dealt with outside this routine.
!
!  P.T.Wallace   Starlink   November 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER IHOUR,IMIN
      REAL SEC,RAD
      INTEGER J

      REAL TURNS

!  Turns to radians
      REAL T2R
      PARAMETER (T2R=6.283185307179586476925287)



!  Convert to turns then radians
      CALL sla_CTF2D(IHOUR,IMIN,SEC,TURNS,J)
      RAD=T2R*TURNS

      END
      SUBROUTINE sla_DAF2R (IDEG, IAMIN, ASEC, RAD, J)
!+
!     - - - - - -
!      D A F 2 R
!     - - - - - -
!
!  Convert degrees, arcminutes, arcseconds to radians
!  (double precision)
!
!  Given:
!     IDEG        int       degrees
!     IAMIN       int       arcminutes
!     ASEC        dp        arcseconds
!
!  Returned:
!     RAD         dp        angle in radians
!     J           int       status:  0 = OK
!                                    1 = IDEG outside range 0-359
!                                    2 = IAMIN outside range 0-59
!                                    3 = ASEC outside range 0-59.999...
!
!  Notes:
!     1)  The result is computed even if any of the range checks
!         fail.
!     2)  The sign must be dealt with outside this routine.
!
!  P.T.Wallace   Starlink   23 August 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER IDEG,IAMIN
      DOUBLE PRECISION ASEC,RAD
      INTEGER J

!  Arc seconds to radians
      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)



!  Preset status
      J=0

!  Validate arcsec, arcmin, deg
      IF (ASEC.LT.0D0.OR.ASEC.GE.60D0) J=3
      IF (IAMIN.LT.0.OR.IAMIN.GT.59) J=2
      IF (IDEG.LT.0.OR.IDEG.GT.359) J=1

!  Compute angle
      RAD=AS2R*(60D0*(60D0*DBLE(IDEG)+DBLE(IAMIN))+ASEC)

      END
      SUBROUTINE sla_DAFIN (STRING, IPTR, A, J)
!+
!     - - - - - -
!      D A F I N
!     - - - - - -
!
!  Sexagesimal character string to angle (double precision)
!
!  Given:
!     STRING  c*(*)   string containing deg, arcmin, arcsec fields
!     IPTR      i     pointer to start of decode (1st = 1)
!
!  Returned:
!     IPTR      i     advanced past the decoded angle
!     A         d     angle in radians
!     J         i     status:  0 = OK
!                             +1 = default, A unchanged
!                             -1 = bad degrees      )
!                             -2 = bad arcminutes   )  (note 3)
!                             -3 = bad arcseconds   )
!
!  Example:
!
!    argument    before                           after
!
!    STRING      '-57 17 44.806  12 34 56.7'      unchanged
!    IPTR        1                                16 (points to 12...)
!    A           ?                                -1.00000D0
!    J           ?                                0
!
!    A further call to sla_DAFIN, without adjustment of IPTR, will
!    decode the second angle, 12deg 34min 56.7sec.
!
!  Notes:
!
!     1)  The first three "fields" in STRING are degrees, arcminutes,
!         arcseconds, separated by spaces or commas.  The degrees field
!         may be signed, but not the others.  The decoding is carried
!         out by the DFLTIN routine and is free-format.
!
!     2)  Successive fields may be absent, defaulting to zero.  For
!         zero status, the only combinations allowed are degrees alone,
!         degrees and arcminutes, and all three fields present.  If all
!         three fields are omitted, a status of +1 is returned and A is
!         unchanged.  In all other cases A is changed.
!
!     3)  Range checking:
!
!           The degrees field is not range checked.  However, it is
!           expected to be integral unless the other two fields are absent.
!
!           The arcminutes field is expected to be 0-59, and integral if
!           the arcseconds field is present.  If the arcseconds field
!           is absent, the arcminutes is expected to be 0-59.9999...
!
!           The arcseconds field is expected to be 0-59.9999...
!
!     4)  Decoding continues even when a check has failed.  Under these
!         circumstances the field takes the supplied value, defaulting
!         to zero, and the result A is computed and returned.
!
!     5)  Further fields after the three expected ones are not treated
!         as an error.  The pointer IPTR is left in the correct state
!         for further decoding with the present routine or with DFLTIN
!         etc. See the example, above.
!
!     6)  If STRING contains hours, minutes, seconds instead of degrees
!         etc, or if the required units are turns (or days) instead of
!         radians, the result A should be multiplied as follows:
!
!           for        to obtain    multiply
!           STRING     A in         A by
!
!           d ' "      radians      1       =  1D0
!           d ' "      turns        1/2pi   =  0.1591549430918953358D0
!           h m s      radians      15      =  15D0
!           h m s      days         15/2pi  =  2.3873241463784300365D0
!
!  Called:  sla_DFLTIN
!
!  P.T.Wallace   Starlink   1 August 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) STRING
      INTEGER IPTR
      DOUBLE PRECISION A
      INTEGER J

      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=4.84813681109535993589914102358D-6)
      INTEGER JF,JD,JM,JS
      DOUBLE PRECISION DEG,ARCMIN,ARCSEC



!  Preset the status to OK
      JF=0

!  Defaults
      DEG=0D0
      ARCMIN=0D0
      ARCSEC=0D0

!  Decode degrees, arcminutes, arcseconds
      CALL sla_DFLTIN(STRING,IPTR,DEG,JD)
      IF (JD.GT.1) THEN
         JF=-1
      ELSE
         CALL sla_DFLTIN(STRING,IPTR,ARCMIN,JM)
         IF (JM.LT.0.OR.JM.GT.1) THEN
            JF=-2
         ELSE
            CALL sla_DFLTIN(STRING,IPTR,ARCSEC,JS)
            IF (JS.LT.0.OR.JS.GT.1) THEN
               JF=-3

!        See if the combination of fields is credible
            ELSE IF (JD.GT.0) THEN
!           No degrees:  arcmin, arcsec ought also to be absent
               IF (JM.EQ.0) THEN
!              Suspect arcmin
                  JF=-2
               ELSE IF (JS.EQ.0) THEN
!              Suspect arcsec
                  JF=-3
               ELSE
!              All three fields absent
                  JF=1
               END IF
!        Degrees present:  if arcsec present so ought arcmin to be
            ELSE IF (JM.NE.0.AND.JS.EQ.0) THEN
               JF=-3

!        Tests for range and integrality

!        Degrees
            ELSE IF (JM.EQ.0.AND.DINT(DEG).NE.DEG) THEN
               JF=-1
!        Arcminutes
            ELSE IF ((JS.EQ.0.AND.DINT(ARCMIN).NE.ARCMIN).OR. &
                    ARCMIN.GE.60D0) THEN
               JF=-2
!        Arcseconds
            ELSE IF (ARCSEC.GE.60D0) THEN
               JF=-3
            END IF
         END IF
      END IF

!  Unless all three fields absent, compute angle value
      IF (JF.LE.0) THEN
         A=AS2R*(60D0*(60D0*ABS(DEG)+ARCMIN)+ARCSEC)
         IF (JD.LT.0) A=-A
      END IF

!  Return the status
      J=JF

      END
      DOUBLE PRECISION FUNCTION sla_DAT (UTC)
!+
!     - - - -
!      D A T
!     - - - -
!
!  Increment to be applied to Coordinated Universal Time UTC to give
!  International Atomic Time TAI (double precision)
!
!  Given:
!     UTC      d      UTC date as a modified JD (JD-2400000.5)
!
!  Result:  TAI-UTC in seconds
!
!  Notes:
!
!  1  The UTC is specified to be a date rather than a time to indicate
!     that care needs to be taken not to specify an instant which lies
!     within a leap second.  Though in most cases UTC can include the
!     fractional part, correct behaviour on the day of a leap second
!     can only be guaranteed up to the end of the second 23:59:59.
!
!  2  For epochs from 1961 January 1 onwards, the expressions from the
!     file ftp://maia.usno.navy.mil/ser7/tai-utc.dat are used.
!
!  3  The 5ms timestep at 1961 January 1 is taken from 2.58.1 (p87) of
!     the 1992 Explanatory Supplement.
!
!  4  UTC began at 1960 January 1.0 (JD 2436934.5) and it is improper
!     to call the routine with an earlier epoch.  However, if this
!     is attempted, the TAI-UTC expression for the year 1960 is used.
!
! &
!     -----------------------------------------: & &
!                                               & &
!                     IMPORTANT                 & &
!                                               &
!       This routine must be updated on each   : & &
!          occasion that a leap second is       & &
!                     announced                 & &
!                                               &
!       Latest leap second:  1999 January 1    : & &
!                                               &
!     -----------------------------------------:
!
!  P.T.Wallace   Starlink   31 May 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION UTC

      DOUBLE PRECISION DT



      IF (.FALSE.) THEN

! - - - - - - - - - - - - - - - - - - - - - - *
!  Add new code here on each occasion that a  *
!  leap second is announced, and update the   *
!  preamble comments appropriately.           *
! - - - - - - - - - - - - - - - - - - - - - - *

!     1999 January 1
      ELSE IF (UTC.GE.51179D0) THEN
         DT=32D0

!     1997 July 1
      ELSE IF (UTC.GE.50630D0) THEN
         DT=31D0

!     1996 January 1
      ELSE IF (UTC.GE.50083D0) THEN
         DT=30D0

!     1994 July 1
      ELSE IF (UTC.GE.49534D0) THEN
         DT=29D0

!     1993 July 1
      ELSE IF (UTC.GE.49169D0) THEN
         DT=28D0

!     1992 July 1
      ELSE IF (UTC.GE.48804D0) THEN
         DT=27D0

!     1991 January 1
      ELSE IF (UTC.GE.48257D0) THEN
         DT=26D0

!     1990 January 1
      ELSE IF (UTC.GE.47892D0) THEN
         DT=25D0

!     1988 January 1
      ELSE IF (UTC.GE.47161D0) THEN
         DT=24D0

!     1985 July 1
      ELSE IF (UTC.GE.46247D0) THEN
         DT=23D0

!     1983 July 1
      ELSE IF (UTC.GE.45516D0) THEN
         DT=22D0

!     1982 July 1
      ELSE IF (UTC.GE.45151D0) THEN
         DT=21D0

!     1981 July 1
      ELSE IF (UTC.GE.44786D0) THEN
         DT=20D0

!     1980 January 1
      ELSE IF (UTC.GE.44239D0) THEN
         DT=19D0

!     1979 January 1
      ELSE IF (UTC.GE.43874D0) THEN
         DT=18D0

!     1978 January 1
      ELSE IF (UTC.GE.43509D0) THEN
         DT=17D0

!     1977 January 1
      ELSE IF (UTC.GE.43144D0) THEN
         DT=16D0

!     1976 January 1
      ELSE IF (UTC.GE.42778D0) THEN
         DT=15D0

!     1975 January 1
      ELSE IF (UTC.GE.42413D0) THEN
         DT=14D0

!     1974 January 1
      ELSE IF (UTC.GE.42048D0) THEN
         DT=13D0

!     1973 January 1
      ELSE IF (UTC.GE.41683D0) THEN
         DT=12D0

!     1972 July 1
      ELSE IF (UTC.GE.41499D0) THEN
         DT=11D0

!     1972 January 1
      ELSE IF (UTC.GE.41317D0) THEN
         DT=10D0

!     1968 February 1
      ELSE IF (UTC.GE.39887D0) THEN
         DT=4.2131700D0+(UTC-39126D0)*0.002592D0

!     1966 January 1
      ELSE IF (UTC.GE.39126D0) THEN
         DT=4.3131700D0+(UTC-39126D0)*0.002592D0

!     1965 September 1
      ELSE IF (UTC.GE.39004D0) THEN
         DT=3.8401300D0+(UTC-38761D0)*0.001296D0

!     1965 July 1
      ELSE IF (UTC.GE.38942D0) THEN
         DT=3.7401300D0+(UTC-38761D0)*0.001296D0

!     1965 March 1
      ELSE IF (UTC.GE.38820D0) THEN
         DT=3.6401300D0+(UTC-38761D0)*0.001296D0

!     1965 January 1
      ELSE IF (UTC.GE.38761D0) THEN
         DT=3.5401300D0+(UTC-38761D0)*0.001296D0

!     1964 September 1
      ELSE IF (UTC.GE.38639D0) THEN
         DT=3.4401300D0+(UTC-38761D0)*0.001296D0

!     1964 April 1
      ELSE IF (UTC.GE.38486D0) THEN
         DT=3.3401300D0+(UTC-38761D0)*0.001296D0

!     1964 January 1
      ELSE IF (UTC.GE.38395D0) THEN
         DT=3.2401300D0+(UTC-38761D0)*0.001296D0

!     1963 November 1
      ELSE IF (UTC.GE.38334D0) THEN
         DT=1.9458580D0+(UTC-37665D0)*0.0011232D0

!     1962 January 1
      ELSE IF (UTC.GE.37665D0) THEN
         DT=1.8458580D0+(UTC-37665D0)*0.0011232D0

!     1961 August 1
      ELSE IF (UTC.GE.37512D0) THEN
         DT=1.3728180D0+(UTC-37300D0)*0.001296D0

!     1961 January 1
      ELSE IF (UTC.GE.37300D0) THEN
         DT=1.4228180D0+(UTC-37300D0)*0.001296D0

!     Before that
      ELSE
         DT=1.4178180D0+(UTC-37300D0)*0.001296D0

      END IF

      sla_DAT=DT

      END
      SUBROUTINE sla_DAV2M (AXVEC, RMAT)
!+
!     - - - - - -
!      D A V 2 M
!     - - - - - -
!
!  Form the rotation matrix corresponding to a given axial vector.
!  (double precision)
!
!  A rotation matrix describes a rotation about some arbitrary axis.
!  The axis is called the Euler axis, and the angle through which the
!  reference frame rotates is called the Euler angle.  The axial
!  vector supplied to this routine has the same direction as the
!  Euler axis, and its magnitude is the Euler angle in radians.
!
!  Given:
!    AXVEC  d(3)     axial vector (radians)
!
!  Returned:
!    RMAT   d(3,3)   rotation matrix
!
!  If AXVEC is null, the unit matrix is returned.
!
!  The reference frame rotates clockwise as seen looking along
!  the axial vector from the origin.
!
!  P.T.Wallace   Starlink   June 1989
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION AXVEC(3),RMAT(3,3)

      DOUBLE PRECISION X,Y,Z,PHI,S,C,W



!  Euler angle - magnitude of axial vector - and functions
      X = AXVEC(1)
      Y = AXVEC(2)
      Z = AXVEC(3)
      PHI = SQRT(X*X+Y*Y+Z*Z)
      S = SIN(PHI)
      C = COS(PHI)
      W = 1D0-C

!  Euler axis - direction of axial vector (perhaps null)
      IF (PHI.NE.0D0) THEN
         X = X/PHI
         Y = Y/PHI
         Z = Z/PHI
      END IF

!  Compute the rotation matrix
      RMAT(1,1) = X*X*W+C
      RMAT(1,2) = X*Y*W+Z*S
      RMAT(1,3) = X*Z*W-Y*S
      RMAT(2,1) = X*Y*W-Z*S
      RMAT(2,2) = Y*Y*W+C
      RMAT(2,3) = Y*Z*W+X*S
      RMAT(3,1) = X*Z*W+Y*S
      RMAT(3,2) = Y*Z*W-X*S
      RMAT(3,3) = Z*Z*W+C

      END
      DOUBLE PRECISION FUNCTION sla_DBEAR (A1, B1, A2, B2)
!+
!     - - - - - -
!      D B E A R
!     - - - - - -
!
!  Bearing (position angle) of one point on a sphere relative to another
!  (double precision)
!
!  Given:
!     A1,B1    d    spherical coordinates of one point
!     A2,B2    d    spherical coordinates of the other point
!
!  (The spherical coordinates are RA,Dec, Long,Lat etc, in radians.)
!
!  The result is the bearing (position angle), in radians, of point
!  A2,B2 as seen from point A1,B1.  It is in the range +/- pi.  If
!  A2,B2 is due east of A1,B1 the bearing is +pi/2.  Zero is returned
!  if the two points are coincident.
!
!  P.T.Wallace   Starlink   23 March 1991
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION A1,B1,A2,B2

      DOUBLE PRECISION DA,X,Y


      DA=A2-A1
      Y=SIN(DA)*COS(B2)
      X=SIN(B2)*COS(B1)-COS(B2)*SIN(B1)*COS(DA)
      IF (X.NE.0D0.OR.Y.NE.0D0) THEN
         sla_DBEAR=ATAN2(Y,X)
      ELSE
         sla_DBEAR=0D0
      END IF

      END
      SUBROUTINE sla_DBJIN (STRING, NSTRT, DRESLT, J1, J2)
!+
!     - - - - - -
!      D B J I N
!     - - - - - -
!
!  Convert free-format input into double precision floating point,
!  using DFLTIN but with special syntax extensions.
!
!  The purpose of the syntax extensions is to help cope with mixed
!  FK4 and FK5 data.  In addition to the syntax accepted by DFLTIN,
!  the following two extensions are recognized by DBJIN:
!
!     1)  A valid non-null field preceded by the character 'B'
!         (or 'b') is accepted.
!
!     2)  A valid non-null field preceded by the character 'J'
!         (or 'j') is accepted.
!
!  The calling program is notified of the incidence of either of these
!  extensions through an supplementary status argument.  The rest of
!  the arguments are as for DFLTIN.
!
!  Given:
!     STRING      char       string containing field to be decoded
!     NSTRT       int        pointer to 1st character of field in string
!
!  Returned:
!     NSTRT       int        incremented
!     DRESLT      double     result
!     J1          int        DFLTIN status: -1 = -OK
!                                            0 = +OK
!                                           +1 = null field
!                                           +2 = error
!     J2          int        syntax flag:  0 = normal DFLTIN syntax
!                                         +1 = 'B' or 'b'
!                                         +2 = 'J' or 'j'
!
!  Called:  sla_DFLTIN
!
!  For details of the basic syntax, see sla_DFLTIN.
!
!  P.T.Wallace   Starlink   23 November 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) STRING
      INTEGER NSTRT
      DOUBLE PRECISION DRESLT
      INTEGER J1,J2

      INTEGER J2A,LENSTR,NA,J1A,NB,J1B
      CHARACTER C



!   Preset syntax flag
      J2A=0

!   Length of string
      LENSTR=LEN(STRING)

!   Pointer to current character
      NA=NSTRT

!   Attempt normal decode
      CALL sla_DFLTIN(STRING,NA,DRESLT,J1A)

!   Proceed only if pointer still within string
      IF (NA.GE.1.AND.NA.LE.LENSTR) THEN

!      See if DFLTIN reported a null field
         IF (J1A.EQ.1) THEN

!         It did: examine character it stuck on
            C=STRING(NA:NA)
            IF (C.EQ.'B'.OR.C.EQ.'b') THEN
!            'B' - provisionally note
               J2A=1
            ELSE IF (C.EQ.'J'.OR.C.EQ.'j') THEN
!            'J' - provisionally note
               J2A=2
            END IF

!         Following B or J, attempt to decode a number
            IF (J2A.EQ.1.OR.J2A.EQ.2) THEN
               NB=NA+1
               CALL sla_DFLTIN(STRING,NB,DRESLT,J1B)

!            If successful, copy pointer and status
               IF (J1B.LE.0) THEN
                  NA=NB
                  J1A=J1B
!            If not, forget about the B or J
               ELSE
                  J2A=0
               END IF

            END IF

         END IF

      END IF

!   Return argument values and exit
      NSTRT=NA
      J1=J1A
      J2=J2A

      END
      SUBROUTINE sla_DC62S (V, A, B, R, AD, BD, RD)
!+
!     - - - - - -
!      D C 6 2 S
!     - - - - - -
!
!  Conversion of position & velocity in Cartesian coordinates
!  to spherical coordinates (double precision)
!
!  Given:
!     V      d(6)   Cartesian position & velocity vector
!
!  Returned:
!     A      d      longitude (radians)
!     B      d      latitude (radians)
!     R      d      radial coordinate
!     AD     d      longitude derivative (radians per unit time)
!     BD     d      latitude derivative (radians per unit time)
!     RD     d      radial derivative
!
!  P.T.Wallace   Starlink   28 April 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION V(6),A,B,R,AD,BD,RD

      DOUBLE PRECISION X,Y,Z,XD,YD,ZD,RXY2,RXY,R2,XYP



!  Components of position/velocity vector
      X=V(1)
      Y=V(2)
      Z=V(3)
      XD=V(4)
      YD=V(5)
      ZD=V(6)

!  Component of R in XY plane squared
      RXY2=X*X+Y*Y

!  Modulus squared
      R2=RXY2+Z*Z

!  Protection against null vector
      IF (R2.EQ.0D0) THEN
         X=XD
         Y=YD
         Z=ZD
         RXY2=X*X+Y*Y
         R2=RXY2+Z*Z
      END IF

!  Position and velocity in spherical coordinates
      RXY=SQRT(RXY2)
      XYP=X*XD+Y*YD
      IF (RXY2.NE.0D0) THEN
         A=ATAN2(Y,X)
         B=ATAN2(Z,RXY)
         AD=(X*YD-Y*XD)/RXY2
         BD=(ZD*RXY2-Z*XYP)/(R2*RXY)
      ELSE
         A=0D0
         IF (Z.NE.0D0) THEN
            B=ATAN2(Z,RXY)
         ELSE
            B=0D0
         END IF
         AD=0D0
         BD=0D0
      END IF
      R=SQRT(R2)
      IF (R.NE.0D0) THEN
         RD=(XYP+Z*ZD)/R
      ELSE
         RD=0D0
      END IF

      END
      SUBROUTINE sla_DCC2S (V, A, B)
!+
!     - - - - - -
!      D C C 2 S
!     - - - - - -
!
!  Direction cosines to spherical coordinates (double precision)
!
!  Given:
!     V     d(3)   x,y,z vector
!
!  Returned:
!     A,B   d      spherical coordinates in radians
!
!  The spherical coordinates are longitude (+ve anticlockwise
!  looking from the +ve latitude pole) and latitude.  The
!  Cartesian coordinates are right handed, with the x axis
!  at zero longitude and latitude, and the z axis at the
!  +ve latitude pole.
!
!  If V is null, zero A and B are returned.
!  At either pole, zero A is returned.
!
!  P.T.Wallace   Starlink   July 1989
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION V(3),A,B

      DOUBLE PRECISION X,Y,Z,R


      X = V(1)
      Y = V(2)
      Z = V(3)
      R = SQRT(X*X+Y*Y)

      IF (R.EQ.0D0) THEN
         A = 0D0
      ELSE
         A = ATAN2(Y,X)
      END IF

      IF (Z.EQ.0D0) THEN
         B = 0D0
      ELSE
         B = ATAN2(Z,R)
      END IF

      END
      SUBROUTINE sla_DCMPF (COEFFS,XZ,YZ,XS,YS,PERP,ORIENT)
!+
!     - - - - - -
!      D C M P F
!     - - - - - -
!
!  Decompose an [X,Y] linear fit into its constituent parameters:
!  zero points, scales, nonperpendicularity and orientation.
!
!  Given:
!     COEFFS  d(6)      transformation coefficients (see note)
!
!  Returned:
!     XZ       d        x zero point
!     YZ       d        y zero point
!     XS       d        x scale
!     YS       d        y scale
!     PERP     d        nonperpendicularity (radians)
!     ORIENT   d        orientation (radians)
!
!  Called:  sla_DRANGE
!
!  The model relates two sets of [X,Y] coordinates as follows.
!  Naming the elements of COEFFS:
!
!     COEFFS(1) = A
!     COEFFS(2) = B
!     COEFFS(3) = C
!     COEFFS(4) = D
!     COEFFS(5) = E
!     COEFFS(6) = F
!
!  the model transforms coordinates [X1,Y1] into coordinates
!  [X2,Y2] as follows:
!
!     X2 = A + B*X1 + C*Y1
!     Y2 = D + E*X1 + F*Y1
!
!  The transformation can be decomposed into four steps:
!
!     1)  Zero points:
!
!             x' = XZ + X1
!             y' = YZ + Y1
!
!     2)  Scales:
!
!             x'' = XS*x'
!             y'' = YS*y'
!
!     3)  Nonperpendicularity:
!
!             x''' = cos(PERP/2)*x'' + sin(PERP/2)*y''
!             y''' = sin(PERP/2)*x'' + cos(PERP/2)*y''
!
!     4)  Orientation:
!
!             X2 = cos(ORIENT)*x''' + sin(ORIENT)*y'''
!             Y2 =-sin(ORIENT)*y''' + cos(ORIENT)*y'''
!
!  See also sla_FITXY, sla_PXY, sla_INVF, sla_XY2XY
!
!  P.T.Wallace   Starlink   19 December 2001
!
!  Copyright (C) 2001 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION COEFFS(6),XZ,YZ,XS,YS,PERP,ORIENT

      DOUBLE PRECISION A,B,C,D,E,F,RB2E2,RC2F2,XSC,YSC,P1,P2,P,WS,WC, &
                      OR,HP,SHP,CHP,SOR,COR,DET,X0,Y0,sla_DRANGE



!  Copy the six coefficients.
      A = COEFFS(1)
      B = COEFFS(2)
      C = COEFFS(3)
      D = COEFFS(4)
      E = COEFFS(5)
      F = COEFFS(6)

!  Scales.
      RB2E2 = SQRT(B*B+E*E)
      RC2F2 = SQRT(C*C+F*F)
      IF (B*F-C*E.GE.0D0) THEN
         XSC = RB2E2
      ELSE
         B = -B
         E = -E
         XSC = -RB2E2
      END IF
      YSC = RC2F2

!  Non-perpendicularity.
      IF (C.NE.0D0.OR.F.NE.0D0) THEN
         P1 = ATAN2(C,F)
      ELSE
         P1 = 0D0
      END IF
      IF (E.NE.0D0.OR.B.NE.0D0) THEN
         P2 = ATAN2(E,B)
      ELSE
         P2 = 0D0
      END IF
      P = sla_DRANGE(P1+P2)

!  Orientation.
      WS = C*RB2E2-E*RC2F2
      WC = B*RC2F2+F*RB2E2
      IF (WS.NE.0D0.OR.WC.NE.0D0) THEN
         OR = ATAN2(WS,WC)
      ELSE
         OR = 0D0
      END IF

!  Zero points.
      HP = P/2D0
      SHP = SIN(HP)
      CHP = COS(HP)
      SOR = SIN(OR)
      COR = COS(OR)
      DET = XSC*YSC*(CHP+SHP)*(CHP-SHP)
      IF (ABS(DET).GT.0D0) THEN
         X0 = YSC*(A*(CHP*COR-SHP*SOR)-D*(CHP*SOR+SHP*COR))/DET
         Y0 = XSC*(A*(CHP*SOR-SHP*COR)+D*(CHP*COR+SHP*SOR))/DET
      ELSE
         X0 = 0D0
         Y0 = 0D0
      END IF

!  Results.
      XZ = X0
      YZ = Y0
      XS = XSC
      YS = YSC
      PERP = P
      ORIENT = OR

      END
      SUBROUTINE sla_DCS2C (A, B, V)
!+
!     - - - - - -
!      D C S 2 C
!     - - - - - -
!
!  Spherical coordinates to direction cosines (double precision)
!
!  Given:
!     A,B       dp      spherical coordinates in radians
!                        (RA,Dec), (Long,Lat) etc
!
!  Returned:
!     V         dp(3)   x,y,z unit vector
!
!  The spherical coordinates are longitude (+ve anticlockwise
!  looking from the +ve latitude pole) and latitude.  The
!  Cartesian coordinates are right handed, with the x axis
!  at zero longitude and latitude, and the z axis at the
!  +ve latitude pole.
!
!  P.T.Wallace   Starlink   October 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION A,B,V(3)

      DOUBLE PRECISION COSB



      COSB=COS(B)

      V(1)=COS(A)*COSB
      V(2)=SIN(A)*COSB
      V(3)=SIN(B)

      END
      SUBROUTINE sla_DD2TF (NDP, DAYS, SIGN, IHMSF)
!+
!     - - - - - -
!      D D 2 T F
!     - - - - - -
!
!  Convert an interval in days into hours, minutes, seconds
!  (double precision)
!
!  Given:
!     NDP      i      number of decimal places of seconds
!     DAYS     d      interval in days
!
!  Returned:
!     SIGN     c      '+' or '-'
!     IHMSF    i(4)   hours, minutes, seconds, fraction
!
!  Notes:
!
!     1)  NDP less than zero is interpreted as zero.
!
!     2)  The largest useful value for NDP is determined by the size
!         of DAYS, the format of DOUBLE PRECISION floating-point numbers
!         on the target machine, and the risk of overflowing IHMSF(4).
!         For example, on the VAX, for DAYS up to 1D0, the available
!         floating-point precision corresponds roughly to NDP=12.
!         However, the practical limit is NDP=9, set by the capacity of
!         the 32-bit integer IHMSF(4).
!
!     3)  The absolute value of DAYS may exceed 1D0.  In cases where it
!         does not, it is up to the caller to test for and handle the
!         case where DAYS is very nearly 1D0 and rounds up to 24 hours,
!         by testing for IHMSF(1)=24 and setting IHMSF(1-4) to zero.
!
!  P.T.Wallace   Starlink   19 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER NDP
      DOUBLE PRECISION DAYS
      CHARACTER SIGN*(*)
      INTEGER IHMSF(4)

!  Days to seconds
      DOUBLE PRECISION D2S
      PARAMETER (D2S=86400D0)

      INTEGER NRS,N
      DOUBLE PRECISION RS,RM,RH,A,AH,AM,AS,AF



!  Handle sign
      IF (DAYS.GE.0D0) THEN
         SIGN='+'
      ELSE
         SIGN='-'
      END IF

!  Field units in terms of least significant figure
      NRS=1
      DO N=1,NDP
         NRS=NRS*10
      END DO
      RS=DBLE(NRS)
      RM=RS*60D0
      RH=RM*60D0

!  Round interval and express in smallest units required
      A=ANINT(RS*D2S*ABS(DAYS))

!  Separate into fields
      AH=AINT(A/RH)
      A=A-AH*RH
      AM=AINT(A/RM)
      A=A-AM*RM
      AS=AINT(A/RS)
      AF=A-AS*RS

!  Return results
      IHMSF(1)=MAX(NINT(AH),0)
      IHMSF(2)=MAX(MIN(NINT(AM),59),0)
      IHMSF(3)=MAX(MIN(NINT(AS),59),0)
      IHMSF(4)=MAX(NINT(MIN(AF,RS-1D0)),0)

      END
      SUBROUTINE sla_DE2H (HA, DEC, PHI, AZ, EL)
!+
!     - - - - -
!      D E 2 H
!     - - - - -
!
!  Equatorial to horizon coordinates:  HA,Dec to Az,El
!
!  (double precision)
!
!  Given:
!     HA      d     hour angle
!     DEC     d     declination
!     PHI     d     observatory latitude
!
!  Returned:
!     AZ      d     azimuth
!     EL      d     elevation
!
!  Notes:
!
!  1)  All the arguments are angles in radians.
!
!  2)  Azimuth is returned in the range 0-2pi;  north is zero,
!      and east is +pi/2.  Elevation is returned in the range
!      +/-pi/2.
!
!  3)  The latitude must be geodetic.  In critical applications,
!      corrections for polar motion should be applied.
!
!  4)  In some applications it will be important to specify the
!      correct type of hour angle and declination in order to
!      produce the required type of azimuth and elevation.  In
!      particular, it may be important to distinguish between
!      elevation as affected by refraction, which would
!      require the "observed" HA,Dec, and the elevation
!      in vacuo, which would require the "topocentric" HA,Dec.
!      If the effects of diurnal aberration can be neglected, the
!      "apparent" HA,Dec may be used instead of the topocentric
!      HA,Dec.
!
!  5)  No range checking of arguments is carried out.
!
!  6)  In applications which involve many such calculations, rather
!      than calling the present routine it will be more efficient to
!      use inline code, having previously computed fixed terms such
!      as sine and cosine of latitude, and (for tracking a star)
!      sine and cosine of declination.
!
!  P.T.Wallace   Starlink   9 July 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION HA,DEC,PHI,AZ,EL

      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=6.283185307179586476925286766559D0)

      DOUBLE PRECISION SH,CH,SD,CD,SP,CP,X,Y,Z,R,A


!  Useful trig functions
      SH=SIN(HA)
      CH=COS(HA)
      SD=SIN(DEC)
      CD=COS(DEC)
      SP=SIN(PHI)
      CP=COS(PHI)

!  Az,El as x,y,z
      X=-CH*CD*SP+SD*CP
      Y=-SH*CD
      Z=CH*CD*CP+SD*SP

!  To spherical
      R=SQRT(X*X+Y*Y)
      IF (R.EQ.0D0) THEN
         A=0D0
      ELSE
         A=ATAN2(Y,X)
      END IF
      IF (A.LT.0D0) A=A+D2PI
      AZ=A
      EL=ATAN2(Z,R)

      END
      SUBROUTINE sla_DEULER (ORDER, PHI, THETA, PSI, RMAT)
!+
!     - - - - - - -
!      D E U L E R
!     - - - - - - -
!
!  Form a rotation matrix from the Euler angles - three successive
!  rotations about specified Cartesian axes (double precision)
!
!  Given:
!    ORDER   c*(*)   specifies about which axes the rotations occur
!    PHI     d       1st rotation (radians)
!    THETA   d       2nd rotation (   "   )
!    PSI     d       3rd rotation (   "   )
!
!  Returned:
!    RMAT    d(3,3)  rotation matrix
!
!  A rotation is positive when the reference frame rotates
!  anticlockwise as seen looking towards the origin from the
!  positive region of the specified axis.
!
!  The characters of ORDER define which axes the three successive
!  rotations are about.  A typical value is 'ZXZ', indicating that
!  RMAT is to become the direction cosine matrix corresponding to
!  rotations of the reference frame through PHI radians about the
!  old Z-axis, followed by THETA radians about the resulting X-axis,
!  then PSI radians about the resulting Z-axis.
!
!  The axis names can be any of the following, in any order or
!  combination:  X, Y, Z, uppercase or lowercase, 1, 2, 3.  Normal
!  axis labelling/numbering conventions apply;  the xyz (=123)
!  triad is right-handed.  Thus, the 'ZXZ' example given above
!  could be written 'zxz' or '313' (or even 'ZxZ' or '3xZ').  ORDER
!  is terminated by length or by the first unrecognized character.
!
!  Fewer than three rotations are acceptable, in which case the later
!  angle arguments are ignored.  If all rotations are zero, the
!  identity matrix is produced.
!
!  P.T.Wallace   Starlink   23 May 1997
!
!  Copyright (C) 1997 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) ORDER
      DOUBLE PRECISION PHI,THETA,PSI,RMAT(3,3)

      INTEGER J,I,L,N,K
      DOUBLE PRECISION RESULT(3,3),ROTN(3,3),ANGLE,S,C,W,WM(3,3)
      CHARACTER AXIS



!  Initialize result matrix
      DO J=1,3
         DO I=1,3
            IF (I.NE.J) THEN
               RESULT(I,J) = 0D0
            ELSE
               RESULT(I,J) = 1D0
            END IF
         END DO
      END DO

!  Establish length of axis string
      L = LEN(ORDER)

!  Look at each character of axis string until finished
      DO N=1,3
         IF (N.LE.L) THEN

!        Initialize rotation matrix for the current rotation
            DO J=1,3
               DO I=1,3
                  IF (I.NE.J) THEN
                     ROTN(I,J) = 0D0
                  ELSE
                     ROTN(I,J) = 1D0
                  END IF
               END DO
            END DO

!        Pick up the appropriate Euler angle and take sine & cosine
            IF (N.EQ.1) THEN
               ANGLE = PHI
            ELSE IF (N.EQ.2) THEN
               ANGLE = THETA
            ELSE
               ANGLE = PSI
            END IF
            S = SIN(ANGLE)
            C = COS(ANGLE)

!        Identify the axis
            AXIS = ORDER(N:N)
            IF (AXIS.EQ.'X'.OR. &
               AXIS.EQ.'x'.OR. &
               AXIS.EQ.'1') THEN

!           Matrix for x-rotation
               ROTN(2,2) = C
               ROTN(2,3) = S
               ROTN(3,2) = -S
               ROTN(3,3) = C

            ELSE IF (AXIS.EQ.'Y'.OR. &
                    AXIS.EQ.'y'.OR. &
                    AXIS.EQ.'2') THEN

!           Matrix for y-rotation
               ROTN(1,1) = C
               ROTN(1,3) = -S
               ROTN(3,1) = S
               ROTN(3,3) = C

            ELSE IF (AXIS.EQ.'Z'.OR. &
                    AXIS.EQ.'z'.OR. &
                    AXIS.EQ.'3') THEN

!           Matrix for z-rotation
               ROTN(1,1) = C
               ROTN(1,2) = S
               ROTN(2,1) = -S
               ROTN(2,2) = C

            ELSE

!           Unrecognized character - fake end of string
               L = 0

            END IF

!        Apply the current rotation (matrix ROTN x matrix RESULT)
            DO I=1,3
               DO J=1,3
                  W = 0D0
                  DO K=1,3
                     W = W+ROTN(I,K)*RESULT(K,J)
                  END DO
                  WM(I,J) = W
               END DO
            END DO
            DO J=1,3
               DO I=1,3
                  RESULT(I,J) = WM(I,J)
               END DO
            END DO

         END IF

      END DO

!  Copy the result
      DO J=1,3
         DO I=1,3
            RMAT(I,J) = RESULT(I,J)
         END DO
      END DO

      END
      SUBROUTINE sla_DFLTIN (STRING, NSTRT, DRESLT, JFLAG)
!+
!     - - - - - - -
!      D F L T I N
!     - - - - - - -
!
!  Convert free-format input into double precision floating point
!
!  Given:
!     STRING     c     string containing number to be decoded
!     NSTRT      i     pointer to where decoding is to start
!     DRESLT     d     current value of result
!
!  Returned:
!     NSTRT      i      advanced to next number
!     DRESLT     d      result
!     JFLAG      i      status: -1 = -OK, 0 = +OK, 1 = null, 2 = error
!
!  Notes:
!
!     1     The reason DFLTIN has separate OK status values for +
!           and - is to enable minus zero to be detected.   This is
!           of crucial importance when decoding mixed-radix numbers.
!           For example, an angle expressed as deg, arcmin, arcsec
!           may have a leading minus sign but a zero degrees field.
!
!     2     A TAB is interpreted as a space, and lowercase characters
!           are interpreted as uppercase.
!
!     3     The basic format is the sequence of fields #^.^@#^, where
!           # is a sign character + or -, ^ means a string of decimal
!           digits, and @, which indicates an exponent, means D or E.
!           Various combinations of these fields can be omitted, and
!           embedded blanks are permissible in certain places.
!
!     4     Spaces:
!
!             .  Leading spaces are ignored.
!
!             .  Embedded spaces are allowed only after +, -, D or E,
!                and after the decomal point if the first sequence of
!                digits is absent.
!
!             .  Trailing spaces are ignored;  the first signifies
!                end of decoding and subsequent ones are skipped.
!
!     5     Delimiters:
!
!             .  Any character other than +,-,0-9,.,D,E or space may be
!                used to signal the end of the number and terminate
!                decoding.
!
!             .  Comma is recognized by DFLTIN as a special case;  it
!                is skipped, leaving the pointer on the next character.
!                See 13, below.
!
!     6     Both signs are optional.  The default is +.
!
!     7     The mantissa ^.^ defaults to 1.
!
!     8     The exponent @#^ defaults to D0.
!
!     9     The strings of decimal digits may be of any length.
!
!     10    The decimal point is optional for whole numbers.
!
!     11    A "null result" occurs when the string of characters being
!           decoded does not begin with +,-,0-9,.,D or E, or consists
!           entirely of spaces.  When this condition is detected, JFLAG
!           is set to 1 and DRESLT is left untouched.
!
!     12    NSTRT = 1 for the first character in the string.
!
!     13    On return from DFLTIN, NSTRT is set ready for the next
!           decode - following trailing blanks and any comma.  If a
!           delimiter other than comma is being used, NSTRT must be
!           incremented before the next call to DFLTIN, otherwise
!           all subsequent calls will return a null result.
!
!     14    Errors (JFLAG=2) occur when:
!
!             .  a +, -, D or E is left unsatisfied;  or
!
!             .  the decimal point is present without at least
!                one decimal digit before or after it;  or
!
!             .  an exponent more than 100 has been presented.
!
!     15    When an error has been detected, NSTRT is left
!           pointing to the character following the last
!           one used before the error came to light.  This
!           may be after the point at which a more sophisticated
!           program could have detected the error.  For example,
!           DFLTIN does not detect that '1D999' is unacceptable
!           (on a computer where this is so) until the entire number
!           has been decoded.
!
!     16    Certain highly unlikely combinations of mantissa &
!           exponent can cause arithmetic faults during the
!           decode, in some cases despite the fact that they
!           together could be construed as a valid number.
!
!     17    Decoding is left to right, one pass.
!
!     18    See also FLOTIN and INTIN
!
!  Called:  sla__IDCHF
!
!  P.T.Wallace   Starlink   18 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) STRING
      INTEGER NSTRT
      DOUBLE PRECISION DRESLT
      INTEGER JFLAG

      INTEGER NPTR,MSIGN,NEXP,NDP,NVEC,NDIGIT,ISIGNX,J
      DOUBLE PRECISION DMANT,DIGIT



!  Current character
      NPTR=NSTRT

!  Set defaults: mantissa & sign, exponent & sign, decimal place count
      DMANT=0D0
      MSIGN=1
      NEXP=0
      ISIGNX=1
      NDP=0

!  Look for sign
 100  CONTINUE
      CALL sla__IDCHF(STRING,NPTR,NVEC,NDIGIT,DIGIT)
      GO TO ( 400,  100,  800,  500,  300,  200, 9110, 9100, 9110),NVEC
!             0-9    SP   D/E    .     +     -     ,   ELSE   END

!  Negative
 200  CONTINUE
      MSIGN=-1

!  Look for first leading decimal
 300  CONTINUE
      CALL sla__IDCHF(STRING,NPTR,NVEC,NDIGIT,DIGIT)
      GO TO ( 400, 300,  800,  500, 9200, 9200, 9200, 9200, 9210),NVEC
!             0-9   SP   D/E    .     +     -     ,   ELSE   END

!  Accept leading decimals
 400  CONTINUE
      DMANT=DMANT*1D1+DIGIT
      CALL sla__IDCHF(STRING,NPTR,NVEC,NDIGIT,DIGIT)
      GO TO ( 400, 1310,  900,  600, 1300, 1300, 1300, 1300, 1310),NVEC
!             0-9   SP    D/E    .     +     -     ,   ELSE   END

!  Look for decimal when none preceded the point
 500  CONTINUE
      CALL sla__IDCHF(STRING,NPTR,NVEC,NDIGIT,DIGIT)
      GO TO ( 700, 500, 9200, 9200, 9200, 9200, 9200, 9200, 9210),NVEC
!             0-9   SP   D/E    .     +     -     ,   ELSE   END

!  Look for trailing decimals
 600  CONTINUE
      CALL sla__IDCHF(STRING,NPTR,NVEC,NDIGIT,DIGIT)
      GO TO ( 700, 1310,  900, 1300, 1300, 1300, 1300, 1300, 1310),NVEC
!             0-9   SP    D/E    .     +     -     ,   ELSE   END

!  Accept trailing decimals
 700  CONTINUE
      NDP=NDP+1
      DMANT=DMANT*1D1+DIGIT
      GO TO 600

!  Exponent symbol first in field: default mantissa to 1
 800  CONTINUE
      DMANT=1D0

!  Look for sign of exponent
 900  CONTINUE
      CALL sla__IDCHF(STRING,NPTR,NVEC,NDIGIT,DIGIT)
      GO TO (1200, 900, 9200, 9200, 1100, 1000, 9200, 9200, 9210),NVEC
!             0-9   SP   D/E    .     +     -     ,   ELSE   END

!  Exponent negative
 1000 CONTINUE
      ISIGNX=-1

!  Look for first digit of exponent
 1100 CONTINUE
      CALL sla__IDCHF(STRING,NPTR,NVEC,NDIGIT,DIGIT)
      GO TO (1200, 1100, 9200, 9200, 9200, 9200, 9200, 9200, 9210),NVEC
!             0-9   SP    D/E    .     +     -     ,   ELSE   END

!  Use exponent digit
 1200 CONTINUE
      NEXP=NEXP*10+NDIGIT
      IF (NEXP.GT.100) GO TO 9200

!  Look for subsequent digits of exponent
      CALL sla__IDCHF(STRING,NPTR,NVEC,NDIGIT,DIGIT)
      GO TO (1200, 1310, 1300, 1300, 1300, 1300, 1300, 1300, 1310),NVEC
!             0-9   SP    D/E    .     +     -     ,   ELSE   END

!  Combine exponent and decimal place count
 1300 CONTINUE
      NPTR=NPTR-1
 1310 CONTINUE
      NEXP=NEXP*ISIGNX-NDP

!  Skip if net exponent negative
      IF (NEXP.LT.0) GO TO 1500

!  Positive exponent: scale up
 1400 CONTINUE
      IF (NEXP.LT.10) GO TO 1410
      DMANT=DMANT*1D10
      NEXP=NEXP-10
      GO TO 1400
 1410 CONTINUE
      IF (NEXP.LT.1) GO TO 1600
      DMANT=DMANT*1D1
      NEXP=NEXP-1
      GO TO 1410

!  Negative exponent: scale down
 1500 CONTINUE
      IF (NEXP.GT.-10) GO TO 1510
      DMANT=DMANT/1D10
      NEXP=NEXP+10
      GO TO 1500
 1510 CONTINUE
      IF (NEXP.GT.-1) GO TO 1600
      DMANT=DMANT/1D1
      NEXP=NEXP+1
      GO TO 1510

!  Get result & status
 1600 CONTINUE
      J=0
      IF (MSIGN.EQ.1) GO TO 1610
      J=-1
      DMANT=-DMANT
 1610 CONTINUE
      DRESLT=DMANT

!  Skip to end of field
 1620 CONTINUE
      CALL sla__IDCHF(STRING,NPTR,NVEC,NDIGIT,DIGIT)
      GO TO (1720, 1620, 1720, 1720, 1720, 1720, 9900, 1720, 9900),NVEC
!             0-9   SP    D/E    .     +     -     ,   ELSE   END

 1720 CONTINUE
      NPTR=NPTR-1
      GO TO 9900


!  Exits

!  Null field
 9100 CONTINUE
      NPTR=NPTR-1
 9110 CONTINUE
      J=1
      GO TO 9900

!  Errors
 9200 CONTINUE
      NPTR=NPTR-1
 9210 CONTINUE
      J=2

!  Return
 9900 CONTINUE
      NSTRT=NPTR
      JFLAG=J

      END
      SUBROUTINE sla_DH2E (AZ, EL, PHI, HA, DEC)
!+
!     - - - - -
!      D E 2 H
!     - - - - -
!
!  Horizon to equatorial coordinates:  Az,El to HA,Dec
!
!  (double precision)
!
!  Given:
!     AZ      d     azimuth
!     EL      d     elevation
!     PHI     d     observatory latitude
!
!  Returned:
!     HA      d     hour angle
!     DEC     d     declination
!
!  Notes:
!
!  1)  All the arguments are angles in radians.
!
!  2)  The sign convention for azimuth is north zero, east +pi/2.
!
!  3)  HA is returned in the range +/-pi.  Declination is returned
!      in the range +/-pi/2.
!
!  4)  The latitude is (in principle) geodetic.  In critical
!      applications, corrections for polar motion should be applied.
!
!  5)  In some applications it will be important to specify the
!      correct type of elevation in order to produce the required
!      type of HA,Dec.  In particular, it may be important to
!      distinguish between the elevation as affected by refraction,
!      which will yield the "observed" HA,Dec, and the elevation
!      in vacuo, which will yield the "topocentric" HA,Dec.  If the
!      effects of diurnal aberration can be neglected, the
!      topocentric HA,Dec may be used as an approximation to the
!      "apparent" HA,Dec.
!
!  6)  No range checking of arguments is done.
!
!  7)  In applications which involve many such calculations, rather
!      than calling the present routine it will be more efficient to
!      use inline code, having previously computed fixed terms such
!      as sine and cosine of latitude.
!
!  P.T.Wallace   Starlink   21 February 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION AZ,EL,PHI,HA,DEC

      DOUBLE PRECISION SA,CA,SE,CE,SP,CP,X,Y,Z,R


!  Useful trig functions
      SA=SIN(AZ)
      CA=COS(AZ)
      SE=SIN(EL)
      CE=COS(EL)
      SP=SIN(PHI)
      CP=COS(PHI)

!  HA,Dec as x,y,z
      X=-CA*CE*SP+SE*CP
      Y=-SA*CE
      Z=CA*CE*CP+SE*SP

!  To HA,Dec
      R=SQRT(X*X+Y*Y)
      IF (R.EQ.0D0) THEN
         HA=0D0
      ELSE
         HA=ATAN2(Y,X)
      END IF
      DEC=ATAN2(Z,R)

      END
      SUBROUTINE sla_DIMXV (DM, VA, VB)
!+
!     - - - - - -
!      D I M X V
!     - - - - - -
!
!  Performs the 3-D backward unitary transformation:
!
!     vector VB = (inverse of matrix DM) * vector VA
!
!  (double precision)
!
!  (n.b.  the matrix must be unitary, as this routine assumes that
!   the inverse and transpose are identical)
!
!  Given:
!     DM       dp(3,3)    matrix
!     VA       dp(3)      vector
!
!  Returned:
!     VB       dp(3)      result vector
!
!  P.T.Wallace   Starlink   March 1986
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DM(3,3),VA(3),VB(3)

      INTEGER I,J
      DOUBLE PRECISION W,VW(3)



!  Inverse of matrix DM * vector VA -> vector VW
      DO J=1,3
         W=0D0
         DO I=1,3
            W=W+DM(I,J)*VA(I)
         END DO
         VW(J)=W
      END DO

!  Vector VW -> vector VB
      DO J=1,3
         VB(J)=VW(J)
      END DO

      END
      SUBROUTINE sla_DJCAL (NDP, DJM, IYMDF, J)
!+
!     - - - - - -
!      D J C A L
!     - - - - - -
!
!  Modified Julian Date to Gregorian Calendar, expressed
!  in a form convenient for formatting messages (namely
!  rounded to a specified precision, and with the fields
!  stored in a single array)
!
!  Given:
!     NDP      i      number of decimal places of days in fraction
!     DJM      d      modified Julian Date (JD-2400000.5)
!
!  Returned:
!     IYMDF    i(4)   year, month, day, fraction in Gregorian
!                     calendar
!     J        i      status:  nonzero = out of range
!
!  Any date after 4701BC March 1 is accepted.
!
!  NDP should be 4 or less if internal overflows are to be avoided
!  on machines which use 32-bit integers.
!
!  The algorithm is derived from that of Hatcher 1984
!  (QJRAS 25, 53-55).
!
!  P.T.Wallace   Starlink   27 April 1998
!
!  Copyright (C) 1998 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER NDP
      DOUBLE PRECISION DJM
      INTEGER IYMDF(4),J

      INTEGER NFD
      DOUBLE PRECISION FD,DF,F,D
      INTEGER JD,N4,ND10



!  Validate
      IF (DJM.LE.-2395520D0.OR.DJM.GE.1D9) THEN
         J=-1
      ELSE
         J=0

!     Denominator of fraction
         NFD=10**MAX(NDP,0)
         FD=DBLE(NFD)

!     Round date and express in units of fraction
         DF=ANINT(DJM*FD)

!     Separate day and fraction
         F=MOD(DF,FD)
         IF (F.LT.0D0) F=F+FD
         D=(DF-F)/FD

!     Express day in Gregorian calendar
         JD=NINT(D)+2400001

         N4=4*(JD+((2*((4*JD-17918)/146097)*3)/4+1)/2-37)
         ND10=10*(MOD(N4-237,1461)/4)+5

         IYMDF(1)=N4/1461-4712
         IYMDF(2)=MOD(ND10/306+2,12)+1
         IYMDF(3)=MOD(ND10,306)/10+1
         IYMDF(4)=NINT(F)

      END IF

      END
      SUBROUTINE sla_DJCL (DJM, IY, IM, ID, FD, J)
!+
!     - - - - -
!      D J C L
!     - - - - -
!
!  Modified Julian Date to Gregorian year, month, day,
!  and fraction of a day.
!
!  Given:
!     DJM      dp     modified Julian Date (JD-2400000.5)
!
!  Returned:
!     IY       int    year
!     IM       int    month
!     ID       int    day
!     FD       dp     fraction of day
!     J        int    status:
!                       0 = OK
!                      -1 = unacceptable date (before 4701BC March 1)
!
!  The algorithm is derived from that of Hatcher 1984
!  (QJRAS 25, 53-55).
!
!  P.T.Wallace   Starlink   27 April 1998
!
!  Copyright (C) 1998 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DJM
      INTEGER IY,IM,ID
      DOUBLE PRECISION FD
      INTEGER J

      DOUBLE PRECISION F,D
      INTEGER JD,N4,ND10



!  Check if date is acceptable
      IF (DJM.LE.-2395520D0.OR.DJM.GE.1D9) THEN
         J=-1
      ELSE
         J=0

!     Separate day and fraction
         F=MOD(DJM,1D0)
         IF (F.LT.0D0) F=F+1D0
         D=ANINT(DJM-F)

!     Express day in Gregorian calendar
         JD=NINT(D)+2400001

         N4=4*(JD+((6*((4*JD-17918)/146097))/4+1)/2-37)
         ND10=10*(MOD(N4-237,1461)/4)+5

         IY=N4/1461-4712
         IM=MOD(ND10/306+2,12)+1
         ID=MOD(ND10,306)/10+1
         FD=F

         J=0

      END IF

      END
      SUBROUTINE sla_DM2AV (RMAT, AXVEC)
!+
!     - - - - - -
!      D M 2 A V
!     - - - - - -
!
!  From a rotation matrix, determine the corresponding axial vector.
!  (double precision)
!
!  A rotation matrix describes a rotation about some arbitrary axis.
!  The axis is called the Euler axis, and the angle through which the
!  reference frame rotates is called the Euler angle.  The axial
!  vector returned by this routine has the same direction as the
!  Euler axis, and its magnitude is the Euler angle in radians.  (The
!  magnitude and direction can be separated by means of the routine
!  sla_DVN.)
!
!  Given:
!    RMAT   d(3,3)   rotation matrix
!
!  Returned:
!    AXVEC  d(3)     axial vector (radians)
!
!  The reference frame rotates clockwise as seen looking along
!  the axial vector from the origin.
!
!  If RMAT is null, so is the result.
!
!  P.T.Wallace   Starlink   19 April 2000
!
!  Copyright (C) 2000 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RMAT(3,3),AXVEC(3)

      DOUBLE PRECISION X,Y,Z,S2,C2,PHI,F



      X = RMAT(2,3)-RMAT(3,2)
      Y = RMAT(3,1)-RMAT(1,3)
      Z = RMAT(1,2)-RMAT(2,1)
      S2 = SQRT(X*X+Y*Y+Z*Z)
      IF (S2.NE.0D0) THEN
         C2 = RMAT(1,1)+RMAT(2,2)+RMAT(3,3)-1D0
         PHI = ATAN2(S2,C2)
         F = PHI/S2
         AXVEC(1) = X*F
         AXVEC(2) = Y*F
         AXVEC(3) = Z*F
      ELSE
         AXVEC(1) = 0D0
         AXVEC(2) = 0D0
         AXVEC(3) = 0D0
      END IF

      END
      SUBROUTINE sla_DMAT (N, A, Y, D, JF, IW)
!+
!     - - - - -
!      D M A T
!     - - - - -
!
!  Matrix inversion & solution of simultaneous equations
!  (double precision)
!
!  For the set of n simultaneous equations in n unknowns:
!     A.Y = X
!
!  where:
!     A is a non-singular N x N matrix
!     Y is the vector of N unknowns
!     X is the known vector
!
!  DMATRX computes:
!     the inverse of matrix A
!     the determinant of matrix A
!     the vector of N unknowns
!
!  Arguments:
!
!     symbol  type   dimension           before              after
!
!       N      i                    no. of unknowns       unchanged
!       A      d      (N,N)             matrix             inverse
!       Y      d       (N)            known vector      solution vector
!       D      d                           -             determinant
!     * JF     i                           -           singularity flag
!       IW     i       (N)                 -              workspace
!
!  * JF is the singularity flag.  If the matrix is non-singular, JF=0
!    is returned.  If the matrix is singular, JF=-1 & D=0D0 are
!    returned.  In the latter case, the contents of array A on return
!    are undefined.
!
!  Algorithm:
!     Gaussian elimination with partial pivoting.
!
!  Speed:
!     Very fast.
!
!  Accuracy:
!     Fairly accurate - errors 1 to 4 times those of routines optimized
!     for accuracy.
!
!  P.T.Wallace   Starlink   4 December 2001
!
!  Copyright (C) 2001 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER N
      DOUBLE PRECISION A(N,N),Y(N),D
      INTEGER JF
      INTEGER IW(N)

      DOUBLE PRECISION SFA
      PARAMETER (SFA=1D-20)

      INTEGER K,IMX,I,J,NP1MK,KI
      DOUBLE PRECISION AMX,T,AKK,YK,AIK


      JF=0
      D=1D0
      DO K=1,N
         AMX=DABS(A(K,K))
         IMX=K
         IF (K.NE.N) THEN
            DO I=K+1,N
               T=DABS(A(I,K))
               IF (T.GT.AMX) THEN
                  AMX=T
                  IMX=I
               END IF
            END DO
         END IF
         IF (AMX.LT.SFA) THEN
            JF=-1
         ELSE
            IF (IMX.NE.K) THEN
               DO J=1,N
                  T=A(K,J)
                  A(K,J)=A(IMX,J)
                  A(IMX,J)=T
               END DO
               T=Y(K)
               Y(K)=Y(IMX)
               Y(IMX)=T
               D=-D
            END IF
            IW(K)=IMX
            AKK=A(K,K)
            D=D*AKK
            IF (DABS(D).LT.SFA) THEN
               JF=-1
            ELSE
               AKK=1D0/AKK
               A(K,K)=AKK
               DO J=1,N
                  IF (J.NE.K) A(K,J)=A(K,J)*AKK
               END DO
               YK=Y(K)*AKK
               Y(K)=YK
               DO I=1,N
                  AIK=A(I,K)
                  IF (I.NE.K) THEN
                     DO J=1,N
                        IF (J.NE.K) A(I,J)=A(I,J)-AIK*A(K,J)
                     END DO
                     Y(I)=Y(I)-AIK*YK
                  END IF
               END DO
               DO I=1,N
                  IF (I.NE.K) A(I,K)=-A(I,K)*AKK
               END DO
            END IF
         END IF
      END DO
      IF (JF.NE.0) THEN
         D=0D0
      ELSE
         DO K=1,N
            NP1MK=N+1-K
            KI=IW(NP1MK)
            IF (NP1MK.NE.KI) THEN
               DO I=1,N
                  T=A(I,NP1MK)
                  A(I,NP1MK)=A(I,KI)
                  A(I,KI)=T
               END DO
            END IF
         END DO
      END IF

      END
      SUBROUTINE sla_DMOON (DATE, PV)
!+
!     - - - - - -
!      D M O O N
!     - - - - - -
!
!  Approximate geocentric position and velocity of the Moon
!  (double precision)
!
!  Given:
!     DATE       D       TDB (loosely ET) as a Modified Julian Date
!                                                    (JD-2400000.5)
!
!  Returned:
!     PV         D(6)    Moon x,y,z,xdot,ydot,zdot, mean equator and
!                                         equinox of date (AU, AU/s)
!
!  Notes:
!
!  1  This routine is a full implementation of the algorithm
!     published by Meeus (see reference).
!
!  2  Meeus quotes accuracies of 10 arcsec in longitude, 3 arcsec in
!     latitude and 0.2 arcsec in HP (equivalent to about 20 km in
!     distance).  Comparison with JPL DE200 over the interval
!     1960-2025 gives RMS errors of 3.7 arcsec and 83 mas/hour in
!     longitude, 2.3 arcsec and 48 mas/hour in latitude, 11 km
!     and 81 mm/s in distance.  The maximum errors over the same
!     interval are 18 arcsec and 0.50 arcsec/hour in longitude,
!     11 arcsec and 0.24 arcsec/hour in latitude, 40 km and 0.29 m/s
!     in distance.
!
!  3  The original algorithm is expressed in terms of the obsolete
!     timescale Ephemeris Time.  Either TDB or TT can be used, but
!     not UT without incurring significant errors (30 arcsec at
!     the present time) due to the Moon's 0.5 arcsec/sec movement.
!
!  4  The algorithm is based on pre IAU 1976 standards.  However,
!     the result has been moved onto the new (FK5) equinox, an
!     adjustment which is in any case much smaller than the
!     intrinsic accuracy of the procedure.
!
!  5  Velocity is obtained by a complete analytical differentiation
!     of the Meeus model.
!
!  Reference:
!     Meeus, l'Astronomie, June 1984, p348.
!
!  P.T.Wallace   Starlink   22 January 1998
!
!  Copyright (C) 1998 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,PV(6)

!  Degrees, arcseconds and seconds of time to radians
      DOUBLE PRECISION D2R,DAS2R,DS2R
      PARAMETER (D2R=0.0174532925199432957692369D0, &
                DAS2R=4.848136811095359935899141D-6, &
                DS2R=7.272205216643039903848712D-5)

!  Seconds per Julian century (86400*36525)
      DOUBLE PRECISION CJ
      PARAMETER (CJ=3155760000D0)

!  Julian epoch of B1950
      DOUBLE PRECISION B1950
      PARAMETER (B1950=1949.9997904423D0)

!  Earth equatorial radius in AU ( = 6378.137 / 149597870 )
      DOUBLE PRECISION ERADAU
      PARAMETER (ERADAU=4.2635212653763D-5)

      DOUBLE PRECISION T,THETA,SINOM,COSOM,DOMCOM,WA,DWA,WB,DWB,WOM, &
                      DWOM,SINWOM,COSWOM,V,DV,COEFF,EMN,EMPN,DN,FN,EN, &
                      DEN,DTHETA,FTHETA,EL,DEL,B,DB,BF,DBF,P,DP,SP,R, &
                      DR,X,Y,Z,XD,YD,ZD,SEL,CEL,SB,CB,RCB,RBD,W,EPJ, &
                      EQCOR,EPS,SINEPS,COSEPS,ES,EC
      INTEGER N,I

!
!  Coefficients for fundamental arguments
!
!   at J1900:  T**0, T**1, T**2, T**3
!   at epoch:  T**0, T**1
!
!  Units are degrees for position and Julian centuries for time
!

!  Moon's mean longitude
      DOUBLE PRECISION ELP0,ELP1,ELP2,ELP3,ELP,DELP
      PARAMETER (ELP0=270.434164D0, &
                ELP1=481267.8831D0, &
                ELP2=-0.001133D0, &
                ELP3=0.0000019D0)

!  Sun's mean anomaly
      DOUBLE PRECISION EM0,EM1,EM2,EM3,EM,DEM
      PARAMETER (EM0=358.475833D0, &
                EM1=35999.0498D0, &
                EM2=-0.000150D0, &
                EM3=-0.0000033D0)

!  Moon's mean anomaly
      DOUBLE PRECISION EMP0,EMP1,EMP2,EMP3,EMP,DEMP
      PARAMETER (EMP0=296.104608D0, &
                EMP1=477198.8491D0, &
                EMP2=0.009192D0, &
                EMP3=0.0000144D0)

!  Moon's mean elongation
      DOUBLE PRECISION D0,D1,D2,D3,D,DD
      PARAMETER (D0=350.737486D0, &
                D1=445267.1142D0, &
                D2=-0.001436D0, &
                D3=0.0000019D0)

!  Mean distance of the Moon from its ascending node
      DOUBLE PRECISION F0,F1,F2,F3,F,DF
      PARAMETER (F0=11.250889D0, &
                F1=483202.0251D0, &
                F2=-0.003211D0, &
                F3=-0.0000003D0)

!  Longitude of the Moon's ascending node
      DOUBLE PRECISION OM0,OM1,OM2,OM3,OM,DOM
      PARAMETER (OM0=259.183275D0, &
                OM1=-1934.1420D0, &
                OM2=0.002078D0, &
                OM3=0.0000022D0)

!  Coefficients for (dimensionless) E factor
      DOUBLE PRECISION E1,E2,E,DE,ESQ,DESQ
      PARAMETER (E1=-0.002495D0,E2=-0.00000752D0)

!  Coefficients for periodic variations etc
      DOUBLE PRECISION PAC,PA0,PA1
      PARAMETER (PAC=0.000233D0,PA0=51.2D0,PA1=20.2D0)
      DOUBLE PRECISION PBC
      PARAMETER (PBC=-0.001778D0)
      DOUBLE PRECISION PCC
      PARAMETER (PCC=0.000817D0)
      DOUBLE PRECISION PDC
      PARAMETER (PDC=0.002011D0)
      DOUBLE PRECISION PEC,PE0,PE1,PE2
      PARAMETER (PEC=0.003964D0, &
                          PE0=346.560D0,PE1=132.870D0,PE2=-0.0091731D0)
      DOUBLE PRECISION PFC
      PARAMETER (PFC=0.001964D0)
      DOUBLE PRECISION PGC
      PARAMETER (PGC=0.002541D0)
      DOUBLE PRECISION PHC
      PARAMETER (PHC=0.001964D0)
      DOUBLE PRECISION PIC
      PARAMETER (PIC=-0.024691D0)
      DOUBLE PRECISION PJC,PJ0,PJ1
      PARAMETER (PJC=-0.004328D0,PJ0=275.05D0,PJ1=-2.30D0)
      DOUBLE PRECISION CW1
      PARAMETER (CW1=0.0004664D0)
      DOUBLE PRECISION CW2
      PARAMETER (CW2=0.0000754D0)

!
!  Coefficients for Moon position
!
!   Tx(N)       = coefficient of L, B or P term (deg)
!   ITx(N,1-5)  = coefficients of M, M', D, F, E**n in argument
!
      INTEGER NL,NB,NP
      PARAMETER (NL=50,NB=45,NP=31)
      DOUBLE PRECISION TL(NL),TB(NB),TP(NP)
      INTEGER ITL(5,NL),ITB(5,NB),ITP(5,NP)
!
!  Longitude
!                                         M   M'  D   F   n
      DATA TL( 1)/            +6.288750D0                     /, &
          (ITL(I, 1),I=1,5)/            +0, +1, +0, +0,  0   /
      DATA TL( 2)/            +1.274018D0                     /, &
          (ITL(I, 2),I=1,5)/            +0, -1, +2, +0,  0   /
      DATA TL( 3)/            +0.658309D0                     /, &
          (ITL(I, 3),I=1,5)/            +0, +0, +2, +0,  0   /
      DATA TL( 4)/            +0.213616D0                     /, &
          (ITL(I, 4),I=1,5)/            +0, +2, +0, +0,  0   /
      DATA TL( 5)/            -0.185596D0                     /, &
          (ITL(I, 5),I=1,5)/            +1, +0, +0, +0,  1   /
      DATA TL( 6)/            -0.114336D0                     /, &
          (ITL(I, 6),I=1,5)/            +0, +0, +0, +2,  0   /
      DATA TL( 7)/            +0.058793D0                     /, &
          (ITL(I, 7),I=1,5)/            +0, -2, +2, +0,  0   /
      DATA TL( 8)/            +0.057212D0                     /, &
          (ITL(I, 8),I=1,5)/            -1, -1, +2, +0,  1   /
      DATA TL( 9)/            +0.053320D0                     /, &
          (ITL(I, 9),I=1,5)/            +0, +1, +2, +0,  0   /
      DATA TL(10)/            +0.045874D0                     /, &
          (ITL(I,10),I=1,5)/            -1, +0, +2, +0,  1   /
      DATA TL(11)/            +0.041024D0                     /, &
          (ITL(I,11),I=1,5)/            -1, +1, +0, +0,  1   /
      DATA TL(12)/            -0.034718D0                     /, &
          (ITL(I,12),I=1,5)/            +0, +0, +1, +0,  0   /
      DATA TL(13)/            -0.030465D0                     /, &
          (ITL(I,13),I=1,5)/            +1, +1, +0, +0,  1   /
      DATA TL(14)/            +0.015326D0                     /, &
          (ITL(I,14),I=1,5)/            +0, +0, +2, -2,  0   /
      DATA TL(15)/            -0.012528D0                     /, &
          (ITL(I,15),I=1,5)/            +0, +1, +0, +2,  0   /
      DATA TL(16)/            -0.010980D0                     /, &
          (ITL(I,16),I=1,5)/            +0, -1, +0, +2,  0   /
      DATA TL(17)/            +0.010674D0                     /, &
          (ITL(I,17),I=1,5)/            +0, -1, +4, +0,  0   /
      DATA TL(18)/            +0.010034D0                     /, &
          (ITL(I,18),I=1,5)/            +0, +3, +0, +0,  0   /
      DATA TL(19)/            +0.008548D0                     /, &
          (ITL(I,19),I=1,5)/            +0, -2, +4, +0,  0   /
      DATA TL(20)/            -0.007910D0                     /, &
          (ITL(I,20),I=1,5)/            +1, -1, +2, +0,  1   /
      DATA TL(21)/            -0.006783D0                     /, &
          (ITL(I,21),I=1,5)/            +1, +0, +2, +0,  1   /
      DATA TL(22)/            +0.005162D0                     /, &
          (ITL(I,22),I=1,5)/            +0, +1, -1, +0,  0   /
      DATA TL(23)/            +0.005000D0                     /, &
          (ITL(I,23),I=1,5)/            +1, +0, +1, +0,  1   /
      DATA TL(24)/            +0.004049D0                     /, &
          (ITL(I,24),I=1,5)/            -1, +1, +2, +0,  1   /
      DATA TL(25)/            +0.003996D0                     /, &
          (ITL(I,25),I=1,5)/            +0, +2, +2, +0,  0   /
      DATA TL(26)/            +0.003862D0                     /, &
          (ITL(I,26),I=1,5)/            +0, +0, +4, +0,  0   /
      DATA TL(27)/            +0.003665D0                     /, &
          (ITL(I,27),I=1,5)/            +0, -3, +2, +0,  0   /
      DATA TL(28)/            +0.002695D0                     /, &
          (ITL(I,28),I=1,5)/            -1, +2, +0, +0,  1   /
      DATA TL(29)/            +0.002602D0                     /, &
          (ITL(I,29),I=1,5)/            +0, +1, -2, -2,  0   /
      DATA TL(30)/            +0.002396D0                     /, &
          (ITL(I,30),I=1,5)/            -1, -2, +2, +0,  1   /
      DATA TL(31)/            -0.002349D0                     /, &
          (ITL(I,31),I=1,5)/            +0, +1, +1, +0,  0   /
      DATA TL(32)/            +0.002249D0                     /, &
          (ITL(I,32),I=1,5)/            -2, +0, +2, +0,  2   /
      DATA TL(33)/            -0.002125D0                     /, &
          (ITL(I,33),I=1,5)/            +1, +2, +0, +0,  1   /
      DATA TL(34)/            -0.002079D0                     /, &
          (ITL(I,34),I=1,5)/            +2, +0, +0, +0,  2   /
      DATA TL(35)/            +0.002059D0                     /, &
          (ITL(I,35),I=1,5)/            -2, -1, +2, +0,  2   /
      DATA TL(36)/            -0.001773D0                     /, &
          (ITL(I,36),I=1,5)/            +0, +1, +2, -2,  0   /
      DATA TL(37)/            -0.001595D0                     /, &
          (ITL(I,37),I=1,5)/            +0, +0, +2, +2,  0   /
      DATA TL(38)/            +0.001220D0                     /, &
          (ITL(I,38),I=1,5)/            -1, -1, +4, +0,  1   /
      DATA TL(39)/            -0.001110D0                     /, &
          (ITL(I,39),I=1,5)/            +0, +2, +0, +2,  0   /
      DATA TL(40)/            +0.000892D0                     /, &
          (ITL(I,40),I=1,5)/            +0, +1, -3, +0,  0   /
      DATA TL(41)/            -0.000811D0                     /, &
          (ITL(I,41),I=1,5)/            +1, +1, +2, +0,  1   /
      DATA TL(42)/            +0.000761D0                     /, &
          (ITL(I,42),I=1,5)/            -1, -2, +4, +0,  1   /
      DATA TL(43)/            +0.000717D0                     /, &
          (ITL(I,43),I=1,5)/            -2, +1, +0, +0,  2   /
      DATA TL(44)/            +0.000704D0                     /, &
          (ITL(I,44),I=1,5)/            -2, +1, -2, +0,  2   /
      DATA TL(45)/            +0.000693D0                     /, &
          (ITL(I,45),I=1,5)/            +1, -2, +2, +0,  1   /
      DATA TL(46)/            +0.000598D0                     /, &
          (ITL(I,46),I=1,5)/            -1, +0, +2, -2,  1   /
      DATA TL(47)/            +0.000550D0                     /, &
          (ITL(I,47),I=1,5)/            +0, +1, +4, +0,  0   /
      DATA TL(48)/            +0.000538D0                     /, &
          (ITL(I,48),I=1,5)/            +0, +4, +0, +0,  0   /
      DATA TL(49)/            +0.000521D0                     /, &
          (ITL(I,49),I=1,5)/            -1, +0, +4, +0,  1   /
      DATA TL(50)/            +0.000486D0                     /, &
          (ITL(I,50),I=1,5)/            +0, +2, -1, +0,  0   /
!
!  Latitude
!                                         M   M'  D   F   n
      DATA TB( 1)/            +5.128189D0                     /, &
          (ITB(I, 1),I=1,5)/            +0, +0, +0, +1,  0   /
      DATA TB( 2)/            +0.280606D0                     /, &
          (ITB(I, 2),I=1,5)/            +0, +1, +0, +1,  0   /
      DATA TB( 3)/            +0.277693D0                     /, &
          (ITB(I, 3),I=1,5)/            +0, +1, +0, -1,  0   /
      DATA TB( 4)/            +0.173238D0                     /, &
          (ITB(I, 4),I=1,5)/            +0, +0, +2, -1,  0   /
      DATA TB( 5)/            +0.055413D0                     /, &
          (ITB(I, 5),I=1,5)/            +0, -1, +2, +1,  0   /
      DATA TB( 6)/            +0.046272D0                     /, &
          (ITB(I, 6),I=1,5)/            +0, -1, +2, -1,  0   /
      DATA TB( 7)/            +0.032573D0                     /, &
          (ITB(I, 7),I=1,5)/            +0, +0, +2, +1,  0   /
      DATA TB( 8)/            +0.017198D0                     /, &
          (ITB(I, 8),I=1,5)/            +0, +2, +0, +1,  0   /
      DATA TB( 9)/            +0.009267D0                     /, &
          (ITB(I, 9),I=1,5)/            +0, +1, +2, -1,  0   /
      DATA TB(10)/            +0.008823D0                     /, &
          (ITB(I,10),I=1,5)/            +0, +2, +0, -1,  0   /
      DATA TB(11)/            +0.008247D0                     /, &
          (ITB(I,11),I=1,5)/            -1, +0, +2, -1,  1   /
      DATA TB(12)/            +0.004323D0                     /, &
          (ITB(I,12),I=1,5)/            +0, -2, +2, -1,  0   /
      DATA TB(13)/            +0.004200D0                     /, &
          (ITB(I,13),I=1,5)/            +0, +1, +2, +1,  0   /
      DATA TB(14)/            +0.003372D0                     /, &
          (ITB(I,14),I=1,5)/            -1, +0, -2, +1,  1   /
      DATA TB(15)/            +0.002472D0                     /, &
          (ITB(I,15),I=1,5)/            -1, -1, +2, +1,  1   /
      DATA TB(16)/            +0.002222D0                     /, &
          (ITB(I,16),I=1,5)/            -1, +0, +2, +1,  1   /
      DATA TB(17)/            +0.002072D0                     /, &
          (ITB(I,17),I=1,5)/            -1, -1, +2, -1,  1   /
      DATA TB(18)/            +0.001877D0                     /, &
          (ITB(I,18),I=1,5)/            -1, +1, +0, +1,  1   /
      DATA TB(19)/            +0.001828D0                     /, &
          (ITB(I,19),I=1,5)/            +0, -1, +4, -1,  0   /
      DATA TB(20)/            -0.001803D0                     /, &
          (ITB(I,20),I=1,5)/            +1, +0, +0, +1,  1   /
      DATA TB(21)/            -0.001750D0                     /, &
          (ITB(I,21),I=1,5)/            +0, +0, +0, +3,  0   /
      DATA TB(22)/            +0.001570D0                     /, &
          (ITB(I,22),I=1,5)/            -1, +1, +0, -1,  1   /
      DATA TB(23)/            -0.001487D0                     /, &
          (ITB(I,23),I=1,5)/            +0, +0, +1, +1,  0   /
      DATA TB(24)/            -0.001481D0                     /, &
          (ITB(I,24),I=1,5)/            +1, +1, +0, +1,  1   /
      DATA TB(25)/            +0.001417D0                     /, &
          (ITB(I,25),I=1,5)/            -1, -1, +0, +1,  1   /
      DATA TB(26)/            +0.001350D0                     /, &
          (ITB(I,26),I=1,5)/            -1, +0, +0, +1,  1   /
      DATA TB(27)/            +0.001330D0                     /, &
          (ITB(I,27),I=1,5)/            +0, +0, -1, +1,  0   /
      DATA TB(28)/            +0.001106D0                     /, &
          (ITB(I,28),I=1,5)/            +0, +3, +0, +1,  0   /
      DATA TB(29)/            +0.001020D0                     /, &
          (ITB(I,29),I=1,5)/            +0, +0, +4, -1,  0   /
      DATA TB(30)/            +0.000833D0                     /, &
          (ITB(I,30),I=1,5)/            +0, -1, +4, +1,  0   /
      DATA TB(31)/            +0.000781D0                     /, &
          (ITB(I,31),I=1,5)/            +0, +1, +0, -3,  0   /
      DATA TB(32)/            +0.000670D0                     /, &
          (ITB(I,32),I=1,5)/            +0, -2, +4, +1,  0   /
      DATA TB(33)/            +0.000606D0                     /, &
          (ITB(I,33),I=1,5)/            +0, +0, +2, -3,  0   /
      DATA TB(34)/            +0.000597D0                     /, &
          (ITB(I,34),I=1,5)/            +0, +2, +2, -1,  0   /
      DATA TB(35)/            +0.000492D0                     /, &
          (ITB(I,35),I=1,5)/            -1, +1, +2, -1,  1   /
      DATA TB(36)/            +0.000450D0                     /, &
          (ITB(I,36),I=1,5)/            +0, +2, -2, -1,  0   /
      DATA TB(37)/            +0.000439D0                     /, &
          (ITB(I,37),I=1,5)/            +0, +3, +0, -1,  0   /
      DATA TB(38)/            +0.000423D0                     /, &
          (ITB(I,38),I=1,5)/            +0, +2, +2, +1,  0   /
      DATA TB(39)/            +0.000422D0                     /, &
          (ITB(I,39),I=1,5)/            +0, -3, +2, -1,  0   /
      DATA TB(40)/            -0.000367D0                     /, &
          (ITB(I,40),I=1,5)/            +1, -1, +2, +1,  1   /
      DATA TB(41)/            -0.000353D0                     /, &
          (ITB(I,41),I=1,5)/            +1, +0, +2, +1,  1   /
      DATA TB(42)/            +0.000331D0                     /, &
          (ITB(I,42),I=1,5)/            +0, +0, +4, +1,  0   /
      DATA TB(43)/            +0.000317D0                     /, &
          (ITB(I,43),I=1,5)/            -1, +1, +2, +1,  1   /
      DATA TB(44)/            +0.000306D0                     /, &
          (ITB(I,44),I=1,5)/            -2, +0, +2, -1,  2   /
      DATA TB(45)/            -0.000283D0                     /, &
          (ITB(I,45),I=1,5)/            +0, +1, +0, +3,  0   /
!
!  Parallax
!                                         M   M'  D   F   n
      DATA TP( 1)/            +0.950724D0                     /, &
          (ITP(I, 1),I=1,5)/            +0, +0, +0, +0,  0   /
      DATA TP( 2)/            +0.051818D0                     /, &
          (ITP(I, 2),I=1,5)/            +0, +1, +0, +0,  0   /
      DATA TP( 3)/            +0.009531D0                     /, &
          (ITP(I, 3),I=1,5)/            +0, -1, +2, +0,  0   /
      DATA TP( 4)/            +0.007843D0                     /, &
          (ITP(I, 4),I=1,5)/            +0, +0, +2, +0,  0   /
      DATA TP( 5)/            +0.002824D0                     /, &
          (ITP(I, 5),I=1,5)/            +0, +2, +0, +0,  0   /
      DATA TP( 6)/            +0.000857D0                     /, &
          (ITP(I, 6),I=1,5)/            +0, +1, +2, +0,  0   /
      DATA TP( 7)/            +0.000533D0                     /, &
          (ITP(I, 7),I=1,5)/            -1, +0, +2, +0,  1   /
      DATA TP( 8)/            +0.000401D0                     /, &
          (ITP(I, 8),I=1,5)/            -1, -1, +2, +0,  1   /
      DATA TP( 9)/            +0.000320D0                     /, &
          (ITP(I, 9),I=1,5)/            -1, +1, +0, +0,  1   /
      DATA TP(10)/            -0.000271D0                     /, &
          (ITP(I,10),I=1,5)/            +0, +0, +1, +0,  0   /
      DATA TP(11)/            -0.000264D0                     /, &
          (ITP(I,11),I=1,5)/            +1, +1, +0, +0,  1   /
      DATA TP(12)/            -0.000198D0                     /, &
          (ITP(I,12),I=1,5)/            +0, -1, +0, +2,  0   /
      DATA TP(13)/            +0.000173D0                     /, &
          (ITP(I,13),I=1,5)/            +0, +3, +0, +0,  0   /
      DATA TP(14)/            +0.000167D0                     /, &
          (ITP(I,14),I=1,5)/            +0, -1, +4, +0,  0   /
      DATA TP(15)/            -0.000111D0                     /, &
          (ITP(I,15),I=1,5)/            +1, +0, +0, +0,  1   /
      DATA TP(16)/            +0.000103D0                     /, &
          (ITP(I,16),I=1,5)/            +0, -2, +4, +0,  0   /
      DATA TP(17)/            -0.000084D0                     /, &
          (ITP(I,17),I=1,5)/            +0, +2, -2, +0,  0   /
      DATA TP(18)/            -0.000083D0                     /, &
          (ITP(I,18),I=1,5)/            +1, +0, +2, +0,  1   /
      DATA TP(19)/            +0.000079D0                     /, &
          (ITP(I,19),I=1,5)/            +0, +2, +2, +0,  0   /
      DATA TP(20)/            +0.000072D0                     /, &
          (ITP(I,20),I=1,5)/            +0, +0, +4, +0,  0   /
      DATA TP(21)/            +0.000064D0                     /, &
          (ITP(I,21),I=1,5)/            -1, +1, +2, +0,  1   /
      DATA TP(22)/            -0.000063D0                     /, &
          (ITP(I,22),I=1,5)/            +1, -1, +2, +0,  1   /
      DATA TP(23)/            +0.000041D0                     /, &
          (ITP(I,23),I=1,5)/            +1, +0, +1, +0,  1   /
      DATA TP(24)/            +0.000035D0                     /, &
          (ITP(I,24),I=1,5)/            -1, +2, +0, +0,  1   /
      DATA TP(25)/            -0.000033D0                     /, &
          (ITP(I,25),I=1,5)/            +0, +3, -2, +0,  0   /
      DATA TP(26)/            -0.000030D0                     /, &
          (ITP(I,26),I=1,5)/            +0, +1, +1, +0,  0   /
      DATA TP(27)/            -0.000029D0                     /, &
          (ITP(I,27),I=1,5)/            +0, +0, -2, +2,  0   /
      DATA TP(28)/            -0.000029D0                     /, &
          (ITP(I,28),I=1,5)/            +1, +2, +0, +0,  1   /
      DATA TP(29)/            +0.000026D0                     /, &
          (ITP(I,29),I=1,5)/            -2, +0, +2, +0,  2   /
      DATA TP(30)/            -0.000023D0                     /, &
          (ITP(I,30),I=1,5)/            +0, +1, -2, +2,  0   /
      DATA TP(31)/            +0.000019D0                     /, &
          (ITP(I,31),I=1,5)/            -1, -1, +4, +0,  1   /



!  Centuries since J1900
      T=(DATE-15019.5D0)/36525D0

!
!  Fundamental arguments (radians) and derivatives (radians per
!  Julian century) for the current epoch
!

!  Moon's mean longitude
      ELP=D2R*MOD(ELP0+(ELP1+(ELP2+ELP3*T)*T)*T,360D0)
      DELP=D2R*(ELP1+(2D0*ELP2+3D0*ELP3*T)*T)

!  Sun's mean anomaly
      EM=D2R*MOD(EM0+(EM1+(EM2+EM3*T)*T)*T,360D0)
      DEM=D2R*(EM1+(2D0*EM2+3D0*EM3*T)*T)

!  Moon's mean anomaly
      EMP=D2R*MOD(EMP0+(EMP1+(EMP2+EMP3*T)*T)*T,360D0)
      DEMP=D2R*(EMP1+(2D0*EMP2+3D0*EMP3*T)*T)

!  Moon's mean elongation
      D=D2R*MOD(D0+(D1+(D2+D3*T)*T)*T,360D0)
      DD=D2R*(D1+(2D0*D2+3D0*D3*T)*T)

!  Mean distance of the Moon from its ascending node
      F=D2R*MOD(F0+(F1+(F2+F3*T)*T)*T,360D0)
      DF=D2R*(F1+(2D0*F2+3D0*F3*T)*T)

!  Longitude of the Moon's ascending node
      OM=D2R*MOD(OM0+(OM1+(OM2+OM3*T)*T)*T,360D0)
      DOM=D2R*(OM1+(2D0*OM2+3D0*OM3*T)*T)
      SINOM=SIN(OM)
      COSOM=COS(OM)
      DOMCOM=DOM*COSOM

!  Add the periodic variations
      THETA=D2R*(PA0+PA1*T)
      WA=SIN(THETA)
      DWA=D2R*PA1*COS(THETA)
      THETA=D2R*(PE0+(PE1+PE2*T)*T)
      WB=PEC*SIN(THETA)
      DWB=D2R*PEC*(PE1+2D0*PE2*T)*COS(THETA)
      ELP=ELP+D2R*(PAC*WA+WB+PFC*SINOM)
      DELP=DELP+D2R*(PAC*DWA+DWB+PFC*DOMCOM)
      EM=EM+D2R*PBC*WA
      DEM=DEM+D2R*PBC*DWA
      EMP=EMP+D2R*(PCC*WA+WB+PGC*SINOM)
      DEMP=DEMP+D2R*(PCC*DWA+DWB+PGC*DOMCOM)
      D=D+D2R*(PDC*WA+WB+PHC*SINOM)
      DD=DD+D2R*(PDC*DWA+DWB+PHC*DOMCOM)
      WOM=OM+D2R*(PJ0+PJ1*T)
      DWOM=DOM+D2R*PJ1
      SINWOM=SIN(WOM)
      COSWOM=COS(WOM)
      F=F+D2R*(WB+PIC*SINOM+PJC*SINWOM)
      DF=DF+D2R*(DWB+PIC*DOMCOM+PJC*DWOM*COSWOM)

!  E-factor, and square
      E=1D0+(E1+E2*T)*T
      DE=E1+2D0*E2*T
      ESQ=E*E
      DESQ=2D0*E*DE

!
!  Series expansions
!

!  Longitude
      V=0D0
      DV=0D0
      DO N=NL,1,-1
         COEFF=TL(N)
         EMN=DBLE(ITL(1,N))
         EMPN=DBLE(ITL(2,N))
         DN=DBLE(ITL(3,N))
         FN=DBLE(ITL(4,N))
         I=ITL(5,N)
         IF (I.EQ.0) THEN
            EN=1D0
            DEN=0D0
         ELSE IF (I.EQ.1) THEN
            EN=E
            DEN=DE
         ELSE
            EN=ESQ
            DEN=DESQ
         END IF
         THETA=EMN*EM+EMPN*EMP+DN*D+FN*F
         DTHETA=EMN*DEM+EMPN*DEMP+DN*DD+FN*DF
         FTHETA=SIN(THETA)
         V=V+COEFF*FTHETA*EN
         DV=DV+COEFF*(COS(THETA)*DTHETA*EN+FTHETA*DEN)
      END DO
      EL=ELP+D2R*V
      DEL=(DELP+D2R*DV)/CJ

!  Latitude
      V=0D0
      DV=0D0
      DO N=NB,1,-1
         COEFF=TB(N)
         EMN=DBLE(ITB(1,N))
         EMPN=DBLE(ITB(2,N))
         DN=DBLE(ITB(3,N))
         FN=DBLE(ITB(4,N))
         I=ITB(5,N)
         IF (I.EQ.0) THEN
            EN=1D0
            DEN=0D0
         ELSE IF (I.EQ.1) THEN
            EN=E
            DEN=DE
         ELSE
            EN=ESQ
            DEN=DESQ
         END IF
         THETA=EMN*EM+EMPN*EMP+DN*D+FN*F
         DTHETA=EMN*DEM+EMPN*DEMP+DN*DD+FN*DF
         FTHETA=SIN(THETA)
         V=V+COEFF*FTHETA*EN
         DV=DV+COEFF*(COS(THETA)*DTHETA*EN+FTHETA*DEN)
      END DO
      BF=1D0-CW1*COSOM-CW2*COSWOM
      DBF=CW1*DOM*SINOM+CW2*DWOM*SINWOM
      B=D2R*V*BF
      DB=D2R*(DV*BF+V*DBF)/CJ

!  Parallax
      V=0D0
      DV=0D0
      DO N=NP,1,-1
         COEFF=TP(N)
         EMN=DBLE(ITP(1,N))
         EMPN=DBLE(ITP(2,N))
         DN=DBLE(ITP(3,N))
         FN=DBLE(ITP(4,N))
         I=ITP(5,N)
         IF (I.EQ.0) THEN
            EN=1D0
            DEN=0D0
         ELSE IF (I.EQ.1) THEN
            EN=E
            DEN=DE
         ELSE
            EN=ESQ
            DEN=DESQ
         END IF
         THETA=EMN*EM+EMPN*EMP+DN*D+FN*F
         DTHETA=EMN*DEM+EMPN*DEMP+DN*DD+FN*DF
         FTHETA=COS(THETA)
         V=V+COEFF*FTHETA*EN
         DV=DV+COEFF*(-SIN(THETA)*DTHETA*EN+FTHETA*DEN)
      END DO
      P=D2R*V
      DP=D2R*DV/CJ

!
!  Transformation into final form
!

!  Parallax to distance (AU, AU/sec)
      SP=SIN(P)
      R=ERADAU/SP
      DR=-R*DP*COS(P)/SP

!  Longitude, latitude to x,y,z (AU)
      SEL=SIN(EL)
      CEL=COS(EL)
      SB=SIN(B)
      CB=COS(B)
      RCB=R*CB
      RBD=R*DB
      W=RBD*SB-CB*DR
      X=RCB*CEL
      Y=RCB*SEL
      Z=R*SB
      XD=-Y*DEL-W*CEL
      YD=X*DEL-W*SEL
      ZD=RBD*CB+SB*DR

!  Julian centuries since J2000
      T=(DATE-51544.5D0)/36525D0

!  Fricke equinox correction
      EPJ=2000D0+T*100D0
      EQCOR=DS2R*(0.035D0+0.00085D0*(EPJ-B1950))

!  Mean obliquity (IAU 1976)
      EPS=DAS2R*(84381.448D0+(-46.8150D0+(-0.00059D0+0.001813D0*T)*T)*T)

!  To the equatorial system, mean of date, FK5 system
      SINEPS=SIN(EPS)
      COSEPS=COS(EPS)
      ES=EQCOR*SINEPS
      EC=EQCOR*COSEPS
      PV(1)=X-EC*Y+ES*Z
      PV(2)=EQCOR*X+Y*COSEPS-Z*SINEPS
      PV(3)=Y*SINEPS+Z*COSEPS
      PV(4)=XD-EC*YD+ES*ZD
      PV(5)=EQCOR*XD+YD*COSEPS-ZD*SINEPS
      PV(6)=YD*SINEPS+ZD*COSEPS

      END
      SUBROUTINE sla_DMXM (A, B, C)
!+
!     - - - - -
!      D M X M
!     - - - - -
!
!  Product of two 3x3 matrices:
!
!      matrix C  =  matrix A  x  matrix B
!
!  (double precision)
!
!  Given:
!      A      dp(3,3)        matrix
!      B      dp(3,3)        matrix
!
!  Returned:
!      C      dp(3,3)        matrix result
!
!  To comply with the ANSI Fortran 77 standard, A, B and C must
!  be different arrays.  However, the routine is coded so as to
!  work properly on the VAX and many other systems even if this
!  rule is violated.
!
!  P.T.Wallace   Starlink   5 April 1990
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION A(3,3),B(3,3),C(3,3)

      INTEGER I,J,K
      DOUBLE PRECISION W,WM(3,3)


!  Multiply into scratch matrix
      DO I=1,3
         DO J=1,3
            W=0D0
            DO K=1,3
               W=W+A(I,K)*B(K,J)
            END DO
            WM(I,J)=W
         END DO
      END DO

!  Return the result
      DO J=1,3
         DO I=1,3
            C(I,J)=WM(I,J)
         END DO
      END DO

      END
      SUBROUTINE sla_DMXV (DM, VA, VB)
!+
!     - - - - -
!      D M X V
!     - - - - -
!
!  Performs the 3-D forward unitary transformation:
!
!     vector VB = matrix DM * vector VA
!
!  (double precision)
!
!  Given:
!     DM       dp(3,3)    matrix
!     VA       dp(3)      vector
!
!  Returned:
!     VB       dp(3)      result vector
!
!  P.T.Wallace   Starlink   March 1986
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DM(3,3),VA(3),VB(3)

      INTEGER I,J
      DOUBLE PRECISION W,VW(3)


!  Matrix DM * vector VA -> vector VW
      DO J=1,3
         W=0D0
         DO I=1,3
            W=W+DM(J,I)*VA(I)
         END DO
         VW(J)=W
      END DO

!  Vector VW -> vector VB
      DO J=1,3
         VB(J)=VW(J)
      END DO

      END
      DOUBLE PRECISION FUNCTION sla_DPAV ( V1, V2 )
!+
!     - - - - -
!      D P A V
!     - - - - -
!
!  Position angle of one celestial direction with respect to another.
!
!  (double precision)
!
!  Given:
!     V1    d(3)    direction cosines of one point
!     V2    d(3)    direction cosines of the other point
!
!  (The coordinate frames correspond to RA,Dec, Long,Lat etc.)
!
!  The result is the bearing (position angle), in radians, of point
!  V2 with respect to point V1.  It is in the range +/- pi.  The
!  sense is such that if V2 is a small distance east of V1, the
!  bearing is about +pi/2.  Zero is returned if the two points
!  are coincident.
!
!  V1 and V2 need not be unit vectors.
!
!  The routine sla_DBEAR performs an equivalent function except
!  that the points are specified in the form of spherical
!  coordinates.
!
!  Patrick Wallace   Starlink   13 July 1997
!
!  Copyright (C) 1997 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION V1(3),V2(3)

      DOUBLE PRECISION X1,Y1,Z1,W,R,XU1,YU1,ZU1,DX,DY,DZ,SQ,CQ



!  Unit vector to point 1
      X1=V1(1)
      Y1=V1(2)
      Z1=V1(3)
      W=SQRT(X1*X1+Y1*Y1+Z1*Z1)
      IF (W.NE.0D0) THEN
         X1=X1/W
         Y1=Y1/W
         Z1=Z1/W
      END IF

!  Unit vector "north" from point 1
      R=SQRT(X1*X1+Y1*Y1)
      IF (R.EQ.0.0) R=1D-5
      W=Z1/R
      XU1=-X1*W
      YU1=-Y1*W
      ZU1=R

!  Vector from point 1 to point 2
      DX=V2(1)-X1
      DY=V2(2)-Y1
      DZ=V2(3)-Z1

!  Position angle
      SQ=DX*YU1*Z1+DY*ZU1*X1+DZ*XU1*Y1-DZ*YU1*X1-DY*XU1*Z1-DX*ZU1*Y1
      CQ=DX*XU1+DY*YU1+DZ*ZU1
      IF (SQ.EQ.0D0.AND.CQ.EQ.0D0) CQ=1D0
      sla_DPAV=ATAN2(SQ,CQ)

      END
      SUBROUTINE sla_DR2AF (NDP, ANGLE, SIGN, IDMSF)
!+
!     - - - - - -
!      D R 2 A F
!     - - - - - -
!
!  Convert an angle in radians to degrees, arcminutes, arcseconds
!  (double precision)
!
!  Given:
!     NDP      i      number of decimal places of arcseconds
!     ANGLE    d      angle in radians
!
!  Returned:
!     SIGN     c      '+' or '-'
!     IDMSF    i(4)   degrees, arcminutes, arcseconds, fraction
!
!  Notes:
!
!     1)  NDP less than zero is interpreted as zero.
!
!     2)  The largest useful value for NDP is determined by the size
!         of ANGLE, the format of DOUBLE PRECISION floating-point
!         numbers on the target machine, and the risk of overflowing
!         IDMSF(4).  For example, on the VAX, for ANGLE up to 2pi, the
!         available floating-point precision corresponds roughly to
!         NDP=12.  However, the practical limit is NDP=9, set by the
!         capacity of the 32-bit integer IDMSF(4).
!
!     3)  The absolute value of ANGLE may exceed 2pi.  In cases where it
!         does not, it is up to the caller to test for and handle the
!         case where ANGLE is very nearly 2pi and rounds up to 360 deg,
!         by testing for IDMSF(1)=360 and setting IDMSF(1-4) to zero.
!
!  Called:  sla_DD2TF
!
!  P.T.Wallace   Starlink   19 March 1999
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER NDP
      DOUBLE PRECISION ANGLE
      CHARACTER SIGN*(*)
      INTEGER IDMSF(4)

!  Hours to degrees * radians to turns
      DOUBLE PRECISION F
      PARAMETER (F=15D0/6.283185307179586476925287D0)



!  Scale then use days to h,m,s routine
      CALL sla_DD2TF(NDP,ANGLE*F,SIGN,IDMSF)

      END
      SUBROUTINE sla_DR2TF (NDP, ANGLE, SIGN, IHMSF)
!+
!     - - - - - -
!      D R 2 T F
!     - - - - - -
!
!  Convert an angle in radians to hours, minutes, seconds
!  (double precision)
!
!  Given:
!     NDP      i      number of decimal places of seconds
!     ANGLE    d      angle in radians
!
!  Returned:
!     SIGN     c      '+' or '-'
!     IHMSF    i(4)   hours, minutes, seconds, fraction
!
!  Notes:
!
!     1)  NDP less than zero is interpreted as zero.
!
!     2)  The largest useful value for NDP is determined by the size
!         of ANGLE, the format of DOUBLE PRECISION floating-point
!         numbers on the target machine, and the risk of overflowing
!         IHMSF(4).  For example, on the VAX, for ANGLE up to 2pi, the
!         available floating-point precision corresponds roughly to
!         NDP=12.  However, the practical limit is NDP=9, set by the
!         capacity of the 32-bit integer IHMSF(4).
!
!     3)  The absolute value of ANGLE may exceed 2pi.  In cases where it
!         does not, it is up to the caller to test for and handle the
!         case where ANGLE is very nearly 2pi and rounds up to 24 hours,
!         by testing for IHMSF(1)=24 and setting IHMSF(1-4) to zero.
!
!  Called:  sla_DD2TF
!
!  P.T.Wallace   Starlink   19 March 1999
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER NDP
      DOUBLE PRECISION ANGLE
      CHARACTER SIGN*(*)
      INTEGER IHMSF(4)

!  Turns to radians
      DOUBLE PRECISION T2R
      PARAMETER (T2R=6.283185307179586476925287D0)



!  Scale then use days to h,m,s routine
      CALL sla_DD2TF(NDP,ANGLE/T2R,SIGN,IHMSF)

      END
      DOUBLE PRECISION FUNCTION sla_DRANGE (ANGLE)
!+
!     - - - - - - -
!      D R A N G E
!     - - - - - - -
!
!  Normalize angle into range +/- pi  (double precision)
!
!  Given:
!     ANGLE     dp      the angle in radians
!
!  The result (double precision) is ANGLE expressed in the range +/- pi.
!
!  P.T.Wallace   Starlink   23 November 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION ANGLE

      DOUBLE PRECISION DPI,D2PI
      PARAMETER (DPI=3.141592653589793238462643D0)
      PARAMETER (D2PI=6.283185307179586476925287D0)


      sla_DRANGE=MOD(ANGLE,D2PI)
      IF (ABS(sla_DRANGE).GE.DPI) &
               sla_DRANGE=sla_DRANGE-SIGN(D2PI,ANGLE)

      END
      DOUBLE PRECISION FUNCTION sla_DRANRM (ANGLE)
!+
!     - - - - - - -
!      D R A N R M
!     - - - - - - -
!
!  Normalize angle into range 0-2 pi  (double precision)
!
!  Given:
!     ANGLE     dp      the angle in radians
!
!  The result is ANGLE expressed in the range 0-2 pi (double
!  precision).
!
!  P.T.Wallace   Starlink   23 November 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION ANGLE

      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=6.283185307179586476925286766559D0)


      sla_DRANRM=MOD(ANGLE,D2PI)
      IF (sla_DRANRM.LT.0D0) sla_DRANRM=sla_DRANRM+D2PI

      END
      SUBROUTINE sla_DS2C6 (A, B, R, AD, BD, RD, V)
!+
!     - - - - - -
!      D S 2 C 6
!     - - - - - -
!
!  Conversion of position & velocity in spherical coordinates
!  to Cartesian coordinates
!
!  (double precision)
!
!  Given:
!     A     dp      longitude (radians)
!     B     dp      latitude (radians)
!     R     dp      radial coordinate
!     AD    dp      longitude derivative (radians per unit time)
!     BD    dp      latitude derivative (radians per unit time)
!     RD    dp      radial derivative
!
!  Returned:
!     V     dp(6)   Cartesian position & velocity vector
!
!  P.T.Wallace   Starlink   10 July 1993
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION A,B,R,AD,BD,RD,V(6)

      DOUBLE PRECISION SA,CA,SB,CB,RCB,X,Y,RBD,W



!  Useful functions
      SA=SIN(A)
      CA=COS(A)
      SB=SIN(B)
      CB=COS(B)
      RCB=R*CB
      X=RCB*CA
      Y=RCB*SA
      RBD=R*BD
      W=RBD*SB-CB*RD

!  Position
      V(1)=X
      V(2)=Y
      V(3)=R*SB

!  Velocity
      V(4)=-Y*AD-W*CA
      V(5)=X*AD-W*SA
      V(6)=RBD*CB+SB*RD

      END
      SUBROUTINE sla_DS2TP (RA, DEC, RAZ, DECZ, XI, ETA, J)
!+
!     - - - - - -
!      D S 2 T P
!     - - - - - -
!
!  Projection of spherical coordinates onto tangent plane:
!  "gnomonic" projection - "standard coordinates" (double precision)
!
!  Given:
!     RA,DEC      dp   spherical coordinates of point to be projected
!     RAZ,DECZ    dp   spherical coordinates of tangent point
!
!  Returned:
!     XI,ETA      dp   rectangular coordinates on tangent plane
!     J           int  status:   0 = OK, star on tangent plane
!                                1 = error, star too far from axis
!                                2 = error, antistar on tangent plane
!                                3 = error, antistar too far from axis
!
!  P.T.Wallace   Starlink   18 July 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RA,DEC,RAZ,DECZ,XI,ETA
      INTEGER J

      DOUBLE PRECISION SDECZ,SDEC,CDECZ,CDEC, &
                      RADIF,SRADIF,CRADIF,DENOM

      DOUBLE PRECISION TINY
      PARAMETER (TINY=1D-6)


!  Trig functions
      SDECZ=SIN(DECZ)
      SDEC=SIN(DEC)
      CDECZ=COS(DECZ)
      CDEC=COS(DEC)
      RADIF=RA-RAZ
      SRADIF=SIN(RADIF)
      CRADIF=COS(RADIF)

!  Reciprocal of star vector length to tangent plane
      DENOM=SDEC*SDECZ+CDEC*CDECZ*CRADIF

!  Handle vectors too far from axis
      IF (DENOM.GT.TINY) THEN
         J=0
      ELSE IF (DENOM.GE.0D0) THEN
         J=1
         DENOM=TINY
      ELSE IF (DENOM.GT.-TINY) THEN
         J=2
         DENOM=-TINY
      ELSE
         J=3
      END IF

!  Compute tangent plane coordinates (even in dubious cases)
      XI=CDEC*SRADIF/DENOM
      ETA=(SDEC*CDECZ-CDEC*SDECZ*CRADIF)/DENOM

      END
      DOUBLE PRECISION FUNCTION sla_DSEP (A1, B1, A2, B2)
!+
!     - - - - -
!      D S E P
!     - - - - -
!
!  Angle between two points on a sphere.
!
!  (double precision)
!
!  Given:
!     A1,B1    d     spherical coordinates of one point
!     A2,B2    d     spherical coordinates of the other point
!
!  (The spherical coordinates are [RA,Dec], [Long,Lat] etc, in radians.)
!
!  The result is the angle, in radians, between the two points.  It
!  is always positive.
!
!  Called:  sla_DCS2C, sla_DSEPV
!
!  Last revision:   7 May 2000
!
!  Copyright P.T.Wallace.  All rights reserved.
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION A1,B1,A2,B2

      DOUBLE PRECISION V1(3),V2(3)
      DOUBLE PRECISION sla_DSEPV



!  Convert coordinates from spherical to Cartesian.
      CALL sla_DCS2C(A1,B1,V1)
      CALL sla_DCS2C(A2,B2,V2)

!  Angle between the vectors.
      sla_DSEP = sla_DSEPV(V1,V2)

      END
      DOUBLE PRECISION FUNCTION sla_DSEPV (V1, V2)
!+
!     - - - - - -
!      D S E P V
!     - - - - - -
!
!  Angle between two vectors.
!
!  (double precision)
!
!  Given:
!     V1      d(3)    first vector
!     V2      d(3)    second vector
!
!  The result is the angle, in radians, between the two vectors.  It
!  is always positive.
!
!  Notes:
!
!  1  There is no requirement for the vectors to be unit length.
!
!  2  If either vector is null, zero is returned.
!
!  3  The simplest formulation would use dot product alone.  However,
!     this would reduce the accuracy for angles near zero and pi.  The
!     algorithm uses both cross product and dot product, which maintains
!     accuracy for all sizes of angle.
!
!  Called:  sla_DVXV, sla_DVN, sla_DVDV
!
!  Last revision:   7 May 2000
!
!  Copyright P.T.Wallace.  All rights reserved.
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION V1(3),V2(3)

      DOUBLE PRECISION V1XV2(3),WV(3),S,C
      DOUBLE PRECISION sla_DVDV



!  Modulus of cross product = sine multiplied by the two moduli.
      CALL sla_DVXV(V1,V2,V1XV2)
      CALL sla_DVN(V1XV2,WV,S)

!  Dot product = cosine multiplied by the two moduli.
      C = sla_DVDV(V1,V2)

!  Angle between the vectors.
      IF (S.NE.0D0) THEN
         sla_DSEPV = ATAN2(S,C)
      ELSE
         sla_DSEPV = 0D0
      END IF

      END
      DOUBLE PRECISION FUNCTION sla_DT (EPOCH)
!+
!     - - -
!      D T
!     - - -
!
!  Estimate the offset between dynamical time and Universal Time
!  for a given historical epoch.
!
!  Given:
!     EPOCH       d        (Julian) epoch (e.g. 1850D0)
!
!  The result is a rough estimate of ET-UT (after 1984, TT-UT) at
!  the given epoch, in seconds.
!
!  Notes:
!
!  1  Depending on the epoch, one of three parabolic approximations
!     is used:
!
!      before 979    Stephenson & Morrison's 390 BC to AD 948 model
!      979 to 1708   Stephenson & Morrison's 948 to 1600 model
!      after 1708    McCarthy & Babcock's post-1650 model
!
!     The breakpoints are chosen to ensure continuity:  they occur
!     at places where the adjacent models give the same answer as
!     each other.
!
!  2  The accuracy is modest, with errors of up to 20 sec during
!     the interval since 1650, rising to perhaps 30 min by 1000 BC.
!     Comparatively accurate values from AD 1600 are tabulated in
!     the Astronomical Almanac (see section K8 of the 1995 AA).
!
!  3  The use of double-precision for both argument and result is
!     purely for compatibility with other SLALIB time routines.
!
!  4  The models used are based on a lunar tidal acceleration value
!     of -26.00 arcsec per century.
!
!  Reference:  Explanatory Supplement to the Astronomical Almanac,
!              ed P.K.Seidelmann, University Science Books (1992),
!              section 2.553, p83.  This contains references to
!              the Stephenson & Morrison and McCarthy & Babcock
!              papers.
!
!  P.T.Wallace   Starlink   1 March 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION EPOCH
      DOUBLE PRECISION T,W,S


!  Centuries since 1800
      T=(EPOCH-1800D0)/100D0

!  Select model
      IF (EPOCH.GE.1708.185161980887D0) THEN

!     Post-1708: use McCarthy & Babcock
         W=T-0.19D0
         S=5.156D0+13.3066D0*W*W
      ELSE IF (EPOCH.GE.979.0258204760233D0) THEN

!     979-1708: use Stephenson & Morrison's 948-1600 model
         S=25.5D0*T*T
      ELSE

!     Pre-979: use Stephenson & Morrison's 390 BC to AD 948 model
         S=1360.0D0+(320D0+44.3D0*T)*T
      END IF

!  Result
      sla_DT=S

      END
      SUBROUTINE sla_DTF2D (IHOUR, IMIN, SEC, DAYS, J)
!+
!     - - - - - -
!      D T F 2 D
!     - - - - - -
!
!  Convert hours, minutes, seconds to days (double precision)
!
!  Given:
!     IHOUR       int       hours
!     IMIN        int       minutes
!     SEC         dp        seconds
!
!  Returned:
!     DAYS        dp        interval in days
!     J           int       status:  0 = OK
!                                    1 = IHOUR outside range 0-23
!                                    2 = IMIN outside range 0-59
!                                    3 = SEC outside range 0-59.999...
!
!  Notes:
!
!     1)  The result is computed even if any of the range checks fail.
!
!     2)  The sign must be dealt with outside this routine.
!
!  P.T.Wallace   Starlink   July 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER IHOUR,IMIN
      DOUBLE PRECISION SEC,DAYS
      INTEGER J

!  Seconds per day
      DOUBLE PRECISION D2S
      PARAMETER (D2S=86400D0)



!  Preset status
      J=0

!  Validate sec, min, hour
      IF (SEC.LT.0D0.OR.SEC.GE.60D0) J=3
      IF (IMIN.LT.0.OR.IMIN.GT.59) J=2
      IF (IHOUR.LT.0.OR.IHOUR.GT.23) J=1

!  Compute interval
      DAYS=(60D0*(60D0*DBLE(IHOUR)+DBLE(IMIN))+SEC)/D2S

      END
      SUBROUTINE sla_DTF2R (IHOUR, IMIN, SEC, RAD, J)
!+
!     - - - - - -
!      D T F 2 R
!     - - - - - -
!
!  Convert hours, minutes, seconds to radians (double precision)
!
!  Given:
!     IHOUR       int       hours
!     IMIN        int       minutes
!     SEC         dp        seconds
!
!  Returned:
!     RAD         dp        angle in radians
!     J           int       status:  0 = OK
!                                    1 = IHOUR outside range 0-23
!                                    2 = IMIN outside range 0-59
!                                    3 = SEC outside range 0-59.999...
!
!  Called:
!     sla_DTF2D
!
!  Notes:
!
!     1)  The result is computed even if any of the range checks fail.
!
!     2)  The sign must be dealt with outside this routine.
!
!  P.T.Wallace   Starlink   July 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER IHOUR,IMIN
      DOUBLE PRECISION SEC,RAD
      INTEGER J

      DOUBLE PRECISION TURNS

!  Turns to radians
      DOUBLE PRECISION T2R
      PARAMETER (T2R=6.283185307179586476925287D0)



!  Convert to turns then radians
      CALL sla_DTF2D(IHOUR,IMIN,SEC,TURNS,J)
      RAD=T2R*TURNS

      END
      SUBROUTINE sla_DTP2S (XI, ETA, RAZ, DECZ, RA, DEC)
!+
!     - - - - - -
!      D T P 2 S
!     - - - - - -
!
!  Transform tangent plane coordinates into spherical
!  (double precision)
!
!  Given:
!     XI,ETA      dp   tangent plane rectangular coordinates
!     RAZ,DECZ    dp   spherical coordinates of tangent point
!
!  Returned:
!     RA,DEC      dp   spherical coordinates (0-2pi,+/-pi/2)
!
!  Called:        sla_DRANRM
!
!  P.T.Wallace   Starlink   24 July 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION XI,ETA,RAZ,DECZ,RA,DEC

      DOUBLE PRECISION sla_DRANRM

      DOUBLE PRECISION SDECZ,CDECZ,DENOM



      SDECZ=SIN(DECZ)
      CDECZ=COS(DECZ)

      DENOM=CDECZ-ETA*SDECZ

      RA=sla_DRANRM(ATAN2(XI,DENOM)+RAZ)
      DEC=ATAN2(SDECZ+ETA*CDECZ,SQRT(XI*XI+DENOM*DENOM))

      END
      SUBROUTINE sla_DTP2V (XI, ETA, V0, V)
!+
!     - - - - - -
!      D T P 2 V
!     - - - - - -
!
!  Given the tangent-plane coordinates of a star and the direction
!  cosines of the tangent point, determine the direction cosines
!  of the star.
!
!  (double precision)
!
!  Given:
!     XI,ETA    d       tangent plane coordinates of star
!     V0        d(3)    direction cosines of tangent point
!
!  Returned:
!     V         d(3)    direction cosines of star
!
!  Notes:
!
!  1  If vector V0 is not of unit length, the returned vector V will
!     be wrong.
!
!  2  If vector V0 points at a pole, the returned vector V will be
!     based on the arbitrary assumption that the RA of the tangent
!     point is zero.
!
!  3  This routine is the Cartesian equivalent of the routine sla_DTP2S.
!
!  P.T.Wallace   Starlink   11 February 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION XI,ETA,V0(3),V(3)

      DOUBLE PRECISION X,Y,Z,F,R


      X=V0(1)
      Y=V0(2)
      Z=V0(3)
      F=SQRT(1D0+XI*XI+ETA*ETA)
      R=SQRT(X*X+Y*Y)
      IF (R.EQ.0D0) THEN
         R=1D-20
         X=R
      END IF
      V(1)=(X-(XI*Y+ETA*X*Z)/R)/F
      V(2)=(Y+(XI*X-ETA*Y*Z)/R)/F
      V(3)=(Z+ETA*R)/F

      END
      SUBROUTINE sla_DTPS2C (XI, ETA, RA, DEC, RAZ1, DECZ1, &
                                              RAZ2, DECZ2, N)
!+
!     - - - - - - -
!      D T P S 2 C
!     - - - - - - -
!
!  From the tangent plane coordinates of a star of known RA,Dec,
!  determine the RA,Dec of the tangent point.
!
!  (double precision)
!
!  Given:
!     XI,ETA      d    tangent plane rectangular coordinates
!     RA,DEC      d    spherical coordinates
!
!  Returned:
!     RAZ1,DECZ1  d    spherical coordinates of tangent point, solution 1
!     RAZ2,DECZ2  d    spherical coordinates of tangent point, solution 2
!     N           i    number of solutions:
!                        0 = no solutions returned (note 2)
!                        1 = only the first solution is useful (note 3)
!                        2 = both solutions are useful (note 3)
!
!  Notes:
!
!  1  The RAZ1 and RAZ2 values are returned in the range 0-2pi.
!
!  2  Cases where there is no solution can only arise near the poles.
!     For example, it is clearly impossible for a star at the pole
!     itself to have a non-zero XI value, and hence it is
!     meaningless to ask where the tangent point would have to be
!     to bring about this combination of XI and DEC.
!
!  3  Also near the poles, cases can arise where there are two useful
!     solutions.  The argument N indicates whether the second of the
!     two solutions returned is useful.  N=1 indicates only one useful
!     solution, the usual case;  under these circumstances, the second
!     solution corresponds to the "over-the-pole" case, and this is
!     reflected in the values of RAZ2 and DECZ2 which are returned.
!
!  4  The DECZ1 and DECZ2 values are returned in the range +/-pi, but
!     in the usual, non-pole-crossing, case, the range is +/-pi/2.
!
!  5  This routine is the spherical equivalent of the routine sla_DTPV2C.
!
!  Called:  sla_DRANRM
!
!  P.T.Wallace   Starlink   5 June 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION XI,ETA,RA,DEC,RAZ1,DECZ1,RAZ2,DECZ2
      INTEGER N

      DOUBLE PRECISION X2,Y2,SD,CD,SDF,R2,R,S,C

      DOUBLE PRECISION sla_DRANRM


      X2=XI*XI
      Y2=ETA*ETA
      SD=SIN(DEC)
      CD=COS(DEC)
      SDF=SD*SQRT(1D0+X2+Y2)
      R2=CD*CD*(1D0+Y2)-SD*SD*X2
      IF (R2.GE.0D0) THEN
         R=SQRT(R2)
         S=SDF-ETA*R
         C=SDF*ETA+R
         IF (XI.EQ.0D0.AND.R.EQ.0D0) R=1D0
         RAZ1=sla_DRANRM(RA-ATAN2(XI,R))
         DECZ1=ATAN2(S,C)
         R=-R
         S=SDF-ETA*R
         C=SDF*ETA+R
         RAZ2=sla_DRANRM(RA-ATAN2(XI,R))
         DECZ2=ATAN2(S,C)
         IF (ABS(SDF).LT.1D0) THEN
            N=1
         ELSE
            N=2
         END IF
      ELSE
         N=0
      END IF

      END
      SUBROUTINE sla_DTPV2C (XI, ETA, V, V01, V02, N)
!+
!     - - - - - - -
!      D T P V 2 C
!     - - - - - - -
!
!  Given the tangent-plane coordinates of a star and its direction
!  cosines, determine the direction cosines of the tangent-point.
!
!  (double precision)
!
!  Given:
!     XI,ETA    d       tangent plane coordinates of star
!     V         d(3)    direction cosines of star
!
!  Returned:
!     V01       d(3)    direction cosines of tangent point, solution 1
!     V02       d(3)    direction cosines of tangent point, solution 2
!     N         i       number of solutions:
!                         0 = no solutions returned (note 2)
!                         1 = only the first solution is useful (note 3)
!                         2 = both solutions are useful (note 3)
!
!  Notes:
!
!  1  The vector V must be of unit length or the result will be wrong.
!
!  2  Cases where there is no solution can only arise near the poles.
!     For example, it is clearly impossible for a star at the pole
!     itself to have a non-zero XI value, and hence it is meaningless
!     to ask where the tangent point would have to be.
!
!  3  Also near the poles, cases can arise where there are two useful
!     solutions.  The argument N indicates whether the second of the
!     two solutions returned is useful.  N=1 indicates only one useful
!     solution, the usual case;  under these circumstances, the second
!     solution can be regarded as valid if the vector V02 is interpreted
!     as the "over-the-pole" case.
!
!  4  This routine is the Cartesian equivalent of the routine sla_DTPS2C.
!
!  P.T.Wallace   Starlink   5 June 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION XI,ETA,V(3),V01(3),V02(3)
      INTEGER N

      DOUBLE PRECISION X,Y,Z,RXY2,XI2,ETA2P1,SDF,R2,R,C


      X=V(1)
      Y=V(2)
      Z=V(3)
      RXY2=X*X+Y*Y
      XI2=XI*XI
      ETA2P1=ETA*ETA+1D0
      SDF=Z*SQRT(XI2+ETA2P1)
      R2=RXY2*ETA2P1-Z*Z*XI2
      IF (R2.GT.0D0) THEN
         R=SQRT(R2)
         C=(SDF*ETA+R)/(ETA2P1*SQRT(RXY2*(R2+XI2)))
         V01(1)=C*(X*R+Y*XI)
         V01(2)=C*(Y*R-X*XI)
         V01(3)=(SDF-ETA*R)/ETA2P1
         R=-R
         C=(SDF*ETA+R)/(ETA2P1*SQRT(RXY2*(R2+XI2)))
         V02(1)=C*(X*R+Y*XI)
         V02(2)=C*(Y*R-X*XI)
         V02(3)=(SDF-ETA*R)/ETA2P1
         IF (ABS(SDF).LT.1D0) THEN
            N=1
         ELSE
            N=2
         END IF
      ELSE
         N=0
      END IF

      END
      DOUBLE PRECISION FUNCTION sla_DTT (UTC)
!+
!     - - - -
!      D T T
!     - - - -
!
!  Increment to be applied to Coordinated Universal Time UTC to give
!  Terrestrial Time TT (formerly Ephemeris Time ET)
!
!  (double precision)
!
!  Given:
!     UTC      d      UTC date as a modified JD (JD-2400000.5)
!
!  Result:  TT-UTC in seconds
!
!  Notes:
!
!  1  The UTC is specified to be a date rather than a time to indicate
!     that care needs to be taken not to specify an instant which lies
!     within a leap second.  Though in most cases UTC can include the
!     fractional part, correct behaviour on the day of a leap second
!     can only be guaranteed up to the end of the second 23:59:59.
!
!  2  Pre 1972 January 1 a fixed value of 10 + ET-TAI is returned.
!
!  3  See also the routine sla_DT, which roughly estimates ET-UT for
!     historical epochs.
!
!  Called:  sla_DAT
!
!  P.T.Wallace   Starlink   6 December 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION UTC

      DOUBLE PRECISION sla_DAT


      sla_DTT=32.184D0+sla_DAT(UTC)

      END
      SUBROUTINE sla_DV2TP (V, V0, XI, ETA, J)
!+
!     - - - - - -
!      D V 2 T P
!     - - - - - -
!
!  Given the direction cosines of a star and of the tangent point,
!  determine the star's tangent-plane coordinates.
!
!  (double precision)
!
!  Given:
!     V         d(3)    direction cosines of star
!     V0        d(3)    direction cosines of tangent point
!
!  Returned:
!     XI,ETA    d       tangent plane coordinates of star
!     J         i       status:   0 = OK
!                                 1 = error, star too far from axis
!                                 2 = error, antistar on tangent plane
!                                 3 = error, antistar too far from axis
!
!  Notes:
!
!  1  If vector V0 is not of unit length, or if vector V is of zero
!     length, the results will be wrong.
!
!  2  If V0 points at a pole, the returned XI,ETA will be based on the
!     arbitrary assumption that the RA of the tangent point is zero.
!
!  3  This routine is the Cartesian equivalent of the routine sla_DS2TP.
!
!  P.T.Wallace   Starlink   27 November 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION V(3),V0(3),XI,ETA
      INTEGER J

      DOUBLE PRECISION X,Y,Z,X0,Y0,Z0,R2,R,W,D

      DOUBLE PRECISION TINY
      PARAMETER (TINY=1D-6)


      X=V(1)
      Y=V(2)
      Z=V(3)
      X0=V0(1)
      Y0=V0(2)
      Z0=V0(3)
      R2=X0*X0+Y0*Y0
      R=SQRT(R2)
      IF (R.EQ.0D0) THEN
         R=1D-20
         X0=R
      END IF
      W=X*X0+Y*Y0
      D=W+Z*Z0
      IF (D.GT.TINY) THEN
         J=0
      ELSE IF (D.GE.0D0) THEN
         J=1
         D=TINY
      ELSE IF (D.GT.-TINY) THEN
         J=2
         D=-TINY
      ELSE
         J=3
      END IF
      D=D*R
      XI=(Y*X0-X*Y0)/D
      ETA=(Z*R2-Z0*W)/D

      END
      DOUBLE PRECISION FUNCTION sla_DVDV (VA, VB)
!+
!     - - - - -
!      D V D V
!     - - - - -
!
!  Scalar product of two 3-vectors  (double precision)
!
!  Given:
!      VA      dp(3)     first vector
!      VB      dp(3)     second vector
!
!  The result is the scalar product VA.VB (double precision)
!
!  P.T.Wallace   Starlink   November 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION VA(3),VB(3)


      sla_DVDV=VA(1)*VB(1)+VA(2)*VB(2)+VA(3)*VB(3)

      END
      SUBROUTINE sla_DVN (V, UV, VM)
!+
!     - - - -
!      D V N
!     - - - -
!
!  Normalizes a 3-vector also giving the modulus (double precision)
!
!  Given:
!     V       dp(3)      vector
!
!  Returned:
!     UV      dp(3)      unit vector in direction of V
!     VM      dp         modulus of V
!
!  If the modulus of V is zero, UV is set to zero as well
!
!  P.T.Wallace   Starlink   23 November 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION V(3),UV(3),VM

      INTEGER I
      DOUBLE PRECISION W1,W2


!  Modulus
      W1=0D0
      DO I=1,3
         W2=V(I)
         W1=W1+W2*W2
      END DO
      W1=SQRT(W1)
      VM=W1

!  Normalize the vector
      IF (W1.LE.0D0) W1=1D0
      DO I=1,3
         UV(I)=V(I)/W1
      END DO

      END
      SUBROUTINE sla_DVXV (VA, VB, VC)
!+
!     - - - - -
!      D V X V
!     - - - - -
!
!  Vector product of two 3-vectors  (double precision)
!
!  Given:
!      VA      dp(3)     first vector
!      VB      dp(3)     second vector
!
!  Returned:
!      VC      dp(3)     vector result
!
!  P.T.Wallace   Starlink   March 1986
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION VA(3),VB(3),VC(3)

      DOUBLE PRECISION VW(3)
      INTEGER I


!  Form the vector product VA cross VB
      VW(1)=VA(2)*VB(3)-VA(3)*VB(2)
      VW(2)=VA(3)*VB(1)-VA(1)*VB(3)
      VW(3)=VA(1)*VB(2)-VA(2)*VB(1)

!  Return the result
      DO I=1,3
         VC(I)=VW(I)
      END DO

      END
      SUBROUTINE sla_E2H (HA, DEC, PHI, AZ, EL)
!+
!     - - - -
!      E 2 H
!     - - - -
!
!  Equatorial to horizon coordinates:  HA,Dec to Az,El
!
!  (single precision)
!
!  Given:
!     HA      r     hour angle
!     DEC     r     declination
!     PHI     r     observatory latitude
!
!  Returned:
!     AZ      r     azimuth
!     EL      r     elevation
!
!  Notes:
!
!  1)  All the arguments are angles in radians.
!
!  2)  Azimuth is returned in the range 0-2pi;  north is zero,
!      and east is +pi/2.  Elevation is returned in the range
!      +/-pi/2.
!
!  3)  The latitude must be geodetic.  In critical applications,
!      corrections for polar motion should be applied.
!
!  4)  In some applications it will be important to specify the
!      correct type of hour angle and declination in order to
!      produce the required type of azimuth and elevation.  In
!      particular, it may be important to distinguish between
!      elevation as affected by refraction, which would
!      require the "observed" HA,Dec, and the elevation
!      in vacuo, which would require the "topocentric" HA,Dec.
!      If the effects of diurnal aberration can be neglected, the
!      "apparent" HA,Dec may be used instead of the topocentric
!      HA,Dec.
!
!  5)  No range checking of arguments is carried out.
!
!  6)  In applications which involve many such calculations, rather
!      than calling the present routine it will be more efficient to
!      use inline code, having previously computed fixed terms such
!      as sine and cosine of latitude, and (for tracking a star)
!      sine and cosine of declination.
!
!  P.T.Wallace   Starlink   9 July 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL HA,DEC,PHI,AZ,EL

      REAL R2PI
      PARAMETER (R2PI=6.283185307179586476925286766559)

      REAL SH,CH,SD,CD,SP,CP,X,Y,Z,R,A


!  Useful trig functions
      SH=SIN(HA)
      CH=COS(HA)
      SD=SIN(DEC)
      CD=COS(DEC)
      SP=SIN(PHI)
      CP=COS(PHI)

!  Az,El as x,y,z
      X=-CH*CD*SP+SD*CP
      Y=-SH*CD
      Z=CH*CD*CP+SD*SP

!  To spherical
      R=SQRT(X*X+Y*Y)
      IF (R.EQ.0.0) THEN
         A=0.0
      ELSE
         A=ATAN2(Y,X)
      END IF
      IF (A.LT.0.0) A=A+R2PI
      AZ=A
      EL=ATAN2(Z,R)

      END
      SUBROUTINE sla_EARTH (IY, ID, FD, PV)
!+
!     - - - - - -
!      E A R T H
!     - - - - - -
!
!  Approximate heliocentric position and velocity of the Earth
!
!  Given:
!     IY       I       year
!     ID       I       day in year (1 = Jan 1st)
!     FD       R       fraction of day
!
!  Returned:
!     PV       R(6)    Earth position & velocity vector
!
!  Notes:
!
!  1  The date and time is TDB (loosely ET) in a Julian calendar
!     which has been aligned to the ordinary Gregorian
!     calendar for the interval 1900 March 1 to 2100 February 28.
!     The year and day can be obtained by calling sla_CALYD or
!     sla_CLYD.
!
!  2  The Earth heliocentric 6-vector is mean equator and equinox
!     of date.  Position part, PV(1-3), is in AU;  velocity part,
!     PV(4-6), is in AU/sec.
!
!  3  Max/RMS errors 1950-2050:
!       13/5 E-5 AU = 19200/7600 km in position
!       47/26 E-10 AU/s = 0.0070/0.0039 km/s in speed
!
!  4  More precise results are obtainable with the routine sla_EVP.
!
!  P.T.Wallace   Starlink   23 November 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER IY,ID
      REAL FD,PV(6)

      INTEGER IY4
      REAL TWOPI,SPEED,REMB,SEMB,YI,YF,T,ELM,GAMMA,EM,ELT,EPS0, &
          E,ESQ,V,R,ELMM,COSELT,SINEPS,COSEPS,W1,W2,SELMM,CELMM

      PARAMETER (TWOPI=6.28318530718)

!  Mean orbital speed of Earth, AU/s
      PARAMETER (SPEED=1.9913E-7)

!  Mean Earth:EMB distance and speed, AU and AU/s
      PARAMETER (REMB=3.12E-5,SEMB=8.31E-11)



!  Whole years & fraction of year, and years since J1900.0
      YI=FLOAT(IY-1900)
      IY4=MOD(MOD(IY,4)+4,4)
      YF=(FLOAT(4*(ID-1/(IY4+1))-IY4-2)+4.0*FD)/1461.0
      T=YI+YF

!  Geometric mean longitude of Sun
!  (cf 4.881627938+6.283319509911*T MOD 2PI)
      ELM=MOD(4.881628+TWOPI*YF+0.00013420*T,TWOPI)

!  Mean longitude of perihelion
      GAMMA=4.908230+3.0005E-4*T

!  Mean anomaly
      EM=ELM-GAMMA

!  Mean obliquity
      EPS0=0.40931975-2.27E-6*T

!  Eccentricity
      E=0.016751-4.2E-7*T
      ESQ=E*E

!  True anomaly
      V=EM+2.0*E*SIN(EM)+1.25*ESQ*SIN(2.0*EM)

!  True ecliptic longitude
      ELT=V+GAMMA

!  True distance
      R=(1.0-ESQ)/(1.0+E*COS(V))

!  Moon's mean longitude
      ELMM=MOD(4.72+83.9971*T,TWOPI)

!  Useful functions
      COSELT=COS(ELT)
      SINEPS=SIN(EPS0)
      COSEPS=COS(EPS0)
      W1=-R*SIN(ELT)
      W2=-SPEED*(COSELT+E*COS(GAMMA))
      SELMM=SIN(ELMM)
      CELMM=COS(ELMM)

!  Earth position and velocity
      PV(1)=-R*COSELT-REMB*CELMM
      PV(2)=(W1-REMB*SELMM)*COSEPS
      PV(3)=W1*SINEPS
      PV(4)=SPEED*(SIN(ELT)+E*SIN(GAMMA))+SEMB*SELMM
      PV(5)=(W2-SEMB*CELMM)*COSEPS
      PV(6)=W2*SINEPS

      END
      SUBROUTINE sla_ECLEQ (DL, DB, DATE, DR, DD)
!+
!     - - - - - -
!      E C L E Q
!     - - - - - -
!
!  Transformation from ecliptic coordinates to
!  J2000.0 equatorial coordinates (double precision)
!
!  Given:
!     DL,DB       dp      ecliptic longitude and latitude
!                           (mean of date, IAU 1980 theory, radians)
!     DATE        dp      TDB (loosely ET) as Modified Julian Date
!                                              (JD-2400000.5)
!  Returned:
!     DR,DD       dp      J2000.0 mean RA,Dec (radians)
!
!  Called:
!     sla_DCS2C, sla_ECMAT, sla_DIMXV, sla_PREC, sla_EPJ, sla_DCC2S,
!     sla_DRANRM, sla_DRANGE
!
!  P.T.Wallace   Starlink   March 1986
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DL,DB,DATE,DR,DD

      DOUBLE PRECISION sla_EPJ,sla_DRANRM,sla_DRANGE

      DOUBLE PRECISION RMAT(3,3),V1(3),V2(3)



!  Spherical to Cartesian
      CALL sla_DCS2C(DL,DB,V1)

!  Ecliptic to equatorial
      CALL sla_ECMAT(DATE,RMAT)
      CALL sla_DIMXV(RMAT,V1,V2)

!  Mean of date to J2000
      CALL sla_PREC(2000D0,sla_EPJ(DATE),RMAT)
      CALL sla_DIMXV(RMAT,V2,V1)

!  Cartesian to spherical
      CALL sla_DCC2S(V1,DR,DD)

!  Express in conventional ranges
      DR=sla_DRANRM(DR)
      DD=sla_DRANGE(DD)

      END
      SUBROUTINE sla_ECMAT (DATE, RMAT)
!+
!     - - - - - -
!      E C M A T
!     - - - - - -
!
!  Form the equatorial to ecliptic rotation matrix - IAU 1980 theory
!  (double precision)
!
!  Given:
!     DATE     dp         TDB (loosely ET) as Modified Julian Date
!                                            (JD-2400000.5)
!  Returned:
!     RMAT     dp(3,3)    matrix
!
!  Reference:
!     Murray,C.A., Vectorial Astrometry, section 4.3.
!
!  Note:
!    The matrix is in the sense   V(ecl)  =  RMAT * V(equ);  the
!    equator, equinox and ecliptic are mean of date.
!
!  Called:  sla_DEULER
!
!  P.T.Wallace   Starlink   23 August 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,RMAT(3,3)

!  Arc seconds to radians
      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

      DOUBLE PRECISION T,EPS0



!  Interval between basic epoch J2000.0 and current epoch (JC)
      T = (DATE-51544.5D0)/36525D0

!  Mean obliquity
      EPS0 = AS2R* &
        (84381.448D0+(-46.8150D0+(-0.00059D0+0.001813D0*T)*T)*T)

!  Matrix
      CALL sla_DEULER('X',EPS0,0D0,0D0,RMAT)

      END
      SUBROUTINE sla_ECOR (RM, DM, IY, ID, FD, RV, TL)
!+
!     - - - - -
!      E C O R
!     - - - - -
!
!  Component of Earth orbit velocity and heliocentric
!  light time in a given direction (single precision)
!
!  Given:
!     RM,DM    real    mean RA, Dec of date (radians)
!     IY       int     year
!     ID       int     day in year (1 = Jan 1st)
!     FD       real    fraction of day
!
!  Returned:
!     RV       real    component of Earth orbital velocity (km/sec)
!     TL       real    component of heliocentric light time (sec)
!
!  Notes:
!
!  1  The date and time is TDB (loosely ET) in a Julian calendar
!     which has been aligned to the ordinary Gregorian
!     calendar for the interval 1900 March 1 to 2100 February 28.
!     The year and day can be obtained by calling sla_CALYD or
!     sla_CLYD.
!
!  2  Sign convention:
!
!     The velocity component is +ve when the Earth is receding from
!     the given point on the sky.  The light time component is +ve
!     when the Earth lies between the Sun and the given point on
!     the sky.
!
!  3  Accuracy:
!
!     The velocity component is usually within 0.004 km/s of the
!     correct value and is never in error by more than 0.007 km/s.
!     The error in light time correction is about 0.03s at worst,
!     but is usually better than 0.01s. For applications requiring
!     higher accuracy, see the sla_EVP routine.
!
!  Called:  sla_EARTH, sla_CS2C, sla_VDV
!
!  P.T.Wallace   Starlink   24 November 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL RM,DM
      INTEGER IY,ID
      REAL FD,RV,TL

      REAL sla_VDV

      REAL PV(6),V(3),AUKM,AUSEC

!  AU to km and light sec (1985 Almanac)
      PARAMETER (AUKM=1.4959787066E8, &
                AUSEC=499.0047837)



!  Sun:Earth position & velocity vector
      CALL sla_EARTH(IY,ID,FD,PV)

!  Star position vector
      CALL sla_CS2C(RM,DM,V)

!  Velocity component
      RV=-AUKM*sla_VDV(PV(4),V)

!  Light time component
      TL=AUSEC*sla_VDV(PV(1),V)

      END
      SUBROUTINE sla_EG50 (DR, DD, DL, DB)
!+
!     - - - - -
!      E G 5 0
!     - - - - -
!
!  Transformation from B1950.0 'FK4' equatorial coordinates to
!  IAU 1958 galactic coordinates (double precision)
!
!  Given:
!     DR,DD       dp       B1950.0 'FK4' RA,Dec
!
!  Returned:
!     DL,DB       dp       galactic longitude and latitude L2,B2
!
!  (all arguments are radians)
!
!  Called:
!     sla_DCS2C, sla_DMXV, sla_DCC2S, sla_SUBET, sla_DRANRM, sla_DRANGE
!
!  Note:
!     The equatorial coordinates are B1950.0 'FK4'.  Use the
!     routine sla_EQGAL if conversion from J2000.0 coordinates
!     is required.
!
!  Reference:
!     Blaauw et al, Mon.Not.R.Astron.Soc.,121,123 (1960)
!
!  P.T.Wallace   Starlink   5 September 1993
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DR,DD,DL,DB

      DOUBLE PRECISION sla_DRANRM,sla_DRANGE

      DOUBLE PRECISION V1(3),V2(3),R,D

!
!  L2,B2 system of galactic coordinates
!
!  P = 192.25       RA of galactic north pole (mean B1950.0)
!  Q =  62.6        inclination of galactic to mean B1950.0 equator
!  R =  33          longitude of ascending node
!
!  P,Q,R are degrees
!
!
!  Equatorial to galactic rotation matrix
!
!  The Euler angles are P, Q, 90-R, about the z then y then
!  z axes.
!
!         +CP.CQ.SR-SP.CR     +SP.CQ.SR+CP.CR     -SQ.SR
!
!         -CP.CQ.CR-SP.SR     -SP.CQ.CR+CP.SR     +SQ.CR
!
!         +CP.SQ              +SP.SQ              +CQ
!

      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3), &
          RMAT(2,1),RMAT(2,2),RMAT(2,3), &
          RMAT(3,1),RMAT(3,2),RMAT(3,3) / &
      -0.066988739415D0,-0.872755765852D0,-0.483538914632D0, &
      +0.492728466075D0,-0.450346958020D0,+0.744584633283D0, &
      -0.867600811151D0,-0.188374601723D0,+0.460199784784D0 /



!  Remove E-terms
      CALL sla_SUBET(DR,DD,1950D0,R,D)

!  Spherical to Cartesian
      CALL sla_DCS2C(R,D,V1)

!  Rotate to galactic
      CALL sla_DMXV(RMAT,V1,V2)

!  Cartesian to spherical
      CALL sla_DCC2S(V2,DL,DB)

!  Express angles in conventional ranges
      DL=sla_DRANRM(DL)
      DB=sla_DRANGE(DB)

      END
      SUBROUTINE sla_EL2UE (DATE, JFORM, EPOCH, ORBINC, ANODE, &
                           PERIH, AORQ, E, AORL, DM, &
                           U, JSTAT)
!+
!     - - - - - -
!      E L 2 U E
!     - - - - - -
!
!  Transform conventional osculating orbital elements into "universal"
!  form.
!
!  Given:
!     DATE    d      epoch (TT MJD) of osculation (Note 3)
!     JFORM   i      choice of element set (1-3, Note 6)
!     EPOCH   d      epoch (TT MJD) of the elements
!     ORBINC  d      inclination (radians)
!     ANODE   d      longitude of the ascending node (radians)
!     PERIH   d      longitude or argument of perihelion (radians)
!     AORQ    d      mean distance or perihelion distance (AU)
!     E       d      eccentricity
!     AORL    d      mean anomaly or longitude (radians, JFORM=1,2 only)
!     DM      d      daily motion (radians, JFORM=1 only)
!
!  Returned:
!     U       d(13)  universal orbital elements (Note 1)
!
!               (1)  combined mass (M+m)
!               (2)  total energy of the orbit (alpha)
!               (3)  reference (osculating) epoch (t0)
!             (4-6)  position at reference epoch (r0)
!             (7-9)  velocity at reference epoch (v0)
!              (10)  heliocentric distance at reference epoch
!              (11)  r0.v0
!              (12)  date (t)
!              (13)  universal eccentric anomaly (psi) of date, approx
!
!     JSTAT   i      status:  0 = OK
!                            -1 = illegal JFORM
!                            -2 = illegal E
!                            -3 = illegal AORQ
!                            -4 = illegal DM
!                            -5 = numerical error
!
!  Called:  sla_UE2PV, sla_PV2UE
!
!  Notes
!
!  1  The "universal" elements are those which define the orbit for the
!     purposes of the method of universal variables (see reference).
!     They consist of the combined mass of the two bodies, an epoch,
!     and the position and velocity vectors (arbitrary reference frame)
!     at that epoch.  The parameter set used here includes also various
!     quantities that can, in fact, be derived from the other
!     information.  This approach is taken to avoiding unnecessary
!     computation and loss of accuracy.  The supplementary quantities
!     are (i) alpha, which is proportional to the total energy of the
!     orbit, (ii) the heliocentric distance at epoch, (iii) the
!     outwards component of the velocity at the given epoch, (iv) an
!     estimate of psi, the "universal eccentric anomaly" at a given
!     date and (v) that date.
!
!  2  The companion routine is sla_UE2PV.  This takes the set of numbers
!     that the present routine outputs and uses them to derive the
!     object's position and velocity.  A single prediction requires one
!     call to the present routine followed by one call to sla_UE2PV;
!     for convenience, the two calls are packaged as the routine
!     sla_PLANEL.  Multiple predictions may be made by again calling the
!     present routine once, but then calling sla_UE2PV multiple times,
!     which is faster than multiple calls to sla_PLANEL.
!
!  3  DATE is the epoch of osculation.  It is in the TT timescale
!     (formerly Ephemeris Time, ET) and is a Modified Julian Date
!     (JD-2400000.5).
!
!  4  The supplied orbital elements are with respect to the J2000
!     ecliptic and equinox.  The position and velocity parameters
!     returned in the array U are with respect to the mean equator and
!     equinox of epoch J2000, and are for the perihelion prior to the
!     specified epoch.
!
!  5  The universal elements returned in the array U are in canonical
!     units (solar masses, AU and canonical days).
!
!  6  Three different element-format options are available:
!
!     Option JFORM=1, suitable for the major planets:
!
!     EPOCH  = epoch of elements (TT MJD)
!     ORBINC = inclination i (radians)
!     ANODE  = longitude of the ascending node, big omega (radians)
!     PERIH  = longitude of perihelion, curly pi (radians)
!     AORQ   = mean distance, a (AU)
!     E      = eccentricity, e (range 0 to <1)
!     AORL   = mean longitude L (radians)
!     DM     = daily motion (radians)
!
!     Option JFORM=2, suitable for minor planets:
!
!     EPOCH  = epoch of elements (TT MJD)
!     ORBINC = inclination i (radians)
!     ANODE  = longitude of the ascending node, big omega (radians)
!     PERIH  = argument of perihelion, little omega (radians)
!     AORQ   = mean distance, a (AU)
!     E      = eccentricity, e (range 0 to <1)
!     AORL   = mean anomaly M (radians)
!
!     Option JFORM=3, suitable for comets:
!
!     EPOCH  = epoch of perihelion (TT MJD)
!     ORBINC = inclination i (radians)
!     ANODE  = longitude of the ascending node, big omega (radians)
!     PERIH  = argument of perihelion, little omega (radians)
!     AORQ   = perihelion distance, q (AU)
!     E      = eccentricity, e (range 0 to 10)
!
!  7  Unused elements (DM for JFORM=2, AORL and DM for JFORM=3) are
!     not accessed.
!
!  8  The algorithm was originally adapted from the EPHSLA program of
!     D.H.P.Jones (private communication, 1996).  The method is based
!     on Stumpff's Universal Variables.
!
!  Reference:  Everhart & Pitkin, Am.J.Phys. 51, 712 (1983).
!
!  P.T.Wallace   Starlink   31 December 2002
!
!  Copyright (C) 2002 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE
      INTEGER JFORM
      DOUBLE PRECISION EPOCH,ORBINC,ANODE,PERIH,AORQ,E,AORL,DM,U(13)
      INTEGER JSTAT

!  Gaussian gravitational constant (exact)
      DOUBLE PRECISION GCON
      PARAMETER (GCON=0.01720209895D0)

!  Sin and cos of J2000 mean obliquity (IAU 1976)
      DOUBLE PRECISION SE,CE
      PARAMETER (SE=0.3977771559319137D0, &
                CE=0.9174820620691818D0)

      INTEGER J

      DOUBLE PRECISION PHT,ARGPH,Q,W,CM,ALPHA,PHS,SW,CW,SI,CI,SO,CO, &
                      X,Y,Z,PX,PY,PZ,VX,VY,VZ,DT,FC,FP,PSI, &
                      UL(13),PV(6)



!  Validate arguments.
      IF (JFORM.LT.1.OR.JFORM.GT.3) THEN
         JSTAT = -1
         GO TO 9999
      END IF
      IF (E.LT.0D0.OR.E.GT.10D0.OR.(E.GE.1D0.AND.JFORM.NE.3)) THEN
         JSTAT = -2
         GO TO 9999
      END IF
      IF (AORQ.LE.0D0) THEN
         JSTAT = -3
         GO TO 9999
      END IF
      IF (JFORM.EQ.1.AND.DM.LE.0D0) THEN
         JSTAT = -4
         GO TO 9999
      END IF

!
!  Transform elements into standard form:
!
!  PHT   = epoch of perihelion passage
!  ARGPH = argument of perihelion (little omega)
!  Q     = perihelion distance (q)
!  CM    = combined mass, M+m (mu)

      IF (JFORM.EQ.1) THEN
         PHT = EPOCH-(AORL-PERIH)/DM
         ARGPH = PERIH-ANODE
         Q = AORQ*(1D0-E)
         W = DM/GCON
         CM = W*W*AORQ*AORQ*AORQ
      ELSE IF (JFORM.EQ.2) THEN
         PHT = EPOCH-AORL*SQRT(AORQ*AORQ*AORQ)/GCON
         ARGPH = PERIH
         Q = AORQ*(1D0-E)
         CM = 1D0
      ELSE IF (JFORM.EQ.3) THEN
         PHT = EPOCH
         ARGPH = PERIH
         Q = AORQ
         CM = 1D0
      END IF

!  The universal variable alpha.  This is proportional to the total
!  energy of the orbit:  -ve for an ellipse, zero for a parabola,
!  +ve for a hyperbola.

      ALPHA = CM*(E-1D0)/Q

!  Speed at perihelion.

      PHS = SQRT(ALPHA+2D0*CM/Q)

!  In a Cartesian coordinate system which has the x-axis pointing
!  to perihelion and the z-axis normal to the orbit (such that the
!  object orbits counter-clockwise as seen from +ve z), the
!  perihelion position and velocity vectors are:
!
!    position   [Q,0,0]
!    velocity   [0,PHS,0]
!
!  To express the results in J2000 equatorial coordinates we make a
!  series of four rotations of the Cartesian axes:
!
!           axis      Euler angle
!
!     1      z        argument of perihelion (little omega)
!     2      x        inclination (i)
!     3      z        longitude of the ascending node (big omega)
!     4      x        J2000 obliquity (epsilon)
!
!  In each case the rotation is clockwise as seen from the +ve end of
!  the axis concerned.

!  Functions of the Euler angles.
      SW = SIN(ARGPH)
      CW = COS(ARGPH)
      SI = SIN(ORBINC)
      CI = COS(ORBINC)
      SO = SIN(ANODE)
      CO = COS(ANODE)

!  Position at perihelion (AU).
      X = Q*CW
      Y = Q*SW
      Z = Y*SI
      Y = Y*CI
      PX = X*CO-Y*SO
      Y = X*SO+Y*CO
      PY = Y*CE-Z*SE
      PZ = Y*SE+Z*CE

!  Velocity at perihelion (AU per canonical day).
      X = -PHS*SW
      Y = PHS*CW
      Z = Y*SI
      Y = Y*CI
      VX = X*CO-Y*SO
      Y = X*SO+Y*CO
      VY = Y*CE-Z*SE
      VZ = Y*SE+Z*CE

!  Time from perihelion to date (in Canonical Days: a canonical day
!  is 58.1324409... days, defined as 1/GCON).

      DT = (DATE-PHT)*GCON

!  First Approximation to the Universal Eccentric Anomaly, PSI,
!  based on the circle (FC) and parabola (FP) values.

      FC = DT/Q
      W = (3D0*DT+SQRT(9D0*DT*DT+8D0*Q*Q*Q))**(1D0/3D0)
      FP = W-2D0*Q/W
      PSI = (1D0-E)*FC+E*FP

!  Assemble local copy of element set.
      UL(1) = CM
      UL(2) = ALPHA
      UL(3) = PHT
      UL(4) = PX
      UL(5) = PY
      UL(6) = PZ
      UL(7) = VX
      UL(8) = VY
      UL(9) = VZ
      UL(10) = Q
      UL(11) = 0D0
      UL(12) = DATE
      UL(13) = PSI

!  Predict position+velocity at epoch of osculation.
      CALL sla_UE2PV(DATE,UL,PV,J)
      IF (J.NE.0) GO TO 9010

!  Convert back to universal elements.
      CALL sla_PV2UE(PV,DATE,CM-1D0,U,J)
      IF (J.NE.0) GO TO 9010

!  OK exit.
      JSTAT = 0
      GO TO 9999

!  Quasi-impossible numerical errors.
 9010 CONTINUE
      JSTAT = -5

 9999 CONTINUE
      END
      DOUBLE PRECISION FUNCTION sla_EPB (DATE)
!+
!     - - - -
!      E P B
!     - - - -
!
!  Conversion of Modified Julian Date to Besselian Epoch
!  (double precision)
!
!  Given:
!     DATE     dp       Modified Julian Date (JD - 2400000.5)
!
!  The result is the Besselian Epoch.
!
!  Reference:
!     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
!
!  P.T.Wallace   Starlink   February 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE


      sla_EPB = 1900D0 + (DATE-15019.81352D0)/365.242198781D0

      END
      DOUBLE PRECISION FUNCTION sla_EPB2D (EPB)
!+
!     - - - - - -
!      E P B 2 D
!     - - - - - -
!
!  Conversion of Besselian Epoch to Modified Julian Date
!  (double precision)
!
!  Given:
!     EPB      dp       Besselian Epoch
!
!  The result is the Modified Julian Date (JD - 2400000.5).
!
!  Reference:
!     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
!
!  P.T.Wallace   Starlink   February 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION EPB


      sla_EPB2D = 15019.81352D0 + (EPB-1900D0)*365.242198781D0

      END
      DOUBLE PRECISION FUNCTION sla_EPCO (K0, K, E)
!+
!     - - - - -
!      E P C O
!     - - - - -
!
!  Convert an epoch into the appropriate form - 'B' or 'J'
!
!  Given:
!     K0    char    form of result:  'B'=Besselian, 'J'=Julian
!     K     char    form of given epoch:  'B' or 'J'
!     E     dp      epoch
!
!  Called:  sla_EPB, sla_EPJ2D, sla_EPJ, sla_EPB2D
!
!  Notes:
!
!     1) The result is always either equal to or very close to
!        the given epoch E.  The routine is required only in
!        applications where punctilious treatment of heterogeneous
!        mixtures of star positions is necessary.
!
!     2) K0 and K are not validated.  They are interpreted as follows:
!
!        o  If K0 and K are the same the result is E.
!        o  If K0 is 'B' or 'b' and K isn't, the conversion is J to B.
!        o  In all other cases, the conversion is B to J.
!
!        Note that K0 and K won't match if their cases differ.
!
!  P.T.Wallace   Starlink   5 September 1993
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) K0,K
      DOUBLE PRECISION E
      DOUBLE PRECISION sla_EPB,sla_EPJ2D,sla_EPJ,sla_EPB2D


      IF (K.EQ.K0) THEN
         sla_EPCO=E
      ELSE IF (K0.EQ.'B'.OR.K0.EQ.'b') THEN
         sla_EPCO=sla_EPB(sla_EPJ2D(E))
      ELSE
         sla_EPCO=sla_EPJ(sla_EPB2D(E))
      END IF

      END
      DOUBLE PRECISION FUNCTION sla_EPJ (DATE)
!+
!     - - - -
!      E P J
!     - - - -
!
!  Conversion of Modified Julian Date to Julian Epoch (double precision)
!
!  Given:
!     DATE     dp       Modified Julian Date (JD - 2400000.5)
!
!  The result is the Julian Epoch.
!
!  Reference:
!     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
!
!  P.T.Wallace   Starlink   February 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE


      sla_EPJ = 2000D0 + (DATE-51544.5D0)/365.25D0

      END
      DOUBLE PRECISION FUNCTION sla_EPJ2D (EPJ)
!+
!     - - - - - -
!      E P J 2 D
!     - - - - - -
!
!  Conversion of Julian Epoch to Modified Julian Date (double precision)
!
!  Given:
!     EPJ      dp       Julian Epoch
!
!  The result is the Modified Julian Date (JD - 2400000.5).
!
!  Reference:
!     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
!
!  P.T.Wallace   Starlink   February 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION EPJ


      sla_EPJ2D = 51544.5D0 + (EPJ-2000D0)*365.25D0

      END
      SUBROUTINE sla_EQECL (DR, DD, DATE, DL, DB)
!+
!     - - - - - -
!      E Q E C L
!     - - - - - -
!
!  Transformation from J2000.0 equatorial coordinates to
!  ecliptic coordinates (double precision)
!
!  Given:
!     DR,DD       dp      J2000.0 mean RA,Dec (radians)
!     DATE        dp      TDB (loosely ET) as Modified Julian Date
!                                              (JD-2400000.5)
!  Returned:
!     DL,DB       dp      ecliptic longitude and latitude
!                         (mean of date, IAU 1980 theory, radians)
!
!  Called:
!     sla_DCS2C, sla_PREC, sla_EPJ, sla_DMXV, sla_ECMAT, sla_DCC2S,
!     sla_DRANRM, sla_DRANGE
!
!  P.T.Wallace   Starlink   March 1986
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DR,DD,DATE,DL,DB

      DOUBLE PRECISION sla_EPJ,sla_DRANRM,sla_DRANGE

      DOUBLE PRECISION RMAT(3,3),V1(3),V2(3)



!  Spherical to Cartesian
      CALL sla_DCS2C(DR,DD,V1)

!  Mean J2000 to mean of date
      CALL sla_PREC(2000D0,sla_EPJ(DATE),RMAT)
      CALL sla_DMXV(RMAT,V1,V2)

!  Equatorial to ecliptic
      CALL sla_ECMAT(DATE,RMAT)
      CALL sla_DMXV(RMAT,V2,V1)

!  Cartesian to spherical
      CALL sla_DCC2S(V1,DL,DB)

!  Express in conventional ranges
      DL=sla_DRANRM(DL)
      DB=sla_DRANGE(DB)

      END
      DOUBLE PRECISION FUNCTION sla_EQEQX (DATE)
!+
!     - - - - - -
!      E Q E Q X
!     - - - - - -
!
!  Equation of the equinoxes  (IAU 1994, double precision)
!
!  Given:
!     DATE    dp      TDB (loosely ET) as Modified Julian Date
!                                          (JD-2400000.5)
!
!  The result is the equation of the equinoxes (double precision)
!  in radians:
!
!     Greenwich apparent ST = GMST + sla_EQEQX
!
!  References:  IAU Resolution C7, Recommendation 3 (1994)
!               Capitaine, N. & Gontier, A.-M., Astron. Astrophys.,
!               275, 645-650 (1993)
!
!  Called:  sla_NUTC
!
!  Patrick Wallace   Starlink   23 August 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE

!  Turns to arc seconds and arc seconds to radians
      DOUBLE PRECISION T2AS,AS2R
      PARAMETER (T2AS=1296000D0, &
                AS2R=0.484813681109535994D-5)

      DOUBLE PRECISION T,OM,DPSI,DEPS,EPS0



!  Interval between basic epoch J2000.0 and current epoch (JC)
      T=(DATE-51544.5D0)/36525D0

!  Longitude of the mean ascending node of the lunar orbit on the
!   ecliptic, measured from the mean equinox of date
      OM=AS2R*(450160.280D0+(-5D0*T2AS-482890.539D0 &
              +(7.455D0+0.008D0*T)*T)*T)

!  Nutation
      CALL sla_NUTC(DATE,DPSI,DEPS,EPS0)

!  Equation of the equinoxes
      sla_EQEQX=DPSI*COS(EPS0)+AS2R*(0.00264D0*SIN(OM)+ &
                                    0.000063D0*SIN(OM+OM))

      END
      SUBROUTINE sla_EQGAL (DR, DD, DL, DB)
!+
!     - - - - - -
!      E Q G A L
!     - - - - - -
!
!  Transformation from J2000.0 equatorial coordinates to
!  IAU 1958 galactic coordinates (double precision)
!
!  Given:
!     DR,DD       dp       J2000.0 RA,Dec
!
!  Returned:
!     DL,DB       dp       galactic longitude and latitude L2,B2
!
!  (all arguments are radians)
!
!  Called:
!     sla_DCS2C, sla_DMXV, sla_DCC2S, sla_DRANRM, sla_DRANGE
!
!  Note:
!     The equatorial coordinates are J2000.0.  Use the routine
!     sla_EG50 if conversion from B1950.0 'FK4' coordinates is
!     required.
!
!  Reference:
!     Blaauw et al, Mon.Not.R.Astron.Soc.,121,123 (1960)
!
!  P.T.Wallace   Starlink   21 September 1998
!
!  Copyright (C) 1998 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DR,DD,DL,DB

      DOUBLE PRECISION sla_DRANRM,sla_DRANGE

      DOUBLE PRECISION V1(3),V2(3)

!
!  L2,B2 system of galactic coordinates
!
!  P = 192.25       RA of galactic north pole (mean B1950.0)
!  Q =  62.6        inclination of galactic to mean B1950.0 equator
!  R =  33          longitude of ascending node
!
!  P,Q,R are degrees
!
!  Equatorial to galactic rotation matrix (J2000.0), obtained by
!  applying the standard FK4 to FK5 transformation, for zero proper
!  motion in FK5, to the columns of the B1950 equatorial to
!  galactic rotation matrix:
!
      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3), &
          RMAT(2,1),RMAT(2,2),RMAT(2,3), &
          RMAT(3,1),RMAT(3,2),RMAT(3,3)/ &
      -0.054875539726D0,-0.873437108010D0,-0.483834985808D0, &
      +0.494109453312D0,-0.444829589425D0,+0.746982251810D0, &
      -0.867666135858D0,-0.198076386122D0,+0.455983795705D0/



!  Spherical to Cartesian
      CALL sla_DCS2C(DR,DD,V1)

!  Equatorial to galactic
      CALL sla_DMXV(RMAT,V1,V2)

!  Cartesian to spherical
      CALL sla_DCC2S(V2,DL,DB)

!  Express in conventional ranges
      DL=sla_DRANRM(DL)
      DB=sla_DRANGE(DB)

      END
      SUBROUTINE sla_ETRMS (EP, EV)
!+
!     - - - - - -
!      E T R M S
!     - - - - - -
!
!  Compute the E-terms (elliptic component of annual aberration)
!  vector (double precision)
!
!  Given:
!     EP      dp      Besselian epoch
!
!  Returned:
!     EV      dp(3)   E-terms as (dx,dy,dz)
!
!  Note the use of the J2000 aberration constant (20.49552 arcsec).
!  This is a reflection of the fact that the E-terms embodied in
!  existing star catalogues were computed from a variety of
!  aberration constants.  Rather than adopting one of the old
!  constants the latest value is used here.
!
!  References:
!     1  Smith, C.A. et al., 1989.  Astr.J. 97, 265.
!     2  Yallop, B.D. et al., 1989.  Astr.J. 97, 274.
!
!  P.T.Wallace   Starlink   23 August 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION EP,EV(3)

!  Arcseconds to radians
      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

      DOUBLE PRECISION T,E,E0,P,EK,CP



!  Julian centuries since B1950
      T=(EP-1950D0)*1.00002135903D-2

!  Eccentricity
      E=0.01673011D0-(0.00004193D0+0.000000126D0*T)*T

!  Mean obliquity
      E0=(84404.836D0-(46.8495D0+(0.00319D0+0.00181D0*T)*T)*T)*AS2R

!  Mean longitude of perihelion
      P=(1015489.951D0+(6190.67D0+(1.65D0+0.012D0*T)*T)*T)*AS2R

!  E-terms
      EK=E*20.49552D0*AS2R
      CP=COS(P)
      EV(1)= EK*SIN(P)
      EV(2)=-EK*CP*COS(E0)
      EV(3)=-EK*CP*SIN(E0)

      END
      SUBROUTINE sla_EULER (ORDER, PHI, THETA, PSI, RMAT)
!+
!     - - - - - -
!      E U L E R
!     - - - - - -
!
!  Form a rotation matrix from the Euler angles - three successive
!  rotations about specified Cartesian axes (single precision)
!
!  Given:
!    ORDER  c*(*)    specifies about which axes the rotations occur
!    PHI    r        1st rotation (radians)
!    THETA  r        2nd rotation (   "   )
!    PSI    r        3rd rotation (   "   )
!
!  Returned:
!    RMAT   r(3,3)   rotation matrix
!
!  A rotation is positive when the reference frame rotates
!  anticlockwise as seen looking towards the origin from the
!  positive region of the specified axis.
!
!  The characters of ORDER define which axes the three successive
!  rotations are about.  A typical value is 'ZXZ', indicating that
!  RMAT is to become the direction cosine matrix corresponding to
!  rotations of the reference frame through PHI radians about the
!  old Z-axis, followed by THETA radians about the resulting X-axis,
!  then PSI radians about the resulting Z-axis.
!
!  The axis names can be any of the following, in any order or
!  combination:  X, Y, Z, uppercase or lowercase, 1, 2, 3.  Normal
!  axis labelling/numbering conventions apply;  the xyz (=123)
!  triad is right-handed.  Thus, the 'ZXZ' example given above
!  could be written 'zxz' or '313' (or even 'ZxZ' or '3xZ').  ORDER
!  is terminated by length or by the first unrecognized character.
!
!  Fewer than three rotations are acceptable, in which case the later
!  angle arguments are ignored.  If all rotations are zero, the
!  identity matrix is produced.
!
!  Called:  sla_DEULER
!
!  P.T.Wallace   Starlink   23 May 1997
!
!  Copyright (C) 1997 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) ORDER
      REAL PHI,THETA,PSI,RMAT(3,3)

      INTEGER J,I
      DOUBLE PRECISION W(3,3)



!  Compute matrix in double precision
      CALL sla_DEULER(ORDER,DBLE(PHI),DBLE(THETA),DBLE(PSI),W)

!  Copy the result
      DO J=1,3
         DO I=1,3
            RMAT(I,J) = REAL(W(I,J))
         END DO
      END DO

      END
      SUBROUTINE sla_EVP (DATE, DEQX, DVB, DPB, DVH, DPH)
!+
!     - - - -
!      E V P
!     - - - -
!
!  Barycentric and heliocentric velocity and position of the Earth
!
!  All arguments are double precision
!
!  Given:
!
!     DATE          TDB (loosely ET) as a Modified Julian Date
!                                         (JD-2400000.5)
!
!     DEQX          Julian Epoch (e.g. 2000.0D0) of mean equator and
!                   equinox of the vectors returned.  If DEQX .LE. 0D0,
!                   all vectors are referred to the mean equator and
!                   equinox (FK5) of epoch DATE.
!
!  Returned (all 3D Cartesian vectors):
!
!     DVB,DPB       barycentric velocity, position
!
!     DVH,DPH       heliocentric velocity, position
!
!  (Units are AU/s for velocity and AU for position)
!
!  Called:  sla_EPJ, sla_PREC
!
!  Accuracy:
!
!     The maximum deviations from the JPL DE96 ephemeris are as
!     follows:
!
!     barycentric velocity         0.42  m/s
!     barycentric position         6900  km
!
!     heliocentric velocity        0.42  m/s
!     heliocentric position        1600  km
!
!  This routine is adapted from the BARVEL and BARCOR
!  subroutines of P.Stumpff, which are described in
!  Astron. Astrophys. Suppl. Ser. 41, 1-8 (1980).  Most of the
!  changes are merely cosmetic and do not affect the results at
!  all.  However, some adjustments have been made so as to give
!  results that refer to the new (IAU 1976 'FK5') equinox
!  and precession, although the differences these changes make
!  relative to the results from Stumpff's original 'FK4' version
!  are smaller than the inherent accuracy of the algorithm.  One
!  minor shortcoming in the original routines that has NOT been
!  corrected is that better numerical accuracy could be achieved
!  if the various polynomial evaluations were nested.  Note also
!  that one of Stumpff's precession constants differs by 0.001 arcsec
!  from the value given in the Explanatory Supplement to the A.E.
!
!  P.T.Wallace   Starlink   21 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,DEQX,DVB(3),DPB(3),DVH(3),DPH(3)

      INTEGER IDEQ,I,J,K

      REAL CC2PI,CCSEC3,CCSGD,CCKM,CCMLD,CCFDI,CCIM,T,TSQ,A,PERTL, &
          PERTLD,PERTR,PERTRD,COSA,SINA,ESQ,E,PARAM,TWOE,TWOG,G, &
          PHI,F,SINF,COSF,PHID,PSID,PERTP,PERTPD,TL,SINLM,COSLM, &
          SIGMA,B,PLON,POMG,PECC,FLATM,FLAT

      DOUBLE PRECISION DC2PI,DS2R,DCSLD,DC1MME,DT,DTSQ,DLOCAL,DML, &
                      DEPS,DPARAM,DPSI,D1PDRO,DRD,DRLD,DTL,DSINLS, &
                      DCOSLS,DXHD,DYHD,DZHD,DXBD,DYBD,DZBD,DCOSEP, &
                      DSINEP,DYAHD,DZAHD,DYABD,DZABD,DR, &
                      DXH,DYH,DZH,DXB,DYB,DZB,DYAH,DZAH,DYAB, &
                      DZAB,DEPJ,DEQCOR,B1950

      REAL SN(4),CCSEL(3,17),CCAMPS(5,15),CCSEC(3,4),CCAMPM(4,3), &
          CCPAMV(4),CCPAM(4),FORBEL(7),SORBEL(17),SINLP(4),COSLP(4)
      EQUIVALENCE (SORBEL(1),E),(FORBEL(1),G)

      DOUBLE PRECISION DCFEL(3,8),DCEPS(3),DCARGS(2,15),DCARGM(2,3), &
                      DPREMA(3,3),W,VW(3)

      DOUBLE PRECISION sla_EPJ

      PARAMETER (DC2PI=6.2831853071796D0,CC2PI=6.283185)
      PARAMETER (DS2R=0.7272205216643D-4)
      PARAMETER (B1950=1949.9997904423D0)

!
!   Constants DCFEL(I,K) of fast changing elements
!                     I=1                I=2              I=3
      DATA DCFEL/ 1.7400353D+00, 6.2833195099091D+02, 5.2796D-06, &
                 6.2565836D+00, 6.2830194572674D+02,-2.6180D-06, &
                 4.7199666D+00, 8.3997091449254D+03,-1.9780D-05, &
                 1.9636505D-01, 8.4334662911720D+03,-5.6044D-05, &
                 4.1547339D+00, 5.2993466764997D+01, 5.8845D-06, &
                 4.6524223D+00, 2.1354275911213D+01, 5.6797D-06, &
                 4.2620486D+00, 7.5025342197656D+00, 5.5317D-06, &
                 1.4740694D+00, 3.8377331909193D+00, 5.6093D-06/

!
!   Constants DCEPS and CCSEL(I,K) of slowly changing elements
!                      I=1           I=2           I=3
      DATA DCEPS/  4.093198D-01,-2.271110D-04,-2.860401D-08 /
      DATA CCSEL/  1.675104E-02,-4.179579E-05,-1.260516E-07, &
                  2.220221E-01, 2.809917E-02, 1.852532E-05, &
                  1.589963E+00, 3.418075E-02, 1.430200E-05, &
                  2.994089E+00, 2.590824E-02, 4.155840E-06, &
                  8.155457E-01, 2.486352E-02, 6.836840E-06, &
                  1.735614E+00, 1.763719E-02, 6.370440E-06, &
                  1.968564E+00, 1.524020E-02,-2.517152E-06, &
                  1.282417E+00, 8.703393E-03, 2.289292E-05, &
                  2.280820E+00, 1.918010E-02, 4.484520E-06, &
                  4.833473E-02, 1.641773E-04,-4.654200E-07, &
                  5.589232E-02,-3.455092E-04,-7.388560E-07, &
                  4.634443E-02,-2.658234E-05, 7.757000E-08, &
                  8.997041E-03, 6.329728E-06,-1.939256E-09, &
                  2.284178E-02,-9.941590E-05, 6.787400E-08, &
                  4.350267E-02,-6.839749E-05,-2.714956E-07, &
                  1.348204E-02, 1.091504E-05, 6.903760E-07, &
                  3.106570E-02,-1.665665E-04,-1.590188E-07/

!
!   Constants of the arguments of the short-period perturbations
!   by the planets:   DCARGS(I,K)
!                       I=1               I=2
      DATA DCARGS/ 5.0974222D+00,-7.8604195454652D+02, &
                  3.9584962D+00,-5.7533848094674D+02, &
                  1.6338070D+00,-1.1506769618935D+03, &
                  2.5487111D+00,-3.9302097727326D+02, &
                  4.9255514D+00,-5.8849265665348D+02, &
                  1.3363463D+00,-5.5076098609303D+02, &
                  1.6072053D+00,-5.2237501616674D+02, &
                  1.3629480D+00,-1.1790629318198D+03, &
                  5.5657014D+00,-1.0977134971135D+03, &
                  5.0708205D+00,-1.5774000881978D+02, &
                  3.9318944D+00, 5.2963464780000D+01, &
                  4.8989497D+00, 3.9809289073258D+01, &
                  1.3097446D+00, 7.7540959633708D+01, &
                  3.5147141D+00, 7.9618578146517D+01, &
                  3.5413158D+00,-5.4868336758022D+02/

!
!   Amplitudes CCAMPS(N,K) of the short-period perturbations
!           N=1          N=2          N=3          N=4          N=5
      DATA CCAMPS/ &
      -2.279594E-5, 1.407414E-5, 8.273188E-6, 1.340565E-5,-2.490817E-7, &
      -3.494537E-5, 2.860401E-7, 1.289448E-7, 1.627237E-5,-1.823138E-7, &
       6.593466E-7, 1.322572E-5, 9.258695E-6,-4.674248E-7,-3.646275E-7, &
       1.140767E-5,-2.049792E-5,-4.747930E-6,-2.638763E-6,-1.245408E-7, &
       9.516893E-6,-2.748894E-6,-1.319381E-6,-4.549908E-6,-1.864821E-7, &
       7.310990E-6,-1.924710E-6,-8.772849E-7,-3.334143E-6,-1.745256E-7, &
      -2.603449E-6, 7.359472E-6, 3.168357E-6, 1.119056E-6,-1.655307E-7, &
      -3.228859E-6, 1.308997E-7, 1.013137E-7, 2.403899E-6,-3.736225E-7, &
       3.442177E-7, 2.671323E-6, 1.832858E-6,-2.394688E-7,-3.478444E-7, &
       8.702406E-6,-8.421214E-6,-1.372341E-6,-1.455234E-6,-4.998479E-8, &
      -1.488378E-6,-1.251789E-5, 5.226868E-7,-2.049301E-7, 0.0E0, &
      -8.043059E-6,-2.991300E-6, 1.473654E-7,-3.154542E-7, 0.0E0, &
       3.699128E-6,-3.316126E-6, 2.901257E-7, 3.407826E-7, 0.0E0, &
       2.550120E-6,-1.241123E-6, 9.901116E-8, 2.210482E-7, 0.0E0, &
      -6.351059E-7, 2.341650E-6, 1.061492E-6, 2.878231E-7, 0.0E0/

!
!   Constants of the secular perturbations in longitude
!   CCSEC3 and CCSEC(N,K)
!                      N=1           N=2           N=3
      DATA CCSEC3/-7.757020E-08/, &
          CCSEC/  1.289600E-06, 5.550147E-01, 2.076942E+00, &
                  3.102810E-05, 4.035027E+00, 3.525565E-01, &
                  9.124190E-06, 9.990265E-01, 2.622706E+00, &
                  9.793240E-07, 5.508259E+00, 1.559103E+01/

!   Sidereal rate DCSLD in longitude, rate CCSGD in mean anomaly
      DATA DCSLD/1.990987D-07/, &
          CCSGD/1.990969E-07/

!   Some constants used in the calculation of the lunar contribution
      DATA CCKM/3.122140E-05/, &
          CCMLD/2.661699E-06/, &
          CCFDI/2.399485E-07/

!
!   Constants DCARGM(I,K) of the arguments of the perturbations
!   of the motion of the Moon
!                       I=1               I=2
      DATA DCARGM/  5.1679830D+00, 8.3286911095275D+03, &
                   5.4913150D+00,-7.2140632838100D+03, &
                   5.9598530D+00, 1.5542754389685D+04/

!
!   Amplitudes CCAMPM(N,K) of the perturbations of the Moon
!            N=1          N=2           N=3           N=4
      DATA CCAMPM/ &
       1.097594E-01, 2.896773E-07, 5.450474E-02, 1.438491E-07, &
      -2.223581E-02, 5.083103E-08, 1.002548E-02,-2.291823E-08, &
       1.148966E-02, 5.658888E-08, 8.249439E-03, 4.063015E-08/

!
!   CCPAMV(K)=A*M*DL/DT (planets), DC1MME=1-MASS(Earth+Moon)
      DATA CCPAMV/8.326827E-11,1.843484E-11,1.988712E-12,1.881276E-12/
      DATA DC1MME/0.99999696D0/

!   CCPAM(K)=A*M(planets), CCIM=INCLINATION(Moon)
      DATA CCPAM/4.960906E-3,2.727436E-3,8.392311E-4,1.556861E-3/
      DATA CCIM/8.978749E-2/




!
!   EXECUTION
!   ---------

!   Control parameter IDEQ, and time arguments
      IDEQ = 0
      IF (DEQX.GT.0D0) IDEQ=1
      DT = (DATE-15019.5D0)/36525D0
      T = REAL(DT)
      DTSQ = DT*DT
      TSQ = REAL(DTSQ)

!   Values of all elements for the instant DATE
      DO K=1,8
         DLOCAL = MOD(DCFEL(1,K)+DT*DCFEL(2,K)+DTSQ*DCFEL(3,K), DC2PI)
         IF (K.EQ.1) THEN
            DML = DLOCAL
         ELSE
            FORBEL(K-1) = REAL(DLOCAL)
         END IF
      END DO
      DEPS = MOD(DCEPS(1)+DT*DCEPS(2)+DTSQ*DCEPS(3), DC2PI)
      DO K=1,17
         SORBEL(K) = MOD(CCSEL(1,K)+T*CCSEL(2,K)+TSQ*CCSEL(3,K), &
                        CC2PI)
      END DO

!   Secular perturbations in longitude
      DO K=1,4
         A = MOD(CCSEC(2,K)+T*CCSEC(3,K), CC2PI)
         SN(K) = SIN(A)
      END DO

!   Periodic perturbations of the EMB (Earth-Moon barycentre)
      PERTL =  CCSEC(1,1)          *SN(1) +CCSEC(1,2)*SN(2)+ &
             (CCSEC(1,3)+T*CCSEC3)*SN(3) +CCSEC(1,4)*SN(4)
      PERTLD = 0.0
      PERTR = 0.0
      PERTRD = 0.0
      DO K=1,15
         A = SNGL(MOD(DCARGS(1,K)+DT*DCARGS(2,K), DC2PI))
         COSA = COS(A)
         SINA = SIN(A)
         PERTL = PERTL + CCAMPS(1,K)*COSA+CCAMPS(2,K)*SINA
         PERTR = PERTR + CCAMPS(3,K)*COSA+CCAMPS(4,K)*SINA
         IF (K.LT.11) THEN
            PERTLD = PERTLD+ &
                    (CCAMPS(2,K)*COSA-CCAMPS(1,K)*SINA)*CCAMPS(5,K)
            PERTRD = PERTRD+ &
                    (CCAMPS(4,K)*COSA-CCAMPS(3,K)*SINA)*CCAMPS(5,K)
         END IF
      END DO

!   Elliptic part of the motion of the EMB
      ESQ = E*E
      DPARAM = 1D0-DBLE(ESQ)
      PARAM = REAL(DPARAM)
      TWOE = E+E
      TWOG = G+G
      PHI = TWOE*((1.0-ESQ*0.125)*SIN(G)+E*0.625*SIN(TWOG) &
               +ESQ*0.54166667*SIN(G+TWOG) )
      F = G+PHI
      SINF = SIN(F)
      COSF = COS(F)
      DPSI = DPARAM/(1D0+DBLE(E*COSF))
      PHID = TWOE*CCSGD*((1.0+ESQ*1.5)*COSF+E*(1.25-SINF*SINF*0.5))
      PSID = CCSGD*E*SINF/SQRT(PARAM)

!   Perturbed heliocentric motion of the EMB
      D1PDRO = 1D0+DBLE(PERTR)
      DRD = D1PDRO*(DBLE(PSID)+DPSI*DBLE(PERTRD))
      DRLD = D1PDRO*DPSI*(DCSLD+DBLE(PHID)+DBLE(PERTLD))
      DTL = MOD(DML+DBLE(PHI)+DBLE(PERTL), DC2PI)
      DSINLS = SIN(DTL)
      DCOSLS = COS(DTL)
      DXHD = DRD*DCOSLS-DRLD*DSINLS
      DYHD = DRD*DSINLS+DRLD*DCOSLS

!   Influence of eccentricity, evection and variation on the
!   geocentric motion of the Moon
      PERTL = 0.0
      PERTLD = 0.0
      PERTP = 0.0
      PERTPD = 0.0
      DO K=1,3
         A = SNGL(MOD(DCARGM(1,K)+DT*DCARGM(2,K), DC2PI))
         SINA = SIN(A)
         COSA = COS(A)
         PERTL = PERTL +CCAMPM(1,K)*SINA
         PERTLD = PERTLD+CCAMPM(2,K)*COSA
         PERTP = PERTP +CCAMPM(3,K)*COSA
         PERTPD = PERTPD-CCAMPM(4,K)*SINA
      END DO

!   Heliocentric motion of the Earth
      TL = FORBEL(2)+PERTL
      SINLM = SIN(TL)
      COSLM = COS(TL)
      SIGMA = CCKM/(1.0+PERTP)
      A = SIGMA*(CCMLD+PERTLD)
      B = SIGMA*PERTPD
      DXHD = DXHD+DBLE(A*SINLM)+DBLE(B*COSLM)
      DYHD = DYHD-DBLE(A*COSLM)+DBLE(B*SINLM)
      DZHD =     -DBLE(SIGMA*CCFDI*COS(FORBEL(3)))

!   Barycentric motion of the Earth
      DXBD = DXHD*DC1MME
      DYBD = DYHD*DC1MME
      DZBD = DZHD*DC1MME
      DO K=1,4
         PLON = FORBEL(K+3)
         POMG = SORBEL(K+1)
         PECC = SORBEL(K+9)
         TL = MOD(PLON+2.0*PECC*SIN(PLON-POMG), CC2PI)
         SINLP(K) = SIN(TL)
         COSLP(K) = COS(TL)
         DXBD = DXBD+DBLE(CCPAMV(K)*(SINLP(K)+PECC*SIN(POMG)))
         DYBD = DYBD-DBLE(CCPAMV(K)*(COSLP(K)+PECC*COS(POMG)))
         DZBD = DZBD-DBLE(CCPAMV(K)*SORBEL(K+13)*COS(PLON-SORBEL(K+5)))
      END DO

!   Transition to mean equator of date
      DCOSEP = COS(DEPS)
      DSINEP = SIN(DEPS)
      DYAHD = DCOSEP*DYHD-DSINEP*DZHD
      DZAHD = DSINEP*DYHD+DCOSEP*DZHD
      DYABD = DCOSEP*DYBD-DSINEP*DZBD
      DZABD = DSINEP*DYBD+DCOSEP*DZBD

!   Heliocentric coordinates of the Earth
      DR = DPSI*D1PDRO
      FLATM = CCIM*SIN(FORBEL(3))
      A = SIGMA*COS(FLATM)
      DXH = DR*DCOSLS-DBLE(A*COSLM)
      DYH = DR*DSINLS-DBLE(A*SINLM)
      DZH =          -DBLE(SIGMA*SIN(FLATM))

!   Barycentric coordinates of the Earth
      DXB = DXH*DC1MME
      DYB = DYH*DC1MME
      DZB = DZH*DC1MME
      DO K=1,4
         FLAT = SORBEL(K+13)*SIN(FORBEL(K+3)-SORBEL(K+5))
         A = CCPAM(K)*(1.0-SORBEL(K+9)*COS(FORBEL(K+3)-SORBEL(K+1)))
         B = A*COS(FLAT)
         DXB = DXB-DBLE(B*COSLP(K))
         DYB = DYB-DBLE(B*SINLP(K))
         DZB = DZB-DBLE(A*SIN(FLAT))
      END DO

!   Transition to mean equator of date
      DYAH = DCOSEP*DYH-DSINEP*DZH
      DZAH = DSINEP*DYH+DCOSEP*DZH
      DYAB = DCOSEP*DYB-DSINEP*DZB
      DZAB = DSINEP*DYB+DCOSEP*DZB

!   Copy result components into vectors, correcting for FK4 equinox
      DEPJ=sla_EPJ(DATE)
      DEQCOR = DS2R*(0.035D0+0.00085D0*(DEPJ-B1950))
      DVH(1) = DXHD-DEQCOR*DYAHD
      DVH(2) = DYAHD+DEQCOR*DXHD
      DVH(3) = DZAHD
      DVB(1) = DXBD-DEQCOR*DYABD
      DVB(2) = DYABD+DEQCOR*DXBD
      DVB(3) = DZABD
      DPH(1) = DXH-DEQCOR*DYAH
      DPH(2) = DYAH+DEQCOR*DXH
      DPH(3) = DZAH
      DPB(1) = DXB-DEQCOR*DYAB
      DPB(2) = DYAB+DEQCOR*DXB
      DPB(3) = DZAB

!   Was precession to another equinox requested?
      IF (IDEQ.NE.0) THEN

!     Yes: compute precession matrix from MJD DATE to Julian epoch DEQX
         CALL sla_PREC(DEPJ,DEQX,DPREMA)

!     Rotate DVH
         DO J=1,3
            W=0D0
            DO I=1,3
               W=W+DPREMA(J,I)*DVH(I)
            END DO
            VW(J)=W
         END DO
         DO J=1,3
            DVH(J)=VW(J)
         END DO

!     Rotate DVB
         DO J=1,3
            W=0D0
            DO I=1,3
               W=W+DPREMA(J,I)*DVB(I)
            END DO
            VW(J)=W
         END DO
         DO J=1,3
            DVB(J)=VW(J)
         END DO

!     Rotate DPH
         DO J=1,3
            W=0D0
            DO I=1,3
               W=W+DPREMA(J,I)*DPH(I)
            END DO
            VW(J)=W
         END DO
         DO J=1,3
            DPH(J)=VW(J)
         END DO

!     Rotate DPB
         DO J=1,3
            W=0D0
            DO I=1,3
               W=W+DPREMA(J,I)*DPB(I)
            END DO
            VW(J)=W
         END DO
         DO J=1,3
            DPB(J)=VW(J)
         END DO
      END IF

      END
      SUBROUTINE sla_FITXY (ITYPE,NP,XYE,XYM,COEFFS,J)
!+
!     - - - - - -
!      F I T X Y
!     - - - - - -
!
!  Fit a linear model to relate two sets of [X,Y] coordinates.
!
!  Given:
!     ITYPE    i        type of model: 4 or 6 (note 1)
!     NP       i        number of samples (note 2)
!     XYE     d(2,np)   expected [X,Y] for each sample
!     XYM     d(2,np)   measured [X,Y] for each sample
!
!  Returned:
!     COEFFS  d(6)      coefficients of model (note 3)
!     J        i        status:  0 = OK
!                               -1 = illegal ITYPE
!                               -2 = insufficient data
!                               -3 = no solution
!
!  Notes:
!
!  1)  ITYPE, which must be either 4 or 6, selects the type of model
!      fitted.  Both allowed ITYPE values produce a model COEFFS which
!      consists of six coefficients, namely the zero points and, for
!      each of XE and YE, the coefficient of XM and YM.  For ITYPE=6,
!      all six coefficients are independent, modelling squash and shear
!      as well as origin, scale, and orientation.  However, ITYPE=4
!      selects the "solid body rotation" option;  the model COEFFS
!      still consists of the same six coefficients, but now two of
!      them are used twice (appropriately signed).  Origin, scale
!      and orientation are still modelled, but not squash or shear -
!      the units of X and Y have to be the same.
!
!  2)  For NC=4, NP must be at least 2.  For NC=6, NP must be at
!      least 3.
!
!  3)  The model is returned in the array COEFFS.  Naming the
!      elements of COEFFS as follows:
!
!                  COEFFS(1) = A
!                  COEFFS(2) = B
!                  COEFFS(3) = C
!                  COEFFS(4) = D
!                  COEFFS(5) = E
!                  COEFFS(6) = F
!
!      the model is:
!
!            XE = A + B*XM + C*YM
!            YE = D + E*XM + F*YM
!
!      For the "solid body rotation" option (ITYPE=4), the
!      magnitudes of B and F, and of C and E, are equal.  The
!      signs of these coefficients depend on whether there is a
!      sign reversal between XE,YE and XM,YM;  fits are performed
!      with and without a sign reversal and the best one chosen.
!
!  4)  Error status values J=-1 and -2 leave COEFFS unchanged;
!      if J=-3 COEFFS may have been changed.
!
!  See also sla_PXY, sla_INVF, sla_XY2XY, sla_DCMPF
!
!  Called:  sla_DMAT, sla_DMXV
!
!  P.T.Wallace   Starlink   30 November 2001
!
!  Copyright (C) 2001 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER ITYPE,NP
      DOUBLE PRECISION XYE(2,NP),XYM(2,NP),COEFFS(6)
      INTEGER J

      INTEGER I,JSTAT,IW(4),NSOL
      DOUBLE PRECISION P,SXE,SXEXM,SXEYM,SYE,SYEYM,SYEXM,SXM, &
                      SYM,SXMXM,SXMYM,SYMYM,XE,YE, &
                      XM,YM,V(4),DM3(3,3),DM4(4,4),DET, &
                      SGN,SXXYY,SXYYX,SX2Y2,A,B,C,D, &
                      SDR2,XR,YR,AOLD,BOLD,COLD,DOLD,SOLD



!  Preset the status
      J=0

!  Float the number of samples
      P=DBLE(NP)

!  Check ITYPE
      IF (ITYPE.EQ.6) THEN

!
!     Six-coefficient linear model
!     ----------------------------

!     Check enough samples
         IF (NP.GE.3) THEN

!     Form summations
         SXE=0D0
         SXEXM=0D0
         SXEYM=0D0
         SYE=0D0
         SYEYM=0D0
         SYEXM=0D0
         SXM=0D0
         SYM=0D0
         SXMXM=0D0
         SXMYM=0D0
         SYMYM=0D0
         DO I=1,NP
            XE=XYE(1,I)
            YE=XYE(2,I)
            XM=XYM(1,I)
            YM=XYM(2,I)
            SXE=SXE+XE
            SXEXM=SXEXM+XE*XM
            SXEYM=SXEYM+XE*YM
            SYE=SYE+YE
            SYEYM=SYEYM+YE*YM
            SYEXM=SYEXM+YE*XM
            SXM=SXM+XM
            SYM=SYM+YM
            SXMXM=SXMXM+XM*XM
            SXMYM=SXMYM+XM*YM
            SYMYM=SYMYM+YM*YM
         END DO

!        Solve for A,B,C in  XE = A + B*XM + C*YM
            V(1)=SXE
            V(2)=SXEXM
            V(3)=SXEYM
            DM3(1,1)=P
            DM3(1,2)=SXM
            DM3(1,3)=SYM
            DM3(2,1)=SXM
            DM3(2,2)=SXMXM
            DM3(2,3)=SXMYM
            DM3(3,1)=SYM
            DM3(3,2)=SXMYM
            DM3(3,3)=SYMYM
            CALL sla_DMAT(3,DM3,V,DET,JSTAT,IW)
            IF (JSTAT.EQ.0) THEN
               DO I=1,3
                  COEFFS(I)=V(I)
               END DO

!           Solve for D,E,F in  YE = D + E*XM + F*YM
               V(1)=SYE
               V(2)=SYEXM
               V(3)=SYEYM
               CALL sla_DMXV(DM3,V,COEFFS(4))

            ELSE

!           No 6-coefficient solution possible
               J=-3

            END IF

         ELSE

!        Insufficient data for 6-coefficient fit
            J=-2

         END IF

      ELSE IF (ITYPE.EQ.4) THEN

!
!     Four-coefficient solid body rotation model
!     ------------------------------------------

!     Check enough samples
         IF (NP.GE.2) THEN

!        Try two solutions, first without then with flip in X
            DO NSOL=1,2
               IF (NSOL.EQ.1) THEN
                  SGN=1D0
               ELSE
                  SGN=-1D0
               END IF

!           Form summations
               SXE=0D0
               SXXYY=0D0
               SXYYX=0D0
               SYE=0D0
               SXM=0D0
               SYM=0D0
               SX2Y2=0D0
               DO I=1,NP
                  XE=XYE(1,I)*SGN
                  YE=XYE(2,I)
                  XM=XYM(1,I)
                  YM=XYM(2,I)
                  SXE=SXE+XE
                  SXXYY=SXXYY+XE*XM+YE*YM
                  SXYYX=SXYYX+XE*YM-YE*XM
                  SYE=SYE+YE
                  SXM=SXM+XM
                  SYM=SYM+YM
                  SX2Y2=SX2Y2+XM*XM+YM*YM
               END DO

!
!           Solve for A,B,C,D in:  +/- XE = A + B*XM - C*YM
!                                    + YE = D + C*XM + B*YM
               V(1)=SXE
               V(2)=SXXYY
               V(3)=SXYYX
               V(4)=SYE
               DM4(1,1)=P
               DM4(1,2)=SXM
               DM4(1,3)=-SYM
               DM4(1,4)=0D0
               DM4(2,1)=SXM
               DM4(2,2)=SX2Y2
               DM4(2,3)=0D0
               DM4(2,4)=SYM
               DM4(3,1)=SYM
               DM4(3,2)=0D0
               DM4(3,3)=-SX2Y2
               DM4(3,4)=-SXM
               DM4(4,1)=0D0
               DM4(4,2)=SYM
               DM4(4,3)=SXM
               DM4(4,4)=P
               CALL sla_DMAT(4,DM4,V,DET,JSTAT,IW)
               IF (JSTAT.EQ.0) THEN
                  A=V(1)
                  B=V(2)
                  C=V(3)
                  D=V(4)

!              Determine sum of radial errors squared
                  SDR2=0D0
                  DO I=1,NP
                     XM=XYM(1,I)
                     YM=XYM(2,I)
                     XR=A+B*XM-C*YM-XYE(1,I)*SGN
                     YR=D+C*XM+B*YM-XYE(2,I)
                     SDR2=SDR2+XR*XR+YR*YR
                  END DO

               ELSE

!              Singular: set flag
                  SDR2=-1D0

               END IF

!           If first pass and non-singular, save variables
               IF (NSOL.EQ.1.AND.JSTAT.EQ.0) THEN
                  AOLD=A
                  BOLD=B
                  COLD=C
                  DOLD=D
                  SOLD=SDR2
               END IF

            END DO

!        Pick the best of the two solutions
            IF (SOLD.GE.0D0.AND.(SOLD.LE.SDR2.OR.NP.EQ.2)) THEN
               COEFFS(1)=AOLD
               COEFFS(2)=BOLD
               COEFFS(3)=-COLD
               COEFFS(4)=DOLD
               COEFFS(5)=COLD
               COEFFS(6)=BOLD
            ELSE IF (JSTAT.EQ.0) THEN
               COEFFS(1)=-A
               COEFFS(2)=-B
               COEFFS(3)=C
               COEFFS(4)=D
               COEFFS(5)=C
               COEFFS(6)=B
            ELSE

!           No 4-coefficient fit possible
               J=-3
            END IF
         ELSE

!        Insufficient data for 4-coefficient fit
            J=-2
         END IF
      ELSE

!     Illegal ITYPE - not 4 or 6
         J=-1
      END IF

      END
      SUBROUTINE sla_FK425 (R1950,D1950,DR1950,DD1950,P1950,V1950, &
                           R2000,D2000,DR2000,DD2000,P2000,V2000)
!+
!     - - - - - -
!      F K 4 2 5
!     - - - - - -
!
!  Convert B1950.0 FK4 star data to J2000.0 FK5 (double precision)
!
!  This routine converts stars from the old, Bessel-Newcomb, FK4
!  system to the new, IAU 1976, FK5, Fricke system.  The precepts
!  of Smith et al (Ref 1) are followed, using the implementation
!  by Yallop et al (Ref 2) of a matrix method due to Standish.
!  Kinoshita's development of Andoyer's post-Newcomb precession is
!  used.  The numerical constants from Seidelmann et al (Ref 3) are
!  used canonically.
!
!  Given:  (all B1950.0,FK4)
!     R1950,D1950     dp    B1950.0 RA,Dec (rad)
!     DR1950,DD1950   dp    B1950.0 proper motions (rad/trop.yr)
!     P1950           dp    parallax (arcsec)
!     V1950           dp    radial velocity (km/s, +ve = moving away)
!
!  Returned:  (all J2000.0,FK5)
!     R2000,D2000     dp    J2000.0 RA,Dec (rad)
!     DR2000,DD2000   dp    J2000.0 proper motions (rad/Jul.yr)
!     P2000           dp    parallax (arcsec)
!     V2000           dp    radial velocity (km/s, +ve = moving away)
!
!  Notes:
!
!  1)  The proper motions in RA are dRA/dt rather than
!      cos(Dec)*dRA/dt, and are per year rather than per century.
!
!  2)  Conversion from Besselian epoch 1950.0 to Julian epoch
!      2000.0 only is provided for.  Conversions involving other
!      epochs will require use of the appropriate precession,
!      proper motion, and E-terms routines before and/or
!      after FK425 is called.
!
!  3)  In the FK4 catalogue the proper motions of stars within
!      10 degrees of the poles do not embody the differential
!      E-term effect and should, strictly speaking, be handled
!      in a different manner from stars outside these regions.
!      However, given the general lack of homogeneity of the star
!      data available for routine astrometry, the difficulties of
!      handling positions that may have been determined from
!      astrometric fields spanning the polar and non-polar regions,
!      the likelihood that the differential E-terms effect was not
!      taken into account when allowing for proper motion in past
!      astrometry, and the undesirability of a discontinuity in
!      the algorithm, the decision has been made in this routine to
!      include the effect of differential E-terms on the proper
!      motions for all stars, whether polar or not.  At epoch 2000,
!      and measuring on the sky rather than in terms of dRA, the
!      errors resulting from this simplification are less than
!      1 milliarcsecond in position and 1 milliarcsecond per
!      century in proper motion.
!
!  References:
!
!     1  Smith, C.A. et al, 1989.  "The transformation of astrometric
!        catalog systems to the equinox J2000.0".  Astron.J. 97, 265.
!
!     2  Yallop, B.D. et al, 1989.  "Transformation of mean star places
!        from FK4 B1950.0 to FK5 J2000.0 using matrices in 6-space".
!        Astron.J. 97, 274.
!
!     3  Seidelmann, P.K. (ed), 1992.  "Explanatory Supplement to
!        the Astronomical Almanac", ISBN 0-935702-68-7.
!
!  P.T.Wallace   Starlink   19 December 1993
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION R1950,D1950,DR1950,DD1950,P1950,V1950, &
                      R2000,D2000,DR2000,DD2000,P2000,V2000


!  Miscellaneous
      DOUBLE PRECISION R,D,UR,UD,PX,RV,SR,CR,SD,CD,W,WD
      DOUBLE PRECISION X,Y,Z,XD,YD,ZD
      DOUBLE PRECISION RXYSQ,RXYZSQ,RXY,RXYZ,SPXY,SPXYZ
      INTEGER I,J

!  Star position and velocity vectors
      DOUBLE PRECISION R0(3),RD0(3)

!  Combined position and velocity vectors
      DOUBLE PRECISION V1(6),V2(6)

!  2Pi
      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=6.283185307179586476925287D0)

!  Radians per year to arcsec per century
      DOUBLE PRECISION PMF
      PARAMETER (PMF=100D0*60D0*60D0*360D0/D2PI)

!  Small number to avoid arithmetic problems
      DOUBLE PRECISION TINY
      PARAMETER (TINY=1D-30)


!
!  CANONICAL CONSTANTS  (see references)
!

!  Km per sec to AU per tropical century
!  = 86400 * 36524.2198782 / 149597870
      DOUBLE PRECISION VF
      PARAMETER (VF=21.095D0)

!  Constant vector and matrix (by columns)
      DOUBLE PRECISION A(3),AD(3),EM(6,6)
      DATA A,AD/ -1.62557D-6,  -0.31919D-6, -0.13843D-6, &
                +1.245D-3,    -1.580D-3,   -0.659D-3/

      DATA (EM(I,1),I=1,6) / +0.9999256782D0, &
                            +0.0111820610D0, &
                            +0.0048579479D0, &
                            -0.000551D0, &
                            +0.238514D0, &
                            -0.435623D0 /

      DATA (EM(I,2),I=1,6) / -0.0111820611D0, &
                            +0.9999374784D0, &
                            -0.0000271474D0, &
                            -0.238565D0, &
                            -0.002667D0, &
                            +0.012254D0 /

      DATA (EM(I,3),I=1,6) / -0.0048579477D0, &
                            -0.0000271765D0, &
                            +0.9999881997D0, &
                            +0.435739D0, &
                            -0.008541D0, &
                            +0.002117D0 /

      DATA (EM(I,4),I=1,6) / +0.00000242395018D0, &
                            +0.00000002710663D0, &
                            +0.00000001177656D0, &
                            +0.99994704D0, &
                            +0.01118251D0, &
                            +0.00485767D0 /

      DATA (EM(I,5),I=1,6) / -0.00000002710663D0, &
                            +0.00000242397878D0, &
                            -0.00000000006582D0, &
                            -0.01118251D0, &
                            +0.99995883D0, &
                            -0.00002714D0 /

      DATA (EM(I,6),I=1,6) / -0.00000001177656D0, &
                            -0.00000000006587D0, &
                            +0.00000242410173D0, &
                            -0.00485767D0, &
                            -0.00002718D0, &
                            +1.00000956D0 /



!  Pick up B1950 data (units radians and arcsec/TC)
      R=R1950
      D=D1950
      UR=DR1950*PMF
      UD=DD1950*PMF
      PX=P1950
      RV=V1950

!  Spherical to Cartesian
      SR=SIN(R)
      CR=COS(R)
      SD=SIN(D)
      CD=COS(D)

      R0(1)=CR*CD
      R0(2)=SR*CD
      R0(3)=   SD

      W=VF*RV*PX

      RD0(1)=-SR*CD*UR-CR*SD*UD+W*R0(1)
      RD0(2)= CR*CD*UR-SR*SD*UD+W*R0(2)
      RD0(3)=             CD*UD+W*R0(3)

!  Allow for e-terms and express as position+velocity 6-vector
      W=R0(1)*A(1)+R0(2)*A(2)+R0(3)*A(3)
      WD=R0(1)*AD(1)+R0(2)*AD(2)+R0(3)*AD(3)
      DO I=1,3
         V1(I)=R0(I)-A(I)+W*R0(I)
         V1(I+3)=RD0(I)-AD(I)+WD*R0(I)
      END DO

!  Convert position+velocity vector to Fricke system
      DO I=1,6
         W=0D0
         DO J=1,6
            W=W+EM(I,J)*V1(J)
         END DO
         V2(I)=W
      END DO

!  Revert to spherical coordinates
      X=V2(1)
      Y=V2(2)
      Z=V2(3)
      XD=V2(4)
      YD=V2(5)
      ZD=V2(6)

      RXYSQ=X*X+Y*Y
      RXYZSQ=RXYSQ+Z*Z
      RXY=SQRT(RXYSQ)
      RXYZ=SQRT(RXYZSQ)

      SPXY=X*XD+Y*YD
      SPXYZ=SPXY+Z*ZD

      IF (X.EQ.0D0.AND.Y.EQ.0D0) THEN
         R=0D0
      ELSE
         R=ATAN2(Y,X)
         IF (R.LT.0.0D0) R=R+D2PI
      END IF
      D=ATAN2(Z,RXY)

      IF (RXY.GT.TINY) THEN
         UR=(X*YD-Y*XD)/RXYSQ
         UD=(ZD*RXYSQ-Z*SPXY)/(RXYZSQ*RXY)
      END IF

      IF (PX.GT.TINY) THEN
         RV=SPXYZ/(PX*RXYZ*VF)
         PX=PX/RXYZ
      END IF

!  Return results
      R2000=R
      D2000=D
      DR2000=UR/PMF
      DD2000=UD/PMF
      V2000=RV
      P2000=PX

      END
      SUBROUTINE sla_FK45Z (R1950,D1950,BEPOCH,R2000,D2000)
!+
!     - - - - - -
!      F K 4 5 Z
!     - - - - - -
!
!  Convert B1950.0 FK4 star data to J2000.0 FK5 assuming zero
!  proper motion in the FK5 frame (double precision)
!
!  This routine converts stars from the old, Bessel-Newcomb, FK4
!  system to the new, IAU 1976, FK5, Fricke system, in such a
!  way that the FK5 proper motion is zero.  Because such a star
!  has, in general, a non-zero proper motion in the FK4 system,
!  the routine requires the epoch at which the position in the
!  FK4 system was determined.
!
!  The method is from Appendix 2 of Ref 1, but using the constants
!  of Ref 4.
!
!  Given:
!     R1950,D1950     dp    B1950.0 FK4 RA,Dec at epoch (rad)
!     BEPOCH          dp    Besselian epoch (e.g. 1979.3D0)
!
!  Returned:
!     R2000,D2000     dp    J2000.0 FK5 RA,Dec (rad)
!
!  Notes:
!
!  1)  The epoch BEPOCH is strictly speaking Besselian, but
!      if a Julian epoch is supplied the result will be
!      affected only to a negligible extent.
!
!  2)  Conversion from Besselian epoch 1950.0 to Julian epoch
!      2000.0 only is provided for.  Conversions involving other
!      epochs will require use of the appropriate precession,
!      proper motion, and E-terms routines before and/or
!      after FK45Z is called.
!
!  3)  In the FK4 catalogue the proper motions of stars within
!      10 degrees of the poles do not embody the differential
!      E-term effect and should, strictly speaking, be handled
!      in a different manner from stars outside these regions.
!      However, given the general lack of homogeneity of the star
!      data available for routine astrometry, the difficulties of
!      handling positions that may have been determined from
!      astrometric fields spanning the polar and non-polar regions,
!      the likelihood that the differential E-terms effect was not
!      taken into account when allowing for proper motion in past
!      astrometry, and the undesirability of a discontinuity in
!      the algorithm, the decision has been made in this routine to
!      include the effect of differential E-terms on the proper
!      motions for all stars, whether polar or not.  At epoch 2000,
!      and measuring on the sky rather than in terms of dRA, the
!      errors resulting from this simplification are less than
!      1 milliarcsecond in position and 1 milliarcsecond per
!      century in proper motion.
!
!  References:
!
!     1  Aoki,S., et al, 1983.  Astron.Astrophys., 128, 263.
!
!     2  Smith, C.A. et al, 1989.  "The transformation of astrometric
!        catalog systems to the equinox J2000.0".  Astron.J. 97, 265.
!
!     3  Yallop, B.D. et al, 1989.  "Transformation of mean star places
!        from FK4 B1950.0 to FK5 J2000.0 using matrices in 6-space".
!        Astron.J. 97, 274.
!
!     4  Seidelmann, P.K. (ed), 1992.  "Explanatory Supplement to
!        the Astronomical Almanac", ISBN 0-935702-68-7.
!
!  Called:  sla_DCS2C, sla_EPJ, sla_EPB2D, sla_DCC2S, sla_DRANRM
!
!  P.T.Wallace   Starlink   21 September 1998
!
!  Copyright (C) 1998 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION R1950,D1950,BEPOCH,R2000,D2000

      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=6.283185307179586476925287D0)

      DOUBLE PRECISION W
      INTEGER I,J

!  Position and position+velocity vectors
      DOUBLE PRECISION R0(3),A1(3),V1(3),V2(6)

!  Radians per year to arcsec per century
      DOUBLE PRECISION PMF
      PARAMETER (PMF=100D0*60D0*60D0*360D0/D2PI)

!  Functions
      DOUBLE PRECISION sla_EPJ,sla_EPB2D,sla_DRANRM

!
!  CANONICAL CONSTANTS  (see references)
!

!  Vectors A and Adot, and matrix M (only half of which is needed here)
      DOUBLE PRECISION A(3),AD(3),EM(6,3)
      DATA A,AD/ -1.62557D-6,  -0.31919D-6, -0.13843D-6, &
                +1.245D-3,    -1.580D-3,   -0.659D-3/

      DATA (EM(I,1),I=1,6) / +0.9999256782D0, &
                            +0.0111820610D0, &
                            +0.0048579479D0, &
                            -0.000551D0, &
                            +0.238514D0, &
                            -0.435623D0 /

      DATA (EM(I,2),I=1,6) / -0.0111820611D0, &
                            +0.9999374784D0, &
                            -0.0000271474D0, &
                            -0.238565D0, &
                            -0.002667D0, &
                            +0.012254D0 /

      DATA (EM(I,3),I=1,6) / -0.0048579477D0, &
                            -0.0000271765D0, &
                            +0.9999881997D0, &
                            +0.435739D0, &
                            -0.008541D0, &
                            +0.002117D0 /



!  Spherical to Cartesian
      CALL sla_DCS2C(R1950,D1950,R0)

!  Adjust vector A to give zero proper motion in FK5
      W=(BEPOCH-1950D0)/PMF
      DO I=1,3
         A1(I)=A(I)+W*AD(I)
      END DO

!  Remove e-terms
      W=R0(1)*A1(1)+R0(2)*A1(2)+R0(3)*A1(3)
      DO I=1,3
         V1(I)=R0(I)-A1(I)+W*R0(I)
      END DO

!  Convert position vector to Fricke system
      DO I=1,6
         W=0D0
         DO J=1,3
            W=W+EM(I,J)*V1(J)
         END DO
         V2(I)=W
      END DO

!  Allow for fictitious proper motion in FK4
      W=(sla_EPJ(sla_EPB2D(BEPOCH))-2000D0)/PMF
      DO I=1,3
         V2(I)=V2(I)+W*V2(I+3)
      END DO

!  Revert to spherical coordinates
      CALL sla_DCC2S(V2,W,D2000)
      R2000=sla_DRANRM(W)

      END
      SUBROUTINE sla_FK524 (R2000,D2000,DR2000,DD2000,P2000,V2000, &
                           R1950,D1950,DR1950,DD1950,P1950,V1950)
!+
!     - - - - - -
!      F K 5 2 4
!     - - - - - -
!
!  Convert J2000.0 FK5 star data to B1950.0 FK4 (double precision)
!
!  This routine converts stars from the new, IAU 1976, FK5, Fricke
!  system, to the old, Bessel-Newcomb, FK4 system.  The precepts
!  of Smith et al (Ref 1) are followed, using the implementation
!  by Yallop et al (Ref 2) of a matrix method due to Standish.
!  Kinoshita's development of Andoyer's post-Newcomb precession is
!  used.  The numerical constants from Seidelmann et al (Ref 3) are
!  used canonically.
!
!  Given:  (all J2000.0,FK5)
!     R2000,D2000     dp    J2000.0 RA,Dec (rad)
!     DR2000,DD2000   dp    J2000.0 proper motions (rad/Jul.yr)
!     P2000           dp    parallax (arcsec)
!     V2000           dp    radial velocity (km/s, +ve = moving away)
!
!  Returned:  (all B1950.0,FK4)
!     R1950,D1950     dp    B1950.0 RA,Dec (rad)
!     DR1950,DD1950   dp    B1950.0 proper motions (rad/trop.yr)
!     P1950           dp    parallax (arcsec)
!     V1950           dp    radial velocity (km/s, +ve = moving away)
!
!  Notes:
!
!  1)  The proper motions in RA are dRA/dt rather than
!      cos(Dec)*dRA/dt, and are per year rather than per century.
!
!  2)  Note that conversion from Julian epoch 2000.0 to Besselian
!      epoch 1950.0 only is provided for.  Conversions involving
!      other epochs will require use of the appropriate precession,
!      proper motion, and E-terms routines before and/or after
!      FK524 is called.
!
!  3)  In the FK4 catalogue the proper motions of stars within
!      10 degrees of the poles do not embody the differential
!      E-term effect and should, strictly speaking, be handled
!      in a different manner from stars outside these regions.
!      However, given the general lack of homogeneity of the star
!      data available for routine astrometry, the difficulties of
!      handling positions that may have been determined from
!      astrometric fields spanning the polar and non-polar regions,
!      the likelihood that the differential E-terms effect was not
!      taken into account when allowing for proper motion in past
!      astrometry, and the undesirability of a discontinuity in
!      the algorithm, the decision has been made in this routine to
!      include the effect of differential E-terms on the proper
!      motions for all stars, whether polar or not.  At epoch 2000,
!      and measuring on the sky rather than in terms of dRA, the
!      errors resulting from this simplification are less than
!      1 milliarcsecond in position and 1 milliarcsecond per
!      century in proper motion.
!
!  References:
!
!     1  Smith, C.A. et al, 1989.  "The transformation of astrometric
!        catalog systems to the equinox J2000.0".  Astron.J. 97, 265.
!
!     2  Yallop, B.D. et al, 1989.  "Transformation of mean star places
!        from FK4 B1950.0 to FK5 J2000.0 using matrices in 6-space".
!        Astron.J. 97, 274.
!
!     3  Seidelmann, P.K. (ed), 1992.  "Explanatory Supplement to
!        the Astronomical Almanac", ISBN 0-935702-68-7.
!
!  P.T.Wallace   Starlink   19 December 1993
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION R2000,D2000,DR2000,DD2000,P2000,V2000, &
                      R1950,D1950,DR1950,DD1950,P1950,V1950


!  Miscellaneous
      DOUBLE PRECISION R,D,UR,UD,PX,RV
      DOUBLE PRECISION SR,CR,SD,CD,X,Y,Z,W
      DOUBLE PRECISION V1(6),V2(6)
      DOUBLE PRECISION XD,YD,ZD
      DOUBLE PRECISION RXYZ,WD,RXYSQ,RXY
      INTEGER I,J

!  2Pi
      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=6.283185307179586476925287D0)

!  Radians per year to arcsec per century
      DOUBLE PRECISION PMF
      PARAMETER (PMF=100D0*60D0*60D0*360D0/D2PI)

!  Small number to avoid arithmetic problems
      DOUBLE PRECISION TINY
      PARAMETER (TINY=1D-30)

!
!  CANONICAL CONSTANTS  (see references)
!

!  Km per sec to AU per tropical century
!  = 86400 * 36524.2198782 / 149597870
      DOUBLE PRECISION VF
      PARAMETER (VF=21.095D0)

!  Constant vector and matrix (by columns)
      DOUBLE PRECISION A(6),EMI(6,6)
      DATA A/ -1.62557D-6,  -0.31919D-6, -0.13843D-6, &
             +1.245D-3,    -1.580D-3,   -0.659D-3/

      DATA (EMI(I,1),I=1,6) / +0.9999256795D0, &
                             -0.0111814828D0, &
                             -0.0048590040D0, &
                             -0.000551D0, &
                             -0.238560D0, &
                             +0.435730D0 /

      DATA (EMI(I,2),I=1,6) / +0.0111814828D0, &
                             +0.9999374849D0, &
                             -0.0000271557D0, &
                             +0.238509D0, &
                             -0.002667D0, &
                             -0.008541D0 /

      DATA (EMI(I,3),I=1,6) / +0.0048590039D0, &
                             -0.0000271771D0, &
                             +0.9999881946D0, &
                             -0.435614D0, &
                             +0.012254D0, &
                             +0.002117D0 /

      DATA (EMI(I,4),I=1,6) / -0.00000242389840D0, &
                             +0.00000002710544D0, &
                             +0.00000001177742D0, &
                             +0.99990432D0, &
                             -0.01118145D0, &
                             -0.00485852D0 /

      DATA (EMI(I,5),I=1,6) / -0.00000002710544D0, &
                             -0.00000242392702D0, &
                             +0.00000000006585D0, &
                             +0.01118145D0, &
                             +0.99991613D0, &
                             -0.00002716D0 /

      DATA (EMI(I,6),I=1,6) / -0.00000001177742D0, &
                             +0.00000000006585D0, &
                             -0.00000242404995D0, &
                             +0.00485852D0, &
                             -0.00002717D0, &
                             +0.99996684D0 /



!  Pick up J2000 data (units radians and arcsec/JC)
      R=R2000
      D=D2000
      UR=DR2000*PMF
      UD=DD2000*PMF
      PX=P2000
      RV=V2000

!  Spherical to Cartesian
      SR=SIN(R)
      CR=COS(R)
      SD=SIN(D)
      CD=COS(D)

      X=CR*CD
      Y=SR*CD
      Z=   SD

      W=VF*RV*PX

      V1(1)=X
      V1(2)=Y
      V1(3)=Z

      V1(4)=-UR*Y-CR*SD*UD+W*X
      V1(5)= UR*X-SR*SD*UD+W*Y
      V1(6)=         CD*UD+W*Z

!  Convert position+velocity vector to BN system
      DO I=1,6
         W=0D0
         DO J=1,6
            W=W+EMI(I,J)*V1(J)
         END DO
         V2(I)=W
      END DO

!  Position vector components and magnitude
      X=V2(1)
      Y=V2(2)
      Z=V2(3)
      RXYZ=SQRT(X*X+Y*Y+Z*Z)

!  Apply E-terms to position
      W=X*A(1)+Y*A(2)+Z*A(3)
      X=X+A(1)*RXYZ-W*X
      Y=Y+A(2)*RXYZ-W*Y
      Z=Z+A(3)*RXYZ-W*Z

!  Recompute magnitude
      RXYZ=SQRT(X*X+Y*Y+Z*Z)

!  Apply E-terms to both position and velocity
      X=V2(1)
      Y=V2(2)
      Z=V2(3)
      W=X*A(1)+Y*A(2)+Z*A(3)
      WD=X*A(4)+Y*A(5)+Z*A(6)
      X=X+A(1)*RXYZ-W*X
      Y=Y+A(2)*RXYZ-W*Y
      Z=Z+A(3)*RXYZ-W*Z
      XD=V2(4)+A(4)*RXYZ-WD*X
      YD=V2(5)+A(5)*RXYZ-WD*Y
      ZD=V2(6)+A(6)*RXYZ-WD*Z

!  Convert to spherical
      RXYSQ=X*X+Y*Y
      RXY=SQRT(RXYSQ)

      IF (X.EQ.0D0.AND.Y.EQ.0D0) THEN
         R=0D0
      ELSE
         R=ATAN2(Y,X)
         IF (R.LT.0.0D0) R=R+D2PI
      END IF
      D=ATAN2(Z,RXY)

      IF (RXY.GT.TINY) THEN
         UR=(X*YD-Y*XD)/RXYSQ
         UD=(ZD*RXYSQ-Z*(X*XD+Y*YD))/((RXYSQ+Z*Z)*RXY)
      END IF

!  Radial velocity and parallax
      IF (PX.GT.TINY) THEN
         RV=(X*XD+Y*YD+Z*ZD)/(PX*VF*RXYZ)
         PX=PX/RXYZ
      END IF

!  Return results
      R1950=R
      D1950=D
      DR1950=UR/PMF
      DD1950=UD/PMF
      P1950=PX
      V1950=RV

      END
      SUBROUTINE sla_FK52H (R5,D5,DR5,DD5,RH,DH,DRH,DDH)
!+
!     - - - - - -
!      F K 5 2 H
!     - - - - - -
!
!  Transform FK5 (J2000) star data into the Hipparcos frame.
!
!  (double precision)
!
!  This routine transforms FK5 star positions and proper motions
!  into the frame of the Hipparcos catalogue.
!
!  Given (all FK5, equinox J2000, epoch J2000):
!     R5        d      RA (radians)
!     D5        d      Dec (radians)
!     DR5       d      proper motion in RA (dRA/dt, rad/Jyear)
!     DD5       d      proper motion in Dec (dDec/dt, rad/Jyear)
!
!  Returned (all Hipparcos, epoch J2000):
!     RH        d      RA (radians)
!     DH        d      Dec (radians)
!     DRH       d      proper motion in RA (dRA/dt, rad/Jyear)
!     DDH       d      proper motion in Dec (dDec/dt, rad/Jyear)
!
!  Called:  sla_DS2C6, sla_DAV2M, sla_DMXV, sla_DVXV, sla_DC62S,
!           sla_DRANRM
!
!  Notes:
!
!  1)  The proper motions in RA are dRA/dt rather than
!      cos(Dec)*dRA/dt, and are per year rather than per century.
!
!  2)  The FK5 to Hipparcos transformation consists of a pure
!      rotation and spin;  zonal errors in the FK5 catalogue are
!      not taken into account.
!
!  3)  The published orientation and spin components are interpreted
!      as "axial vectors".  An axial vector points at the pole of the
!      rotation and its length is the amount of rotation in radians.
!
!  4)  See also sla_H2FK5, sla_FK5HZ, sla_HFK5Z.
!
!  Reference:
!
!     M.Feissel & F.Mignard, Astron. Astrophys. 331, L33-L36 (1998).
!
!  P.T.Wallace   Starlink   22 June 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION R5,D5,DR5,DD5,RH,DH,DRH,DDH

      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

!  FK5 to Hipparcos orientation and spin (radians, radians/year)
      DOUBLE PRECISION EPX,EPY,EPZ
      DOUBLE PRECISION OMX,OMY,OMZ

      PARAMETER ( EPX = -19.9D-3 * AS2R, &
                 EPY =  -9.1D-3 * AS2R, &
                 EPZ = +22.9D-3 * AS2R )

      PARAMETER ( OMX = -0.30D-3 * AS2R, &
                 OMY = +0.60D-3 * AS2R, &
                 OMZ = +0.70D-3 * AS2R )

      DOUBLE PRECISION PV5(6),ORTN(3),R5H(3,3),S5(3),VV(3),PVH(6),W,R,V
      INTEGER I

      DOUBLE PRECISION sla_DRANRM



!  FK5 barycentric position/velocity 6-vector (normalized).
      CALL sla_DS2C6(R5,D5,1D0,DR5,DD5,0D0,PV5)

!  FK5 to Hipparcos orientation matrix.
      ORTN(1) = EPX
      ORTN(2) = EPY
      ORTN(3) = EPZ
      CALL sla_DAV2M(ORTN,R5H)

!  Hipparcos wrt FK5 spin vector.
      S5(1) = OMX
      S5(2) = OMY
      S5(3) = OMZ

!  Orient & spin the 6-vector into the Hipparcos frame.
      CALL sla_DMXV(R5H,PV5,PVH)
      CALL sla_DVXV(PV5,S5,VV)
      DO I=1,3
         VV(I) = PV5(I+3)+VV(I)
      END DO
      CALL sla_DMXV(R5H,VV,PVH(4))

!  Hipparcos 6-vector to spherical.
      CALL sla_DC62S(PVH,W,DH,R,DRH,DDH,V)
      RH = sla_DRANRM(W)

      END
      SUBROUTINE sla_FK54Z (R2000,D2000,BEPOCH, &
                           R1950,D1950,DR1950,DD1950)
!+
!     - - - - - -
!      F K 5 4 Z
!     - - - - - -
!
!  Convert a J2000.0 FK5 star position to B1950.0 FK4 assuming
!  zero proper motion and parallax (double precision)
!
!  This routine converts star positions from the new, IAU 1976,
!  FK5, Fricke system to the old, Bessel-Newcomb, FK4 system.
!
!  Given:
!     R2000,D2000     dp    J2000.0 FK5 RA,Dec (rad)
!     BEPOCH          dp    Besselian epoch (e.g. 1950D0)
!
!  Returned:
!     R1950,D1950     dp    B1950.0 FK4 RA,Dec (rad) at epoch BEPOCH
!     DR1950,DD1950   dp    B1950.0 FK4 proper motions (rad/trop.yr)
!
!  Notes:
!
!  1)  The proper motion in RA is dRA/dt rather than cos(Dec)*dRA/dt.
!
!  2)  Conversion from Julian epoch 2000.0 to Besselian epoch 1950.0
!      only is provided for.  Conversions involving other epochs will
!      require use of the appropriate precession routines before and
!      after this routine is called.
!
!  3)  Unlike in the sla_FK524 routine, the FK5 proper motions, the
!      parallax and the radial velocity are presumed zero.
!
!  4)  It is the intention that FK5 should be a close approximation
!      to an inertial frame, so that distant objects have zero proper
!      motion;  such objects have (in general) non-zero proper motion
!      in FK4, and this routine returns those fictitious proper
!      motions.
!
!  5)  The position returned by this routine is in the B1950
!      reference frame but at Besselian epoch BEPOCH.  For
!      comparison with catalogues the BEPOCH argument will
!      frequently be 1950D0.
!
!  Called:  sla_FK524, sla_PM
!
!  P.T.Wallace   Starlink   10 April 1990
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION R2000,D2000,BEPOCH, &
                      R1950,D1950,DR1950,DD1950

      DOUBLE PRECISION R,D,PX,RV



!  FK5 equinox J2000 (any epoch) to FK4 equinox B1950 epoch B1950
      CALL sla_FK524(R2000,D2000,0D0,0D0,0D0,0D0, &
                    R,D,DR1950,DD1950,PX,RV)

!  Fictitious proper motion to epoch BEPOCH
      CALL sla_PM(R,D,DR1950,DD1950,0D0,0D0,1950D0,BEPOCH, &
                 R1950,D1950)

      END
      SUBROUTINE sla_FK5HZ (R5,D5,EPOCH,RH,DH)
!+
!     - - - - - -
!      F K 5 H Z
!     - - - - - -
!
!  Transform an FK5 (J2000) star position into the frame of the
!  Hipparcos catalogue, assuming zero Hipparcos proper motion.
!
!  (double precision)
!
!  This routine converts a star position from the FK5 system to
!  the Hipparcos system, in such a way that the Hipparcos proper
!  motion is zero.  Because such a star has, in general, a non-zero
!  proper motion in the FK5 system, the routine requires the epoch
!  at which the position in the FK5 system was determined.
!
!  Given:
!     R5        d      FK5 RA (radians), equinox J2000, epoch EPOCH
!     D5        d      FK5 Dec (radians), equinox J2000, epoch EPOCH
!     EPOCH     d      Julian epoch (TDB)
!
!  Returned (all Hipparcos):
!     RH        d      RA (radians)
!     DH        d      Dec (radians)
!
!  Called:  sla_DCS2C, sla_DAV2M, sla_DIMXV, sla_DMXV, sla_DCC2S,
!           sla_DRANRM
!
!  Notes:
!
!  1)  The FK5 to Hipparcos transformation consists of a pure
!      rotation and spin;  zonal errors in the FK5 catalogue are
!      not taken into account.
!
!  2)  The published orientation and spin components are interpreted
!      as "axial vectors".  An axial vector points at the pole of the
!      rotation and its length is the amount of rotation in radians.
!
!  3)  See also sla_FK52H, sla_H2FK5, sla_HFK5Z.
!
!  Reference:
!
!     M.Feissel & F.Mignard, Astron. Astrophys. 331, L33-L36 (1998).
!
!  P.T.Wallace   Starlink   22 June 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION R5,D5,EPOCH,RH,DH

      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

!  FK5 to Hipparcos orientation and spin (radians, radians/year)
      DOUBLE PRECISION EPX,EPY,EPZ
      DOUBLE PRECISION OMX,OMY,OMZ

      PARAMETER ( EPX = -19.9D-3 * AS2R, &
                 EPY =  -9.1D-3 * AS2R, &
                 EPZ = +22.9D-3 * AS2R )

      PARAMETER ( OMX = -0.30D-3 * AS2R, &
                 OMY = +0.60D-3 * AS2R, &
                 OMZ = +0.70D-3 * AS2R )

      DOUBLE PRECISION P5E(3),ORTN(3),R5H(3,3),T,VST(3),RST(3,3), &
                      P5(3),PH(3),W

      DOUBLE PRECISION sla_DRANRM



!  FK5 barycentric position vector.
      CALL sla_DCS2C(R5,D5,P5E)

!  FK5 to Hipparcos orientation matrix.
      ORTN(1) = EPX
      ORTN(2) = EPY
      ORTN(3) = EPZ
      CALL sla_DAV2M(ORTN,R5H)

!  Time interval from epoch to J2000.
      T = 2000D0-EPOCH

!  Axial vector:  accumulated Hipparcos wrt FK5 spin over that interval.
      VST(1) = OMX*T
      VST(2) = OMY*T
      VST(3) = OMZ*T

!  Express the accumulated spin as a rotation matrix.
      CALL sla_DAV2M(VST,RST)

!  Derotate the vector's FK5 axes back to epoch.
      CALL sla_DIMXV(RST,P5E,P5)

!  Rotate the vector into the Hipparcos frame.
      CALL sla_DMXV(R5H,P5,PH)

!  Hipparcos vector to spherical.
      CALL sla_DCC2S(PH,W,DH)
      RH = sla_DRANRM(W)

      END
      SUBROUTINE sla_FLOTIN (STRING, NSTRT, RESLT, JFLAG)
!+
!     - - - - - - -
!      F L O T I N
!     - - - - - - -
!
!  Convert free-format input into single precision floating point
!
!  Given:
!     STRING     c     string containing number to be decoded
!     NSTRT      i     pointer to where decoding is to start
!     RESLT      r     current value of result
!
!  Returned:
!     NSTRT      i      advanced to next number
!     RESLT      r      result
!     JFLAG      i      status: -1 = -OK, 0 = +OK, 1 = null, 2 = error
!
!  Called:  sla_DFLTIN
!
!  Notes:
!
!     1     The reason FLOTIN has separate OK status values for +
!           and - is to enable minus zero to be detected.   This is
!           of crucial importance when decoding mixed-radix numbers.
!           For example, an angle expressed as deg, arcmin, arcsec
!           may have a leading minus sign but a zero degrees field.
!
!     2     A TAB is interpreted as a space, and lowercase characters
!           are interpreted as uppercase.
!
!     3     The basic format is the sequence of fields #^.^@#^, where
!           # is a sign character + or -, ^ means a string of decimal
!           digits, and @, which indicates an exponent, means D or E.
!           Various combinations of these fields can be omitted, and
!           embedded blanks are permissible in certain places.
!
!     4     Spaces:
!
!             .  Leading spaces are ignored.
!
!             .  Embedded spaces are allowed only after +, -, D or E,
!                and after the decomal point if the first sequence of
!                digits is absent.
!
!             .  Trailing spaces are ignored;  the first signifies
!                end of decoding and subsequent ones are skipped.
!
!     5     Delimiters:
!
!             .  Any character other than +,-,0-9,.,D,E or space may be
!                used to signal the end of the number and terminate
!                decoding.
!
!             .  Comma is recognized by FLOTIN as a special case;  it
!                is skipped, leaving the pointer on the next character.
!                See 13, below.
!
!     6     Both signs are optional.  The default is +.
!
!     7     The mantissa ^.^ defaults to 1.
!
!     8     The exponent @#^ defaults to E0.
!
!     9     The strings of decimal digits may be of any length.
!
!     10    The decimal point is optional for whole numbers.
!
!     11    A "null result" occurs when the string of characters being
!           decoded does not begin with +,-,0-9,.,D or E, or consists
!           entirely of spaces.  When this condition is detected, JFLAG
!           is set to 1 and RESLT is left untouched.
!
!     12    NSTRT = 1 for the first character in the string.
!
!     13    On return from FLOTIN, NSTRT is set ready for the next
!           decode - following trailing blanks and any comma.  If a
!           delimiter other than comma is being used, NSTRT must be
!           incremented before the next call to FLOTIN, otherwise
!           all subsequent calls will return a null result.
!
!     14    Errors (JFLAG=2) occur when:
!
!             .  a +, -, D or E is left unsatisfied;  or
!
!             .  the decimal point is present without at least
!                one decimal digit before or after it;  or
!
!             .  an exponent more than 100 has been presented.
!
!     15    When an error has been detected, NSTRT is left
!           pointing to the character following the last
!           one used before the error came to light.  This
!           may be after the point at which a more sophisticated
!           program could have detected the error.  For example,
!           FLOTIN does not detect that '1E999' is unacceptable
!           (on a computer where this is so) until the entire number
!           has been decoded.
!
!     16    Certain highly unlikely combinations of mantissa &
!           exponent can cause arithmetic faults during the
!           decode, in some cases despite the fact that they
!           together could be construed as a valid number.
!
!     17    Decoding is left to right, one pass.
!
!     18    See also DFLTIN and INTIN
!
!  P.T.Wallace   Starlink   23 November 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) STRING
      INTEGER NSTRT
      REAL RESLT
      INTEGER JFLAG

      DOUBLE PRECISION DRESLT


!  Call the double precision version
      CALL sla_DFLTIN(STRING,NSTRT,DRESLT,JFLAG)
      IF (JFLAG.LE.0) RESLT=REAL(DRESLT)

      END
      SUBROUTINE sla_GALEQ (DL, DB, DR, DD)
!+
!     - - - - - -
!      G A L E Q
!     - - - - - -
!
!  Transformation from IAU 1958 galactic coordinates to
!  J2000.0 equatorial coordinates (double precision)
!
!  Given:
!     DL,DB       dp       galactic longitude and latitude L2,B2
!
!  Returned:
!     DR,DD       dp       J2000.0 RA,Dec
!
!  (all arguments are radians)
!
!  Called:
!     sla_DCS2C, sla_DIMXV, sla_DCC2S, sla_DRANRM, sla_DRANGE
!
!  Note:
!     The equatorial coordinates are J2000.0.  Use the routine
!     sla_GE50 if conversion to B1950.0 'FK4' coordinates is
!     required.
!
!  Reference:
!     Blaauw et al, Mon.Not.R.Astron.Soc.,121,123 (1960)
!
!  P.T.Wallace   Starlink   21 September 1998
!
!  Copyright (C) 1998 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DL,DB,DR,DD

      DOUBLE PRECISION sla_DRANRM,sla_DRANGE

      DOUBLE PRECISION V1(3),V2(3)

!
!  L2,B2 system of galactic coordinates
!
!  P = 192.25       RA of galactic north pole (mean B1950.0)
!  Q =  62.6        inclination of galactic to mean B1950.0 equator
!  R =  33          longitude of ascending node
!
!  P,Q,R are degrees
!
!  Equatorial to galactic rotation matrix (J2000.0), obtained by
!  applying the standard FK4 to FK5 transformation, for zero proper
!  motion in FK5, to the columns of the B1950 equatorial to
!  galactic rotation matrix:
!
      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3), &
          RMAT(2,1),RMAT(2,2),RMAT(2,3), &
          RMAT(3,1),RMAT(3,2),RMAT(3,3)/ &
      -0.054875539726D0,-0.873437108010D0,-0.483834985808D0, &
      +0.494109453312D0,-0.444829589425D0,+0.746982251810D0, &
      -0.867666135858D0,-0.198076386122D0,+0.455983795705D0/



!  Spherical to Cartesian
      CALL sla_DCS2C(DL,DB,V1)

!  Galactic to equatorial
      CALL sla_DIMXV(RMAT,V1,V2)

!  Cartesian to spherical
      CALL sla_DCC2S(V2,DR,DD)

!  Express in conventional ranges
      DR=sla_DRANRM(DR)
      DD=sla_DRANGE(DD)

      END
      SUBROUTINE sla_GALSUP (DL, DB, DSL, DSB)
!+
!     - - - - - - -
!      G A L S U P
!     - - - - - - -
!
!  Transformation from IAU 1958 galactic coordinates to
!  de Vaucouleurs supergalactic coordinates (double precision)
!
!  Given:
!     DL,DB       dp       galactic longitude and latitude L2,B2
!
!  Returned:
!     DSL,DSB     dp       supergalactic longitude and latitude
!
!  (all arguments are radians)
!
!  Called:
!     sla_DCS2C, sla_DMXV, sla_DCC2S, sla_DRANRM, sla_DRANGE
!
!  References:
!
!     de Vaucouleurs, de Vaucouleurs, & Corwin, Second Reference
!     Catalogue of Bright Galaxies, U. Texas, page 8.
!
!     Systems & Applied Sciences Corp., Documentation for the
!     machine-readable version of the above catalogue,
!     Contract NAS 5-26490.
!
!    (These two references give different values for the galactic
!     longitude of the supergalactic origin.  Both are wrong;  the
!     correct value is L2=137.37.)
!
!  P.T.Wallace   Starlink   25 January 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DL,DB,DSL,DSB

      DOUBLE PRECISION sla_DRANRM,sla_DRANGE

      DOUBLE PRECISION V1(3),V2(3)

!
!  System of supergalactic coordinates:
!
!    SGL   SGB        L2     B2      (deg)
!     -    +90      47.37  +6.32
!     0     0         -      0
!
!  Galactic to supergalactic rotation matrix:
!
      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3), &
          RMAT(2,1),RMAT(2,2),RMAT(2,3), &
          RMAT(3,1),RMAT(3,2),RMAT(3,3)/ &
      -0.735742574804D0,+0.677261296414D0,+0.000000000000D0, &
      -0.074553778365D0,-0.080991471307D0,+0.993922590400D0, &
      +0.673145302109D0,+0.731271165817D0,+0.110081262225D0/



!  Spherical to Cartesian
      CALL sla_DCS2C(DL,DB,V1)

!  Galactic to supergalactic
      CALL sla_DMXV(RMAT,V1,V2)

!  Cartesian to spherical
      CALL sla_DCC2S(V2,DSL,DSB)

!  Express in conventional ranges
      DSL=sla_DRANRM(DSL)
      DSB=sla_DRANGE(DSB)

      END
      SUBROUTINE sla_GE50 (DL, DB, DR, DD)
!+
!     - - - - -
!      G E 5 0
!     - - - - -
!
!  Transformation from IAU 1958 galactic coordinates to
!  B1950.0 'FK4' equatorial coordinates (double precision)
!
!  Given:
!     DL,DB       dp       galactic longitude and latitude L2,B2
!
!  Returned:
!     DR,DD       dp       B1950.0 'FK4' RA,Dec
!
!  (all arguments are radians)
!
!  Called:
!     sla_DCS2C, sla_DIMXV, sla_DCC2S, sla_ADDET, sla_DRANRM, sla_DRANGE
!
!  Note:
!     The equatorial coordinates are B1950.0 'FK4'.  Use the
!     routine sla_GALEQ if conversion to J2000.0 coordinates
!     is required.
!
!  Reference:
!     Blaauw et al, Mon.Not.R.Astron.Soc.,121,123 (1960)
!
!  P.T.Wallace   Starlink   5 September 1993
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DL,DB,DR,DD

      DOUBLE PRECISION sla_DRANRM,sla_DRANGE

      DOUBLE PRECISION V1(3),V2(3),R,D,RE,DE

!
!  L2,B2 system of galactic coordinates
!
!  P = 192.25       RA of galactic north pole (mean B1950.0)
!  Q =  62.6        inclination of galactic to mean B1950.0 equator
!  R =  33          longitude of ascending node
!
!  P,Q,R are degrees
!
!
!  Equatorial to galactic rotation matrix
!
!  The Euler angles are P, Q, 90-R, about the z then y then
!  z axes.
!
!         +CP.CQ.SR-SP.CR     +SP.CQ.SR+CP.CR     -SQ.SR
!
!         -CP.CQ.CR-SP.SR     -SP.CQ.CR+CP.SR     +SQ.CR
!
!         +CP.SQ              +SP.SQ              +CQ
!

      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3), &
          RMAT(2,1),RMAT(2,2),RMAT(2,3), &
          RMAT(3,1),RMAT(3,2),RMAT(3,3) / &
      -0.066988739415D0,-0.872755765852D0,-0.483538914632D0, &
      +0.492728466075D0,-0.450346958020D0,+0.744584633283D0, &
      -0.867600811151D0,-0.188374601723D0,+0.460199784784D0 /



!  Spherical to Cartesian
      CALL sla_DCS2C(DL,DB,V1)

!  Rotate to mean B1950.0
      CALL sla_DIMXV(RMAT,V1,V2)

!  Cartesian to spherical
      CALL sla_DCC2S(V2,R,D)

!  Introduce E-terms
      CALL sla_ADDET(R,D,1950D0,RE,DE)

!  Express in conventional ranges
      DR=sla_DRANRM(RE)
      DD=sla_DRANGE(DE)

      END
      SUBROUTINE sla_GEOC (P, H, R, Z)
!+
!     - - - - -
!      G E O C
!     - - - - -
!
!  Convert geodetic position to geocentric (double precision)
!
!  Given:
!     P     dp     latitude (geodetic, radians)
!     H     dp     height above reference spheroid (geodetic, metres)
!
!  Returned:
!     R     dp     distance from Earth axis (AU)
!     Z     dp     distance from plane of Earth equator (AU)
!
!  Notes:
!     1)  Geocentric latitude can be obtained by evaluating ATAN2(Z,R).
!     2)  IAU 1976 constants are used.
!
!  Reference:
!     Green,R.M., Spherical Astronomy, CUP 1985, p98.
!
!  P.T.Wallace   Starlink   4th October 1989
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION P,H,R,Z

!  Earth equatorial radius (metres)
      DOUBLE PRECISION A0
      PARAMETER (A0=6378140D0)

!  Reference spheroid flattening factor and useful function
      DOUBLE PRECISION F,B
      PARAMETER (F=1D0/298.257D0,B=(1D0-F)**2)

!  Astronomical unit in metres
      DOUBLE PRECISION AU
      PARAMETER (AU=1.49597870D11)

      DOUBLE PRECISION SP,CP,C,S



!  Geodetic to geocentric conversion
      SP=SIN(P)
      CP=COS(P)
      C=1D0/SQRT(CP*CP+B*SP*SP)
      S=B*C
      R=(A0*C+H)*CP/AU
      Z=(A0*S+H)*SP/AU

      END
      DOUBLE PRECISION FUNCTION sla_GMST (UT1)
!+
!     - - - - -
!      G M S T
!     - - - - -
!
!  Conversion from universal time to sidereal time (double precision)
!
!  Given:
!    UT1    dp     universal time (strictly UT1) expressed as
!                  modified Julian Date (JD-2400000.5)
!
!  The result is the Greenwich mean sidereal time (double
!  precision, radians).
!
!  The IAU 1982 expression (see page S15 of 1984 Astronomical Almanac)
!  is used, but rearranged to reduce rounding errors.  This expression
!  is always described as giving the GMST at 0 hours UT.  In fact, it
!  gives the difference between the GMST and the UT, which happens to
!  equal the GMST (modulo 24 hours) at 0 hours UT each day.  In this
!  routine, the entire UT is used directly as the argument for the
!  standard formula, and the fractional part of the UT is added
!  separately.  Note that the factor 1.0027379... does not appear in the
!  IAU 1982 expression explicitly but in the form of the coefficient
!  8640184.812866, which is 86400x36525x0.0027379...
!
!  See also the routine sla_GMSTA, which delivers better numerical
!  precision by accepting the UT date and time as separate arguments.
!
!  Called:  sla_DRANRM
!
!  P.T.Wallace   Starlink   14 October 2001
!
!  Copyright (C) 2001 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION UT1

      DOUBLE PRECISION sla_DRANRM

      DOUBLE PRECISION D2PI,S2R
      PARAMETER (D2PI=6.283185307179586476925286766559D0, &
                S2R=7.272205216643039903848711535369D-5)

      DOUBLE PRECISION TU



!  Julian centuries from fundamental epoch J2000 to this UT
      TU=(UT1-51544.5D0)/36525D0

!  GMST at this UT
      sla_GMST=sla_DRANRM(MOD(UT1,1D0)*D2PI+ &
                         (24110.54841D0+ &
                         (8640184.812866D0+ &
                         (0.093104D0-6.2D-6*TU)*TU)*TU)*S2R)

      END
      DOUBLE PRECISION FUNCTION sla_GMSTA (DATE, UT)
!+
!     - - - - - -
!      G M S T A
!     - - - - - -
!
!  Conversion from Universal Time to Greenwich mean sidereal time,
!  with rounding errors minimized.
!
!  double precision
!
!  Given:
!    DATE    d      UT1 date (MJD: integer part of JD-2400000.5))
!    UT      d      UT1 time (fraction of a day)
!
!  The result is the Greenwich mean sidereal time (double precision,
!  radians, in the range 0 to 2pi).
!
!  There is no restriction on how the UT is apportioned between the
!  DATE and UT arguments.  Either of the two arguments could, for
!  example, be zero and the entire date+time supplied in the other.
!  However, the routine is designed to deliver maximum accuracy when
!  the DATE argument is a whole number and the UT lies in the range
!  0 to 1 (or vice versa).
!
!  The algorithm is based on the IAU 1982 expression (see page S15 of
!  the 1984 Astronomical Almanac).  This is always described as giving
!  the GMST at 0 hours UT1.  In fact, it gives the difference between
!  the GMST and the UT, the steady 4-minutes-per-day drawing-ahead of
!  ST with respect to UT.  When whole days are ignored, the expression
!  happens to equal the GMST at 0 hours UT1 each day.  Note that the
!  factor 1.0027379... does not appear explicitly but in the form of
!  the coefficient 8640184.812866, which is 86400x36525x0.0027379...
!
!  In this routine, the entire UT1 (the sum of the two arguments DATE
!  and UT) is used directly as the argument for the standard formula.
!  The UT1 is then added, but omitting whole days to conserve accuracy.
!
!  See also the routine sla_GMST, which accepts the UT as a single
!  argument.  Compared with sla_GMST, the extra numerical precision
!  delivered by the present routine is unlikely to be important in
!  an absolute sense, but may be useful when critically comparing
!  algorithms and in applications where two sidereal times close
!  together are differenced.
!
!  Called:  sla_DRANRM
!
!  P.T.Wallace   Starlink   14 October 2001
!
!  Copyright (C) 2001 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,UT

!  Seconds of time to radians
      DOUBLE PRECISION S2R
      PARAMETER (S2R=7.272205216643039903848712D-5)

      DOUBLE PRECISION D1,D2,T
      DOUBLE PRECISION sla_DRANRM


!  Julian centuries since J2000.
      IF (DATE.LT.UT) THEN
         D1=DATE
         D2=UT
      ELSE
         D1=UT
         D2=DATE
      END IF
      T=(D1+(D2-51544.5D0))/36525D0

!  GMST at this UT1.
      sla_GMSTA=sla_DRANRM(S2R*(24110.54841D0+ &
                              (8640184.812866D0+ &
                              (0.093104D0 &
                              -6.2D-6*T)*T)*T &
                              +86400D0*(MOD(D1,1D0)+MOD(D2,1D0))))

      END
      REAL FUNCTION sla_GRESID (S)
!+
!     - - - - - - -
!      G R E S I D
!     - - - - - - -
!
!  Generate pseudo-random normal deviate ( = 'Gaussian residual')
!  (single precision)
!
!  !!! Sun 4 specific !!!
!
!  Given:
!     S      real     standard deviation
!
!  The results of many calls to this routine will be
!  normally distributed with mean zero and standard deviation S.
!
!  The Box-Muller algorithm is used.  This is described in
!  Numerical Recipes, section 7.2.
!
!  Called:  RAND (a REAL function from the Sun Fortran Library)
!
!  P.T.Wallace   Starlink   14 October 1991
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL S

      REAL X,Y,R,W,GNEXT,G
      LOGICAL FTF,FIRST

      REAL RAND

      SAVE GNEXT,FIRST
      DATA FTF,FIRST / .TRUE.,.TRUE. /



!  First time through, initialise the random-number generator
      IF (FTF) THEN
         X = RAND(123456789)
         FTF = .FALSE.
      END IF

!  Second normal deviate of the pair available?
      IF (FIRST) THEN

!     No - generate two random numbers inside unit circle
         R = 2.0
         DO WHILE (R.GE.1.0)

!        Generate two random numbers in range +/- 1
            X = 2.0*RAND(0)-1.0
            Y = 2.0*RAND(0)-1.0

!        Try again if not in unit circle
            R = X*X+Y*Y
         END DO

!     Box-Muller transformation, generating two deviates
         W = SQRT(-2.0*LOG(R)/MAX(R,1E-20))
         GNEXT = X*W
         G = Y*W

!     Set flag to indicate availability of next deviate
         FIRST = .FALSE.
      ELSE

!     Return second deviate of the pair & reset flag
         G = GNEXT
         FIRST = .TRUE.
      END IF

!  Scale the deviate by the required standard deviation
      sla_GRESID = G*S

      END
      SUBROUTINE sla_H2E (AZ, EL, PHI, HA, DEC)
!+
!     - - - - -
!      D E 2 H
!     - - - - -
!
!  Horizon to equatorial coordinates:  Az,El to HA,Dec
!
!  (single precision)
!
!  Given:
!     AZ      r     azimuth
!     EL      r     elevation
!     PHI     r     observatory latitude
!
!  Returned:
!     HA      r     hour angle
!     DEC     r     declination
!
!  Notes:
!
!  1)  All the arguments are angles in radians.
!
!  2)  The sign convention for azimuth is north zero, east +pi/2.
!
!  3)  HA is returned in the range +/-pi.  Declination is returned
!      in the range +/-pi/2.
!
!  4)  The latitude is (in principle) geodetic.  In critical
!      applications, corrections for polar motion should be applied.
!
!  5)  In some applications it will be important to specify the
!      correct type of elevation in order to produce the required
!      type of HA,Dec.  In particular, it may be important to
!      distinguish between the elevation as affected by refraction,
!      which will yield the "observed" HA,Dec, and the elevation
!      in vacuo, which will yield the "topocentric" HA,Dec.  If the
!      effects of diurnal aberration can be neglected, the
!      topocentric HA,Dec may be used as an approximation to the
!      "apparent" HA,Dec.
!
!  6)  No range checking of arguments is done.
!
!  7)  In applications which involve many such calculations, rather
!      than calling the present routine it will be more efficient to
!      use inline code, having previously computed fixed terms such
!      as sine and cosine of latitude.
!
!  P.T.Wallace   Starlink   21 February 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL AZ,EL,PHI,HA,DEC

      DOUBLE PRECISION SA,CA,SE,CE,SP,CP,X,Y,Z,R


!  Useful trig functions
      SA=SIN(AZ)
      CA=COS(AZ)
      SE=SIN(EL)
      CE=COS(EL)
      SP=SIN(PHI)
      CP=COS(PHI)

!  HA,Dec as x,y,z
      X=-CA*CE*SP+SE*CP
      Y=-SA*CE
      Z=CA*CE*CP+SE*SP

!  To HA,Dec
      R=SQRT(X*X+Y*Y)
      IF (R.EQ.0.0) THEN
         HA=0.0
      ELSE
         HA=ATAN2(Y,X)
      END IF
      DEC=ATAN2(Z,R)

      END
      SUBROUTINE sla_H2FK5 (RH,DH,DRH,DDH,R5,D5,DR5,DD5)
!+
!     - - - - - -
!      H 2 F K 5
!     - - - - - -
!
!  Transform Hipparcos star data into the FK5 (J2000) system.
!
!  (double precision)
!
!  This routine transforms Hipparcos star positions and proper
!  motions into FK5 J2000.
!
!  Given (all Hipparcos, epoch J2000):
!     RH        d      RA (radians)
!     DH        d      Dec (radians)
!     DRH       d      proper motion in RA (dRA/dt, rad/Jyear)
!     DDH       d      proper motion in Dec (dDec/dt, rad/Jyear)
!
!  Returned (all FK5, equinox J2000, epoch J2000):
!     R5        d      RA (radians)
!     D5        d      Dec (radians)
!     DR5       d      proper motion in RA (dRA/dt, rad/Jyear)
!     DD5       d      proper motion in Dec (dDec/dt, rad/Jyear)
!
!  Called:  sla_DS2C6, sla_DAV2M, sla_DMXV, sla_DIMXV, sla_DVXV,
!           sla_DC62S, sla_DRANRM
!
!  Notes:
!
!  1)  The proper motions in RA are dRA/dt rather than
!      cos(Dec)*dRA/dt, and are per year rather than per century.
!
!  2)  The FK5 to Hipparcos transformation consists of a pure
!      rotation and spin;  zonal errors in the FK5 catalogue are
!      not taken into account.
!
!  3)  The published orientation and spin components are interpreted
!      as "axial vectors".  An axial vector points at the pole of the
!      rotation and its length is the amount of rotation in radians.
!
!  4)  See also sla_FK52H, sla_FK5HZ, sla_HFK5Z.
!
!  Reference:
!
!     M.Feissel & F.Mignard, Astron. Astrophys. 331, L33-L36 (1998).
!
!  P.T.Wallace   Starlink   22 June 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RH,DH,DRH,DDH,R5,D5,DR5,DD5

      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

!  FK5 to Hipparcos orientation and spin (radians, radians/year)
      DOUBLE PRECISION EPX,EPY,EPZ
      DOUBLE PRECISION OMX,OMY,OMZ

      PARAMETER ( EPX = -19.9D-3 * AS2R, &
                 EPY =  -9.1D-3 * AS2R, &
                 EPZ = +22.9D-3 * AS2R )

      PARAMETER ( OMX = -0.30D-3 * AS2R, &
                 OMY = +0.60D-3 * AS2R, &
                 OMZ = +0.70D-3 * AS2R )

      DOUBLE PRECISION PVH(6),ORTN(3),R5H(3,3),S5(3),SH(3),VV(3), &
                      PV5(6),W,R,V
      INTEGER I

      DOUBLE PRECISION sla_DRANRM



!  Hipparcos barycentric position/velocity 6-vector (normalized).
      CALL sla_DS2C6(RH,DH,1D0,DRH,DDH,0D0,PVH)

!  FK5 to Hipparcos orientation matrix.
      ORTN(1) = EPX
      ORTN(2) = EPY
      ORTN(3) = EPZ
      CALL sla_DAV2M(ORTN,R5H)

!  Hipparcos wrt FK5 spin vector.
      S5(1) = OMX
      S5(2) = OMY
      S5(3) = OMZ

!  Rotate the spin vector into the Hipparcos frame.
      CALL sla_DMXV(R5H,S5,SH)

!  De-orient & de-spin the 6-vector into FK5 J2000.
      CALL sla_DIMXV(R5H,PVH,PV5)
      CALL sla_DVXV(PVH,SH,VV)
      DO I=1,3
         VV(I) = PVH(I+3)-VV(I)
      END DO
      CALL sla_DIMXV(R5H,VV,PV5(4))

!  FK5 6-vector to spherical.
      CALL sla_DC62S(PV5,W,D5,R,DR5,DD5,V)
      R5 = sla_DRANRM(W)

      END
      SUBROUTINE sla_HFK5Z (RH,DH,EPOCH,R5,D5,DR5,DD5)
!+
!     - - - - - -
!      H F K 5 Z
!     - - - - - -
!
!  Transform a Hipparcos star position into FK5 J2000, assuming
!  zero Hipparcos proper motion.
!
!  (double precision)
!
!  Given:
!     RH        d      Hipparcos RA (radians)
!     DH        d      Hipparcos Dec (radians)
!     EPOCH     d      Julian epoch (TDB)
!
!  Returned (all FK5, equinox J2000, epoch EPOCH):
!     R5        d      RA (radians)
!     D5        d      Dec (radians)
!
!  Called:  sla_DCS2C, sla_DAV2M, sla_DMXV, sla_DMXM,
!           sla_DIMXV, sla_DVXV, sla_DC62S, sla_DRANRM
!
!  Notes:
!
!  1)  The proper motion in RA is dRA/dt rather than cos(Dec)*dRA/dt.
!
!  2)  The FK5 to Hipparcos transformation consists of a pure
!      rotation and spin;  zonal errors in the FK5 catalogue are
!      not taken into account.
!
!  3)  The published orientation and spin components are interpreted
!      as "axial vectors".  An axial vector points at the pole of the
!      rotation and its length is the amount of rotation in radians.
!
!  4)  It was the intention that Hipparcos should be a close
!      approximation to an inertial frame, so that distant objects
!      have zero proper motion;  such objects have (in general)
!      non-zero proper motion in FK5, and this routine returns those
!      fictitious proper motions.
!
!  5)  The position returned by this routine is in the FK5 J2000
!      reference frame but at Julian epoch EPOCH.
!
!  6)  See also sla_FK52H, sla_H2FK5, sla_FK5ZHZ.
!
!  Reference:
!
!     M.Feissel & F.Mignard, Astron. Astrophys. 331, L33-L36 (1998).
!
!  P.T.Wallace   Starlink   30 December 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RH,DH,EPOCH,R5,D5,DR5,DD5

      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

!  FK5 to Hipparcos orientation and spin (radians, radians/year)
      DOUBLE PRECISION EPX,EPY,EPZ
      DOUBLE PRECISION OMX,OMY,OMZ

      PARAMETER ( EPX = -19.9D-3 * AS2R, &
                 EPY =  -9.1D-3 * AS2R, &
                 EPZ = +22.9D-3 * AS2R )

      PARAMETER ( OMX = -0.30D-3 * AS2R, &
                 OMY = +0.60D-3 * AS2R, &
                 OMZ = +0.70D-3 * AS2R )

      DOUBLE PRECISION PH(3),ORTN(3),R5H(3,3),S5(3),SH(3),T,VST(3), &
                      RST(3,3),R5HT(3,3),PV5E(6),VV(3),W,R,V

      DOUBLE PRECISION sla_DRANRM



!  Hipparcos barycentric position vector (normalized).
      CALL sla_DCS2C(RH,DH,PH)

!  FK5 to Hipparcos orientation matrix.
      ORTN(1) = EPX
      ORTN(2) = EPY
      ORTN(3) = EPZ
      CALL sla_DAV2M(ORTN,R5H)

!  Hipparcos wrt FK5 spin vector.
      S5(1) = OMX
      S5(2) = OMY
      S5(3) = OMZ

!  Rotate the spin vector into the Hipparcos frame.
      CALL sla_DMXV(R5H,S5,SH)

!  Time interval from J2000 to epoch.
      T = EPOCH-2000D0

!  Axial vector:  accumulated Hipparcos wrt FK5 spin over that interval.
      VST(1) = OMX*T
      VST(2) = OMY*T
      VST(3) = OMZ*T

!  Express the accumulated spin as a rotation matrix.
      CALL sla_DAV2M(VST,RST)

!  Rotation matrix:  accumulated spin, then FK5 to Hipparcos.
      CALL sla_DMXM(R5H,RST,R5HT)

!  De-orient & de-spin the vector into FK5 J2000 at epoch.
      CALL sla_DIMXV(R5HT,PH,PV5E)
      CALL sla_DVXV(SH,PH,VV)
      CALL sla_DIMXV(R5HT,VV,PV5E(4))

!  FK5 position/velocity 6-vector to spherical.
      CALL sla_DC62S(PV5E,W,D5,R,DR5,DD5,V)
      R5 = sla_DRANRM(W)

      END
      SUBROUTINE sla__IDCHF (STRING, NPTR, NVEC, NDIGIT, DIGIT)
!+
!     - - - - - -
!      I D C H F
!     - - - - - -
!
!  Internal routine used by DFLTIN
!
!  Identify next character in string
!
!  Given:
!     STRING      char        string
!     NPTR        int         pointer to character to be identified
!
!  Returned:
!     NPTR        int         incremented unless end of field
!     NVEC        int         vector for identified character
!     NDIGIT      int         0-9 if character was a numeral
!     DIGIT       double      equivalent of NDIGIT
!
!     NVEC takes the following values:
!
!      1     0-9
!      2     space or TAB   !!! n.b. ASCII TAB assumed !!!
!      3     D,d,E or e
!      4     .
!      5     +
!      6     -
!      7     ,
!      8     else
!      9     outside field
!
!  If the character is not 0-9, NDIGIT and DIGIT are either not
!  altered or are set to arbitrary values.
!
!  P.T.Wallace   Starlink   22 December 1992
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) STRING
      INTEGER NPTR,NVEC,NDIGIT
      DOUBLE PRECISION DIGIT

      CHARACTER K
      INTEGER NCHAR

!  Character/vector tables
      INTEGER NCREC
      PARAMETER (NCREC=19)
      CHARACTER KCTAB(NCREC)
      INTEGER KVTAB(NCREC)
      DATA KCTAB/'0','1','2','3','4','5','6','7','8','9', &
                ' ','D','d','E','e','.','+','-',','/
      DATA KVTAB/10*1,2,4*3,4,5,6,7/


!  Handle pointer outside field
      IF (NPTR.LT.1.OR.NPTR.GT.LEN(STRING)) THEN
         NVEC=9
      ELSE

!     Not end of field: identify the character
         K=STRING(NPTR:NPTR)
         DO NCHAR=1,NCREC
            IF (K.EQ.KCTAB(NCHAR)) THEN

!           Recognized
               NVEC=KVTAB(NCHAR)
               NDIGIT=NCHAR-1
               DIGIT=DBLE(NDIGIT)
               GO TO 2300
            END IF
         END DO

!     Not recognized: check for TAB    !!! n.b. ASCII assumed !!!
         IF (K.EQ.CHAR(9)) THEN

!        TAB: treat as space
            NVEC=2
         ELSE

!        Unrecognized
            NVEC=8
         END IF

!     Increment pointer
 2300    CONTINUE
         NPTR=NPTR+1
      END IF

      END
      SUBROUTINE sla__IDCHI (STRING, NPTR, NVEC, DIGIT)
!+
!     - - - - - -
!      I D C H I
!     - - - - - -
!
!  Internal routine used by INTIN
!
!  Identify next character in string
!
!  Given:
!     STRING      char        string
!     NPTR        int         pointer to character to be identified
!
!  Returned:
!     NPTR        int         incremented unless end of field
!     NVEC        int         vector for identified character
!     DIGIT       double      double precision digit if 0-9
!
!     NVEC takes the following values:
!
!      1     0-9
!      2     space or TAB   !!! n.b. ASCII TAB assumed !!!
!      3     +
!      4     -
!      5     ,
!      6     else
!      7     outside string
!
!  If the character is not 0-9, DIGIT is either unaltered or
!  is set to an arbitrary value.
!
!  P.T.Wallace   Starlink   22 December 1992
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) STRING
      INTEGER NPTR,NVEC
      DOUBLE PRECISION DIGIT

      CHARACTER K
      INTEGER NCHAR

!  Character/vector tables
      INTEGER NCREC
      PARAMETER (NCREC=14)
      CHARACTER KCTAB(NCREC)
      INTEGER KVTAB(NCREC)
      DATA KCTAB/'0','1','2','3','4','5','6','7','8','9', &
                ' ', '+','-',','/
      DATA KVTAB/10*1,2,3,4,5/



!  Handle pointer outside field
      IF (NPTR.LT.1.OR.NPTR.GT.LEN(STRING)) THEN
         NVEC=7
      ELSE

!     Not end of field: identify character
         K=STRING(NPTR:NPTR)
         DO NCHAR=1,NCREC
            IF (K.EQ.KCTAB(NCHAR)) THEN

!           Recognized
               NVEC=KVTAB(NCHAR)
               DIGIT=DBLE(NCHAR-1)
               GO TO 2300
            END IF
         END DO

!     Not recognized: check for TAB   !!! n.b. ASCII assumed !!!
         IF (K.EQ.CHAR(9)) THEN

!        TAB: treat as space
            NVEC=2
         ELSE

!        Unrecognized
            NVEC=6
         END IF

!     Increment pointer
 2300    CONTINUE
         NPTR=NPTR+1
      END IF

      END
      SUBROUTINE sla_IMXV (RM, VA, VB)
!+
!     - - - - -
!      I M X V
!     - - - - -
!
!  Performs the 3-D backward unitary transformation:
!
!     vector VB = (inverse of matrix RM) * vector VA
!
!  (single precision)
!
!  (n.b.  the matrix must be unitary, as this routine assumes that
!   the inverse and transpose are identical)
!
!  Given:
!     RM       real(3,3)    matrix
!     VA       real(3)      vector
!
!  Returned:
!     VB       real(3)      result vector
!
!  P.T.Wallace   Starlink   November 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL RM(3,3),VA(3),VB(3)

      INTEGER I,J
      REAL W,VW(3)



!  Inverse of matrix RM * vector VA -> vector VW
      DO J=1,3
         W=0.0
         DO I=1,3
            W=W+RM(I,J)*VA(I)
         END DO
         VW(J)=W
      END DO

!  Vector VW -> vector VB
      DO J=1,3
         VB(J)=VW(J)
      END DO

      END
      SUBROUTINE sla_INTIN (STRING, NSTRT, IRESLT, JFLAG)
!+
!     - - - - - -
!      I N T I N
!     - - - - - -
!
!  Convert free-format input into an integer
!
!  Given:
!     STRING     c     string containing number to be decoded
!     NSTRT      i     pointer to where decoding is to start
!     IRESLT     i     current value of result
!
!  Returned:
!     NSTRT      i      advanced to next number
!     IRESLT     i      result
!     JFLAG      i      status: -1 = -OK, 0 = +OK, 1 = null, 2 = error
!
!  Called:  sla__IDCHI
!
!  Notes:
!
!     1     The reason INTIN has separate OK status values for +
!           and - is to enable minus zero to be detected.   This is
!           of crucial importance when decoding mixed-radix numbers.
!           For example, an angle expressed as deg, arcmin, arcsec
!           may have a leading minus sign but a zero degrees field.
!
!     2     A TAB is interpreted as a space.
!
!     3     The basic format is the sequence of fields #^, where
!           # is a sign character + or -, and ^ means a string of
!           decimal digits.
!
!     4     Spaces:
!
!             .  Leading spaces are ignored.
!
!             .  Spaces between the sign and the number are allowed.
!
!             .  Trailing spaces are ignored;  the first signifies
!                end of decoding and subsequent ones are skipped.
!
!     5     Delimiters:
!
!             .  Any character other than +,-,0-9 or space may be
!                used to signal the end of the number and terminate
!                decoding.
!
!             .  Comma is recognized by INTIN as a special case;  it
!                is skipped, leaving the pointer on the next character.
!                See 9, below.
!
!     6     The sign is optional.  The default is +.
!
!     7     A "null result" occurs when the string of characters being
!           decoded does not begin with +,- or 0-9, or consists
!           entirely of spaces.  When this condition is detected, JFLAG
!           is set to 1 and IRESLT is left untouched.
!
!     8     NSTRT = 1 for the first character in the string.
!
!     9     On return from INTIN, NSTRT is set ready for the next
!           decode - following trailing blanks and any comma.  If a
!           delimiter other than comma is being used, NSTRT must be
!           incremented before the next call to INTIN, otherwise
!           all subsequent calls will return a null result.
!
!     10    Errors (JFLAG=2) occur when:
!
!             .  there is a + or - but no number;  or
!
!             .  the number is greater than BIG (defined below).
!
!     11    When an error has been detected, NSTRT is left
!           pointing to the character following the last
!           one used before the error came to light.
!
!     12    See also FLOTIN and DFLTIN.
!
!  P.T.Wallace   Starlink   27 April 1998
!
!  Copyright (C) 1998 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) STRING
      INTEGER NSTRT,IRESLT,JFLAG

!  Maximum allowed value
      DOUBLE PRECISION BIG
      PARAMETER (BIG=2147483647D0)

      INTEGER JPTR,MSIGN,NVEC,J
      DOUBLE PRECISION DRES,DIGIT



!  Current character
      JPTR=NSTRT

!  Set defaults
      DRES=0D0
      MSIGN=1

!  Look for sign
 100  CONTINUE
      CALL sla__IDCHI(STRING,JPTR,NVEC,DIGIT)
      GO TO ( 400, 100,  300,  200, 9110, 9100, 9110),NVEC
!             0-9   SP     +     -     ,   ELSE   END

!  Negative
 200  CONTINUE
      MSIGN=-1

!  Look for first decimal
 300  CONTINUE
      CALL sla__IDCHI(STRING,JPTR,NVEC,DIGIT)
      GO TO ( 400, 300, 9200, 9200, 9200, 9200, 9210),NVEC
!             0-9   SP     +     -     ,   ELSE   END

!  Accept decimals
 400  CONTINUE
      DRES=DRES*1D1+DIGIT

!  Test for overflow
      IF (DRES.GT.BIG) GO TO 9200

!  Look for subsequent decimals
      CALL sla__IDCHI(STRING,JPTR,NVEC,DIGIT)
      GO TO ( 400, 1610, 1600, 1600, 1600, 1600, 1610),NVEC
!             0-9   SP     +     -     ,   ELSE   END

!  Get result & status
 1600 CONTINUE
      JPTR=JPTR-1
 1610 CONTINUE
      J=0
      IF (MSIGN.EQ.1) GO TO 1620
      J=-1
      DRES=-DRES
 1620 CONTINUE
      IRESLT=NINT(DRES)

!  Skip to end of field
 1630 CONTINUE
      CALL sla__IDCHI(STRING,JPTR,NVEC,DIGIT)
      GO TO (1720, 1630, 1720, 1720, 9900, 1720, 9900),NVEC
!             0-9   SP     +     -     ,   ELSE   END

 1720 CONTINUE
      JPTR=JPTR-1
      GO TO 9900

!  Exits

!  Null field
 9100 CONTINUE
      JPTR=JPTR-1
 9110 CONTINUE
      J=1
      GO TO 9900

!  Errors
 9200 CONTINUE
      JPTR=JPTR-1
 9210 CONTINUE
      J=2

!  Return
 9900 CONTINUE
      NSTRT=JPTR
      JFLAG=J

      END
      SUBROUTINE sla_INVF (FWDS,BKWDS,J)
!+
!     - - - - -
!      I N V F
!     - - - - -
!
!  Invert a linear model of the type produced by the
!  sla_FITXY routine.
!
!  Given:
!     FWDS    d(6)      model coefficients
!
!  Returned:
!     BKWDS   d(6)      inverse model
!     J        i        status:  0 = OK, -1 = no inverse
!
!  The models relate two sets of [X,Y] coordinates as follows.
!  Naming the elements of FWDS:
!
!     FWDS(1) = A
!     FWDS(2) = B
!     FWDS(3) = C
!     FWDS(4) = D
!     FWDS(5) = E
!     FWDS(6) = F
!
!  where two sets of coordinates [X1,Y1] and [X2,Y1] are related
!  thus:
!
!     X2 = A + B*X1 + C*Y1
!     Y2 = D + E*X1 + F*Y1
!
!  the present routine generates a new set of coefficients:
!
!     BKWDS(1) = P
!     BKWDS(2) = Q
!     BKWDS(3) = R
!     BKWDS(4) = S
!     BKWDS(5) = T
!     BKWDS(6) = U
!
!  such that:
!
!     X1 = P + Q*X2 + R*Y2
!     Y1 = S + T*X2 + U*Y2
!
!  Two successive calls to sla_INVF will thus deliver a set
!  of coefficients equal to the starting values.
!
!  To comply with the ANSI Fortran standard, FWDS and BKWDS must
!  not be the same array, even though the routine is coded to
!  work on the VAX and most other computers even if this rule
!  is violated.
!
!  See also sla_FITXY, sla_PXY, sla_XY2XY, sla_DCMPF
!
!  P.T.Wallace   Starlink   11 April 1990
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION FWDS(6),BKWDS(6)
      INTEGER J

      DOUBLE PRECISION A,B,C,D,E,F,DET



      A=FWDS(1)
      B=FWDS(2)
      C=FWDS(3)
      D=FWDS(4)
      E=FWDS(5)
      F=FWDS(6)
      DET=B*F-C*E
      IF (DET.NE.0D0) THEN
         BKWDS(1)=(C*D-A*F)/DET
         BKWDS(2)=F/DET
         BKWDS(3)=-C/DET
         BKWDS(4)=(A*E-B*D)/DET
         BKWDS(5)=-E/DET
         BKWDS(6)=B/DET
         J=0
      ELSE
         J=-1
      END IF

      END
      SUBROUTINE sla_KBJ (JB, E, K, J)
!+
!     - - - -
!      K B J
!     - - - -
!
!  Select epoch prefix 'B' or 'J'
!
!  Given:
!     JB     int     sla_DBJIN prefix status:  0=none, 1='B', 2='J'
!     E      dp      epoch - Besselian or Julian
!
!  Returned:
!     K      char    'B' or 'J'
!     J      int     status:  0=OK
!
!  If JB=0, B is assumed for E < 1984D0, otherwise J.
!
!  P.T.Wallace   Starlink   31 July 1989
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER JB
      DOUBLE PRECISION E
      CHARACTER K*(*)
      INTEGER J

!  Preset status
      J=0

!  If prefix given expressly, use it
      IF (JB.EQ.1) THEN
         K='B'
      ELSE IF (JB.EQ.2) THEN
         K='J'

!  If no prefix, examine the epoch
      ELSE IF (JB.EQ.0) THEN

!     If epoch is pre-1984.0, assume Besselian;  otherwise Julian
         IF (E.LT.1984D0) THEN
            K='B'
         ELSE
            K='J'
         END IF

!  If illegal prefix, return error status
      ELSE
         K=' '
         J=1
      END IF

      END
      SUBROUTINE sla_M2AV (RMAT, AXVEC)
!+
!     - - - - -
!      M 2 A V
!     - - - - -
!
!  From a rotation matrix, determine the corresponding axial vector
!  (single precision)
!
!  A rotation matrix describes a rotation about some arbitrary axis.
!  The axis is called the Euler axis, and the angle through which the
!  reference frame rotates is called the Euler angle.  The axial
!  vector returned by this routine has the same direction as the
!  Euler axis, and its magnitude is the Euler angle in radians.  (The
!  magnitude and direction can be separated by means of the routine
!  sla_VN.)
!
!  Given:
!    RMAT   r(3,3)   rotation matrix
!
!  Returned:
!    AXVEC  r(3)     axial vector (radians)
!
!  The reference frame rotates clockwise as seen looking along
!  the axial vector from the origin.
!
!  If RMAT is null, so is the result.
!
!  P.T.Wallace   Starlink   11 April 1990
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL RMAT(3,3),AXVEC(3)

      REAL X,Y,Z,S2,C2,PHI,F



      X = RMAT(2,3)-RMAT(3,2)
      Y = RMAT(3,1)-RMAT(1,3)
      Z = RMAT(1,2)-RMAT(2,1)
      S2 = SQRT(X*X+Y*Y+Z*Z)
      IF (S2.NE.0.0) THEN
         C2 = (RMAT(1,1)+RMAT(2,2)+RMAT(3,3)-1.0)
         PHI = ATAN2(S2/2.0,C2/2.0)
         F = PHI/S2
         AXVEC(1) = X*F
         AXVEC(2) = Y*F
         AXVEC(3) = Z*F
      ELSE
         AXVEC(1) = 0.0
         AXVEC(2) = 0.0
         AXVEC(3) = 0.0
      END IF

      END
      SUBROUTINE sla_MAP (RM, DM, PR, PD, PX, RV, EQ, DATE, RA, DA)
!+
!     - - - -
!      M A P
!     - - - -
!
!  Transform star RA,Dec from mean place to geocentric apparent
!
!  The reference frames and timescales used are post IAU 1976.
!
!  References:
!     1984 Astronomical Almanac, pp B39-B41.
!     (also Lederle & Schwan, Astron. Astrophys. 134,
!      1-6, 1984)
!
!  Given:
!     RM,DM    dp     mean RA,Dec (rad)
!     PR,PD    dp     proper motions:  RA,Dec changes per Julian year
!     PX       dp     parallax (arcsec)
!     RV       dp     radial velocity (km/sec, +ve if receding)
!     EQ       dp     epoch and equinox of star data (Julian)
!     DATE     dp     TDB for apparent place (JD-2400000.5)
!
!  Returned:
!     RA,DA    dp     apparent RA,Dec (rad)
!
!  Called:
!     sla_MAPPA       star-independent parameters
!     sla_MAPQK       quick mean to apparent
!
!  Notes:
!
!  1)  EQ is the Julian epoch specifying both the reference frame and
!      the epoch of the position - usually 2000.  For positions where
!      the epoch and equinox are different, use the routine sla_PM to
!      apply proper motion corrections before using this routine.
!
!  2)  The distinction between the required TDB and TT is always
!      negligible.  Moreover, for all but the most critical
!      applications UTC is adequate.
!
!  3)  The proper motions in RA are dRA/dt rather than cos(Dec)*dRA/dt.
!
!  4)  This routine may be wasteful for some applications because it
!      recomputes the Earth position/velocity and the precession-
!      nutation matrix each time, and because it allows for parallax
!      and proper motion.  Where multiple transformations are to be
!      carried out for one epoch, a faster method is to call the
!      sla_MAPPA routine once and then either the sla_MAPQK routine
!      (which includes parallax and proper motion) or sla_MAPQKZ (which
!      assumes zero parallax and proper motion).
!
!  5)  The accuracy is sub-milliarcsecond, limited by the
!      precession-nutation model (IAU 1976 precession, Shirai &
!      Fukushima 2001 forced nutation and precession corrections).
!
!  6)  The accuracy is further limited by the routine sla_EVP, called
!      by sla_MAPPA, which computes the Earth position and velocity
!      using the methods of Stumpff.  The maximum error is about
!      0.3 mas.
!
!  P.T.Wallace   Starlink   17 September 2001
!
!  Copyright (C) 2001 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RM,DM,PR,PD,PX,RV,EQ,DATE,RA,DA

      DOUBLE PRECISION AMPRMS(21)



!  Star-independent parameters
      CALL sla_MAPPA(EQ,DATE,AMPRMS)

!  Mean to apparent
      CALL sla_MAPQK(RM,DM,PR,PD,PX,RV,AMPRMS,RA,DA)

      END
      SUBROUTINE sla_MAPPA (EQ, DATE, AMPRMS)
!+
!     - - - - - -
!      M A P P A
!     - - - - - -
!
!  Compute star-independent parameters in preparation for
!  conversions between mean place and geocentric apparent place.
!
!  The parameters produced by this routine are required in the
!  parallax, light deflection, aberration, and precession/nutation
!  parts of the mean/apparent transformations.
!
!  The reference frames and timescales used are post IAU 1976.
!
!  Given:
!     EQ       d      epoch of mean equinox to be used (Julian)
!     DATE     d      TDB (JD-2400000.5)
!
!  Returned:
!     AMPRMS   d(21)  star-independent mean-to-apparent parameters:
!
!       (1)      time interval for proper motion (Julian years)
!       (2-4)    barycentric position of the Earth (AU)
!       (5-7)    heliocentric direction of the Earth (unit vector)
!       (8)      (grav rad Sun)*2/(Sun-Earth distance)
!       (9-11)   ABV: barycentric Earth velocity in units of c
!       (12)     sqrt(1-v**2) where v=modulus(ABV)
!       (13-21)  precession/nutation (3,3) matrix
!
!  References:
!     1984 Astronomical Almanac, pp B39-B41.
!     (also Lederle & Schwan, Astron. Astrophys. 134,
!      1-6, 1984)
!
!  Notes:
!
!  1)  For DATE, the distinction between the required TDB and TT
!      is always negligible.  Moreover, for all but the most
!      critical applications UTC is adequate.
!
!  2)  The vectors AMPRMS(2-4) and AMPRMS(5-7) are referred to
!      the mean equinox and equator of epoch EQ.
!
!  3)  The parameters AMPRMS produced by this routine are used by
!      sla_AMPQK, sla_MAPQK and sla_MAPQKZ.
!
!  4)  The accuracy is sub-milliarcsecond, limited by the
!      precession-nutation model (IAU 1976 precession, Shirai &
!      Fukushima 2001 forced nutation and precession corrections).
!
!  5)  A further limit to the accuracy of routines using the parameter
!      array AMPRMS is imposed by the routine sla_EVP, used here to
!      compute the Earth position and velocity by the methods of
!      Stumpff.  The maximum error in the resulting aberration
!      corrections is about 0.3 milliarcsecond.
!
!  Called:
!     sla_EPJ         MDJ to Julian epoch
!     sla_EVP         earth position & velocity
!     sla_DVN         normalize vector
!     sla_PRENUT      precession/nutation matrix
!
!  P.T.Wallace   Starlink   24 October 2003
!
!  Copyright (C) 2003 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION EQ,DATE,AMPRMS(21)

!  Light time for 1 AU (sec)
      DOUBLE PRECISION CR
      PARAMETER (CR=499.004782D0)

!  Gravitational radius of the Sun x 2 (2*mu/c**2, AU)
      DOUBLE PRECISION GR2
      PARAMETER (GR2=2D0*9.87063D-9)

      INTEGER I

      DOUBLE PRECISION EBD(3),EHD(3),EH(3),E,VN(3),VM

      DOUBLE PRECISION sla_EPJ



!  Time interval for proper motion correction
      AMPRMS(1) = sla_EPJ(DATE)-EQ

!  Get Earth barycentric and heliocentric position and velocity
      CALL sla_EVP(DATE,EQ,EBD,AMPRMS(2),EHD,EH)

!  Heliocentric direction of earth (normalized) and modulus
      CALL sla_DVN(EH,AMPRMS(5),E)

!  Light deflection parameter
      AMPRMS(8) = GR2/E

!  Aberration parameters
      DO I=1,3
         AMPRMS(I+8) = EBD(I)*CR
      END DO
      CALL sla_DVN(AMPRMS(9),VN,VM)
      AMPRMS(12) = SQRT(1D0-VM*VM)

!  Precession/nutation matrix
      CALL sla_PRENUT(EQ,DATE,AMPRMS(13))

      END
      SUBROUTINE sla_MAPQK (RM, DM, PR, PD, PX, RV, AMPRMS, RA, DA)
!+
!     - - - - - -
!      M A P Q K
!     - - - - - -
!
!  Quick mean to apparent place:  transform a star RA,Dec from
!  mean place to geocentric apparent place, given the
!  star-independent parameters.
!
!  Use of this routine is appropriate when efficiency is important
!  and where many star positions, all referred to the same equator
!  and equinox, are to be transformed for one epoch.  The
!  star-independent parameters can be obtained by calling the
!  sla_MAPPA routine.
!
!  If the parallax and proper motions are zero the sla_MAPQKZ
!  routine can be used instead.
!
!  The reference frames and timescales used are post IAU 1976.
!
!  Given:
!     RM,DM    d      mean RA,Dec (rad)
!     PR,PD    d      proper motions:  RA,Dec changes per Julian year
!     PX       d      parallax (arcsec)
!     RV       d      radial velocity (km/sec, +ve if receding)
!
!     AMPRMS   d(21)  star-independent mean-to-apparent parameters:
!
!       (1)      time interval for proper motion (Julian years)
!       (2-4)    barycentric position of the Earth (AU)
!       (5-7)    heliocentric direction of the Earth (unit vector)
!       (8)      (grav rad Sun)*2/(Sun-Earth distance)
!       (9-11)   barycentric Earth velocity in units of c
!       (12)     sqrt(1-v**2) where v=modulus(ABV)
!       (13-21)  precession/nutation (3,3) matrix
!
!  Returned:
!     RA,DA    d      apparent RA,Dec (rad)
!
!  References:
!     1984 Astronomical Almanac, pp B39-B41.
!     (also Lederle & Schwan, Astron. Astrophys. 134,
!      1-6, 1984)
!
!  Notes:
!
!  1)  The vectors AMPRMS(2-4) and AMPRMS(5-7) are referred to
!      the mean equinox and equator of epoch EQ.
!
!  2)  Strictly speaking, the routine is not valid for solar-system
!      sources, though the error will usually be extremely small.
!      However, to prevent gross errors in the case where the
!      position of the Sun is specified, the gravitational
!      deflection term is restrained within about 920 arcsec of the
!      centre of the Sun's disc.  The term has a maximum value of
!      about 1.85 arcsec at this radius, and decreases to zero as
!      the centre of the disc is approached.
!
!  Called:
!     sla_DCS2C       spherical to Cartesian
!     sla_DVDV        dot product
!     sla_DMXV        matrix x vector
!     sla_DCC2S       Cartesian to spherical
!     sla_DRANRM      normalize angle 0-2Pi
!
!  P.T.Wallace   Starlink   15 January 2000
!
!  Copyright (C) 2000 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RM,DM,PR,PD,PX,RV,AMPRMS(21),RA,DA

!  Arc seconds to radians
      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

!  Km/s to AU/year
      DOUBLE PRECISION VF
      PARAMETER (VF=0.21094502D0)

      INTEGER I

      DOUBLE PRECISION PMT,GR2E,AB1,EB(3),EHN(3),ABV(3), &
                      Q(3),PXR,W,EM(3),P(3),PN(3),PDE,PDEP1, &
                      P1(3),P1DV,P2(3),P3(3)

      DOUBLE PRECISION sla_DVDV,sla_DRANRM



!  Unpack scalar and vector parameters
      PMT = AMPRMS(1)
      GR2E = AMPRMS(8)
      AB1 = AMPRMS(12)
      DO I=1,3
         EB(I) = AMPRMS(I+1)
         EHN(I) = AMPRMS(I+4)
         ABV(I) = AMPRMS(I+8)
      END DO

!  Spherical to x,y,z
      CALL sla_DCS2C(RM,DM,Q)

!  Space motion (radians per year)
      PXR = PX*AS2R
      W = VF*RV*PXR
      EM(1) = -PR*Q(2)-PD*COS(RM)*SIN(DM)+W*Q(1)
      EM(2) =  PR*Q(1)-PD*SIN(RM)*SIN(DM)+W*Q(2)
      EM(3) =          PD*COS(DM)        +W*Q(3)

!  Geocentric direction of star (normalized)
      DO I=1,3
         P(I) = Q(I)+PMT*EM(I)-PXR*EB(I)
      END DO
      CALL sla_DVN(P,PN,W)

!  Light deflection (restrained within the Sun's disc)
      PDE = sla_DVDV(PN,EHN)
      PDEP1 = PDE+1D0
      W = GR2E/MAX(PDEP1,1D-5)
      DO I=1,3
         P1(I) = PN(I)+W*(EHN(I)-PDE*PN(I))
      END DO

!  Aberration (normalization omitted)
      P1DV = sla_DVDV(P1,ABV)
      W = 1D0+P1DV/(AB1+1D0)
      DO I=1,3
         P2(I) = AB1*P1(I)+W*ABV(I)
      END DO

!  Precession and nutation
      CALL sla_DMXV(AMPRMS(13),P2,P3)

!  Geocentric apparent RA,Dec
      CALL sla_DCC2S(P3,RA,DA)
      RA = sla_DRANRM(RA)

      END
      SUBROUTINE sla_MAPQKZ (RM, DM, AMPRMS, RA, DA)
!+
!     - - - - - - -
!      M A P Q K Z
!     - - - - - - -
!
!  Quick mean to apparent place:  transform a star RA,Dec from
!  mean place to geocentric apparent place, given the
!  star-independent parameters, and assuming zero parallax
!  and proper motion.
!
!  Use of this routine is appropriate when efficiency is important
!  and where many star positions, all with parallax and proper
!  motion either zero or already allowed for, and all referred to
!  the same equator and equinox, are to be transformed for one
!  epoch.  The star-independent parameters can be obtained by
!  calling the sla_MAPPA routine.
!
!  The corresponding routine for the case of non-zero parallax
!  and proper motion is sla_MAPQK.
!
!  The reference frames and timescales used are post IAU 1976.
!
!  Given:
!     RM,DM    d      mean RA,Dec (rad)
!     AMPRMS   d(21)  star-independent mean-to-apparent parameters:
!
!       (1-4)    not used
!       (5-7)    heliocentric direction of the Earth (unit vector)
!       (8)      (grav rad Sun)*2/(Sun-Earth distance)
!       (9-11)   ABV: barycentric Earth velocity in units of c
!       (12)     sqrt(1-v**2) where v=modulus(ABV)
!       (13-21)  precession/nutation (3,3) matrix
!
!  Returned:
!     RA,DA    d      apparent RA,Dec (rad)
!
!  References:
!     1984 Astronomical Almanac, pp B39-B41.
!     (also Lederle & Schwan, Astron. Astrophys. 134,
!      1-6, 1984)
!
!  Notes:
!
!  1)  The vectors AMPRMS(2-4) and AMPRMS(5-7) are referred to the
!      mean equinox and equator of epoch EQ.
!
!  2)  Strictly speaking, the routine is not valid for solar-system
!      sources, though the error will usually be extremely small.
!      However, to prevent gross errors in the case where the
!      position of the Sun is specified, the gravitational
!      deflection term is restrained within about 920 arcsec of the
!      centre of the Sun's disc.  The term has a maximum value of
!      about 1.85 arcsec at this radius, and decreases to zero as
!      the centre of the disc is approached.
!
!  Called:  sla_DCS2C, sla_DVDV, sla_DMXV, sla_DCC2S, sla_DRANRM
!
!  P.T.Wallace   Starlink   18 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RM,DM,AMPRMS(21),RA,DA

      INTEGER I

      DOUBLE PRECISION GR2E,AB1,EHN(3),ABV(3), &
                      P(3),PDE,PDEP1,W,P1(3),P1DV, &
                      P1DVP1,P2(3),P3(3)

      DOUBLE PRECISION sla_DVDV,sla_DRANRM




!  Unpack scalar and vector parameters
      GR2E = AMPRMS(8)
      AB1 = AMPRMS(12)
      DO I=1,3
         EHN(I) = AMPRMS(I+4)
         ABV(I) = AMPRMS(I+8)
      END DO

!  Spherical to x,y,z
      CALL sla_DCS2C(RM,DM,P)

!  Light deflection
      PDE = sla_DVDV(P,EHN)
      PDEP1 = PDE+1D0
      W = GR2E/MAX(PDEP1,1D-5)
      DO I=1,3
         P1(I) = P(I)+W*(EHN(I)-PDE*P(I))
      END DO

!  Aberration
      P1DV = sla_DVDV(P1,ABV)
      P1DVP1 = P1DV+1D0
      W = 1D0+P1DV/(AB1+1D0)
      DO I=1,3
         P2(I) = (AB1*P1(I)+W*ABV(I))/P1DVP1
      END DO

!  Precession and nutation
      CALL sla_DMXV(AMPRMS(13),P2,P3)

!  Geocentric apparent RA,Dec
      CALL sla_DCC2S(P3,RA,DA)
      RA = sla_DRANRM(RA)

      END
      SUBROUTINE sla_MOON (IY, ID, FD, PV)
!+
!     - - - - -
!      M O O N
!     - - - - -
!
!  Approximate geocentric position and velocity of the Moon
!  (single precision).
!
!  Given:
!     IY       i       year
!     ID       i       day in year (1 = Jan 1st)
!     FD       r       fraction of day
!
!  Returned:
!     PV       r(6)    Moon position & velocity vector
!
!  Notes:
!
!  1  The date and time is TDB (loosely ET) in a Julian calendar
!     which has been aligned to the ordinary Gregorian
!     calendar for the interval 1900 March 1 to 2100 February 28.
!     The year and day can be obtained by calling sla_CALYD or
!     sla_CLYD.
!
!  2  The Moon 6-vector is Moon centre relative to Earth centre,
!     mean equator and equinox of date.  Position part, PV(1-3),
!     is in AU;  velocity part, PV(4-6), is in AU/sec.
!
!  3  The position is accurate to better than 0.5 arcminute
!     in direction and 1000 km in distance.  The velocity
!     is accurate to better than 0.5"/hour in direction and
!     4 m/s in distance.  (RMS figures with respect to JPL DE200
!     for the interval 1960-2025 are 14 arcsec and 0.2 arcsec/hour in
!     longitude, 9 arcsec and 0.2 arcsec/hour in latitude, 350 km and
!     2 m/s in distance.)  Note that the distance accuracy is
!     comparatively poor because this routine is principally intended
!     for computing topocentric direction.
!
!  4  This routine is only a partial implementation of the original
!     Meeus algorithm (reference below), which offers 4 times the
!     accuracy in direction and 30 times the accuracy in distance
!     when fully implemented (as it is in sla_DMOON).
!
!  Reference:
!     Meeus, l'Astronomie, June 1984, p348.
!
!  Called:  sla_CS2C6
!
!  P.T.Wallace   Starlink   8 December 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER IY,ID
      REAL FD,PV(6)

      INTEGER ITP(4,4),ITL(4,39),ITB(4,29),I,IY4,N
      REAL D2R,RATCON,ERADAU
      REAL ELP0,ELP1,ELP1I,ELP1F
      REAL EM0,EM1,EM1F
      REAL EMP0,EMP1,EMP1I,EMP1F
      REAL D0,D1,D1I,D1F
      REAL F0,F1,F1I,F1F
      REAL TL(39)
      REAL TB(29)
      REAL TP(4)
      REAL YI,YF,T,ELP,EM,EMP,D,F,EL,ELD,COEFF,CEM,CEMP
      REAL CD,CF,THETA,THETAD,B,BD,P,PD,SP,R,RD
      REAL V(6),EPS,SINEPS,COSEPS

!  Degrees to radians
      PARAMETER (D2R=1.745329252E-2)

!  Rate conversion factor:  D2R**2/(86400*365.25)
      PARAMETER (RATCON=9.652743551E-12)

!  Earth radius in AU:  6378.137/149597870
      PARAMETER (ERADAU=4.2635212653763E-5)

!
!  Coefficients for fundamental arguments
!
!  Fixed term (deg), term in T (deg & whole revs + fraction per year)
!
!  Moon's mean longitude
      DATA ELP0,ELP1,ELP1I,ELP1F / &
                 270.434164, 4812.678831, 4680., 132.678831 /
!
!  Sun's mean anomaly
      DATA EM0,EM1,EM1F / &
                 358.475833,  359.990498,        359.990498 /
!
!  Moon's mean anomaly
      DATA EMP0,EMP1,EMP1I,EMP1F / &
                 296.104608, 4771.988491, 4680.,  91.988491 /
!
!  Moon's mean elongation
      DATA D0,D1,D1I,D1F / &
                 350.737486,  4452.671142, 4320., 132.671142 /
!
!  Mean distance of the Moon from its ascending node
      DATA F0,F1,F1I,F1F / &
                  11.250889, 4832.020251, 4680., 152.020251 /

!
!  Coefficients for Moon position
!
!   T(N)       = coefficient of term (deg)
!   IT(N,1-4)  = coefficients of M, M', D, F in argument
!
!  Longitude
!                                         M   M'  D   F
      DATA TL( 1)/            +6.288750                     /, &
          (ITL(I, 1),I=1,4)/             0, +1,  0,  0     /
      DATA TL( 2)/            +1.274018                     /, &
          (ITL(I, 2),I=1,4)/             0, -1, +2,  0     /
      DATA TL( 3)/            +0.658309                     /, &
          (ITL(I, 3),I=1,4)/             0,  0, +2,  0     /
      DATA TL( 4)/            +0.213616                     /, &
          (ITL(I, 4),I=1,4)/             0, +2,  0,  0     /
      DATA TL( 5)/            -0.185596                     /, &
          (ITL(I, 5),I=1,4)/            +1,  0,  0,  0     /
      DATA TL( 6)/            -0.114336                     /, &
          (ITL(I, 6),I=1,4)/             0,  0,  0, +2     /
      DATA TL( 7)/            +0.058793                     /, &
          (ITL(I, 7),I=1,4)/             0, -2, +2,  0     /
      DATA TL( 8)/            +0.057212                     /, &
          (ITL(I, 8),I=1,4)/            -1, -1, +2,  0     /
      DATA TL( 9)/            +0.053320                     /, &
          (ITL(I, 9),I=1,4)/             0, +1, +2,  0     /
      DATA TL(10)/            +0.045874                     /, &
          (ITL(I,10),I=1,4)/            -1,  0, +2,  0     /
      DATA TL(11)/            +0.041024                     /, &
          (ITL(I,11),I=1,4)/            -1, +1,  0,  0     /
      DATA TL(12)/            -0.034718                     /, &
          (ITL(I,12),I=1,4)/             0,  0, +1,  0     /
      DATA TL(13)/            -0.030465                     /, &
          (ITL(I,13),I=1,4)/            +1, +1,  0,  0     /
      DATA TL(14)/            +0.015326                     /, &
          (ITL(I,14),I=1,4)/             0,  0, +2, -2     /
      DATA TL(15)/            -0.012528                     /, &
          (ITL(I,15),I=1,4)/             0, +1,  0, +2     /
      DATA TL(16)/            -0.010980                     /, &
          (ITL(I,16),I=1,4)/             0, -1,  0, +2     /
      DATA TL(17)/            +0.010674                     /, &
          (ITL(I,17),I=1,4)/             0, -1, +4,  0     /
      DATA TL(18)/            +0.010034                     /, &
          (ITL(I,18),I=1,4)/             0, +3,  0,  0     /
      DATA TL(19)/            +0.008548                     /, &
          (ITL(I,19),I=1,4)/             0, -2, +4,  0     /
      DATA TL(20)/            -0.007910                     /, &
          (ITL(I,20),I=1,4)/            +1, -1, +2,  0     /
      DATA TL(21)/            -0.006783                     /, &
          (ITL(I,21),I=1,4)/            +1,  0, +2,  0     /
      DATA TL(22)/            +0.005162                     /, &
          (ITL(I,22),I=1,4)/             0, +1, -1,  0     /
      DATA TL(23)/            +0.005000                     /, &
          (ITL(I,23),I=1,4)/            +1,  0, +1,  0     /
      DATA TL(24)/            +0.004049                     /, &
          (ITL(I,24),I=1,4)/            -1, +1, +2,  0     /
      DATA TL(25)/            +0.003996                     /, &
          (ITL(I,25),I=1,4)/             0, +2, +2,  0     /
      DATA TL(26)/            +0.003862                     /, &
          (ITL(I,26),I=1,4)/             0,  0, +4,  0     /
      DATA TL(27)/            +0.003665                     /, &
          (ITL(I,27),I=1,4)/             0, -3, +2,  0     /
      DATA TL(28)/            +0.002695                     /, &
          (ITL(I,28),I=1,4)/            -1, +2,  0,  0     /
      DATA TL(29)/            +0.002602                     /, &
          (ITL(I,29),I=1,4)/             0, +1, -2, -2     /
      DATA TL(30)/            +0.002396                     /, &
          (ITL(I,30),I=1,4)/            -1, -2, +2,  0     /
      DATA TL(31)/            -0.002349                     /, &
          (ITL(I,31),I=1,4)/             0, +1, +1,  0     /
      DATA TL(32)/            +0.002249                     /, &
          (ITL(I,32),I=1,4)/            -2,  0, +2,  0     /
      DATA TL(33)/            -0.002125                     /, &
          (ITL(I,33),I=1,4)/            +1, +2,  0,  0     /
      DATA TL(34)/            -0.002079                     /, &
          (ITL(I,34),I=1,4)/            +2,  0,  0,  0     /
      DATA TL(35)/            +0.002059                     /, &
          (ITL(I,35),I=1,4)/            -2, -1, +2,  0     /
      DATA TL(36)/            -0.001773                     /, &
          (ITL(I,36),I=1,4)/             0, +1, +2, -2     /
      DATA TL(37)/            -0.001595                     /, &
          (ITL(I,37),I=1,4)/             0,  0, +2, +2     /
      DATA TL(38)/            +0.001220                     /, &
          (ITL(I,38),I=1,4)/            -1, -1, +4,  0     /
      DATA TL(39)/            -0.001110                     /, &
          (ITL(I,39),I=1,4)/             0, +2,  0, +2     /
!
!  Latitude
!                                         M   M'  D   F
      DATA TB( 1)/            +5.128189                     /, &
          (ITB(I, 1),I=1,4)/             0,  0,  0, +1     /
      DATA TB( 2)/            +0.280606                     /, &
          (ITB(I, 2),I=1,4)/             0, +1,  0, +1     /
      DATA TB( 3)/            +0.277693                     /, &
          (ITB(I, 3),I=1,4)/             0, +1,  0, -1     /
      DATA TB( 4)/            +0.173238                     /, &
          (ITB(I, 4),I=1,4)/             0,  0, +2, -1     /
      DATA TB( 5)/            +0.055413                     /, &
          (ITB(I, 5),I=1,4)/             0, -1, +2, +1     /
      DATA TB( 6)/            +0.046272                     /, &
          (ITB(I, 6),I=1,4)/             0, -1, +2, -1     /
      DATA TB( 7)/            +0.032573                     /, &
          (ITB(I, 7),I=1,4)/             0,  0, +2, +1     /
      DATA TB( 8)/            +0.017198                     /, &
          (ITB(I, 8),I=1,4)/             0, +2,  0, +1     /
      DATA TB( 9)/            +0.009267                     /, &
          (ITB(I, 9),I=1,4)/             0, +1, +2, -1     /
      DATA TB(10)/            +0.008823                     /, &
          (ITB(I,10),I=1,4)/             0, +2,  0, -1     /
      DATA TB(11)/            +0.008247                     /, &
          (ITB(I,11),I=1,4)/            -1,  0, +2, -1     /
      DATA TB(12)/            +0.004323                     /, &
          (ITB(I,12),I=1,4)/             0, -2, +2, -1     /
      DATA TB(13)/            +0.004200                     /, &
          (ITB(I,13),I=1,4)/             0, +1, +2, +1     /
      DATA TB(14)/            +0.003372                     /, &
          (ITB(I,14),I=1,4)/            -1,  0, -2, +1     /
      DATA TB(15)/            +0.002472                     /, &
          (ITB(I,15),I=1,4)/            -1, -1, +2, +1     /
      DATA TB(16)/            +0.002222                     /, &
          (ITB(I,16),I=1,4)/            -1,  0, +2, +1     /
      DATA TB(17)/            +0.002072                     /, &
          (ITB(I,17),I=1,4)/            -1, -1, +2, -1     /
      DATA TB(18)/            +0.001877                     /, &
          (ITB(I,18),I=1,4)/            -1, +1,  0, +1     /
      DATA TB(19)/            +0.001828                     /, &
          (ITB(I,19),I=1,4)/             0, -1, +4, -1     /
      DATA TB(20)/            -0.001803                     /, &
          (ITB(I,20),I=1,4)/            +1,  0,  0, +1     /
      DATA TB(21)/            -0.001750                     /, &
          (ITB(I,21),I=1,4)/             0,  0,  0, +3     /
      DATA TB(22)/            +0.001570                     /, &
          (ITB(I,22),I=1,4)/            -1, +1,  0, -1     /
      DATA TB(23)/            -0.001487                     /, &
          (ITB(I,23),I=1,4)/             0,  0, +1, +1     /
      DATA TB(24)/            -0.001481                     /, &
          (ITB(I,24),I=1,4)/            +1, +1,  0, +1     /
      DATA TB(25)/            +0.001417                     /, &
          (ITB(I,25),I=1,4)/            -1, -1,  0, +1     /
      DATA TB(26)/            +0.001350                     /, &
          (ITB(I,26),I=1,4)/            -1,  0,  0, +1     /
      DATA TB(27)/            +0.001330                     /, &
          (ITB(I,27),I=1,4)/             0,  0, -1, +1     /
      DATA TB(28)/            +0.001106                     /, &
          (ITB(I,28),I=1,4)/             0, +3,  0, +1     /
      DATA TB(29)/            +0.001020                     /, &
          (ITB(I,29),I=1,4)/             0,  0, +4, -1     /
!
!  Parallax
!                                         M   M'  D   F
      DATA TP( 1)/            +0.051818                     /, &
          (ITP(I, 1),I=1,4)/             0, +1,  0,  0     /
      DATA TP( 2)/            +0.009531                     /, &
          (ITP(I, 2),I=1,4)/             0, -1, +2,  0     /
      DATA TP( 3)/            +0.007843                     /, &
          (ITP(I, 3),I=1,4)/             0,  0, +2,  0     /
      DATA TP( 4)/            +0.002824                     /, &
          (ITP(I, 4),I=1,4)/             0, +2,  0,  0     /



!  Whole years & fraction of year, and years since J1900.0
      YI=FLOAT(IY-1900)
      IY4=MOD(MOD(IY,4)+4,4)
      YF=(FLOAT(4*(ID-1/(IY4+1))-IY4-2)+4.0*FD)/1461.0
      T=YI+YF

!  Moon's mean longitude
      ELP=D2R*MOD(ELP0+ELP1I*YF+ELP1F*T,360.0)

!  Sun's mean anomaly
      EM=D2R*MOD(EM0+EM1F*T,360.0)

!  Moon's mean anomaly
      EMP=D2R*MOD(EMP0+EMP1I*YF+EMP1F*T,360.0)

!  Moon's mean elongation
      D=D2R*MOD(D0+D1I*YF+D1F*T,360.0)

!  Mean distance of the moon from its ascending node
      F=D2R*MOD(F0+F1I*YF+F1F*T,360.0)

!  Longitude
      EL=0.0
      ELD=0.0
      DO N=39,1,-1
         COEFF=TL(N)
         CEM=FLOAT(ITL(1,N))
         CEMP=FLOAT(ITL(2,N))
         CD=FLOAT(ITL(3,N))
         CF=FLOAT(ITL(4,N))
         THETA=CEM*EM+CEMP*EMP+CD*D+CF*F
         THETAD=CEM*EM1+CEMP*EMP1+CD*D1+CF*F1
         EL=EL+COEFF*SIN(THETA)
         ELD=ELD+COEFF*COS(THETA)*THETAD
      END DO
      EL=EL*D2R+ELP
      ELD=RATCON*(ELD+ELP1/D2R)

!  Latitude
      B=0.0
      BD=0.0
      DO N=29,1,-1
         COEFF=TB(N)
         CEM=FLOAT(ITB(1,N))
         CEMP=FLOAT(ITB(2,N))
         CD=FLOAT(ITB(3,N))
         CF=FLOAT(ITB(4,N))
         THETA=CEM*EM+CEMP*EMP+CD*D+CF*F
         THETAD=CEM*EM1+CEMP*EMP1+CD*D1+CF*F1
         B=B+COEFF*SIN(THETA)
         BD=BD+COEFF*COS(THETA)*THETAD
      END DO
      B=B*D2R
      BD=RATCON*BD

!  Parallax
      P=0.0
      PD=0.0
      DO N=4,1,-1
         COEFF=TP(N)
         CEM=FLOAT(ITP(1,N))
         CEMP=FLOAT(ITP(2,N))
         CD=FLOAT(ITP(3,N))
         CF=FLOAT(ITP(4,N))
         THETA=CEM*EM+CEMP*EMP+CD*D+CF*F
         THETAD=CEM*EM1+CEMP*EMP1+CD*D1+CF*F1
         P=P+COEFF*COS(THETA)
         PD=PD-COEFF*SIN(THETA)*THETAD
      END DO
      P=(P+0.950724)*D2R
      PD=RATCON*PD

!  Transform parallax to distance (AU, AU/sec)
      SP=SIN(P)
      R=ERADAU/SP
      RD=-R*PD/SP

!  Longitude, latitude to x,y,z (AU)
      CALL sla_CS2C6(EL,B,R,ELD,BD,RD,V)

!  Mean obliquity
      EPS=D2R*(23.45229-0.00013*T)
      SINEPS=SIN(EPS)
      COSEPS=COS(EPS)

!  Rotate Moon position and velocity into equatorial system
      PV(1)=V(1)
      PV(2)=V(2)*COSEPS-V(3)*SINEPS
      PV(3)=V(2)*SINEPS+V(3)*COSEPS
      PV(4)=V(4)
      PV(5)=V(5)*COSEPS-V(6)*SINEPS
      PV(6)=V(5)*SINEPS+V(6)*COSEPS

      END
      SUBROUTINE sla_MXM (A, B, C)
!+
!     - - - -
!      M X M
!     - - - -
!
!  Product of two 3x3 matrices:
!      matrix C  =  matrix A  x  matrix B
!
!  (single precision)
!
!  Given:
!      A      real(3,3)        matrix
!      B      real(3,3)        matrix
!
!  Returned:
!      C      real(3,3)        matrix result
!
!  To comply with the ANSI Fortran 77 standard, A, B and C must
!  be different arrays.  However, the routine is coded so as to
!  work properly on the VAX and many other systems even if this
!  rule is violated.
!
!  P.T.Wallace   Starlink   5 April 1990
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL A(3,3),B(3,3),C(3,3)

      INTEGER I,J,K
      REAL W,WM(3,3)


!  Multiply into scratch matrix
      DO I=1,3
         DO J=1,3
            W=0.0
            DO K=1,3
               W=W+A(I,K)*B(K,J)
            END DO
            WM(I,J)=W
         END DO
      END DO

!  Return the result
      DO J=1,3
         DO I=1,3
            C(I,J)=WM(I,J)
         END DO
      END DO

      END
      SUBROUTINE sla_MXV (RM, VA, VB)
!+
!     - - - -
!      M X V
!     - - - -
!
!  Performs the 3-D forward unitary transformation:
!
!     vector VB = matrix RM * vector VA
!
!  (single precision)
!
!  Given:
!     RM       real(3,3)    matrix
!     VA       real(3)      vector
!
!  Returned:
!     VB       real(3)      result vector
!
!  P.T.Wallace   Starlink   March 1986
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL RM(3,3),VA(3),VB(3)

      INTEGER I,J
      REAL W,VW(3)


!  Matrix RM * vector VA -> vector VW
      DO J=1,3
         W=0.0
         DO I=1,3
            W=W+RM(J,I)*VA(I)
         END DO
         VW(J)=W
      END DO

!  Vector VW -> vector VB
      DO J=1,3
         VB(J)=VW(J)
      END DO

      END
      SUBROUTINE sla_NUT (DATE, RMATN)
!+
!     - - - -
!      N U T
!     - - - -
!
!  Form the matrix of nutation for a given date - Shirai & Fukushima
!  2001 theory (double precision)
!
!  Reference:
!     Shirai, T. & Fukushima, T., Astron.J. 121, 3270-3283 (2001).
!
!  Given:
!     DATE    d          TDB (loosely ET) as Modified Julian Date
!                                           (=JD-2400000.5)
!  Returned:
!     RMATN   d(3,3)     nutation matrix
!
!  The matrix is in the sense   V(true)  =  RMATN * V(mean)
!
!  Called:   sla_NUTC, sla_DEULER
!
!  P.T.Wallace   Starlink   17 September 2001
!
!  Copyright (C) 2001 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,RMATN(3,3)

      DOUBLE PRECISION DPSI,DEPS,EPS0



!  Nutation components and mean obliquity
      CALL sla_NUTC(DATE,DPSI,DEPS,EPS0)

!  Rotation matrix
      CALL sla_DEULER('XZX',EPS0,-DPSI,-(EPS0+DEPS),RMATN)

      END
      SUBROUTINE sla_NUTC (DATE, DPSI, DEPS, EPS0)
!+
!     - - - - -
!      N U T C
!     - - - - -
!
!  Nutation:  longitude & obliquity components and mean obliquity,
!  using the Shirai & Fukushima (2001) theory.
!
!  Given:
!     DATE        d    TDB (loosely ET) as Modified Julian Date
!                                            (JD-2400000.5)
!  Returned:
!     DPSI,DEPS   d    nutation in longitude,obliquity
!     EPS0        d    mean obliquity
!
!  Notes:
!
!  1  The routine predicts forced nutation (but not free core nutation)
!     plus corrections to the IAU 1976 precession model.
!
!  2  Earth attitude predictions made by combining the present nutation
!     model with IAU 1976 precession are accurate to 1 mas (with respect
!     to the ICRF) for a few decades around 2000.
!
!  3  The sla_NUTC80 routine is the equivalent of the present routine
!     but using the IAU 1980 nutation theory.  The older theory is less
!     accurate, leading to errors as large as 350 mas over the interval
!     1900-2100, mainly because of the error in the IAU 1976 precession.
!
!  References:
!
!     Shirai, T. & Fukushima, T., Astron.J. 121, 3270-3283 (2001).
!
!     Fukushima, T., 1991, Astron.Astrophys. 244, L11 (1991).
!
!     Simon, J. L., Bretagnon, P., Chapront, J., Chapront-Touze, M.,
!     Francou, G. & Laskar, J., Astron.Astrophys. 282, 663 (1994).
!
!  P.T.Wallace   Starlink   7 October 2001
!
!  Copyright (C) 2001 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,DPSI,DEPS,EPS0

!  Degrees to radians
      DOUBLE PRECISION DD2R
      PARAMETER (DD2R=1.745329251994329576923691D-2)

!  Arc seconds to radians
      DOUBLE PRECISION DAS2R
      PARAMETER (DAS2R=4.848136811095359935899141D-6)

!  Arc seconds in a full circle
      DOUBLE PRECISION TURNAS
      PARAMETER (TURNAS=1296000D0)

!  Reference epoch (J2000), MJD
      DOUBLE PRECISION DJM0
      PARAMETER (DJM0=51544.5D0 )

!  Days per Julian century
      DOUBLE PRECISION DJC
      PARAMETER (DJC=36525D0)

      INTEGER I,J
      DOUBLE PRECISION T,EL,ELP,F,D,OM,VE,MA,JU,SA,THETA,C,S,DP,DE

!  Number of terms in the nutation model
      INTEGER NTERMS
      PARAMETER (NTERMS=194)

!  The SF2001 forced nutation model
      INTEGER NA(9,NTERMS)
      DOUBLE PRECISION PSI(4,NTERMS), EPS(4,NTERMS)

!  Coefficients of fundamental angles
      DATA ( ( NA(I,J), I=1,9 ), J=1,10 ) / &
         0,   0,   0,   0,  -1,   0,   0,   0,   0, &
         0,   0,   2,  -2,   2,   0,   0,   0,   0, &
         0,   0,   2,   0,   2,   0,   0,   0,   0, &
         0,   0,   0,   0,  -2,   0,   0,   0,   0, &
         0,   1,   0,   0,   0,   0,   0,   0,   0, &
         0,   1,   2,  -2,   2,   0,   0,   0,   0, &
         1,   0,   0,   0,   0,   0,   0,   0,   0, &
         0,   0,   2,   0,   1,   0,   0,   0,   0, &
         1,   0,   2,   0,   2,   0,   0,   0,   0, &
         0,  -1,   2,  -2,   2,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=11,20 ) / &
         0,   0,   2,  -2,   1,   0,   0,   0,   0, &
        -1,   0,   2,   0,   2,   0,   0,   0,   0, &
        -1,   0,   0,   2,   0,   0,   0,   0,   0, &
         1,   0,   0,   0,   1,   0,   0,   0,   0, &
         1,   0,   0,   0,  -1,   0,   0,   0,   0, &
        -1,   0,   2,   2,   2,   0,   0,   0,   0, &
         1,   0,   2,   0,   1,   0,   0,   0,   0, &
        -2,   0,   2,   0,   1,   0,   0,   0,   0, &
         0,   0,   0,   2,   0,   0,   0,   0,   0, &
         0,   0,   2,   2,   2,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=21,30 ) / &
         2,   0,   0,  -2,   0,   0,   0,   0,   0, &
         2,   0,   2,   0,   2,   0,   0,   0,   0, &
         1,   0,   2,  -2,   2,   0,   0,   0,   0, &
        -1,   0,   2,   0,   1,   0,   0,   0,   0, &
         2,   0,   0,   0,   0,   0,   0,   0,   0, &
         0,   0,   2,   0,   0,   0,   0,   0,   0, &
         0,   1,   0,   0,   1,   0,   0,   0,   0, &
        -1,   0,   0,   2,   1,   0,   0,   0,   0, &
         0,   2,   2,  -2,   2,   0,   0,   0,   0, &
         0,   0,   2,  -2,   0,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=31,40 ) / &
        -1,   0,   0,   2,  -1,   0,   0,   0,   0, &
         0,   1,   0,   0,  -1,   0,   0,   0,   0, &
         0,   2,   0,   0,   0,   0,   0,   0,   0, &
        -1,   0,   2,   2,   1,   0,   0,   0,   0, &
         1,   0,   2,   2,   2,   0,   0,   0,   0, &
         0,   1,   2,   0,   2,   0,   0,   0,   0, &
        -2,   0,   2,   0,   0,   0,   0,   0,   0, &
         0,   0,   2,   2,   1,   0,   0,   0,   0, &
         0,  -1,   2,   0,   2,   0,   0,   0,   0, &
         0,   0,   0,   2,   1,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=41,50 ) / &
         1,   0,   2,  -2,   1,   0,   0,   0,   0, &
         2,   0,   0,  -2,  -1,   0,   0,   0,   0, &
         2,   0,   2,  -2,   2,   0,   0,   0,   0, &
         2,   0,   2,   0,   1,   0,   0,   0,   0, &
         0,   0,   0,   2,  -1,   0,   0,   0,   0, &
         0,  -1,   2,  -2,   1,   0,   0,   0,   0, &
        -1,  -1,   0,   2,   0,   0,   0,   0,   0, &
         2,   0,   0,  -2,   1,   0,   0,   0,   0, &
         1,   0,   0,   2,   0,   0,   0,   0,   0, &
         0,   1,   2,  -2,   1,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=51,60 ) / &
         1,  -1,   0,   0,   0,   0,   0,   0,   0, &
        -2,   0,   2,   0,   2,   0,   0,   0,   0, &
         0,  -1,   0,   2,   0,   0,   0,   0,   0, &
         3,   0,   2,   0,   2,   0,   0,   0,   0, &
         0,   0,   0,   1,   0,   0,   0,   0,   0, &
         1,  -1,   2,   0,   2,   0,   0,   0,   0, &
         1,   0,   0,  -1,   0,   0,   0,   0,   0, &
        -1,  -1,   2,   2,   2,   0,   0,   0,   0, &
        -1,   0,   2,   0,   0,   0,   0,   0,   0, &
         2,   0,   0,   0,  -1,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=61,70 ) / &
         0,  -1,   2,   2,   2,   0,   0,   0,   0, &
         1,   1,   2,   0,   2,   0,   0,   0,   0, &
         2,   0,   0,   0,   1,   0,   0,   0,   0, &
         1,   1,   0,   0,   0,   0,   0,   0,   0, &
         1,   0,  -2,   2,  -1,   0,   0,   0,   0, &
         1,   0,   2,   0,   0,   0,   0,   0,   0, &
        -1,   1,   0,   1,   0,   0,   0,   0,   0, &
         1,   0,   0,   0,   2,   0,   0,   0,   0, &
        -1,   0,   1,   0,   1,   0,   0,   0,   0, &
         0,   0,   2,   1,   2,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=71,80 ) / &
        -1,   1,   0,   1,   1,   0,   0,   0,   0, &
        -1,   0,   2,   4,   2,   0,   0,   0,   0, &
         0,  -2,   2,  -2,   1,   0,   0,   0,   0, &
         1,   0,   2,   2,   1,   0,   0,   0,   0, &
         1,   0,   0,   0,  -2,   0,   0,   0,   0, &
        -2,   0,   2,   2,   2,   0,   0,   0,   0, &
         1,   1,   2,  -2,   2,   0,   0,   0,   0, &
        -2,   0,   2,   4,   2,   0,   0,   0,   0, &
        -1,   0,   4,   0,   2,   0,   0,   0,   0, &
         2,   0,   2,  -2,   1,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=81,90 ) / &
         1,   0,   0,  -1,  -1,   0,   0,   0,   0, &
         2,   0,   2,   2,   2,   0,   0,   0,   0, &
         1,   0,   0,   2,   1,   0,   0,   0,   0, &
         3,   0,   0,   0,   0,   0,   0,   0,   0, &
         0,   0,   2,  -2,  -1,   0,   0,   0,   0, &
         3,   0,   2,  -2,   2,   0,   0,   0,   0, &
         0,   0,   4,  -2,   2,   0,   0,   0,   0, &
        -1,   0,   0,   4,   0,   0,   0,   0,   0, &
         0,   1,   2,   0,   1,   0,   0,   0,   0, &
         0,   0,   2,  -2,   3,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=91,100 ) / &
        -2,   0,   0,   4,   0,   0,   0,   0,   0, &
        -1,  -1,   0,   2,   1,   0,   0,   0,   0, &
        -2,   0,   2,   0,  -1,   0,   0,   0,   0, &
         0,   0,   2,   0,  -1,   0,   0,   0,   0, &
         0,  -1,   2,   0,   1,   0,   0,   0,   0, &
         0,   1,   0,   0,   2,   0,   0,   0,   0, &
         0,   0,   2,  -1,   2,   0,   0,   0,   0, &
         2,   1,   0,  -2,   0,   0,   0,   0,   0, &
         0,   0,   2,   4,   2,   0,   0,   0,   0, &
        -1,  -1,   0,   2,  -1,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=101,110 ) / &
        -1,   1,   0,   2,   0,   0,   0,   0,   0, &
         1,  -1,   0,   0,   1,   0,   0,   0,   0, &
         0,  -1,   2,  -2,   0,   0,   0,   0,   0, &
         0,   1,   0,   0,  -2,   0,   0,   0,   0, &
         1,  -1,   2,   2,   2,   0,   0,   0,   0, &
         1,   0,   0,   2,  -1,   0,   0,   0,   0, &
        -1,   1,   2,   2,   2,   0,   0,   0,   0, &
         3,   0,   2,   0,   1,   0,   0,   0,   0, &
         0,   1,   2,   2,   2,   0,   0,   0,   0, &
         1,   0,   2,  -2,   0,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=111,120 ) / &
        -1,   0,  -2,   4,  -1,   0,   0,   0,   0, &
        -1,  -1,   2,   2,   1,   0,   0,   0,   0, &
         0,  -1,   2,   2,   1,   0,   0,   0,   0, &
         2,  -1,   2,   0,   2,   0,   0,   0,   0, &
         0,   0,   0,   2,   2,   0,   0,   0,   0, &
         1,  -1,   2,   0,   1,   0,   0,   0,   0, &
        -1,   1,   2,   0,   2,   0,   0,   0,   0, &
         0,   1,   0,   2,   0,   0,   0,   0,   0, &
         0,   1,   2,  -2,   0,   0,   0,   0,   0, &
         0,   3,   2,  -2,   2,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=121,130 ) / &
         0,   0,   0,   1,   1,   0,   0,   0,   0, &
        -1,   0,   2,   2,   0,   0,   0,   0,   0, &
         2,   1,   2,   0,   2,   0,   0,   0,   0, &
         1,   1,   0,   0,   1,   0,   0,   0,   0, &
         2,   0,   0,   2,   0,   0,   0,   0,   0, &
         1,   1,   2,   0,   1,   0,   0,   0,   0, &
        -1,   0,   0,   2,   2,   0,   0,   0,   0, &
         1,   0,  -2,   2,   0,   0,   0,   0,   0, &
         0,  -1,   0,   2,  -1,   0,   0,   0,   0, &
        -1,   0,   1,   0,   2,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=131,140 ) / &
         0,   1,   0,   1,   0,   0,   0,   0,   0, &
         1,   0,  -2,   2,  -2,   0,   0,   0,   0, &
         0,   0,   0,   1,  -1,   0,   0,   0,   0, &
         1,  -1,   0,   0,  -1,   0,   0,   0,   0, &
         0,   0,   0,   4,   0,   0,   0,   0,   0, &
         1,  -1,   0,   2,   0,   0,   0,   0,   0, &
         1,   0,   2,   1,   2,   0,   0,   0,   0, &
         1,   0,   2,  -1,   2,   0,   0,   0,   0, &
        -1,   0,   0,   2,  -2,   0,   0,   0,   0, &
         0,   0,   2,   1,   1,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=141,150 ) / &
        -1,   0,   2,   0,  -1,   0,   0,   0,   0, &
        -1,   0,   2,   4,   1,   0,   0,   0,   0, &
         0,   0,   2,   2,   0,   0,   0,   0,   0, &
         1,   1,   2,  -2,   1,   0,   0,   0,   0, &
         0,   0,   1,   0,   1,   0,   0,   0,   0, &
        -1,   0,   2,  -1,   1,   0,   0,   0,   0, &
        -2,   0,   2,   2,   1,   0,   0,   0,   0, &
         2,  -1,   0,   0,   0,   0,   0,   0,   0, &
         4,   0,   2,   0,   2,   0,   0,   0,   0, &
         2,   1,   2,  -2,   2,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=151,160 ) / &
         0,   1,   2,   1,   2,   0,   0,   0,   0, &
         1,   0,   4,  -2,   2,   0,   0,   0,   0, &
         1,   1,   0,   0,  -1,   0,   0,   0,   0, &
        -2,   0,   2,   4,   1,   0,   0,   0,   0, &
         2,   0,   2,   0,   0,   0,   0,   0,   0, &
        -1,   0,   1,   0,   0,   0,   0,   0,   0, &
         1,   0,   0,   1,   0,   0,   0,   0,   0, &
         0,   1,   0,   2,   1,   0,   0,   0,   0, &
        -1,   0,   4,   0,   1,   0,   0,   0,   0, &
        -1,   0,   0,   4,   1,   0,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=161,170 ) / &
         2,   0,   2,   2,   1,   0,   0,   0,   0, &
         2,   1,   0,   0,   0,   0,   0,   0,   0, &
         0,   0,   5,  -5,   5,  -3,   0,   0,   0, &
         0,   0,   0,   0,   0,   0,   0,   2,   0, &
         0,   0,   1,  -1,   1,   0,   0,  -1,   0, &
         0,   0,  -1,   1,  -1,   1,   0,   0,   0, &
         0,   0,  -1,   1,   0,   0,   2,   0,   0, &
         0,   0,   3,  -3,   3,   0,   0,  -1,   0, &
         0,   0,  -8,   8,  -7,   5,   0,   0,   0, &
         0,   0,  -1,   1,  -1,   0,   2,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=171,180 ) / &
         0,   0,  -2,   2,  -2,   2,   0,   0,   0, &
         0,   0,  -6,   6,  -6,   4,   0,   0,   0, &
         0,   0,  -2,   2,  -2,   0,   8,  -3,   0, &
         0,   0,   6,  -6,   6,   0,  -8,   3,   0, &
         0,   0,   4,  -4,   4,  -2,   0,   0,   0, &
         0,   0,  -3,   3,  -3,   2,   0,   0,   0, &
         0,   0,   4,  -4,   3,   0,  -8,   3,   0, &
         0,   0,  -4,   4,  -5,   0,   8,  -3,   0, &
         0,   0,   0,   0,   0,   2,   0,   0,   0, &
         0,   0,  -4,   4,  -4,   3,   0,   0,   0 /
      DATA ( ( NA(I,J), I=1,9 ), J=181,190 ) / &
         0,   1,  -1,   1,  -1,   0,   0,   1,   0, &
         0,   0,   0,   0,   0,   0,   0,   1,   0, &
         0,   0,   1,  -1,   1,   1,   0,   0,   0, &
         0,   0,   2,  -2,   2,   0,  -2,   0,   0, &
         0,  -1,  -7,   7,  -7,   5,   0,   0,   0, &
        -2,   0,   2,   0,   2,   0,   0,  -2,   0, &
        -2,   0,   2,   0,   1,   0,   0,  -3,   0, &
         0,   0,   2,  -2,   2,   0,   0,  -2,   0, &
         0,   0,   1,  -1,   1,   0,   0,   1,   0, &
         0,   0,   0,   0,   0,   0,   0,   0,   2 /
      DATA ( ( NA(I,J), I=1,9 ), J=191,NTERMS ) / &
         0,   0,   0,   0,   0,   0,   0,   0,   1, &
         2,   0,  -2,   0,  -2,   0,   0,   3,   0, &
         0,   0,   1,  -1,   1,   0,   0,  -2,   0, &
         0,   0,  -7,   7,  -7,   5,   0,   0,   0 /

!  Nutation series: longitude
      DATA ( ( PSI(I,J), I=1,4 ), J=1,10 ) / &
       3341.5D0, 17206241.8D0,  3.1D0, 17409.5D0, &
      -1716.8D0, -1317185.3D0,  1.4D0,  -156.8D0, &
        285.7D0,  -227667.0D0,  0.3D0,   -23.5D0, &
        -68.6D0,  -207448.0D0,  0.0D0,   -21.4D0, &
        950.3D0,   147607.9D0, -2.3D0,  -355.0D0, &
        -66.7D0,   -51689.1D0,  0.2D0,   122.6D0, &
       -108.6D0,    71117.6D0,  0.0D0,     7.0D0, &
         35.6D0,   -38740.2D0,  0.1D0,   -36.2D0, &
         85.4D0,   -30127.6D0,  0.0D0,    -3.1D0, &
          9.0D0,    21583.0D0,  0.1D0,   -50.3D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=11,20 ) / &
         22.1D0,    12822.8D0,  0.0D0,    13.3D0, &
          3.4D0,    12350.8D0,  0.0D0,     1.3D0, &
        -21.1D0,    15699.4D0,  0.0D0,     1.6D0, &
          4.2D0,     6313.8D0,  0.0D0,     6.2D0, &
        -22.8D0,     5796.9D0,  0.0D0,     6.1D0, &
         15.7D0,    -5961.1D0,  0.0D0,    -0.6D0, &
         13.1D0,    -5159.1D0,  0.0D0,    -4.6D0, &
          1.8D0,     4592.7D0,  0.0D0,     4.5D0, &
        -17.5D0,     6336.0D0,  0.0D0,     0.7D0, &
         16.3D0,    -3851.1D0,  0.0D0,    -0.4D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=21,30 ) / &
         -2.8D0,     4771.7D0,  0.0D0,     0.5D0, &
         13.8D0,    -3099.3D0,  0.0D0,    -0.3D0, &
          0.2D0,     2860.3D0,  0.0D0,     0.3D0, &
          1.4D0,     2045.3D0,  0.0D0,     2.0D0, &
         -8.6D0,     2922.6D0,  0.0D0,     0.3D0, &
         -7.7D0,     2587.9D0,  0.0D0,     0.2D0, &
          8.8D0,    -1408.1D0,  0.0D0,     3.7D0, &
          1.4D0,     1517.5D0,  0.0D0,     1.5D0, &
         -1.9D0,    -1579.7D0,  0.0D0,     7.7D0, &
          1.3D0,    -2178.6D0,  0.0D0,    -0.2D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=31,40 ) / &
         -4.8D0,     1286.8D0,  0.0D0,     1.3D0, &
          6.3D0,     1267.2D0,  0.0D0,    -4.0D0, &
         -1.0D0,     1669.3D0,  0.0D0,    -8.3D0, &
          2.4D0,    -1020.0D0,  0.0D0,    -0.9D0, &
          4.5D0,     -766.9D0,  0.0D0,     0.0D0, &
         -1.1D0,      756.5D0,  0.0D0,    -1.7D0, &
         -1.4D0,    -1097.3D0,  0.0D0,    -0.5D0, &
          2.6D0,     -663.0D0,  0.0D0,    -0.6D0, &
          0.8D0,     -714.1D0,  0.0D0,     1.6D0, &
          0.4D0,     -629.9D0,  0.0D0,    -0.6D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=41,50 ) / &
          0.3D0,      580.4D0,  0.0D0,     0.6D0, &
         -1.6D0,      577.3D0,  0.0D0,     0.5D0, &
         -0.9D0,      644.4D0,  0.0D0,     0.0D0, &
          2.2D0,     -534.0D0,  0.0D0,    -0.5D0, &
         -2.5D0,      493.3D0,  0.0D0,     0.5D0, &
         -0.1D0,     -477.3D0,  0.0D0,    -2.4D0, &
         -0.9D0,      735.0D0,  0.0D0,    -1.7D0, &
          0.7D0,      406.2D0,  0.0D0,     0.4D0, &
         -2.8D0,      656.9D0,  0.0D0,     0.0D0, &
          0.6D0,      358.0D0,  0.0D0,     2.0D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=51,60 ) / &
         -0.7D0,      472.5D0,  0.0D0,    -1.1D0, &
         -0.1D0,     -300.5D0,  0.0D0,     0.0D0, &
         -1.2D0,      435.1D0,  0.0D0,    -1.0D0, &
          1.8D0,     -289.4D0,  0.0D0,     0.0D0, &
          0.6D0,     -422.6D0,  0.0D0,     0.0D0, &
          0.8D0,     -287.6D0,  0.0D0,     0.6D0, &
        -38.6D0,     -392.3D0,  0.0D0,     0.0D0, &
          0.7D0,     -281.8D0,  0.0D0,     0.6D0, &
          0.6D0,     -405.7D0,  0.0D0,     0.0D0, &
         -1.2D0,      229.0D0,  0.0D0,     0.2D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=61,70 ) / &
          1.1D0,     -264.3D0,  0.0D0,     0.5D0, &
         -0.7D0,      247.9D0,  0.0D0,    -0.5D0, &
         -0.2D0,      218.0D0,  0.0D0,     0.2D0, &
          0.6D0,     -339.0D0,  0.0D0,     0.8D0, &
         -0.7D0,      198.7D0,  0.0D0,     0.2D0, &
         -1.5D0,      334.0D0,  0.0D0,     0.0D0, &
          0.1D0,      334.0D0,  0.0D0,     0.0D0, &
         -0.1D0,     -198.1D0,  0.0D0,     0.0D0, &
       -106.6D0,        0.0D0,  0.0D0,     0.0D0, &
         -0.5D0,      165.8D0,  0.0D0,     0.0D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=71,80 ) / &
          0.0D0,      134.8D0,  0.0D0,     0.0D0, &
          0.9D0,     -151.6D0,  0.0D0,     0.0D0, &
          0.0D0,     -129.7D0,  0.0D0,     0.0D0, &
          0.8D0,     -132.8D0,  0.0D0,    -0.1D0, &
          0.5D0,     -140.7D0,  0.0D0,     0.0D0, &
         -0.1D0,      138.4D0,  0.0D0,     0.0D0, &
          0.0D0,      129.0D0,  0.0D0,    -0.3D0, &
          0.5D0,     -121.2D0,  0.0D0,     0.0D0, &
         -0.3D0,      114.5D0,  0.0D0,     0.0D0, &
         -0.1D0,      101.8D0,  0.0D0,     0.0D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=81,90 ) / &
         -3.6D0,     -101.9D0,  0.0D0,     0.0D0, &
          0.8D0,     -109.4D0,  0.0D0,     0.0D0, &
          0.2D0,      -97.0D0,  0.0D0,     0.0D0, &
         -0.7D0,      157.3D0,  0.0D0,     0.0D0, &
          0.2D0,      -83.3D0,  0.0D0,     0.0D0, &
         -0.3D0,       93.3D0,  0.0D0,     0.0D0, &
         -0.1D0,       92.1D0,  0.0D0,     0.0D0, &
         -0.5D0,      133.6D0,  0.0D0,     0.0D0, &
         -0.1D0,       81.5D0,  0.0D0,     0.0D0, &
          0.0D0,      123.9D0,  0.0D0,     0.0D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=91,100 ) / &
         -0.3D0,      128.1D0,  0.0D0,     0.0D0, &
          0.1D0,       74.1D0,  0.0D0,    -0.3D0, &
         -0.2D0,      -70.3D0,  0.0D0,     0.0D0, &
         -0.4D0,       66.6D0,  0.0D0,     0.0D0, &
          0.1D0,      -66.7D0,  0.0D0,     0.0D0, &
         -0.7D0,       69.3D0,  0.0D0,    -0.3D0, &
          0.0D0,      -70.4D0,  0.0D0,     0.0D0, &
         -0.1D0,      101.5D0,  0.0D0,     0.0D0, &
          0.5D0,      -69.1D0,  0.0D0,     0.0D0, &
         -0.2D0,       58.5D0,  0.0D0,     0.2D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=101,110 ) / &
          0.1D0,      -94.9D0,  0.0D0,     0.2D0, &
          0.0D0,       52.9D0,  0.0D0,    -0.2D0, &
          0.1D0,       86.7D0,  0.0D0,    -0.2D0, &
         -0.1D0,      -59.2D0,  0.0D0,     0.2D0, &
          0.3D0,      -58.8D0,  0.0D0,     0.1D0, &
         -0.3D0,       49.0D0,  0.0D0,     0.0D0, &
         -0.2D0,       56.9D0,  0.0D0,    -0.1D0, &
          0.3D0,      -50.2D0,  0.0D0,     0.0D0, &
         -0.2D0,       53.4D0,  0.0D0,    -0.1D0, &
          0.1D0,      -76.5D0,  0.0D0,     0.0D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=111,120 ) / &
         -0.2D0,       45.3D0,  0.0D0,     0.0D0, &
          0.1D0,      -46.8D0,  0.0D0,     0.0D0, &
          0.2D0,      -44.6D0,  0.0D0,     0.0D0, &
          0.2D0,      -48.7D0,  0.0D0,     0.0D0, &
          0.1D0,      -46.8D0,  0.0D0,     0.0D0, &
          0.1D0,      -42.0D0,  0.0D0,     0.0D0, &
          0.0D0,       46.4D0,  0.0D0,    -0.1D0, &
          0.2D0,      -67.3D0,  0.0D0,     0.1D0, &
          0.0D0,      -65.8D0,  0.0D0,     0.2D0, &
         -0.1D0,      -43.9D0,  0.0D0,     0.3D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=121,130 ) / &
          0.0D0,      -38.9D0,  0.0D0,     0.0D0, &
         -0.3D0,       63.9D0,  0.0D0,     0.0D0, &
         -0.2D0,       41.2D0,  0.0D0,     0.0D0, &
          0.0D0,      -36.1D0,  0.0D0,     0.2D0, &
         -0.3D0,       58.5D0,  0.0D0,     0.0D0, &
         -0.1D0,       36.1D0,  0.0D0,     0.0D0, &
          0.0D0,      -39.7D0,  0.0D0,     0.0D0, &
          0.1D0,      -57.7D0,  0.0D0,     0.0D0, &
         -0.2D0,       33.4D0,  0.0D0,     0.0D0, &
         36.4D0,        0.0D0,  0.0D0,     0.0D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=131,140 ) / &
         -0.1D0,       55.7D0,  0.0D0,    -0.1D0, &
          0.1D0,      -35.4D0,  0.0D0,     0.0D0, &
          0.1D0,      -31.0D0,  0.0D0,     0.0D0, &
         -0.1D0,       30.1D0,  0.0D0,     0.0D0, &
         -0.3D0,       49.2D0,  0.0D0,     0.0D0, &
         -0.2D0,       49.1D0,  0.0D0,     0.0D0, &
         -0.1D0,       33.6D0,  0.0D0,     0.0D0, &
          0.1D0,      -33.5D0,  0.0D0,     0.0D0, &
          0.1D0,      -31.0D0,  0.0D0,     0.0D0, &
         -0.1D0,       28.0D0,  0.0D0,     0.0D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=141,150 ) / &
          0.1D0,      -25.2D0,  0.0D0,     0.0D0, &
          0.1D0,      -26.2D0,  0.0D0,     0.0D0, &
         -0.2D0,       41.5D0,  0.0D0,     0.0D0, &
          0.0D0,       24.5D0,  0.0D0,     0.1D0, &
        -16.2D0,        0.0D0,  0.0D0,     0.0D0, &
          0.0D0,      -22.3D0,  0.0D0,     0.0D0, &
          0.0D0,       23.1D0,  0.0D0,     0.0D0, &
         -0.1D0,       37.5D0,  0.0D0,     0.0D0, &
          0.2D0,      -25.7D0,  0.0D0,     0.0D0, &
          0.0D0,       25.2D0,  0.0D0,     0.0D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=151,160 ) / &
          0.1D0,      -24.5D0,  0.0D0,     0.0D0, &
         -0.1D0,       24.3D0,  0.0D0,     0.0D0, &
          0.1D0,      -20.7D0,  0.0D0,     0.0D0, &
          0.1D0,      -20.8D0,  0.0D0,     0.0D0, &
         -0.2D0,       33.4D0,  0.0D0,     0.0D0, &
         32.9D0,        0.0D0,  0.0D0,     0.0D0, &
          0.1D0,      -32.6D0,  0.0D0,     0.0D0, &
          0.0D0,       19.9D0,  0.0D0,     0.0D0, &
         -0.1D0,       19.6D0,  0.0D0,     0.0D0, &
          0.0D0,      -18.7D0,  0.0D0,     0.0D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=161,170 ) / &
          0.1D0,      -19.0D0,  0.0D0,     0.0D0, &
          0.1D0,      -28.6D0,  0.0D0,     0.0D0, &
          4.0D0,      178.8D0,-11.8D0,     0.3D0, &
         39.8D0,     -107.3D0, -5.6D0,    -1.0D0, &
          9.9D0,      164.0D0, -4.1D0,     0.1D0, &
         -4.8D0,     -135.3D0, -3.4D0,    -0.1D0, &
         50.5D0,       75.0D0,  1.4D0,    -1.2D0, &
         -1.1D0,      -53.5D0,  1.3D0,     0.0D0, &
        -45.0D0,       -2.4D0, -0.4D0,     6.6D0, &
        -11.5D0,      -61.0D0, -0.9D0,     0.4D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=171,180 ) / &
          4.4D0,      -68.4D0, -3.4D0,     0.0D0, &
          7.7D0,      -47.1D0, -4.7D0,    -1.0D0, &
        -42.9D0,      -12.6D0, -1.2D0,     4.2D0, &
        -42.8D0,       12.7D0, -1.2D0,    -4.2D0, &
         -7.6D0,      -44.1D0,  2.1D0,    -0.5D0, &
        -64.1D0,        1.7D0,  0.2D0,     4.5D0, &
         36.4D0,      -10.4D0,  1.0D0,     3.5D0, &
         35.6D0,       10.2D0,  1.0D0,    -3.5D0, &
         -1.7D0,       39.5D0,  2.0D0,     0.0D0, &
         50.9D0,       -8.2D0, -0.8D0,    -5.0D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=181,190 ) / &
          0.0D0,       52.3D0,  1.2D0,     0.0D0, &
        -42.9D0,      -17.8D0,  0.4D0,     0.0D0, &
          2.6D0,       34.3D0,  0.8D0,     0.0D0, &
         -0.8D0,      -48.6D0,  2.4D0,    -0.1D0, &
         -4.9D0,       30.5D0,  3.7D0,     0.7D0, &
          0.0D0,      -43.6D0,  2.1D0,     0.0D0, &
          0.0D0,      -25.4D0,  1.2D0,     0.0D0, &
          2.0D0,       40.9D0, -2.0D0,     0.0D0, &
         -2.1D0,       26.1D0,  0.6D0,     0.0D0, &
         22.6D0,       -3.2D0, -0.5D0,    -0.5D0 /
      DATA ( ( PSI(I,J), I=1,4 ), J=191,NTERMS ) / &
         -7.6D0,       24.9D0, -0.4D0,    -0.2D0, &
         -6.2D0,       34.9D0,  1.7D0,     0.3D0, &
          2.0D0,       17.4D0, -0.4D0,     0.1D0, &
         -3.9D0,       20.5D0,  2.4D0,     0.6D0 /

!  Nutation series: obliquity
      DATA ( ( EPS(I,J), I=1,4 ), J=1,10 ) / &
      9205365.8D0, -1506.2D0,  885.7D0, -0.2D0, &
       573095.9D0,  -570.2D0, -305.0D0, -0.3D0, &
        97845.5D0,   147.8D0,  -48.8D0, -0.2D0, &
       -89753.6D0,    28.0D0,   46.9D0,  0.0D0, &
         7406.7D0,  -327.1D0,  -18.2D0,  0.8D0, &
        22442.3D0,   -22.3D0,  -67.6D0,  0.0D0, &
         -683.6D0,    46.8D0,    0.0D0,  0.0D0, &
        20070.7D0,    36.0D0,    1.6D0,  0.0D0, &
        12893.8D0,    39.5D0,   -6.2D0,  0.0D0, &
        -9593.2D0,    14.4D0,   30.2D0, -0.1D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=11,20 ) / &
        -6899.5D0,     4.8D0,   -0.6D0,  0.0D0, &
        -5332.5D0,    -0.1D0,    2.7D0,  0.0D0, &
         -125.2D0,    10.5D0,    0.0D0,  0.0D0, &
        -3323.4D0,    -0.9D0,   -0.3D0,  0.0D0, &
         3142.3D0,     8.9D0,    0.3D0,  0.0D0, &
         2552.5D0,     7.3D0,   -1.2D0,  0.0D0, &
         2634.4D0,     8.8D0,    0.2D0,  0.0D0, &
        -2424.4D0,     1.6D0,   -0.4D0,  0.0D0, &
         -123.3D0,     3.9D0,    0.0D0,  0.0D0, &
         1642.4D0,     7.3D0,   -0.8D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=21,30 ) / &
           47.9D0,     3.2D0,    0.0D0,  0.0D0, &
         1321.2D0,     6.2D0,   -0.6D0,  0.0D0, &
        -1234.1D0,    -0.3D0,    0.6D0,  0.0D0, &
        -1076.5D0,    -0.3D0,    0.0D0,  0.0D0, &
          -61.6D0,     1.8D0,    0.0D0,  0.0D0, &
          -55.4D0,     1.6D0,    0.0D0,  0.0D0, &
          856.9D0,    -4.9D0,   -2.1D0,  0.0D0, &
         -800.7D0,    -0.1D0,    0.0D0,  0.0D0, &
          685.1D0,    -0.6D0,   -3.8D0,  0.0D0, &
          -16.9D0,    -1.5D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=31,40 ) / &
          695.7D0,     1.8D0,    0.0D0,  0.0D0, &
          642.2D0,    -2.6D0,   -1.6D0,  0.0D0, &
           13.3D0,     1.1D0,   -0.1D0,  0.0D0, &
          521.9D0,     1.6D0,    0.0D0,  0.0D0, &
          325.8D0,     2.0D0,   -0.1D0,  0.0D0, &
         -325.1D0,    -0.5D0,    0.9D0,  0.0D0, &
           10.1D0,     0.3D0,    0.0D0,  0.0D0, &
          334.5D0,     1.6D0,    0.0D0,  0.0D0, &
          307.1D0,     0.4D0,   -0.9D0,  0.0D0, &
          327.2D0,     0.5D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=41,50 ) / &
         -304.6D0,    -0.1D0,    0.0D0,  0.0D0, &
          304.0D0,     0.6D0,    0.0D0,  0.0D0, &
         -276.8D0,    -0.5D0,    0.1D0,  0.0D0, &
          268.9D0,     1.3D0,    0.0D0,  0.0D0, &
          271.8D0,     1.1D0,    0.0D0,  0.0D0, &
          271.5D0,    -0.4D0,   -0.8D0,  0.0D0, &
           -5.2D0,     0.5D0,    0.0D0,  0.0D0, &
         -220.5D0,     0.1D0,    0.0D0,  0.0D0, &
          -20.1D0,     0.3D0,    0.0D0,  0.0D0, &
         -191.0D0,     0.1D0,    0.5D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=51,60 ) / &
           -4.1D0,     0.3D0,    0.0D0,  0.0D0, &
          130.6D0,    -0.1D0,    0.0D0,  0.0D0, &
            3.0D0,     0.3D0,    0.0D0,  0.0D0, &
          122.9D0,     0.8D0,    0.0D0,  0.0D0, &
            3.7D0,    -0.3D0,    0.0D0,  0.0D0, &
          123.1D0,     0.4D0,   -0.3D0,  0.0D0, &
          -52.7D0,    15.3D0,    0.0D0,  0.0D0, &
          120.7D0,     0.3D0,   -0.3D0,  0.0D0, &
            4.0D0,    -0.3D0,    0.0D0,  0.0D0, &
          126.5D0,     0.5D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=61,70 ) / &
          112.7D0,     0.5D0,   -0.3D0,  0.0D0, &
         -106.1D0,    -0.3D0,    0.3D0,  0.0D0, &
         -112.9D0,    -0.2D0,    0.0D0,  0.0D0, &
            3.6D0,    -0.2D0,    0.0D0,  0.0D0, &
          107.4D0,     0.3D0,    0.0D0,  0.0D0, &
          -10.9D0,     0.2D0,    0.0D0,  0.0D0, &
           -0.9D0,     0.0D0,    0.0D0,  0.0D0, &
           85.4D0,     0.0D0,    0.0D0,  0.0D0, &
            0.0D0,   -88.8D0,    0.0D0,  0.0D0, &
          -71.0D0,    -0.2D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=71,80 ) / &
          -70.3D0,     0.0D0,    0.0D0,  0.0D0, &
           64.5D0,     0.4D0,    0.0D0,  0.0D0, &
           69.8D0,     0.0D0,    0.0D0,  0.0D0, &
           66.1D0,     0.4D0,    0.0D0,  0.0D0, &
          -61.0D0,    -0.2D0,    0.0D0,  0.0D0, &
          -59.5D0,    -0.1D0,    0.0D0,  0.0D0, &
          -55.6D0,     0.0D0,    0.2D0,  0.0D0, &
           51.7D0,     0.2D0,    0.0D0,  0.0D0, &
          -49.0D0,    -0.1D0,    0.0D0,  0.0D0, &
          -52.7D0,    -0.1D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=81,90 ) / &
          -49.6D0,     1.4D0,    0.0D0,  0.0D0, &
           46.3D0,     0.4D0,    0.0D0,  0.0D0, &
           49.6D0,     0.1D0,    0.0D0,  0.0D0, &
           -5.1D0,     0.1D0,    0.0D0,  0.0D0, &
          -44.0D0,    -0.1D0,    0.0D0,  0.0D0, &
          -39.9D0,    -0.1D0,    0.0D0,  0.0D0, &
          -39.5D0,    -0.1D0,    0.0D0,  0.0D0, &
           -3.9D0,     0.1D0,    0.0D0,  0.0D0, &
          -42.1D0,    -0.1D0,    0.0D0,  0.0D0, &
          -17.2D0,     0.1D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=91,100 ) / &
           -2.3D0,     0.1D0,    0.0D0,  0.0D0, &
          -39.2D0,     0.0D0,    0.0D0,  0.0D0, &
          -38.4D0,     0.1D0,    0.0D0,  0.0D0, &
           36.8D0,     0.2D0,    0.0D0,  0.0D0, &
           34.6D0,     0.1D0,    0.0D0,  0.0D0, &
          -32.7D0,     0.3D0,    0.0D0,  0.0D0, &
           30.4D0,     0.0D0,    0.0D0,  0.0D0, &
            0.4D0,     0.1D0,    0.0D0,  0.0D0, &
           29.3D0,     0.2D0,    0.0D0,  0.0D0, &
           31.6D0,     0.1D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=101,110 ) / &
            0.8D0,    -0.1D0,    0.0D0,  0.0D0, &
          -27.9D0,     0.0D0,    0.0D0,  0.0D0, &
            2.9D0,     0.0D0,    0.0D0,  0.0D0, &
          -25.3D0,     0.0D0,    0.0D0,  0.0D0, &
           25.0D0,     0.1D0,    0.0D0,  0.0D0, &
           27.5D0,     0.1D0,    0.0D0,  0.0D0, &
          -24.4D0,    -0.1D0,    0.0D0,  0.0D0, &
           24.9D0,     0.2D0,    0.0D0,  0.0D0, &
          -22.8D0,    -0.1D0,    0.0D0,  0.0D0, &
            0.9D0,    -0.1D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=111,120 ) / &
           24.4D0,     0.1D0,    0.0D0,  0.0D0, &
           23.9D0,     0.1D0,    0.0D0,  0.0D0, &
           22.5D0,     0.1D0,    0.0D0,  0.0D0, &
           20.8D0,     0.1D0,    0.0D0,  0.0D0, &
           20.1D0,     0.0D0,    0.0D0,  0.0D0, &
           21.5D0,     0.1D0,    0.0D0,  0.0D0, &
          -20.0D0,     0.0D0,    0.0D0,  0.0D0, &
            1.4D0,     0.0D0,    0.0D0,  0.0D0, &
           -0.2D0,    -0.1D0,    0.0D0,  0.0D0, &
           19.0D0,     0.0D0,   -0.1D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=121,130 ) / &
           20.5D0,     0.0D0,    0.0D0,  0.0D0, &
           -2.0D0,     0.0D0,    0.0D0,  0.0D0, &
          -17.6D0,    -0.1D0,    0.0D0,  0.0D0, &
           19.0D0,     0.0D0,    0.0D0,  0.0D0, &
           -2.4D0,     0.0D0,    0.0D0,  0.0D0, &
          -18.4D0,    -0.1D0,    0.0D0,  0.0D0, &
           17.1D0,     0.0D0,    0.0D0,  0.0D0, &
            0.4D0,     0.0D0,    0.0D0,  0.0D0, &
           18.4D0,     0.1D0,    0.0D0,  0.0D0, &
            0.0D0,    17.4D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=131,140 ) / &
           -0.6D0,     0.0D0,    0.0D0,  0.0D0, &
          -15.4D0,     0.0D0,    0.0D0,  0.0D0, &
          -16.8D0,    -0.1D0,    0.0D0,  0.0D0, &
           16.3D0,     0.0D0,    0.0D0,  0.0D0, &
           -2.0D0,     0.0D0,    0.0D0,  0.0D0, &
           -1.5D0,     0.0D0,    0.0D0,  0.0D0, &
          -14.3D0,    -0.1D0,    0.0D0,  0.0D0, &
           14.4D0,     0.0D0,    0.0D0,  0.0D0, &
          -13.4D0,     0.0D0,    0.0D0,  0.0D0, &
          -14.3D0,    -0.1D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=141,150 ) / &
          -13.7D0,     0.0D0,    0.0D0,  0.0D0, &
           13.1D0,     0.1D0,    0.0D0,  0.0D0, &
           -1.7D0,     0.0D0,    0.0D0,  0.0D0, &
          -12.8D0,     0.0D0,    0.0D0,  0.0D0, &
            0.0D0,   -14.4D0,    0.0D0,  0.0D0, &
           12.4D0,     0.0D0,    0.0D0,  0.0D0, &
          -12.0D0,     0.0D0,    0.0D0,  0.0D0, &
           -0.8D0,     0.0D0,    0.0D0,  0.0D0, &
           10.9D0,     0.1D0,    0.0D0,  0.0D0, &
          -10.8D0,     0.0D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=151,160 ) / &
           10.5D0,     0.0D0,    0.0D0,  0.0D0, &
          -10.4D0,     0.0D0,    0.0D0,  0.0D0, &
          -11.2D0,     0.0D0,    0.0D0,  0.0D0, &
           10.5D0,     0.1D0,    0.0D0,  0.0D0, &
           -1.4D0,     0.0D0,    0.0D0,  0.0D0, &
            0.0D0,     0.1D0,    0.0D0,  0.0D0, &
            0.7D0,     0.0D0,    0.0D0,  0.0D0, &
          -10.3D0,     0.0D0,    0.0D0,  0.0D0, &
          -10.0D0,     0.0D0,    0.0D0,  0.0D0, &
            9.6D0,     0.0D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=161,170 ) / &
            9.4D0,     0.1D0,    0.0D0,  0.0D0, &
            0.6D0,     0.0D0,    0.0D0,  0.0D0, &
          -87.7D0,     4.4D0,   -0.4D0, -6.3D0, &
           46.3D0,    22.4D0,    0.5D0, -2.4D0, &
           15.6D0,    -3.4D0,    0.1D0,  0.4D0, &
            5.2D0,     5.8D0,    0.2D0, -0.1D0, &
          -30.1D0,    26.9D0,    0.7D0,  0.0D0, &
           23.2D0,    -0.5D0,    0.0D0,  0.6D0, &
            1.0D0,    23.2D0,    3.4D0,  0.0D0, &
          -12.2D0,    -4.3D0,    0.0D0,  0.0D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=171,180 ) / &
           -2.1D0,    -3.7D0,   -0.2D0,  0.1D0, &
          -18.6D0,    -3.8D0,   -0.4D0,  1.8D0, &
            5.5D0,   -18.7D0,   -1.8D0, -0.5D0, &
           -5.5D0,   -18.7D0,    1.8D0, -0.5D0, &
           18.4D0,    -3.6D0,    0.3D0,  0.9D0, &
           -0.6D0,     1.3D0,    0.0D0,  0.0D0, &
           -5.6D0,   -19.5D0,    1.9D0,  0.0D0, &
            5.5D0,   -19.1D0,   -1.9D0,  0.0D0, &
          -17.3D0,    -0.8D0,    0.0D0,  0.9D0, &
           -3.2D0,    -8.3D0,   -0.8D0,  0.3D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=181,190 ) / &
           -0.1D0,     0.0D0,    0.0D0,  0.0D0, &
           -5.4D0,     7.8D0,   -0.3D0,  0.0D0, &
          -14.8D0,     1.4D0,    0.0D0,  0.3D0, &
           -3.8D0,     0.4D0,    0.0D0, -0.2D0, &
           12.6D0,     3.2D0,    0.5D0, -1.5D0, &
            0.1D0,     0.0D0,    0.0D0,  0.0D0, &
          -13.6D0,     2.4D0,   -0.1D0,  0.0D0, &
            0.9D0,     1.2D0,    0.0D0,  0.0D0, &
          -11.9D0,    -0.5D0,    0.0D0,  0.3D0, &
            0.4D0,    12.0D0,    0.3D0, -0.2D0 /
      DATA ( ( EPS(I,J), I=1,4 ), J=191,NTERMS ) / &
            8.3D0,     6.1D0,   -0.1D0,  0.1D0, &
            0.0D0,     0.0D0,    0.0D0,  0.0D0, &
            0.4D0,   -10.8D0,    0.3D0,  0.0D0, &
            9.6D0,     2.2D0,    0.3D0, -1.2D0 /



!  Interval between fundamental epoch J2000.0 and given epoch (JC).
      T = (DATE-DJM0)/DJC

!  Mean anomaly of the Moon.
      EL  = 134.96340251D0*DD2R+ &
           MOD(T*(1717915923.2178D0+ &
               T*(        31.8792D0+ &
               T*(         0.051635D0+ &
               T*(       - 0.00024470D0)))),TURNAS)*DAS2R

!  Mean anomaly of the Sun.
      ELP = 357.52910918D0*DD2R+ &
           MOD(T*( 129596581.0481D0+ &
               T*(       - 0.5532D0+ &
               T*(         0.000136D0+ &
               T*(       - 0.00001149D0)))),TURNAS)*DAS2R

!  Mean argument of the latitude of the Moon.
      F   =  93.27209062D0*DD2R+ &
           MOD(T*(1739527262.8478D0+ &
               T*(      - 12.7512D0+ &
               T*(      -  0.001037D0+ &
               T*(         0.00000417D0)))),TURNAS)*DAS2R

!  Mean elongation of the Moon from the Sun.
      D   = 297.85019547D0*DD2R+ &
           MOD(T*(1602961601.2090D0+ &
               T*(       - 6.3706D0+ &
               T*(         0.006539D0+ &
               T*(       - 0.00003169D0)))),TURNAS)*DAS2R

!  Mean longitude of the ascending node of the Moon.
      OM  = 125.04455501D0*DD2R+ &
           MOD(T*( - 6962890.5431D0+ &
               T*(         7.4722D0+ &
               T*(         0.007702D0+ &
               T*(       - 0.00005939D0)))),TURNAS)*DAS2R

!  Mean longitude of Venus.
      VE    = 181.97980085D0*DD2R+MOD(210664136.433548D0*T,TURNAS)*DAS2R

!  Mean longitude of Mars.
      MA    = 355.43299958D0*DD2R+MOD( 68905077.493988D0*T,TURNAS)*DAS2R

!  Mean longitude of Jupiter.
      JU    =  34.35151874D0*DD2R+MOD( 10925660.377991D0*T,TURNAS)*DAS2R

!  Mean longitude of Saturn.
      SA    =  50.07744430D0*DD2R+MOD(  4399609.855732D0*T,TURNAS)*DAS2R

!  Geodesic nutation (Fukushima 1991) in microarcsec.
      DP = -153.1D0*SIN(ELP)-1.9D0*SIN(2D0*ELP)
      DE = 0D0

!  Shirai & Fukushima (2001) nutation series.
      DO J=NTERMS,1,-1
         THETA = DBLE(NA(1,J))*EL+ &
                DBLE(NA(2,J))*ELP+ &
                DBLE(NA(3,J))*F+ &
                DBLE(NA(4,J))*D+ &
                DBLE(NA(5,J))*OM+ &
                DBLE(NA(6,J))*VE+ &
                DBLE(NA(7,J))*MA+ &
                DBLE(NA(8,J))*JU+ &
                DBLE(NA(9,J))*SA
         C = COS(THETA)
         S = SIN(THETA)
         DP = DP+(PSI(1,J)+PSI(3,J)*T)*C+(PSI(2,J)+PSI(4,J)*T)*S
         DE = DE+(EPS(1,J)+EPS(3,J)*T)*C+(EPS(2,J)+EPS(4,J)*T)*S
      END DO

!  Change of units, and addition of the precession correction.
      DPSI = (DP*1D-6-0.042888D0-0.29856D0*T)*DAS2R
      DEPS = (DE*1D-6-0.005171D0-0.02408D0*T)*DAS2R

!  Mean obliquity of date (Simon et al. 1994).
      EPS0 = (84381.412D0+ &
              (-46.80927D0+ &
               (-0.000152D0+ &
                (0.0019989D0+ &
               (-0.00000051D0+ &
               (-0.000000025D0)*T)*T)*T)*T)*T)*DAS2R

      END
      SUBROUTINE sla_NUTC80 (DATE, DPSI, DEPS, EPS0)
!+
!     - - - - - - -
!      N U T C 8 0
!     - - - - - - -
!
!  Nutation:  longitude & obliquity components and mean obliquity,
!  using the IAU 1980 theory (double precision)
!
!  Given:
!     DATE        d     TDB (loosely ET) as Modified Julian Date
!                                            (JD-2400000.5)
!  Returned:
!     DPSI,DEPS   d     nutation in longitude,obliquity
!     EPS0        d     mean obliquity
!
!  Called:  sla_DRANGE
!
!  Notes:
!
!  1  Earth attitude predictions made by combining the present nutation
!     model with IAU 1976 precession are accurate to 0.35 arcsec over
!     the interval 1900-2100.  (The accuracy is much better near the
!     middle of the interval.)
!
!  2  The sla_NUTC routine is the equivalent of the present routine
!     but using the Shirai & Fukushima 2001 forced nutation theory
!     (SF2001).  The newer theory is more accurate than IAU 1980,
!     within 1 mas (with respect to the ICRF) for a few decades around
!     2000.  The improvement is mainly because of the corrections to the
!     IAU 1976 precession that the SF2001 theory includes.
!
!  References:
!     Final report of the IAU Working Group on Nutation,
!      chairman P.K.Seidelmann, 1980.
!     Kaplan,G.H., 1981, USNO circular no. 163, pA3-6.
!
!  P.T.Wallace   Starlink   7 October 2001
!
!  Copyright (C) 2001 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,DPSI,DEPS,EPS0

      DOUBLE PRECISION T2AS,AS2R,U2R
      DOUBLE PRECISION T,EL,EL2,EL3
      DOUBLE PRECISION ELP,ELP2
      DOUBLE PRECISION F,F2,F4
      DOUBLE PRECISION D,D2,D4
      DOUBLE PRECISION OM,OM2
      DOUBLE PRECISION DP,DE
      DOUBLE PRECISION A

      DOUBLE PRECISION sla_DRANGE


!  Turns to arc seconds
      PARAMETER (T2AS=1296000D0)
!  Arc seconds to radians
      PARAMETER (AS2R=0.484813681109535994D-5)
!  Units of 0.0001 arcsec to radians
      PARAMETER (U2R=AS2R/1D4)

!  Interval between basic epoch J2000.0 and current epoch (JC)
      T=(DATE-51544.5D0)/36525D0

!
!  FUNDAMENTAL ARGUMENTS in the FK5 reference system
!

!  Mean longitude of the Moon minus mean longitude of the Moon's perigee
      EL=sla_DRANGE(AS2R*(485866.733D0+(1325D0*T2AS+715922.633D0 &
                        +(31.310D0+0.064D0*T)*T)*T))

!  Mean longitude of the Sun minus mean longitude of the Sun's perigee
      ELP=sla_DRANGE(AS2R*(1287099.804D0+(99D0*T2AS+1292581.224D0 &
                        +(-0.577D0-0.012D0*T)*T)*T))

!  Mean longitude of the Moon minus mean longitude of the Moon's node
      F=sla_DRANGE(AS2R*(335778.877D0+(1342D0*T2AS+295263.137D0 &
                        +(-13.257D0+0.011D0*T)*T)*T))

!  Mean elongation of the Moon from the Sun
      D=sla_DRANGE(AS2R*(1072261.307D0+(1236D0*T2AS+1105601.328D0 &
                        +(-6.891D0+0.019D0*T)*T)*T))

!  Longitude of the mean ascending node of the lunar orbit on the
!   ecliptic, measured from the mean equinox of date
      OM=sla_DRANGE(AS2R*(450160.280D0+(-5D0*T2AS-482890.539D0 &
                        +(7.455D0+0.008D0*T)*T)*T))

!  Multiples of arguments
      EL2=EL+EL
      EL3=EL2+EL
      ELP2=ELP+ELP
      F2=F+F
      F4=F2+F2
      D2=D+D
      D4=D2+D2
      OM2=OM+OM


!
!  SERIES FOR THE NUTATION
!
      DP=0D0
      DE=0D0

!  106
      DP=DP+SIN(ELP+D)
!  105
      DP=DP-SIN(F2+D4+OM2)
!  104
      DP=DP+SIN(EL2+D2)
!  103
      DP=DP-SIN(EL-F2+D2)
!  102
      DP=DP-SIN(EL+ELP-D2+OM)
!  101
      DP=DP-SIN(-ELP+F2+OM)
!  100
      DP=DP-SIN(EL-F2-D2)
!  99
      DP=DP-SIN(ELP+D2)
!  98
      DP=DP-SIN(F2-D+OM2)
!  97
      DP=DP-SIN(-F2+OM)
!  96
      DP=DP+SIN(-EL-ELP+D2+OM)
!  95
      DP=DP+SIN(ELP+F2+OM)
!  94
      DP=DP-SIN(EL+F2-D2)
!  93
      DP=DP+SIN(EL3+F2-D2+OM2)
!  92
      DP=DP+SIN(F4-D2+OM2)
!  91
      DP=DP-SIN(EL+D2+OM)
!  90
      DP=DP-SIN(EL2+F2+D2+OM2)
!  89
      A=EL2+F2-D2+OM
      DP=DP+SIN(A)
      DE=DE-COS(A)
!  88
      DP=DP+SIN(EL-ELP-D2)
!  87
      DP=DP+SIN(-EL+F4+OM2)
!  86
      A=-EL2+F2+D4+OM2
      DP=DP-SIN(A)
      DE=DE+COS(A)
!  85
      A=EL+F2+D2+OM
      DP=DP-SIN(A)
      DE=DE+COS(A)
!  84
      A=EL+ELP+F2-D2+OM2
      DP=DP+SIN(A)
      DE=DE-COS(A)
!  83
      DP=DP-SIN(EL2-D4)
!  82
      A=-EL+F2+D4+OM2
      DP=DP-2D0*SIN(A)
      DE=DE+COS(A)
!  81
      A=-EL2+F2+D2+OM2
      DP=DP+SIN(A)
      DE=DE-COS(A)
!  80
      DP=DP-SIN(EL-D4)
!  79
      A=-EL+OM2
      DP=DP+SIN(A)
      DE=DE-COS(A)
!  78
      A=F2+D+OM2
      DP=DP+2D0*SIN(A)
      DE=DE-COS(A)
!  77
      DP=DP+2D0*SIN(EL3)
!  76
      A=EL+OM2
      DP=DP-2D0*SIN(A)
      DE=DE+COS(A)
!  75
      A=EL2+OM
      DP=DP+2D0*SIN(A)
      DE=DE-COS(A)
!  74
      A=-EL+F2-D2+OM
      DP=DP-2D0*SIN(A)
      DE=DE+COS(A)
!  73
      A=EL+ELP+F2+OM2
      DP=DP+2D0*SIN(A)
      DE=DE-COS(A)
!  72
      A=-ELP+F2+D2+OM2
      DP=DP-3D0*SIN(A)
      DE=DE+COS(A)
!  71
      A=EL3+F2+OM2
      DP=DP-3D0*SIN(A)
      DE=DE+COS(A)
!  70
      A=-EL2+OM
      DP=DP-2D0*SIN(A)
      DE=DE+COS(A)
!  69
      A=-EL-ELP+F2+D2+OM2
      DP=DP-3D0*SIN(A)
      DE=DE+COS(A)
!  68
      A=EL-ELP+F2+OM2
      DP=DP-3D0*SIN(A)
      DE=DE+COS(A)
!  67
      DP=DP+3D0*SIN(EL+F2)
!  66
      DP=DP-3D0*SIN(EL+ELP)
!  65
      DP=DP-4D0*SIN(D)
!  64
      DP=DP+4D0*SIN(EL-F2)
!  63
      DP=DP-4D0*SIN(ELP-D2)
!  62
      A=EL2+F2+OM
      DP=DP-5D0*SIN(A)
      DE=DE+3D0*COS(A)
!  61
      DP=DP+5D0*SIN(EL-ELP)
!  60
      A=-D2+OM
      DP=DP-5D0*SIN(A)
      DE=DE+3D0*COS(A)
!  59
      A=EL+F2-D2+OM
      DP=DP+6D0*SIN(A)
      DE=DE-3D0*COS(A)
!  58
      A=F2+D2+OM
      DP=DP-7D0*SIN(A)
      DE=DE+3D0*COS(A)
!  57
      A=D2+OM
      DP=DP-6D0*SIN(A)
      DE=DE+3D0*COS(A)
!  56
      A=EL2+F2-D2+OM2
      DP=DP+6D0*SIN(A)
      DE=DE-3D0*COS(A)
!  55
      DP=DP+6D0*SIN(EL+D2)
!  54
      A=EL+F2+D2+OM2
      DP=DP-8D0*SIN(A)
      DE=DE+3D0*COS(A)
!  53
      A=-ELP+F2+OM2
      DP=DP-7D0*SIN(A)
      DE=DE+3D0*COS(A)
!  52
      A=ELP+F2+OM2
      DP=DP+7D0*SIN(A)
      DE=DE-3D0*COS(A)
!  51
      DP=DP-7D0*SIN(EL+ELP-D2)
!  50
      A=-EL+F2+D2+OM
      DP=DP-10D0*SIN(A)
      DE=DE+5D0*COS(A)
!  49
      A=EL-D2+OM
      DP=DP-13D0*SIN(A)
      DE=DE+7D0*COS(A)
!  48
      A=-EL+D2+OM
      DP=DP+16D0*SIN(A)
      DE=DE-8D0*COS(A)
!  47
      A=-EL+F2+OM
      DP=DP+21D0*SIN(A)
      DE=DE-10D0*COS(A)
!  46
      DP=DP+26D0*SIN(F2)
      DE=DE-COS(F2)
!  45
      A=EL2+F2+OM2
      DP=DP-31D0*SIN(A)
      DE=DE+13D0*COS(A)
!  44
      A=EL+F2-D2+OM2
      DP=DP+29D0*SIN(A)
      DE=DE-12D0*COS(A)
!  43
      DP=DP+29D0*SIN(EL2)
      DE=DE-COS(EL2)
!  42
      A=F2+D2+OM2
      DP=DP-38D0*SIN(A)
      DE=DE+16D0*COS(A)
!  41
      A=EL+F2+OM
      DP=DP-51D0*SIN(A)
      DE=DE+27D0*COS(A)
!  40
      A=-EL+F2+D2+OM2
      DP=DP-59D0*SIN(A)
      DE=DE+26D0*COS(A)
!  39
      A=-EL+OM
      DP=DP+(-58D0-0.1D0*T)*SIN(A)
      DE=DE+32D0*COS(A)
!  38
      A=EL+OM
      DP=DP+(63D0+0.1D0*T)*SIN(A)
      DE=DE-33D0*COS(A)
!  37
      DP=DP+63D0*SIN(D2)
      DE=DE-2D0*COS(D2)
!  36
      A=-EL+F2+OM2
      DP=DP+123D0*SIN(A)
      DE=DE-53D0*COS(A)
!  35
      A=EL-D2
      DP=DP-158D0*SIN(A)
      DE=DE-COS(A)
!  34
      A=EL+F2+OM2
      DP=DP-301D0*SIN(A)
      DE=DE+(129D0-0.1D0*T)*COS(A)
!  33
      A=F2+OM
      DP=DP+(-386D0-0.4D0*T)*SIN(A)
      DE=DE+200D0*COS(A)
!  32
      DP=DP+(712D0+0.1D0*T)*SIN(EL)
      DE=DE-7D0*COS(EL)
!  31
      A=F2+OM2
      DP=DP+(-2274D0-0.2D0*T)*SIN(A)
      DE=DE+(977D0-0.5D0*T)*COS(A)
!  30
      DP=DP-SIN(ELP+F2-D2)
!  29
      DP=DP+SIN(-EL+D+OM)
!  28
      DP=DP+SIN(ELP+OM2)
!  27
      DP=DP-SIN(ELP-F2+D2)
!  26
      DP=DP+SIN(-F2+D2+OM)
!  25
      DP=DP+SIN(EL2+ELP-D2)
!  24
      DP=DP-4D0*SIN(EL-D)
!  23
      A=ELP+F2-D2+OM
      DP=DP+4D0*SIN(A)
      DE=DE-2D0*COS(A)
!  22
      A=EL2-D2+OM
      DP=DP+4D0*SIN(A)
      DE=DE-2D0*COS(A)
!  21
      A=-ELP+F2-D2+OM
      DP=DP-5D0*SIN(A)
      DE=DE+3D0*COS(A)
!  20
      A=-EL2+D2+OM
      DP=DP-6D0*SIN(A)
      DE=DE+3D0*COS(A)
!  19
      A=-ELP+OM
      DP=DP-12D0*SIN(A)
      DE=DE+6D0*COS(A)
!  18
      A=ELP2+F2-D2+OM2
      DP=DP+(-16D0+0.1D0*T)*SIN(A)
      DE=DE+7D0*COS(A)
!  17
      A=ELP+OM
      DP=DP-15D0*SIN(A)
      DE=DE+9D0*COS(A)
!  16
      DP=DP+(17D0-0.1D0*T)*SIN(ELP2)
!  15
      DP=DP-22D0*SIN(F2-D2)
!  14
      A=EL2-D2
      DP=DP+48D0*SIN(A)
      DE=DE+COS(A)
!  13
      A=F2-D2+OM
      DP=DP+(129D0+0.1D0*T)*SIN(A)
      DE=DE-70D0*COS(A)
!  12
      A=-ELP+F2-D2+OM2
      DP=DP+(217D0-0.5D0*T)*SIN(A)
      DE=DE+(-95D0+0.3D0*T)*COS(A)
!  11
      A=ELP+F2-D2+OM2
      DP=DP+(-517D0+1.2D0*T)*SIN(A)
      DE=DE+(224D0-0.6D0*T)*COS(A)
!  10
      DP=DP+(1426D0-3.4D0*T)*SIN(ELP)
      DE=DE+(54D0-0.1D0*T)*COS(ELP)
!  9
      A=F2-D2+OM2
      DP=DP+(-13187D0-1.6D0*T)*SIN(A)
      DE=DE+(5736D0-3.1D0*T)*COS(A)
!  8
      DP=DP+SIN(EL2-F2+OM)
!  7
      A=-ELP2+F2-D2+OM
      DP=DP-2D0*SIN(A)
      DE=DE+1D0*COS(A)
!  6
      DP=DP-3D0*SIN(EL-ELP-D)
!  5
      A=-EL2+F2+OM2
      DP=DP-3D0*SIN(A)
      DE=DE+1D0*COS(A)
!  4
      DP=DP+11D0*SIN(EL2-F2)
!  3
      A=-EL2+F2+OM
      DP=DP+46D0*SIN(A)
      DE=DE-24D0*COS(A)
!  2
      DP=DP+(2062D0+0.2D0*T)*SIN(OM2)
      DE=DE+(-895D0+0.5D0*T)*COS(OM2)
!  1
      DP=DP+(-171996D0-174.2D0*T)*SIN(OM)
      DE=DE+(92025D0+8.9D0*T)*COS(OM)

!  Convert results to radians
      DPSI=DP*U2R
      DEPS=DE*U2R

!  Mean obliquity
      EPS0=AS2R*(84381.448D0+ &
                (-46.8150D0+ &
                (-0.00059D0+ &
                0.001813D0*T)*T)*T)

      END
      SUBROUTINE sla_OAP (TYPE, OB1, OB2, DATE, DUT, ELONGM, PHIM, &
                         HM, XP, YP, TDK, PMB, RH, WL, TLR, &
                         RAP, DAP)
!+
!     - - - -
!      O A P
!     - - - -
!
!  Observed to apparent place
!
!  Given:
!     TYPE   c*(*)  type of coordinates - 'R', 'H' or 'A' (see below)
!     OB1    d      observed Az, HA or RA (radians; Az is N=0,E=90)
!     OB2    d      observed ZD or Dec (radians)
!     DATE   d      UTC date/time (modified Julian Date, JD-2400000.5)
!     DUT    d      delta UT:  UT1-UTC (UTC seconds)
!     ELONGM d      mean longitude of the observer (radians, east +ve)
!     PHIM   d      mean geodetic latitude of the observer (radians)
!     HM     d      observer's height above sea level (metres)
!     XP     d      polar motion x-coordinate (radians)
!     YP     d      polar motion y-coordinate (radians)
!     TDK    d      local ambient temperature (DegK; std=273.15D0)
!     PMB    d      local atmospheric pressure (mB; std=1013.25D0)
!     RH     d      local relative humidity (in the range 0D0-1D0)
!     WL     d      effective wavelength (micron, e.g. 0.55D0)
!     TLR    d      tropospheric lapse rate (DegK/metre, e.g. 0.0065D0)
!
!  Returned:
!     RAP    d      geocentric apparent right ascension
!     DAP    d      geocentric apparent declination
!
!  Notes:
!
!  1)  Only the first character of the TYPE argument is significant.
!      'R' or 'r' indicates that OBS1 and OBS2 are the observed Right
!      Ascension and Declination;  'H' or 'h' indicates that they are
!      Hour Angle (West +ve) and Declination;  anything else ('A' or
!      'a' is recommended) indicates that OBS1 and OBS2 are Azimuth
!      (North zero, East is 90 deg) and zenith distance.  (Zenith
!      distance is used rather than elevation in order to reflect the
!      fact that no allowance is made for depression of the horizon.)
!
!  2)  The accuracy of the result is limited by the corrections for
!      refraction.  Providing the meteorological parameters are
!      known accurately and there are no gross local effects, the
!      predicted apparent RA,Dec should be within about 0.1 arcsec
!      for a zenith distance of less than 70 degrees.  Even at a
!      topocentric zenith distance of 90 degrees, the accuracy in
!      elevation should be better than 1 arcmin;  useful results
!      are available for a further 3 degrees, beyond which the
!      sla_REFRO routine returns a fixed value of the refraction.
!      The complementary routines sla_AOP (or sla_AOPQK) and sla_OAP
!      (or sla_OAPQK) are self-consistent to better than 1 micro-
!      arcsecond all over the celestial sphere.
!
!  3)  It is advisable to take great care with units, as even
!      unlikely values of the input parameters are accepted and
!      processed in accordance with the models used.
!
!  4)  "Observed" Az,El means the position that would be seen by a
!      perfect theodolite located at the observer.  This is
!      related to the observed HA,Dec via the standard rotation, using
!      the geodetic latitude (corrected for polar motion), while the
!      observed HA and RA are related simply through the local
!      apparent ST.  "Observed" RA,Dec or HA,Dec thus means the
!      position that would be seen by a perfect equatorial located
!      at the observer and with its polar axis aligned to the
!      Earth's axis of rotation (n.b. not to the refracted pole).
!      By removing from the observed place the effects of
!      atmospheric refraction and diurnal aberration, the
!      geocentric apparent RA,Dec is obtained.
!
!  5)  Frequently, mean rather than apparent RA,Dec will be required,
!      in which case further transformations will be necessary.  The
!      sla_AMP etc routines will convert the apparent RA,Dec produced
!      by the present routine into an "FK5" (J2000) mean place, by
!      allowing for the Sun's gravitational lens effect, annual
!      aberration, nutation and precession.  Should "FK4" (1950)
!      coordinates be needed, the routines sla_FK524 etc will also
!      need to be applied.
!
!  6)  To convert to apparent RA,Dec the coordinates read from a
!      real telescope, corrections would have to be applied for
!      encoder zero points, gear and encoder errors, tube flexure,
!      the position of the rotator axis and the pointing axis
!      relative to it, non-perpendicularity between the mounting
!      axes, and finally for the tilt of the azimuth or polar axis
!      of the mounting (with appropriate corrections for mount
!      flexures).  Some telescopes would, of course, exhibit other
!      properties which would need to be accounted for at the
!      appropriate point in the sequence.
!
!  7)  The star-independent apparent-to-observed-place parameters
!      in AOPRMS may be computed by means of the sla_AOPPA routine.
!      If nothing has changed significantly except the time, the
!      sla_AOPPAT routine may be used to perform the requisite
!      partial recomputation of AOPRMS.
!
!  8)  The DATE argument is UTC expressed as an MJD.  This is,
!      strictly speaking, wrong, because of leap seconds.  However,
!      as long as the delta UT and the UTC are consistent there
!      are no difficulties, except during a leap second.  In this
!      case, the start of the 61st second of the final minute should
!      begin a new MJD day and the old pre-leap delta UT should
!      continue to be used.  As the 61st second completes, the MJD
!      should revert to the start of the day as, simultaneously,
!      the delta UTC changes by one second to its post-leap new value.
!
!  9)  The delta UT (UT1-UTC) is tabulated in IERS circulars and
!      elsewhere.  It increases by exactly one second at the end of
!      each UTC leap second, introduced in order to keep delta UT
!      within +/- 0.9 seconds.
!
!  10) IMPORTANT -- TAKE CARE WITH THE LONGITUDE SIGN CONVENTION.
!      The longitude required by the present routine is east-positive,
!      in accordance with geographical convention (and right-handed).
!      In particular, note that the longitudes returned by the
!      sla_OBS routine are west-positive, following astronomical
!      usage, and must be reversed in sign before use in the present
!      routine.
!
!  11) The polar coordinates XP,YP can be obtained from IERS
!      circulars and equivalent publications.  The maximum amplitude
!      is about 0.3 arcseconds.  If XP,YP values are unavailable,
!      use XP=YP=0D0.  See page B60 of the 1988 Astronomical Almanac
!      for a definition of the two angles.
!
!  12) The height above sea level of the observing station, HM,
!      can be obtained from the Astronomical Almanac (Section J
!      in the 1988 edition), or via the routine sla_OBS.  If P,
!      the pressure in millibars, is available, an adequate
!      estimate of HM can be obtained from the expression
!
!             HM ~ -29.3D0*TSL*LOG(P/1013.25D0).
!
!      where TSL is the approximate sea-level air temperature in
!      deg K (see Astrophysical Quantities, C.W.Allen, 3rd edition,
!      section 52).  Similarly, if the pressure P is not known,
!      it can be estimated from the height of the observing
!      station, HM as follows:
!
!             P ~ 1013.25D0*EXP(-HM/(29.3D0*TSL)).
!
!      Note, however, that the refraction is proportional to the
!      pressure and that an accurate P value is important for
!      precise work.
!
!  13) The azimuths etc used by the present routine are with respect
!      to the celestial pole.  Corrections from the terrestrial pole
!      can be computed using sla_POLMO.
!
!  Called:  sla_AOPPA, sla_OAPQK
!
!  P.T.Wallace   Starlink   23 May 2002
!
!  Copyright (C) 2002 P.T.Wallace and CCLRC
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) TYPE
      DOUBLE PRECISION OB1,OB2,DATE,DUT,ELONGM,PHIM,HM, &
                      XP,YP,TDK,PMB,RH,WL,TLR,RAP,DAP

      DOUBLE PRECISION AOPRMS(14)


      CALL sla_AOPPA(DATE,DUT,ELONGM,PHIM,HM,XP,YP,TDK,PMB,RH,WL,TLR, &
                    AOPRMS)
      CALL sla_OAPQK(TYPE,OB1,OB2,AOPRMS,RAP,DAP)

      END
      SUBROUTINE sla_OAPQK (TYPE, OB1, OB2, AOPRMS, RAP, DAP)
!+
!     - - - - - -
!      O A P Q K
!     - - - - - -
!
!  Quick observed to apparent place
!
!  Given:
!     TYPE   c*(*)  type of coordinates - 'R', 'H' or 'A' (see below)
!     OB1    d      observed Az, HA or RA (radians; Az is N=0,E=90)
!     OB2    d      observed ZD or Dec (radians)
!     AOPRMS d(14)  star-independent apparent-to-observed parameters:
!
!       (1)      geodetic latitude (radians)
!       (2,3)    sine and cosine of geodetic latitude
!       (4)      magnitude of diurnal aberration vector
!       (5)      height (HM)
!       (6)      ambient temperature (T)
!       (7)      pressure (P)
!       (8)      relative humidity (RH)
!       (9)      wavelength (WL)
!       (10)     lapse rate (TLR)
!       (11,12)  refraction constants A and B (radians)
!       (13)     longitude + eqn of equinoxes + sidereal DUT (radians)
!       (14)     local apparent sidereal time (radians)
!
!  Returned:
!     RAP    d      geocentric apparent right ascension
!     DAP    d      geocentric apparent declination
!
!  Notes:
!
!  1)  Only the first character of the TYPE argument is significant.
!      'R' or 'r' indicates that OBS1 and OBS2 are the observed Right
!      Ascension and Declination;  'H' or 'h' indicates that they are
!      Hour Angle (West +ve) and Declination;  anything else ('A' or
!      'a' is recommended) indicates that OBS1 and OBS2 are Azimuth
!      (North zero, East is 90 deg) and zenith distance.  (Zenith
!      distance is used rather than elevation in order to reflect the
!      fact that no allowance is made for depression of the horizon.)
!
!  2)  The accuracy of the result is limited by the corrections for
!      refraction.  Providing the meteorological parameters are
!      known accurately and there are no gross local effects, the
!      predicted apparent RA,Dec should be within about 0.1 arcsec
!      for a zenith distance of less than 70 degrees.  Even at a
!      topocentric zenith distance of 90 degrees, the accuracy in
!      elevation should be better than 1 arcmin;  useful results
!      are available for a further 3 degrees, beyond which the
!      sla_REFRO routine returns a fixed value of the refraction.
!      The complementary routines sla_AOP (or sla_AOPQK) and sla_OAP
!      (or sla_OAPQK) are self-consistent to better than 1 micro-
!      arcsecond all over the celestial sphere.
!
!  3)  It is advisable to take great care with units, as even
!      unlikely values of the input parameters are accepted and
!      processed in accordance with the models used.
!
!  5)  "Observed" Az,El means the position that would be seen by a
!      perfect theodolite located at the observer.  This is
!      related to the observed HA,Dec via the standard rotation, using
!      the geodetic latitude (corrected for polar motion), while the
!      observed HA and RA are related simply through the local
!      apparent ST.  "Observed" RA,Dec or HA,Dec thus means the
!      position that would be seen by a perfect equatorial located
!      at the observer and with its polar axis aligned to the
!      Earth's axis of rotation (n.b. not to the refracted pole).
!      By removing from the observed place the effects of
!      atmospheric refraction and diurnal aberration, the
!      geocentric apparent RA,Dec is obtained.
!
!  5)  Frequently, mean rather than apparent RA,Dec will be required,
!      in which case further transformations will be necessary.  The
!      sla_AMP etc routines will convert the apparent RA,Dec produced
!      by the present routine into an "FK5" (J2000) mean place, by
!      allowing for the Sun's gravitational lens effect, annual
!      aberration, nutation and precession.  Should "FK4" (1950)
!      coordinates be needed, the routines sla_FK524 etc will also
!      need to be applied.
!
!  6)  To convert to apparent RA,Dec the coordinates read from a
!      real telescope, corrections would have to be applied for
!      encoder zero points, gear and encoder errors, tube flexure,
!      the position of the rotator axis and the pointing axis
!      relative to it, non-perpendicularity between the mounting
!      axes, and finally for the tilt of the azimuth or polar axis
!      of the mounting (with appropriate corrections for mount
!      flexures).  Some telescopes would, of course, exhibit other
!      properties which would need to be accounted for at the
!      appropriate point in the sequence.
!
!  7)  The star-independent apparent-to-observed-place parameters
!      in AOPRMS may be computed by means of the sla_AOPPA routine.
!      If nothing has changed significantly except the time, the
!      sla_AOPPAT routine may be used to perform the requisite
!      partial recomputation of AOPRMS.
!
!  8) The azimuths etc used by the present routine are with respect
!     to the celestial pole.  Corrections from the terrestrial pole
!     can be computed using sla_POLMO.
!
!  Called:  sla_DCS2C, sla_DCC2S, sla_REFRO, sla_DRANRM
!
!  P.T.Wallace   Starlink   23 June 1997
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER*(*) TYPE
      DOUBLE PRECISION OB1,OB2,AOPRMS(14),RAP,DAP

!  Breakpoint for fast/slow refraction algorithm:
!  ZD greater than arctan(4), (see sla_REFCO routine)
!  or vector Z less than cosine(arctan(Z)) = 1/sqrt(17)
      DOUBLE PRECISION ZBREAK
      PARAMETER (ZBREAK=0.242535625D0)

      CHARACTER C
      DOUBLE PRECISION C1,C2,SPHI,CPHI,ST,CE,XAEO,YAEO,ZAEO,V(3), &
                      XMHDO,YMHDO,ZMHDO,AZ,SZ,ZDO,TZ,DREF,ZDT, &
                      XAET,YAET,ZAET,XMHDA,YMHDA,ZMHDA,DIURAB,F,HMA

      DOUBLE PRECISION sla_DRANRM



!  Coordinate type
      C = TYPE(1:1)

!  Coordinates
      C1 = OB1
      C2 = OB2

!  Sin, cos of latitude
      SPHI = AOPRMS(2)
      CPHI = AOPRMS(3)

!  Local apparent sidereal time
      ST = AOPRMS(14)

!  Standardise coordinate type
      IF (C.EQ.'R'.OR.C.EQ.'r') THEN
         C = 'R'
      ELSE IF (C.EQ.'H'.OR.C.EQ.'h') THEN
         C = 'H'
      ELSE
         C = 'A'
      END IF

!  If Az,ZD convert to Cartesian (S=0,E=90)
      IF (C.EQ.'A') THEN
         CE = SIN(C2)
         XAEO = -COS(C1)*CE
         YAEO = SIN(C1)*CE
         ZAEO = COS(C2)
      ELSE

!     If RA,Dec convert to HA,Dec
         IF (C.EQ.'R') THEN
            C1 = ST-C1
         END IF

!     To Cartesian -HA,Dec
         CALL sla_DCS2C(-C1,C2,V)
         XMHDO = V(1)
         YMHDO = V(2)
         ZMHDO = V(3)

!     To Cartesian Az,El (S=0,E=90)
         XAEO = SPHI*XMHDO-CPHI*ZMHDO
         YAEO = YMHDO
         ZAEO = CPHI*XMHDO+SPHI*ZMHDO
      END IF

!  Azimuth (S=0,E=90)
      IF (XAEO.NE.0D0.OR.YAEO.NE.0D0) THEN
         AZ = ATAN2(YAEO,XAEO)
      ELSE
         AZ = 0D0
      END IF

!  Sine of observed ZD, and observed ZD
      SZ = SQRT(XAEO*XAEO+YAEO*YAEO)
      ZDO = ATAN2(SZ,ZAEO)

!
!  Refraction
!  ----------

!  Large zenith distance?
      IF (ZAEO.GE.ZBREAK) THEN

!     Fast algorithm using two constant model
         TZ = SZ/ZAEO
         DREF = AOPRMS(11)*TZ+AOPRMS(12)*TZ*TZ*TZ

      ELSE

!     Rigorous algorithm for large ZD
         CALL sla_REFRO(ZDO,AOPRMS(5),AOPRMS(6),AOPRMS(7),AOPRMS(8), &
                       AOPRMS(9),AOPRMS(1),AOPRMS(10),1D-8,DREF)
      END IF

      ZDT = ZDO+DREF

!  To Cartesian Az,ZD
      CE = SIN(ZDT)
      XAET = COS(AZ)*CE
      YAET = SIN(AZ)*CE
      ZAET = COS(ZDT)

!  Cartesian Az,ZD to Cartesian -HA,Dec
      XMHDA = SPHI*XAET+CPHI*ZAET
      YMHDA = YAET
      ZMHDA = -CPHI*XAET+SPHI*ZAET

!  Diurnal aberration
      DIURAB = -AOPRMS(4)
      F = (1D0-DIURAB*YMHDA)
      V(1) = F*XMHDA
      V(2) = F*(YMHDA+DIURAB)
      V(3) = F*ZMHDA

!  To spherical -HA,Dec
      CALL sla_DCC2S(V,HMA,DAP)

!  Right Ascension
      RAP = sla_DRANRM(ST+HMA)

      END
      SUBROUTINE sla_OBS (N, C, NAME, W, P, H)
!+
!     - - - -
!      O B S
!     - - - -
!
!  Parameters of selected groundbased observing stations
!
!  Given:
!     N       int     number specifying observing station
!
!  Either given or returned
!     C       c*(*)   identifier specifying observing station
!
!  Returned:
!     NAME    c*(*)   name of specified observing station
!     W       dp      longitude (radians, West +ve)
!     P       dp      geodetic latitude (radians, North +ve)
!     H       dp      height above sea level (metres)
!
!  Notes:
!
!     Station identifiers C may be up to 10 characters long,
!     and station names NAME may be up to 40 characters long.
!
!     C and N are alternative ways of specifying the observing
!     station.  The C option, which is the most generally useful,
!     may be selected by specifying an N value of zero or less.
!     If N is 1 or more, the parameters of the Nth station
!     in the currently supported list are interrogated, and
!     the station identifier C is returned as well as NAME, W,
!     P and H.
!
!     If the station parameters are not available, either because
!     the station identifier C is not recognized, or because an
!     N value greater than the number of stations supported is
!     given, a name of '?' is returned and C, W, P and H are left
!     in their current states.
!
!     Programs can obtain a list of all currently supported
!     stations by calling the routine repeatedly, with N=1,2,3...
!     When NAME='?' is seen, the list of stations has been
!     exhausted.
!
!     Station numbers, identifiers, names and other details are
!     subject to change and should not be hardwired into
!     application programs.
!
!     All station identifiers C are uppercase only;  lowercase
!     characters must be converted to uppercase by the calling
!     program.  The station names returned may contain both upper-
!     and lowercase.  All characters up to the first space are
!     checked;  thus an abbreviated ID will return the parameters
!     for the first station in the list which matches the
!     abbreviation supplied, and no station in the list will ever
!     contain embedded spaces.  C must not have leading spaces.
!
!     IMPORTANT -- BEWARE OF THE LONGITUDE SIGN CONVENTION.  The
!     longitude returned by sla_OBS is west-positive in accordance
!     with astronomical usage.  However, this sign convention is
!     left-handed and is the opposite of the one used by geographers;
!     elsewhere in SLALIB the preferable east-positive convention is
!     used.  In particular, note that for use in sla_AOP, sla_AOPPA
!     and sla_OAP the sign of the longitude must be reversed.
!
!     Users are urged to inform the author of any improvements
!     they would like to see made.  For example:
!
!         typographical corrections
!         more accurate parameters
!         better station identifiers or names
!         additional stations
!
!  P.T.Wallace   Starlink   15 March 2002
!
!  Copyright (C) 2002 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER N
      CHARACTER C*(*),NAME*(*)
      DOUBLE PRECISION W,P,H

      INTEGER NMAX,M,NS,I
      CHARACTER*10 CC

      DOUBLE PRECISION AS2R,WEST,NORTH,EAST,SOUTH
      INTEGER ID,IAM
      REAL AS
      PARAMETER (AS2R=0.484813681109535994D-5)

!  Table of station identifiers
      PARAMETER (NMAX=83)
      CHARACTER*10 CTAB(NMAX)
      DATA CTAB  (1) /'AAT       '/
      DATA CTAB  (2) /'LPO4.2    '/
      DATA CTAB  (3) /'LPO2.5    '/
      DATA CTAB  (4) /'LPO1      '/
      DATA CTAB  (5) /'LICK120   '/
      DATA CTAB  (6) /'MMT       '/
      DATA CTAB  (7) /'DAO72     '/
      DATA CTAB  (8) /'DUPONT    '/
      DATA CTAB  (9) /'MTHOP1.5  '/
      DATA CTAB (10) /'STROMLO74 '/
      DATA CTAB (11) /'ANU2.3    '/
      DATA CTAB (12) /'GBVA140   '/
      DATA CTAB (13) /'TOLOLO4M  '/
      DATA CTAB (14) /'TOLOLO1.5M'/
      DATA CTAB (15) /'TIDBINBLA '/
      DATA CTAB (16) /'BLOEMF    '/
      DATA CTAB (17) /'BOSQALEGRE'/
      DATA CTAB (18) /'FLAGSTF61 '/
      DATA CTAB (19) /'LOWELL72  '/
      DATA CTAB (20) /'HARVARD   '/
      DATA CTAB (21) /'OKAYAMA   '/
      DATA CTAB (22) /'KPNO158   '/
      DATA CTAB (23) /'KPNO90    '/
      DATA CTAB (24) /'KPNO84    '/
      DATA CTAB (25) /'KPNO36FT  '/
      DATA CTAB (26) /'KOTTAMIA  '/
      DATA CTAB (27) /'ESO3.6    '/
      DATA CTAB (28) /'MAUNAK88  '/
      DATA CTAB (29) /'UKIRT     '/
      DATA CTAB (30) /'QUEBEC1.6 '/
      DATA CTAB (31) /'MTEKAR    '/
      DATA CTAB (32) /'MTLEMMON60'/
      DATA CTAB (33) /'MCDONLD2.7'/
      DATA CTAB (34) /'MCDONLD2.1'/
      DATA CTAB (35) /'PALOMAR200'/
      DATA CTAB (36) /'PALOMAR60 '/
      DATA CTAB (37) /'DUNLAP74  '/
      DATA CTAB (38) /'HPROV1.93 '/
      DATA CTAB (39) /'HPROV1.52 '/
      DATA CTAB (40) /'SANPM83   '/
      DATA CTAB (41) /'SAAO74    '/
      DATA CTAB (42) /'TAUTNBG   '/
      DATA CTAB (43) /'CATALINA61'/
      DATA CTAB (44) /'STEWARD90 '/
      DATA CTAB (45) /'USSR6     '/
      DATA CTAB (46) /'ARECIBO   '/
      DATA CTAB (47) /'CAMB5KM   '/
      DATA CTAB (48) /'CAMB1MILE '/
      DATA CTAB (49) /'EFFELSBERG'/
      DATA CTAB (50) /'GBVA300   '/
      DATA CTAB (51) /'JODRELL1  '/
      DATA CTAB (52) /'PARKES    '/
      DATA CTAB (53) /'VLA       '/
      DATA CTAB (54) /'SUGARGROVE'/
      DATA CTAB (55) /'USSR600   '/
      DATA CTAB (56) /'NOBEYAMA  '/
      DATA CTAB (57) /'JCMT      '/
      DATA CTAB (58) /'ESONTT    '/
      DATA CTAB (59) /'ST.ANDREWS'/
      DATA CTAB (60) /'APO3.5    '/
      DATA CTAB (61) /'KECK1     '/
      DATA CTAB (62) /'TAUTSCHM  '/
      DATA CTAB (63) /'PALOMAR48 '/
      DATA CTAB (64) /'UKST      '/
      DATA CTAB (65) /'KISO      '/
      DATA CTAB (66) /'ESOSCHM   '/
      DATA CTAB (67) /'ATCA      '/
      DATA CTAB (68) /'MOPRA     '/
      DATA CTAB (69) /'SUBARU    '/
      DATA CTAB (70) /'CFHT      '/
      DATA CTAB (71) /'KECK2     '/
      DATA CTAB (72) /'GEMININ   '/
      DATA CTAB (73) /'FCRAO     '/
      DATA CTAB (74) /'IRTF      '/
      DATA CTAB (75) /'CSO       '/
      DATA CTAB (76) /'VLT1      '/
      DATA CTAB (77) /'VLT2      '/
      DATA CTAB (78) /'VLT3      '/
      DATA CTAB (79) /'VLT4      '/
      DATA CTAB (80) /'GEMINIS   '/
      DATA CTAB (81) /'KOSMA3M   '/
      DATA CTAB (82) /'MAGELLAN1 '/
      DATA CTAB (83) /'MAGELLAN2 '/

!  Degrees, arcminutes, arcseconds to radians
      WEST(ID,IAM,AS)=AS2R*(DBLE(60*(60*ID+IAM))+DBLE(AS))
      NORTH(ID,IAM,AS)=WEST(ID,IAM,AS)
      EAST(ID,IAM,AS)=-WEST(ID,IAM,AS)
      SOUTH(ID,IAM,AS)=-WEST(ID,IAM,AS)




!  Station specified by number or identifier?
      IF (N.GT.0) THEN

!     Station specified by number
         M=N
         IF (M.LE.NMAX) C=CTAB(M)

      ELSE

!     Station specified by identifier:  determine corresponding number
         CC=C
         DO NS=1,NMAX
            DO I=1,10
               IF (CC(I:I).EQ.' ') GO TO 5
               IF (CC(I:I).NE.CTAB(NS)(I:I)) GO TO 1
            END DO
            GO TO 5
 1          CONTINUE
         END DO
         NS=NMAX+1
 5       CONTINUE
         IF (C(1:1).NE.' ') THEN
            M=NS
         ELSE
            M=NMAX+1
         END IF

      END IF

!
!  Return parameters of Mth station
!  --------------------------------

      GO TO (10,20,30,40,50,60,70,80,90,100, &
            110,120,130,140,150,160,170,180,190,200, &
            210,220,230,240,250,260,270,280,290,300, &
            310,320,330,340,350,360,370,380,390,400, &
            410,420,430,440,450,460,470,480,490,500, &
            510,520,530,540,550,560,570,580,590,600, &
            610,620,630,640,650,660,670,680,690,700, &
            710,720,730,740,750,760,770,780,790,800, &
            810,820,830) M
      GO TO 9000

!  AAT (Observer's Guide)                                            AAT
 10   CONTINUE
      NAME='Anglo-Australian 3.9m Telescope'
      W=EAST(149,03,57.91)
      P=SOUTH(31,16,37.34)
      H=1164D0
      GO TO 9999

!  WHT (Gemini, April 1987)                                       LPO4.2
 20   CONTINUE
      NAME='William Herschel 4.2m Telescope'
      W=WEST(17,52,53.9)
      P=NORTH(28,45,38.1)
      H=2332D0
      GO TO 9999

!  INT (Gemini, April 1987)                                       LPO2.5
 30   CONTINUE
      NAME='Isaac Newton 2.5m Telescope'
      W=WEST(17,52,39.5)
      P=NORTH(28,45,43.2)
      H=2336D0
      GO TO 9999

!  JKT (Gemini, April 1987)                                         LPO1
 40   CONTINUE
      NAME='Jacobus Kapteyn 1m Telescope'
      W=WEST(17,52,41.2)
      P=NORTH(28,45,39.9)
      H=2364D0
      GO TO 9999

!  Lick 120" (S.L.Allen, private communication, 2002)            LICK120
 50   CONTINUE
      NAME='Lick 120 inch'
      W=WEST(121,38,13.689)
      P=NORTH(37,20,34.931)
      H=1286D0
      GO TO 9999

!  MMT 6.5m conversion (MMT Observatory website)                     MMT
 60   CONTINUE
      NAME='MMT 6.5m, Mt Hopkins'
      W=WEST(110,53,04.4)
      P=NORTH(31,41,19.6)
      H=2608D0
      GO TO 9999

!  Victoria B.C. 1.85m (1984 Almanac)                              DAO72
 70   CONTINUE
      NAME='DAO Victoria BC 1.85 metre'
      W=WEST(123,25,01.18)
      P=NORTH(48,31,11.9)
      H=238D0
      GO TO 9999

!  Las Campanas (1983 Almanac)                                    DUPONT
 80   CONTINUE
      NAME='Du Pont 2.5m Telescope, Las Campanas'
      W=WEST(70,42,9.)
      P=SOUTH(29,00,11.)
      H=2280D0
      GO TO 9999

!  Mt Hopkins 1.5m (1983 Almanac)                               MTHOP1.5
 90   CONTINUE
      NAME='Mt Hopkins 1.5 metre'
      W=WEST(110,52,39.00)
      P=NORTH(31,40,51.4)
      H=2344D0
      GO TO 9999

!  Mt Stromlo 74" (1983 Almanac)                               STROMLO74
 100  CONTINUE
      NAME='Mount Stromlo 74 inch'
      W=EAST(149,00,27.59)
      P=SOUTH(35,19,14.3)
      H=767D0
      GO TO 9999

!  ANU 2.3m, SSO (Gary Hovey)                                     ANU2.3
 110  CONTINUE
      NAME='Siding Spring 2.3 metre'
      W=EAST(149,03,40.3)
      P=SOUTH(31,16,24.1)
      H=1149D0
      GO TO 9999

!  Greenbank 140' (1983 Almanac)                                 GBVA140
 120  CONTINUE
      NAME='Greenbank 140 foot'
      W=WEST(79,50,09.61)
      P=NORTH(38,26,15.4)
      H=881D0
      GO TO 9999

!  Cerro Tololo 4m (1982 Almanac)                               TOLOLO4M
 130  CONTINUE
      NAME='Cerro Tololo 4 metre'
      W=WEST(70,48,53.6)
      P=SOUTH(30,09,57.8)
      H=2235D0
      GO TO 9999

!  Cerro Tololo 1.5m (1982 Almanac)                           TOLOLO1.5M
 140  CONTINUE
      NAME='Cerro Tololo 1.5 metre'
      W=WEST(70,48,54.5)
      P=SOUTH(30,09,56.3)
      H=2225D0
      GO TO 9999

!  Tidbinbilla 64m (1982 Almanac)                              TIDBINBLA
 150  CONTINUE
      NAME='Tidbinbilla 64 metre'
      W=EAST(148,58,48.20)
      P=SOUTH(35,24,14.3)
      H=670D0
      GO TO 9999

!  Bloemfontein 1.52m (1981 Almanac)                              BLOEMF
 160  CONTINUE
      NAME='Bloemfontein 1.52 metre'
      W=EAST(26,24,18.)
      P=SOUTH(29,02,18.)
      H=1387D0
      GO TO 9999

!  Bosque Alegre 1.54m (1981 Almanac)                         BOSQALEGRE
 170  CONTINUE
      NAME='Bosque Alegre 1.54 metre'
      W=WEST(64,32,48.0)
      P=SOUTH(31,35,53.)
      H=1250D0
      GO TO 9999

!  USNO 61" astrographic reflector, Flagstaff (1981 Almanac)   FLAGSTF61
 180  CONTINUE
      NAME='USNO 61 inch astrograph, Flagstaff'
      W=WEST(111,44,23.6)
      P=NORTH(35,11,02.5)
      H=2316D0
      GO TO 9999

!  Lowell 72" (1981 Almanac)                                    LOWELL72
 190  CONTINUE
      NAME='Perkins 72 inch, Lowell'
      W=WEST(111,32,09.3)
      P=NORTH(35,05,48.6)
      H=2198D0
      GO TO 9999

!  Harvard 1.55m (1981 Almanac)                                  HARVARD
 200  CONTINUE
      NAME='Harvard College Observatory 1.55m'
      W=WEST(71,33,29.32)
      P=NORTH(42,30,19.0)
      H=185D0
      GO TO 9999

!  Okayama 1.88m (1981 Almanac)                                  OKAYAMA
 210  CONTINUE
      NAME='Okayama 1.88 metre'
      W=EAST(133,35,47.29)
      P=NORTH(34,34,26.1)
      H=372D0
      GO TO 9999

!  Kitt Peak Mayall 4m (1981 Almanac)                            KPNO158
 220  CONTINUE
      NAME='Kitt Peak 158 inch'
      W=WEST(111,35,57.61)
      P=NORTH(31,57,50.3)
      H=2120D0
      GO TO 9999

!  Kitt Peak 90 inch (1981 Almanac)                               KPNO90
 230  CONTINUE
      NAME='Kitt Peak 90 inch'
      W=WEST(111,35,58.24)
      P=NORTH(31,57,46.9)
      H=2071D0
      GO TO 9999

!  Kitt Peak 84 inch (1981 Almanac)                               KPNO84
 240  CONTINUE
      NAME='Kitt Peak 84 inch'
      W=WEST(111,35,51.56)
      P=NORTH(31,57,29.2)
      H=2096D0
      GO TO 9999

!  Kitt Peak 36 foot (1981 Almanac)                             KPNO36FT
 250  CONTINUE
      NAME='Kitt Peak 36 foot'
      W=WEST(111,36,51.12)
      P=NORTH(31,57,12.1)
      H=1939D0
      GO TO 9999

!  Kottamia 74" (1981 Almanac)                                  KOTTAMIA
 260  CONTINUE
      NAME='Kottamia 74 inch'
      W=EAST(31,49,30.)
      P=NORTH(29,55,54.)
      H=476D0
      GO TO 9999

!  La Silla 3.6m (1981 Almanac)                                   ESO3.6
 270  CONTINUE
      NAME='ESO 3.6 metre'
      W=WEST(70,43,36.)
      P=SOUTH(29,15,36.)
      H=2428D0
      GO TO 9999

!  Mauna Kea 88 inch                                            MAUNAK88
!  (IfA website, Richard Wainscoat)
 280  CONTINUE
      NAME='Mauna Kea 88 inch'
      W=WEST(155,28,09.96)
      P=NORTH(19,49,22.77)
      H=4213.6D0
      GO TO 9999

!  UKIRT (IfA website, Richard Wainscoat)                          UKIRT
 290  CONTINUE
      NAME='UK Infra Red Telescope'
      W=WEST(155,28,13.18)
      P=NORTH(19,49,20.75)
      H=4198.5D0
      GO TO 9999

!  Quebec 1.6m (1981 Almanac)                                  QUEBEC1.6
 300  CONTINUE
      NAME='Quebec 1.6 metre'
      W=WEST(71,09,09.7)
      P=NORTH(45,27,20.6)
      H=1114D0
      GO TO 9999

!  Mt Ekar 1.82m (1981 Almanac)                                   MTEKAR
 310  CONTINUE
      NAME='Mt Ekar 1.82 metre'
      W=EAST(11,34,15.)
      P=NORTH(45,50,48.)
      H=1365D0
      GO TO 9999

!  Mt Lemmon 60" (1981 Almanac)                               MTLEMMON60
 320  CONTINUE
      NAME='Mt Lemmon 60 inch'
      W=WEST(110,42,16.9)
      P=NORTH(32,26,33.9)
      H=2790D0
      GO TO 9999

!  Mt Locke 2.7m (1981 Almanac)                               MCDONLD2.7
 330  CONTINUE
      NAME='McDonald 2.7 metre'
      W=WEST(104,01,17.60)
      P=NORTH(30,40,17.7)
      H=2075D0
      GO TO 9999

!  Mt Locke 2.1m (1981 Almanac)                               MCDONLD2.1
 340  CONTINUE
      NAME='McDonald 2.1 metre'
      W=WEST(104,01,20.10)
      P=NORTH(30,40,17.7)
      H=2075D0
      GO TO 9999

!  Palomar 200" (1981 Almanac)                                PALOMAR200
 350  CONTINUE
      NAME='Palomar 200 inch'
      W=WEST(116,51,50.)
      P=NORTH(33,21,22.)
      H=1706D0
      GO TO 9999

!  Palomar 60" (1981 Almanac)                                  PALOMAR60
 360  CONTINUE
      NAME='Palomar 60 inch'
      W=WEST(116,51,31.)
      P=NORTH(33,20,56.)
      H=1706D0
      GO TO 9999

!  David Dunlap 74" (1981 Almanac)                              DUNLAP74
 370  CONTINUE
      NAME='David Dunlap 74 inch'
      W=WEST(79,25,20.)
      P=NORTH(43,51,46.)
      H=244D0
      GO TO 9999

!  Haute Provence 1.93m (1981 Almanac)                         HPROV1.93
 380  CONTINUE
      NAME='Haute Provence 1.93 metre'
      W=EAST(5,42,46.75)
      P=NORTH(43,55,53.3)
      H=665D0
      GO TO 9999

!  Haute Provence 1.52m (1981 Almanac)                         HPROV1.52
 390  CONTINUE
      NAME='Haute Provence 1.52 metre'
      W=EAST(5,42,43.82)
      P=NORTH(43,56,00.2)
      H=667D0
      GO TO 9999

!  San Pedro Martir 83" (1981 Almanac)                           SANPM83
 400  CONTINUE
      NAME='San Pedro Martir 83 inch'
      W=WEST(115,27,47.)
      P=NORTH(31,02,38.)
      H=2830D0
      GO TO 9999

!  Sutherland 74" (1981 Almanac)                                  SAAO74
 410  CONTINUE
      NAME='Sutherland 74 inch'
      W=EAST(20,48,44.3)
      P=SOUTH(32,22,43.4)
      H=1771D0
      GO TO 9999

!  Tautenburg 2m (1981 Almanac)                                  TAUTNBG
 420  CONTINUE
      NAME='Tautenburg 2 metre'
      W=EAST(11,42,45.)
      P=NORTH(50,58,51.)
      H=331D0
      GO TO 9999

!  Catalina 61" (1981 Almanac)                                CATALINA61
 430  CONTINUE
      NAME='Catalina 61 inch'
      W=WEST(110,43,55.1)
      P=NORTH(32,25,00.7)
      H=2510D0
      GO TO 9999

!  Steward 90" (1981 Almanac)                                  STEWARD90
 440  CONTINUE
      NAME='Steward 90 inch'
      W=WEST(111,35,58.24)
      P=NORTH(31,57,46.9)
      H=2071D0
      GO TO 9999

!  Russian 6m (1981 Almanac)                                       USSR6
 450  CONTINUE
      NAME='USSR 6 metre'
      W=EAST(41,26,30.0)
      P=NORTH(43,39,12.)
      H=2100D0
      GO TO 9999

!  Arecibo 1000' (1981 Almanac)                                  ARECIBO
 460  CONTINUE
      NAME='Arecibo 1000 foot'
      W=WEST(66,45,11.1)
      P=NORTH(18,20,36.6)
      H=496D0
      GO TO 9999

!  Cambridge 5km (1981 Almanac)                                  CAMB5KM
 470  CONTINUE
      NAME='Cambridge 5km'
      W=EAST(0,02,37.23)
      P=NORTH(52,10,12.2)
      H=17D0
      GO TO 9999

!  Cambridge 1 mile (1981 Almanac)                             CAMB1MILE
 480  CONTINUE
      NAME='Cambridge 1 mile'
      W=EAST(0,02,21.64)
      P=NORTH(52,09,47.3)
      H=17D0
      GO TO 9999

!  Bonn 100m (1981 Almanac)                                   EFFELSBERG
 490  CONTINUE
      NAME='Effelsberg 100 metre'
      W=EAST(6,53,01.5)
      P=NORTH(50,31,28.6)
      H=366D0
      GO TO 9999

!  Greenbank 300' (1981 Almanac)                        GBVA300 (R.I.P.)
 500  CONTINUE
      NAME='Greenbank 300 foot'
      W=WEST(79,50,56.36)
      P=NORTH(38,25,46.3)
      H=894D0
      GO TO 9999

!  Jodrell Bank Mk 1 (1981 Almanac)                             JODRELL1
 510  CONTINUE
      NAME='Jodrell Bank 250 foot'
      W=WEST(2,18,25.)
      P=NORTH(53,14,10.5)
      H=78D0
      GO TO 9999

!  Australia Telescope Parkes Observatory                         PARKES
!  (Peter te Lintel Hekkert)
 520  CONTINUE
      NAME='Parkes 64 metre'
      W=EAST(148,15,44.3591)
      P=SOUTH(32,59,59.8657)
      H=391.79D0
      GO TO 9999

!  VLA (1981 Almanac)                                                VLA
 530  CONTINUE
      NAME='Very Large Array'
      W=WEST(107,37,03.82)
      P=NORTH(34,04,43.5)
      H=2124D0
      GO TO 9999

!  Sugar Grove 150' (1981 Almanac)                            SUGARGROVE
 540  CONTINUE
      NAME='Sugar Grove 150 foot'
      W=WEST(79,16,23.)
      P=NORTH(38,31,14.)
      H=705D0
      GO TO 9999

!  Russian 600' (1981 Almanac)                                   USSR600
 550  CONTINUE
      NAME='USSR 600 foot'
      W=EAST(41,35,25.5)
      P=NORTH(43,49,32.)
      H=973D0
      GO TO 9999

!  Nobeyama 45 metre mm dish (based on 1981 Almanac entry)      NOBEYAMA
 560  CONTINUE
      NAME='Nobeyama 45 metre'
      W=EAST(138,29,12.)
      P=NORTH(35,56,19.)
      H=1350D0
      GO TO 9999

!  James Clerk Maxwell 15 metre mm telescope, Mauna Kea             JCMT
!  (IfA website, Richard Wainscoat, height from I.Coulson)
 570  CONTINUE
      NAME='JCMT 15 metre'
      W=WEST(155,28,37.20)
      P=NORTH(19,49,22.11)
      H=4111D0
      GO TO 9999

!  ESO 3.5 metre NTT, La Silla (K.Wirenstrand)                    ESONTT
 580  CONTINUE
      NAME='ESO 3.5 metre NTT'
      W=WEST(70,43,07.)
      P=SOUTH(29,15,30.)
      H=2377D0
      GO TO 9999

!  St Andrews University Observatory (1982 Almanac)           ST.ANDREWS
 590  CONTINUE
      NAME='St Andrews'
      W=WEST(2,48,52.5)
      P=NORTH(56,20,12.)
      H=30D0
      GO TO 9999

!  Apache Point 3.5 metre (R.Owen)                                APO3.5
 600  CONTINUE
      NAME='Apache Point 3.5m'
      W=WEST(105,49,11.56)
      P=NORTH(32,46,48.96)
      H=2809D0
      GO TO 9999

!  W.M.Keck Observatory, Telescope 1                               KECK1
!  (William Lupton)
 610  CONTINUE
      NAME='Keck 10m Telescope #1'
      W=WEST(155,28,28.99)
      P=NORTH(19,49,33.41)
      H=4160D0
      GO TO 9999

!  Tautenberg Schmidt (1983 Almanac)                            TAUTSCHM
 620  CONTINUE
      NAME='Tautenberg 1.34 metre Schmidt'
      W=EAST(11,42,45.0)
      P=NORTH(50,58,51.0)
      H=331D0
      GO TO 9999

!  Palomar Schmidt (1981 Almanac)                              PALOMAR48
 630  CONTINUE
      NAME='Palomar 48-inch Schmidt'
      W=WEST(116,51,32.0)
      P=NORTH(33,21,26.0)
      H=1706D0
      GO TO 9999

!  UK Schmidt, Siding Spring (1983 Almanac)                         UKST
 640  CONTINUE
      NAME='UK 1.2 metre Schmidt, Siding Spring'
      W=EAST(149,04,12.8)
      P=SOUTH(31,16,27.8)
      H=1145D0
      GO TO 9999

!  Kiso Schmidt, Japan (1981 Almanac)                               KISO
 650  CONTINUE
      NAME='Kiso 1.05 metre Schmidt, Japan'
      W=EAST(137,37,42.2)
      P=NORTH(35,47,38.7)
      H=1130D0
      GO TO 9999

!  ESO Schmidt, La Silla (1981 Almanac)                          ESOSCHM
 660  CONTINUE
      NAME='ESO 1 metre Schmidt, La Silla'
      W=WEST(70,43,46.5)
      P=SOUTH(29,15,25.8)
      H=2347D0
      GO TO 9999

!  Australia Telescope Compact Array                                ATCA
!  (WGS84 coordinates of Station 35, Mark Calabretta)
 670  CONTINUE
      NAME='Australia Telescope Compact Array'
      W=EAST(149,33,00.500)
      P=SOUTH(30,18,46.385)
      H=236.9D0
      GO TO 9999

!  Australia Telescope Mopra Observatory                           MOPRA
!  (Peter te Lintel Hekkert)
 680  CONTINUE
      NAME='ATNF Mopra Observatory'
      W=EAST(149,05,58.732)
      P=SOUTH(31,16,04.451)
      H=850D0
      GO TO 9999

!  Subaru telescope, Mauna Kea                                     SUBARU
!  (IfA website, Richard Wainscoat)
 690  CONTINUE
      NAME='Subaru 8m telescope'
      W=WEST(155,28,33.67)
      P=NORTH(19,49,31.81)
      H=4163D0
      GO TO 9999

!  Canada-France-Hawaii Telescope, Mauna Kea                         CFHT
!  (IfA website, Richard Wainscoat)
 700  CONTINUE
      NAME='Canada-France-Hawaii 3.6m Telescope'
      W=WEST(155,28,07.95)
      P=NORTH(19,49,30.91)
      H=4204.1D0
      GO TO 9999

!  W.M.Keck Observatory, Telescope 2                                KECK2
!  (William Lupton)
 710  CONTINUE
      NAME='Keck 10m Telescope #2'
      W=WEST(155,28,27.24)
      P=NORTH(19,49,35.62)
      H=4159.6D0
      GO TO 9999

!  Gemini North, Mauna Kea                                        GEMININ
!  (IfA website, Richard Wainscoat)
 720  CONTINUE
      NAME='Gemini North 8-m telescope'
      W=WEST(155,28,08.57)
      P=NORTH(19,49,25.69)
      H=4213.4D0
      GO TO 9999

!  Five College Radio Astronomy Observatory                        FCRAO
!  (Tim Jenness)
 730  CONTINUE
      NAME='Five College Radio Astronomy Obs'
      W=WEST(72,20,42.0)
      P=NORTH(42,23,30.0)
      H=314D0
      GO TO 9999

!  NASA Infra Red Telescope Facility                                IRTF
!  (IfA website, Richard Wainscoat)
 740  CONTINUE
      NAME='NASA IR Telescope Facility, Mauna Kea'
      W=WEST(155,28,19.20)
      P=NORTH(19,49,34.39)
      H=4168.1D0
      GO TO 9999

!  Caltech Submillimeter Observatory                                 CSO
!  (IfA website, Richard Wainscoat; height estimated)
 750  CONTINUE
      NAME='Caltech Sub-mm Observatory, Mauna Kea'
      W=WEST(155,28,31.79)
      P=NORTH(19,49,20.78)
      H=4080D0
      GO TO 9999

! ESO VLT, UT1                                                       VLT1
! (ESO website, VLT Whitebook Chapter 2)
 760  CONTINUE
      NAME='ESO VLT, Paranal, Chile: UT1'
      W=WEST(70,24,11.642)
      P=SOUTH(24,37,33.117)
      H=2635.43
      GO TO 9999

! ESO VLT, UT2                                                       VLT2
! (ESO website, VLT Whitebook Chapter 2)
 770  CONTINUE
      NAME='ESO VLT, Paranal, Chile: UT2'
      W=WEST(70,24,10.855)
      P=SOUTH(24,37,31.465)
      H=2635.43
      GO TO 9999

! ESO VLT, UT3                                                       VLT3
! (ESO website, VLT Whitebook Chapter 2)
 780  CONTINUE
      NAME='ESO VLT, Paranal, Chile: UT3'
      W=WEST(70,24,09.896)
      P=SOUTH(24,37,30.300)
      H=2635.43
      GO TO 9999

! ESO VLT, UT4                                                       VLT4
! (ESO website, VLT Whitebook Chapter 2)
 790  CONTINUE
      NAME='ESO VLT, Paranal, Chile: UT4'
      W=WEST(70,24,08.000)
      P=SOUTH(24,37,31.000)
      H=2635.43
      GO TO 9999

!  Gemini South, Cerro Pachon                                     GEMINIS
!  (GPS readings by Patrick Wallace)
 800  CONTINUE
      NAME='Gemini South 8-m telescope'
      W=WEST(70,44,11.5)
      P=SOUTH(30,14,26.7)
      H=2738D0
      GO TO 9999

!  Cologne Observatory for Submillimeter Astronomy (KOSMA)        KOSMA3M
!  (Holger Jakob)
 810  CONTINUE
      NAME='KOSMA 3m telescope, Gornergrat'
      W=EAST(7,47,3.48)
      P=NORTH(45,58,59.772)
      H=3141D0
      GO TO 9999

!  Magellan 1, 6.5m telescope at Las Campanas, Chile            MAGELLAN1
!  (Skip Schaller)
 820  CONTINUE
      NAME='Magellan 1, 6.5m, Las Campanas'
      W=WEST(70,41,31.9)
      P=SOUTH(29,00,51.7)
      H=2408D0
      GO TO 9999

!  Magellan 2, 6.5m telescope at Las Campanas, Chile            MAGELLAN2
!  (Skip Schaller)
 830  CONTINUE
      NAME='Magellan 2, 6.5m, Las Campanas'
      W=WEST(70,41,33.5)
      P=SOUTH(29,00,50.3)
      H=2408D0
      GO TO 9999

!  Unrecognized station
 9000 CONTINUE
      NAME='?'

!  Exit
 9999 CONTINUE

      END
      DOUBLE PRECISION FUNCTION sla_PA (HA, DEC, PHI)
!+
!     - - -
!      P A
!     - - -
!
!  HA, Dec to Parallactic Angle (double precision)
!
!  Given:
!     HA     d     hour angle in radians (geocentric apparent)
!     DEC    d     declination in radians (geocentric apparent)
!     PHI    d     observatory latitude in radians (geodetic)
!
!  The result is in the range -pi to +pi
!
!  Notes:
!
!  1)  The parallactic angle at a point in the sky is the position
!      angle of the vertical, i.e. the angle between the direction to
!      the pole and to the zenith.  In precise applications care must
!      be taken only to use geocentric apparent HA,Dec and to consider
!      separately the effects of atmospheric refraction and telescope
!      mount errors.
!
!  2)  At the pole a zero result is returned.
!
!  P.T.Wallace   Starlink   16 August 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION HA,DEC,PHI

      DOUBLE PRECISION CP,SQSZ,CQSZ



      CP=COS(PHI)
      SQSZ=CP*SIN(HA)
      CQSZ=SIN(PHI)*COS(DEC)-CP*SIN(DEC)*COS(HA)
      IF (SQSZ.EQ.0D0.AND.CQSZ.EQ.0D0) CQSZ=1D0
      sla_PA=ATAN2(SQSZ,CQSZ)

      END
      REAL FUNCTION sla_PAV ( V1, V2 )
!+
!     - - - -
!      P A V
!     - - - -
!
!  Position angle of one celestial direction with respect to another.
!
!  (single precision)
!
!  Given:
!     V1    r(3)    direction cosines of one point
!     V2    r(3)    direction cosines of the other point
!
!  (The coordinate frames correspond to RA,Dec, Long,Lat etc.)
!
!  The result is the bearing (position angle), in radians, of point
!  V2 with respect to point V1.  It is in the range +/- pi.  The
!  sense is such that if V2 is a small distance east of V1, the
!  bearing is about +pi/2.  Zero is returned if the two points
!  are coincident.
!
!  V1 and V2 do not have to be unit vectors.
!
!  The routine sla_BEAR performs an equivalent function except
!  that the points are specified in the form of spherical
!  coordinates.
!
!  Called:  sla_DPAV
!
!  Patrick Wallace   Starlink   23 May 1997
!
!  Copyright (C) 1997 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL V1(3),V2(3)

      INTEGER I
      DOUBLE PRECISION D1(3),D2(3)

      DOUBLE PRECISION sla_DPAV


!  Call the double precision version
      DO I=1,3
         D1(I)=V1(I)
         D2(I)=V2(I)
      END DO
      sla_PAV=sla_DPAV(D1,D2)

      END
      SUBROUTINE sla_PCD (DISCO,X,Y)
!+
!     - - - -
!      P C D
!     - - - -
!
!  Apply pincushion/barrel distortion to a tangent-plane [x,y].
!
!  Given:
!     DISCO    d      pincushion/barrel distortion coefficient
!     X,Y      d      tangent-plane coordinates
!
!  Returned:
!     X,Y      d      distorted coordinates
!
!  Notes:
!
!  1)  The distortion is of the form RP = R*(1 + C*R**2), where R is
!      the radial distance from the tangent point, C is the DISCO
!      argument, and RP is the radial distance in the presence of
!      the distortion.
!
!  2)  For pincushion distortion, C is +ve;  for barrel distortion,
!      C is -ve.
!
!  3)  For X,Y in units of one projection radius (in the case of
!      a photographic plate, the focal length), the following
!      DISCO values apply:
!
!          Geometry          DISCO
!
!          astrograph         0.0
!          Schmidt           -0.3333
!          AAT PF doublet  +147.069
!          AAT PF triplet  +178.585
!          AAT f/8          +21.20
!          JKT f/8          +13.32
!
!  4)  There is a companion routine, sla_UNPCD, which performs the
!      inverse operation.
!
!  P.T.Wallace   Starlink   3 September 2000
!
!  Copyright (C) 2000 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DISCO,X,Y

      DOUBLE PRECISION F



      F=1D0+DISCO*(X*X+Y*Y)
      X=X*F
      Y=Y*F

      END
      SUBROUTINE sla_PDA2H (P, D, A, H1, J1, H2, J2)
!+
!     - - - - - -
!      P D A 2 H
!     - - - - - -
!
!  Hour Angle corresponding to a given azimuth
!
!  (double precision)
!
!  Given:
!     P       d        latitude
!     D       d        declination
!     A       d        azimuth
!
!  Returned:
!     H1      d        hour angle:  first solution if any
!     J1      i        flag: 0 = solution 1 is valid
!     H2      d        hour angle:  second solution if any
!     J2      i        flag: 0 = solution 2 is valid
!
!  Called:  sla_DRANGE
!
!  P.T.Wallace   Starlink   6 October 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION P,D,A,H1
      INTEGER J1
      DOUBLE PRECISION H2
      INTEGER J2

      DOUBLE PRECISION DPI
      PARAMETER (DPI=3.141592653589793238462643D0)
      DOUBLE PRECISION D90
      PARAMETER (D90=DPI/2D0)
      DOUBLE PRECISION TINY
      PARAMETER (TINY=1D-12)
      DOUBLE PRECISION PN,AN,DN,SA,CA,SASP,QT,QB,HPT,T
      DOUBLE PRECISION sla_DRANGE


!  Preset status flags to OK
      J1=0
      J2=0

!  Adjust latitude, azimuth, declination to avoid critical values
      PN=sla_DRANGE(P)
      IF (ABS(ABS(PN)-D90).LT.TINY) THEN
         PN=PN-SIGN(TINY,PN)
      ELSE IF (ABS(PN).LT.TINY) THEN
         PN=TINY
      END IF
      AN=sla_DRANGE(A)
      IF (ABS(ABS(AN)-DPI).LT.TINY) THEN
         AN=AN-SIGN(TINY,AN)
      ELSE IF (ABS(AN).LT.TINY) THEN
         AN=TINY
      END IF
      DN=sla_DRANGE(D)
      IF (ABS(ABS(DN)-ABS(P)).LT.TINY) THEN
         DN=DN-SIGN(TINY,DN)
      ELSE IF (ABS(ABS(DN)-D90).LT.TINY) THEN
         DN=DN-SIGN(TINY,DN)
      ELSE IF (ABS(DN).LT.TINY) THEN
         DN=TINY
      END IF

!  Useful functions
      SA=SIN(AN)
      CA=COS(AN)
      SASP=SA*SIN(PN)

!  Quotient giving sin(h+t)
      QT=SIN(DN)*SA*COS(PN)
      QB=COS(DN)*SQRT(CA*CA+SASP*SASP)

!  Any solutions?
      IF (ABS(QT).LE.QB) THEN

!     Yes: find h+t and t
         HPT=ASIN(QT/QB)
         T=ATAN2(SASP,-CA)

!     The two solutions
         H1=sla_DRANGE(HPT-T)
         H2=sla_DRANGE(-HPT-(T+DPI))

!     Reject unless h and A different signs
         IF (H1*AN.GT.0D0) J1=-1
         IF (H2*AN.GT.0D0) J2=-1
      ELSE
         J1=-1
         J2=-1
      END IF

      END
      SUBROUTINE sla_PDQ2H (P, D, Q, H1, J1, H2, J2)
!+
!     - - - - - -
!      P D Q 2 H
!     - - - - - -
!
!  Hour Angle corresponding to a given parallactic angle
!
!  (double precision)
!
!  Given:
!     P       d        latitude
!     D       d        declination
!     Q       d        parallactic angle
!
!  Returned:
!     H1      d        hour angle:  first solution if any
!     J1      i        flag: 0 = solution 1 is valid
!     H2      d        hour angle:  second solution if any
!     J2      i        flag: 0 = solution 2 is valid
!
!  Called:  sla_DRANGE
!
!  P.T.Wallace   Starlink   6 October 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION P,D,Q,H1
      INTEGER J1
      DOUBLE PRECISION H2
      INTEGER J2

      DOUBLE PRECISION DPI
      PARAMETER (DPI=3.141592653589793238462643D0)
      DOUBLE PRECISION D90
      PARAMETER (D90=DPI/2D0)
      DOUBLE PRECISION TINY
      PARAMETER (TINY=1D-12)
      DOUBLE PRECISION PN,QN,DN,SQ,CQ,SQSD,QT,QB,HPT,T
      DOUBLE PRECISION sla_DRANGE


!  Preset status flags to OK
      J1=0
      J2=0

!  Adjust latitude, declination, parallactic angle to avoid critical values
      PN=sla_DRANGE(P)
      IF (ABS(ABS(PN)-D90).LT.TINY) THEN
         PN=PN-SIGN(TINY,PN)
      ELSE IF (ABS(PN).LT.TINY) THEN
         PN=TINY
      END IF
      QN=sla_DRANGE(Q)
      IF (ABS(ABS(QN)-DPI).LT.TINY) THEN
         QN=QN-SIGN(TINY,QN)
      ELSE IF (ABS(QN).LT.TINY) THEN
         QN=TINY
      END IF
      DN=sla_DRANGE(D)
      IF (ABS(ABS(D)-ABS(P)).LT.TINY) THEN
         DN=DN-SIGN(TINY,DN)
      ELSE IF (ABS(ABS(D)-D90).LT.TINY) THEN
         DN=DN-SIGN(TINY,DN)
      END IF

!  Useful functions
      SQ=SIN(QN)
      CQ=COS(QN)
      SQSD=SQ*SIN(DN)

!  Quotient giving sin(h+t)
      QT=SIN(PN)*SQ*COS(DN)
      QB=COS(PN)*SQRT(CQ*CQ+SQSD*SQSD)

!  Any solutions?
      IF (ABS(QT).LE.QB) THEN

!     Yes: find h+t and t
         HPT=ASIN(QT/QB)
         T=ATAN2(SQSD,CQ)

!     The two solutions
         H1=sla_DRANGE(HPT-T)
         H2=sla_DRANGE(-HPT-(T+DPI))

!     Reject if h and Q different signs
         IF (H1*QN.LT.0D0) J1=-1
         IF (H2*QN.LT.0D0) J2=-1
      ELSE
         J1=-1
         J2=-1
      END IF

      END
      SUBROUTINE sla_PERMUT ( N, ISTATE, IORDER, J )
!+
!     - - - - - - -
!      P E R M U T
!     - - - - - - -
!
!  Generate the next permutation of a specified number of items.
!
!  Given:
!     N         i      number of items:  there will be N! permutations
!     ISTATE    i(N)   state, ISTATE(1)=-1 to initialize
!
!  Returned:
!     ISTATE    i(N)   state, updated ready for next time
!     IORDER    i(N)   next permutation of numbers 1,2,...,N
!     J         i      status: -1 = illegal N (zero or less is illegal)
!                               0 = OK
!                              +1 = no more permutations available
!
!  Notes:
!
!  1) This routine returns, in the IORDER array, the integers 1 to N
!     inclusive, in an order that depends on the current contents of
!     the ISTATE array.  Before calling the routine for the first
!     time, the caller must set the first element of the ISTATE array
!     to -1 (any negative number will do) to cause the ISTATE array
!     to be fully initialized.
!
!  2) The first permutation to be generated is:
!
!          IORDER(1)=N, IORDER(2)=N-1, ..., IORDER(N)=1
!
!     This is also the permutation returned for the "finished"
!     (J=1) case.
!
!     The final permutation to be generated is:
!
!          IORDER(1)=1, IORDER(2)=2, ..., IORDER(N)=N
!
!  3) If the "finished" (J=1) status is ignored, the routine continues
!     to deliver permutations, the pattern repeating every N! calls.
!
!  P.T.Wallace   Starlink   25 August 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER N,IORDER(N),ISTATE(N),J

      INTEGER I,IP1,ISLOT,ISKIP


!  -------------
!  Preliminaries
!  -------------

!  Validate, and set status.
      IF (N.LT.1) THEN
         J = -1
         GO TO 9999
      ELSE
         J = 0
      END IF

!  If just starting, initialize state array
      IF (ISTATE(1).LT.0) THEN
         ISTATE(1) = -1
         DO I=2,N
            ISTATE(I) = 0
         END DO
      END IF

!  --------------------------
!  Increment the state number
!  --------------------------

!  The state number, maintained in the ISTATE array, is a mixed-radix
!  number with N! states.  The least significant digit, with a radix of
!  1, is in ISTATE(1).  The next digit, in ISTATE(2), has a radix of 2,
!  and so on.

!  Increment the least-significant digit of the state number.
      ISTATE(1) = ISTATE(1)+1

!  Digit by digit starting with the least significant.
      DO I=1,N

!     Carry?
         IF (ISTATE(I).GE.I) THEN

!        Yes:  reset the current digit.
            ISTATE(I) = 0

!        Overflow?
            IF (I.GE.N) THEN

!           Yes:  there are no more permutations.
               J = 1
            ELSE

!           No:  carry.
               IP1 = I+1
               ISTATE(IP1) = ISTATE(IP1)+1
            END IF
         END IF
      END DO

!  -------------------------------------------------------------------
!  Translate the state number into the corresponding permutation order
!  -------------------------------------------------------------------

!  Initialize the order array.  All but one element will be overwritten.
      DO I=1,N
         IORDER(I) = 1
      END DO

!  Look at each state number digit, starting with the most significant.
      DO I=N,2,-1

!     Initialize the position where the new number will go.
         ISLOT = 0

!     The state number digit says which unfilled slot is to be used.
         DO ISKIP=0,ISTATE(I)

!        Increment the slot number until an unused slot is found.
            ISLOT = ISLOT+1
            DO WHILE (IORDER(ISLOT).GT.1)
               ISLOT = ISLOT+1
            END DO
         END DO

!     Store the number in the permutation order array.
         IORDER(ISLOT) = I
      END DO

 9999 CONTINUE

      END
      SUBROUTINE sla_PERTEL (JFORM, DATE0, DATE1, &
                      EPOCH0, ORBI0, ANODE0, PERIH0, AORQ0, E0, AM0, &
                      EPOCH1, ORBI1, ANODE1, PERIH1, AORQ1, E1, AM1, &
                            JSTAT)
!+
!     - - - - - - -
!      P E R T E L
!     - - - - - - -
!
!  Update the osculating orbital elements of an asteroid or comet by
!  applying planetary perturbations.
!
!  Given (format and dates):
!     JFORM   i    choice of element set (2 or 3; Note 1)
!     DATE0   d    date of osculation (TT MJD) for the given elements
!     DATE1   d    date of osculation (TT MJD) for the updated elements
!
!  Given (the unperturbed elements):
!     EPOCH0  d    epoch (TT MJD) of the given element set (Note 2)
!     ORBI0   d    inclination (radians)
!     ANODE0  d    longitude of the ascending node (radians)
!     PERIH0  d    argument of perihelion (radians)
!     AORQ0   d    mean distance or perihelion distance (AU)
!     E0      d    eccentricity
!     AM0     d    mean anomaly (radians, JFORM=2 only)
!
!  Returned (the updated elements):
!     EPOCH1  d    epoch (TT MJD) of the updated element set (Note 2)
!     ORBI1   d    inclination (radians)
!     ANODE1  d    longitude of the ascending node (radians)
!     PERIH1  d    argument of perihelion (radians)
!     AORQ1   d    mean distance or perihelion distance (AU)
!     E1      d    eccentricity
!     AM1     d    mean anomaly (radians, JFORM=2 only)
!
!  Returned (status flag):
!     JSTAT   i    status: +102 = warning, distant epoch
!                          +101 = warning, large timespan ( > 100 years)
!                      +1 to +8 = coincident with major planet (Note 6)
!                             0 = OK
!                            -1 = illegal JFORM
!                            -2 = illegal E0
!                            -3 = illegal AORQ0
!                            -4 = internal error
!                            -5 = numerical error
!
!  Notes:
!
!  1  Two different element-format options are available:
!
!     Option JFORM=2, suitable for minor planets:
!
!     EPOCH   = epoch of elements (TT MJD)
!     ORBI    = inclination i (radians)
!     ANODE   = longitude of the ascending node, big omega (radians)
!     PERIH   = argument of perihelion, little omega (radians)
!     AORQ    = mean distance, a (AU)
!     E       = eccentricity, e
!     AM      = mean anomaly M (radians)
!
!     Option JFORM=3, suitable for comets:
!
!     EPOCH   = epoch of perihelion (TT MJD)
!     ORBI    = inclination i (radians)
!     ANODE   = longitude of the ascending node, big omega (radians)
!     PERIH   = argument of perihelion, little omega (radians)
!     AORQ    = perihelion distance, q (AU)
!     E       = eccentricity, e
!
!  2  DATE0, DATE1, EPOCH0 and EPOCH1 are all instants of time in
!     the TT timescale (formerly Ephemeris Time, ET), expressed
!     as Modified Julian Dates (JD-2400000.5).
!
!     DATE0 is the instant at which the given (i.e. unperturbed)
!     osculating elements are correct.
!
!     DATE1 is the specified instant at which the updated osculating
!     elements are correct.
!
!     EPOCH0 and EPOCH1 will be the same as DATE0 and DATE1
!     (respectively) for the JFORM=2 case, normally used for minor
!     planets.  For the JFORM=3 case, the two epochs will refer to
!     perihelion passage and so will not, in general, be the same as
!     DATE0 and/or DATE1 though they may be similar to one another.
!
!  3  The elements are with respect to the J2000 ecliptic and equinox.
!
!  4  Unused elements (AM0 and AM1 for JFORM=3) are not accessed.
!
!  5  See the sla_PERTUE routine for details of the algorithm used.
!
!  6  This routine is not intended to be used for major planets, which
!     is why JFORM=1 is not available and why there is no opportunity
!     to specify either the longitude of perihelion or the daily
!     motion.  However, if JFORM=2 elements are somehow obtained for a
!     major planet and supplied to the routine, sensible results will,
!     in fact, be produced.  This happens because the sla_PERTUE routine
!     that is called to perform the calculations checks the separation
!     between the body and each of the planets and interprets a
!     suspiciously small value (0.001 AU) as an attempt to apply it to
!     the planet concerned.  If this condition is detected, the
!     contribution from that planet is ignored, and the status is set to
!     the planet number (Mercury=1,...,Neptune=8) as a warning.
!
!  Reference:
!
!     Sterne, Theodore E., "An Introduction to Celestial Mechanics",
!     Interscience Publishers Inc., 1960.  Section 6.7, p199.
!
!  Called:  sla_EL2UE, sla_PERTUE, sla_UE2EL
!
!  P.T.Wallace   Starlink   27 June 2002
!
!  Copyright (C) 2002 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE
      INTEGER JFORM
      DOUBLE PRECISION DATE0,DATE1, &
                      EPOCH0,ORBI0,ANODE0,PERIH0,AORQ0,E0,AM0, &
                      EPOCH1,ORBI1,ANODE1,PERIH1,AORQ1,E1,AM1
      INTEGER JSTAT

      DOUBLE PRECISION U(13),DM
      INTEGER J,JF



!  Check that the elements are either minor-planet or comet format.
      IF (JFORM.LT.2.OR.JFORM.GT.3) THEN
         JSTAT = -1
         GO TO 9999
      ELSE

!     Provisionally set the status to OK.
         JSTAT = 0
      END IF

!  Transform the elements from conventional to universal form.
      CALL sla_EL2UE(DATE0,JFORM,EPOCH0,ORBI0,ANODE0,PERIH0, &
                    AORQ0,E0,AM0,0D0,U,J)
      IF (J.NE.0) THEN
         JSTAT = J
         GO TO 9999
      END IF

!  Update the universal elements.
      CALL sla_PERTUE(DATE1,U,J)
      IF (J.GT.0) THEN
         JSTAT = J
      ELSE IF (J.LT.0) THEN
         JSTAT = -5
         GO TO 9999
      END IF

!  Transform from universal to conventional elements.
      CALL sla_UE2EL(U,JFORM, &
                    JF, EPOCH1, ORBI1, ANODE1, PERIH1, &
                    AORQ1, E1, AM1, DM, J)
      IF (JF.NE.JFORM.OR.J.NE.0) JSTAT=-5

 9999 CONTINUE
      END
      SUBROUTINE sla_PERTUE (DATE, U, JSTAT)
!+
!     - - - - - - -
!      P E R T U E
!     - - - - - - -
!
!  Update the universal elements of an asteroid or comet by applying
!  planetary perturbations.
!
!  Given:
!     DATE     d       final epoch (TT MJD) for the updated elements
!
!  Given and returned:
!     U        d(13)   universal elements (updated in place)
!
!                (1)   combined mass (M+m)
!                (2)   total energy of the orbit (alpha)
!                (3)   reference (osculating) epoch (t0)
!              (4-6)   position at reference epoch (r0)
!              (7-9)   velocity at reference epoch (v0)
!               (10)   heliocentric distance at reference epoch
!               (11)   r0.v0
!               (12)   date (t)
!               (13)   universal eccentric anomaly (psi) of date, approx
!
!  Returned:
!     JSTAT    i       status:
!                          +102 = warning, distant epoch
!                          +101 = warning, large timespan ( > 100 years)
!                      +1 to +8 = coincident with major planet (Note 5)
!                             0 = OK
!                            -1 = numerical error
!
!  Called:  sla_EPJ, sla_PLANET, sla_PV2UE, sla_UE2PV, sla_EVP,
!           sla_PREC, sla_DMOON, sla_DMXV
!
!  Notes:
!
!  1  The "universal" elements are those which define the orbit for the
!     purposes of the method of universal variables (see reference 2).
!     They consist of the combined mass of the two bodies, an epoch,
!     and the position and velocity vectors (arbitrary reference frame)
!     at that epoch.  The parameter set used here includes also various
!     quantities that can, in fact, be derived from the other
!     information.  This approach is taken to avoiding unnecessary
!     computation and loss of accuracy.  The supplementary quantities
!     are (i) alpha, which is proportional to the total energy of the
!     orbit, (ii) the heliocentric distance at epoch, (iii) the
!     outwards component of the velocity at the given epoch, (iv) an
!     estimate of psi, the "universal eccentric anomaly" at a given
!     date and (v) that date.
!
!  2  The universal elements are with respect to the J2000 equator and
!     equinox.
!
!  3  The epochs DATE, U(3) and U(12) are all Modified Julian Dates
!     (JD-2400000.5).
!
!  4  The algorithm is a simplified form of Encke's method.  It takes as
!     a basis the unperturbed motion of the body, and numerically
!     integrates the perturbing accelerations from the major planets.
!     The expression used is essentially Sterne's 6.7-2 (reference 1).
!     Everhart and Pitkin (reference 2) suggest rectifying the orbit at
!     each integration step by propagating the new perturbed position
!     and velocity as the new universal variables.  In the present
!     routine the orbit is rectified less frequently than this, in order
!     to gain a slight speed advantage.  However, the rectification is
!     done directly in terms of position and velocity, as suggested by
!     Everhart and Pitkin, bypassing the use of conventional orbital
!     elements.
!
!     The f(q) part of the full Encke method is not used.  The purpose
!     of this part is to avoid subtracting two nearly equal quantities
!     when calculating the "indirect member", which takes account of the
!     small change in the Sun's attraction due to the slightly displaced
!     position of the perturbed body.  A simpler, direct calculation in
!     double precision proves to be faster and not significantly less
!     accurate.
!
!     Apart from employing a variable timestep, and occasionally
!     "rectifying the orbit" to keep the indirect member small, the
!     integration is done in a fairly straightforward way.  The
!     acceleration estimated for the middle of the timestep is assumed
!     to apply throughout that timestep;  it is also used in the
!     extrapolation of the perturbations to the middle of the next
!     timestep, to predict the new disturbed position.  There is no
!     iteration within a timestep.
!
!     Measures are taken to reach a compromise between execution time
!     and accuracy.  The starting-point is the goal of achieving
!     arcsecond accuracy for ordinary minor planets over a ten-year
!     timespan.  This goal dictates how large the timesteps can be,
!     which in turn dictates how frequently the unperturbed motion has
!     to be recalculated from the osculating elements.
!
!     Within predetermined limits, the timestep for the numerical
!     integration is varied in length in inverse proportion to the
!     magnitude of the net acceleration on the body from the major
!     planets.
!
!     The numerical integration requires estimates of the major-planet
!     motions.  Approximate positions for the major planets (Pluto
!     alone is omitted) are obtained from the routine sla_PLANET.  Two
!     levels of interpolation are used, to enhance speed without
!     significantly degrading accuracy.  At a low frequency, the routine
!     sla_PLANET is called to generate updated position+velocity "state
!     vectors".  The only task remaining to be carried out at the full
!     frequency (i.e. at each integration step) is to use the state
!     vectors to extrapolate the planetary positions.  In place of a
!     strictly linear extrapolation, some allowance is made for the
!     curvature of the orbit by scaling back the radius vector as the
!     linear extrapolation goes off at a tangent.
!
!     Various other approximations are made.  For example, perturbations
!     by Pluto and the minor planets are neglected and relativistic
!     effects are not taken into account.
!
!     In the interests of simplicity, the background calculations for
!     the major planets are carried out en masse.  The mean elements and
!     state vectors for all the planets are refreshed at the same time,
!     without regard for orbit curvature, mass or proximity.
!
!     The Earth-Moon system is treated as a single body when the body is
!     distant but as separate bodies when closer to the EMB than the
!     parameter RNE, which incurs a time penalty but improves accuracy
!     for near-Earth objects.
!
!  5  This routine is not intended to be used for major planets.
!     However, if major-planet elements are supplied, sensible results
!     will, in fact, be produced.  This happens because the routine
!     checks the separation between the body and each of the planets and
!     interprets a suspiciously small value (0.001 AU) as an attempt to
!     apply the routine to the planet concerned.  If this condition is
!     detected, the contribution from that planet is ignored, and the
!     status is set to the planet number (Mercury=1,...,Neptune=8) as a
!     warning.
!
!  References:
!
!     1  Sterne, Theodore E., "An Introduction to Celestial Mechanics",
!        Interscience Publishers Inc., 1960.  Section 6.7, p199.
!
!     2  Everhart, E. & Pitkin, E.T., Am.J.Phys. 51, 712, 1983.
!
!  P.T.Wallace   Starlink   9 December 2002
!
!  Copyright (C) 2002 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE
      DOUBLE PRECISION DATE,U(13)
      INTEGER JSTAT

!  Distance from EMB at which Earth and Moon are treated separately
      DOUBLE PRECISION RNE
      PARAMETER (RNE=1D0)

!  Coincidence with major planet distance
      DOUBLE PRECISION COINC
      PARAMETER (COINC=0.0001D0)

!  Coefficient relating timestep to perturbing force
      DOUBLE PRECISION TSC
      PARAMETER (TSC=1D-4)

!  Minimum and maximum timestep (days)
      DOUBLE PRECISION TSMIN,TSMAX
      PARAMETER (TSMIN=0.01D0,TSMAX=10D0)

!  Age limit for major-planet state vector (days)
      DOUBLE PRECISION AGEPMO
      PARAMETER (AGEPMO=5D0)

!  Age limit for major-planet mean elements (days)
      DOUBLE PRECISION AGEPEL
      PARAMETER (AGEPEL=50D0)

!  Margin for error when deciding whether to renew the planetary data
      DOUBLE PRECISION TINY
      PARAMETER (TINY=1D-6)

!  Age limit for the body's osculating elements (before rectification)
      DOUBLE PRECISION AGEBEL
      PARAMETER (AGEBEL=100D0)

!  Gaussian gravitational constant (exact) and square
      DOUBLE PRECISION GCON,GCON2
      PARAMETER (GCON=0.01720209895D0,GCON2=GCON*GCON)

!  The final epoch
      DOUBLE PRECISION TFINAL

!  The body's current universal elements
      DOUBLE PRECISION UL(13)

!  Current reference epoch
      DOUBLE PRECISION T0

!  Timespan from latest orbit rectification to final epoch (days)
      DOUBLE PRECISION TSPAN

!  Time left to go before integration is complete
      DOUBLE PRECISION TLEFT

!  Time direction flag: +1=forwards, -1=backwards
      DOUBLE PRECISION FB

!  First-time flag
      LOGICAL FIRST

!
!  The current perturbations
!
!  Epoch (days relative to current reference epoch)
      DOUBLE PRECISION RTN
!  Position (AU)
      DOUBLE PRECISION PERP(3)
!  Velocity (AU/d)
      DOUBLE PRECISION PERV(3)
!  Acceleration (AU/d/d)
      DOUBLE PRECISION PERA(3)
!

!  Length of current timestep (days), and half that
      DOUBLE PRECISION TS,HTS

!  Epoch of middle of timestep
      DOUBLE PRECISION T

!  Epoch of planetary mean elements
      DOUBLE PRECISION TPEL

!  Planet number (1=Mercury, 2=Venus, 3=EMB...8=Neptune)
      INTEGER NP

!  Planetary universal orbital elements
      DOUBLE PRECISION UP(13,8)

!  Epoch of planetary state vectors
      DOUBLE PRECISION TPMO

!  State vectors for the major planets (AU,AU/s)
      DOUBLE PRECISION PVIN(6,8)

!  Earth velocity and position vectors (AU,AU/s)
      DOUBLE PRECISION VB(3),PB(3),VH(3),PE(3)

!  Moon geocentric state vector (AU,AU/s) and position part
      DOUBLE PRECISION PVM(6),PM(3)

!  Date to J2000 de-precession matrix
      DOUBLE PRECISION PMAT(3,3)

!
!  Correction terms for extrapolated major planet vectors
!
!  Sun-to-planet distances squared multiplied by 3
      DOUBLE PRECISION R2X3(8)
!  Sunward acceleration terms, G/2R^3
      DOUBLE PRECISION GC(8)
!  Tangential-to-circular correction factor
      DOUBLE PRECISION FC
!  Radial correction factor due to Sunwards acceleration
      DOUBLE PRECISION FG
!

!  The body's unperturbed and perturbed state vectors (AU,AU/s)
      DOUBLE PRECISION PV0(6),PV(6)

!  The body's perturbed and unperturbed heliocentric distances (AU) cubed
      DOUBLE PRECISION R03,R3

!  The perturbating accelerations, indirect and direct
      DOUBLE PRECISION FI(3),FD(3)

!  Sun-to-planet vector, and distance cubed
      DOUBLE PRECISION RHO(3),RHO3

!  Body-to-planet vector, and distance cubed
      DOUBLE PRECISION DELTA(3),DELTA3

!  Miscellaneous
      INTEGER I,J
      DOUBLE PRECISION R2,W,DT,DT2,R,FT
      LOGICAL NE

      DOUBLE PRECISION sla_EPJ

!  Planetary inverse masses, Mercury through Neptune then Earth and Moon
      DOUBLE PRECISION AMAS(10)
      DATA AMAS / 6023600D0, 408523.5D0, 328900.5D0, 3098710D0, &
                 1047.355D0, 3498.5D0, 22869D0, 19314D0, &
                 332946.038D0, 27068709D0 /

!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!----------------------------------------------------------------------*


!  Preset the status to OK.
      JSTAT = 0

!  Copy the final epoch.
      TFINAL = DATE

!  Copy the elements (which will be periodically updated).
      DO I=1,13
         UL(I) = U(I)
      END DO

!  Initialize the working reference epoch.
      T0=UL(3)

!  Total timespan (days) and hence time left.
      TSPAN = TFINAL-T0
      TLEFT = TSPAN

!  Warn if excessive.
      IF (ABS(TSPAN).GT.36525D0) JSTAT=101

!  Time direction: +1 for forwards, -1 for backwards.
      FB = SIGN(1D0,TSPAN)

!  Initialize relative epoch for start of current timestep.
      RTN = 0D0

!  Reset the perturbations (position, velocity, acceleration).
      DO I=1,3
         PERP(I) = 0D0
         PERV(I) = 0D0
         PERA(I) = 0D0
      END DO

!  Set "first iteration" flag.
      FIRST = .TRUE.

!  Step through the time left.
      DO WHILE (FB*TLEFT.GT.0D0)

!     Magnitude of current acceleration due to planetary attractions.
         IF (FIRST) THEN
            TS = TSMIN
         ELSE
            R2 = 0D0
            DO I=1,3
               W = FD(I)
               R2 = R2+W*W
            END DO
            W = SQRT(R2)

!        Use the acceleration to decide how big a timestep can be tolerated.
            IF (W.NE.0D0) THEN
               TS = MIN(TSMAX,MAX(TSMIN,TSC/W))
            ELSE
               TS = TSMAX
            END IF
         END IF
         TS = TS*FB

!     Override if final epoch is imminent.
         TLEFT = TSPAN-RTN
         IF (ABS(TS).GT.ABS(TLEFT)) TS=TLEFT

!     Epoch of middle of timestep.
         HTS = TS/2D0
         T = T0+RTN+HTS

!     Is it time to recompute the major-planet elements?
         IF (FIRST.OR.ABS(T-TPEL)-AGEPEL.GE.TINY) THEN

!        Yes: go forward in time by just under the maximum allowed.
            TPEL = T+FB*AGEPEL

!        Compute the state vector for the new epoch.
            DO NP=1,8
               CALL sla_PLANET(TPEL,NP,PV,J)

!           Warning if remote epoch, abort if error.
               IF (J.EQ.1) THEN
                  JSTAT = 102
               ELSE IF (J.NE.0) THEN
                  GO TO 9010
               END IF

!           Transform the vector into universal elements.
               CALL sla_PV2UE(PV,TPEL,0D0,UP(1,NP),J)
               IF (J.NE.0) GO TO 9010
            END DO
         END IF

!     Is it time to recompute the major-planet motions?
         IF (FIRST.OR.ABS(T-TPMO)-AGEPMO.GE.TINY) THEN

!        Yes: look ahead.
            TPMO = T+FB*AGEPMO

!        Compute the motions of each planet (AU,AU/d).
            DO NP=1,8

!           The planet's position and velocity (AU,AU/s).
               CALL sla_UE2PV(TPMO,UP(1,NP),PVIN(1,NP),J)
               IF (J.NE.0) GO TO 9010

!           Scale velocity to AU/d.
               DO J=4,6
                  PVIN(J,NP) = PVIN(J,NP)*86400D0
               END DO

!           Precompute also the extrapolation correction terms.
               R2 = 0D0
               DO I=1,3
                  W = PVIN(I,NP)
                  R2 = R2+W*W
               END DO
               R2X3(NP) = R2*3D0
               GC(NP) = GCON2/(2D0*R2*SQRT(R2))
            END DO
         END IF

!     Reset the first-time flag.
         FIRST = .FALSE.

!     Unperturbed motion of the body at middle of timestep (AU,AU/s).
         CALL sla_UE2PV(T,UL,PV0,J)
         IF (J.NE.0) GO TO 9010

!     Perturbed position of the body (AU) and heliocentric distance cubed.
         R2 = 0D0
         DO I=1,3
            W = PV0(I)+PERP(I)+(PERV(I)+PERA(I)*HTS/2D0)*HTS
            PV(I) = W
            R2 = R2+W*W
         END DO
         R3 = R2*SQRT(R2)

!     The body's unperturbed heliocentric distance cubed.
         R2 = 0D0
         DO I=1,3
            W = PV0(I)
            R2 = R2+W*W
         END DO
         R03 = R2*SQRT(R2)

!     Compute indirect and initialize direct parts of the perturbation.
         DO I=1,3
            FI(I) = PV0(I)/R03-PV(I)/R3
            FD(I) = 0D0
         END DO

!     Ready to compute the direct planetary effects.

!     Reset the "near-Earth" flag.
         NE = .FALSE.

!     Interval from state-vector epoch to middle of current timestep.
         DT = T-TPMO
         DT2 = DT*DT

!     Planet by planet, including separate Earth and Moon.
         DO NP=1,10

!        Which perturbing body?
            IF (NP.LE.8) THEN

!           Planet: compute the extrapolation in longitude (squared).
               R2 = 0D0
               DO J=4,6
                  W = PVIN(J,NP)*DT
                  R2 = R2+W*W
               END DO

!           Hence the tangential-to-circular correction factor.
               FC = 1D0+R2/R2X3(NP)

!           The radial correction factor due to the inwards acceleration.
               FG = 1D0-GC(NP)*DT2

!           Planet's position.
               DO I=1,3
                  RHO(I) = FG*(PVIN(I,NP)+FC*PVIN(I+3,NP)*DT)
               END DO

            ELSE IF (NE) THEN

!           Near-Earth and either Earth or Moon.

               IF (NP.EQ.9) THEN

!              Earth: position.
                  CALL sla_EVP(T,2000D0,VB,PB,VH,PE)
                  DO I=1,3
                     RHO(I) = PE(I)
                  END DO

               ELSE

!              Moon: position.
                  CALL sla_PREC(sla_EPJ(T),2000D0,PMAT)
                  CALL sla_DMOON(T,PVM)
                  CALL sla_DMXV(PMAT,PVM,PM)
                  DO I=1,3
                     RHO(I) = PM(I)+PE(I)
                  END DO
               END IF
            END IF

!        Proceed unless Earth or Moon and not the near-Earth case.
            IF (NP.LE.8.OR.NE) THEN

!           Heliocentric distance cubed.
               R2 = 0D0
               DO I=1,3
                  W = RHO(I)
                  R2 = R2+W*W
               END DO
               R = SQRT(R2)
               RHO3 = R2*R

!           Body-to-planet vector, and distance.
               R2 = 0D0
               DO I=1,3
                  W = RHO(I)-PV(I)
                  DELTA(I) = W
                  R2 = R2+W*W
               END DO
               R = SQRT(R2)

!           If this is the EMB, set the near-Earth flag appropriately.
               IF (NP.EQ.3.AND.R.LT.RNE) NE = .TRUE.

!           Proceed unless EMB and this is the near-Earth case.
               IF (.NOT.(NE.AND.NP.EQ.3)) THEN

!              If too close, ignore this planet and set a warning.
                  IF (R.LT.COINC) THEN
                     JSTAT = NP

                  ELSE

!                 Accumulate "direct" part of perturbation acceleration.
                     DELTA3 = R2*R
                     W = AMAS(NP)
                     DO I=1,3
                        FD(I) = FD(I)+(DELTA(I)/DELTA3-RHO(I)/RHO3)/W
                     END DO
                  END IF
               END IF
            END IF
         END DO

!     Update the perturbations to the end of the timestep.
         RTN = RTN+TS
         DO I=1,3
            W = (FI(I)+FD(I))*GCON2
            FT = W*TS
            PERP(I) = PERP(I)+(PERV(I)+FT/2D0)*TS
            PERV(I) = PERV(I)+FT
            PERA(I) = W
         END DO

!     Time still to go.
         TLEFT = TSPAN-RTN

!     Is it either time to rectify the orbit or the last time through?
         IF (ABS(RTN).GE.AGEBEL.OR.FB*TLEFT.LE.0D0) THEN

!        Yes: update to the end of the current timestep.
            T0 = T0+RTN
            RTN = 0D0

!        The body's unperturbed motion (AU,AU/s).
            CALL sla_UE2PV(T0,UL,PV0,J)
            IF (J.NE.0) GO TO 9010

!        Add and re-initialize the perturbations.
            DO I=1,3
               J = I+3
               PV(I) = PV0(I)+PERP(I)
               PV(J) = PV0(J)+PERV(I)/86400D0
               PERP(I) = 0D0
               PERV(I) = 0D0
               PERA(I) = FD(I)*GCON2
            END DO

!        Use the position and velocity to set up new universal elements.
            CALL sla_PV2UE(PV,T0,0D0,UL,J)
            IF (J.NE.0) GO TO 9010

!        Adjust the timespan and time left.
            TSPAN = TFINAL-T0
            TLEFT = TSPAN
         END IF

!     Next timestep.
      END DO

!  Return the updated universal-element set.
      DO I=1,13
         U(I) = UL(I)
      END DO

!  Finished.
      GO TO 9999

!  Miscellaneous numerical error.
 9010 CONTINUE
      JSTAT = -1

 9999 CONTINUE
      END
      SUBROUTINE sla_PLANEL (DATE, JFORM, EPOCH, ORBINC, ANODE, PERIH, &
                            AORQ, E, AORL, DM, PV, JSTAT)
!+
!     - - - - - - -
!      P L A N E L
!     - - - - - - -
!
!  Heliocentric position and velocity of a planet, asteroid or comet,
!  starting from orbital elements.
!
!  Given:
!     DATE     d     date, Modified Julian Date (JD - 2400000.5, Note 1)
!     JFORM    i     choice of element set (1-3; Note 3)
!     EPOCH    d     epoch of elements (TT MJD, Note 4)
!     ORBINC   d     inclination (radians)
!     ANODE    d     longitude of the ascending node (radians)
!     PERIH    d     longitude or argument of perihelion (radians)
!     AORQ     d     mean distance or perihelion distance (AU)
!     E        d     eccentricity
!     AORL     d     mean anomaly or longitude (radians, JFORM=1,2 only)
!     DM       d     daily motion (radians, JFORM=1 only)
!
!  Returned:
!     PV       d(6)  heliocentric x,y,z,xdot,ydot,zdot of date,
!                                     J2000 equatorial triad (AU,AU/s)
!     JSTAT    i     status:  0 = OK
!                            -1 = illegal JFORM
!                            -2 = illegal E
!                            -3 = illegal AORQ
!                            -4 = illegal DM
!                            -5 = numerical error
!
!  Called:  sla_EL2UE, sla_UE2PV
!
!  Notes
!
!  1  DATE is the instant for which the prediction is required.  It is
!     in the TT timescale (formerly Ephemeris Time, ET) and is a
!     Modified Julian Date (JD-2400000.5).
!
!  2  The elements are with respect to the J2000 ecliptic and equinox.
!
!  3  A choice of three different element-set options is available:
!
!     Option JFORM = 1, suitable for the major planets:
!
!       EPOCH  = epoch of elements (TT MJD)
!       ORBINC = inclination i (radians)
!       ANODE  = longitude of the ascending node, big omega (radians)
!       PERIH  = longitude of perihelion, curly pi (radians)
!       AORQ   = mean distance, a (AU)
!       E      = eccentricity, e (range 0 to <1)
!       AORL   = mean longitude L (radians)
!       DM     = daily motion (radians)
!
!     Option JFORM = 2, suitable for minor planets:
!
!       EPOCH  = epoch of elements (TT MJD)
!       ORBINC = inclination i (radians)
!       ANODE  = longitude of the ascending node, big omega (radians)
!       PERIH  = argument of perihelion, little omega (radians)
!       AORQ   = mean distance, a (AU)
!       E      = eccentricity, e (range 0 to <1)
!       AORL   = mean anomaly M (radians)
!
!     Option JFORM = 3, suitable for comets:
!
!       EPOCH  = epoch of elements and perihelion (TT MJD)
!       ORBINC = inclination i (radians)
!       ANODE  = longitude of the ascending node, big omega (radians)
!       PERIH  = argument of perihelion, little omega (radians)
!       AORQ   = perihelion distance, q (AU)
!       E      = eccentricity, e (range 0 to 10)
!
!     Unused arguments (DM for JFORM=2, AORL and DM for JFORM=3) are not
!     accessed.
!
!  4  Each of the three element sets defines an unperturbed heliocentric
!     orbit.  For a given epoch of observation, the position of the body
!     in its orbit can be predicted from these elements, which are
!     called "osculating elements", using standard two-body analytical
!     solutions.  However, due to planetary perturbations, a given set
!     of osculating elements remains usable for only as long as the
!     unperturbed orbit that it describes is an adequate approximation
!     to reality.  Attached to such a set of elements is a date called
!     the "osculating epoch", at which the elements are, momentarily,
!     a perfect representation of the instantaneous position and
!     velocity of the body.
!
!     Therefore, for any given problem there are up to three different
!     epochs in play, and it is vital to distinguish clearly between
!     them:
!
!     . The epoch of observation:  the moment in time for which the
!       position of the body is to be predicted.
!
!     . The epoch defining the position of the body:  the moment in time
!       at which, in the absence of purturbations, the specified
!       position (mean longitude, mean anomaly, or perihelion) is
!       reached.
!
!     . The osculating epoch:  the moment in time at which the given
!       elements are correct.
!
!     For the major-planet and minor-planet cases it is usual to make
!     the epoch that defines the position of the body the same as the
!     epoch of osculation.  Thus, only two different epochs are
!     involved:  the epoch of the elements and the epoch of observation.
!
!     For comets, the epoch of perihelion fixes the position in the
!     orbit and in general a different epoch of osculation will be
!     chosen.  Thus, all three types of epoch are involved.
!
!     For the present routine:
!
!     . The epoch of observation is the argument DATE.
!
!     . The epoch defining the position of the body is the argument
!       EPOCH.
!
!     . The osculating epoch is not used and is assumed to be close
!       enough to the epoch of observation to deliver adequate accuracy.
!       If not, a preliminary call to sla_PERTEL may be used to update
!       the element-set (and its associated osculating epoch) by
!       applying planetary perturbations.
!
!  5  The reference frame for the result is with respect to the mean
!     equator and equinox of epoch J2000.
!
!  6  The algorithm was originally adapted from the EPHSLA program of
!     D.H.P.Jones (private communication, 1996).  The method is based
!     on Stumpff's Universal Variables.
!
!  Reference:  Everhart, E. & Pitkin, E.T., Am.J.Phys. 51, 712, 1983.
!
!  P.T.Wallace   Starlink   31 December 2002
!
!  Copyright (C) 2002 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE
      INTEGER JFORM
      DOUBLE PRECISION EPOCH,ORBINC,ANODE,PERIH,AORQ,E,AORL,DM,PV(6)
      INTEGER JSTAT

      DOUBLE PRECISION U(13)
      INTEGER J



!  Validate elements and convert to "universal variables" parameters.
      CALL sla_EL2UE(DATE,JFORM, &
                    EPOCH,ORBINC,ANODE,PERIH,AORQ,E,AORL,DM,U,J)

!  Determine the position and velocity.
      IF (J.EQ.0) THEN
         CALL sla_UE2PV(DATE,U,PV,J)
         IF (J.NE.0) J=-5
      END IF

!  Wrap up.
      JSTAT = J

      END
      SUBROUTINE sla_PLANET (DATE, NP, PV, JSTAT)
!+
!     - - - - - - -
!      P L A N E T
!     - - - - - - -
!
!  Approximate heliocentric position and velocity of a specified
!  major planet.
!
!  Given:
!     DATE      d      Modified Julian Date (JD - 2400000.5)
!     NP        i      planet (1=Mercury, 2=Venus, 3=EMB ... 9=Pluto)
!
!  Returned:
!     PV        d(6)   heliocentric x,y,z,xdot,ydot,zdot, J2000
!                                           equatorial triad (AU,AU/s)
!     JSTAT     i      status: +1 = warning: date out of range
!                               0 = OK
!                              -1 = illegal NP (outside 1-9)
!                              -2 = solution didn't converge
!
!  Called:  sla_PLANEL
!
!  Notes
!
!  1  The epoch, DATE, is in the TDB timescale and is a Modified
!     Julian Date (JD-2400000.5).
!
!  2  The reference frame is equatorial and is with respect to the
!     mean equinox and ecliptic of epoch J2000.
!
!  3  If an NP value outside the range 1-9 is supplied, an error
!     status (JSTAT = -1) is returned and the PV vector set to zeroes.
!
!  4  The algorithm for obtaining the mean elements of the planets
!     from Mercury to Neptune is due to J.L. Simon, P. Bretagnon,
!     J. Chapront, M. Chapront-Touze, G. Francou and J. Laskar
!     (Bureau des Longitudes, Paris).  The (completely different)
!     algorithm for calculating the ecliptic coordinates of Pluto
!     is by Meeus.
!
!  5  Comparisons of the present routine with the JPL DE200 ephemeris
!     give the following RMS errors over the interval 1960-2025:
!
!                      position (km)     speed (metre/sec)
!
!        Mercury            334               0.437
!        Venus             1060               0.855
!        EMB               2010               0.815
!        Mars              7690               1.98
!        Jupiter          71700               7.70
!        Saturn          199000              19.4
!        Uranus          564000              16.4
!        Neptune         158000              14.4
!        Pluto            36400               0.137
!
!     From comparisons with DE102, Simon et al quote the following
!     longitude accuracies over the interval 1800-2200:
!
!        Mercury                 4"
!        Venus                   5"
!        EMB                     6"
!        Mars                   17"
!        Jupiter                71"
!        Saturn                 81"
!        Uranus                 86"
!        Neptune                11"
!
!     In the case of Pluto, Meeus quotes an accuracy of 0.6 arcsec
!     in longitude and 0.2 arcsec in latitude for the period
!     1885-2099.
!
!     For all except Pluto, over the period 1000-3000 the accuracy
!     is better than 1.5 times that over 1800-2200.  Outside the
!     period 1000-3000 the accuracy declines.  For Pluto the
!     accuracy declines rapidly outside the period 1885-2099.
!     Outside these ranges (1885-2099 for Pluto, 1000-3000 for
!     the rest) a "date out of range" warning status (JSTAT=+1)
!     is returned.
!
!  6  The algorithms for (i) Mercury through Neptune and (ii) Pluto
!     are completely independent.  In the Mercury through Neptune
!     case, the present SLALIB implementation differs from the
!     original Simon et al Fortran code in the following respects.
!
!     !  The date is supplied as a Modified Julian Date rather
!        than a Julian Date (MJD = JD - 2400000.5).
!
!     !  The result is returned only in equatorial Cartesian form;
!        the ecliptic longitude, latitude and radius vector are not
!        returned.
!
!     !  The velocity is in AU per second, not AU per day.
!
!     !  Different error/warning status values are used.
!
!     !  Kepler's equation is not solved inline.
!
!     !  Polynomials in T are nested to minimize rounding errors.
!
!     !  Explicit double-precision constants are used to avoid
!        mixed-mode expressions.
!
!     !  There are other, cosmetic, changes to comply with
!        Starlink/SLALIB style guidelines.
!
!     None of the above changes affects the result significantly.
!
!  7  For NP=3 the result is for the Earth-Moon Barycentre.  To
!     obtain the heliocentric position and velocity of the Earth,
!     either use the SLALIB routine sla_EVP or call sla_DMOON and
!     subtract 0.012150581 times the geocentric Moon vector from
!     the EMB vector produced by the present routine.  (The Moon
!     vector should be precessed to J2000 first, but this can
!     be omitted for modern epochs without introducing significant
!     inaccuracy.)
!
!  References:  Simon et al., Astron. Astrophys. 282, 663 (1994).
!               Meeus, Astronomical Algorithms, Willmann-Bell (1991).
!
!  P.T.Wallace   Starlink   27 May 1997
!
!  Copyright (C) 1997 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE
      INTEGER NP
      DOUBLE PRECISION PV(6)
      INTEGER JSTAT

!  2Pi, deg to radians, arcsec to radians
      DOUBLE PRECISION D2PI,D2R,AS2R
      PARAMETER (D2PI=6.283185307179586476925286766559D0, &
                D2R=0.017453292519943295769236907684886D0, &
                AS2R=4.848136811095359935899141023579D-6)

!  Gaussian gravitational constant (exact)
      DOUBLE PRECISION GCON
      PARAMETER (GCON=0.01720209895D0)

!  Seconds per Julian century
      DOUBLE PRECISION SPC
      PARAMETER (SPC=36525D0*86400D0)

!  Sin and cos of J2000 mean obliquity (IAU 1976)
      DOUBLE PRECISION SE,CE
      PARAMETER (SE=0.3977771559319137D0, &
                CE=0.9174820620691818D0)

      INTEGER I,J,IJSP(3,43)
      DOUBLE PRECISION AMAS(8),A(3,8),DLM(3,8),E(3,8), &
                      PI(3,8),DINC(3,8),OMEGA(3,8), &
                      DKP(9,8),CA(9,8),SA(9,8), &
                      DKQ(10,8),CLO(10,8),SLO(10,8), &
                      T,DA,DE,DPE,DI,DO,DMU,ARGA,ARGL,DM, &
                      AB(2,3,43),DJ0,DS0,DP0,DL0,DLD0,DB0,DR0, &
                      DJ,DS,DP,DJD,DSD,DPD,WLBR(3),WLBRD(3), &
                      WJ,WS,WP,AL,ALD,SAL,CAL, &
                      AC,BC,DL,DLD,DB,DBD,DR,DRD, &
                      SL,CL,SB,CB,SLCB,CLCB,X,Y,Z,XD,YD,ZD

!  -----------------------
!  Mercury through Neptune
!  -----------------------

!  Planetary inverse masses
      DATA AMAS / 6023600D0,408523.5D0,328900.5D0,3098710D0, &
                 1047.355D0,3498.5D0,22869D0,19314D0 /

!
!  Tables giving the mean Keplerian elements, limited to T**2 terms:
!
!         A       semi-major axis (AU)
!         DLM     mean longitude (degree and arcsecond)
!         E       eccentricity
!         PI      longitude of the perihelion (degree and arcsecond)
!         DINC    inclination (degree and arcsecond)
!         OMEGA   longitude of the ascending node (degree and arcsecond)
!
      DATA A / &
       0.3870983098D0,             0D0,      0D0, &
       0.7233298200D0,             0D0,      0D0, &
       1.0000010178D0,             0D0,      0D0, &
       1.5236793419D0,           3D-10,      0D0, &
       5.2026032092D0,       19132D-10,  -39D-10, &
       9.5549091915D0, -0.0000213896D0,  444D-10, &
      19.2184460618D0,       -3716D-10,  979D-10, &
      30.1103868694D0,      -16635D-10,  686D-10 /
!
      DATA DLM / &
      252.25090552D0, 5381016286.88982D0,  -1.92789D0, &
      181.97980085D0, 2106641364.33548D0,   0.59381D0, &
      100.46645683D0, 1295977422.83429D0,  -2.04411D0, &
      355.43299958D0,  689050774.93988D0,   0.94264D0, &
       34.35151874D0,  109256603.77991D0, -30.60378D0, &
       50.07744430D0,   43996098.55732D0,  75.61614D0, &
      314.05500511D0,   15424811.93933D0,  -1.75083D0, &
      304.34866548D0,    7865503.20744D0,   0.21103D0/
!
      DATA E / &
      0.2056317526D0,  0.0002040653D0,      -28349D-10, &
      0.0067719164D0, -0.0004776521D0,       98127D-10, &
      0.0167086342D0, -0.0004203654D0, -0.0000126734D0, &
      0.0934006477D0,  0.0009048438D0,      -80641D-10, &
      0.0484979255D0,  0.0016322542D0, -0.0000471366D0, &
      0.0555481426D0, -0.0034664062D0, -0.0000643639D0, &
      0.0463812221D0, -0.0002729293D0,  0.0000078913D0, &
      0.0094557470D0,  0.0000603263D0,            0D0 /
!
      DATA PI / &
       77.45611904D0,  5719.11590D0,   -4.83016D0, &
      131.56370300D0,   175.48640D0, -498.48184D0, &
      102.93734808D0, 11612.35290D0,   53.27577D0, &
      336.06023395D0, 15980.45908D0,  -62.32800D0, &
       14.33120687D0,  7758.75163D0,  259.95938D0, &
       93.05723748D0, 20395.49439D0,  190.25952D0, &
      173.00529106D0,  3215.56238D0,  -34.09288D0, &
       48.12027554D0,  1050.71912D0,   27.39717D0 /
!
      DATA DINC / &
      7.00498625D0, -214.25629D0,   0.28977D0, &
      3.39466189D0,  -30.84437D0, -11.67836D0, &
               0D0,  469.97289D0,  -3.35053D0, &
      1.84972648D0, -293.31722D0,  -8.11830D0, &
      1.30326698D0,  -71.55890D0,  11.95297D0, &
      2.48887878D0,   91.85195D0, -17.66225D0, &
      0.77319689D0,  -60.72723D0,   1.25759D0, &
      1.76995259D0,    8.12333D0,   0.08135D0 /
!
      DATA OMEGA / &
       48.33089304D0,  -4515.21727D0,  -31.79892D0, &
       76.67992019D0, -10008.48154D0,  -51.32614D0, &
      174.87317577D0,  -8679.27034D0,   15.34191D0, &
       49.55809321D0, -10620.90088D0, -230.57416D0, &
      100.46440702D0,   6362.03561D0,  326.52178D0, &
      113.66550252D0,  -9240.19942D0,  -66.23743D0, &
       74.00595701D0,   2669.15033D0,  145.93964D0, &
      131.78405702D0,   -221.94322D0,   -0.78728D0 /
!
!  Tables for trigonometric terms to be added to the mean elements
!  of the semi-major axes.
!
      DATA DKP / &
      69613, 75645, 88306, 59899, 15746, 71087, 142173,  3086,    0, &
      21863, 32794, 26934, 10931, 26250, 43725,  53867, 28939,    0, &
      16002, 21863, 32004, 10931, 14529, 16368,  15318, 32794,    0, &
      6345,   7818, 15636,  7077,  8184, 14163,   1107,  4872,    0, &
      1760,   1454,  1167,   880,   287,  2640,     19,  2047, 1454, &
       574,      0,   880,   287,    19,  1760,   1167,   306,  574, &
       204,      0,   177,  1265,     4,   385,    200,   208,  204, &
         0,    102,   106,     4,    98,  1367,    487,   204,    0 /
!
      DATA CA / &
           4,    -13,    11,    -9,    -9,    -3,    -1,     4,    0, &
        -156,     59,   -42,     6,    19,   -20,   -10,   -12,    0, &
          64,   -152,    62,    -8,    32,   -41,    19,   -11,    0, &
         124,    621,  -145,   208,    54,   -57,    30,    15,    0, &
      -23437,  -2634,  6601,  6259, -1507, -1821,  2620, -2115,-1489, &
       62911,-119919, 79336, 17814,-24241, 12068,  8306, -4893, 8902, &
      389061,-262125,-44088,  8387,-22976, -2093,  -615, -9720, 6633, &
     -412235,-157046,-31430, 37817, -9740,   -13, -7449,  9644,    0 /
!
      DATA SA / &
          -29,    -1,     9,     6,    -6,     5,     4,     0,    0, &
          -48,  -125,   -26,   -37,    18,   -13,   -20,    -2,    0, &
         -150,   -46,    68,    54,    14,    24,   -28,    22,    0, &
         -621,   532,  -694,   -20,   192,   -94,    71,   -73,    0, &
       -14614,-19828, -5869,  1881, -4372, -2255,   782,   930,  913, &
       139737,     0, 24667, 51123, -5102,  7429, -4095, -1976,-9566, &
      -138081,     0, 37205,-49039,-41901,-33872,-27037,-12474,18797, &
            0, 28492,133236, 69654, 52322,-49577,-26430, -3593,    0 /
!
!  Tables giving the trigonometric terms to be added to the mean
!  elements of the mean longitudes.
!
      DATA DKQ / &
       3086, 15746, 69613, 59899, 75645, 88306, 12661, 2658,  0,   0, &
      21863, 32794, 10931,    73,  4387, 26934,  1473, 2157,  0,   0, &
         10, 16002, 21863, 10931,  1473, 32004,  4387,   73,  0,   0, &
         10,  6345,  7818,  1107, 15636,  7077,  8184,  532, 10,   0, &
         19,  1760,  1454,   287,  1167,   880,   574, 2640, 19,1454, &
         19,   574,   287,   306,  1760,    12,    31,   38, 19, 574, &
          4,   204,   177,     8,    31,   200,  1265,  102,  4, 204, &
          4,   102,   106,     8,    98,  1367,   487,  204,  4, 102 /
!
      DATA CLO / &
          21,   -95, -157,   41,   -5,   42,   23,   30,     0,    0, &
        -160,  -313, -235,   60,  -74,  -76,  -27,   34,     0,    0, &
        -325,  -322,  -79,  232,  -52,   97,   55,  -41,     0,    0, &
        2268,  -979,  802,  602, -668,  -33,  345,  201,   -55,    0, &
        7610, -4997,-7689,-5841,-2617, 1115, -748, -607,  6074,  354, &
      -18549, 30125,20012, -730,  824,   23, 1289, -352,-14767,-2062, &
     -135245,-14594, 4197,-4030,-5630,-2898, 2540, -306,  2939, 1986, &
       89948,  2103, 8963, 2695, 3682, 1648,  866, -154, -1963, -283 /
!
      DATA SLO / &
        -342,   136,  -23,   62,   66,  -52,  -33,   17,     0,    0, &
         524,  -149,  -35,  117,  151,  122,  -71,  -62,     0,    0, &
        -105,  -137,  258,   35, -116,  -88, -112,  -80,     0,    0, &
         854,  -205, -936, -240,  140, -341,  -97, -232,   536,    0, &
      -56980,  8016, 1012, 1448,-3024,-3710,  318,  503,  3767,  577, &
      138606,-13478,-4964, 1441,-1319,-1482,  427, 1236, -9167,-1918, &
       71234,-41116, 5334,-4935,-1848,   66,  434,-1748,  3780, -701, &
      -47645, 11647, 2166, 3194,  679,    0, -244, -419, -2531,   48 /

!  -----
!  Pluto
!  -----

!
!  Coefficients for fundamental arguments:  mean longitudes
!  (degrees) and mean rate of change of longitude (degrees per
!  Julian century) for Jupiter, Saturn and Pluto
!
      DATA DJ0, DJD / 34.35D0, 3034.9057D0 /
      DATA DS0, DSD / 50.08D0, 1222.1138D0 /
      DATA DP0, DPD / 238.96D0, 144.9600D0 /

!  Coefficients for latitude, longitude, radius vector
      DATA DL0,DLD0 / 238.956785D0, 144.96D0 /
      DATA DB0 / -3.908202D0 /
      DATA DR0 / 40.7247248D0 /

!
!  Coefficients for periodic terms (Meeus's Table 36.A)
!
!  The coefficients for term n in the series are:
!
!    IJSP(1,n)     J
!    IJSP(2,n)     S
!    IJSP(3,n)     P
!    AB(1,1,n)     longitude sine (degrees)
!    AB(2,1,n)     longitude cosine (degrees)
!    AB(1,2,n)     latitude sine (degrees)
!    AB(2,2,n)     latitude cosine (degrees)
!    AB(1,3,n)     radius vector sine (AU)
!    AB(2,3,n)     radius vector cosine (AU)
!
      DATA (IJSP(I, 1),I=1,3),((AB(J,I, 1),J=1,2),I=1,3) / &
                                  0,  0,  1, &
                 -19798886D-6,  19848454D-6, &
                  -5453098D-6, -14974876D-6, &
                  66867334D-7,  68955876D-7 /
      DATA (IJSP(I, 2),I=1,3),((AB(J,I, 2),J=1,2),I=1,3) / &
                                  0,  0,  2, &
                    897499D-6,  -4955707D-6, &
                   3527363D-6,   1672673D-6, &
                 -11826086D-7,   -333765D-7 /
      DATA (IJSP(I, 3),I=1,3),((AB(J,I, 3),J=1,2),I=1,3) / &
                                  0,  0,  3, &
                    610820D-6,   1210521D-6, &
                  -1050939D-6,    327763D-6, &
                   1593657D-7,  -1439953D-7 /
      DATA (IJSP(I, 4),I=1,3),((AB(J,I, 4),J=1,2),I=1,3) / &
                                  0,  0,  4, &
                   -341639D-6,   -189719D-6, &
                    178691D-6,   -291925D-6, &
                    -18948D-7,    482443D-7 /
      DATA (IJSP(I, 5),I=1,3),((AB(J,I, 5),J=1,2),I=1,3) / &
                                  0,  0,  5, &
                    129027D-6,    -34863D-6, &
                     18763D-6,    100448D-6, &
                    -66634D-7,    -85576D-7 /
      DATA (IJSP(I, 6),I=1,3),((AB(J,I, 6),J=1,2),I=1,3) / &
                                  0,  0,  6, &
                    -38215D-6,     31061D-6, &
                    -30594D-6,    -25838D-6, &
                     30841D-7,     -5765D-7 /
      DATA (IJSP(I, 7),I=1,3),((AB(J,I, 7),J=1,2),I=1,3) / &
                                  0,  1, -1, &
                     20349D-6,     -9886D-6, &
                      4965D-6,     11263D-6, &
                     -6140D-7,     22254D-7 /
      DATA (IJSP(I, 8),I=1,3),((AB(J,I, 8),J=1,2),I=1,3) / &
                                  0,  1,  0, &
                     -4045D-6,     -4904D-6, &
                       310D-6,      -132D-6, &
                      4434D-7,      4443D-7 /
      DATA (IJSP(I, 9),I=1,3),((AB(J,I, 9),J=1,2),I=1,3) / &
                                  0,  1,  1, &
                     -5885D-6,     -3238D-6, &
                      2036D-6,      -947D-6, &
                     -1518D-7,       641D-7 /
      DATA (IJSP(I,10),I=1,3),((AB(J,I,10),J=1,2),I=1,3) / &
                                  0,  1,  2, &
                     -3812D-6,      3011D-6, &
                        -2D-6,      -674D-6, &
                        -5D-7,       792D-7 /
      DATA (IJSP(I,11),I=1,3),((AB(J,I,11),J=1,2),I=1,3) / &
                                  0,  1,  3, &
                      -601D-6,      3468D-6, &
                      -329D-6,      -563D-6, &
                       518D-7,       518D-7 /
      DATA (IJSP(I,12),I=1,3),((AB(J,I,12),J=1,2),I=1,3) / &
                                  0,  2, -2, &
                      1237D-6,       463D-6, &
                       -64D-6,        39D-6, &
                       -13D-7,      -221D-7 /
      DATA (IJSP(I,13),I=1,3),((AB(J,I,13),J=1,2),I=1,3) / &
                                  0,  2, -1, &
                      1086D-6,      -911D-6, &
                       -94D-6,       210D-6, &
                       837D-7,      -494D-7 /
      DATA (IJSP(I,14),I=1,3),((AB(J,I,14),J=1,2),I=1,3) / &
                                  0,  2,  0, &
                       595D-6,     -1229D-6, &
                        -8D-6,      -160D-6, &
                      -281D-7,       616D-7 /
      DATA (IJSP(I,15),I=1,3),((AB(J,I,15),J=1,2),I=1,3) / &
                                  1, -1,  0, &
                      2484D-6,      -485D-6, &
                      -177D-6,       259D-6, &
                       260D-7,      -395D-7 /
      DATA (IJSP(I,16),I=1,3),((AB(J,I,16),J=1,2),I=1,3) / &
                                  1, -1,  1, &
                       839D-6,     -1414D-6, &
                        17D-6,       234D-6, &
                      -191D-7,      -396D-7 /
      DATA (IJSP(I,17),I=1,3),((AB(J,I,17),J=1,2),I=1,3) / &
                                  1,  0, -3, &
                      -964D-6,      1059D-6, &
                       582D-6,      -285D-6, &
                     -3218D-7,       370D-7 /
      DATA (IJSP(I,18),I=1,3),((AB(J,I,18),J=1,2),I=1,3) / &
                                  1,  0, -2, &
                     -2303D-6,     -1038D-6, &
                      -298D-6,       692D-6, &
                      8019D-7,     -7869D-7 /
      DATA (IJSP(I,19),I=1,3),((AB(J,I,19),J=1,2),I=1,3) / &
                                  1,  0, -1, &
                      7049D-6,       747D-6, &
                       157D-6,       201D-6, &
                       105D-7,     45637D-7 /
      DATA (IJSP(I,20),I=1,3),((AB(J,I,20),J=1,2),I=1,3) / &
                                  1,  0,  0, &
                      1179D-6,      -358D-6, &
                       304D-6,       825D-6, &
                      8623D-7,      8444D-7 /
      DATA (IJSP(I,21),I=1,3),((AB(J,I,21),J=1,2),I=1,3) / &
                                  1,  0,  1, &
                       393D-6,       -63D-6, &
                      -124D-6,       -29D-6, &
                      -896D-7,      -801D-7 /
      DATA (IJSP(I,22),I=1,3),((AB(J,I,22),J=1,2),I=1,3) / &
                                  1,  0,  2, &
                       111D-6,      -268D-6, &
                        15D-6,         8D-6, &
                       208D-7,      -122D-7 /
      DATA (IJSP(I,23),I=1,3),((AB(J,I,23),J=1,2),I=1,3) / &
                                  1,  0,  3, &
                       -52D-6,      -154D-6, &
                         7D-6,        15D-6, &
                      -133D-7,        65D-7 /
      DATA (IJSP(I,24),I=1,3),((AB(J,I,24),J=1,2),I=1,3) / &
                                  1,  0,  4, &
                       -78D-6,       -30D-6, &
                         2D-6,         2D-6, &
                       -16D-7,         1D-7 /
      DATA (IJSP(I,25),I=1,3),((AB(J,I,25),J=1,2),I=1,3) / &
                                  1,  1, -3, &
                       -34D-6,       -26D-6, &
                         4D-6,         2D-6, &
                       -22D-7,         7D-7 /
      DATA (IJSP(I,26),I=1,3),((AB(J,I,26),J=1,2),I=1,3) / &
                                  1,  1, -2, &
                       -43D-6,         1D-6, &
                         3D-6,         0D-6, &
                        -8D-7,        16D-7 /
      DATA (IJSP(I,27),I=1,3),((AB(J,I,27),J=1,2),I=1,3) / &
                                  1,  1, -1, &
                       -15D-6,        21D-6, &
                         1D-6,        -1D-6, &
                         2D-7,         9D-7 /
      DATA (IJSP(I,28),I=1,3),((AB(J,I,28),J=1,2),I=1,3) / &
                                  1,  1,  0, &
                        -1D-6,        15D-6, &
                         0D-6,        -2D-6, &
                        12D-7,         5D-7 /
      DATA (IJSP(I,29),I=1,3),((AB(J,I,29),J=1,2),I=1,3) / &
                                  1,  1,  1, &
                         4D-6,         7D-6, &
                         1D-6,         0D-6, &
                         1D-7,        -3D-7 /
      DATA (IJSP(I,30),I=1,3),((AB(J,I,30),J=1,2),I=1,3) / &
                                  1,  1,  3, &
                         1D-6,         5D-6, &
                         1D-6,        -1D-6, &
                         1D-7,         0D-7 /
      DATA (IJSP(I,31),I=1,3),((AB(J,I,31),J=1,2),I=1,3) / &
                                  2,  0, -6, &
                         8D-6,         3D-6, &
                        -2D-6,        -3D-6, &
                         9D-7,         5D-7 /
      DATA (IJSP(I,32),I=1,3),((AB(J,I,32),J=1,2),I=1,3) / &
                                  2,  0, -5, &
                        -3D-6,         6D-6, &
                         1D-6,         2D-6, &
                         2D-7,        -1D-7 /
      DATA (IJSP(I,33),I=1,3),((AB(J,I,33),J=1,2),I=1,3) / &
                                  2,  0, -4, &
                         6D-6,       -13D-6, &
                        -8D-6,         2D-6, &
                        14D-7,        10D-7 /
      DATA (IJSP(I,34),I=1,3),((AB(J,I,34),J=1,2),I=1,3) / &
                                  2,  0, -3, &
                        10D-6,        22D-6, &
                        10D-6,        -7D-6, &
                       -65D-7,        12D-7 /
      DATA (IJSP(I,35),I=1,3),((AB(J,I,35),J=1,2),I=1,3) / &
                                  2,  0, -2, &
                       -57D-6,       -32D-6, &
                         0D-6,        21D-6, &
                       126D-7,      -233D-7 /
      DATA (IJSP(I,36),I=1,3),((AB(J,I,36),J=1,2),I=1,3) / &
                                  2,  0, -1, &
                       157D-6,       -46D-6, &
                         8D-6,         5D-6, &
                       270D-7,      1068D-7 /
      DATA (IJSP(I,37),I=1,3),((AB(J,I,37),J=1,2),I=1,3) / &
                                  2,  0,  0, &
                        12D-6,       -18D-6, &
                        13D-6,        16D-6, &
                       254D-7,       155D-7 /
      DATA (IJSP(I,38),I=1,3),((AB(J,I,38),J=1,2),I=1,3) / &
                                  2,  0,  1, &
                        -4D-6,         8D-6, &
                        -2D-6,        -3D-6, &
                       -26D-7,        -2D-7 /
      DATA (IJSP(I,39),I=1,3),((AB(J,I,39),J=1,2),I=1,3) / &
                                  2,  0,  2, &
                        -5D-6,         0D-6, &
                         0D-6,         0D-6, &
                         7D-7,         0D-7 /
      DATA (IJSP(I,40),I=1,3),((AB(J,I,40),J=1,2),I=1,3) / &
                                  2,  0,  3, &
                         3D-6,         4D-6, &
                         0D-6,         1D-6, &
                       -11D-7,         4D-7 /
      DATA (IJSP(I,41),I=1,3),((AB(J,I,41),J=1,2),I=1,3) / &
                                  3,  0, -2, &
                        -1D-6,        -1D-6, &
                         0D-6,         1D-6, &
                         4D-7,       -14D-7 /
      DATA (IJSP(I,42),I=1,3),((AB(J,I,42),J=1,2),I=1,3) / &
                                  3,  0, -1, &
                         6D-6,        -3D-6, &
                         0D-6,         0D-6, &
                        18D-7,        35D-7 /
      DATA (IJSP(I,43),I=1,3),((AB(J,I,43),J=1,2),I=1,3) / &
                                  3,  0,  0, &
                        -1D-6,        -2D-6, &
                         0D-6,         1D-6, &
                        13D-7,         3D-7 /


!  Validate the planet number.
      IF (NP.LT.1.OR.NP.GT.9) THEN
         JSTAT=-1
         DO I=1,6
            PV(I)=0D0
         END DO
      ELSE

!     Separate algorithms for Pluto and the rest.
         IF (NP.NE.9) THEN

!        -----------------------
!        Mercury through Neptune
!        -----------------------

!        Time: Julian millennia since J2000.
            T=(DATE-51544.5D0)/365250D0

!        OK status unless remote epoch.
            IF (ABS(T).LE.1D0) THEN
               JSTAT=0
            ELSE
               JSTAT=1
            END IF

!        Compute the mean elements.
            DA=A(1,NP)+(A(2,NP)+A(3,NP)*T)*T
            DL=(3600D0*DLM(1,NP)+(DLM(2,NP)+DLM(3,NP)*T)*T)*AS2R
            DE=E(1,NP)+(E(2,NP)+E(3,NP)*T)*T
            DPE=MOD((3600D0*PI(1,NP)+(PI(2,NP)+PI(3,NP)*T)*T)*AS2R,D2PI)
            DI=(3600D0*DINC(1,NP)+(DINC(2,NP)+DINC(3,NP)*T)*T)*AS2R
            DO=MOD((3600D0*OMEGA(1,NP) &
                             +(OMEGA(2,NP)+OMEGA(3,NP)*T)*T)*AS2R,D2PI)

!        Apply the trigonometric terms.
            DMU=0.35953620D0*T
            DO J=1,8
               ARGA=DKP(J,NP)*DMU
               ARGL=DKQ(J,NP)*DMU
               DA=DA+(CA(J,NP)*COS(ARGA)+SA(J,NP)*SIN(ARGA))*1D-7
               DL=DL+(CLO(J,NP)*COS(ARGL)+SLO(J,NP)*SIN(ARGL))*1D-7
            END DO
            ARGA=DKP(9,NP)*DMU
            DA=DA+T*(CA(9,NP)*COS(ARGA)+SA(9,NP)*SIN(ARGA))*1D-7
            DO J=9,10
               ARGL=DKQ(J,NP)*DMU
               DL=DL+T*(CLO(J,NP)*COS(ARGL)+SLO(J,NP)*SIN(ARGL))*1D-7
            END DO
            DL=MOD(DL,D2PI)

!        Daily motion.
            DM=GCON*SQRT((1D0+1D0/AMAS(NP))/(DA*DA*DA))

!        Make the prediction.
            CALL sla_PLANEL(DATE,1,DATE,DI,DO,DPE,DA,DE,DL,DM,PV,J)
            IF (J.LT.0) JSTAT=-2

         ELSE

!        -----
!        Pluto
!        -----

!        Time: Julian centuries since J2000.
            T=(DATE-51544.5D0)/36525D0

!        OK status unless remote epoch.
            IF (T.GE.-1.15D0.AND.T.LE.1D0) THEN
               JSTAT=0
            ELSE
               JSTAT=1
            END IF

!        Fundamental arguments (radians).
            DJ=(DJ0+DJD*T)*D2R
            DS=(DS0+DSD*T)*D2R
            DP=(DP0+DPD*T)*D2R

!        Initialize coefficients and derivatives.
            DO I=1,3
               WLBR(I)=0D0
               WLBRD(I)=0D0
            END DO

!        Term by term through Meeus Table 36.A.
            DO J=1,43

!           Argument and derivative (radians, radians per century).
               WJ=DBLE(IJSP(1,J))
               WS=DBLE(IJSP(2,J))
               WP=DBLE(IJSP(3,J))
               AL=WJ*DJ+WS*DS+WP*DP
               ALD=(WJ*DJD+WS*DSD+WP*DPD)*D2R

!           Functions of argument.
               SAL=SIN(AL)
               CAL=COS(AL)

!           Periodic terms in longitude, latitude, radius vector.
               DO I=1,3

!              A and B coefficients (deg, AU).
                  AC=AB(1,I,J)
                  BC=AB(2,I,J)

!              Periodic terms (deg, AU, deg/Jc, AU/Jc).
                  WLBR(I)=WLBR(I)+AC*SAL+BC*CAL
                  WLBRD(I)=WLBRD(I)+(AC*CAL-BC*SAL)*ALD
               END DO
            END DO

!        Heliocentric longitude and derivative (radians, radians/sec).
            DL=(DL0+DLD0*T+WLBR(1))*D2R
            DLD=(DLD0+WLBRD(1))*D2R/SPC

!        Heliocentric latitude and derivative (radians, radians/sec).
            DB=(DB0+WLBR(2))*D2R
            DBD=WLBRD(2)*D2R/SPC

!        Heliocentric radius vector and derivative (AU, AU/sec).
            DR=DR0+WLBR(3)
            DRD=WLBRD(3)/SPC

!        Functions of latitude, longitude, radius vector.
            SL=SIN(DL)
            CL=COS(DL)
            SB=SIN(DB)
            CB=COS(DB)
            SLCB=SL*CB
            CLCB=CL*CB

!        Heliocentric vector and derivative, J2000 ecliptic and equinox.
            X=DR*CLCB
            Y=DR*SLCB
            Z=DR*SB
            XD=DRD*CLCB-DR*(CL*SB*DBD+SLCB*DLD)
            YD=DRD*SLCB+DR*(-SL*SB*DBD+CLCB*DLD)
            ZD=DRD*SB+DR*CB*DBD

!        Transform to J2000 equator and equinox.
            PV(1)=X
            PV(2)=Y*CE-Z*SE
            PV(3)=Y*SE+Z*CE
            PV(4)=XD
            PV(5)=YD*CE-ZD*SE
            PV(6)=YD*SE+ZD*CE
         END IF
      END IF

      END
      SUBROUTINE sla_PLANTE (DATE, ELONG, PHI, JFORM, EPOCH, &
                            ORBINC, ANODE, PERIH, AORQ, E, &
                            AORL, DM, RA, DEC, R, JSTAT)
!+
!     - - - - - - -
!      P L A N T E
!     - - - - - - -
!
!  Topocentric apparent RA,Dec of a Solar-System object whose
!  heliocentric orbital elements are known.
!
!  Given:
!     DATE     d     MJD of observation (JD - 2400000.5, Notes 1,5)
!     ELONG    d     observer's east longitude (radians, Note 2)
!     PHI      d     observer's geodetic latitude (radians, Note 2)
!     JFORM    i     choice of element set (1-3; Notes 3-6)
!     EPOCH    d     epoch of elements (TT MJD, Note 5)
!     ORBINC   d     inclination (radians)
!     ANODE    d     longitude of the ascending node (radians)
!     PERIH    d     longitude or argument of perihelion (radians)
!     AORQ     d     mean distance or perihelion distance (AU)
!     E        d     eccentricity
!     AORL     d     mean anomaly or longitude (radians, JFORM=1,2 only)
!     DM       d     daily motion (radians, JFORM=1 only )
!
!  Returned:
!     RA,DEC   d     RA, Dec (topocentric apparent, radians)
!     R        d     distance from observer (AU)
!     JSTAT    i     status:  0 = OK
!                            -1 = illegal JFORM
!                            -2 = illegal E
!                            -3 = illegal AORQ
!                            -4 = illegal DM
!                            -5 = numerical error
!
!  Called: sla_EL2UE, sla_PLANTU
!
!  Notes:
!
!  1  DATE is the instant for which the prediction is required.  It is
!     in the TT timescale (formerly Ephemeris Time, ET) and is a
!     Modified Julian Date (JD-2400000.5).
!
!  2  The longitude and latitude allow correction for geocentric
!     parallax.  This is usually a small effect, but can become
!     important for near-Earth asteroids.  Geocentric positions can be
!     generated by appropriate use of routines sla_EVP and sla_PLANEL.
!
!  3  The elements are with respect to the J2000 ecliptic and equinox.
!
!  4  A choice of three different element-set options is available:
!
!     Option JFORM = 1, suitable for the major planets:
!
!       EPOCH  = epoch of elements (TT MJD)
!       ORBINC = inclination i (radians)
!       ANODE  = longitude of the ascending node, big omega (radians)
!       PERIH  = longitude of perihelion, curly pi (radians)
!       AORQ   = mean distance, a (AU)
!       E      = eccentricity, e (range 0 to <1)
!       AORL   = mean longitude L (radians)
!       DM     = daily motion (radians)
!
!     Option JFORM = 2, suitable for minor planets:
!
!       EPOCH  = epoch of elements (TT MJD)
!       ORBINC = inclination i (radians)
!       ANODE  = longitude of the ascending node, big omega (radians)
!       PERIH  = argument of perihelion, little omega (radians)
!       AORQ   = mean distance, a (AU)
!       E      = eccentricity, e (range 0 to <1)
!       AORL   = mean anomaly M (radians)
!
!     Option JFORM = 3, suitable for comets:
!
!       EPOCH  = epoch of elements and perihelion (TT MJD)
!       ORBINC = inclination i (radians)
!       ANODE  = longitude of the ascending node, big omega (radians)
!       PERIH  = argument of perihelion, little omega (radians)
!       AORQ   = perihelion distance, q (AU)
!       E      = eccentricity, e (range 0 to 10)
!
!     Unused arguments (DM for JFORM=2, AORL and DM for JFORM=3) are not
!     accessed.
!
!  5  Each of the three element sets defines an unperturbed heliocentric
!     orbit.  For a given epoch of observation, the position of the body
!     in its orbit can be predicted from these elements, which are
!     called "osculating elements", using standard two-body analytical
!     solutions.  However, due to planetary perturbations, a given set
!     of osculating elements remains usable for only as long as the
!     unperturbed orbit that it describes is an adequate approximation
!     to reality.  Attached to such a set of elements is a date called
!     the "osculating epoch", at which the elements are, momentarily,
!     a perfect representation of the instantaneous position and
!     velocity of the body.
!
!     Therefore, for any given problem there are up to three different
!     epochs in play, and it is vital to distinguish clearly between
!     them:
!
!     . The epoch of observation:  the moment in time for which the
!       position of the body is to be predicted.
!
!     . The epoch defining the position of the body:  the moment in time
!       at which, in the absence of purturbations, the specified
!       position (mean longitude, mean anomaly, or perihelion) is
!       reached.
!
!     . The osculating epoch:  the moment in time at which the given
!       elements are correct.
!
!     For the major-planet and minor-planet cases it is usual to make
!     the epoch that defines the position of the body the same as the
!     epoch of osculation.  Thus, only two different epochs are
!     involved:  the epoch of the elements and the epoch of observation.
!
!     For comets, the epoch of perihelion fixes the position in the
!     orbit and in general a different epoch of osculation will be
!     chosen.  Thus, all three types of epoch are involved.
!
!     For the present routine:
!
!     . The epoch of observation is the argument DATE.
!
!     . The epoch defining the position of the body is the argument
!       EPOCH.
!
!     . The osculating epoch is not used and is assumed to be close
!       enough to the epoch of observation to deliver adequate accuracy.
!       If not, a preliminary call to sla_PERTEL may be used to update
!       the element-set (and its associated osculating epoch) by
!       applying planetary perturbations.
!
!  6  Two important sources for orbital elements are Horizons, operated
!     by the Jet Propulsion Laboratory, Pasadena, and the Minor Planet
!     Center, operated by the Center for Astrophysics, Harvard.
!
!     The JPL Horizons elements (heliocentric, J2000 ecliptic and
!     equinox) correspond to SLALIB arguments as follows.
!
!       Major planets:
!
!         JFORM  = 1
!         EPOCH  = JDCT-2400000.5D0
!         ORBINC = IN (in radians)
!         ANODE  = OM (in radians)
!         PERIH  = OM+W (in radians)
!         AORQ   = A
!         E      = EC
!         AORL   = MA+OM+W (in radians)
!         DM     = N (in radians)
!
!         Epoch of osculation = JDCT-2400000.5D0
!
!       Minor planets:
!
!         JFORM  = 2
!         EPOCH  = JDCT-2400000.5D0
!         ORBINC = IN (in radians)
!         ANODE  = OM (in radians)
!         PERIH  = W (in radians)
!         AORQ   = A
!         E      = EC
!         AORL   = MA (in radians)
!
!         Epoch of osculation = JDCT-2400000.5D0
!
!       Comets:
!
!         JFORM  = 3
!         EPOCH  = Tp-2400000.5D0
!         ORBINC = IN (in radians)
!         ANODE  = OM (in radians)
!         PERIH  = W (in radians)
!         AORQ   = QR
!         E      = EC
!
!         Epoch of osculation = JDCT-2400000.5D0
!
!     The MPC elements correspond to SLALIB arguments as follows.
!
!       Minor planets:
!
!         JFORM  = 2
!         EPOCH  = Epoch-2400000.5D0
!         ORBINC = Incl. (in radians)
!         ANODE  = Node (in radians)
!         PERIH  = Perih. (in radians)
!         AORQ   = a
!         E      = e
!         AORL   = M (in radians)
!
!         Epoch of osculation = Epoch-2400000.5D0
!
!       Comets:
!
!         JFORM  = 3
!         EPOCH  = T-2400000.5D0
!         ORBINC = Incl. (in radians)
!         ANODE  = Node. (in radians)
!         PERIH  = Perih. (in radians)
!         AORQ   = q
!         E      = e
!
!         Epoch of osculation = Epoch-2400000.5D0
!
!  P.T.Wallace   Starlink   1 January 2003
!
!  Copyright (C) 2003 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,ELONG,PHI
      INTEGER JFORM
      DOUBLE PRECISION EPOCH,ORBINC,ANODE,PERIH,AORQ,E, &
                      AORL,DM,RA,DEC,R
      INTEGER JSTAT

      DOUBLE PRECISION U(13)


!  Transform conventional elements to universal elements.
      CALL sla_EL2UE(DATE, &
                    JFORM,EPOCH,ORBINC,ANODE,PERIH,AORQ,E,AORL,DM, &
                    U,JSTAT)

!  If successful, make the prediction.
      IF (JSTAT.EQ.0) CALL sla_PLANTU(DATE,ELONG,PHI,U,RA,DEC,R,JSTAT)

      END
      SUBROUTINE sla_PLANTU (DATE, ELONG, PHI, U, RA, DEC, R, JSTAT)
!+
!     - - - - - - -
!      P L A N T U
!     - - - - - - -
!
!  Topocentric apparent RA,Dec of a Solar-System object whose
!  heliocentric universal elements are known.
!
!  Given:
!     DATE      d     TT MJD of observation (JD - 2400000.5)
!     ELONG     d     observer's east longitude (radians)
!     PHI       d     observer's geodetic latitude (radians)
!     U       d(13)   universal elements
!
!               (1)   combined mass (M+m)
!               (2)   total energy of the orbit (alpha)
!               (3)   reference (osculating) epoch (t0)
!             (4-6)   position at reference epoch (r0)
!             (7-9)   velocity at reference epoch (v0)
!              (10)   heliocentric distance at reference epoch
!              (11)   r0.v0
!              (12)   date (t)
!              (13)   universal eccentric anomaly (psi) of date, approx
!
!  Returned:
!     RA,DEC    d     RA, Dec (topocentric apparent, radians)
!     R         d     distance from observer (AU)
!     JSTAT     i     status:  0 = OK
!                             -1 = radius vector zero
!                             -2 = failed to converge
!
!  Called: sla_GMST, sla_DT, sla_EPJ, sla_EVP, sla_UE2PV, sla_PRENUT,
!          sla_DMXV, sla_PVOBS, sla_DCC2S, sla_DRANRM
!
!  Notes:
!
!  1  DATE is the instant for which the prediction is required.  It is
!     in the TT timescale (formerly Ephemeris Time, ET) and is a
!     Modified Julian Date (JD-2400000.5).
!
!  2  The longitude and latitude allow correction for geocentric
!     parallax.  This is usually a small effect, but can become
!     important for near-Earth asteroids.  Geocentric positions can be
!     generated by appropriate use of routines sla_EVP and sla_UE2PV.
!
!  3  The "universal" elements are those which define the orbit for the
!     purposes of the method of universal variables (see reference 2).
!     They consist of the combined mass of the two bodies, an epoch,
!     and the position and velocity vectors (arbitrary reference frame)
!     at that epoch.  The parameter set used here includes also various
!     quantities that can, in fact, be derived from the other
!     information.  This approach is taken to avoiding unnecessary
!     computation and loss of accuracy.  The supplementary quantities
!     are (i) alpha, which is proportional to the total energy of the
!     orbit, (ii) the heliocentric distance at epoch, (iii) the
!     outwards component of the velocity at the given epoch, (iv) an
!     estimate of psi, the "universal eccentric anomaly" at a given
!     date and (v) that date.
!
!  4  The universal elements are with respect to the J2000 equator and
!     equinox.
!
!     1  Sterne, Theodore E., "An Introduction to Celestial Mechanics",
!        Interscience Publishers Inc., 1960.  Section 6.7, p199.
!
!     2  Everhart, E. & Pitkin, E.T., Am.J.Phys. 51, 712, 1983.
!
!  P.T.Wallace   Starlink   9 December 2002
!
!  Copyright (C) 2002 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,ELONG,PHI,U(13),RA,DEC,R
      INTEGER JSTAT

!  Light time for unit distance (sec)
      DOUBLE PRECISION TAU
      PARAMETER (TAU=499.004782D0)

      INTEGER I
      DOUBLE PRECISION DVB(3),DPB(3),VSG(6),VSP(6),V(6),RMAT(3,3), &
                      VGP(6),STL,VGO(6),DX,DY,DZ,D,TL
      DOUBLE PRECISION sla_GMST,sla_DT,sla_EPJ,sla_DRANRM



!  Sun to geocentre (J2000).
      CALL sla_EVP(DATE,2000D0,DVB,DPB,VSG(4),VSG)

!  Sun to planet (J2000).
      CALL sla_UE2PV(DATE,U,VSP,JSTAT)

!  Geocentre to planet (J2000).
      DO I=1,6
         V(I)=VSP(I)-VSG(I)
      END DO

!  Precession and nutation to date.
      CALL sla_PRENUT(2000D0,DATE,RMAT)
      CALL sla_DMXV(RMAT,V,VGP)
      CALL sla_DMXV(RMAT,V(4),VGP(4))

!  Geocentre to observer (date).
      STL=sla_GMST(DATE-sla_DT(sla_EPJ(DATE))/86400D0)+ELONG
      CALL sla_PVOBS(PHI,0D0,STL,VGO)

!  Observer to planet (date).
      DO I=1,6
         V(I)=VGP(I)-VGO(I)
      END DO

!  Geometric distance (AU).
      DX=V(1)
      DY=V(2)
      DZ=V(3)
      D=SQRT(DX*DX+DY*DY+DZ*DZ)

!  Light time (sec).
      TL=TAU*D

!  Correct position for planetary aberration
      DO I=1,3
         V(I)=V(I)-TL*V(I+3)
      END DO

!  To RA,Dec.
      CALL sla_DCC2S(V,RA,DEC)
      RA=sla_DRANRM(RA)
      R=D

      END
      SUBROUTINE sla_PM (R0, D0, PR, PD, PX, RV, EP0, EP1, R1, D1)
!+
!     - - -
!      P M
!     - - -
!
!  Apply corrections for proper motion to a star RA,Dec
!  (double precision)
!
!  References:
!     1984 Astronomical Almanac, pp B39-B41.
!     (also Lederle & Schwan, Astron. Astrophys. 134,
!      1-6, 1984)
!
!  Given:
!     R0,D0    dp     RA,Dec at epoch EP0 (rad)
!     PR,PD    dp     proper motions:  RA,Dec changes per year of epoch
!     PX       dp     parallax (arcsec)
!     RV       dp     radial velocity (km/sec, +ve if receding)
!     EP0      dp     start epoch in years (e.g. Julian epoch)
!     EP1      dp     end epoch in years (same system as EP0)
!
!  Returned:
!     R1,D1    dp     RA,Dec at epoch EP1 (rad)
!
!  Called:
!     sla_DCS2C       spherical to Cartesian
!     sla_DCC2S       Cartesian to spherical
!     sla_DRANRM      normalize angle 0-2Pi
!
!  Notes:
!
!  1  The proper motions in RA are dRA/dt rather than cos(Dec)*dRA/dt,
!     and are in the same coordinate system as R0,D0.
!
!  2  If the available proper motions are pre-FK5 they will be per
!     tropical year rather than per Julian year, and so the epochs
!     must both be Besselian rather than Julian.  In such cases, a
!     scaling factor of 365.2422D0/365.25D0 should be applied to the
!     radial velocity before use.
!
!  P.T.Wallace   Starlink   19 January 2000
!
!  Copyright (C) 2000 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION R0,D0,PR,PD,PX,RV,EP0,EP1,R1,D1

!  Km/s to AU/year multiplied by arcseconds to radians
      DOUBLE PRECISION VFR
      PARAMETER (VFR=(365.25D0*86400D0/149597870D0)*4.8481368111D-6)

      INTEGER I
      DOUBLE PRECISION sla_DRANRM
      DOUBLE PRECISION W,EM(3),T,P(3)



!  Spherical to Cartesian
      CALL sla_DCS2C(R0,D0,P)

!  Space motion (radians per year)
      W=VFR*RV*PX
      EM(1)=-PR*P(2)-PD*COS(R0)*SIN(D0)+W*P(1)
      EM(2)= PR*P(1)-PD*SIN(R0)*SIN(D0)+W*P(2)
      EM(3)=         PD*COS(D0)        +W*P(3)

!  Apply the motion
      T=EP1-EP0
      DO I=1,3
         P(I)=P(I)+T*EM(I)
      END DO

!  Cartesian to spherical
      CALL sla_DCC2S(P,R1,D1)
      R1=sla_DRANRM(R1)

      END
      SUBROUTINE sla_POLMO ( ELONGM, PHIM, XP, YP, ELONG, PHI, DAZ )
!+
!     - - - - - -
!      P O L M O
!     - - - - - -
!
!  Polar motion:  correct site longitude and latitude for polar
!  motion and calculate azimuth difference between celestial and
!  terrestrial poles.
!
!  Given:
!     ELONGM   d      mean longitude of the observer (radians, east +ve)
!     PHIM     d      mean geodetic latitude of the observer (radians)
!     XP       d      polar motion x-coordinate (radians)
!     YP       d      polar motion y-coordinate (radians)
!
!  Returned:
!     ELONG    d      true longitude of the observer (radians, east +ve)
!     PHI      d      true geodetic latitude of the observer (radians)
!     DAZ      d      azimuth correction (terrestrial-celestial, radians)
!
!  Notes:
!
!   1)  "Mean" longitude and latitude are the (fixed) values for the
!       site's location with respect to the IERS terrestrial reference
!       frame;  the latitude is geodetic.  TAKE CARE WITH THE LONGITUDE
!       SIGN CONVENTION.  The longitudes used by the present routine
!       are east-positive, in accordance with geographical convention
!       (and right-handed).  In particular, note that the longitudes
!       returned by the sla_OBS routine are west-positive, following
!       astronomical usage, and must be reversed in sign before use in
!       the present routine.
!
!   2)  XP and YP are the (changing) coordinates of the Celestial
!       Ephemeris Pole with respect to the IERS Reference Pole.
!       XP is positive along the meridian at longitude 0 degrees,
!       and YP is positive along the meridian at longitude
!       270 degrees (i.e. 90 degrees west).  Values for XP,YP can
!       be obtained from IERS circulars and equivalent publications;
!       the maximum amplitude observed so far is about 0.3 arcseconds.
!
!   3)  "True" longitude and latitude are the (moving) values for
!       the site's location with respect to the celestial ephemeris
!       pole and the meridian which corresponds to the Greenwich
!       apparent sidereal time.  The true longitude and latitude
!       link the terrestrial coordinates with the standard celestial
!       models (for precession, nutation, sidereal time etc).
!
!   4)  The azimuths produced by sla_AOP and sla_AOPQK are with
!       respect to due north as defined by the Celestial Ephemeris
!       Pole, and can therefore be called "celestial azimuths".
!       However, a telescope fixed to the Earth measures azimuth
!       essentially with respect to due north as defined by the
!       IERS Reference Pole, and can therefore be called "terrestrial
!       azimuth".  Uncorrected, this would manifest itself as a
!       changing "azimuth zero-point error".  The value DAZ is the
!       correction to be added to a celestial azimuth to produce
!       a terrestrial azimuth.
!
!   5)  The present routine is rigorous.  For most practical
!       purposes, the following simplified formulae provide an
!       adequate approximation:
!
!       ELONG = ELONGM+XP*COS(ELONGM)-YP*SIN(ELONGM)
!       PHI   = PHIM+(XP*SIN(ELONGM)+YP*COS(ELONGM))*TAN(PHIM)
!       DAZ   = -SQRT(XP*XP+YP*YP)*COS(ELONGM-ATAN2(XP,YP))/COS(PHIM)
!
!       An alternative formulation for DAZ is:
!
!       X = COS(ELONGM)*COS(PHIM)
!       Y = SIN(ELONGM)*COS(PHIM)
!       DAZ = ATAN2(-X*YP-Y*XP,X*X+Y*Y)
!
!   Reference:  Seidelmann, P.K. (ed), 1992.  "Explanatory Supplement
!               to the Astronomical Almanac", ISBN 0-935702-68-7,
!               sections 3.27, 4.25, 4.52.
!
!  P.T.Wallace   Starlink   30 November 2000
!
!  Copyright (C) 2000 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION ELONGM,PHIM,XP,YP,ELONG,PHI,DAZ

      DOUBLE PRECISION SEL,CEL,SPH,CPH,XM,YM,ZM,XNM,YNM,ZNM, &
                      SXP,CXP,SYP,CYP,ZW,XT,YT,ZT,XNT,YNT



!  Site mean longitude and mean geodetic latitude as a Cartesian vector
      SEL=SIN(ELONGM)
      CEL=COS(ELONGM)
      SPH=SIN(PHIM)
      CPH=COS(PHIM)

      XM=CEL*CPH
      YM=SEL*CPH
      ZM=SPH

!  Rotate site vector by polar motion, Y-component then X-component
      SXP=SIN(XP)
      CXP=COS(XP)
      SYP=SIN(YP)
      CYP=COS(YP)

      ZW=(-YM*SYP+ZM*CYP)

      XT=XM*CXP-ZW*SXP
      YT=YM*CYP+ZM*SYP
      ZT=XM*SXP+ZW*CXP

!  Rotate also the geocentric direction of the terrestrial pole (0,0,1)
      XNM=-SXP*CYP
      YNM=SYP
      ZNM=CXP*CYP

      CPH=SQRT(XT*XT+YT*YT)
      IF (CPH.EQ.0D0) XT=1D0
      SEL=YT/CPH
      CEL=XT/CPH

!  Return true longitude and true geodetic latitude of site
      IF (XT.NE.0D0.OR.YT.NE.0D0) THEN
         ELONG=ATAN2(YT,XT)
      ELSE
         ELONG=0D0
      END IF
      PHI=ATAN2(ZT,CPH)

!  Return current azimuth of terrestrial pole seen from site position
      XNT=(XNM*CEL+YNM*SEL)*ZT-ZNM*CPH
      YNT=-XNM*SEL+YNM*CEL
      IF (XNT.NE.0D0.OR.YNT.NE.0D0) THEN
         DAZ=ATAN2(-YNT,-XNT)
      ELSE
         DAZ=0D0
      END IF

      END
      SUBROUTINE sla_PREBN (BEP0, BEP1, RMATP)
!+
!     - - - - - -
!      P R E B N
!     - - - - - -
!
!  Generate the matrix of precession between two epochs,
!  using the old, pre-IAU1976, Bessel-Newcomb model, using
!  Kinoshita's formulation (double precision)
!
!  Given:
!     BEP0    dp         beginning Besselian epoch
!     BEP1    dp         ending Besselian epoch
!
!  Returned:
!     RMATP  dp(3,3)    precession matrix
!
!  The matrix is in the sense   V(BEP1)  =  RMATP * V(BEP0)
!
!  Reference:
!     Kinoshita, H. (1975) 'Formulas for precession', SAO Special
!     Report No. 364, Smithsonian Institution Astrophysical
!     Observatory, Cambridge, Massachusetts.
!
!  Called:  sla_DEULER
!
!  P.T.Wallace   Starlink   23 August 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION BEP0,BEP1,RMATP(3,3)

!  Arc seconds to radians
      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

      DOUBLE PRECISION BIGT,T,TAS2R,W,ZETA,Z,THETA



!  Interval between basic epoch B1850.0 and beginning epoch in TC
      BIGT = (BEP0-1850D0)/100D0

!  Interval over which precession required, in tropical centuries
      T = (BEP1-BEP0)/100D0

!  Euler angles
      TAS2R = T*AS2R
      W = 2303.5548D0+(1.39720D0+0.000059D0*BIGT)*BIGT

      ZETA = (W+(0.30242D0-0.000269D0*BIGT+0.017996D0*T)*T)*TAS2R
      Z = (W+(1.09478D0+0.000387D0*BIGT+0.018324D0*T)*T)*TAS2R
      THETA = (2005.1125D0+(-0.85294D0-0.000365D0*BIGT)*BIGT+ &
             (-0.42647D0-0.000365D0*BIGT-0.041802D0*T)*T)*TAS2R

!  Rotation matrix
      CALL sla_DEULER('ZYZ',-ZETA,THETA,-Z,RMATP)

      END
      SUBROUTINE sla_PREC (EP0, EP1, RMATP)
!+
!     - - - - -
!      P R E C
!     - - - - -
!
!  Form the matrix of precession between two epochs (IAU 1976, FK5)
!  (double precision)
!
!  Given:
!     EP0    dp         beginning epoch
!     EP1    dp         ending epoch
!
!  Returned:
!     RMATP  dp(3,3)    precession matrix
!
!  Notes:
!
!     1)  The epochs are TDB (loosely ET) Julian epochs.
!
!     2)  The matrix is in the sense   V(EP1)  =  RMATP * V(EP0)
!
!     3)  Though the matrix method itself is rigorous, the precession
!         angles are expressed through canonical polynomials which are
!         valid only for a limited time span.  There are also known
!         errors in the IAU precession rate.  The absolute accuracy
!         of the present formulation is better than 0.1 arcsec from
!         1960AD to 2040AD, better than 1 arcsec from 1640AD to 2360AD,
!         and remains below 3 arcsec for the whole of the period
!         500BC to 3000AD.  The errors exceed 10 arcsec outside the
!         range 1200BC to 3900AD, exceed 100 arcsec outside 4200BC to
!         5600AD and exceed 1000 arcsec outside 6800BC to 8200AD.
!         The SLALIB routine sla_PRECL implements a more elaborate
!         model which is suitable for problems spanning several
!         thousand years.
!
!  References:
!     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
!      equations (6) & (7), p283.
!     Kaplan,G.H., 1981. USNO circular no. 163, pA2.
!
!  Called:  sla_DEULER
!
!  P.T.Wallace   Starlink   23 August 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION EP0,EP1,RMATP(3,3)

!  Arc seconds to radians
      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

      DOUBLE PRECISION T0,T,TAS2R,W,ZETA,Z,THETA



!  Interval between basic epoch J2000.0 and beginning epoch (JC)
      T0 = (EP0-2000D0)/100D0

!  Interval over which precession required (JC)
      T = (EP1-EP0)/100D0

!  Euler angles
      TAS2R = T*AS2R
      W = 2306.2181D0+(1.39656D0-0.000139D0*T0)*T0

      ZETA = (W+((0.30188D0-0.000344D0*T0)+0.017998D0*T)*T)*TAS2R
      Z = (W+((1.09468D0+0.000066D0*T0)+0.018203D0*T)*T)*TAS2R
      THETA = ((2004.3109D0+(-0.85330D0-0.000217D0*T0)*T0) &
             +((-0.42665D0-0.000217D0*T0)-0.041833D0*T)*T)*TAS2R

!  Rotation matrix
      CALL sla_DEULER('ZYZ',-ZETA,THETA,-Z,RMATP)

      END
      SUBROUTINE sla_PRECES (SYSTEM, EP0, EP1, RA, DC)
!+
!     - - - - - - -
!      P R E C E S
!     - - - - - - -
!
!  Precession - either FK4 (Bessel-Newcomb, pre IAU 1976) or
!  FK5 (Fricke, post IAU 1976) as required.
!
!  Given:
!     SYSTEM     char   precession to be applied: 'FK4' or 'FK5'
!     EP0,EP1    dp     starting and ending epoch
!     RA,DC      dp     RA,Dec, mean equator & equinox of epoch EP0
!
!  Returned:
!     RA,DC      dp     RA,Dec, mean equator & equinox of epoch EP1
!
!  Called:    sla_DRANRM, sla_PREBN, sla_PREC, sla_DCS2C,
!             sla_DMXV, sla_DCC2S
!
!  Notes:
!
!     1)  Lowercase characters in SYSTEM are acceptable.
!
!     2)  The epochs are Besselian if SYSTEM='FK4' and Julian if 'FK5'.
!         For example, to precess coordinates in the old system from
!         equinox 1900.0 to 1950.0 the call would be:
!             CALL sla_PRECES ('FK4', 1900D0, 1950D0, RA, DC)
!
!     3)  This routine will NOT correctly convert between the old and
!         the new systems - for example conversion from B1950 to J2000.
!         For these purposes see sla_FK425, sla_FK524, sla_FK45Z and
!         sla_FK54Z.
!
!     4)  If an invalid SYSTEM is supplied, values of -99D0,-99D0 will
!         be returned for both RA and DC.
!
!  P.T.Wallace   Starlink   20 April 1990
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      CHARACTER SYSTEM*(*)
      DOUBLE PRECISION EP0,EP1,RA,DC

      DOUBLE PRECISION PM(3,3),V1(3),V2(3)
      CHARACTER SYSUC*3

      DOUBLE PRECISION sla_DRANRM




!  Convert to uppercase and validate SYSTEM
      SYSUC=SYSTEM
      IF (SYSUC(1:1).EQ.'f') SYSUC(1:1)='F'
      IF (SYSUC(2:2).EQ.'k') SYSUC(2:2)='K'
      IF (SYSUC.NE.'FK4'.AND.SYSUC.NE.'FK5') THEN
         RA=-99D0
         DC=-99D0
      ELSE

!     Generate appropriate precession matrix
         IF (SYSUC.EQ.'FK4') THEN
            CALL sla_PREBN(EP0,EP1,PM)
         ELSE
            CALL sla_PREC(EP0,EP1,PM)
         END IF

!     Convert RA,Dec to x,y,z
         CALL sla_DCS2C(RA,DC,V1)

!     Precess
         CALL sla_DMXV(PM,V1,V2)

!     Back to RA,Dec
         CALL sla_DCC2S(V2,RA,DC)
         RA=sla_DRANRM(RA)

      END IF

      END
      SUBROUTINE sla_PRECL (EP0, EP1, RMATP)
!+
!     - - - - - -
!      P R E C L
!     - - - - - -
!
!  Form the matrix of precession between two epochs, using the
!  model of Simon et al (1994), which is suitable for long
!  periods of time.
!
!  (double precision)
!
!  Given:
!     EP0    dp         beginning epoch
!     EP1    dp         ending epoch
!
!  Returned:
!     RMATP  dp(3,3)    precession matrix
!
!  Notes:
!
!     1)  The epochs are TDB Julian epochs.
!
!     2)  The matrix is in the sense   V(EP1)  =  RMATP * V(EP0)
!
!     3)  The absolute accuracy of the model is limited by the
!         uncertainty in the general precession, about 0.3 arcsec per
!         1000 years.  The remainder of the formulation provides a
!         precision of 1 mas over the interval from 1000AD to 3000AD,
!         0.1 arcsec from 1000BC to 5000AD and 1 arcsec from
!         4000BC to 8000AD.
!
!  Reference:
!     Simon, J.L. et al., 1994. Astron.Astrophys., 282, 663-683.
!
!  Called:  sla_DEULER
!
!  P.T.Wallace   Starlink   23 August 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION EP0,EP1,RMATP(3,3)

!  Arc seconds to radians
      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

      DOUBLE PRECISION T0,T,TAS2R,W,ZETA,Z,THETA



!  Interval between basic epoch J2000.0 and beginning epoch (1000JY)
      T0 = (EP0-2000D0)/1000D0

!  Interval over which precession required (1000JY)
      T = (EP1-EP0)/1000D0

!  Euler angles
      TAS2R = T*AS2R
      W =      23060.9097D0+ &
               (139.7459D0+ &
                (-0.0038D0+ &
                (-0.5918D0+ &
                (-0.0037D0+ &
                  0.0007D0*T0)*T0)*T0)*T0)*T0

      ZETA =   (W+(30.2226D0+ &
                 (-0.2523D0+ &
                 (-0.3840D0+ &
                 (-0.0014D0+ &
                   0.0007D0*T0)*T0)*T0)*T0+ &
                 (18.0183D0+ &
                 (-0.1326D0+ &
                  (0.0006D0+ &
                   0.0005D0*T0)*T0)*T0+ &
                 (-0.0583D0+ &
                 (-0.0001D0+ &
                   0.0007D0*T0)*T0+ &
                 (-0.0285D0+ &
                 (-0.0002D0)*T)*T)*T)*T)*T)*TAS2R

      Z =     (W+(109.5270D0+ &
                  (0.2446D0+ &
                 (-1.3913D0+ &
                 (-0.0134D0+ &
                   0.0026D0*T0)*T0)*T0)*T0+ &
                 (18.2667D0+ &
                 (-1.1400D0+ &
                 (-0.0173D0+ &
                   0.0044D0*T0)*T0)*T0+ &
                 (-0.2821D0+ &
                 (-0.0093D0+ &
                   0.0032D0*T0)*T0+ &
                 (-0.0301D0+ &
                   0.0006D0*T0 &
                  -0.0001D0*T)*T)*T)*T)*T)*TAS2R

      THETA =  (20042.0207D0+ &
                (-85.3131D0+ &
                 (-0.2111D0+ &
                  (0.3642D0+ &
                  (0.0008D0+ &
                 (-0.0005D0)*T0)*T0)*T0)*T0)*T0+ &
                (-42.6566D0+ &
                 (-0.2111D0+ &
                  (0.5463D0+ &
                  (0.0017D0+ &
                 (-0.0012D0)*T0)*T0)*T0)*T0+ &
                (-41.8238D0+ &
                  (0.0359D0+ &
                  (0.0027D0+ &
                 (-0.0001D0)*T0)*T0)*T0+ &
                 (-0.0731D0+ &
                  (0.0019D0+ &
                   0.0009D0*T0)*T0+ &
                 (-0.0127D0+ &
                   0.0011D0*T0+0.0004D0*T)*T)*T)*T)*T)*TAS2R

!  Rotation matrix
      CALL sla_DEULER('ZYZ',-ZETA,THETA,-Z,RMATP)

      END
      SUBROUTINE sla_PRENUT (EPOCH, DATE, RMATPN)
!+
!     - - - - - - -
!      P R E N U T
!     - - - - - - -
!
!  Form the matrix of precession and nutation (IAU1976/1980/FK5)
!  (double precision)
!
!  Given:
!     EPOCH   dp         Julian Epoch for mean coordinates
!     DATE    dp         Modified Julian Date (JD-2400000.5)
!                        for true coordinates
!
!  Returned:
!     RMATPN  dp(3,3)    combined precession/nutation matrix
!
!  Called:  sla_PREC, sla_EPJ, sla_NUT, sla_DMXM
!
!  Notes:
!
!  1)  The epoch and date are TDB (loosely ET).
!
!  2)  The matrix is in the sense   V(true)  =  RMATPN * V(mean)
!
!  P.T.Wallace   Starlink   8 May 2000
!
!  Copyright (C) 2000 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION EPOCH,DATE,RMATPN(3,3)

      DOUBLE PRECISION RMATP(3,3),RMATN(3,3),sla_EPJ



!  Precession
      CALL sla_PREC(EPOCH,sla_EPJ(DATE),RMATP)

!  Nutation
      CALL sla_NUT(DATE,RMATN)

!  Combine the matrices:  PN = N x P
      CALL sla_DMXM(RMATN,RMATP,RMATPN)

      END
      SUBROUTINE sla_PV2EL (PV, DATE, PMASS, JFORMR, &
                           JFORM, EPOCH, ORBINC, ANODE, PERIH, &
                           AORQ, E, AORL, DM, JSTAT)
!+
!     - - - - - -
!      P V 2 E L
!     - - - - - -
!
!  Heliocentric osculating elements obtained from instantaneous position
!  and velocity.
!
!  Given:
!     PV        d(6)   heliocentric x,y,z,xdot,ydot,zdot of date,
!                      J2000 equatorial triad (AU,AU/s; Note 1)
!     DATE      d      date (TT Modified Julian Date = JD-2400000.5)
!     PMASS     d      mass of the planet (Sun=1; Note 2)
!     JFORMR    i      requested element set (1-3; Note 3)
!
!  Returned:
!     JFORM     d      element set actually returned (1-3; Note 4)
!     EPOCH     d      epoch of elements (TT MJD)
!     ORBINC    d      inclination (radians)
!     ANODE     d      longitude of the ascending node (radians)
!     PERIH     d      longitude or argument of perihelion (radians)
!     AORQ      d      mean distance or perihelion distance (AU)
!     E         d      eccentricity
!     AORL      d      mean anomaly or longitude (radians, JFORM=1,2 only)
!     DM        d      daily motion (radians, JFORM=1 only)
!     JSTAT     i      status:  0 = OK
!                              -1 = illegal PMASS
!                              -2 = illegal JFORMR
!                              -3 = position/velocity out of range
!
!  Notes
!
!  1  The PV 6-vector is with respect to the mean equator and equinox of
!     epoch J2000.  The orbital elements produced are with respect to
!     the J2000 ecliptic and mean equinox.
!
!  2  The mass, PMASS, is important only for the larger planets.  For
!     most purposes (e.g. asteroids) use 0D0.  Values less than zero
!     are illegal.
!
!  3  Three different element-format options are supported:
!
!     Option JFORM=1, suitable for the major planets:
!
!     EPOCH  = epoch of elements (TT MJD)
!     ORBINC = inclination i (radians)
!     ANODE  = longitude of the ascending node, big omega (radians)
!     PERIH  = longitude of perihelion, curly pi (radians)
!     AORQ   = mean distance, a (AU)
!     E      = eccentricity, e
!     AORL   = mean longitude L (radians)
!     DM     = daily motion (radians)
!
!     Option JFORM=2, suitable for minor planets:
!
!     EPOCH  = epoch of elements (TT MJD)
!     ORBINC = inclination i (radians)
!     ANODE  = longitude of the ascending node, big omega (radians)
!     PERIH  = argument of perihelion, little omega (radians)
!     AORQ   = mean distance, a (AU)
!     E      = eccentricity, e
!     AORL   = mean anomaly M (radians)
!
!     Option JFORM=3, suitable for comets:
!
!     EPOCH  = epoch of perihelion (TT MJD)
!     ORBINC = inclination i (radians)
!     ANODE  = longitude of the ascending node, big omega (radians)
!     PERIH  = argument of perihelion, little omega (radians)
!     AORQ   = perihelion distance, q (AU)
!     E      = eccentricity, e
!
!  4  It may not be possible to generate elements in the form
!     requested through JFORMR.  The caller is notified of the form
!     of elements actually returned by means of the JFORM argument:
!
!      JFORMR   JFORM     meaning
!
!        1        1       OK - elements are in the requested format
!        1        2       never happens
!        1        3       orbit not elliptical
!
!        2        1       never happens
!        2        2       OK - elements are in the requested format
!        2        3       orbit not elliptical
!
!        3        1       never happens
!        3        2       never happens
!        3        3       OK - elements are in the requested format
!
!  5  The arguments returned for each value of JFORM (cf Note 5: JFORM
!     may not be the same as JFORMR) are as follows:
!
!         JFORM         1              2              3
!         EPOCH         t0             t0             T
!         ORBINC        i              i              i
!         ANODE         Omega          Omega          Omega
!         PERIH         curly pi       omega          omega
!         AORQ          a              a              q
!         E             e              e              e
!         AORL          L              M              -
!         DM            n              -              -
!
!     where:
!
!         t0           is the epoch of the elements (MJD, TT)
!         T              "    epoch of perihelion (MJD, TT)
!         i              "    inclination (radians)
!         Omega          "    longitude of the ascending node (radians)
!         curly pi       "    longitude of perihelion (radians)
!         omega          "    argument of perihelion (radians)
!         a              "    mean distance (AU)
!         q              "    perihelion distance (AU)
!         e              "    eccentricity
!         L              "    longitude (radians, 0-2pi)
!         M              "    mean anomaly (radians, 0-2pi)
!         n              "    daily motion (radians)
!         -             means no value is set
!
!  6  At very small inclinations, the longitude of the ascending node
!     ANODE becomes indeterminate and under some circumstances may be
!     set arbitrarily to zero.  Similarly, if the orbit is close to
!     circular, the true anomaly becomes indeterminate and under some
!     circumstances may be set arbitrarily to zero.  In such cases,
!     the other elements are automatically adjusted to compensate,
!     and so the elements remain a valid description of the orbit.
!
!  7  The osculating epoch for the returned elements is the argument
!     DATE.
!
!  Reference:  Sterne, Theodore E., "An Introduction to Celestial
!              Mechanics", Interscience Publishers, 1960
!
!  Called:  sla_DRANRM
!
!  P.T.Wallace   Starlink   31 December 2002
!
!  Copyright (C) 2002 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION PV(6),DATE,PMASS
      INTEGER JFORMR,JFORM
      DOUBLE PRECISION EPOCH,ORBINC,ANODE,PERIH,AORQ,E,AORL,DM
      INTEGER JSTAT

!  Seconds to days
      DOUBLE PRECISION DAY
      PARAMETER (DAY=86400D0)

!  Gaussian gravitational constant (exact)
      DOUBLE PRECISION GCON
      PARAMETER (GCON=0.01720209895D0)

!  Sin and cos of J2000 mean obliquity (IAU 1976)
      DOUBLE PRECISION SE,CE
      PARAMETER (SE=0.3977771559319137D0, &
                CE=0.9174820620691818D0)

!  Minimum allowed distance (AU) and speed (AU/day)
      DOUBLE PRECISION RMIN,VMIN
      PARAMETER (RMIN=1D-3,VMIN=1D-8)

!  How close to unity the eccentricity has to be to call it a parabola
      DOUBLE PRECISION PARAB
      PARAMETER (PARAB=1D-8)

      DOUBLE PRECISION X,Y,Z,XD,YD,ZD,R,V2,V,RDV,GMU,HX,HY,HZ, &
                      HX2PY2,H2,H,OI,BIGOM,AR,ECC,S,C,AT,U,OM, &
                      GAR3,EM1,EP1,HAT,SHAT,CHAT,AE,AM,DN,PL, &
                      EL,Q,TP,THAT,THHF,F

      INTEGER JF

      DOUBLE PRECISION sla_DRANRM


!  Validate arguments PMASS and JFORMR.
      IF (PMASS.LT.0D0) THEN
         JSTAT = -1
         GO TO 999
      END IF
      IF (JFORMR.LT.1.OR.JFORMR.GT.3) THEN
         JSTAT = -2
         GO TO 999
      END IF

!  Provisionally assume the elements will be in the chosen form.
      JF = JFORMR

!  Rotate the position from equatorial to ecliptic coordinates.
      X = PV(1)
      Y = PV(2)*CE+PV(3)*SE
      Z = -PV(2)*SE+PV(3)*CE

!  Rotate the velocity similarly, scaling to AU/day.
      XD = DAY*PV(4)
      YD = DAY*(PV(5)*CE+PV(6)*SE)
      ZD = DAY*(-PV(5)*SE+PV(6)*CE)

!  Distance and speed.
      R = SQRT(X*X+Y*Y+Z*Z)
      V2 = XD*XD+YD*YD+ZD*ZD
      V = SQRT(V2)

!  Reject unreasonably small values.
      IF (R.LT.RMIN.OR.V.LT.VMIN) THEN
         JSTAT = -3
         GO TO 999
      END IF

!  R dot V.
      RDV = X*XD+Y*YD+Z*ZD

!  Mu.
      GMU = (1D0+PMASS)*GCON*GCON

!  Vector angular momentum per unit reduced mass.
      HX = Y*ZD-Z*YD
      HY = Z*XD-X*ZD
      HZ = X*YD-Y*XD

!  Areal constant.
      HX2PY2 = HX*HX+HY*HY
      H2 = HX2PY2+HZ*HZ
      H = SQRT(H2)

!  Inclination.
      OI = ATAN2(SQRT(HX2PY2),HZ)

!  Longitude of ascending node.
      IF (HX.NE.0D0.OR.HY.NE.0D0) THEN
         BIGOM = ATAN2(HX,-HY)
      ELSE
         BIGOM=0D0
      END IF

!  Reciprocal of mean distance etc.
      AR = 2D0/R-V2/GMU

!  Eccentricity.
      ECC = SQRT(MAX(1D0-AR*H2/GMU,0D0))

!  True anomaly.
      S = H*RDV
      C = H2-R*GMU
      IF (S.NE.0D0.OR.C.NE.0D0) THEN
         AT = ATAN2(S,C)
      ELSE
         AT = 0D0
      END IF

!  Argument of the latitude.
      S = SIN(BIGOM)
      C = COS(BIGOM)
      U = ATAN2((-X*S+Y*C)*COS(OI)+Z*SIN(OI),X*C+Y*S)

!  Argument of perihelion.
      OM = U-AT

!  Capture near-parabolic cases.
      IF (ABS(ECC-1D0).LT.PARAB) ECC=1D0

!  Comply with JFORMR = 1 or 2 only if orbit is elliptical.
      IF (ECC.GE.1D0) JF=3

!  Functions.
      GAR3 = GMU*AR*AR*AR
      EM1 = ECC-1D0
      EP1 = ECC+1D0
      HAT = AT/2D0
      SHAT = SIN(HAT)
      CHAT = COS(HAT)

!  Ellipse?
      IF (ECC.LT.1D0 ) THEN

!     Eccentric anomaly.
         AE = 2D0*ATAN2(SQRT(-EM1)*SHAT,SQRT(EP1)*CHAT)

!     Mean anomaly.
         AM = AE-ECC*SIN(AE)

!     Daily motion.
         DN = SQRT(GAR3)
      END IF

!  "Major planet" element set?
      IF (JF.EQ.1) THEN

!     Longitude of perihelion.
         PL = BIGOM+OM

!     Longitude at epoch.
         EL = PL+AM
      END IF

!  "Comet" element set?
      IF (JF.EQ.3) THEN

!     Perihelion distance.
         Q = H2/(GMU*EP1)

!     Ellipse, parabola, hyperbola?
         IF (ECC.LT.1D0) THEN

!        Ellipse: epoch of perihelion.
            TP = DATE-AM/DN
         ELSE

!        Parabola or hyperbola: evaluate tan ( ( true anomaly ) / 2 )
            THAT = SHAT/CHAT
            IF (ECC.EQ.1D0) THEN

!           Parabola: epoch of perihelion.
               TP = DATE-THAT*(1D0+THAT*THAT/3D0)*H*H2/(2D0*GMU*GMU)
            ELSE

!           Hyperbola: epoch of perihelion.
               THHF = SQRT(EM1/EP1)*THAT
               F = LOG(1D0+THHF)-LOG(1D0-THHF)
               TP = DATE-(ECC*SINH(F)-F)/SQRT(-GAR3)
            END IF
         END IF
      END IF

!  Return the appropriate set of elements.
      JFORM = JF
      ORBINC = OI
      ANODE = sla_DRANRM(BIGOM)
      E = ECC
      IF (JF.EQ.1) THEN
         PERIH = sla_DRANRM(PL)
         AORL = sla_DRANRM(EL)
         DM = DN
      ELSE
         PERIH = sla_DRANRM(OM)
         IF (JF.EQ.2) AORL = sla_DRANRM(AM)
      END IF
      IF (JF.NE.3) THEN
         EPOCH = DATE
         AORQ = 1D0/AR
      ELSE
         EPOCH = TP
         AORQ = Q
      END IF
      JSTAT = 0

 999  CONTINUE
      END
      SUBROUTINE sla_PV2UE (PV, DATE, PMASS, U, JSTAT)
!+
!     - - - - - -
!      P V 2 U E
!     - - - - - -
!
!  Construct a universal element set based on an instantaneous position
!  and velocity.
!
!  Given:
!     PV        d(6)   heliocentric x,y,z,xdot,ydot,zdot of date,
!                      (AU,AU/s; Note 1)
!     DATE      d      date (TT Modified Julian Date = JD-2400000.5)
!     PMASS     d      mass of the planet (Sun=1; Note 2)
!
!  Returned:
!     U         d(13)  universal orbital elements (Note 3)
!
!                 (1)  combined mass (M+m)
!                 (2)  total energy of the orbit (alpha)
!                 (3)  reference (osculating) epoch (t0)
!               (4-6)  position at reference epoch (r0)
!               (7-9)  velocity at reference epoch (v0)
!                (10)  heliocentric distance at reference epoch
!                (11)  r0.v0
!                (12)  date (t)
!                (13)  universal eccentric anomaly (psi) of date, approx
!
!     JSTAT     i      status:  0 = OK
!                              -1 = illegal PMASS
!                              -2 = too close to Sun
!                              -3 = too slow
!
!  Notes
!
!  1  The PV 6-vector can be with respect to any chosen inertial frame,
!     and the resulting universal-element set will be with respect to
!     the same frame.  A common choice will be mean equator and ecliptic
!     of epoch J2000.
!
!  2  The mass, PMASS, is important only for the larger planets.  For
!     most purposes (e.g. asteroids) use 0D0.  Values less than zero
!     are illegal.
!
!  3  The "universal" elements are those which define the orbit for the
!     purposes of the method of universal variables (see reference).
!     They consist of the combined mass of the two bodies, an epoch,
!     and the position and velocity vectors (arbitrary reference frame)
!     at that epoch.  The parameter set used here includes also various
!     quantities that can, in fact, be derived from the other
!     information.  This approach is taken to avoiding unnecessary
!     computation and loss of accuracy.  The supplementary quantities
!     are (i) alpha, which is proportional to the total energy of the
!     orbit, (ii) the heliocentric distance at epoch, (iii) the
!     outwards component of the velocity at the given epoch, (iv) an
!     estimate of psi, the "universal eccentric anomaly" at a given
!     date and (v) that date.
!
!  Reference:  Everhart, E. & Pitkin, E.T., Am.J.Phys. 51, 712, 1983.
!
!  P.T.Wallace   Starlink   18 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION PV(6),DATE,PMASS,U(13)
      INTEGER JSTAT

!  Gaussian gravitational constant (exact)
      DOUBLE PRECISION GCON
      PARAMETER (GCON=0.01720209895D0)

!  Canonical days to seconds
      DOUBLE PRECISION CD2S
      PARAMETER (CD2S=GCON/86400D0)

!  Minimum allowed distance (AU) and speed (AU per canonical day)
      DOUBLE PRECISION RMIN,VMIN
      PARAMETER (RMIN=1D-3,VMIN=1D-3)

      DOUBLE PRECISION T0,CM,X,Y,Z,XD,YD,ZD,R,V2,V,ALPHA,RDV


!  Reference epoch.
      T0 = DATE

!  Combined mass (mu=M+m).
      IF (PMASS.LT.0D0) GO TO 9010
      CM = 1D0+PMASS

!  Unpack the state vector, expressing velocity in AU per canonical day.
      X = PV(1)
      Y = PV(2)
      Z = PV(3)
      XD = PV(4)/CD2S
      YD = PV(5)/CD2S
      ZD = PV(6)/CD2S

!  Heliocentric distance, and speed.
      R = SQRT(X*X+Y*Y+Z*Z)
      V2 = XD*XD+YD*YD+ZD*ZD
      V = SQRT(V2)

!  Reject unreasonably small values.
      IF (R.LT.RMIN) GO TO 9020
      IF (V.LT.VMIN) GO TO 9030

!  Total energy of the orbit.
      ALPHA = V2-2D0*CM/R

!  Outward component of velocity.
      RDV = X*XD+Y*YD+Z*ZD

!  Construct the universal-element set.
      U(1) = CM
      U(2) = ALPHA
      U(3) = T0
      U(4) = X
      U(5) = Y
      U(6) = Z
      U(7) = XD
      U(8) = YD
      U(9) = ZD
      U(10) = R
      U(11) = RDV
      U(12) = T0
      U(13) = 0D0

!  Exit.
      JSTAT = 0
      GO TO 9999

!  Negative PMASS.
 9010 CONTINUE
      JSTAT = -1
      GO TO 9999

!  Too close.
 9020 CONTINUE
      JSTAT = -2
      GO TO 9999

!  Too slow.
 9030 CONTINUE
      JSTAT = -3

 9999 CONTINUE
      END
      SUBROUTINE sla_PVOBS (P, H, STL, PV)
!+
!     - - - - - -
!      P V O B S
!     - - - - - -
!
!  Position and velocity of an observing station (double precision)
!
!  Given:
!     P     dp     latitude (geodetic, radians)
!     H     dp     height above reference spheroid (geodetic, metres)
!     STL   dp     local apparent sidereal time (radians)
!
!  Returned:
!     PV    dp(6)  position/velocity 6-vector (AU, AU/s, true equator
!                                              and equinox of date)
!
!  Called:  sla_GEOC
!
!  IAU 1976 constants are used.
!
!  P.T.Wallace   Starlink   14 November 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION P,H,STL,PV(6)

      DOUBLE PRECISION R,Z,S,C,V

!  Mean sidereal rate (at J2000) in radians per (UT1) second
      DOUBLE PRECISION SR
      PARAMETER (SR=7.292115855306589D-5)



!  Geodetic to geocentric conversion
      CALL sla_GEOC(P,H,R,Z)

!  Functions of ST
      S=SIN(STL)
      C=COS(STL)

!  Speed
      V=SR*R

!  Position
      PV(1)=R*C
      PV(2)=R*S
      PV(3)=Z

!  Velocity
      PV(4)=-V*S
      PV(5)=V*C
      PV(6)=0D0

      END
      SUBROUTINE sla_PXY (NP,XYE,XYM,COEFFS,XYP,XRMS,YRMS,RRMS)
!+
!     - - - -
!      P X Y
!     - - - -
!
!  Given arrays of "expected" and "measured" [X,Y] coordinates, and a
!  linear model relating them (as produced by sla_FITXY), compute
!  the array of "predicted" coordinates and the RMS residuals.
!
!  Given:
!     NP       i        number of samples
!     XYE     d(2,np)   expected [X,Y] for each sample
!     XYM     d(2,np)   measured [X,Y] for each sample
!     COEFFS  d(6)      coefficients of model (see below)
!
!  Returned:
!     XYP     d(2,np)   predicted [X,Y] for each sample
!     XRMS     d        RMS in X
!     YRMS     d        RMS in Y
!     RRMS     d        total RMS (vector sum of XRMS and YRMS)
!
!  The model is supplied in the array COEFFS.  Naming the
!  elements of COEFF as follows:
!
!     COEFFS(1) = A
!     COEFFS(2) = B
!     COEFFS(3) = C
!     COEFFS(4) = D
!     COEFFS(5) = E
!     COEFFS(6) = F
!
!  the model is applied thus:
!
!     XP = A + B*XM + C*YM
!     YP = D + E*XM + F*YM
!
!  The residuals are (XP-XE) and (YP-YE).
!
!  If NP is less than or equal to zero, no coordinates are
!  transformed, and the RMS residuals are all zero.
!
!  See also sla_FITXY, sla_INVF, sla_XY2XY, sla_DCMPF
!
!  Called:  sla_XY2XY
!
!  P.T.Wallace   Starlink   22 May 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER NP
      DOUBLE PRECISION XYE(2,NP),XYM(2,NP),COEFFS(6), &
                      XYP(2,NP),XRMS,YRMS,RRMS

      INTEGER I
      DOUBLE PRECISION SDX2,SDY2,XP,YP,DX,DY,DX2,DY2,P



!  Initialize summations
      SDX2=0D0
      SDY2=0D0

!  Loop by sample
      DO I=1,NP

!     Transform "measured" [X,Y] to "predicted" [X,Y]
         CALL sla_XY2XY(XYM(1,I),XYM(2,I),COEFFS,XP,YP)
         XYP(1,I)=XP
         XYP(2,I)=YP

!     Compute residuals in X and Y, and update summations
         DX=XYE(1,I)-XP
         DY=XYE(2,I)-YP
         DX2=DX*DX
         DY2=DY*DY
         SDX2=SDX2+DX2
         SDY2=SDY2+DY2

!     Next sample
      END DO

!  Compute RMS values
      P=MAX(1D0,DBLE(NP))
      XRMS=SQRT(SDX2/P)
      YRMS=SQRT(SDY2/P)
      RRMS=SQRT(XRMS*XRMS+YRMS*YRMS)

      END
      REAL FUNCTION sla_RANDOM (SEED)
!+
!     - - - - - - -
!      R A N D O M
!     - - - - - - -
!
!  Generate pseudo-random real number in the range 0 <= X < 1.
!  (single precision)
!
!  !!! Sun 4 dependent !!!
!
!  Given:
!     SEED     real     an arbitrary real number
!
!  Notes:
!
!  1)  The result is a pseudo-random REAL number in the range
!      0 <= sla_RANDOM < 1.
!
!  2)  SEED is used first time through only.
!
!  Called:  RAND (a REAL function from the Sun Fortran Library)
!
!  P.T.Wallace   Starlink   14 October 1991
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL SEED

      REAL RAND

      REAL AS
      INTEGER ISEED
      LOGICAL FIRST
      SAVE FIRST
      DATA FIRST /.TRUE./



!  If first time, turn SEED into a large, odd integer, and start the
!  generator
      IF (FIRST) THEN
         AS=ABS(SEED)+1.0
         ISEED=NINT(AS/10.0**(NINT(ALOG10(AS))-6))
         IF (MOD(ISEED,2).EQ.0) ISEED=ISEED+1
         FIRST=.FALSE.
         AS=RAND(ISEED)
      END IF

!  Next pseudo-random number
      sla_RANDOM=RAND(0)

      END
      REAL FUNCTION sla_RANGE (ANGLE)
!+
!     - - - - - -
!      R A N G E
!     - - - - - -
!
!  Normalize angle into range +/- pi  (single precision)
!
!  Given:
!     ANGLE     dp      the angle in radians
!
!  The result is ANGLE expressed in the +/- pi (single
!  precision).
!
!  P.T.Wallace   Starlink   23 November 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL ANGLE

      REAL API,A2PI
      PARAMETER (API=3.141592653589793238462643)
      PARAMETER (A2PI=6.283185307179586476925287)


      sla_RANGE=MOD(ANGLE,A2PI)
      IF (ABS(sla_RANGE).GE.API) &
               sla_RANGE=sla_RANGE-SIGN(A2PI,ANGLE)

      END
      REAL FUNCTION sla_RANORM (ANGLE)
!+
!     - - - - - - -
!      R A N O R M
!     - - - - - - -
!
!  Normalize angle into range 0-2 pi  (single precision)
!
!  Given:
!     ANGLE     dp      the angle in radians
!
!  The result is ANGLE expressed in the range 0-2 pi (single
!  precision).
!
!  P.T.Wallace   Starlink   23 November 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL ANGLE

      REAL A2PI
      PARAMETER (A2PI=6.283185307179586476925287)


      sla_RANORM=MOD(ANGLE,A2PI)
      IF (sla_RANORM.LT.0.0) sla_RANORM=sla_RANORM+A2PI

      END
      DOUBLE PRECISION FUNCTION sla_RCC (TDB, UT1, WL, U, V)
!+
!     - - - -
!      R C C
!     - - - -
!
!  Relativistic clock correction:  the difference between proper time at
!  a point on the surface of the Earth and coordinate time in the Solar
!  System barycentric space-time frame of reference.
!
!  The proper time is terrestrial time, TT;  the coordinate time is an
!  implementation of barycentric dynamical time, TDB.
!
!  Given:
!    TDB      d     TDB (MJD: JD-2400000.5)
!    UT1      d     universal time (fraction of one day)
!    WL       d     clock longitude (radians west)
!    U        d     clock distance from Earth spin axis (km)
!    V        d     clock distance north of Earth equatorial plane (km)
!
!  Returned:
!    The clock correction, TDB-TT, in seconds:
!
!    .  TDB is coordinate time in the solar system barycentre frame
!       of reference, in units chosen to eliminate the scale difference
!       with respect to terrestrial time.
!
!    .  TT is the proper time for clocks at mean sea level on the
!       Earth.
!
!  Notes:
!
!  1  The argument TDB is, strictly, the barycentric coordinate time;
!     however, the terrestrial time TT can in practice be used without
!     any significant loss of accuracy.
!
!  2  The result returned by sla_RCC comprises a main (annual)
!     sinusoidal term of amplitude approximately 0.00166 seconds, plus
!     planetary and lunar terms up to about 20 microseconds, and diurnal
!     terms up to 2 microseconds.  The variation arises from the
!     transverse Doppler effect and the gravitational red-shift as the
!     observer varies in speed and moves through different gravitational
!     potentials.
!
!  3  The geocentric model is that of Fairhead & Bretagnon (1990), in
!     its full form.  It was supplied by Fairhead (private
!     communication) as a FORTRAN subroutine.  The original Fairhead
!     routine used explicit formulae, in such large numbers that
!     problems were experienced with certain compilers (Microsoft
!     Fortran on PC aborted with stack overflow, Convex compiled
!     successfully but extremely slowly).  The present implementation is
!     a complete recoding, with the original Fairhead coefficients held
!     in a table.  To optimise arithmetic precision, the terms are
!     accumulated in reverse order, smallest first.  A number of other
!     coding changes were made, in order to match the calling sequence
!     of previous versions of the present routine, and to comply with
!     Starlink programming standards.  The numerical results compared
!     with those from the Fairhead form are essentially unaffected by
!     the changes, the differences being at the 10^-20 sec level.
!
!  4  The topocentric part of the model is from Moyer (1981) and
!     Murray (1983).  It is an approximation to the expression
!     ( v / c ) . ( r / c ), where v is the barycentric velocity of
!     the Earth, r is the geocentric position of the observer and
!     c is the speed of light.
!
!  5  During the interval 1950-2050, the absolute accuracy of is better
!     than +/- 3 nanoseconds relative to direct numerical integrations
!     using the JPL DE200/LE200 solar system ephemeris.
!
!  6  The IAU definition of TDB was that it must differ from TT only by
!     periodic terms.  Though practical, this is an imprecise definition
!     which ignores the existence of very long-period and secular
!     effects in the dynamics of the solar system.  As a consequence,
!     different implementations of TDB will, in general, differ in zero-
!     point and will drift linearly relative to one other.
!
!  7  TDB was, in principle, superseded by new coordinate timescales
!     which the IAU introduced in 1991:  geocentric coordinate time,
!     TCG, and barycentric coordinate time, TCB.  However, sla_RCC
!     can be used to implement the periodic part of TCB-TCG.
!
!  References:
!
!  1  Fairhead, L., & Bretagnon, P., Astron.Astrophys., 229, 240-247
!     (1990).
!
!  2  Moyer, T.D., Cel.Mech., 23, 33 (1981).
!
!  3  Murray, C.A., Vectorial Astrometry, Adam Hilger (1983).
!
!  4  Seidelmann, P.K. et al, Explanatory Supplement to the
!     Astronomical Almanac, Chapter 2, University Science Books
!     (1992).
!
!  5  Simon J.L., Bretagnon P., Chapront J., Chapront-Touze M.,
!     Francou G. & Laskar J., Astron.Astrophys., 282, 663-683 (1994).
!
!  P.T.Wallace   Starlink   7 May 2000
!
!  Copyright (C) 2000 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION TDB,UT1,WL,U,V

      DOUBLE PRECISION D2PI,D2R
      PARAMETER (D2PI=6.283185307179586476925287D0, &
                D2R=0.0174532925199432957692369D0)

      DOUBLE PRECISION T,TSOL,W,ELSUN,EMSUN,D,ELJ,ELS
      DOUBLE PRECISION WTT,W0,W1,W2,W3,W4,WF,WJ

! -----------------------------------------------------------------------
!
!  Fairhead and Bretagnon canonical coefficients
!
!  787 sets of three coefficients.
!
!  Each set is amplitude (microseconds)
!              frequency (radians per Julian millennium since J2000),
!              phase (radians).
!
!  Sets   1-474 are the T**0 terms,
!   "   475-679  "   "  T**1   "
!   "   680-764  "   "  T**2   "
!   "   765-784  "   "  T**3   "
!   "   785-787  "   "  T**4   "  .
!
      DOUBLE PRECISION FAIRHD(3,787)
      INTEGER I,J
      DATA ((FAIRHD(I,J),I=1,3),J=  1, 10) / &
      1656.674564D-6,    6283.075849991D0, 6.240054195D0, &
        22.417471D-6,    5753.384884897D0, 4.296977442D0, &
        13.839792D-6,   12566.151699983D0, 6.196904410D0, &
         4.770086D-6,     529.690965095D0, 0.444401603D0, &
         4.676740D-6,    6069.776754553D0, 4.021195093D0, &
         2.256707D-6,     213.299095438D0, 5.543113262D0, &
         1.694205D-6,      -3.523118349D0, 5.025132748D0, &
         1.554905D-6,   77713.771467920D0, 5.198467090D0, &
         1.276839D-6,    7860.419392439D0, 5.988822341D0, &
         1.193379D-6,    5223.693919802D0, 3.649823730D0 /
      DATA ((FAIRHD(I,J),I=1,3),J= 11, 20) / &
         1.115322D-6,    3930.209696220D0, 1.422745069D0, &
         0.794185D-6,   11506.769769794D0, 2.322313077D0, &
         0.447061D-6,      26.298319800D0, 3.615796498D0, &
         0.435206D-6,    -398.149003408D0, 4.349338347D0, &
         0.600309D-6,    1577.343542448D0, 2.678271909D0, &
         0.496817D-6,    6208.294251424D0, 5.696701824D0, &
         0.486306D-6,    5884.926846583D0, 0.520007179D0, &
         0.432392D-6,      74.781598567D0, 2.435898309D0, &
         0.468597D-6,    6244.942814354D0, 5.866398759D0, &
         0.375510D-6,    5507.553238667D0, 4.103476804D0 /
      DATA ((FAIRHD(I,J),I=1,3),J= 21, 30) / &
         0.243085D-6,    -775.522611324D0, 3.651837925D0, &
         0.173435D-6,   18849.227549974D0, 6.153743485D0, &
         0.230685D-6,    5856.477659115D0, 4.773852582D0, &
         0.203747D-6,   12036.460734888D0, 4.333987818D0, &
         0.143935D-6,    -796.298006816D0, 5.957517795D0, &
         0.159080D-6,   10977.078804699D0, 1.890075226D0, &
         0.119979D-6,      38.133035638D0, 4.551585768D0, &
         0.118971D-6,    5486.777843175D0, 1.914547226D0, &
         0.116120D-6,    1059.381930189D0, 0.873504123D0, &
         0.137927D-6,   11790.629088659D0, 1.135934669D0 /
      DATA ((FAIRHD(I,J),I=1,3),J= 31, 40) / &
         0.098358D-6,    2544.314419883D0, 0.092793886D0, &
         0.101868D-6,   -5573.142801634D0, 5.984503847D0, &
         0.080164D-6,     206.185548437D0, 2.095377709D0, &
         0.079645D-6,    4694.002954708D0, 2.949233637D0, &
         0.062617D-6,      20.775395492D0, 2.654394814D0, &
         0.075019D-6,    2942.463423292D0, 4.980931759D0, &
         0.064397D-6,    5746.271337896D0, 1.280308748D0, &
         0.063814D-6,    5760.498431898D0, 4.167901731D0, &
         0.048042D-6,    2146.165416475D0, 1.495846011D0, &
         0.048373D-6,     155.420399434D0, 2.251573730D0 /
      DATA ((FAIRHD(I,J),I=1,3),J= 41, 50) / &
         0.058844D-6,     426.598190876D0, 4.839650148D0, &
         0.046551D-6,      -0.980321068D0, 0.921573539D0, &
         0.054139D-6,   17260.154654690D0, 3.411091093D0, &
         0.042411D-6,    6275.962302991D0, 2.869567043D0, &
         0.040184D-6,      -7.113547001D0, 3.565975565D0, &
         0.036564D-6,    5088.628839767D0, 3.324679049D0, &
         0.040759D-6,   12352.852604545D0, 3.981496998D0, &
         0.036507D-6,     801.820931124D0, 6.248866009D0, &
         0.036955D-6,    3154.687084896D0, 5.071801441D0, &
         0.042732D-6,     632.783739313D0, 5.720622217D0 /
      DATA ((FAIRHD(I,J),I=1,3),J= 51, 60) / &
         0.042560D-6,  161000.685737473D0, 1.270837679D0, &
         0.040480D-6,   15720.838784878D0, 2.546610123D0, &
         0.028244D-6,   -6286.598968340D0, 5.069663519D0, &
         0.033477D-6,    6062.663207553D0, 4.144987272D0, &
         0.034867D-6,     522.577418094D0, 5.210064075D0, &
         0.032438D-6,    6076.890301554D0, 0.749317412D0, &
         0.030215D-6,    7084.896781115D0, 3.389610345D0, &
         0.029247D-6,  -71430.695617928D0, 4.183178762D0, &
         0.033529D-6,    9437.762934887D0, 2.404714239D0, &
         0.032423D-6,    8827.390269875D0, 5.541473556D0 /
      DATA ((FAIRHD(I,J),I=1,3),J= 61, 70) / &
         0.027567D-6,    6279.552731642D0, 5.040846034D0, &
         0.029862D-6,   12139.553509107D0, 1.770181024D0, &
         0.022509D-6,   10447.387839604D0, 1.460726241D0, &
         0.020937D-6,    8429.241266467D0, 0.652303414D0, &
         0.020322D-6,     419.484643875D0, 3.735430632D0, &
         0.024816D-6,   -1194.447010225D0, 1.087136918D0, &
         0.025196D-6,    1748.016413067D0, 2.901883301D0, &
         0.021691D-6,   14143.495242431D0, 5.952658009D0, &
         0.017673D-6,    6812.766815086D0, 3.186129845D0, &
         0.022567D-6,    6133.512652857D0, 3.307984806D0 /
      DATA ((FAIRHD(I,J),I=1,3),J= 71, 80) / &
         0.016155D-6,   10213.285546211D0, 1.331103168D0, &
         0.014751D-6,    1349.867409659D0, 4.308933301D0, &
         0.015949D-6,    -220.412642439D0, 4.005298270D0, &
         0.015974D-6,   -2352.866153772D0, 6.145309371D0, &
         0.014223D-6,   17789.845619785D0, 2.104551349D0, &
         0.017806D-6,      73.297125859D0, 3.475975097D0, &
         0.013671D-6,    -536.804512095D0, 5.971672571D0, &
         0.011942D-6,    8031.092263058D0, 2.053414715D0, &
         0.014318D-6,   16730.463689596D0, 3.016058075D0, &
         0.012462D-6,     103.092774219D0, 1.737438797D0 /
      DATA ((FAIRHD(I,J),I=1,3),J= 81, 90) / &
         0.010962D-6,       3.590428652D0, 2.196567739D0, &
         0.015078D-6,   19651.048481098D0, 3.969480770D0, &
         0.010396D-6,     951.718406251D0, 5.717799605D0, &
         0.011707D-6,   -4705.732307544D0, 2.654125618D0, &
         0.010453D-6,    5863.591206116D0, 1.913704550D0, &
         0.012420D-6,    4690.479836359D0, 4.734090399D0, &
         0.011847D-6,    5643.178563677D0, 5.489005403D0, &
         0.008610D-6,    3340.612426700D0, 3.661698944D0, &
         0.011622D-6,    5120.601145584D0, 4.863931876D0, &
         0.010825D-6,     553.569402842D0, 0.842715011D0 /
      DATA ((FAIRHD(I,J),I=1,3),J= 91,100) / &
         0.008666D-6,    -135.065080035D0, 3.293406547D0, &
         0.009963D-6,     149.563197135D0, 4.870690598D0, &
         0.009858D-6,    6309.374169791D0, 1.061816410D0, &
         0.007959D-6,     316.391869657D0, 2.465042647D0, &
         0.010099D-6,     283.859318865D0, 1.942176992D0, &
         0.007147D-6,    -242.728603974D0, 3.661486981D0, &
         0.007505D-6,    5230.807466803D0, 4.920937029D0, &
         0.008323D-6,   11769.853693166D0, 1.229392026D0, &
         0.007490D-6,   -6256.777530192D0, 3.658444681D0, &
         0.009370D-6,  149854.400134205D0, 0.673880395D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=101,110) / &
         0.007117D-6,      38.027672636D0, 5.294249518D0, &
         0.007857D-6,   12168.002696575D0, 0.525733528D0, &
         0.007019D-6,    6206.809778716D0, 0.837688810D0, &
         0.006056D-6,     955.599741609D0, 4.194535082D0, &
         0.008107D-6,   13367.972631107D0, 3.793235253D0, &
         0.006731D-6,    5650.292110678D0, 5.639906583D0, &
         0.007332D-6,      36.648562930D0, 0.114858677D0, &
         0.006366D-6,    4164.311989613D0, 2.262081818D0, &
         0.006858D-6,    5216.580372801D0, 0.642063318D0, &
         0.006919D-6,    6681.224853400D0, 6.018501522D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=111,120) / &
         0.006826D-6,    7632.943259650D0, 3.458654112D0, &
         0.005308D-6,   -1592.596013633D0, 2.500382359D0, &
         0.005096D-6,   11371.704689758D0, 2.547107806D0, &
         0.004841D-6,    5333.900241022D0, 0.437078094D0, &
         0.005582D-6,    5966.683980335D0, 2.246174308D0, &
         0.006304D-6,   11926.254413669D0, 2.512929171D0, &
         0.006603D-6,   23581.258177318D0, 5.393136889D0, &
         0.005123D-6,      -1.484472708D0, 2.999641028D0, &
         0.004648D-6,    1589.072895284D0, 1.275847090D0, &
         0.005119D-6,    6438.496249426D0, 1.486539246D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=121,130) / &
         0.004521D-6,    4292.330832950D0, 6.140635794D0, &
         0.005680D-6,   23013.539539587D0, 4.557814849D0, &
         0.005488D-6,      -3.455808046D0, 0.090675389D0, &
         0.004193D-6,    7234.794256242D0, 4.869091389D0, &
         0.003742D-6,    7238.675591600D0, 4.691976180D0, &
         0.004148D-6,    -110.206321219D0, 3.016173439D0, &
         0.004553D-6,   11499.656222793D0, 5.554998314D0, &
         0.004892D-6,    5436.993015240D0, 1.475415597D0, &
         0.004044D-6,    4732.030627343D0, 1.398784824D0, &
         0.004164D-6,   12491.370101415D0, 5.650931916D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=131,140) / &
         0.004349D-6,   11513.883316794D0, 2.181745369D0, &
         0.003919D-6,   12528.018664345D0, 5.823319737D0, &
         0.003129D-6,    6836.645252834D0, 0.003844094D0, &
         0.004080D-6,   -7058.598461315D0, 3.690360123D0, &
         0.003270D-6,      76.266071276D0, 1.517189902D0, &
         0.002954D-6,    6283.143160294D0, 4.447203799D0, &
         0.002872D-6,      28.449187468D0, 1.158692983D0, &
         0.002881D-6,     735.876513532D0, 0.349250250D0, &
         0.003279D-6,    5849.364112115D0, 4.893384368D0, &
         0.003625D-6,    6209.778724132D0, 1.473760578D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=141,150) / &
         0.003074D-6,     949.175608970D0, 5.185878737D0, &
         0.002775D-6,    9917.696874510D0, 1.030026325D0, &
         0.002646D-6,   10973.555686350D0, 3.918259169D0, &
         0.002575D-6,   25132.303399966D0, 6.109659023D0, &
         0.003500D-6,     263.083923373D0, 1.892100742D0, &
         0.002740D-6,   18319.536584880D0, 4.320519510D0, &
         0.002464D-6,     202.253395174D0, 4.698203059D0, &
         0.002409D-6,       2.542797281D0, 5.325009315D0, &
         0.003354D-6,  -90955.551694697D0, 1.942656623D0, &
         0.002296D-6,    6496.374945429D0, 5.061810696D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=151,160) / &
         0.003002D-6,    6172.869528772D0, 2.797822767D0, &
         0.003202D-6,   27511.467873537D0, 0.531673101D0, &
         0.002954D-6,   -6283.008539689D0, 4.533471191D0, &
         0.002353D-6,     639.897286314D0, 3.734548088D0, &
         0.002401D-6,   16200.772724501D0, 2.605547070D0, &
         0.003053D-6,  233141.314403759D0, 3.029030662D0, &
         0.003024D-6,   83286.914269554D0, 2.355556099D0, &
         0.002863D-6,   17298.182327326D0, 5.240963796D0, &
         0.002103D-6,   -7079.373856808D0, 5.756641637D0, &
         0.002303D-6,   83996.847317911D0, 2.013686814D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=161,170) / &
         0.002303D-6,   18073.704938650D0, 1.089100410D0, &
         0.002381D-6,      63.735898303D0, 0.759188178D0, &
         0.002493D-6,    6386.168624210D0, 0.645026535D0, &
         0.002366D-6,       3.932153263D0, 6.215885448D0, &
         0.002169D-6,   11015.106477335D0, 4.845297676D0, &
         0.002397D-6,    6243.458341645D0, 3.809290043D0, &
         0.002183D-6,    1162.474704408D0, 6.179611691D0, &
         0.002353D-6,    6246.427287062D0, 4.781719760D0, &
         0.002199D-6,    -245.831646229D0, 5.956152284D0, &
         0.001729D-6,    3894.181829542D0, 1.264976635D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=171,180) / &
         0.001896D-6,   -3128.388765096D0, 4.914231596D0, &
         0.002085D-6,      35.164090221D0, 1.405158503D0, &
         0.002024D-6,   14712.317116458D0, 2.752035928D0, &
         0.001737D-6,    6290.189396992D0, 5.280820144D0, &
         0.002229D-6,     491.557929457D0, 1.571007057D0, &
         0.001602D-6,   14314.168113050D0, 4.203664806D0, &
         0.002186D-6,     454.909366527D0, 1.402101526D0, &
         0.001897D-6,   22483.848574493D0, 4.167932508D0, &
         0.001825D-6,   -3738.761430108D0, 0.545828785D0, &
         0.001894D-6,    1052.268383188D0, 5.817167450D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=181,190) / &
         0.001421D-6,      20.355319399D0, 2.419886601D0, &
         0.001408D-6,   10984.192351700D0, 2.732084787D0, &
         0.001847D-6,   10873.986030480D0, 2.903477885D0, &
         0.001391D-6,   -8635.942003763D0, 0.593891500D0, &
         0.001388D-6,      -7.046236698D0, 1.166145902D0, &
         0.001810D-6,  -88860.057071188D0, 0.487355242D0, &
         0.001288D-6,   -1990.745017041D0, 3.913022880D0, &
         0.001297D-6,   23543.230504682D0, 3.063805171D0, &
         0.001335D-6,    -266.607041722D0, 3.995764039D0, &
         0.001376D-6,   10969.965257698D0, 5.152914309D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=191,200) / &
         0.001745D-6,  244287.600007027D0, 3.626395673D0, &
         0.001649D-6,   31441.677569757D0, 1.952049260D0, &
         0.001416D-6,    9225.539273283D0, 4.996408389D0, &
         0.001238D-6,    4804.209275927D0, 5.503379738D0, &
         0.001472D-6,    4590.910180489D0, 4.164913291D0, &
         0.001169D-6,    6040.347246017D0, 5.841719038D0, &
         0.001039D-6,    5540.085789459D0, 2.769753519D0, &
         0.001004D-6,    -170.672870619D0, 0.755008103D0, &
         0.001284D-6,   10575.406682942D0, 5.306538209D0, &
         0.001278D-6,      71.812653151D0, 4.713486491D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=201,210) / &
         0.001321D-6,   18209.330263660D0, 2.624866359D0, &
         0.001297D-6,   21228.392023546D0, 0.382603541D0, &
         0.000954D-6,    6282.095528923D0, 0.882213514D0, &
         0.001145D-6,    6058.731054289D0, 1.169483931D0, &
         0.000979D-6,    5547.199336460D0, 5.448375984D0, &
         0.000987D-6,   -6262.300454499D0, 2.656486959D0, &
         0.001070D-6, -154717.609887482D0, 1.827624012D0, &
         0.000991D-6,    4701.116501708D0, 4.387001801D0, &
         0.001155D-6,     -14.227094002D0, 3.042700750D0, &
         0.001176D-6,     277.034993741D0, 3.335519004D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=211,220) / &
         0.000890D-6,   13916.019109642D0, 5.601498297D0, &
         0.000884D-6,   -1551.045222648D0, 1.088831705D0, &
         0.000876D-6,    5017.508371365D0, 3.969902609D0, &
         0.000806D-6,   15110.466119866D0, 5.142876744D0, &
         0.000773D-6,   -4136.910433516D0, 0.022067765D0, &
         0.001077D-6,     175.166059800D0, 1.844913056D0, &
         0.000954D-6,   -6284.056171060D0, 0.968480906D0, &
         0.000737D-6,    5326.786694021D0, 4.923831588D0, &
         0.000845D-6,    -433.711737877D0, 4.749245231D0, &
         0.000819D-6,    8662.240323563D0, 5.991247817D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=221,230) / &
         0.000852D-6,     199.072001436D0, 2.189604979D0, &
         0.000723D-6,   17256.631536341D0, 6.068719637D0, &
         0.000940D-6,    6037.244203762D0, 6.197428148D0, &
         0.000885D-6,   11712.955318231D0, 3.280414875D0, &
         0.000706D-6,   12559.038152982D0, 2.824848947D0, &
         0.000732D-6,    2379.164473572D0, 2.501813417D0, &
         0.000764D-6,   -6127.655450557D0, 2.236346329D0, &
         0.000908D-6,     131.541961686D0, 2.521257490D0, &
         0.000907D-6,   35371.887265976D0, 3.370195967D0, &
         0.000673D-6,    1066.495477190D0, 3.876512374D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=231,240) / &
         0.000814D-6,   17654.780539750D0, 4.627122566D0, &
         0.000630D-6,      36.027866677D0, 0.156368499D0, &
         0.000798D-6,     515.463871093D0, 5.151962502D0, &
         0.000798D-6,     148.078724426D0, 5.909225055D0, &
         0.000806D-6,     309.278322656D0, 6.054064447D0, &
         0.000607D-6,     -39.617508346D0, 2.839021623D0, &
         0.000601D-6,     412.371096874D0, 3.984225404D0, &
         0.000646D-6,   11403.676995575D0, 3.852959484D0, &
         0.000704D-6,   13521.751441591D0, 2.300991267D0, &
         0.000603D-6,  -65147.619767937D0, 4.140083146D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=241,250) / &
         0.000609D-6,   10177.257679534D0, 0.437122327D0, &
         0.000631D-6,    5767.611978898D0, 4.026532329D0, &
         0.000576D-6,   11087.285125918D0, 4.760293101D0, &
         0.000674D-6,   14945.316173554D0, 6.270510511D0, &
         0.000726D-6,    5429.879468239D0, 6.039606892D0, &
         0.000710D-6,   28766.924424484D0, 5.672617711D0, &
         0.000647D-6,   11856.218651625D0, 3.397132627D0, &
         0.000678D-6,   -5481.254918868D0, 6.249666675D0, &
         0.000618D-6,   22003.914634870D0, 2.466427018D0, &
         0.000738D-6,    6134.997125565D0, 2.242668890D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=251,260) / &
         0.000660D-6,     625.670192312D0, 5.864091907D0, &
         0.000694D-6,    3496.032826134D0, 2.668309141D0, &
         0.000531D-6,    6489.261398429D0, 1.681888780D0, &
         0.000611D-6, -143571.324284214D0, 2.424978312D0, &
         0.000575D-6,   12043.574281889D0, 4.216492400D0, &
         0.000553D-6,   12416.588502848D0, 4.772158039D0, &
         0.000689D-6,    4686.889407707D0, 6.224271088D0, &
         0.000495D-6,    7342.457780181D0, 3.817285811D0, &
         0.000567D-6,    3634.621024518D0, 1.649264690D0, &
         0.000515D-6,   18635.928454536D0, 3.945345892D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=261,270) / &
         0.000486D-6,    -323.505416657D0, 4.061673868D0, &
         0.000662D-6,   25158.601719765D0, 1.794058369D0, &
         0.000509D-6,     846.082834751D0, 3.053874588D0, &
         0.000472D-6,  -12569.674818332D0, 5.112133338D0, &
         0.000461D-6,    6179.983075773D0, 0.513669325D0, &
         0.000641D-6,   83467.156352816D0, 3.210727723D0, &
         0.000520D-6,   10344.295065386D0, 2.445597761D0, &
         0.000493D-6,   18422.629359098D0, 1.676939306D0, &
         0.000478D-6,    1265.567478626D0, 5.487314569D0, &
         0.000472D-6,     -18.159247265D0, 1.999707589D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=271,280) / &
         0.000559D-6,   11190.377900137D0, 5.783236356D0, &
         0.000494D-6,    9623.688276691D0, 3.022645053D0, &
         0.000463D-6,    5739.157790895D0, 1.411223013D0, &
         0.000432D-6,   16858.482532933D0, 1.179256434D0, &
         0.000574D-6,   72140.628666286D0, 1.758191830D0, &
         0.000484D-6,   17267.268201691D0, 3.290589143D0, &
         0.000550D-6,    4907.302050146D0, 0.864024298D0, &
         0.000399D-6,      14.977853527D0, 2.094441910D0, &
         0.000491D-6,     224.344795702D0, 0.878372791D0, &
         0.000432D-6,   20426.571092422D0, 6.003829241D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=281,290) / &
         0.000481D-6,    5749.452731634D0, 4.309591964D0, &
         0.000480D-6,    5757.317038160D0, 1.142348571D0, &
         0.000485D-6,    6702.560493867D0, 0.210580917D0, &
         0.000426D-6,    6055.549660552D0, 4.274476529D0, &
         0.000480D-6,    5959.570433334D0, 5.031351030D0, &
         0.000466D-6,   12562.628581634D0, 4.959581597D0, &
         0.000520D-6,   39302.096962196D0, 4.788002889D0, &
         0.000458D-6,   12132.439962106D0, 1.880103788D0, &
         0.000470D-6,   12029.347187887D0, 1.405611197D0, &
         0.000416D-6,   -7477.522860216D0, 1.082356330D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=291,300) / &
         0.000449D-6,   11609.862544012D0, 4.179989585D0, &
         0.000465D-6,   17253.041107690D0, 0.353496295D0, &
         0.000362D-6,   -4535.059436924D0, 1.583849576D0, &
         0.000383D-6,   21954.157609398D0, 3.747376371D0, &
         0.000389D-6,      17.252277143D0, 1.395753179D0, &
         0.000331D-6,   18052.929543158D0, 0.566790582D0, &
         0.000430D-6,   13517.870106233D0, 0.685827538D0, &
         0.000368D-6,   -5756.908003246D0, 0.731374317D0, &
         0.000330D-6,   10557.594160824D0, 3.710043680D0, &
         0.000332D-6,   20199.094959633D0, 1.652901407D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=301,310) / &
         0.000384D-6,   11933.367960670D0, 5.827781531D0, &
         0.000387D-6,   10454.501386605D0, 2.541182564D0, &
         0.000325D-6,   15671.081759407D0, 2.178850542D0, &
         0.000318D-6,     138.517496871D0, 2.253253037D0, &
         0.000305D-6,    9388.005909415D0, 0.578340206D0, &
         0.000352D-6,    5749.861766548D0, 3.000297967D0, &
         0.000311D-6,    6915.859589305D0, 1.693574249D0, &
         0.000297D-6,   24072.921469776D0, 1.997249392D0, &
         0.000363D-6,    -640.877607382D0, 5.071820966D0, &
         0.000323D-6,   12592.450019783D0, 1.072262823D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=311,320) / &
         0.000341D-6,   12146.667056108D0, 4.700657997D0, &
         0.000290D-6,    9779.108676125D0, 1.812320441D0, &
         0.000342D-6,    6132.028180148D0, 4.322238614D0, &
         0.000329D-6,    6268.848755990D0, 3.033827743D0, &
         0.000374D-6,   17996.031168222D0, 3.388716544D0, &
         0.000285D-6,    -533.214083444D0, 4.687313233D0, &
         0.000338D-6,    6065.844601290D0, 0.877776108D0, &
         0.000276D-6,      24.298513841D0, 0.770299429D0, &
         0.000336D-6,   -2388.894020449D0, 5.353796034D0, &
         0.000290D-6,    3097.883822726D0, 4.075291557D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=321,330) / &
         0.000318D-6,     709.933048357D0, 5.941207518D0, &
         0.000271D-6,   13095.842665077D0, 3.208912203D0, &
         0.000331D-6,    6073.708907816D0, 4.007881169D0, &
         0.000292D-6,     742.990060533D0, 2.714333592D0, &
         0.000362D-6,   29088.811415985D0, 3.215977013D0, &
         0.000280D-6,   12359.966151546D0, 0.710872502D0, &
         0.000267D-6,   10440.274292604D0, 4.730108488D0, &
         0.000262D-6,     838.969287750D0, 1.327720272D0, &
         0.000250D-6,   16496.361396202D0, 0.898769761D0, &
         0.000325D-6,   20597.243963041D0, 0.180044365D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=331,340) / &
         0.000268D-6,    6148.010769956D0, 5.152666276D0, &
         0.000284D-6,    5636.065016677D0, 5.655385808D0, &
         0.000301D-6,    6080.822454817D0, 2.135396205D0, &
         0.000294D-6,    -377.373607916D0, 3.708784168D0, &
         0.000236D-6,    2118.763860378D0, 1.733578756D0, &
         0.000234D-6,    5867.523359379D0, 5.575209112D0, &
         0.000268D-6, -226858.238553767D0, 0.069432392D0, &
         0.000265D-6,  167283.761587465D0, 4.369302826D0, &
         0.000280D-6,   28237.233459389D0, 5.304829118D0, &
         0.000292D-6,   12345.739057544D0, 4.096094132D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=341,350) / &
         0.000223D-6,   19800.945956225D0, 3.069327406D0, &
         0.000301D-6,   43232.306658416D0, 6.205311188D0, &
         0.000264D-6,   18875.525869774D0, 1.417263408D0, &
         0.000304D-6,   -1823.175188677D0, 3.409035232D0, &
         0.000301D-6,     109.945688789D0, 0.510922054D0, &
         0.000260D-6,     813.550283960D0, 2.389438934D0, &
         0.000299D-6,  316428.228673312D0, 5.384595078D0, &
         0.000211D-6,    5756.566278634D0, 3.789392838D0, &
         0.000209D-6,    5750.203491159D0, 1.661943545D0, &
         0.000240D-6,   12489.885628707D0, 5.684549045D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=351,360) / &
         0.000216D-6,    6303.851245484D0, 3.862942261D0, &
         0.000203D-6,    1581.959348283D0, 5.549853589D0, &
         0.000200D-6,    5642.198242609D0, 1.016115785D0, &
         0.000197D-6,     -70.849445304D0, 4.690702525D0, &
         0.000227D-6,    6287.008003254D0, 2.911891613D0, &
         0.000197D-6,     533.623118358D0, 1.048982898D0, &
         0.000205D-6,   -6279.485421340D0, 1.829362730D0, &
         0.000209D-6,  -10988.808157535D0, 2.636140084D0, &
         0.000208D-6,    -227.526189440D0, 4.127883842D0, &
         0.000191D-6,     415.552490612D0, 4.401165650D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=361,370) / &
         0.000190D-6,   29296.615389579D0, 4.175658539D0, &
         0.000264D-6,   66567.485864652D0, 4.601102551D0, &
         0.000256D-6,   -3646.350377354D0, 0.506364778D0, &
         0.000188D-6,   13119.721102825D0, 2.032195842D0, &
         0.000185D-6,    -209.366942175D0, 4.694756586D0, &
         0.000198D-6,   25934.124331089D0, 3.832703118D0, &
         0.000195D-6,    4061.219215394D0, 3.308463427D0, &
         0.000234D-6,    5113.487598583D0, 1.716090661D0, &
         0.000188D-6,    1478.866574064D0, 5.686865780D0, &
         0.000222D-6,   11823.161639450D0, 1.942386641D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=371,380) / &
         0.000181D-6,   10770.893256262D0, 1.999482059D0, &
         0.000171D-6,    6546.159773364D0, 1.182807992D0, &
         0.000206D-6,      70.328180442D0, 5.934076062D0, &
         0.000169D-6,   20995.392966449D0, 2.169080622D0, &
         0.000191D-6,   10660.686935042D0, 5.405515999D0, &
         0.000228D-6,   33019.021112205D0, 4.656985514D0, &
         0.000184D-6,   -4933.208440333D0, 3.327476868D0, &
         0.000220D-6,    -135.625325010D0, 1.765430262D0, &
         0.000166D-6,   23141.558382925D0, 3.454132746D0, &
         0.000191D-6,    6144.558353121D0, 5.020393445D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=381,390) / &
         0.000180D-6,    6084.003848555D0, 0.602182191D0, &
         0.000163D-6,   17782.732072784D0, 4.960593133D0, &
         0.000225D-6,   16460.333529525D0, 2.596451817D0, &
         0.000222D-6,    5905.702242076D0, 3.731990323D0, &
         0.000204D-6,     227.476132789D0, 5.636192701D0, &
         0.000159D-6,   16737.577236597D0, 3.600691544D0, &
         0.000200D-6,    6805.653268085D0, 0.868220961D0, &
         0.000187D-6,   11919.140866668D0, 2.629456641D0, &
         0.000161D-6,     127.471796607D0, 2.862574720D0, &
         0.000205D-6,    6286.666278643D0, 1.742882331D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=391,400) / &
         0.000189D-6,     153.778810485D0, 4.812372643D0, &
         0.000168D-6,   16723.350142595D0, 0.027860588D0, &
         0.000149D-6,   11720.068865232D0, 0.659721876D0, &
         0.000189D-6,    5237.921013804D0, 5.245313000D0, &
         0.000143D-6,    6709.674040867D0, 4.317625647D0, &
         0.000146D-6,    4487.817406270D0, 4.815297007D0, &
         0.000144D-6,    -664.756045130D0, 5.381366880D0, &
         0.000175D-6,    5127.714692584D0, 4.728443327D0, &
         0.000162D-6,    6254.626662524D0, 1.435132069D0, &
         0.000187D-6,   47162.516354635D0, 1.354371923D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=401,410) / &
         0.000146D-6,   11080.171578918D0, 3.369695406D0, &
         0.000180D-6,    -348.924420448D0, 2.490902145D0, &
         0.000148D-6,     151.047669843D0, 3.799109588D0, &
         0.000157D-6,    6197.248551160D0, 1.284375887D0, &
         0.000167D-6,     146.594251718D0, 0.759969109D0, &
         0.000133D-6,   -5331.357443741D0, 5.409701889D0, &
         0.000154D-6,      95.979227218D0, 3.366890614D0, &
         0.000148D-6,   -6418.140930027D0, 3.384104996D0, &
         0.000128D-6,   -6525.804453965D0, 3.803419985D0, &
         0.000130D-6,   11293.470674356D0, 0.939039445D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=411,420) / &
         0.000152D-6,   -5729.506447149D0, 0.734117523D0, &
         0.000138D-6,     210.117701700D0, 2.564216078D0, &
         0.000123D-6,    6066.595360816D0, 4.517099537D0, &
         0.000140D-6,   18451.078546566D0, 0.642049130D0, &
         0.000126D-6,   11300.584221356D0, 3.485280663D0, &
         0.000119D-6,   10027.903195729D0, 3.217431161D0, &
         0.000151D-6,    4274.518310832D0, 4.404359108D0, &
         0.000117D-6,    6072.958148291D0, 0.366324650D0, &
         0.000165D-6,   -7668.637425143D0, 4.298212528D0, &
         0.000117D-6,   -6245.048177356D0, 5.379518958D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=421,430) / &
         0.000130D-6,   -5888.449964932D0, 4.527681115D0, &
         0.000121D-6,    -543.918059096D0, 6.109429504D0, &
         0.000162D-6,    9683.594581116D0, 5.720092446D0, &
         0.000141D-6,    6219.339951688D0, 0.679068671D0, &
         0.000118D-6,   22743.409379516D0, 4.881123092D0, &
         0.000129D-6,    1692.165669502D0, 0.351407289D0, &
         0.000126D-6,    5657.405657679D0, 5.146592349D0, &
         0.000114D-6,     728.762966531D0, 0.520791814D0, &
         0.000120D-6,      52.596639600D0, 0.948516300D0, &
         0.000115D-6,      65.220371012D0, 3.504914846D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=431,440) / &
         0.000126D-6,    5881.403728234D0, 5.577502482D0, &
         0.000158D-6,  163096.180360983D0, 2.957128968D0, &
         0.000134D-6,   12341.806904281D0, 2.598576764D0, &
         0.000151D-6,   16627.370915377D0, 3.985702050D0, &
         0.000109D-6,    1368.660252845D0, 0.014730471D0, &
         0.000131D-6,    6211.263196841D0, 0.085077024D0, &
         0.000146D-6,    5792.741760812D0, 0.708426604D0, &
         0.000146D-6,     -77.750543984D0, 3.121576600D0, &
         0.000107D-6,    5341.013788022D0, 0.288231904D0, &
         0.000138D-6,    6281.591377283D0, 2.797450317D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=441,450) / &
         0.000113D-6,   -6277.552925684D0, 2.788904128D0, &
         0.000115D-6,    -525.758811831D0, 5.895222200D0, &
         0.000138D-6,    6016.468808270D0, 6.096188999D0, &
         0.000139D-6,   23539.707386333D0, 2.028195445D0, &
         0.000146D-6,   -4176.041342449D0, 4.660008502D0, &
         0.000107D-6,   16062.184526117D0, 4.066520001D0, &
         0.000142D-6,   83783.548222473D0, 2.936315115D0, &
         0.000128D-6,    9380.959672717D0, 3.223844306D0, &
         0.000135D-6,    6205.325306007D0, 1.638054048D0, &
         0.000101D-6,    2699.734819318D0, 5.481603249D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=451,460) / &
         0.000104D-6,    -568.821874027D0, 2.205734493D0, &
         0.000103D-6,    6321.103522627D0, 2.440421099D0, &
         0.000119D-6,    6321.208885629D0, 2.547496264D0, &
         0.000138D-6,    1975.492545856D0, 2.314608466D0, &
         0.000121D-6,     137.033024162D0, 4.539108237D0, &
         0.000123D-6,   19402.796952817D0, 4.538074405D0, &
         0.000119D-6,   22805.735565994D0, 2.869040566D0, &
         0.000133D-6,   64471.991241142D0, 6.056405489D0, &
         0.000129D-6,     -85.827298831D0, 2.540635083D0, &
         0.000131D-6,   13613.804277336D0, 4.005732868D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=461,470) / &
         0.000104D-6,    9814.604100291D0, 1.959967212D0, &
         0.000112D-6,   16097.679950283D0, 3.589026260D0, &
         0.000123D-6,    2107.034507542D0, 1.728627253D0, &
         0.000121D-6,   36949.230808424D0, 6.072332087D0, &
         0.000108D-6,  -12539.853380183D0, 3.716133846D0, &
         0.000113D-6,   -7875.671863624D0, 2.725771122D0, &
         0.000109D-6,    4171.425536614D0, 4.033338079D0, &
         0.000101D-6,    6247.911759770D0, 3.441347021D0, &
         0.000113D-6,    7330.728427345D0, 0.656372122D0, &
         0.000113D-6,   51092.726050855D0, 2.791483066D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=471,480) / &
         0.000106D-6,    5621.842923210D0, 1.815323326D0, &
         0.000101D-6,     111.430161497D0, 5.711033677D0, &
         0.000103D-6,     909.818733055D0, 2.812745443D0, &
         0.000101D-6,    1790.642637886D0, 1.965746028D0, &

!  T 
       102.156724D-6,    6283.075849991D0, 4.249032005D0, &
         1.706807D-6,   12566.151699983D0, 4.205904248D0, &
         0.269668D-6,     213.299095438D0, 3.400290479D0, &
         0.265919D-6,     529.690965095D0, 5.836047367D0, &
         0.210568D-6,      -3.523118349D0, 6.262738348D0, &
         0.077996D-6,    5223.693919802D0, 4.670344204D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=481,490) / &
         0.054764D-6,    1577.343542448D0, 4.534800170D0, &
         0.059146D-6,      26.298319800D0, 1.083044735D0, &
         0.034420D-6,    -398.149003408D0, 5.980077351D0, &
         0.032088D-6,   18849.227549974D0, 4.162913471D0, &
         0.033595D-6,    5507.553238667D0, 5.980162321D0, &
         0.029198D-6,    5856.477659115D0, 0.623811863D0, &
         0.027764D-6,     155.420399434D0, 3.745318113D0, &
         0.025190D-6,    5746.271337896D0, 2.980330535D0, &
         0.022997D-6,    -796.298006816D0, 1.174411803D0, &
         0.024976D-6,    5760.498431898D0, 2.467913690D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=491,500) / &
         0.021774D-6,     206.185548437D0, 3.854787540D0, &
         0.017925D-6,    -775.522611324D0, 1.092065955D0, &
         0.013794D-6,     426.598190876D0, 2.699831988D0, &
         0.013276D-6,    6062.663207553D0, 5.845801920D0, &
         0.011774D-6,   12036.460734888D0, 2.292832062D0, &
         0.012869D-6,    6076.890301554D0, 5.333425680D0, &
         0.012152D-6,    1059.381930189D0, 6.222874454D0, &
         0.011081D-6,      -7.113547001D0, 5.154724984D0, &
         0.010143D-6,    4694.002954708D0, 4.044013795D0, &
         0.009357D-6,    5486.777843175D0, 3.416081409D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=501,510) / &
         0.010084D-6,     522.577418094D0, 0.749320262D0, &
         0.008587D-6,   10977.078804699D0, 2.777152598D0, &
         0.008628D-6,    6275.962302991D0, 4.562060226D0, &
         0.008158D-6,    -220.412642439D0, 5.806891533D0, &
         0.007746D-6,    2544.314419883D0, 1.603197066D0, &
         0.007670D-6,    2146.165416475D0, 3.000200440D0, &
         0.007098D-6,      74.781598567D0, 0.443725817D0, &
         0.006180D-6,    -536.804512095D0, 1.302642751D0, &
         0.005818D-6,    5088.628839767D0, 4.827723531D0, &
         0.004945D-6,   -6286.598968340D0, 0.268305170D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=511,520) / &
         0.004774D-6,    1349.867409659D0, 5.808636673D0, &
         0.004687D-6,    -242.728603974D0, 5.154890570D0, &
         0.006089D-6,    1748.016413067D0, 4.403765209D0, &
         0.005975D-6,   -1194.447010225D0, 2.583472591D0, &
         0.004229D-6,     951.718406251D0, 0.931172179D0, &
         0.005264D-6,     553.569402842D0, 2.336107252D0, &
         0.003049D-6,    5643.178563677D0, 1.362634430D0, &
         0.002974D-6,    6812.766815086D0, 1.583012668D0, &
         0.003403D-6,   -2352.866153772D0, 2.552189886D0, &
         0.003030D-6,     419.484643875D0, 5.286473844D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=521,530) / &
         0.003210D-6,      -7.046236698D0, 1.863796539D0, &
         0.003058D-6,    9437.762934887D0, 4.226420633D0, &
         0.002589D-6,   12352.852604545D0, 1.991935820D0, &
         0.002927D-6,    5216.580372801D0, 2.319951253D0, &
         0.002425D-6,    5230.807466803D0, 3.084752833D0, &
         0.002656D-6,    3154.687084896D0, 2.487447866D0, &
         0.002445D-6,   10447.387839604D0, 2.347139160D0, &
         0.002990D-6,    4690.479836359D0, 6.235872050D0, &
         0.002890D-6,    5863.591206116D0, 0.095197563D0, &
         0.002498D-6,    6438.496249426D0, 2.994779800D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=531,540) / &
         0.001889D-6,    8031.092263058D0, 3.569003717D0, &
         0.002567D-6,     801.820931124D0, 3.425611498D0, &
         0.001803D-6,  -71430.695617928D0, 2.192295512D0, &
         0.001782D-6,       3.932153263D0, 5.180433689D0, &
         0.001694D-6,   -4705.732307544D0, 4.641779174D0, &
         0.001704D-6,   -1592.596013633D0, 3.997097652D0, &
         0.001735D-6,    5849.364112115D0, 0.417558428D0, &
         0.001643D-6,    8429.241266467D0, 2.180619584D0, &
         0.001680D-6,      38.133035638D0, 4.164529426D0, &
         0.002045D-6,    7084.896781115D0, 0.526323854D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=541,550) / &
         0.001458D-6,    4292.330832950D0, 1.356098141D0, &
         0.001437D-6,      20.355319399D0, 3.895439360D0, &
         0.001738D-6,    6279.552731642D0, 0.087484036D0, &
         0.001367D-6,   14143.495242431D0, 3.987576591D0, &
         0.001344D-6,    7234.794256242D0, 0.090454338D0, &
         0.001438D-6,   11499.656222793D0, 0.974387904D0, &
         0.001257D-6,    6836.645252834D0, 1.509069366D0, &
         0.001358D-6,   11513.883316794D0, 0.495572260D0, &
         0.001628D-6,    7632.943259650D0, 4.968445721D0, &
         0.001169D-6,     103.092774219D0, 2.838496795D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=551,560) / &
         0.001162D-6,    4164.311989613D0, 3.408387778D0, &
         0.001092D-6,    6069.776754553D0, 3.617942651D0, &
         0.001008D-6,   17789.845619785D0, 0.286350174D0, &
         0.001008D-6,     639.897286314D0, 1.610762073D0, &
         0.000918D-6,   10213.285546211D0, 5.532798067D0, &
         0.001011D-6,   -6256.777530192D0, 0.661826484D0, &
         0.000753D-6,   16730.463689596D0, 3.905030235D0, &
         0.000737D-6,   11926.254413669D0, 4.641956361D0, &
         0.000694D-6,    3340.612426700D0, 2.111120332D0, &
         0.000701D-6,    3894.181829542D0, 2.760823491D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=561,570) / &
         0.000689D-6,    -135.065080035D0, 4.768800780D0, &
         0.000700D-6,   13367.972631107D0, 5.760439898D0, &
         0.000664D-6,    6040.347246017D0, 1.051215840D0, &
         0.000654D-6,    5650.292110678D0, 4.911332503D0, &
         0.000788D-6,    6681.224853400D0, 4.699648011D0, &
         0.000628D-6,    5333.900241022D0, 5.024608847D0, &
         0.000755D-6,    -110.206321219D0, 4.370971253D0, &
         0.000628D-6,    6290.189396992D0, 3.660478857D0, &
         0.000635D-6,   25132.303399966D0, 4.121051532D0, &
         0.000534D-6,    5966.683980335D0, 1.173284524D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=571,580) / &
         0.000543D-6,    -433.711737877D0, 0.345585464D0, &
         0.000517D-6,   -1990.745017041D0, 5.414571768D0, &
         0.000504D-6,    5767.611978898D0, 2.328281115D0, &
         0.000485D-6,    5753.384884897D0, 1.685874771D0, &
         0.000463D-6,    7860.419392439D0, 5.297703006D0, &
         0.000604D-6,     515.463871093D0, 0.591998446D0, &
         0.000443D-6,   12168.002696575D0, 4.830881244D0, &
         0.000570D-6,     199.072001436D0, 3.899190272D0, &
         0.000465D-6,   10969.965257698D0, 0.476681802D0, &
         0.000424D-6,   -7079.373856808D0, 1.112242763D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=581,590) / &
         0.000427D-6,     735.876513532D0, 1.994214480D0, &
         0.000478D-6,   -6127.655450557D0, 3.778025483D0, &
         0.000414D-6,   10973.555686350D0, 5.441088327D0, &
         0.000512D-6,    1589.072895284D0, 0.107123853D0, &
         0.000378D-6,   10984.192351700D0, 0.915087231D0, &
         0.000402D-6,   11371.704689758D0, 4.107281715D0, &
         0.000453D-6,    9917.696874510D0, 1.917490952D0, &
         0.000395D-6,     149.563197135D0, 2.763124165D0, &
         0.000371D-6,    5739.157790895D0, 3.112111866D0, &
         0.000350D-6,   11790.629088659D0, 0.440639857D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=591,600) / &
         0.000356D-6,    6133.512652857D0, 5.444568842D0, &
         0.000344D-6,     412.371096874D0, 5.676832684D0, &
         0.000383D-6,     955.599741609D0, 5.559734846D0, &
         0.000333D-6,    6496.374945429D0, 0.261537984D0, &
         0.000340D-6,    6055.549660552D0, 5.975534987D0, &
         0.000334D-6,    1066.495477190D0, 2.335063907D0, &
         0.000399D-6,   11506.769769794D0, 5.321230910D0, &
         0.000314D-6,   18319.536584880D0, 2.313312404D0, &
         0.000424D-6,    1052.268383188D0, 1.211961766D0, &
         0.000307D-6,      63.735898303D0, 3.169551388D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=601,610) / &
         0.000329D-6,      29.821438149D0, 6.106912080D0, &
         0.000357D-6,    6309.374169791D0, 4.223760346D0, &
         0.000312D-6,   -3738.761430108D0, 2.180556645D0, &
         0.000301D-6,     309.278322656D0, 1.499984572D0, &
         0.000268D-6,   12043.574281889D0, 2.447520648D0, &
         0.000257D-6,   12491.370101415D0, 3.662331761D0, &
         0.000290D-6,     625.670192312D0, 1.272834584D0, &
         0.000256D-6,    5429.879468239D0, 1.913426912D0, &
         0.000339D-6,    3496.032826134D0, 4.165930011D0, &
         0.000283D-6,    3930.209696220D0, 4.325565754D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=611,620) / &
         0.000241D-6,   12528.018664345D0, 3.832324536D0, &
         0.000304D-6,    4686.889407707D0, 1.612348468D0, &
         0.000259D-6,   16200.772724501D0, 3.470173146D0, &
         0.000238D-6,   12139.553509107D0, 1.147977842D0, &
         0.000236D-6,    6172.869528772D0, 3.776271728D0, &
         0.000296D-6,   -7058.598461315D0, 0.460368852D0, &
         0.000306D-6,   10575.406682942D0, 0.554749016D0, &
         0.000251D-6,   17298.182327326D0, 0.834332510D0, &
         0.000290D-6,    4732.030627343D0, 4.759564091D0, &
         0.000261D-6,    5884.926846583D0, 0.298259862D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=621,630) / &
         0.000249D-6,    5547.199336460D0, 3.749366406D0, &
         0.000213D-6,   11712.955318231D0, 5.415666119D0, &
         0.000223D-6,    4701.116501708D0, 2.703203558D0, &
         0.000268D-6,    -640.877607382D0, 0.283670793D0, &
         0.000209D-6,    5636.065016677D0, 1.238477199D0, &
         0.000193D-6,   10177.257679534D0, 1.943251340D0, &
         0.000182D-6,    6283.143160294D0, 2.456157599D0, &
         0.000184D-6,    -227.526189440D0, 5.888038582D0, &
         0.000182D-6,   -6283.008539689D0, 0.241332086D0, &
         0.000228D-6,   -6284.056171060D0, 2.657323816D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=631,640) / &
         0.000166D-6,    7238.675591600D0, 5.930629110D0, &
         0.000167D-6,    3097.883822726D0, 5.570955333D0, &
         0.000159D-6,    -323.505416657D0, 5.786670700D0, &
         0.000154D-6,   -4136.910433516D0, 1.517805532D0, &
         0.000176D-6,   12029.347187887D0, 3.139266834D0, &
         0.000167D-6,   12132.439962106D0, 3.556352289D0, &
         0.000153D-6,     202.253395174D0, 1.463313961D0, &
         0.000157D-6,   17267.268201691D0, 1.586837396D0, &
         0.000142D-6,   83996.847317911D0, 0.022670115D0, &
         0.000152D-6,   17260.154654690D0, 0.708528947D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=641,650) / &
         0.000144D-6,    6084.003848555D0, 5.187075177D0, &
         0.000135D-6,    5756.566278634D0, 1.993229262D0, &
         0.000134D-6,    5750.203491159D0, 3.457197134D0, &
         0.000144D-6,    5326.786694021D0, 6.066193291D0, &
         0.000160D-6,   11015.106477335D0, 1.710431974D0, &
         0.000133D-6,    3634.621024518D0, 2.836451652D0, &
         0.000134D-6,   18073.704938650D0, 5.453106665D0, &
         0.000134D-6,    1162.474704408D0, 5.326898811D0, &
         0.000128D-6,    5642.198242609D0, 2.511652591D0, &
         0.000160D-6,     632.783739313D0, 5.628785365D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=651,660) / &
         0.000132D-6,   13916.019109642D0, 0.819294053D0, &
         0.000122D-6,   14314.168113050D0, 5.677408071D0, &
         0.000125D-6,   12359.966151546D0, 5.251984735D0, &
         0.000121D-6,    5749.452731634D0, 2.210924603D0, &
         0.000136D-6,    -245.831646229D0, 1.646502367D0, &
         0.000120D-6,    5757.317038160D0, 3.240883049D0, &
         0.000134D-6,   12146.667056108D0, 3.059480037D0, &
         0.000137D-6,    6206.809778716D0, 1.867105418D0, &
         0.000141D-6,   17253.041107690D0, 2.069217456D0, &
         0.000129D-6,   -7477.522860216D0, 2.781469314D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=661,670) / &
         0.000116D-6,    5540.085789459D0, 4.281176991D0, &
         0.000116D-6,    9779.108676125D0, 3.320925381D0, &
         0.000129D-6,    5237.921013804D0, 3.497704076D0, &
         0.000113D-6,    5959.570433334D0, 0.983210840D0, &
         0.000122D-6,    6282.095528923D0, 2.674938860D0, &
         0.000140D-6,     -11.045700264D0, 4.957936982D0, &
         0.000108D-6,   23543.230504682D0, 1.390113589D0, &
         0.000106D-6,  -12569.674818332D0, 0.429631317D0, &
         0.000110D-6,    -266.607041722D0, 5.501340197D0, &
         0.000115D-6,   12559.038152982D0, 4.691456618D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=671,680) / &
         0.000134D-6,   -2388.894020449D0, 0.577313584D0, &
         0.000109D-6,   10440.274292604D0, 6.218148717D0, &
         0.000102D-6,    -543.918059096D0, 1.477842615D0, &
         0.000108D-6,   21228.392023546D0, 2.237753948D0, &
         0.000101D-6,   -4535.059436924D0, 3.100492232D0, &
         0.000103D-6,      76.266071276D0, 5.594294322D0, &
         0.000104D-6,     949.175608970D0, 5.674287810D0, &
         0.000101D-6,   13517.870106233D0, 2.196632348D0, &
         0.000100D-6,   11933.367960670D0, 4.056084160D0, &
         4.322990D-6,    6283.075849991D0, 2.642893748D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=681,690) / &
         0.406495D-6,       0.000000000D0, 4.712388980D0, &
         0.122605D-6,   12566.151699983D0, 2.438140634D0, &
         0.019476D-6,     213.299095438D0, 1.642186981D0, &
         0.016916D-6,     529.690965095D0, 4.510959344D0, &
         0.013374D-6,      -3.523118349D0, 1.502210314D0, &
         0.008042D-6,      26.298319800D0, 0.478549024D0, &
         0.007824D-6,     155.420399434D0, 5.254710405D0, &
         0.004894D-6,    5746.271337896D0, 4.683210850D0, &
         0.004875D-6,    5760.498431898D0, 0.759507698D0, &
         0.004416D-6,    5223.693919802D0, 6.028853166D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=691,700) / &
         0.004088D-6,      -7.113547001D0, 0.060926389D0, &
         0.004433D-6,   77713.771467920D0, 3.627734103D0, &
         0.003277D-6,   18849.227549974D0, 2.327912542D0, &
         0.002703D-6,    6062.663207553D0, 1.271941729D0, &
         0.003435D-6,    -775.522611324D0, 0.747446224D0, &
         0.002618D-6,    6076.890301554D0, 3.633715689D0, &
         0.003146D-6,     206.185548437D0, 5.647874613D0, &
         0.002544D-6,    1577.343542448D0, 6.232904270D0, &
         0.002218D-6,    -220.412642439D0, 1.309509946D0, &
         0.002197D-6,    5856.477659115D0, 2.407212349D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=701,710) / &
         0.002897D-6,    5753.384884897D0, 5.863842246D0, &
         0.001766D-6,     426.598190876D0, 0.754113147D0, &
         0.001738D-6,    -796.298006816D0, 2.714942671D0, &
         0.001695D-6,     522.577418094D0, 2.629369842D0, &
         0.001584D-6,    5507.553238667D0, 1.341138229D0, &
         0.001503D-6,    -242.728603974D0, 0.377699736D0, &
         0.001552D-6,    -536.804512095D0, 2.904684667D0, &
         0.001370D-6,    -398.149003408D0, 1.265599125D0, &
         0.001889D-6,   -5573.142801634D0, 4.413514859D0, &
         0.001722D-6,    6069.776754553D0, 2.445966339D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=711,720) / &
         0.001124D-6,    1059.381930189D0, 5.041799657D0, &
         0.001258D-6,     553.569402842D0, 3.849557278D0, &
         0.000831D-6,     951.718406251D0, 2.471094709D0, &
         0.000767D-6,    4694.002954708D0, 5.363125422D0, &
         0.000756D-6,    1349.867409659D0, 1.046195744D0, &
         0.000775D-6,     -11.045700264D0, 0.245548001D0, &
         0.000597D-6,    2146.165416475D0, 4.543268798D0, &
         0.000568D-6,    5216.580372801D0, 4.178853144D0, &
         0.000711D-6,    1748.016413067D0, 5.934271972D0, &
         0.000499D-6,   12036.460734888D0, 0.624434410D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=721,730) / &
         0.000671D-6,   -1194.447010225D0, 4.136047594D0, &
         0.000488D-6,    5849.364112115D0, 2.209679987D0, &
         0.000621D-6,    6438.496249426D0, 4.518860804D0, &
         0.000495D-6,   -6286.598968340D0, 1.868201275D0, &
         0.000456D-6,    5230.807466803D0, 1.271231591D0, &
         0.000451D-6,    5088.628839767D0, 0.084060889D0, &
         0.000435D-6,    5643.178563677D0, 3.324456609D0, &
         0.000387D-6,   10977.078804699D0, 4.052488477D0, &
         0.000547D-6,  161000.685737473D0, 2.841633844D0, &
         0.000522D-6,    3154.687084896D0, 2.171979966D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=731,740) / &
         0.000375D-6,    5486.777843175D0, 4.983027306D0, &
         0.000421D-6,    5863.591206116D0, 4.546432249D0, &
         0.000439D-6,    7084.896781115D0, 0.522967921D0, &
         0.000309D-6,    2544.314419883D0, 3.172606705D0, &
         0.000347D-6,    4690.479836359D0, 1.479586566D0, &
         0.000317D-6,     801.820931124D0, 3.553088096D0, &
         0.000262D-6,     419.484643875D0, 0.606635550D0, &
         0.000248D-6,    6836.645252834D0, 3.014082064D0, &
         0.000245D-6,   -1592.596013633D0, 5.519526220D0, &
         0.000225D-6,    4292.330832950D0, 2.877956536D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=741,750) / &
         0.000214D-6,    7234.794256242D0, 1.605227587D0, &
         0.000205D-6,    5767.611978898D0, 0.625804796D0, &
         0.000180D-6,   10447.387839604D0, 3.499954526D0, &
         0.000229D-6,     199.072001436D0, 5.632304604D0, &
         0.000214D-6,     639.897286314D0, 5.960227667D0, &
         0.000175D-6,    -433.711737877D0, 2.162417992D0, &
         0.000209D-6,     515.463871093D0, 2.322150893D0, &
         0.000173D-6,    6040.347246017D0, 2.556183691D0, &
         0.000184D-6,    6309.374169791D0, 4.732296790D0, &
         0.000227D-6,  149854.400134205D0, 5.385812217D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=751,760) / &
         0.000154D-6,    8031.092263058D0, 5.120720920D0, &
         0.000151D-6,    5739.157790895D0, 4.815000443D0, &
         0.000197D-6,    7632.943259650D0, 0.222827271D0, &
         0.000197D-6,      74.781598567D0, 3.910456770D0, &
         0.000138D-6,    6055.549660552D0, 1.397484253D0, &
         0.000149D-6,   -6127.655450557D0, 5.333727496D0, &
         0.000137D-6,    3894.181829542D0, 4.281749907D0, &
         0.000135D-6,    9437.762934887D0, 5.979971885D0, &
         0.000139D-6,   -2352.866153772D0, 4.715630782D0, &
         0.000142D-6,    6812.766815086D0, 0.513330157D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=761,770) / &
         0.000120D-6,   -4705.732307544D0, 0.194160689D0, &
         0.000131D-6,  -71430.695617928D0, 0.000379226D0, &
         0.000124D-6,    6279.552731642D0, 2.122264908D0, &
         0.000108D-6,   -6256.777530192D0, 0.883445696D0, &
         0.143388D-6,    6283.075849991D0, 1.131453581D0, &
         0.006671D-6,   12566.151699983D0, 0.775148887D0, &
         0.001480D-6,     155.420399434D0, 0.480016880D0, &
         0.000934D-6,     213.299095438D0, 6.144453084D0, &
         0.000795D-6,     529.690965095D0, 2.941595619D0, &
         0.000673D-6,    5746.271337896D0, 0.120415406D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=771,780) / &
         0.000672D-6,    5760.498431898D0, 5.317009738D0, &
         0.000389D-6,    -220.412642439D0, 3.090323467D0, &
         0.000373D-6,    6062.663207553D0, 3.003551964D0, &
         0.000360D-6,    6076.890301554D0, 1.918913041D0, &
         0.000316D-6,     -21.340641002D0, 5.545798121D0, &
         0.000315D-6,    -242.728603974D0, 1.884932563D0, &
         0.000278D-6,     206.185548437D0, 1.266254859D0, &
         0.000238D-6,    -536.804512095D0, 4.532664830D0, &
         0.000185D-6,     522.577418094D0, 4.578313856D0, &
         0.000245D-6,   18849.227549974D0, 0.587467082D0 /
      DATA ((FAIRHD(I,J),I=1,3),J=781,787) / &
         0.000180D-6,     426.598190876D0, 5.151178553D0, &
         0.000200D-6,     553.569402842D0, 5.355983739D0, &
         0.000141D-6,    5223.693919802D0, 1.336556009D0, &
         0.000104D-6,    5856.477659115D0, 4.239842759D0, &
         0.003826D-6,    6283.075849991D0, 5.705257275D0, &
         0.000303D-6,   12566.151699983D0, 5.407132842D0, &
         0.000209D-6,     155.420399434D0, 1.989815753D0 /
! -----------------------------------------------------------------------



!  Time since J2000.0 in Julian millennia.
      T=(TDB-51544.5D0)/365250D0

! -------------------- Topocentric terms -------------------------------

!  Convert UT1 to local solar time in radians.
      TSOL = MOD(UT1,1D0)*D2PI - WL

!  FUNDAMENTAL ARGUMENTS:  Simon et al 1994

!  Combine time argument (millennia) with deg/arcsec factor.
      W = T / 3600D0

!  Sun Mean Longitude.
      ELSUN = MOD(280.46645683D0+1296027711.03429D0*W,360D0)*D2R

!  Sun Mean Anomaly.
      EMSUN = MOD(357.52910918D0+1295965810.481D0*W,360D0)*D2R

!  Mean Elongation of Moon from Sun.
      D = MOD(297.85019547D0+16029616012.090D0*W,360D0)*D2R

!  Mean Longitude of Jupiter.
      ELJ = MOD(34.35151874D0+109306899.89453D0*W,360D0)*D2R

!  Mean Longitude of Saturn.
      ELS = MOD(50.07744430D0+44046398.47038D0*W,360D0)*D2R

!  TOPOCENTRIC TERMS:  Moyer 1981 and Murray 1983.
 
      WTT =  0.00029D-10*U*SIN(TSOL+ELSUN-ELS) &
           + 0.00100D-10*U*SIN(TSOL-2D0*EMSUN) &
           + 0.00133D-10*U*SIN(TSOL-D) &
           + 0.00133D-10*U*SIN(TSOL+ELSUN-ELJ) &
           - 0.00229D-10*U*SIN(TSOL+2D0*ELSUN+EMSUN) &
           - 0.02200D-10*V*COS(ELSUN+EMSUN) &
           + 0.05312D-10*U*SIN(TSOL-EMSUN) &
           - 0.13677D-10*U*SIN(TSOL+2D0*ELSUN) &
           - 1.31840D-10*V*COS(ELSUN) &
           + 3.17679D-10*U*SIN(TSOL)

! --------------- Fairhead model ---------------------------------------

!  T**0
      W0=0D0
      DO I=474,1,-1
         W0=W0+FAIRHD(1,I)*SIN(FAIRHD(2,I)*T+FAIRHD(3,I))
      END DO

!  T**1
      W1=0D0
      DO I=679,475,-1
         W1=W1+FAIRHD(1,I)*SIN(FAIRHD(2,I)*T+FAIRHD(3,I))
      END DO

!  T**2
      W2=0D0
      DO I=764,680,-1
         W2=W2+FAIRHD(1,I)*SIN(FAIRHD(2,I)*T+FAIRHD(3,I))
      END DO

!  T**3
      W3=0D0
      DO I=784,765,-1
         W3=W3+FAIRHD(1,I)*SIN(FAIRHD(2,I)*T+FAIRHD(3,I))
      END DO

!  T**4
      W4=0D0
      DO I=787,785,-1
         W4=W4+FAIRHD(1,I)*SIN(FAIRHD(2,I)*T+FAIRHD(3,I))
      END DO

!  Multiply by powers of T and combine.
      WF=T*(T*(T*(T*W4+W3)+W2)+W1)+W0

!  Adjustments to use JPL planetary masses instead of IAU.
      WJ=     0.00065D-6  * SIN(   6069.776754D0   *T + 4.021194D0   ) + &
             0.00033D-6  * SIN(    213.299095D0   *T + 5.543132D0   ) + &
           (-0.00196D-6  * SIN(   6208.294251D0   *T + 5.696701D0   ))+ &
           (-0.00173D-6  * SIN(     74.781599D0   *T + 2.435900D0   ))+ &
             0.03638D-6*T*T

! -----------------------------------------------------------------------

!  Final result:  TDB-TT in seconds.
      sla_RCC=WTT+WF+WJ

      END
      SUBROUTINE sla_RDPLAN (DATE, NP, ELONG, PHI, RA, DEC, DIAM)
!+
!     - - - - - - -
!      R D P L A N
!     - - - - - - -
!
!  Approximate topocentric apparent RA,Dec of a planet, and its
!  angular diameter.
!
!  Given:
!     DATE        d       MJD of observation (JD - 2400000.5)
!     NP          i       planet: 1 = Mercury
!                                 2 = Venus
!                                 3 = Moon
!                                 4 = Mars
!                                 5 = Jupiter
!                                 6 = Saturn
!                                 7 = Uranus
!                                 8 = Neptune
!                                 9 = Pluto
!                              else = Sun
!     ELONG,PHI   d       observer's east longitude and geodetic
!                                               latitude (radians)
!
!  Returned:
!     RA,DEC      d        RA, Dec (topocentric apparent, radians)
!     DIAM        d        angular diameter (equatorial, radians)
!
!  Notes:
!
!  1  The date is in a dynamical timescale (TDB, formerly ET) and is
!     in the form of a Modified Julian Date (JD-2400000.5).  For all
!     practical purposes, TT can be used instead of TDB, and for many
!     applications UT will do (except for the Moon).
!
!  2  The longitude and latitude allow correction for geocentric
!     parallax.  This is a major effect for the Moon, but in the
!     context of the limited accuracy of the present routine its
!     effect on planetary positions is small (negligible for the
!     outer planets).  Geocentric positions can be generated by
!     appropriate use of the routines sla_DMOON and sla_PLANET.
!
!  3  The direction accuracy (arcsec, 1000-3000AD) is of order:
!
!            Sun              5
!            Mercury          2
!            Venus           10
!            Moon            30
!            Mars            50
!            Jupiter         90
!            Saturn          90
!            Uranus          90
!            Neptune         10
!            Pluto            1   (1885-2099AD only)
!
!     The angular diameter accuracy is about 0.4% for the Moon,
!     and 0.01% or better for the Sun and planets.
!
!  See the sla_PLANET routine for references.
!
!  Called: sla_GMST, sla_DT, sla_EPJ, sla_DMOON, sla_PVOBS, sla_PRENUT,
!          sla_PLANET, sla_DMXV, sla_DCC2S, sla_DRANRM
!
!  P.T.Wallace   Starlink   26 May 1997
!
!  Copyright (C) 1997 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE
      INTEGER NP
      DOUBLE PRECISION ELONG,PHI,RA,DEC,DIAM

!  AU in km
      DOUBLE PRECISION AUKM
      PARAMETER (AUKM=1.49597870D8)

!  Light time for unit distance (sec)
      DOUBLE PRECISION TAU
      PARAMETER (TAU=499.004782D0)

      INTEGER IP,J,I
      DOUBLE PRECISION EQRAU(0:9),STL,VGM(6),V(6),RMAT(3,3), &
                      VSE(6),VSG(6),VSP(6),VGO(6),DX,DY,DZ,R,TL
      DOUBLE PRECISION sla_GMST,sla_DT,sla_EPJ,sla_DRANRM

!  Equatorial radii (km)
      DATA EQRAU / 696000D0,2439.7D0,6051.9D0,1738D0,3397D0,71492D0, &
                  60268D0,25559D0,24764D0,1151D0 /



!  Classify NP
      IP=NP
      IF (IP.LT.0.OR.IP.GT.9) IP=0

!  Approximate local ST
      STL=sla_GMST(DATE-sla_DT(sla_EPJ(DATE))/86400D0)+ELONG

!  Geocentre to Moon (mean of date)
      CALL sla_DMOON(DATE,V)

!  Nutation to true of date
      CALL sla_NUT(DATE,RMAT)
      CALL sla_DMXV(RMAT,V,VGM)
      CALL sla_DMXV(RMAT,V(4),VGM(4))

!  Moon?
      IF (IP.EQ.3) THEN

!     Yes: geocentre to Moon (true of date)
         DO I=1,6
            V(I)=VGM(I)
         END DO
      ELSE

!     No: precession/nutation matrix, J2000 to date
         CALL sla_PRENUT(2000D0,DATE,RMAT)

!     Sun to Earth-Moon Barycentre (J2000)
         CALL sla_PLANET(DATE,3,V,J)

!     Precession and nutation to date
         CALL sla_DMXV(RMAT,V,VSE)
         CALL sla_DMXV(RMAT,V(4),VSE(4))

!     Sun to geocentre (true of date)
         DO I=1,6
            VSG(I)=VSE(I)-0.012150581D0*VGM(I)
         END DO

!     Sun?
         IF (IP.EQ.0) THEN

!        Yes: geocentre to Sun
            DO I=1,6
               V(I)=-VSG(I)
            END DO
         ELSE

!        No: Sun to Planet (J2000)
            CALL sla_PLANET(DATE,IP,V,J)

!        Precession and nutation to date
            CALL sla_DMXV(RMAT,V,VSP)
            CALL sla_DMXV(RMAT,V(4),VSP(4))

!        Geocentre to planet
            DO I=1,6
               V(I)=VSP(I)-VSG(I)
            END DO
         END IF
      END IF

!  Refer to origin at the observer
      CALL sla_PVOBS(PHI,0D0,STL,VGO)
      DO I=1,6
         V(I)=V(I)-VGO(I)
      END DO

!  Geometric distance (AU)
      DX=V(1)
      DY=V(2)
      DZ=V(3)
      R=SQRT(DX*DX+DY*DY+DZ*DZ)

!  Light time (sec)
      TL=TAU*R

!  Correct position for planetary aberration
      DO I=1,3
         V(I)=V(I)-TL*V(I+3)
      END DO

!  To RA,Dec
      CALL sla_DCC2S(V,RA,DEC)
      RA=sla_DRANRM(RA)

!  Angular diameter (radians)
      DIAM=2D0*ASIN(EQRAU(IP)/(R*AUKM))

      END
      SUBROUTINE sla_REFCO (HM, TDK, PMB, RH, WL, PHI, TLR, EPS, &
                           REFA, REFB)
!+
!     - - - - - -
!      R E F C O
!     - - - - - -
!
!  Determine the constants A and B in the atmospheric refraction
!  model dZ = A tan Z + B tan**3 Z.
!
!  Z is the "observed" zenith distance (i.e. affected by refraction)
!  and dZ is what to add to Z to give the "topocentric" (i.e. in vacuo)
!  zenith distance.
!
!  Given:
!    HM      d     height of the observer above sea level (metre)
!    TDK     d     ambient temperature at the observer (deg K)
!    PMB     d     pressure at the observer (millibar)
!    RH      d     relative humidity at the observer (range 0-1)
!    WL      d     effective wavelength of the source (micrometre)
!    PHI     d     latitude of the observer (radian, astronomical)
!    TLR     d     temperature lapse rate in the troposphere (degK/metre)
!    EPS     d     precision required to terminate iteration (radian)
!
!  Returned:
!    REFA    d     tan Z coefficient (radian)
!    REFB    d     tan**3 Z coefficient (radian)
!
!  Called:  sla_REFRO
!
!  Notes:
!
!  1  Typical values for the TLR and EPS arguments might be 0.0065D0 and
!     1D-10 respectively.
!
!  2  The radio refraction is chosen by specifying WL > 100 micrometres.
!
!  3  The routine is a slower but more accurate alternative to the
!     sla_REFCOQ routine.  The constants it produces give perfect
!     agreement with sla_REFRO at zenith distances arctan(1) (45 deg)
!     and arctan(4) (about 76 deg).  It achieves 0.5 arcsec accuracy
!     for ZD < 80 deg, 0.01 arcsec accuracy for ZD < 60 deg, and
!     0.001 arcsec accuracy for ZD < 45 deg.
!
!  P.T.Wallace   Starlink   3 June 1997
!
!  Copyright (C) 1997 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION HM,TDK,PMB,RH,WL,PHI,TLR,EPS,REFA,REFB

      DOUBLE PRECISION ATN1,ATN4,R1,R2

!  Sample zenith distances: arctan(1) and arctan(4)
      PARAMETER (ATN1=0.7853981633974483D0, &
                ATN4=1.325817663668033D0)



!  Determine refraction for the two sample zenith distances
      CALL sla_REFRO(ATN1,HM,TDK,PMB,RH,WL,PHI,TLR,EPS,R1)
      CALL sla_REFRO(ATN4,HM,TDK,PMB,RH,WL,PHI,TLR,EPS,R2)

!  Solve for refraction constants
      REFA = (64D0*R1-R2)/60D0
      REFB = (R2-4D0*R1)/60D0

      END
      SUBROUTINE sla_REFCOQ (TDK, PMB, RH, WL, REFA, REFB)
!+
!     - - - - - - -
!      R E F C O Q
!     - - - - - - -
!
!  Determine the constants A and B in the atmospheric refraction
!  model dZ = A tan Z + B tan**3 Z.  This is a fast alternative
!  to the sla_REFCO routine - see notes.
!
!  Z is the "observed" zenith distance (i.e. affected by refraction)
!  and dZ is what to add to Z to give the "topocentric" (i.e. in vacuo)
!  zenith distance.
!
!  Given:
!    TDK      d      ambient temperature at the observer (deg K)
!    PMB      d      pressure at the observer (millibar)
!    RH       d      relative humidity at the observer (range 0-1)
!    WL       d      effective wavelength of the source (micrometre)
!
!  Returned:
!    REFA     d      tan Z coefficient (radian)
!    REFB     d      tan**3 Z coefficient (radian)
!
!  The radio refraction is chosen by specifying WL > 100 micrometres.
!
!  Notes:
!
!  1  The model is an approximation, for moderate zenith distances,
!     to the predictions of the sla_REFRO routine.  The approximation
!     is maintained across a range of conditions, and applies to
!     both optical/IR and radio.
!
!  2  The algorithm is a fast alternative to the sla_REFCO routine.
!     The latter calls the sla_REFRO routine itself:  this involves
!     integrations through a model atmosphere, and is costly in
!     processor time.  However, the model which is produced is precisely
!     correct for two zenith distance (45 degrees and about 76 degrees)
!     and at other zenith distances is limited in accuracy only by the
!     A tan Z + B tan**3 Z formulation itself.  The present routine
!     is not as accurate, though it satisfies most practical
!     requirements.
!
!  3  The model omits the effects of (i) height above sea level (apart
!     from the reduced pressure itself), (ii) latitude (i.e. the
!     flattening of the Earth) and (iii) variations in tropospheric
!     lapse rate.
!
!     The model was tested using the following range of conditions:
!
!       lapse rates 0.0055, 0.0065, 0.0075 deg/metre
!       latitudes 0, 25, 50, 75 degrees
!       heights 0, 2500, 5000 metres ASL
!       pressures mean for height -10% to +5% in steps of 5%
!       temperatures -10 deg to +20 deg with respect to 280 deg at SL
!       relative humidity 0, 0.5, 1
!       wavelengths 0.4, 0.6, ... 2 micron, + radio
!       zenith distances 15, 45, 75 degrees
!
!     The accuracy with respect to direct use of the sla_REFRO routine
!     was as follows:
!
!                            worst         RMS
!
!       optical/IR           62 mas       8 mas
!       radio               319 mas      49 mas
!
!     For this particular set of conditions:
!
!       lapse rate 0.0065 degK/metre
!       latitude 50 degrees
!       sea level
!       pressure 1005 mB
!       temperature 280.15 degK
!       humidity 80%
!       wavelength 5740 Angstroms
!
!     the results were as follows:
!
!       ZD        sla_REFRO   sla_REFCOQ  Saastamoinen
!
!       10         10.27        10.27        10.27
!       20         21.19        21.20        21.19
!       30         33.61        33.61        33.60
!       40         48.82        48.83        48.81
!       45         58.16        58.18        58.16
!       50         69.28        69.30        69.27
!       55         82.97        82.99        82.95
!       60        100.51       100.54       100.50
!       65        124.23       124.26       124.20
!       70        158.63       158.68       158.61
!       72        177.32       177.37       177.31
!       74        200.35       200.38       200.32
!       76        229.45       229.43       229.42
!       78        267.44       267.29       267.41
!       80        319.13       318.55       319.10
!
!      deg        arcsec       arcsec       arcsec
!
!     The values for Saastamoinen's formula (which includes terms
!     up to tan^5) are taken from Hohenkerk and Sinclair (1985).
!
!     The results from the much slower but more accurate sla_REFCO
!     routine have not been included in the tabulation as they are
!     identical to those in the sla_REFRO column to the 0.01 arcsec
!     resolution used.
!
!  4  Outlandish input parameters are silently limited to mathematically
!     safe values.  Zero pressure is permissible, and causes zeroes to
!     be returned.
!
!  5  The algorithm draws on several sources, as follows:
!
!     a) The formula for the saturation vapour pressure of water as
!        a function of temperature and temperature is taken from
!        expressions A4.5-A4.7 of Gill (1982).
!
!     b) The formula for the water vapour pressure, given the
!        saturation pressure and the relative humidity, is from
!        Crane (1976), expression 2.5.5.
!
!     c) The refractivity of air is a function of temperature,
!        total pressure, water-vapour pressure and, in the case
!        of optical/IR but not radio, wavelength.  The formulae
!        for the two cases are developed from Hohenkerk & Sinclair
!        (1985) and Rueger (2002).
!
!     The above three items are as used in the sla_REFRO routine.
!
!     d) The formula for beta, the ratio of the scale height of the
!        atmosphere to the geocentric distance of the observer, is
!        an adaption of expression 9 from Stone (1996).  The
!        adaptations, arrived at empirically, consist of (i) a
!        small adjustment to the coefficient and (ii) a humidity
!        term for the radio case only.
!
!     e) The formulae for the refraction constants as a function of
!        n-1 and beta are from Green (1987), expression 4.31.
!
!  References:
!
!     Crane, R.K., Meeks, M.L. (ed), "Refraction Effects in the Neutral
!     Atmosphere", Methods of Experimental Physics: Astrophysics 12B,
!     Academic Press, 1976.
!
!     Gill, Adrian E., "Atmosphere-Ocean Dynamics", Academic Press, 1982.
!
!     Green, R.M., "Spherical Astronomy", Cambridge University Press, 1987.
!
!     Hohenkerk, C.Y., & Sinclair, A.T., NAO Technical Note No. 63, 1985.
!
!     Rueger, J.M., "Refractive Index Formulae for Electronic Distance
!     Measurement with Radio and Millimetre Waves", in Unisurv Report
!     S-68, School of Surveying and Spatial Information Systems,
!     University of New South Wales, Sydney, Australia, 2002.
!
!     Stone, Ronald C., P.A.S.P. 108 1051-1058, 1996.
!
!  P.T.Wallace   Starlink   23 May 2002
!
!  Copyright (C) 2002 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION TDK,PMB,RH,WL,REFA,REFB

      LOGICAL OPTIC
      DOUBLE PRECISION T,P,R,W,TDC,PS,PW,WLSQ,GAMMA,BETA



!  Decide whether optical/IR or radio case:  switch at 100 microns.
      OPTIC = WL.LE.100D0

!  Restrict parameters to safe values.
      T = MIN(MAX(TDK,100D0),500D0)
      P = MIN(MAX(PMB,0D0),10000D0)
      R = MIN(MAX(RH,0D0),1D0)
      W = MIN(MAX(WL,0.1D0),1D6)

!  Water vapour pressure at the observer.
      IF (P.GT.0D0) THEN
         TDC = T-273.15D0
         PS = 10D0**((0.7859D0+0.03477D0*TDC)/(1D0+0.00412D0*TDC))* &
                                         (1D0+P*(4.5D-6+6D-10*TDC*TDC))
         PW = R*PS/(1D0-(1D0-R)*PS/P)
      ELSE
         PW = 0D0
      END IF

!  Refractive index minus 1 at the observer.
      IF (OPTIC) THEN
         WLSQ = W*W
         GAMMA = ((77.532D-6+(4.391D-7+3.57D-9/WLSQ)/WLSQ)*P &
                                                      -11.2684D-6*PW)/T
      ELSE
         GAMMA = (77.6890D-6*P-(6.3938D-6-0.375463D0/T)*PW)/T
      END IF

!  Formula for beta adapted from Stone, with empirical adjustments.
      BETA=4.4474D-6*T
      IF (.NOT.OPTIC) BETA=BETA-0.0074D0*PW*BETA

!  Refraction constants from Green.
      REFA = GAMMA*(1D0-BETA)
      REFB = -GAMMA*(BETA-GAMMA/2D0)

      END
      SUBROUTINE sla_REFRO (ZOBS, HM, TDK, PMB, RH, WL, PHI, TLR, &
                           EPS, REF)
!+
!     - - - - - -
!      R E F R O
!     - - - - - -
!
!  Atmospheric refraction for radio and optical/IR wavelengths.
!
!  Given:
!    ZOBS    d  observed zenith distance of the source (radian)
!    HM      d  height of the observer above sea level (metre)
!    TDK     d  ambient temperature at the observer (deg K)
!    PMB     d  pressure at the observer (millibar)
!    RH      d  relative humidity at the observer (range 0-1)
!    WL      d  effective wavelength of the source (micrometre)
!    PHI     d  latitude of the observer (radian, astronomical)
!    TLR     d  temperature lapse rate in the troposphere (K/metre)
!    EPS     d  precision required to terminate iteration (radian)
!
!  Returned:
!    REF     d  refraction: in vacuo ZD minus observed ZD (radian)
!
!  Notes:
!
!  1  A suggested value for the TLR argument is 0.0065D0.  The
!     refraction is significantly affected by TLR, and if studies
!     of the local atmosphere have been carried out a better TLR
!     value may be available.  The sign of the supplied TLR value
!     is ignored.
!
!  2  A suggested value for the EPS argument is 1D-8.  The result is
!     usually at least two orders of magnitude more computationally
!     precise than the supplied EPS value.
!
!  3  The routine computes the refraction for zenith distances up
!     to and a little beyond 90 deg using the method of Hohenkerk
!     and Sinclair (NAO Technical Notes 59 and 63, subsequently adopted
!     in the Explanatory Supplement, 1992 edition - see section 3.281).
!
!  4  The code is a development of the optical/IR refraction subroutine
!     AREF of C.Hohenkerk (HMNAO, September 1984), with extensions to
!     support the radio case.  Apart from merely cosmetic changes, the
!     following modifications to the original HMNAO optical/IR refraction
!     code have been made:
!
!     .  The angle arguments have been changed to radians.
!
!     .  Any value of ZOBS is allowed (see note 6, below).
!
!     .  Other argument values have been limited to safe values.
!
!     .  Murray's values for the gas constants have been used
!        (Vectorial Astrometry, Adam Hilger, 1983).
!
!     .  The numerical integration phase has been rearranged for
!        extra clarity.
!
!     .  A better model for Ps(T) has been adopted (taken from
!        Gill, Atmosphere-Ocean Dynamics, Academic Press, 1982).
!
!     .  More accurate expressions for Pwo have been adopted
!        (again from Gill 1982).
!
!     .  Provision for radio wavelengths has been added using
!        expressions devised by A.T.Sinclair, RGO (private
!        communication 1989).  The refractivity model currently
!        used is from J.M.Rueger, "Refractive Index Formulae for
!        Electronic Distance Measurement with Radio and Millimetre
!        Waves", in Unisurv Report S-68 (2002), School of Surveying
!        and Spatial Information Systems, University of New South
!        Wales, Sydney, Australia.
!
!     .  Various small changes have been made to gain speed.
!
!     None of the changes significantly affects the optical/IR results
!     with respect to the algorithm given in the 1992 Explanatory
!     Supplement.  For example, at 70 deg zenith distance the present
!     routine agrees with the ES algorithm to better than 0.05 arcsec
!     for any reasonable combination of parameters.  However, the
!     improved water-vapour expressions do make a significant difference
!     in the radio band, at 70 deg zenith distance reaching almost
!     4 arcsec for a hot, humid, low-altitude site during a period of
!     low pressure.
!
!  5  The radio refraction is chosen by specifying WL > 100 micrometres.
!     Because the algorithm takes no account of the ionosphere, the
!     accuracy deteriorates at low frequencies, below about 30 MHz.
!
!  6  Before use, the value of ZOBS is expressed in the range +/- pi.
!     If this ranged ZOBS is -ve, the result REF is computed from its
!     absolute value before being made -ve to match.  In addition, if
!     it has an absolute value greater than 93 deg, a fixed REF value
!     equal to the result for ZOBS = 93 deg is returned, appropriately
!     signed.
!
!  7  As in the original Hohenkerk and Sinclair algorithm, fixed values
!     of the water vapour polytrope exponent, the height of the
!     tropopause, and the height at which refraction is negligible are
!     used.
!
!  8  The radio refraction has been tested against work done by
!     Iain Coulson, JACH, (private communication 1995) for the
!     James Clerk Maxwell Telescope, Mauna Kea.  For typical conditions,
!     agreement at the 0.1 arcsec level is achieved for moderate ZD,
!     worsening to perhaps 0.5-1.0 arcsec at ZD 80 deg.  At hot and
!     humid sea-level sites the accuracy will not be as good.
!
!  9  It should be noted that the relative humidity RH is formally
!     defined in terms of "mixing ratio" rather than pressures or
!     densities as is often stated.  It is the mass of water per unit
!     mass of dry air divided by that for saturated air at the same
!     temperature and pressure (see Gill 1982).
!
!  10 The algorithm is designed for observers in the troposphere.  The
!     supplied temperature, pressure and lapse rate are assumed to be
!     for a point in the troposphere and are used to define a model
!     atmosphere with the tropopause at 11km altitude and a constant
!     temperature above that.  However, in practice, the refraction
!     values returned for stratospheric observers, at altitudes up to
!     25km, are quite usable.
!
!  Called:  sla_DRANGE, sla__ATMT, sla__ATMS
!
!  P.T.Wallace   Starlink   28 May 2002
!
!  Copyright (C) 2002 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION ZOBS,HM,TDK,PMB,RH,WL,PHI,TLR,EPS,REF

!
!  Fixed parameters
!
      DOUBLE PRECISION D93,GCR,DMD,DMW,S,DELTA,HT,HS
      INTEGER ISMAX
!  93 degrees in radians
      PARAMETER (D93=1.623156204D0)
!  Universal gas constant
      PARAMETER (GCR=8314.32D0)
!  Molecular weight of dry air
      PARAMETER (DMD=28.9644D0)
!  Molecular weight of water vapour
      PARAMETER (DMW=18.0152D0)
!  Mean Earth radius (metre)
      PARAMETER (S=6378120D0)
!  Exponent of temperature dependence of water vapour pressure
      PARAMETER (DELTA=18.36D0)
!  Height of tropopause (metre)
      PARAMETER (HT=11000D0)
!  Upper limit for refractive effects (metre)
      PARAMETER (HS=80000D0)
!  Numerical integration: maximum number of strips.
      PARAMETER (ISMAX=16384)

      INTEGER IS,K,N,I,J
      LOGICAL OPTIC,LOOP
      DOUBLE PRECISION ZOBS1,ZOBS2,HMOK,TDKOK,PMBOK,RHOK,WLOK,ALPHA, &
                      TOL,WLSQ,GB,A,GAMAL,GAMMA,GAMM2,DELM2, &
                      TDC,PSAT,PWO,W, &
                      C1,C2,C3,C4,C5,C6,R0,TEMPO,DN0,RDNDR0,SK0,F0, &
                      RT,TT,DNT,RDNDRT,SINE,ZT,FT,DNTS,RDNDRP,ZTS,FTS, &
                      RS,DNS,RDNDRS,ZS,FS,REFOLD,Z0,ZRANGE,FB,FF,FO,FE, &
                      H,R,SZ,RG,DR,TG,DN,RDNDR,T,F,REFP,REFT

      DOUBLE PRECISION sla_DRANGE

!  The refraction integrand
      DOUBLE PRECISION REFI
      REFI(DN,RDNDR) = RDNDR/(DN+RDNDR)



!  Transform ZOBS into the normal range.
      ZOBS1 = sla_DRANGE(ZOBS)
      ZOBS2 = MIN(ABS(ZOBS1),D93)

!  Keep other arguments within safe bounds.
      HMOK = MIN(MAX(HM,-1D3),HS)
      TDKOK = MIN(MAX(TDK,100D0),500D0)
      PMBOK = MIN(MAX(PMB,0D0),10000D0)
      RHOK = MIN(MAX(RH,0D0),1D0)
      WLOK = MAX(WL,0.1D0)
      ALPHA = MIN(MAX(ABS(TLR),0.001D0),0.01D0)

!  Tolerance for iteration.
      TOL = MIN(MAX(ABS(EPS),1D-12),0.1D0)/2D0

!  Decide whether optical/IR or radio case - switch at 100 microns.
      OPTIC = WLOK.LE.100D0

!  Set up model atmosphere parameters defined at the observer.
      WLSQ = WLOK*WLOK
      GB = 9.784D0*(1D0-0.0026D0*COS(PHI+PHI)-0.00000028D0*HMOK)
      IF (OPTIC) THEN
         A = (287.604D0+(1.6288D0+0.0136D0/WLSQ)/WLSQ) &
                                                   *273.15D-6/1013.25D0
      ELSE
         A = 77.6890D-6
      END IF
      GAMAL = (GB*DMD)/GCR
      GAMMA = GAMAL/ALPHA
      GAMM2 = GAMMA-2D0
      DELM2 = DELTA-2D0
      TDC = TDKOK-273.15D0
      PSAT = 10D0**((0.7859D0+0.03477D0*TDC)/(1D0+0.00412D0*TDC))* &
                                     (1D0+PMBOK*(4.5D-6+6D-10*TDC*TDC))
      IF (PMBOK.GT.0D0) THEN
         PWO = RHOK*PSAT/(1D0-(1D0-RHOK)*PSAT/PMBOK)
      ELSE
         PWO = 0D0
      END IF
      W = PWO*(1D0-DMW/DMD)*GAMMA/(DELTA-GAMMA)
      C1 = A*(PMBOK+W)/TDKOK
      IF (OPTIC) THEN
         C2 = (A*W+11.2684D-6*PWO)/TDKOK
      ELSE
         C2 = (A*W+6.3938D-6*PWO)/TDKOK
      END IF
      C3 = (GAMMA-1D0)*ALPHA*C1/TDKOK
      C4 = (DELTA-1D0)*ALPHA*C2/TDKOK
      IF (OPTIC) THEN
         C5 = 0D0
         C6 = 0D0
      ELSE
         C5 = 375463D-6*PWO/TDKOK
         C6 = C5*DELM2*ALPHA/(TDKOK*TDKOK)
      END IF

!  Conditions at the observer.
      R0 = S+HMOK
      CALL sla__ATMT(R0,TDKOK,ALPHA,GAMM2,DELM2,C1,C2,C3,C4,C5,C6, &
                                                   R0,TEMPO,DN0,RDNDR0)
      SK0 = DN0*R0*SIN(ZOBS2)
      F0 = REFI(DN0,RDNDR0)

!  Conditions in the troposphere at the tropopause.
      RT = S+MAX(HT,HMOK)
      CALL sla__ATMT(R0,TDKOK,ALPHA,GAMM2,DELM2,C1,C2,C3,C4,C5,C6, &
                                                      RT,TT,DNT,RDNDRT)
      SINE = SK0/(RT*DNT)
      ZT = ATAN2(SINE,SQRT(MAX(1D0-SINE*SINE,0D0)))
      FT = REFI(DNT,RDNDRT)

!  Conditions in the stratosphere at the tropopause.
      CALL sla__ATMS(RT,TT,DNT,GAMAL,RT,DNTS,RDNDRP)
      SINE = SK0/(RT*DNTS)
      ZTS = ATAN2(SINE,SQRT(MAX(1D0-SINE*SINE,0D0)))
      FTS = REFI(DNTS,RDNDRP)

!  Conditions at the stratosphere limit.
      RS = S+HS
      CALL sla__ATMS(RT,TT,DNT,GAMAL,RS,DNS,RDNDRS)
      SINE = SK0/(RS*DNS)
      ZS = ATAN2(SINE,SQRT(MAX(1D0-SINE*SINE,0D0)))
      FS = REFI(DNS,RDNDRS)

!
!  Integrate the refraction integral in two parts;  first in the
!  troposphere (K=1), then in the stratosphere (K=2).
!
      DO K = 1,2

!     Initialize previous refraction to ensure at least two iterations.
         REFOLD = 1D0

!     Start off with 8 strips.
         IS = 8

!     Start Z, Z range, and start and end values.
         IF (K.EQ.1) THEN
            Z0 = ZOBS2
            ZRANGE = ZT-Z0
            FB = F0
            FF = FT
         ELSE
            Z0 = ZTS
            ZRANGE = ZS-Z0
            FB = FTS
            FF = FS
         END IF

!     Sums of odd and even values.
         FO = 0D0
         FE = 0D0

!     First time through the loop we have to do every point.
         N = 1

!     Start of iteration loop (terminates at specified precision).
         LOOP = .TRUE.
         DO WHILE (LOOP)

!        Strip width.
            H = ZRANGE/DBLE(IS)

!        Initialize distance from Earth centre for quadrature pass.
            IF (K.EQ.1) THEN
               R = R0
            ELSE
               R = RT
            END IF

!        One pass (no need to compute evens after first time).
            DO I=1,IS-1,N

!           Sine of observed zenith distance.
               SZ = SIN(Z0+H*DBLE(I))

!           Find R (to the nearest metre, maximum four iterations).
               IF (SZ.GT.1D-20) THEN
                  W = SK0/SZ
                  RG = R
                  DR = 1D6
                  J = 0
                  DO WHILE (ABS(DR).GT.1D0.AND.J.LT.4)
                     J=J+1
                     IF (K.EQ.1) THEN
                        CALL sla__ATMT(R0,TDKOK,ALPHA,GAMM2,DELM2, &
                                      C1,C2,C3,C4,C5,C6,RG,TG,DN,RDNDR)
                     ELSE
                        CALL sla__ATMS(RT,TT,DNT,GAMAL,RG,DN,RDNDR)
                     END IF
                     DR = (RG*DN-W)/(DN+RDNDR)
                     RG = RG-DR
                  END DO
                  R = RG
               END IF

!           Find the refractive index and integrand at R.
               IF (K.EQ.1) THEN
                  CALL sla__ATMT(R0,TDKOK,ALPHA,GAMM2,DELM2, &
                                        C1,C2,C3,C4,C5,C6,R,T,DN,RDNDR)
               ELSE
                  CALL sla__ATMS(RT,TT,DNT,GAMAL,R,DN,RDNDR)
               END IF
               F = REFI(DN,RDNDR)

!           Accumulate odd and (first time only) even values.
               IF (N.EQ.1.AND.MOD(I,2).EQ.0) THEN
                  FE = FE+F
               ELSE
                  FO = FO+F
               END IF
            END DO

!        Evaluate the integrand using Simpson's Rule.
            REFP = H*(FB+4D0*FO+2D0*FE+FF)/3D0

!        Has the required precision been achieved (or can't be)?
            IF (ABS(REFP-REFOLD).GT.TOL.AND.IS.LT.ISMAX) THEN

!           No: prepare for next iteration.

!           Save current value for convergence test.
               REFOLD = REFP

!           Double the number of strips.
               IS = IS+IS

!           Sum of all current values = sum of next pass's even values.
               FE = FE+FO

!           Prepare for new odd values.
               FO = 0D0

!           Skip even values next time.
               N = 2
            ELSE

!           Yes: save troposphere component and terminate the loop.
               IF (K.EQ.1) REFT = REFP
               LOOP = .FALSE.
            END IF
         END DO
      END DO

!  Result.
      REF = REFT+REFP
      IF (ZOBS1.LT.0D0) REF = -REF

      END
      SUBROUTINE sla_REFV (VU, REFA, REFB, VR)
!+
!     - - - - -
!      R E F V
!     - - - - -
!
!  Adjust an unrefracted Cartesian vector to include the effect of
!  atmospheric refraction, using the simple A tan Z + B tan**3 Z
!  model.
!
!  Given:
!    VU    dp    unrefracted position of the source (Az/El 3-vector)
!    REFA  dp    tan Z coefficient (radian)
!    REFB  dp    tan**3 Z coefficient (radian)
!
!  Returned:
!    VR    dp    refracted position of the source (Az/El 3-vector)
!
!  Notes:
!
!  1  This routine applies the adjustment for refraction in the
!     opposite sense to the usual one - it takes an unrefracted
!     (in vacuo) position and produces an observed (refracted)
!     position, whereas the A tan Z + B tan**3 Z model strictly
!     applies to the case where an observed position is to have the
!     refraction removed.  The unrefracted to refracted case is
!     harder, and requires an inverted form of the text-book
!     refraction models;  the algorithm used here is equivalent to
!     one iteration of the Newton-Raphson method applied to the above
!     formula.
!
!  2  Though optimized for speed rather than precision, the present
!     routine achieves consistency with the refracted-to-unrefracted
!     A tan Z + B tan**3 Z model at better than 1 microarcsecond within
!     30 degrees of the zenith and remains within 1 milliarcsecond to
!     beyond ZD 70 degrees.  The inherent accuracy of the model is, of
!     course, far worse than this - see the documentation for sla_REFCO
!     for more information.
!
!  3  At low elevations (below about 3 degrees) the refraction
!     correction is held back to prevent arithmetic problems and
!     wildly wrong results.  Over a wide range of observer heights
!     and corresponding temperatures and pressures, the following
!     levels of accuracy (arcsec) are achieved, relative to numerical
!     integration through a model atmosphere:
!
!              ZD    error
!
!              80      0.4
!              81      0.8
!              82      1.6
!              83      3
!              84      7
!              85     17
!              86     45
!              87    150
!              88    340
!              89    620
!              90   1100
!              91   1900         } relevant only to
!              92   3200         } high-elevation sites
!
!  4  See also the routine sla_REFZ, which performs the adjustment to
!     the zenith distance rather than in Cartesian Az/El coordinates.
!     The present routine is faster than sla_REFZ and, except very low down,
!     is equally accurate for all practical purposes.  However, beyond
!     about ZD 84 degrees sla_REFZ should be used, and for the utmost
!     accuracy iterative use of sla_REFRO should be considered.
!
!  P.T.Wallace   Starlink   26 December 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION VU(3),REFA,REFB,VR(3)

      DOUBLE PRECISION X,Y,Z1,Z,ZSQ,RSQ,R,WB,WT,D,CD,F



!  Initial estimate = unrefracted vector
      X = VU(1)
      Y = VU(2)
      Z1 = VU(3)

!  Keep correction approximately constant below about 3 deg elevation
      Z = MAX(Z1,0.05D0)

!  One Newton-Raphson iteration
      ZSQ = Z*Z
      RSQ = X*X+Y*Y
      R = SQRT(RSQ)
      WB = REFB*RSQ/ZSQ
      WT = (REFA+WB)/(1D0+(REFA+3D0*WB)*(ZSQ+RSQ)/ZSQ)
      D = WT*R/Z
      CD = 1D0-D*D/2D0
      F = CD*(1D0-WT)

!  Post-refraction x,y,z
      VR(1) = X*F
      VR(2) = Y*F
      VR(3) = CD*(Z+D*R)+(Z1-Z)

      END
      SUBROUTINE sla_REFZ (ZU, REFA, REFB, ZR)
!+
!     - - - - -
!      R E F Z
!     - - - - -
!
!  Adjust an unrefracted zenith distance to include the effect of
!  atmospheric refraction, using the simple A tan Z + B tan**3 Z
!  model (plus special handling for large ZDs).
!
!  Given:
!    ZU    dp    unrefracted zenith distance of the source (radian)
!    REFA  dp    tan Z coefficient (radian)
!    REFB  dp    tan**3 Z coefficient (radian)
!
!  Returned:
!    ZR    dp    refracted zenith distance (radian)
!
!  Notes:
!
!  1  This routine applies the adjustment for refraction in the
!     opposite sense to the usual one - it takes an unrefracted
!     (in vacuo) position and produces an observed (refracted)
!     position, whereas the A tan Z + B tan**3 Z model strictly
!     applies to the case where an observed position is to have the
!     refraction removed.  The unrefracted to refracted case is
!     harder, and requires an inverted form of the text-book
!     refraction models;  the formula used here is based on the
!     Newton-Raphson method.  For the utmost numerical consistency
!     with the refracted to unrefracted model, two iterations are
!     carried out, achieving agreement at the 1D-11 arcseconds level
!     for a ZD of 80 degrees.  The inherent accuracy of the model
!     is, of course, far worse than this - see the documentation for
!     sla_REFCO for more information.
!
!  2  At ZD 83 degrees, the rapidly-worsening A tan Z + B tan**3 Z
!     model is abandoned and an empirical formula takes over.  Over a
!     wide range of observer heights and corresponding temperatures and
!     pressures, the following levels of accuracy (arcsec) are
!     typically achieved, relative to numerical integration through a
!     model atmosphere:
!
!              ZR    error
!
!              80      0.4
!              81      0.8
!              82      1.5
!              83      3.2
!              84      4.9
!              85      5.8
!              86      6.1
!              87      7.1
!              88     10
!              89     20
!              90     40
!              91    100         } relevant only to
!              92    200         } high-elevation sites
!
!     The high-ZD model is scaled to match the normal model at the
!     transition point;  there is no glitch.
!
!  3  Beyond 93 deg zenith distance, the refraction is held at its
!     93 deg value.
!
!  4  See also the routine sla_REFV, which performs the adjustment in
!     Cartesian Az/El coordinates, and with the emphasis on speed
!     rather than numerical accuracy.
!
!  P.T.Wallace   Starlink   19 September 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION ZU,REFA,REFB,ZR

!  Radians to degrees
      DOUBLE PRECISION R2D
      PARAMETER (R2D=57.29577951308232D0)

!  Largest usable ZD (deg)
      DOUBLE PRECISION D93
      PARAMETER (D93=93D0)

!  Coefficients for high ZD model (used beyond ZD 83 deg)
      DOUBLE PRECISION C1,C2,C3,C4,C5
      PARAMETER (C1=+0.55445D0, &
                C2=-0.01133D0, &
                C3=+0.00202D0, &
                C4=+0.28385D0, &
                C5=+0.02390D0)

!  ZD at which one model hands over to the other (radians)
      DOUBLE PRECISION Z83
      PARAMETER (Z83=83D0/R2D)

!  High-ZD-model prediction (deg) for that point
      DOUBLE PRECISION REF83
      PARAMETER (REF83=(C1+C2*7D0+C3*49D0)/(1D0+C4*7D0+C5*49D0))

      DOUBLE PRECISION ZU1,ZL,S,C,T,TSQ,TCU,REF,E,E2



!  Perform calculations for ZU or 83 deg, whichever is smaller
      ZU1 = MIN(ZU,Z83)

!  Functions of ZD
      ZL = ZU1
      S = SIN(ZL)
      C = COS(ZL)
      T = S/C
      TSQ = T*T
      TCU = T*TSQ

!  Refracted ZD (mathematically to better than 1 mas at 70 deg)
      ZL = ZL-(REFA*T+REFB*TCU)/(1D0+(REFA+3D0*REFB*TSQ)/(C*C))

!  Further iteration
      S = SIN(ZL)
      C = COS(ZL)
      T = S/C
      TSQ = T*T
      TCU = T*TSQ
      REF = ZU1-ZL+ &
               (ZL-ZU1+REFA*T+REFB*TCU)/(1D0+(REFA+3D0*REFB*TSQ)/(C*C))

!  Special handling for large ZU
      IF (ZU.GT.ZU1) THEN
         E = 90D0-MIN(D93,ZU*R2D)
         E2 = E*E
         REF = (REF/REF83)*(C1+C2*E+C3*E2)/(1D0+C4*E+C5*E2)
      END IF

!  Return refracted ZD
      ZR = ZU-REF

      END
      REAL FUNCTION sla_RVEROT (PHI, RA, DA, ST)
!+
!     - - - - - - -
!      R V E R O T
!     - - - - - - -
!
!  Velocity component in a given direction due to Earth rotation
!  (single precision)
!
!  Given:
!     PHI     real    latitude of observing station (geodetic)
!     RA,DA   real    apparent RA,DEC
!     ST      real    local apparent sidereal time
!
!  PHI, RA, DEC and ST are all in radians.
!
!  Result:
!     Component of Earth rotation in direction RA,DA (km/s)
!
!  Sign convention:
!     The result is +ve when the observatory is receding from the
!     given point on the sky.
!
!  Accuracy:
!     The simple algorithm used assumes a spherical Earth, of
!     a radius chosen to give results accurate to about 0.0005 km/s
!     for observing stations at typical latitudes and heights.  For
!     applications requiring greater precision, use the routine
!     sla_PVOBS.
!
!  P.T.Wallace   Starlink   20 July 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL PHI,RA,DA,ST

!  Nominal mean sidereal speed of Earth equator in km/s (the actual
!  value is about 0.4651)
      REAL ESPEED
      PARAMETER (ESPEED=0.4655)


      sla_RVEROT=ESPEED*COS(PHI)*SIN(ST-RA)*COS(DA)

      END
      REAL FUNCTION sla_RVGALC (R2000, D2000)
!+
!     - - - - - - -
!      R V G A L C
!     - - - - - - -
!
!  Velocity component in a given direction due to the rotation
!  of the Galaxy (single precision)
!
!  Given:
!     R2000,D2000   real    J2000.0 mean RA,Dec (radians)
!
!  Result:
!     Component of dynamical LSR motion in direction R2000,D2000 (km/s)
!
!  Sign convention:
!     The result is +ve when the dynamical LSR is receding from the
!     given point on the sky.
!
!  Note:  The Local Standard of Rest used here is a point in the
!         vicinity of the Sun which is in a circular orbit around
!         the Galactic centre.  Sometimes called the "dynamical" LSR,
!         it is not to be confused with a "kinematical" LSR, which
!         is the mean standard of rest of star catalogues or stellar
!         populations.
!
!  Reference:  The orbital speed of 220 km/s used here comes from
!              Kerr & Lynden-Bell (1986), MNRAS, 221, p1023.
!
!  Called:
!     sla_CS2C, sla_VDV
!
!  P.T.Wallace   Starlink   23 March 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL R2000,D2000

      REAL VA(3), VB(3)

      REAL sla_VDV

!
!  LSR velocity due to Galactic rotation
!
!  Speed = 220 km/s
!  Apex  = L2,B2  90deg, 0deg
!        = RA,Dec  21 12 01.1  +48 19 47  J2000.0
!
!  This is expressed in the form of a J2000.0 x,y,z vector:
!
!      VA(1) = X = -SPEED*COS(RA)*COS(DEC)
!      VA(2) = Y = -SPEED*SIN(RA)*COS(DEC)
!      VA(3) = Z = -SPEED*SIN(DEC)

      DATA VA / -108.70408, +97.86251, -164.33610 /



!  Convert given J2000 RA,Dec to x,y,z
      CALL sla_CS2C(R2000,D2000,VB)

!  Compute dot product with LSR motion vector
      sla_RVGALC=sla_VDV(VA,VB)

      END
      REAL FUNCTION sla_RVLG (R2000, D2000)
!+
!     - - - - -
!      R V L G
!     - - - - -
!
!  Velocity component in a given direction due to the combination
!  of the rotation of the Galaxy and the motion of the Galaxy
!  relative to the mean motion of the local group (single precision)
!
!  Given:
!     R2000,D2000   real    J2000.0 mean RA,Dec (radians)
!
!  Result:
!     Component of SOLAR motion in direction R2000,D2000 (km/s)
!
!  Sign convention:
!     The result is +ve when the Sun is receding from the
!     given point on the sky.
!
!  Reference:
!     IAU Trans 1976, 168, p201.
!
!  Called:
!     sla_CS2C, sla_VDV
!
!  P.T.Wallace   Starlink   June 1985
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL R2000,D2000

      REAL VA(3), VB(3)

      REAL sla_VDV

!
!  Solar velocity due to Galactic rotation and translation
!
!  Speed = 300 km/s
!
!  Apex  = L2,B2  90deg, 0deg
!        = RA,Dec  21 12 01.1  +48 19 47  J2000.0
!
!  This is expressed in the form of a J2000.0 x,y,z vector:
!
!      VA(1) = X = -SPEED*COS(RA)*COS(DEC)
!      VA(2) = Y = -SPEED*SIN(RA)*COS(DEC)
!      VA(3) = Z = -SPEED*SIN(DEC)

      DATA VA / -148.23284, +133.44888, -224.09467 /



!  Convert given J2000 RA,Dec to x,y,z
      CALL sla_CS2C(R2000,D2000,VB)

!  Compute dot product with Solar motion vector
      sla_RVLG=sla_VDV(VA,VB)

      END
      REAL FUNCTION sla_RVLSRD (R2000, D2000)
!+
!     - - - - - - -
!      R V L S R D
!     - - - - - - -
!
!  Velocity component in a given direction due to the Sun's motion
!  with respect to the dynamical Local Standard of Rest.
!
!  (single precision)
!
!  Given:
!     R2000,D2000   r    J2000.0 mean RA,Dec (radians)
!
!  Result:
!     Component of "peculiar" solar motion in direction R2000,D2000 (km/s)
!
!  Sign convention:
!     The result is +ve when the Sun is receding from the given point on
!     the sky.
!
!  Note:  The Local Standard of Rest used here is the "dynamical" LSR,
!         a point in the vicinity of the Sun which is in a circular
!         orbit around the Galactic centre.  The Sun's motion with
!         respect to the dynamical LSR is called the "peculiar" solar
!         motion.
!
!         There is another type of LSR, called a "kinematical" LSR.  A
!         kinematical LSR is the mean standard of rest of specified star
!         catalogues or stellar populations, and several slightly
!         different kinematical LSRs are in use.  The Sun's motion with
!         respect to an agreed kinematical LSR is known as the "standard"
!         solar motion.  To obtain a radial velocity correction with
!         respect to an adopted kinematical LSR use the routine sla_RVLSRK.
!
!  Reference:  Delhaye (1965), in "Stars and Stellar Systems", vol 5,
!              p73.
!
!  Called:
!     sla_CS2C, sla_VDV
!
!  P.T.Wallace   Starlink   9 March 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL R2000,D2000

      REAL VA(3), VB(3)

      REAL sla_VDV

!
!  Peculiar solar motion from Delhaye 1965: in Galactic Cartesian
!  coordinates (+9,+12,+7) km/s.  This corresponds to about 16.6 km/s
!  towards Galactic coordinates L2 = 53 deg, B2 = +25 deg, or RA,Dec
!  17 49 58.7 +28 07 04 J2000.
!
!  The solar motion is expressed here in the form of a J2000.0
!  equatorial Cartesian vector:
!
!      VA(1) = X = -SPEED*COS(RA)*COS(DEC)
!      VA(2) = Y = -SPEED*SIN(RA)*COS(DEC)
!      VA(3) = Z = -SPEED*SIN(DEC)

      DATA VA / +0.63823, +14.58542, -7.80116 /



!  Convert given J2000 RA,Dec to x,y,z
      CALL sla_CS2C(R2000,D2000,VB)

!  Compute dot product with solar motion vector
      sla_RVLSRD=sla_VDV(VA,VB)

      END
      REAL FUNCTION sla_RVLSRK (R2000, D2000)
!+
!     - - - - - - -
!      R V L S R K
!     - - - - - - -
!
!  Velocity component in a given direction due to the Sun's motion
!  with respect to an adopted kinematic Local Standard of Rest.
!
!  (single precision)
!
!  Given:
!     R2000,D2000   r    J2000.0 mean RA,Dec (radians)
!
!  Result:
!     Component of "standard" solar motion in direction R2000,D2000 (km/s)
!
!  Sign convention:
!     The result is +ve when the Sun is receding from the given point on
!     the sky.
!
!  Note:  The Local Standard of Rest used here is one of several
!         "kinematical" LSRs in common use.  A kinematical LSR is the
!         mean standard of rest of specified star catalogues or stellar
!         populations.  The Sun's motion with respect to a kinematical
!         LSR is known as the "standard" solar motion.
!
!         There is another sort of LSR, the "dynamical" LSR, which is a
!         point in the vicinity of the Sun which is in a circular orbit
!         around the Galactic centre.  The Sun's motion with respect to
!         the dynamical LSR is called the "peculiar" solar motion.  To
!         obtain a radial velocity correction with respect to the
!         dynamical LSR use the routine sla_RVLSRD.
!
!  Reference:  Delhaye (1965), in "Stars and Stellar Systems", vol 5,
!              p73.
!
!  Called:
!     sla_CS2C, sla_VDV
!
!  P.T.Wallace   Starlink   11 March 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL R2000,D2000

      REAL VA(3), VB(3)

      REAL sla_VDV

!
!  Standard solar motion (from Methods of Experimental Physics, ed Meeks,
!  vol 12, part C, sec 6.1.5.2, p281):
!
!  20 km/s towards RA 18h Dec +30d (1900).
!
!  The solar motion is expressed here in the form of a J2000.0
!  equatorial Cartesian vector:
!
!      VA(1) = X = -SPEED*COS(RA)*COS(DEC)
!      VA(2) = Y = -SPEED*SIN(RA)*COS(DEC)
!      VA(3) = Z = -SPEED*SIN(DEC)

      DATA VA / -0.29000, +17.31726, -10.00141 /



!  Convert given J2000 RA,Dec to x,y,z
      CALL sla_CS2C(R2000,D2000,VB)

!  Compute dot product with solar motion vector
      sla_RVLSRK=sla_VDV(VA,VB)

      END
      SUBROUTINE sla_S2TP (RA, DEC, RAZ, DECZ, XI, ETA, J)
!+
!     - - - - -
!      S 2 T P
!     - - - - -
!
!  Projection of spherical coordinates onto tangent plane:
!  "gnomonic" projection - "standard coordinates"
!  (single precision)
!
!  Given:
!     RA,DEC      real  spherical coordinates of point to be projected
!     RAZ,DECZ    real  spherical coordinates of tangent point
!
!  Returned:
!     XI,ETA      real  rectangular coordinates on tangent plane
!     J           int   status:   0 = OK, star on tangent plane
!                                 1 = error, star too far from axis
!                                 2 = error, antistar on tangent plane
!                                 3 = error, antistar too far from axis
!
!  P.T.Wallace   Starlink   18 July 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL RA,DEC,RAZ,DECZ,XI,ETA
      INTEGER J

      REAL SDECZ,SDEC,CDECZ,CDEC,RADIF,SRADIF,CRADIF,DENOM

      REAL TINY
      PARAMETER (TINY=1E-6)


!  Trig functions
      SDECZ=SIN(DECZ)
      SDEC=SIN(DEC)
      CDECZ=COS(DECZ)
      CDEC=COS(DEC)
      RADIF=RA-RAZ
      SRADIF=SIN(RADIF)
      CRADIF=COS(RADIF)

!  Reciprocal of star vector length to tangent plane
      DENOM=SDEC*SDECZ+CDEC*CDECZ*CRADIF

!  Handle vectors too far from axis
      IF (DENOM.GT.TINY) THEN
         J=0
      ELSE IF (DENOM.GE.0.0) THEN
         J=1
         DENOM=TINY
      ELSE IF (DENOM.GT.-TINY) THEN
         J=2
         DENOM=-TINY
      ELSE
         J=3
      END IF

!  Compute tangent plane coordinates (even in dubious cases)
      XI=CDEC*SRADIF/DENOM
      ETA=(SDEC*CDECZ-CDEC*SDECZ*CRADIF)/DENOM

      END
      REAL FUNCTION sla_SEP (A1, B1, A2, B2)
!+
!     - - - -
!      S E P
!     - - - -
!
!  Angle between two points on a sphere.
!
!  (single precision)
!
!  Given:
!     A1,B1    r     spherical coordinates of one point
!     A2,B2    r     spherical coordinates of the other point
!
!  (The spherical coordinates are [RA,Dec], [Long,Lat] etc, in radians.)
!
!  The result is the angle, in radians, between the two points.  It
!  is always positive.
!
!  Called:  sla_DSEP
!
!  Last revision:   7 May 2000
!
!  Copyright P.T.Wallace.  All rights reserved.
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL A1,B1,A2,B2

      DOUBLE PRECISION sla_DSEP



!  Use double precision version.
      sla_SEP = REAL(sla_DSEP(DBLE(A1),DBLE(B1),DBLE(A2),DBLE(B2)))

      END
      REAL FUNCTION sla_SEPV (V1, V2)
!+
!     - - - - -
!      S E P V
!     - - - - -
!
!  Angle between two vectors.
!
!  (single precision)
!
!  Given:
!     V1      r(3)    first vector
!     V2      r(3)    second vector
!
!  The result is the angle, in radians, between the two vectors.  It
!  is always positive.
!
!  Notes:
!
!  1  There is no requirement for the vectors to be unit length.
!
!  2  If either vector is null, zero is returned.
!
!  3  The simplest formulation would use dot product alone.  However,
!     this would reduce the accuracy for angles near zero and pi.  The
!     algorithm uses both cross product and dot product, which maintains
!     accuracy for all sizes of angle.
!
!  Called:  sla_DSEPV
!
!  Last revision:   7 May 2000
!
!  Copyright P.T.Wallace.  All rights reserved.
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL V1(3),V2(3)

      INTEGER I
      DOUBLE PRECISION DV1(3),DV2(3)
      DOUBLE PRECISION sla_DSEPV



!  Use double precision version.
      DO I=1,3
         DV1(I) = DBLE(V1(I))
         DV2(I) = DBLE(V2(I))
      END DO
      sla_SEPV = REAL(sla_DSEPV(DV1,DV2))

      END
      SUBROUTINE sla_SMAT (N, A, Y, D, JF, IW)
!+
!     - - - - -
!      S M A T
!     - - - - -
!
!  Matrix inversion & solution of simultaneous equations
!  (single precision)
!
!  For the set of n simultaneous equations in n unknowns:
!     A.Y = X
!
!  where:
!     A is a non-singular N x N matrix
!     Y is the vector of N unknowns
!     X is the known vector
!
!  SMATRX computes:
!     the inverse of matrix A
!     the determinant of matrix A
!     the vector of N unknowns
!
!  Arguments:
!
!     symbol  type dimension           before              after
!
!       N      int                 no. of unknowns       unchanged
!       A      real  (N,N)             matrix             inverse
!       Y      real   (N)              vector            solution
!       D      real                       -             determinant
!     * JF     int                        -           singularity flag
!       IW     int    (N)                 -              workspace
!
!  !  JF is the singularity flag.  If the matrix is non-singular,
!    JF=0 is returned.  If the matrix is singular, JF=-1 & D=0.0 are
!    returned.  In the latter case, the contents of array A on return
!    are undefined.
!
!  Algorithm:
!     Gaussian elimination with partial pivoting.
!
!  Speed:
!     Very fast.
!
!  Accuracy:
!     Fairly accurate - errors 1 to 4 times those of routines optimised
!     for accuracy.
!
!  Note:  replaces the obsolete sla_SMATRX routine.
!
!  P.T.Wallace   Starlink   10 September 1990
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER N
      REAL A(N,N),Y(N),D
      INTEGER JF
      INTEGER IW(N)

      REAL SFA
      PARAMETER (SFA=1E-20)

      INTEGER K,IMX,I,J,NP1MK,KI
      REAL AMX,T,AKK,YK,AIK


      JF=0
      D=1.0
      DO K=1,N
         AMX=ABS(A(K,K))
         IMX=K
         IF (K.NE.N) THEN
            DO I=K+1,N
               T=ABS(A(I,K))
               IF (T.GT.AMX) THEN
                  AMX=T
                  IMX=I
               END IF
            END DO
         END IF
         IF (AMX.LT.SFA) THEN
            JF=-1
         ELSE
            IF (IMX.NE.K) THEN
               DO J=1,N
                  T=A(K,J)
                  A(K,J)=A(IMX,J)
                  A(IMX,J)=T
               END DO
               T=Y(K)
               Y(K)=Y(IMX)
               Y(IMX)=T
               D=-D
            END IF
            IW(K)=IMX
            AKK=A(K,K)
            D=D*AKK
            IF (ABS(D).LT.SFA) THEN
               JF=-1
            ELSE
               AKK=1.0/AKK
               A(K,K)=AKK
               DO J=1,N
                  IF (J.NE.K) A(K,J)=A(K,J)*AKK
               END DO
               YK=Y(K)*AKK
               Y(K)=YK
               DO I=1,N
                  AIK=A(I,K)
                  IF (I.NE.K) THEN
                     DO J=1,N
                        IF (J.NE.K) A(I,J)=A(I,J)-AIK*A(K,J)
                     END DO
                     Y(I)=Y(I)-AIK*YK
                  END IF
               END DO
               DO I=1,N
                  IF (I.NE.K) A(I,K)=-A(I,K)*AKK
               END DO
            END IF
         END IF
      END DO
      IF (JF.NE.0) THEN
         D=0.0
      ELSE
         DO K=1,N
            NP1MK=N+1-K
            KI=IW(NP1MK)
            IF (NP1MK.NE.KI) THEN
               DO I=1,N
                  T=A(I,NP1MK)
                  A(I,NP1MK)=A(I,KI)
                  A(I,KI)=T
               END DO
            END IF
         END DO
      END IF
      END
      SUBROUTINE sla_SUBET (RC, DC, EQ, RM, DM)
!+
!     - - - - - -
!      S U B E T
!     - - - - - -
!
!  Remove the E-terms (elliptic component of annual aberration)
!  from a pre IAU 1976 catalogue RA,Dec to give a mean place
!  (double precision)
!
!  Given:
!     RC,DC     dp     RA,Dec (radians) with E-terms included
!     EQ        dp     Besselian epoch of mean equator and equinox
!
!  Returned:
!     RM,DM     dp     RA,Dec (radians) without E-terms
!
!  Called:
!     sla_ETRMS, sla_DCS2C, sla_,DVDV, sla_DCC2S, sla_DRANRM
!
!  Explanation:
!     Most star positions from pre-1984 optical catalogues (or
!     derived from astrometry using such stars) embody the
!     E-terms.  This routine converts such a position to a
!     formal mean place (allowing, for example, comparison with a
!     pulsar timing position).
!
!  Reference:
!     Explanatory Supplement to the Astronomical Ephemeris,
!     section 2D, page 48.
!
!  P.T.Wallace   Starlink   10 May 1990
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION RC,DC,EQ,RM,DM

      DOUBLE PRECISION sla_DRANRM,sla_DVDV
      DOUBLE PRECISION A(3),V(3),F

      INTEGER I



!  E-terms
      CALL sla_ETRMS(EQ,A)

!  Spherical to Cartesian
      CALL sla_DCS2C(RC,DC,V)

!  Include the E-terms
      F=1D0+sla_DVDV(V,A)
      DO I=1,3
         V(I)=F*V(I)-A(I)
      END DO

!  Cartesian to spherical
      CALL sla_DCC2S(V,RM,DM)

!  Bring RA into conventional range
      RM=sla_DRANRM(RM)

      END
      SUBROUTINE sla_SUPGAL (DSL, DSB, DL, DB)
!+
!     - - - - - - -
!      S U P G A L
!     - - - - - - -
!
!  Transformation from de Vaucouleurs supergalactic coordinates
!  to IAU 1958 galactic coordinates (double precision)
!
!  Given:
!     DSL,DSB     dp       supergalactic longitude and latitude
!
!  Returned:
!     DL,DB       dp       galactic longitude and latitude L2,B2
!
!  (all arguments are radians)
!
!  Called:
!     sla_DCS2C, sla_DIMXV, sla_DCC2S, sla_DRANRM, sla_DRANGE
!
!  References:
!
!     de Vaucouleurs, de Vaucouleurs, & Corwin, Second Reference
!     Catalogue of Bright Galaxies, U. Texas, page 8.
!
!     Systems & Applied Sciences Corp., Documentation for the
!     machine-readable version of the above catalogue,
!     Contract NAS 5-26490.
!
!    (These two references give different values for the galactic
!     longitude of the supergalactic origin.  Both are wrong;  the
!     correct value is L2=137.37.)
!
!  P.T.Wallace   Starlink   March 1986
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DSL,DSB,DL,DB

      DOUBLE PRECISION sla_DRANRM,sla_DRANGE

      DOUBLE PRECISION V1(3),V2(3)

!
!  System of supergalactic coordinates:
!
!    SGL   SGB        L2     B2      (deg)
!     -    +90      47.37  +6.32
!     0     0         -      0
!
!  Galactic to supergalactic rotation matrix:
!
      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3), &
          RMAT(2,1),RMAT(2,2),RMAT(2,3), &
          RMAT(3,1),RMAT(3,2),RMAT(3,3)/ &
      -0.735742574804D0,+0.677261296414D0,+0.000000000000D0, &
      -0.074553778365D0,-0.080991471307D0,+0.993922590400D0, &
      +0.673145302109D0,+0.731271165817D0,+0.110081262225D0/



!  Spherical to Cartesian
      CALL sla_DCS2C(DSL,DSB,V1)

!  Supergalactic to galactic
      CALL sla_DIMXV(RMAT,V1,V2)

!  Cartesian to spherical
      CALL sla_DCC2S(V2,DL,DB)

!  Express in conventional ranges
      DL=sla_DRANRM(DL)
      DB=sla_DRANGE(DB)

      END
      SUBROUTINE sla_SVD (M, N, MP, NP, A, W, V, WORK, JSTAT)
!+
!     - - - -
!      S V D
!     - - - -
!
!  Singular value decomposition  (double precision)
!
!  This routine expresses a given matrix A as the product of
!  three matrices U, W, V:
!
!     A = U x W x VT
!
!  Where:
!
!     A   is any M (rows) x N (columns) matrix, where M.GE.N
!     U   is an M x N column-orthogonal matrix
!     W   is an N x N diagonal matrix with W(I,I).GE.0
!     VT  is the transpose of an N x N orthogonal matrix
!
!     Note that M and N, above, are the LOGICAL dimensions of the
!     matrices and vectors concerned, which can be located in
!     arrays of larger PHYSICAL dimensions, given by MP and NP.
!
!  Given:
!     M,N    i         numbers of rows and columns in matrix A
!     MP,NP  i         physical dimensions of array containing matrix A
!     A      d(MP,NP)  array containing MxN matrix A
!
!  Returned:
!     A      d(MP,NP)  array containing MxN column-orthogonal matrix U
!     W      d(N)      NxN diagonal matrix W (diagonal elements only)
!     V      d(NP,NP)  array containing NxN orthogonal matrix V
!     WORK   d(N)      workspace
!     JSTAT  i         0 = OK, -1 = A wrong shape, >0 = index of W
!                      for which convergence failed.  See note 2, below.
!
!   Notes:
!
!   1)  V contains matrix V, not the transpose of matrix V.
!
!   2)  If the status JSTAT is greater than zero, this need not
!       necessarily be treated as a failure.  It means that, due to
!       chance properties of the matrix A, the QR transformation
!       phase of the routine did not fully converge in a predefined
!       number of iterations, something that very seldom occurs.
!       When this condition does arise, it is possible that the
!       elements of the diagonal matrix W have not been correctly
!       found.  However, in practice the results are likely to
!       be trustworthy.  Applications should report the condition
!       as a warning, but then proceed normally.
!
!  References:
!     The algorithm is an adaptation of the routine SVD in the EISPACK
!     library (Garbow et al 1977, EISPACK Guide Extension, Springer
!     Verlag), which is a FORTRAN 66 implementation of the Algol
!     routine SVD of Wilkinson & Reinsch 1971 (Handbook for Automatic
!     Computation, vol 2, ed Bauer et al, Springer Verlag).  These
!     references give full details of the algorithm used here.  A good
!     account of the use of SVD in least squares problems is given in
!     Numerical Recipes (Press et al 1986, Cambridge University Press),
!     which includes another variant of the EISPACK code.
!
!  P.T.Wallace   Starlink   22 December 1993
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER M,N,MP,NP
      DOUBLE PRECISION A(MP,NP),W(N),V(NP,NP),WORK(N)
      INTEGER JSTAT

!  Maximum number of iterations in QR phase
      INTEGER ITMAX
      PARAMETER (ITMAX=30)

      INTEGER I,K,L,J,K1,ITS,L1,I1
      LOGICAL CANCEL
      DOUBLE PRECISION G,SCALE,AN,S,X,F,H,C,Y,Z



!  Check that the matrix is the right shape
      IF (M.LT.N) THEN

!     No:  error status
         JSTAT = -1

      ELSE

!     Yes:  preset the status to OK
         JSTAT = 0

!
!     Householder reduction to bidiagonal form
!     ----------------------------------------

         G = 0D0
         SCALE = 0D0
         AN = 0D0
         DO I=1,N
            L = I+1
            WORK(I) = SCALE*G
            G = 0D0
            S = 0D0
            SCALE = 0D0
            IF (I.LE.M) THEN
               DO K=I,M
                  SCALE = SCALE+ABS(A(K,I))
               END DO
               IF (SCALE.NE.0D0) THEN
                  DO K=I,M
                     X = A(K,I)/SCALE
                     A(K,I) = X
                     S = S+X*X
                  END DO
                  F = A(I,I)
                  G = -SIGN(SQRT(S),F)
                  H = F*G-S
                  A(I,I) = F-G
                  IF (I.NE.N) THEN
                     DO J=L,N
                        S = 0D0
                        DO K=I,M
                           S = S+A(K,I)*A(K,J)
                        END DO
                        F = S/H
                        DO K=I,M
                           A(K,J) = A(K,J)+F*A(K,I)
                        END DO
                     END DO
                  END IF
                  DO K=I,M
                     A(K,I) = SCALE*A(K,I)
                  END DO
               END IF
            END IF
            W(I) = SCALE*G
            G = 0D0
            S = 0D0
            SCALE = 0D0
            IF (I.LE.M .AND. I.NE.N) THEN
               DO K=L,N
                  SCALE = SCALE+ABS(A(I,K))
               END DO
               IF (SCALE.NE.0D0) THEN
                  DO K=L,N
                     X = A(I,K)/SCALE
                     A(I,K) = X
                     S = S+X*X
                  END DO
                  F = A(I,L)
                  G = -SIGN(SQRT(S),F)
                  H = F*G-S
                  A(I,L) = F-G
                  DO K=L,N
                     WORK(K) = A(I,K)/H
                  END DO
                  IF (I.NE.M) THEN
                     DO J=L,M
                        S = 0D0
                        DO K=L,N
                           S = S+A(J,K)*A(I,K)
                        END DO
                        DO K=L,N
                           A(J,K) = A(J,K)+S*WORK(K)
                        END DO
                     END DO
                  END IF
                  DO K=L,N
                     A(I,K) = SCALE*A(I,K)
                  END DO
               END IF
            END IF

!        Overestimate of largest column norm for convergence test
            AN = MAX(AN,ABS(W(I))+ABS(WORK(I)))

         END DO

!
!     Accumulation of right-hand transformations
!     ------------------------------------------

         DO I=N,1,-1
            IF (I.NE.N) THEN
               IF (G.NE.0D0) THEN
                  DO J=L,N
                     V(J,I) = (A(I,J)/A(I,L))/G
                  END DO
                  DO J=L,N
                     S = 0D0
                     DO K=L,N
                        S = S+A(I,K)*V(K,J)
                     END DO
                     DO K=L,N
                        V(K,J) = V(K,J)+S*V(K,I)
                     END DO
                  END DO
               END IF
               DO J=L,N
                  V(I,J) = 0D0
                  V(J,I) = 0D0
               END DO
            END IF
            V(I,I) = 1D0
            G = WORK(I)
            L = I
         END DO

!
!     Accumulation of left-hand transformations
!     -----------------------------------------

         DO I=N,1,-1
            L = I+1
            G = W(I)
            IF (I.NE.N) THEN
               DO J=L,N
                  A(I,J) = 0D0
               END DO
            END IF
            IF (G.NE.0D0) THEN
               IF (I.NE.N) THEN
                  DO J=L,N
                     S = 0D0
                     DO K=L,M
                        S = S+A(K,I)*A(K,J)
                     END DO
                     F = (S/A(I,I))/G
                     DO K=I,M
                        A(K,J) = A(K,J)+F*A(K,I)
                     END DO
                  END DO
               END IF
               DO J=I,M
                  A(J,I) = A(J,I)/G
               END DO
            ELSE
               DO J=I,M
                  A(J,I) = 0D0
               END DO
            END IF
            A(I,I) = A(I,I)+1D0
         END DO

!
!     Diagonalisation of the bidiagonal form
!     --------------------------------------

         DO K=N,1,-1
            K1 = K-1

!        Iterate until converged
            ITS = 0
            DO WHILE (ITS.LT.ITMAX)
               ITS = ITS+1

!           Test for splitting into submatrices
               CANCEL = .TRUE.
               DO L=K,1,-1
                  L1 = L-1
                  IF (AN+ABS(WORK(L)).EQ.AN) THEN
                     CANCEL = .FALSE.
                     GO TO 10
                  END IF
!              (Following never attempted for L=1 because WORK(1) is zero)
                  IF (AN+ABS(W(L1)).EQ.AN) GO TO 10
               END DO
 10            CONTINUE

!           Cancellation of WORK(L) if L>1
               IF (CANCEL) THEN
                  C = 0D0
                  S = 1D0
                  DO I=L,K
                     F = S*WORK(I)
                     IF (AN+ABS(F).EQ.AN) GO TO 20
                     G = W(I)
                     H = SQRT(F*F+G*G)
                     W(I) = H
                     C = G/H
                     S = -F/H
                     DO J=1,M
                        Y = A(J,L1)
                        Z = A(J,I)
                        A(J,L1) = Y*C+Z*S
                        A(J,I) = -Y*S+Z*C
                     END DO
                  END DO
 20               CONTINUE
               END IF

!           Converged?
               Z = W(K)
               IF (L.EQ.K) THEN

!              Yes:  stop iterating
                  ITS = ITMAX

!              Ensure singular values non-negative
                  IF (Z.LT.0D0) THEN
                     W(K) = -Z
                     DO J=1,N
                        V(J,K) = -V(J,K)
                     END DO
                  END IF
               ELSE

!              Not converged yet:  set status if iteration limit reached
                  IF (ITS.EQ.ITMAX) JSTAT = K

!              Shift from bottom 2x2 minor
                  X = W(L)
                  Y = W(K1)
                  G = WORK(K1)
                  H = WORK(K)
                  F = ((Y-Z)*(Y+Z)+(G-H)*(G+H))/(2D0*H*Y)
                  IF (ABS(F).LE.1D15) THEN
                     G = SQRT(F*F+1D0)
                  ELSE
                     G = ABS(F)
                  END IF
                  F = ((X-Z)*(X+Z)+H*(Y/(F+SIGN(G,F))-H))/X

!              Next QR transformation
                  C = 1D0
                  S = 1D0
                  DO I1=L,K1
                     I = I1+1
                     G = WORK(I)
                     Y = W(I)
                     H = S*G
                     G = C*G
                     Z = SQRT(F*F+H*H)
                     WORK(I1) = Z
                     IF (Z.NE.0D0) THEN
                        C = F/Z
                        S = H/Z
                     ELSE
                        C = 1D0
                        S = 0D0
                     END IF
                     F = X*C+G*S
                     G = -X*S+G*C
                     H = Y*S
                     Y = Y*C
                     DO J=1,N
                        X = V(J,I1)
                        Z = V(J,I)
                        V(J,I1) = X*C+Z*S
                        V(J,I) = -X*S+Z*C
                     END DO
                     Z = SQRT(F*F+H*H)
                     W(I1) = Z
                     IF (Z.NE.0D0) THEN
                        C = F/Z
                        S = H/Z
                     END IF
                     F = C*G+S*Y
                     X = -S*G+C*Y
                     DO J=1,M
                        Y = A(J,I1)
                        Z = A(J,I)
                        A(J,I1) = Y*C+Z*S
                        A(J,I) = -Y*S+Z*C
                     END DO
                  END DO
                  WORK(L) = 0D0
                  WORK(K) = F
                  W(K) = X
               END IF
            END DO
         END DO
      END IF

      END
      SUBROUTINE sla_SVDCOV (N, NP, NC, W, V, WORK, CVM)
!+
!     - - - - - - -
!      S V D C O V
!     - - - - - - -
!
!  From the W and V matrices from the SVD factorisation of a matrix
!  (as obtained from the sla_SVD routine), obtain the covariance matrix.
!
!  (double precision)
!
!  Given:
!     N      i         number of rows and columns in matrices W and V
!     NP     i         first dimension of array containing matrix V
!     NC     i         first dimension of array to receive CVM
!     W      d(N)      NxN diagonal matrix W (diagonal elements only)
!     V      d(NP,NP)  array containing NxN orthogonal matrix V
!
!  Returned:
!     WORK   d(N)      workspace
!     CVM    d(NC,NC)  array to receive covariance matrix
!
!  Reference:
!     Numerical Recipes, section 14.3.
!
!  P.T.Wallace   Starlink   December 1988
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER N,NP,NC
      DOUBLE PRECISION W(N),V(NP,NP),WORK(N),CVM(NC,NC)

      INTEGER I,J,K
      DOUBLE PRECISION S



      DO I=1,N
         S=W(I)
         IF (S.NE.0D0) THEN
            WORK(I)=1D0/(S*S)
         ELSE
            WORK(I)=0D0
         END IF
      END DO
      DO I=1,N
         DO J=1,I
            S=0D0
            DO K=1,N
               S=S+V(I,K)*V(J,K)*WORK(K)
            END DO
            CVM(I,J)=S
            CVM(J,I)=S
         END DO
      END DO

      END
      SUBROUTINE sla_SVDSOL (M, N, MP, NP, B, U, W, V, WORK, X)
!+
!     - - - - - - -
!      S V D S O L
!     - - - - - - -
!
!  From a given vector and the SVD of a matrix (as obtained from
!  the SVD routine), obtain the solution vector (double precision)
!
!  This routine solves the equation:
!
!     A . x = b
!
!  where:
!
!     A   is a given M (rows) x N (columns) matrix, where M.GE.N
!     x   is the N-vector we wish to find
!     b   is a given M-vector
!
!  by means of the Singular Value Decomposition method (SVD).  In
!  this method, the matrix A is first factorised (for example by
!  the routine sla_SVD) into the following components:
!
!     A = U x W x VT
!
!  where:
!
!     A   is the M (rows) x N (columns) matrix
!     U   is an M x N column-orthogonal matrix
!     W   is an N x N diagonal matrix with W(I,I).GE.0
!     VT  is the transpose of an NxN orthogonal matrix
!
!     Note that M and N, above, are the LOGICAL dimensions of the
!     matrices and vectors concerned, which can be located in
!     arrays of larger PHYSICAL dimensions MP and NP.
!
!  The solution is found from the expression:
!
!     x = V . [diag(1/Wj)] . (transpose(U) . b)
!
!  Notes:
!
!  1)  If matrix A is square, and if the diagonal matrix W is not
!      adjusted, the method is equivalent to conventional solution
!      of simultaneous equations.
!
!  2)  If M>N, the result is a least-squares fit.
!
!  3)  If the solution is poorly determined, this shows up in the
!      SVD factorisation as very small or zero Wj values.  Where
!      a Wj value is small but non-zero it can be set to zero to
!      avoid ill effects.  The present routine detects such zero
!      Wj values and produces a sensible solution, with highly
!      correlated terms kept under control rather than being allowed
!      to elope to infinity, and with meaningful values for the
!      other terms.
!
!  Given:
!     M,N    i         numbers of rows and columns in matrix A
!     MP,NP  i         physical dimensions of array containing matrix A
!     B      d(M)      known vector b
!     U      d(MP,NP)  array containing MxN matrix U
!     W      d(N)      NxN diagonal matrix W (diagonal elements only)
!     V      d(NP,NP)  array containing NxN orthogonal matrix V
!
!  Returned:
!     WORK   d(N)      workspace
!     X      d(N)      unknown vector x
!
!  Reference:
!     Numerical Recipes, section 2.9.
!
!  P.T.Wallace   Starlink   29 October 1993
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      INTEGER M,N,MP,NP
      DOUBLE PRECISION B(M),U(MP,NP),W(N),V(NP,NP),WORK(N),X(N)

      INTEGER J,I,JJ
      DOUBLE PRECISION S



!  Calculate [diag(1/Wj)] . transpose(U) . b (or zero for zero Wj)
      DO J=1,N
         S=0D0
         IF (W(J).NE.0D0) THEN
            DO I=1,M
               S=S+U(I,J)*B(I)
            END DO
            S=S/W(J)
         END IF
         WORK(J)=S
      END DO

!  Multiply by matrix V to get result
      DO J=1,N
         S=0D0
         DO JJ=1,N
            S=S+V(J,JJ)*WORK(JJ)
         END DO
         X(J)=S
      END DO

      END
      SUBROUTINE sla_TP2S (XI, ETA, RAZ, DECZ, RA, DEC)
!+
!     - - - - -
!      T P 2 S
!     - - - - -
!
!  Transform tangent plane coordinates into spherical
!  (single precision)
!
!  Given:
!     XI,ETA      real  tangent plane rectangular coordinates
!     RAZ,DECZ    real  spherical coordinates of tangent point
!
!  Returned:
!     RA,DEC      real  spherical coordinates (0-2pi,+/-pi/2)
!
!  Called:        sla_RANORM
!
!  P.T.Wallace   Starlink   24 July 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL XI,ETA,RAZ,DECZ,RA,DEC

      REAL sla_RANORM

      REAL SDECZ,CDECZ,DENOM



      SDECZ=SIN(DECZ)
      CDECZ=COS(DECZ)

      DENOM=CDECZ-ETA*SDECZ

      RA=sla_RANORM(ATAN2(XI,DENOM)+RAZ)
      DEC=ATAN2(SDECZ+ETA*CDECZ,SQRT(XI*XI+DENOM*DENOM))

      END
      SUBROUTINE sla_TP2V (XI, ETA, V0, V)
!+
!     - - - - -
!      T P 2 V
!     - - - - -
!
!  Given the tangent-plane coordinates of a star and the direction
!  cosines of the tangent point, determine the direction cosines
!  of the star.
!
!  (single precision)
!
!  Given:
!     XI,ETA    r       tangent plane coordinates of star
!     V0        r(3)    direction cosines of tangent point
!
!  Returned:
!     V         r(3)    direction cosines of star
!
!  Notes:
!
!  1  If vector V0 is not of unit length, the returned vector V will
!     be wrong.
!
!  2  If vector V0 points at a pole, the returned vector V will be
!     based on the arbitrary assumption that the RA of the tangent
!     point is zero.
!
!  3  This routine is the Cartesian equivalent of the routine sla_TP2S.
!
!  P.T.Wallace   Starlink   11 February 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL XI,ETA,V0(3),V(3)

      REAL X,Y,Z,F,R


      X=V0(1)
      Y=V0(2)
      Z=V0(3)
      F=SQRT(1.0+XI*XI+ETA*ETA)
      R=SQRT(X*X+Y*Y)
      IF (R.EQ.0.0) THEN
         R=1E-20
         X=R
      END IF
      V(1)=(X-(XI*Y+ETA*X*Z)/R)/F
      V(2)=(Y+(XI*X-ETA*Y*Z)/R)/F
      V(3)=(Z+ETA*R)/F

      END
      SUBROUTINE sla_TPS2C (XI, ETA, RA, DEC, RAZ1, DECZ1, &
                                             RAZ2, DECZ2, N)
!+
!     - - - - - -
!      T P S 2 C
!     - - - - - -
!
!  From the tangent plane coordinates of a star of known RA,Dec,
!  determine the RA,Dec of the tangent point.
!
!  (single precision)
!
!  Given:
!     XI,ETA      r    tangent plane rectangular coordinates
!     RA,DEC      r    spherical coordinates
!
!  Returned:
!     RAZ1,DECZ1  r    spherical coordinates of tangent point, solution 1
!     RAZ2,DECZ2  r    spherical coordinates of tangent point, solution 2
!     N           i    number of solutions:
!                        0 = no solutions returned (note 2)
!                        1 = only the first solution is useful (note 3)
!                        2 = both solutions are useful (note 3)
!
!  Notes:
!
!  1  The RAZ1 and RAZ2 values are returned in the range 0-2pi.
!
!  2  Cases where there is no solution can only arise near the poles.
!     For example, it is clearly impossible for a star at the pole
!     itself to have a non-zero XI value, and hence it is
!     meaningless to ask where the tangent point would have to be
!     to bring about this combination of XI and DEC.
!
!  3  Also near the poles, cases can arise where there are two useful
!     solutions.  The argument N indicates whether the second of the
!     two solutions returned is useful.  N=1 indicates only one useful
!     solution, the usual case;  under these circumstances, the second
!     solution corresponds to the "over-the-pole" case, and this is
!     reflected in the values of RAZ2 and DECZ2 which are returned.
!
!  4  The DECZ1 and DECZ2 values are returned in the range +/-pi, but
!     in the usual, non-pole-crossing, case, the range is +/-pi/2.
!
!  5  This routine is the spherical equivalent of the routine sla_DTPV2C.
!
!  Called:  sla_RANORM
!
!  P.T.Wallace   Starlink   5 June 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL XI,ETA,RA,DEC,RAZ1,DECZ1,RAZ2,DECZ2
      INTEGER N

      REAL X2,Y2,SD,CD,SDF,R2,R,S,C

      REAL sla_RANORM


      X2=XI*XI
      Y2=ETA*ETA
      SD=SIN(DEC)
      CD=COS(DEC)
      SDF=SD*SQRT(1.0+X2+Y2)
      R2=CD*CD*(1.0+Y2)-SD*SD*X2
      IF (R2.GE.0.0) THEN
         R=SQRT(R2)
         S=SDF-ETA*R
         C=SDF*ETA+R
         IF (XI.EQ.0.0.AND.R.EQ.0.0) R=1.0
         RAZ1=sla_RANORM(RA-ATAN2(XI,R))
         DECZ1=ATAN2(S,C)
         R=-R
         S=SDF-ETA*R
         C=SDF*ETA+R
         RAZ2=sla_RANORM(RA-ATAN2(XI,R))
         DECZ2=ATAN2(S,C)
         IF (ABS(SDF).LT.1.0) THEN
            N=1
         ELSE
            N=2
         END IF
      ELSE
         N=0
      END IF

      END
      SUBROUTINE sla_TPV2C (XI, ETA, V, V01, V02, N)
!+
!     - - - - - -
!      T P V 2 C
!     - - - - - -
!
!  Given the tangent-plane coordinates of a star and its direction
!  cosines, determine the direction cosines of the tangent-point.
!
!  (single precision)
!
!  Given:
!     XI,ETA    r       tangent plane coordinates of star
!     V         r(3)    direction cosines of star
!
!  Returned:
!     V01       r(3)    direction cosines of tangent point, solution 1
!     V02       r(3)    direction cosines of tangent point, solution 2
!     N         i       number of solutions:
!                         0 = no solutions returned (note 2)
!                         1 = only the first solution is useful (note 3)
!                         2 = both solutions are useful (note 3)
!
!  Notes:
!
!  1  The vector V must be of unit length or the result will be wrong.
!
!  2  Cases where there is no solution can only arise near the poles.
!     For example, it is clearly impossible for a star at the pole
!     itself to have a non-zero XI value, and hence it is meaningless
!     to ask where the tangent point would have to be.
!
!  3  Also near the poles, cases can arise where there are two useful
!     solutions.  The argument N indicates whether the second of the
!     two solutions returned is useful.  N=1 indicates only one useful
!     solution, the usual case;  under these circumstances, the second
!     solution can be regarded as valid if the vector V02 is interpreted
!     as the "over-the-pole" case.
!
!  4  This routine is the Cartesian equivalent of the routine sla_TPS2C.
!
!  P.T.Wallace   Starlink   5 June 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL XI,ETA,V(3),V01(3),V02(3)
      INTEGER N

      REAL X,Y,Z,RXY2,XI2,ETA2P1,SDF,R2,R,C


      X=V(1)
      Y=V(2)
      Z=V(3)
      RXY2=X*X+Y*Y
      XI2=XI*XI
      ETA2P1=ETA*ETA+1.0
      SDF=Z*SQRT(XI2+ETA2P1)
      R2=RXY2*ETA2P1-Z*Z*XI2
      IF (R2.GT.0.0) THEN
         R=SQRT(R2)
         C=(SDF*ETA+R)/(ETA2P1*SQRT(RXY2*(R2+XI2)))
         V01(1)=C*(X*R+Y*XI)
         V01(2)=C*(Y*R-X*XI)
         V01(3)=(SDF-ETA*R)/ETA2P1
         R=-R
         C=(SDF*ETA+R)/(ETA2P1*SQRT(RXY2*(R2+XI2)))
         V02(1)=C*(X*R+Y*XI)
         V02(2)=C*(Y*R-X*XI)
         V02(3)=(SDF-ETA*R)/ETA2P1
         IF (ABS(SDF).LT.1.0) THEN
            N=1
         ELSE
            N=2
         END IF
      ELSE
         N=0
      END IF

      END
      SUBROUTINE sla_UE2EL (U, JFORMR, &
                           JFORM, EPOCH, ORBINC, ANODE, PERIH, &
                           AORQ, E, AORL, DM, JSTAT)
!+
!     - - - - - -
!      U E 2 E L
!     - - - - - -
!
!  Transform universal elements into conventional heliocentric
!  osculating elements.
!
!  Given:
!     U         d(13)  universal orbital elements (Note 1)
!
!                 (1)  combined mass (M+m)
!                 (2)  total energy of the orbit (alpha)
!                 (3)  reference (osculating) epoch (t0)
!               (4-6)  position at reference epoch (r0)
!               (7-9)  velocity at reference epoch (v0)
!                (10)  heliocentric distance at reference epoch
!                (11)  r0.v0
!                (12)  date (t)
!                (13)  universal eccentric anomaly (psi) of date, approx
!
!     JFORMR    i      requested element set (1-3; Note 3)
!
!  Returned:
!     JFORM     d      element set actually returned (1-3; Note 4)
!     EPOCH     d      epoch of elements (TT MJD)
!     ORBINC    d      inclination (radians)
!     ANODE     d      longitude of the ascending node (radians)
!     PERIH     d      longitude or argument of perihelion (radians)
!     AORQ      d      mean distance or perihelion distance (AU)
!     E         d      eccentricity
!     AORL      d      mean anomaly or longitude (radians, JFORM=1,2 only)
!     DM        d      daily motion (radians, JFORM=1 only)
!     JSTAT     i      status:  0 = OK
!                              -1 = illegal combined mass
!                              -2 = illegal JFORMR
!                              -3 = position/velocity out of range
!
!  Notes
!
!  1  The "universal" elements are those which define the orbit for the
!     purposes of the method of universal variables (see reference 2).
!     They consist of the combined mass of the two bodies, an epoch,
!     and the position and velocity vectors (arbitrary reference frame)
!     at that epoch.  The parameter set used here includes also various
!     quantities that can, in fact, be derived from the other
!     information.  This approach is taken to avoiding unnecessary
!     computation and loss of accuracy.  The supplementary quantities
!     are (i) alpha, which is proportional to the total energy of the
!     orbit, (ii) the heliocentric distance at epoch, (iii) the
!     outwards component of the velocity at the given epoch, (iv) an
!     estimate of psi, the "universal eccentric anomaly" at a given
!     date and (v) that date.
!
!  2  The universal elements are with respect to the mean equator and
!     equinox of epoch J2000.  The orbital elements produced are with
!     respect to the J2000 ecliptic and mean equinox.
!
!  3  Three different element-format options are supported:
!
!     Option JFORM=1, suitable for the major planets:
!
!     EPOCH  = epoch of elements (TT MJD)
!     ORBINC = inclination i (radians)
!     ANODE  = longitude of the ascending node, big omega (radians)
!     PERIH  = longitude of perihelion, curly pi (radians)
!     AORQ   = mean distance, a (AU)
!     E      = eccentricity, e
!     AORL   = mean longitude L (radians)
!     DM     = daily motion (radians)
!
!     Option JFORM=2, suitable for minor planets:
!
!     EPOCH  = epoch of elements (TT MJD)
!     ORBINC = inclination i (radians)
!     ANODE  = longitude of the ascending node, big omega (radians)
!     PERIH  = argument of perihelion, little omega (radians)
!     AORQ   = mean distance, a (AU)
!     E      = eccentricity, e
!     AORL   = mean anomaly M (radians)
!
!     Option JFORM=3, suitable for comets:
!
!     EPOCH  = epoch of perihelion (TT MJD)
!     ORBINC = inclination i (radians)
!     ANODE  = longitude of the ascending node, big omega (radians)
!     PERIH  = argument of perihelion, little omega (radians)
!     AORQ   = perihelion distance, q (AU)
!     E      = eccentricity, e
!
!  4  It may not be possible to generate elements in the form
!     requested through JFORMR.  The caller is notified of the form
!     of elements actually returned by means of the JFORM argument:
!
!      JFORMR   JFORM     meaning
!
!        1        1       OK - elements are in the requested format
!        1        2       never happens
!        1        3       orbit not elliptical
!
!        2        1       never happens
!        2        2       OK - elements are in the requested format
!        2        3       orbit not elliptical
!
!        3        1       never happens
!        3        2       never happens
!        3        3       OK - elements are in the requested format
!
!  5  The arguments returned for each value of JFORM (cf Note 6: JFORM
!     may not be the same as JFORMR) are as follows:
!
!         JFORM         1              2              3
!         EPOCH         t0             t0             T
!         ORBINC        i              i              i
!         ANODE         Omega          Omega          Omega
!         PERIH         curly pi       omega          omega
!         AORQ          a              a              q
!         E             e              e              e
!         AORL          L              M              -
!         DM            n              -              -
!
!     where:
!
!         t0           is the epoch of the elements (MJD, TT)
!         T              "    epoch of perihelion (MJD, TT)
!         i              "    inclination (radians)
!         Omega          "    longitude of the ascending node (radians)
!         curly pi       "    longitude of perihelion (radians)
!         omega          "    argument of perihelion (radians)
!         a              "    mean distance (AU)
!         q              "    perihelion distance (AU)
!         e              "    eccentricity
!         L              "    longitude (radians, 0-2pi)
!         M              "    mean anomaly (radians, 0-2pi)
!         n              "    daily motion (radians)
!         -             means no value is set
!
!  6  At very small inclinations, the longitude of the ascending node
!     ANODE becomes indeterminate and under some circumstances may be
!     set arbitrarily to zero.  Similarly, if the orbit is close to
!     circular, the true anomaly becomes indeterminate and under some
!     circumstances may be set arbitrarily to zero.  In such cases,
!     the other elements are automatically adjusted to compensate,
!     and so the elements remain a valid description of the orbit.
!
!  References:
!
!     1  Sterne, Theodore E., "An Introduction to Celestial Mechanics",
!        Interscience Publishers Inc., 1960.  Section 6.7, p199.
!
!     2  Everhart, E. & Pitkin, E.T., Am.J.Phys. 51, 712, 1983.
!
!  Called:  sla_PV2EL
!
!  P.T.Wallace   Starlink   18 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION U(13)
      INTEGER JFORMR,JFORM
      DOUBLE PRECISION EPOCH,ORBINC,ANODE,PERIH,AORQ,E,AORL,DM
      INTEGER JSTAT

!  Gaussian gravitational constant (exact)
      DOUBLE PRECISION GCON
      PARAMETER (GCON=0.01720209895D0)

!  Canonical days to seconds
      DOUBLE PRECISION CD2S
      PARAMETER (CD2S=GCON/86400D0)

      INTEGER I
      DOUBLE PRECISION PMASS,DATE,PV(6)


!  Unpack the universal elements.
      PMASS = U(1)-1D0
      DATE = U(3)
      DO I=1,3
         PV(I) = U(I+3)
         PV(I+3) = U(I+6)*CD2S
      END DO

!  Convert the position and velocity etc into conventional elements.
      CALL sla_PV2EL(PV,DATE,PMASS,JFORMR,JFORM,EPOCH,ORBINC,ANODE, &
                    PERIH,AORQ,E,AORL,DM,JSTAT)

      END
      SUBROUTINE sla_UE2PV (DATE, U, PV, JSTAT)
!+
!     - - - - - -
!      U E 2 P V
!     - - - - - -
!
!  Heliocentric position and velocity of a planet, asteroid or comet,
!  starting from orbital elements in the "universal variables" form.
!
!  Given:
!     DATE     d       date, Modified Julian Date (JD-2400000.5)
!
!  Given and returned:
!     U        d(13)   universal orbital elements (updated; Note 1)
!
!       given    (1)   combined mass (M+m)
!         "      (2)   total energy of the orbit (alpha)
!         "      (3)   reference (osculating) epoch (t0)
!         "    (4-6)   position at reference epoch (r0)
!         "    (7-9)   velocity at reference epoch (v0)
!         "     (10)   heliocentric distance at reference epoch
!         "     (11)   r0.v0
!     returned  (12)   date (t)
!         "     (13)   universal eccentric anomaly (psi) of date
!
!  Returned:
!     PV       d(6)    position (AU) and velocity (AU/s)
!     JSTAT    i       status:  0 = OK
!                              -1 = radius vector zero
!                              -2 = failed to converge
!
!  Notes
!
!  1  The "universal" elements are those which define the orbit for the
!     purposes of the method of universal variables (see reference).
!     They consist of the combined mass of the two bodies, an epoch,
!     and the position and velocity vectors (arbitrary reference frame)
!     at that epoch.  The parameter set used here includes also various
!     quantities that can, in fact, be derived from the other
!     information.  This approach is taken to avoiding unnecessary
!     computation and loss of accuracy.  The supplementary quantities
!     are (i) alpha, which is proportional to the total energy of the
!     orbit, (ii) the heliocentric distance at epoch, (iii) the
!     outwards component of the velocity at the given epoch, (iv) an
!     estimate of psi, the "universal eccentric anomaly" at a given
!     date and (v) that date.
!
!  2  The companion routine is sla_EL2UE.  This takes the conventional
!     orbital elements and transforms them into the set of numbers
!     needed by the present routine.  A single prediction requires one
!     one call to sla_EL2UE followed by one call to the present routine;
!     for convenience, the two calls are packaged as the routine
!     sla_PLANEL.  Multiple predictions may be made by again
!     calling sla_EL2UE once, but then calling the present routine
!     multiple times, which is faster than multiple calls to sla_PLANEL.
!
!     It is not obligatory to use sla_EL2UE to obtain the parameters.
!     However, it should be noted that because sla_EL2UE performs its
!     own validation, no checks on the contents of the array U are made
!     by the present routine.
!
!  3  DATE is the instant for which the prediction is required.  It is
!     in the TT timescale (formerly Ephemeris Time, ET) and is a
!     Modified Julian Date (JD-2400000.5).
!
!  4  The universal elements supplied in the array U are in canonical
!     units (solar masses, AU and canonical days).  The position and
!     velocity are not sensitive to the choice of reference frame.  The
!     sla_EL2UE routine in fact produces coordinates with respect to the
!     J2000 equator and equinox.
!
!  5  The algorithm was originally adapted from the EPHSLA program of
!     D.H.P.Jones (private communication, 1996).  The method is based
!     on Stumpff's Universal Variables.
!
!  Reference:  Everhart, E. & Pitkin, E.T., Am.J.Phys. 51, 712, 1983.
!
!  P.T.Wallace   Starlink   19 March 1999
!
!  Copyright (C) 1999 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,U(13),PV(6)
      INTEGER JSTAT

!  Gaussian gravitational constant (exact)
      DOUBLE PRECISION GCON
      PARAMETER (GCON=0.01720209895D0)

!  Canonical days to seconds
      DOUBLE PRECISION CD2S
      PARAMETER (CD2S=GCON/86400D0)

!  Test value for solution and maximum number of iterations
      DOUBLE PRECISION TEST
      INTEGER NITMAX
      PARAMETER (TEST=1D-13,NITMAX=20)

      INTEGER I,NIT,N

      DOUBLE PRECISION CM,ALPHA,T0,P0(3),V0(3),R0,SIGMA0,T,PSI,DT,W, &
                      TOL,PSJ,PSJ2,BETA,S0,S1,S2,S3,FF,R,F,G,FD,GD



!  Unpack the parameters.
      CM = U(1)
      ALPHA = U(2)
      T0 = U(3)
      DO I=1,3
         P0(I) = U(I+3)
         V0(I) = U(I+6)
      END DO
      R0 = U(10)
      SIGMA0 = U(11)
      T = U(12)
      PSI = U(13)

!  Approximately update the universal eccentric anomaly.
      PSI = PSI+(DATE-T)*GCON/R0

!  Time from reference epoch to date (in Canonical Days: a canonical
!  day is 58.1324409... days, defined as 1/GCON).
      DT = (DATE-T0)*GCON

!  Refine the universal eccentric anomaly.
      NIT = 1
      W = 1D0
      TOL = 0D0
      DO WHILE (ABS(W).GE.TOL)

!     Form half angles until BETA small enough.
         N = 0
         PSJ = PSI
         PSJ2 = PSJ*PSJ
         BETA = ALPHA*PSJ2
         DO WHILE (ABS(BETA).GT.0.7D0)
            N = N+1
            BETA = BETA/4D0
            PSJ = PSJ/2D0
            PSJ2 = PSJ2/4D0
         END DO

!     Calculate Universal Variables S0,S1,S2,S3 by nested series.
         S3 = PSJ*PSJ2*((((((BETA/210D0+1D0) &
                           *BETA/156D0+1D0) &
                           *BETA/110D0+1D0) &
                           *BETA/72D0+1D0) &
                           *BETA/42D0+1D0) &
                           *BETA/20D0+1D0)/6D0
         S2 = PSJ2*((((((BETA/182D0+1D0) &
                       *BETA/132D0+1D0) &
                       *BETA/90D0+1D0) &
                       *BETA/56D0+1D0) &
                       *BETA/30D0+1D0) &
                       *BETA/12D0+1D0)/2D0
         S1 = PSJ+ALPHA*S3
         S0 = 1D0+ALPHA*S2

!     Undo the angle-halving.
         TOL = TEST
         DO WHILE (N.GT.0)
            S3 = 2D0*(S0*S3+PSJ*S2)
            S2 = 2D0*S1*S1
            S1 = 2D0*S0*S1
            S0 = 2D0*S0*S0-1D0
            PSJ = PSJ+PSJ
            TOL = TOL+TOL
            N = N-1
         END DO

!     Improve the approximation to PSI.
         FF = R0*S1+SIGMA0*S2+CM*S3-DT
         R = R0*S0+SIGMA0*S1+CM*S2
         IF (R.EQ.0D0) GO TO 9010
         W = FF/R
         PSI = PSI-W

!     Next iteration, unless too many already.
         IF (NIT.GE.NITMAX) GO TO 9020
         NIT = NIT+1
      END DO

!  Project the position and velocity vectors (scaling velocity to AU/s).
      W = CM*S2
      F = 1D0-W/R0
      G = DT-CM*S3
      FD = -CM*S1/(R0*R)
      GD = 1D0-W/R
      DO I=1,3
         PV(I) = P0(I)*F+V0(I)*G
         PV(I+3) = CD2S*(P0(I)*FD+V0(I)*GD)
      END DO

!  Update the parameters to allow speedy prediction of PSI next time.
      U(12) = DATE
      U(13) = PSI

!  OK exit.
      JSTAT = 0
      GO TO 9999

!  Null radius vector.
 9010 CONTINUE
      JSTAT = -1
      GO TO 9999

!  Failed to converge.
 9020 CONTINUE
      JSTAT = -2

 9999 CONTINUE
      END
      SUBROUTINE sla_UNPCD ( DISCO, X, Y )
!+
!     - - - - - -
!      U N P C D
!     - - - - - -
!
!  Remove pincushion/barrel distortion from a distorted [x,y] to give
!  tangent-plane [x,y].
!
!  Given:
!     DISCO    d      pincushion/barrel distortion coefficient
!     X,Y      d      distorted coordinates
!
!  Returned:
!     X,Y      d      tangent-plane coordinates
!
!  Notes:
!
!  1)  The distortion is of the form RP = R*(1+C*R^2), where R is
!      the radial distance from the tangent point, C is the DISCO
!      argument, and RP is the radial distance in the presence of
!      the distortion.
!
!  2)  For pincushion distortion, C is +ve;  for barrel distortion,
!      C is -ve.
!
!  3)  For X,Y in "radians" - units of one projection radius,
!      which in the case of a photograph is the focal length of
!      the camera - the following DISCO values apply:
!
!          Geometry          DISCO
!
!          astrograph         0.0
!          Schmidt           -0.3333
!          AAT PF doublet  +147.069
!          AAT PF triplet  +178.585
!          AAT f/8          +21.20
!          JKT f/8          +13.32
!
!  4)  The present routine is a rigorous inverse of the companion
!      routine sla_PCD.  The expression for RP in Note 1 is rewritten
!      in the form x^3+a*x+b=0 and solved by standard techniques.
!
!  5)  Cases where the cubic has multiple real roots can sometimes
!      occur, corresponding to extreme instances of barrel distortion
!      where up to three different undistorted [X,Y]s all produce the
!      same distorted [X,Y].  However, only one solution is returned,
!      the one that produces the smallest change in [X,Y].
!
!  P.T.Wallace   Starlink   3 September 2000
!
!  Copyright (C) 2000 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION DISCO,X,Y

      DOUBLE PRECISION THIRD
      PARAMETER (THIRD=1D0/3D0)
      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=6.283185307179586476925286766559D0)

      DOUBLE PRECISION RP,Q,R,D,W,S,T,F,C,T3,F1,F2,F3,W1,W2,W3



!  Distance of the point from the origin.
      RP = SQRT(X*X+Y*Y)

!  If zero, or if no distortion, no action is necessary.
      IF (RP.NE.0D0.AND.DISCO.NE.0D0) THEN

!     Begin algebraic solution.
         Q = 1D0/(3D0*DISCO)
         R = RP/(2D0*DISCO)
         W = Q*Q*Q+R*R

!     Continue if one real root, or three of which only one is positive.
         IF (W.GE.0D0) THEN
            D = SQRT(W)
            W = R+D
            S = SIGN(ABS(W)**THIRD,W)
            W = R-D
            T = SIGN((ABS(W))**THIRD,W)
            F = S+T
         ELSE

!        Three different real roots:  use geometrical method instead.
            W = 2D0/SQRT(-3D0*DISCO)
            C = 4D0*RP/(DISCO*W*W*W)
            S = SQRT(1D0-MIN(C*C,1D0))
            T3 = ATAN2(S,C)

!        The three solutions.
            F1 = W*COS((D2PI-T3)/3D0)
            F2 = W*COS((T3)/3D0)
            F3 = W*COS((D2PI+T3)/3D0)

!        Pick the one that moves [X,Y] least.
            W1 = ABS(F1-RP)
            W2 = ABS(F2-RP)
            W3 = ABS(F3-RP)
            IF (W1.LT.W2) THEN
               IF (W1.LT.W3) THEN
                  F = F1
               ELSE
                  F = F3
               END IF
            ELSE
               IF (W2.LT.W3) THEN
                  F = F2
               ELSE
                  F = F3
               END IF
            END IF

         END IF

!     Remove the distortion.
         F = F/RP
         X = F*X
         Y = F*Y

      END IF

      END
      SUBROUTINE sla_V2TP (V, V0, XI, ETA, J)
!+
!     - - - - -
!      V 2 T P
!     - - - - -
!
!  Given the direction cosines of a star and of the tangent point,
!  determine the star's tangent-plane coordinates.
!
!  (single precision)
!
!  Given:
!     V         r(3)    direction cosines of star
!     V0        r(3)    direction cosines of tangent point
!
!  Returned:
!     XI,ETA    r       tangent plane coordinates of star
!     J         i       status:   0 = OK
!                                 1 = error, star too far from axis
!                                 2 = error, antistar on tangent plane
!                                 3 = error, antistar too far from axis
!
!  Notes:
!
!  1  If vector V0 is not of unit length, or if vector V is of zero
!     length, the results will be wrong.
!
!  2  If V0 points at a pole, the returned XI,ETA will be based on the
!     arbitrary assumption that the RA of the tangent point is zero.
!
!  3  This routine is the Cartesian equivalent of the routine sla_S2TP.
!
!  P.T.Wallace   Starlink   27 November 1996
!
!  Copyright (C) 1996 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL V(3),V0(3),XI,ETA
      INTEGER J

      REAL X,Y,Z,X0,Y0,Z0,R2,R,W,D

      REAL TINY
      PARAMETER (TINY=1E-6)


      X=V(1)
      Y=V(2)
      Z=V(3)
      X0=V0(1)
      Y0=V0(2)
      Z0=V0(3)
      R2=X0*X0+Y0*Y0
      R=SQRT(R2)
      IF (R.EQ.0.0) THEN
         R=1E-20
         X0=R
      END IF
      W=X*X0+Y*Y0
      D=W+Z*Z0
      IF (D.GT.TINY) THEN
         J=0
      ELSE IF (D.GE.0.0) THEN
         J=1
         D=TINY
      ELSE IF (D.GT.-TINY) THEN
         J=2
         D=-TINY
      ELSE
         J=3
      END IF
      D=D*R
      XI=(Y*X0-X*Y0)/D
      ETA=(Z*R2-Z0*W)/D

      END
      REAL FUNCTION sla_VDV (VA, VB)
!+
!     - - - -
!      V D V
!     - - - -
!
!  Scalar product of two 3-vectors  (single precision)
!
!  Given:
!      VA      real(3)     first vector
!      VB      real(3)     second vector
!
!  The result is the scalar product VA.VB (single precision)
!
!  P.T.Wallace   Starlink   November 1984
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL VA(3),VB(3)


      sla_VDV=VA(1)*VB(1)+VA(2)*VB(2)+VA(3)*VB(3)

      END
      SUBROUTINE sla_VN (V, UV, VM)
!+
!     - - -
!      V N
!     - - -
!
!  Normalizes a 3-vector also giving the modulus (single precision)
!
!  Given:
!     V       real(3)      vector
!
!  Returned:
!     UV      real(3)      unit vector in direction of V
!     VM      real         modulus of V
!
!  If the modulus of V is zero, UV is set to zero as well
!
!  P.T.Wallace   Starlink   23 November 1995
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL V(3),UV(3),VM

      INTEGER I
      REAL W1,W2


!  Modulus
      W1=0.0
      DO I=1,3
         W2=V(I)
         W1=W1+W2*W2
      END DO
      W1=SQRT(W1)
      VM=W1

!  Normalize the vector
      IF (W1.LE.0.0) W1=1.0
      DO I=1,3
         UV(I)=V(I)/W1
      END DO

      END
      SUBROUTINE sla_VXV (VA, VB, VC)
!+
!     - - - -
!      V X V
!     - - - -
!
!  Vector product of two 3-vectors (single precision)
!
!  Given:
!      VA      real(3)     first vector
!      VB      real(3)     second vector
!
!  Returned:
!      VC      real(3)     vector result
!
!  P.T.Wallace   Starlink   March 1986
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL VA(3),VB(3),VC(3)

      REAL VW(3)
      INTEGER I


!  Form the vector product VA cross VB
      VW(1)=VA(2)*VB(3)-VA(3)*VB(2)
      VW(2)=VA(3)*VB(1)-VA(1)*VB(3)
      VW(3)=VA(1)*VB(2)-VA(2)*VB(1)

!  Return the result
      DO I=1,3
         VC(I)=VW(I)
      END DO

      END
      SUBROUTINE sla_WAIT (DELAY)
!+
!     - - - - -
!      W A I T
!     - - - - -
!
!  Interval wait
!
!  !!! Version for: SPARC/SunOS4, 
!                   SPARC/Solaris2, 
!                   DEC Mips/Ultrix
!                   DEC AXP/Digital Unix
!                   Intel/Linux
!                   Convex
!
!  Given:
!     DELAY     real      delay in seconds
!
!  Called:  SLEEP (a Fortran Intrinsic on all obove platforms)
!
!  P.T.Wallace   Starlink   22 January 1998
!
!  Copyright (C) 1998 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      REAL DELAY

      CALL SLEEP(NINT(DELAY))

      END
      SUBROUTINE sla_XY2XY (X1,Y1,COEFFS,X2,Y2)
!+
!     - - - - - -
!      X Y 2 X Y
!     - - - - - -
!
!  Transform one [X,Y] into another using a linear model of the type
!  produced by the sla_FITXY routine.
!
!  Given:
!     X1       d        x-coordinate
!     Y1       d        y-coordinate
!     COEFFS  d(6)      transformation coefficients (see note)
!
!  Returned:
!     X2       d        x-coordinate
!     Y2       d        y-coordinate
!
!  The model relates two sets of [X,Y] coordinates as follows.
!  Naming the elements of COEFFS:
!
!     COEFFS(1) = A
!     COEFFS(2) = B
!     COEFFS(3) = C
!     COEFFS(4) = D
!     COEFFS(5) = E
!     COEFFS(6) = F
!
!  the present routine performs the transformation:
!
!     X2 = A + B*X1 + C*Y1
!     Y2 = D + E*X1 + F*Y1
!
!  See also sla_FITXY, sla_PXY, sla_INVF, sla_DCMPF
!
!  P.T.Wallace   Starlink   5 December 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION X1,Y1,COEFFS(6),X2,Y2


      X2=COEFFS(1)+COEFFS(2)*X1+COEFFS(3)*Y1
      Y2=COEFFS(4)+COEFFS(5)*X1+COEFFS(6)*Y1

      END
      DOUBLE PRECISION FUNCTION sla_ZD (HA, DEC, PHI)
!+
!     - - -
!      Z D
!     - - -
!
!  HA, Dec to Zenith Distance (double precision)
!
!  Given:
!     HA     d     Hour Angle in radians
!     DEC    d     declination in radians
!     PHI    d     observatory latitude in radians
!
!  The result is in the range 0 to pi.
!
!  Notes:
!
!  1)  The latitude must be geodetic.  In critical applications,
!      corrections for polar motion should be applied.
!
!  2)  In some applications it will be important to specify the
!      correct type of hour angle and declination in order to
!      produce the required type of zenith distance.  In particular,
!      it may be important to distinguish between the zenith distance
!      as affected by refraction, which would require the "observed"
!      HA,Dec, and the zenith distance in vacuo, which would require
!      the "topocentric" HA,Dec.  If the effects of diurnal aberration
!      can be neglected, the "apparent" HA,Dec may be used instead of
!      the topocentric HA,Dec.
!
!  3)  No range checking of arguments is done.
!
!  4)  In applications which involve many zenith distance calculations,
!      rather than calling the present routine it will be more efficient
!      to use inline code, having previously computed fixed terms such
!      as sine and cosine of latitude, and perhaps sine and cosine of
!      declination.
!
!  P.T.Wallace   Starlink   3 April 1994
!
!  Copyright (C) 1995 Rutherford Appleton Laboratory
!
!  License:
!    This program is free software; you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation; either version 2 of the License, or
!    (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with this program (see SLA_CONDITIONS); if not, write to the 
!    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!    Boston, MA  02111-1307  USA
!
!-

      IMPLICIT NONE

      DOUBLE PRECISION HA,DEC,PHI

      DOUBLE PRECISION SH,CH,SD,CD,SP,CP,X,Y,Z


      SH=SIN(HA)
      CH=COS(HA)
      SD=SIN(DEC)
      CD=COS(DEC)
      SP=SIN(PHI)
      CP=COS(PHI)
      X=CH*CD*SP-SD*CP
      Y=SH*CD
      Z=CH*CD*CP+SD*SP
      sla_ZD=ATAN2(SQRT(X*X+Y*Y),Z)

      END
