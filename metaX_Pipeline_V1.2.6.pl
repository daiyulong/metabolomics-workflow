#!/usr/bin/perl -w
use strict;
use File::Path;
use Getopt::Long;
use FindBin '$Bin';
use Cwd qw(abs_path);

my $Rscript="/ifs5/ST_METABO/PMO/2015_project/pipeline/software/3.3.3/bin/Rscript";
#my $dir="/ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport";

my ($conf,$runMetaX);
GetOptions(
    "conf=s" => \$conf,
    "runMetaX=s" => \$runMetaX,
);
die"
Description: Untarget metabolomics data analysis based on metaX software and generate metabolomics report
    Usage:
    -conf   <file>  a .conf file
    -runMetaX   <str>   YES or NO
e.g:
    perl $0 -conf pipeline.conf -runMetaX YES\n" unless ($conf and $runMetaX);

### read config
my $config=&readConf($conf);
my %config=%$config;

### check and store parameters in .conf
my $metaXR_pos=$config{'MetaXR_pos'}if($config{'MetaXR_pos'});
my $metaXR_neg=$config{'MetaXR_neg'}if($config{'MetaXR_neg'});
my $metaX_pos=$config{'MetaX_pos'}if($config{'MetaX_pos'});
my $metaX_neg=$config{'MetaX_neg'}if($config{'MetaX_neg'});
my $pre_pos=$config{'Pre_pos'}if($config{'Pre_pos'});
my $pre_neg=$config{'Pre_neg'}if($config{'Pre_neg'});
my $VIP=$config{'VIP'}if($config{'VIP'});
my $species=$config{'Species'}if($config{'Species'});
my $testPvalue=$config{'TestPvalue'}if($config{'TestPvalue'});
my $meas_pos=$config{'Meas_pos'}if($config{'Meas_pos'});
my $meas_neg=$config{'Meas_neg'}if($config{'Meas_neg'});
my $group=$config{'Group'}if($config{'Group'});
my $out=$config{'Output'}if($config{'Output'});

if($out){
    mkpath $out;
    $out=abs_path $out;
}else{print "unexist $out!\n";}

### generate shells of all modules
my $cmd;
open SH,">$out/shell.log";

### create dirctory
my $log="$out/logFile";
mkpath $log;

### execute metaX.R
my $metaXFlag=0;
if($metaXR_pos && $metaXR_neg){
    ### pos
    $cmd="$Rscript $metaXR_pos";
    print SH "#=== metaX.R ===#\n$cmd\n\n";
    if($runMetaX=~/YES/i){
        `$cmd 1>$log/metaX.R.pos.loge 2>$log/metaX.R.pos.logt`;
    }
    ### neg
    $cmd="$Rscript $metaXR_neg";
    print SH "$cmd\n\n";
    if($runMetaX=~/YES/i){
        `$cmd 1>$log/metaX.R.neg.loge 2>$log/metaX.R.neg.logt`;
    }
    
    $metaXFlag=1;
}
if(!$metaXR_pos && $metaXR_neg){
    $cmd="$Rscript $metaXR_neg";
    print SH "#=== metaX.R neg ===#\n$cmd\n\n";
    if($runMetaX=~/YES/i){
       `$cmd 1>$log/metaX.R.neg.loge 2>$log/metaX.R.neg.logt`;
    }
    $metaXFlag=1;
}
if($metaXR_pos && !$metaXR_neg){
    $cmd="$Rscript $metaXR_pos";
    print SH "#=== metaX.R pos ===#\n$cmd\n\n";
    if($runMetaX=~/YES/i){
       `$cmd 1>$log/metaX.R.pos.loge 2>$log/metaX.R.pos.logt`;
    }
    $metaXFlag=1;
}
print "#======== metaX.R finished ==========#\n";


