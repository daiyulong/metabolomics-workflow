#!/usr/bin/perl -w
use strict;

die "Usage:\nperl $0 <mode|pos or neg> <in|.raw> <out|outDir>\n"unless @ARGV==3;

my ($mode,$raw,$outDir)=@ARGV[0,1,2];
`mkdir -p $outDir`unless -d $outDir;

my ($m,$n,$k,$massLow,$massHigh,$polarity,$analyser,$capillary,$sampleCone,$sourceTem,$sourceOff,$desolTemp,$coneGasFlow,$scanTime,$rampLow,$rampHigh,$desolGas);

open IN,"$raw/_INLET.INF"or die "no $raw/_INLET.INF such file!";
open TO,">$outDir/Elution_$mode.txt"or die "can't create $outDir/Elution.txt file!";
while(<IN>){
    chomp;
    my @arr=split /\s+/;
    if($_=~/Time\(min\)/){print TO "$arr[1]\t$arr[2] $arr[3]\t$arr[4]\t$arr[5]\t$arr[6]\n";next;}
    if($_=~/^\s+\d+\./){print TO "$arr[2]\t$arr[3]\t$arr[4]\t$arr[5]\t$arr[6]\n";next;}
    if($_=~/^Run Events/){last;}
}
close TO;
close IN;

my $flag=0;
open IN,"<$raw/_extern.inf"or die "no $raw/_ertern.inf file!";
open TO,">$outDir/MSparameter_$mode.txt"or die "can't create $outDir/MSparameter.txt file!";
print TO "MS parameter\tvalue\tMS paramameter\tvalue\n";
while(<IN>){
    chomp;
    my @arr=split /\s+/;
    if($_=~/^Acquisition\s+mass\s+range/){$flag=1;next;}
    if($flag==1){
        if($_=~/^Start\s+mass/i){$massLow=$arr[2];next;}
        if($_=~/^End\s+mass/i){$massHigh=$arr[2];}
        $flag=0;next;
    }
    if($_=~/^polarity/i){$polarity=$arr[1];next;}
    if($_=~/^analyser/i){$analyser=$arr[1];next;}
    if($_=~/^capillary/i){$capillary=$arr[2];next;}
    if($_=~/^sampling cone/i){$sampleCone=$arr[2];next;}
    if($_=~/^source Temperature/i){$sourceTem=$arr[3];next;}
    if($_=~/^source Offset/i){$sourceOff=$arr[2];next;}
    if($_=~/^desolvation Temp/i){$desolTemp=$arr[3];next;}
    if($_=~/^desolvation Gas Flow/i){$desolGas=$arr[4];next;}
    if($_=~/^cone Gas Flow/i){$coneGasFlow=$arr[4];next;}
    if($_=~/^survey scan time/i){$scanTime=$arr[3];next;}
    if($_=~/^Ramp High Energy from/i){$rampLow=$arr[4];$rampHigh=$arr[6];next;}
}
print TO "Capillary(kV):\t$capillary\tIonization mode:\t$polarity\nSampling cone:\t$sampleCone\tTOF acquisition mode:\t$analyser\nSource temperature(℃):\t$sourceTem\tAcquisition method:\tContinuum MSE\nDesolvation temperature(℃):\t$desolTemp\tTOF mass range(Da):\t$massLow-$massHigh\nDesolvation/Cone gas(L/Hr):\t$desolGas/$coneGasFlow\tScan time(s):\t$scanTime\nSource offset:\t$sourceOff\tCollision energy function 2:\tTrap CE ramp $rampLow to $rampHigh eV";
close IN;
close TO;
