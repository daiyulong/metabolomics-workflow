#!/bin/perl
#########################################################################
# Author: ZhanlongMei(meizhanlong@genomics.cn)
# Created Time: Mon 13 Feb 2017 01:38:37 PM CST
# File Name: run_correlation_metaX_xbio.pl
# Description: 
#########################################################################
use strict;
use File::Path;
use Getopt::Long;
use FindBin '$Bin';
use Cwd qw(abs_path);

my $Rscript="/zfssz3/SP_MSI/USER/zengchunwei/software/R-3.4.1/bin/Rscript";

my ($conf);
GetOptions(
    "conf=s" => \$conf,
    );
    die"
    Description: Based on the Project_Information.conf to generate the fellowing files:
	scripts:all R,conf,sh files
	supprot files:Item.txt Progenesis_QI.txt
    Usage:
        -conf   <file>  a .conf file
        e.g:
        perl $0 -conf Project_Information.conf\n" unless $conf;
### read config
my $config=&readConf($conf);
my %config=%$config;
#===============================read conf=================================
my $main_dir=$config{'Main_dir'}if($config{'Main_dir'});
my $pid=$config{'Pid'}if($config{'Pid'});
my $sid=$config{'Sid'}if($config{'Sid'});
my $guest_mail=$config{'Guest_Email'}if($config{'Guest_Email'});
my $sample=$config{'Sample'}if($config{'Sample'});
my $expType=$config{'ExperimentType'}if($config{'ExperimentType'});
my $database=$config{'Database'}if($config{'Database'});
my $species=$config{'Species'}if($config{'Species'});
my $group=$config{'Group'}if($config{'Group'});
my $ex_pca=$config{'Extra_pca_group'}if($config{'Extra_pca_group'});
my $ex_heatmap=$config{'Extra_heatmap_group'}if($config{'Extra_heatmap_group'});
my $raw_pos=$config{'Rawdata_pos'}if($config{'Rawdata_pos'});
my $raw_neg=$config{'Rawdata_neg'}if($config{'Rawdata_neg'});
#=================================other dir==============================
my $CSV="$main_dir/CSV";
my $Script="$main_dir/Script";
my $Personalized_analysis="$main_dir/Personalized_analysis";
my $Quality_control="$main_dir/Quality_control";
my $Submit="$main_dir/Submit";
#=========================sample list meament identification============
my $lneg="$CSV/s_neg.list";
my $lpos="$CSV/s_pos.list";
my $mneg="$CSV/m_neg.csv";
my $mpos="$CSV/m_pos.csv";
my $ineg="$CSV/i_neg.csv";
my $ipos="$CSV/i_pos.csv";
#==========1.读取sample list决定是否做loess，vip用不用，做不做plsda====================
my ($pls,$qcs,$vipv);#plsda,loess,vip
my $listsum="$main_dir/Audit/list.txt";
`/ifs5/ST_METABO/PMO/2015_project/pipeline/software/3.3.3/bin/Rscript /ifs1/ST_PRO/USER/metabolomics/MEIZHANLONG/Program_develop/commercial_project_auto_run/subprogram/list.R $lneg >$listsum`;
my $listc=`/ifs5/ST_METABO/PMO/2015_project/pipeline/software/3.3.3/bin/Rscript /ifs1/ST_PRO/USER/metabolomics/MEIZHANLONG/Program_develop/commercial_project_auto_run/subprogram/list.R $lneg`;
print "============1.do plsda or not;loess or not; vip setting=========\n";
print "$listc\n";
$listc=~/(#?plsdaPara\@do = FALSE)/;
$pls=$1;
$listc=~/qcsc=(\d)/;
$qcs=$1;
$listc=~/VIP=(\d)/;
$vipv=$1;
print "------------\n";
print "在本项目中plsda设置为：$pls\nloess设置为：$qcs\nvip设置为：$vipv\n\n";
#=========================2.生成metaX的R文件 ===============================
sub metaX_r_sh_file{
my ($m,$l,$i,$g,$mode,$out)=@_;
my $R_file = << "POS";
options(bitmapType="cairo");
#############################################################################
library(metaX)
para <- new("metaXpara")
pfile <- "$m"
sfile <- "$l"
idres <- "$i"
para\@outdir <- "metaX_result_$mode"
para\@prefix <- "$mode"
para\@sampleListFile <- sfile
para\@ratioPairs <- "$g"
para <- importDataFromQI(para,file=pfile)
#para <- removeSample(para,rsamples=c("PDB13AY02035","PDB13CP00599","13B0149944"))
#para\@pairTest = TRUE
plsdaPara <- new("plsDAPara")
plsdaPara\@scale = "pareto"
plsdaPara\@cpu = 4
$pls
res <- doQCRLSC(para,cpu=1)
#missValueImputeMethod(para)<-"KNN"
p <- metaXpipe(para,plsdaPara=plsdaPara,missValueRatioQC = 0.5, missValueRatioSample = 0.8,cvFilter=0.3,idres=idres,qcsc=$qcs,scale="pareto",remveOutlier=FALSE,nor.method="pqn",t=1,nor.order = 1,pclean = FALSE,doROC=FALSE)
save(p,file="p1.rda")
sessionInfo()
POS
my $r_file="$out/$mode.R";
open TO, "> $r_file" or die $!;
print TO $R_file;
close TO;
my $run_file="/ifs5/ST_METABO/PMO/2015_project/pipeline/software/3.3.3/bin/Rscript $out/$mode.R 1>$out/$mode.loge 2>$out/$mode.logt";
open TO, "> $out/metaX_run_$mode.sh" or die $!;
print TO $run_file;
close TO;
}
&metaX_r_sh_file($mpos,$lpos,$ipos,$group,"pos","$Script");
&metaX_r_sh_file($mneg,$lneg,$ineg,$group,"neg","$Script");
#=============================Quality_control_sh_file=========================================
if (defined $mneg && defined $lneg){
my $qc_neg_sh="sh /ifs5/ST_METABO/USER/daiyulong/Code/mk_dir_generate/metaX_quality_control_run.sh $lneg $mneg \"$group\" neg $main_dir/Quality_control/neg";
open TO, "> $main_dir/Quality_control/qc_neg_run.sh" or die $!;
print TO $qc_neg_sh;
close TO;
}
if (defined $mpos && defined $lpos){
my $qc_pos_sh="sh /ifs5/ST_METABO/USER/daiyulong/Code/mk_dir_generate/metaX_quality_control_run.sh $lpos $mpos \"$group\" pos $main_dir/Quality_control/pos";
open TO, "> $main_dir/Quality_control/qc_pos_run.sh" or die $!;
print TO $qc_pos_sh;
close TO;
}

#==============================write the conf file=============================================
$group=~s/:/_/g;
print "=========================2.本项目标准分析比较组设置为===============\n";
print "$group\n";
print "===============================注意=================================\n";
print "阳离子TIC图路径：$main_dir/Infor/tic_pos.png\n";
print "阴离子TIC图路径：$main_dir/Infor/tic_neg.png\n\n";
print "请先上传TIC图片再运行metaX_pipeline1.2.3.sh\n";
my $conf = << "CONF";
===========================================================
#   This file is to set parameter for metaX_Pipline.pl and metaX_getArf_V1.0.pl  #
#===========================================================
#================== metaX.R path ===============================
MetaXR_pos = $Script/pos.R
MetaXR_neg = $Script/neg.R
#================ metaX result path ============================
MetaX_pos = $Script/metaX_result_pos
MetaX_neg = $Script/metaX_result_neg
#================ metaX prefix =================================
Pre_pos = pos
Pre_neg = neg
#================ sample and expriment ==================================
Sample = $sample   ### serum , tissue or urine
ExperimentType = $expType    ### lipids or globe
#================ VIP ====================================
VIP = $vipv  ### 1 or 0, 0 indicates VIP will not be taken into account when select different m/z
#================= pathway analysis database ====================
Species = $species
#================== choose Test =================================
Base = $database ### HMDB,KEGG,LipidMaps,...
Test = T  ### T or Wilcoxon
TestPvalue = t.test_p.value_BHcorrect   ### t.test_p.value ,  wilcox.test_p.value , t.test_p.value_BHcorrect or wilcox.test_p.value_BHcorrect
#================== *measurement.csv ============================
Meas_pos = $mpos
Meas_neg = $mneg
#================== sample.list =================================
SampleList_pos = $lpos
SampleList_neg = $lneg
#================== compare group ===============================
Group = $group  ### be consistent with metaX,fold change= 1/2
#================= experiment information file ===================
Item = $main_dir/Infor/Item.txt
ChromColumn = /ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport/Abstract/ChromColumn.txt
ProgenesisQI = $main_dir/Infor/ProgenesisQI.txt
##================= .raw file path =================================
Rawdata_pos = $raw_pos
Rawdata_neg = $raw_neg
############## QC TIC figure ##################
QCTIC_pos = $main_dir/Infor/tic_pos.png
QCTIC_neg = $main_dir/Infor/tic_neg.png
##============== outdir =======================#
Output = $main_dir/Submit
#============== Stat.pl result path ============#
IonStat_pos = $main_dir/Submit/statPos
IonStat_neg = $main_dir/Submit/statNeg
#============== pathway analysis result path =======#
Pathway_pos = $main_dir/Submit/pathwayPos
Pathway_neg = $main_dir/Submit/pathwayNeg
#===================qcsc============================#
Qcsc=$qcs
CONF
my $conf_file="$Script/metaX_pipeline1.2.3.conf";
open TO, "> $conf_file" or die $!;
print TO $conf;
close TO;
#-------------------------------xbio_run.sh-----------------------------------
my $conf_sh="perl $Script/metaX_Pipeline_V1.2.6.pl -conf $Script/metaX_pipeline1.2.3.conf -runMetaX YES";
open TO, "> $Script/metaX_pipeline1.2.6.sh" or die $!;
print TO "job_start_time=\$(date \"+%Y%m%d\")";
print TO $conf_sh;
#print TO "job_end_time=\$(data \"+%Y%m%d\")";
print TO "echo \"\$job_start_time\">>/zfssz3/SP_MSI/PROJECTS/Metabolomics/job_time_record/$sid.csv";
close TO;
#--------------------------------auto p value analysis-----------------------
my $auto_p="sh /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/p_value_analysis_shouhou.sh $main_dir";
open TO, "> $Script/auto_p_value_shouhou.sh" or die $!;
print TO $auto_p;
close TO;
#--------------------------------auto xbio check------------------------------
my $auto_check="perl /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/auto_xbio_report_check.pl -conf $Script/metaX_pipeline1.2.3.conf\nsh /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/auto_size_log_check.sh $main_dir";
open TO, "> $Script/auto_check.sh" or die $!;
print TO $auto_check;
close TO;
#-------------------------------arf_check.sh-----------------------------------
open TO, "> $Script/arf_check.sh" or die $!;
print TO "perl $Script/arf_check.pl -i $main_dir/Submit/upload/arf -d $main_dir/Submit/upload";
close TO;
#---------------------------upload.sh------------------------------------------
my $today=`date "+%Y%m%d"`;
chomp $today;
print "\nToday is:$today, Cheer up!\n";
open TO, "> $Script/upload.sh" or die $!;
print TO "/ifs4/BC_PUB/biosoft/bin/GenerateUserPro.sh -usr $guest_mail -pid $pid -sid $sid -type Metabolomics; >$Script/upload.log\n";
print TO "/ifs4/BC_PUB/biosoft/bin/upload.sh.x -usr $today -pwd 1234 -area SZ -id $sid -n \"Untarget Metabolomics Report\" -f $main_dir/Submit/upload -p $pid/$sid >>$Script/upload.log\n";
print TO "job_end_time=\$(data \"+%Y%m%d\")";
print TO "echo \"\$job_end_time\n\">>/zfssz3/SP_MSI/PROJECTS/Metabolomics/job_time_record/$sid.csv";
close TO;
#--------------------------extra_pca------------------------------------------
if (defined $ex_pca){
open TO,">$Personalized_analysis/Extra_PCA/extra_pca.sh" or die;
print TO "#Note: You need to change the groups information before you run the script! eg:B_C_D;C_D_E\n";
print TO "perl /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/extra_pca.pl -metaxr $Script/pos.R -groups \"$ex_pca\" -mode \"pos\" -out $Personalized_analysis/Extra_PCA/pos -main $main_dir";
print TO "\n";
print TO "perl /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/extra_pca.pl -metaxr $Script/neg.R -groups \"$ex_pca\" -mode \"neg\" -out $Personalized_analysis/Extra_PCA/neg -main $main_dir";
close TO;
open TO, ">$Personalized_analysis/Extra_PCA/extra_pca_auto_check.sh" or die;
print TO "sh /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/auto_pca_check.sh $main_dir";
close TO;
}
#-----------------------------extra_heatmap----------------------------------
if (defined $ex_heatmap){
open TO, ">$Personalized_analysis/Extra_Heatmap/extra_heatmap.sh" or die;
open TO2, ">$Personalized_analysis/Extra_Heatmap/cp_heatmap_to_result.sh" or die;
my $heat = << "HEAT";
#Note: You need to change the groups and check the method and test before running the scripts!
##Usage:
##    -method   <str>  union or intersect
##    -prefix  <str>  prefix
##    -group  <str>   group used to do heatmap,e.g. A_B_C
##    -metax  <path>  metaX dirctory
##    -test   <str>   used to choose different m/z,choose t.test_p.value or wilcox.test_p.value or t.test_p.value_BHcorrect or wilcox.test_p.value_BHcorrect
##    -out    <path>  output
for i in $ex_heatmap
do
perl /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/Heatmap_individal.pl -method union -prefix pos -group \$i -metax $Script/metaX_result_pos -test t.test_p.value_BHcorrect -out $Personalized_analysis/Extra_Heatmap/pos >$Personalized_analysis/Extra_Heatmap/pos.log
perl /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/Heatmap_individal.pl -method union -prefix neg -group \$i -metax $Script/metaX_result_neg -test t.test_p.value_BHcorrect -out $Personalized_analysis/Extra_Heatmap/neg >$Personalized_analysis/Extra_Heatmap/neg.log
done
HEAT
print TO $heat;
close TO;
open TO,">$Personalized_analysis/Extra_Heatmap/auto_check_extra_heatmap.sh" or die;
print TO "sh /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/extra_heatmap_atuo_check.sh $main_dir";
close TO;
}

my $cp_heat = << "CP_HEAT";
out_dir=$main_dir/Submit/upload/personalized/Heatmap
mkdir -p \$out_dir
cp -r $Personalized_analysis/Extra_Heatmap/pos \$out_dir
cp -r $Personalized_analysis/Extra_Heatmap/neg \$out_dir
CP_HEAT
print TO2 $cp_heat;
close TO2;


#=================Item.txt===================================
`/zfssz3/SP_MSI/USER/zengchunwei/software/R-3.4.1/bin/Rscript /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/item.R $CSV/s_neg.list $pid $sample $main_dir/Infor/Item.txt`;
`sed -i 's/"//g' $main_dir/Infor/Item.txt`;
#=================Progensis_QI.txt===========================
`perl /zfssz3/SP_MSI/USER/daiyulong/Script/mk_dir_generate/progensis_QI_item.pl -database $database -outQI $main_dir/Infor/ProgenesisQI.txt`;
#============================================================

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