### summary m/z information,draw volcano graph and heatmap graph
my $statFlag=0;
my $statPos="$out/statPos";
my $statNeg="$out/statNeg";
while($metaXFlag){
    if($metaX_pos && $metaX_neg){
        mkpath $statPos;
        mkpath $statNeg;
        ### pos
        $cmd="perl $Bin/Stat_V1.6.pl -meas $meas_pos -metax $metaX_pos -prefix $pre_pos -mode pos -test $testPvalue -vip $VIP -out $statPos";
        print SH "#=== Stat.pl ===#\n$cmd\n\n";
        `$cmd 1>$log/Stat.pos.loge 2>$log/Stat.pos.logt`;
        ### neg
        $cmd="perl $Bin/Stat_V1.6.pl -meas $meas_neg -metax $metaX_neg -prefix $pre_neg -mode neg -test $testPvalue -vip $VIP -out $statNeg";
        print SH "$cmd\n\n";
        `$cmd 1>$log/Stat.neg.loge 2>$log/Stat.neg.logt`;
        ### set flag
        $statFlag=1;
        $metaXFlag=0;
    }
    if($metaX_pos && !$metaX_neg){
        mkpath $statPos;

        $cmd="perl $Bin/Stat_V1.6.pl -meas $meas_pos -metax $metaX_pos -prefix $pre_pos -mode pos -test $testPvalue -vip $VIP -out $statPos";
        print SH "#=== Stat.pl pos ===#\n$cmd\n\n";
        `$cmd 1>$log/Stat.pos.loge 2>$log/Stat.pos.logt`;

        $statFlag=1;
        $metaXFlag=0;
    }
    if(!$metaX_pos && $metaX_neg){
        mkpath $statNeg;
        
        $cmd="perl $Bin/Stat_V1.6.pl -meas $meas_neg -metax $metaX_neg -prefix $pre_neg -mode neg -test $testPvalue -vip $VIP -out $statNeg";
        print SH "#=== Stat.pl neg ===#\n$cmd\n\n";
        `$cmd 1>$log/Stat.neg.loge 2>$log/Stat.neg.logt`;

        $statFlag=1;
        $metaXFlag=0;
    }
}
print "#======== Stat.pl finished ===========#\n";


### pathway analysis
my $pathwayFlag=0;
my $pathwayPos="$out/pathwayPos";
my $pathwayNeg="$out/pathwayNeg";
while($statFlag){
    if($metaX_pos && $metaX_neg){
        mkpath $pathwayPos;
        mkpath $pathwayNeg;
        ### pathway pos
        $cmd="perl $Bin/metaX_HMDB_KEGG_pathway_V1.3.pl -total $statPos/quant-identification.txt -diff $statPos -species $species -outdir $pathwayPos";
        print SH "#=== metaX_HMDB_KEGG_pathway.pl ===#\n$cmd\n\n";
        `$cmd 1>$log/pathway.pos.loge 2>$log/pathway.pos.logt`;
        ### pathway neg
        $cmd="perl $Bin/metaX_HMDB_KEGG_pathway_V1.3.pl -total $statNeg/quant-identification.txt -diff $statNeg -species $species -outdir $pathwayNeg";
        print SH "$cmd\n\n";
        `$cmd 1>$log/pathway.neg.loge 2>$log/pathway.neg.logt`;

        $pathwayFlag=1;
        $statFlag=0;
    }
    if($metaX_pos && !$metaX_neg){
        mkpath $pathwayPos;
        $cmd="perl $Bin/metaX_HMDB_KEGG_pathway_V1.3.pl -total $statPos/quant-identification.txt -diff $statPos -species $species -outdir $pathwayPos";
        print SH "#=== metaX_HMDB_KEGG_pathway.pl pos===#\n$cmd\n\n";
        `$cmd 1>$log/pathway.pos.loge 2>$log/pathway.pos.logt`;

        $pathwayFlag=1;
        $statFlag=0;
    }
    if(!$metaX_pos && $metaX_neg){
        mkpath $pathwayNeg;
        $cmd="perl $Bin/metaX_HMDB_KEGG_pathway_V1.3.pl -total $statNeg/quant-identification.txt -diff $statNeg -species $species -outdir $pathwayNeg";
        print SH "#=== metaX_HMDB_KEGG_pathway.pl neg ===#\n$cmd\n\n";
        `$cmd 1>$log/pathway.neg.loge 2>$log/pathway.neg.logt`;

        $pathwayFlag=1;
        $statFlag=0;
    }
}
print "#======== pathway analysis finished ===========#\n";


### generate .arf files and BGI_result 
while($pathwayFlag){
    $cmd="perl $Bin/metaX_getArf_V1.2.pl -conf $conf";
    print SH "#=== metaX_getArf_V1.2.pl ===#\n$cmd\n\n";
    `$cmd 1>$log/upload.loge 2>$log/upload.logt`;    
    $pathwayFlag=0;
}

print "#======== metaX_getArf finished ===================#\n";

#============= function:read .conf file ========
sub readConf{
    my ($confFile)=@_;
    my %hash;
    open IN,"<$confFile" or die $!;
    while(<IN>){
        chomp;
        next if(/^\s*$/ || /^\s*\#/);
        $_=~s/^\s*//;
        $_=~s/#(.)*//;
        $_=~s/\s*$//;
        if(/^(\w+)\s*=\s*(.*)$/xms){
            next if ($2=~/^\s*$/);
            my $key=$1;
            my $value=$2;
            $value=~s/\s*$//;
            $hash{$key}=$value;
        }
    }
    return \%hash;
}
