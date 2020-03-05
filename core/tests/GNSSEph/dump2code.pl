#!/usr/bin/perl

# This script converts the output from rawNavDump to C++ code that can
# be inserted into BDSEphemeris_T::wut()

use warnings;
use strict;

my ($prn, $health, $tocStr, $toeStr, $af0, $af1, $af2, $A, $Adot, $dn, $dndot,
    $ecc, $w, $M0, $OMEGA0, $OMEGAdot, $i0, $idot, $crs, $crc, $cis, $cic,
    $cus, $cuc);
my ($m, $d, $y, $hr, $min, $sec);

while (<>)
{
    chomp;
    my @arr = split(/ +/);
    if (/^PRN : /)
    {
        $prn = $arr[2];
    }
    elsif (/^Health bit/)
    {
        $health = hex($arr[$#arr]);
    }
    elsif (/^Clock Epoch:/)
    {
        $tocStr = $arr[$#arr-1] . " " . $arr[$#arr];
    }
    elsif (/^Eph Epoch:/)
    {
        $toeStr = $arr[$#arr-1] . " " . $arr[$#arr];
    }
    elsif (/^Bias T0:/)
    {
        $af0 = $arr[2];
    }
    elsif (/^Drift:/)
    {
        $af1 = $arr[1];
    }
    elsif (/^Drift rate:/)
    {
        $af2 = $arr[2];
    }
    elsif (/^Semi-major axis:/)
    {
        $A = $arr[2];
        $Adot = $arr[4];
    }
    elsif (/^Motion correction:/)
    {
        $dn = $arr[2];
        $dndot = $arr[4];
    }
    elsif (/^Eccentricity:/)
    {
        $ecc = $arr[1];
    }
    elsif (/^Arg of perigee:/)
    {
        $w = $arr[3];
    }
    elsif (/^Mean anomaly at epoch:/)
    {
        $M0 = $arr[4];
    }
    elsif (/^Right ascension:/)
    {
        $OMEGA0 = $arr[2];
        $OMEGAdot= $arr[4];
    }
    elsif (/^Inclination:/)
    {
        $i0 = $arr[1];
        $idot = $arr[3];
    }
    elsif (/^Radial *Sine:/)
    {
        $crs = $arr[2];
        $crc = $arr[5];
    }
    elsif (/^Inclination *Sine:/)
    {
        $cis = $arr[2];
        $cic = $arr[5];
    }
    elsif (/^In-track *Sine:/)
    {
        $cus = $arr[2];
        $cuc = $arr[5];
        printf("   try\n   {\n");
        printf("      gpstk::BDSEphemeris oe;\n");
        printf("      oe.Cuc      = $cuc;\n");
        printf("      oe.Cus      = $cus;\n");
        printf("      oe.Crc      = $crc;\n");
        printf("      oe.Crs      = $crs;\n");
        printf("      oe.Cic      = $cic;\n");
        printf("      oe.Cis      = $cis;\n");
        printf("      oe.M0       = $M0;\n");
        printf("      oe.dn       = $dn;\n");
        printf("      oe.dndot    = $dndot;\n");
        printf("      oe.ecc      = $ecc;\n");
        printf("      oe.A        = $A;\n");
        printf("      oe.Adot     = $Adot;\n");
        printf("      oe.OMEGA0   = $OMEGA0;\n");
        printf("      oe.i0       = $i0;\n");
        printf("      oe.w        = $w;\n");
        printf("      oe.OMEGAdot = $OMEGAdot;\n");
        printf("      oe.idot     = $idot;\n");
        ($m, $d, $y, $hr, $min, $sec) = split(/[\/ :]/, $tocStr);
        printf("      oe.ctToc    = gpstk::CivilTime(%d,%d,%d,%d,%d,%d,gpstk::TimeSystem::BDT);\n",$y,$m,$d,$hr,$min,$sec);
        printf("      oe.af0      = $af0;\n");
        printf("      oe.af1      = $af1;\n");
        printf("      oe.af2      = $af2;\n");
        printf("      oe.dataLoadedFlag = true;\n");
        printf("      oe.satID = gpstk::SatID($prn, gpstk::SatID::systemBeiDou);\n");
        ($m, $d, $y, $hr, $min, $sec) = split(/[\/ :]/, $toeStr);
        printf("      oe.ctToe    = gpstk::CivilTime(%d,%d,%d,%d,%d,%d,gpstk::TimeSystem::BDT);\n",$y,$m,$d,$hr,$min,$sec);
        printf("      writeVel(oe);\n");
        printf("   }\n");
        printf("   catch(...)\n");
        printf("   {\n");
        printf("      cerr << \"exception\" << endl;\n");
        printf("   }\n");
    }
}
