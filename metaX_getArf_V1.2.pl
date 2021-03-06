#!/usr/bin/perl -w
use strict;
use File::Path;
use Getopt::Long;
use FindBin;
use Cwd qw(abs_path);

my $conf;
GetOptions(
    "conf=s" => \$conf,
);
    die "
    Description: This program is used to generate .arf files and upload directory
    Usage:
    -conf     <file>    the .conf file
e.g:
    perl $0 -conf pipeline_V1.0.conf\n" unless $conf;

my $arf="/ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport/arf";
my $resource="/ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport/Resource";
my $pdftk="/ifs1/ST_PRO/USER/xushx/software_centos6/application/pdftk/pdftk";

#read config
my $config=&readConf($conf);
my %config=%$config;

#check and store parameters in config
my $test=$config{'Test'}if($config{'Test'});
my $database=$config{'Base'}if($config{'Base'});
my $QCTIC_pos=$config{'QCTIC_pos'}if($config{'QCTIC_pos'});
my $QCTIC_neg=$config{'QCTIC_neg'}if($config{'QCTIC_neg'});
my $group=$config{'Group'}if($config{'Group'});
my $pre_pos=$config{'Pre_pos'}if($config{'Pre_pos'});
my $pre_neg=$config{'Pre_neg'}if($config{'Pre_neg'});
my $metaX_pos=$config{'MetaX_pos'}if($config{'MetaX_pos'});
my $metaX_neg=$config{'MetaX_neg'}if($config{'MetaX_neg'});
my $ionStat_pos=$config{'IonStat_pos'}if($config{'IonStat_pos'});
my $ionStat_neg=$config{'IonStat_neg'}if($config{'IonStat_neg'});
my $pathPos=$config{'Pathway_pos'}if($config{'Pathway_pos'});
my $pathNeg=$config{'Pathway_neg'}if($config{'Pathway_neg'});
my $rawdata_pos=$config{'Rawdata_pos'}if($config{'Rawdata_pos'});
my $rawdata_neg=$config{'Rawdata_neg'}if($config{'Rawdata_neg'});
my $item=$config{'Item'}if($config{'Item'});
my $progenesisQI=$config{'ProgenesisQI'}if($config{'ProgenesisQI'});
my $outDir=$config{'Output'}if($config{'Output'});
my $sample=$config{'Sample'}if($config{'Sample'});
my $expType=$config{'ExperimentType'}if($config{'ExperimentType'});
my $sampleList_pos=$config{'SampleList_pos'}if($config{'SampleList_pos'});
my $sampleList_neg=$config{'SampleList_neg'}if($config{'SampleList_neg'});

my $out="$outDir/upload";
my $ab="$out/BGI_result/1.Abstract";
my $qu="$out/BGI_result/2.QualityControl";
my $st="$out/BGI_result/3.Statistic";
my $plsda="$out/BGI_result/3.Statistic/PLSDA/graph";
my $plsdaFi="$out/BGI_result/3.Statistic/PLSDA/file";
my $pca="$out/BGI_result/3.Statistic/PCA/graph";
my $pcaFi="$out/BGI_result/3.Statistic/PCA/file";
my $volcano="$out/BGI_result/3.Statistic/Volcano/graph";
my $volcanoFi="$out/BGI_result/3.Statistic/Volcano/file";
my $diCluster="$out/BGI_result/4.Differential/Cluster/graph";
my $diClusterFi="$out/BGI_result/4.Differential/Cluster/file";
my $diQuant="$out/BGI_result/4.Differential/Quant";
my $diQuantId="$out/BGI_result/4.Differential/QuantIdenti";
my $rsd="$out/BGI_result/5.RSD_0_30";
my $pa="$out/BGI_result/6.Pathway";
my $exp="$out/BGI_result/7.Experiment";
my $temp="$outDir/temp";
my $pdftemp="$out/pdftemp";
mkpath $ab;
mkpath $qu;
mkpath $st;
mkpath $plsda;
mkpath $plsdaFi;
mkpath $pca;
mkpath $pcaFi;
mkpath $volcano;
mkpath $volcanoFi;
mkpath $diCluster;
mkpath $diClusterFi;
mkpath $diQuant;
mkpath $diQuantId;
mkpath $rsd;
mkpath $pa;
mkpath $exp;
mkpath $temp;
mkpath $pdftemp;
my @class=split(";",$group);

#==================== experiment information file in BGI_result =====================================
`cp $progenesisQI $exp`;
`cp /ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport/Abstract/Instrument.txt $exp`;
`cp /ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport/Abstract/MetabolitesExtract/$sample\_$expType\_MetabolitesExtract.txt $exp/MetaboExtract.txt`;
if($rawdata_pos && $rawdata_neg){
  `perl /ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport/QI_parameter.pl pos $rawdata_pos $temp`;
  `perl /ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport/QI_parameter.pl neg $rawdata_neg $temp`;
}
if($rawdata_pos && !$rawdata_neg){
    `perl /ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport/QI_parameter.pl pos $rawdata_pos $temp`;
}
if($rawdata_neg && !$rawdata_pos){
    `perl /ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport/QI_parameter.pl neg $rawdata_neg $temp`;
}

#======================== graph and files in BGI_result ==========================================
if($metaX_pos){
    `cp $metaX_pos/data/$pre_pos-PCA.png $qu/qc-PCA-pos.png`;
    system("$pdftk A=$metaX_pos/data/$pre_pos-PCA.pdf cat A1-1 output $qu/qc-PCA-pos.pdf");
    system("$pdftk A=$metaX_pos/data/$pre_pos-noqc-nobatch-PCA.pdf cat A1-1 output $pca/PCA-pos.pdf");
    `cp $metaX_pos/data/*noqc-nobatch-PCA.png $pca/PCA-pos.png`;
    `cp $metaX_pos/data/*norm-metaboAnalystInput.csv $rsd/metaboAnalystInput-pos.csv`;
    `cp $ionStat_pos/*volcano-pos.pdf $volcano`;
    `cp $ionStat_pos/*volcano-pos.txt $volcanoFi`;
    `cp $ionStat_pos/qcPCAscores-pos.txt $qu`;
    `cp $ionStat_pos/*heatmap-pos.txt $diClusterFi`;
    `cp $ionStat_pos/*pcaScores-pos.txt $pcaFi`;
    `cp $ionStat_pos/*plsdaScores-pos.txt $plsdaFi`;
    `cp $ionStat_pos/PCAscores-pos.txt $pcaFi`;
    `cp $ionStat_pos/quant-identification.txt $rsd/quant-identification-pos.txt`;
    foreach my $i(0..$#class){
        `convert -density 120 $ionStat_pos/$class[$i]-volcano-pos.pdf $volcano/$class[$i]-volcano-pos.png`;
        system("$pdftk A=$metaX_pos/data/$pre_pos-$class[$i]-PLSDA.pdf cat A1-1 output $plsda/$class[$i]-PLSDA-pos.pdf");
        #`convert -density 120 $plsda/$class[$i]-PLSDA-pos.pdf $plsda/$class[$i]-PLSDA-pos.png`;
        `cp $metaX_pos/data/*$class[$i]-PLSDA-score.png $plsda/$class[$i]-PLSDA-pos.png`;
        `cp $metaX_pos/data/*$class[$i]-PCA.png $pca/$class[$i]-PCA-pos.png`;
        system("$pdftk A=$metaX_pos/data/$pre_pos-$class[$i]-PCA.pdf cat A1-1 output $pca/$class[$i]-PCA-pos.pdf");
        `cp $ionStat_pos/$class[$i]-diff-quant.txt $diQuant/$class[$i]-diff-quant-pos.txt`;
        `cp $pathPos/diff/$class[$i]-diff-quant-identification_filtering.txt $diQuantId/$class[$i]-diff-quant-identification-filtering-pos.txt`;
    }
    system("$pdftk A=$metaX_pos/data/$pre_pos-peakStat.pdf cat A6-6 output $pca/$class[0]-PCA-pos.pdf");
}
if($metaX_neg){
    `cp $metaX_neg/data/$pre_neg-PCA.png $qu/qc-PCA-neg.png`;
    system("$pdftk A=$metaX_neg/data/$pre_neg-PCA.pdf cat A1-1 output $qu/qc-PCA-neg.pdf");
    system("$pdftk A=$metaX_neg/data/$pre_neg-noqc-nobatch-PCA.pdf cat A1-1 output $pca/PCA-neg.pdf");
    `cp $metaX_neg/data/*noqc-nobatch-PCA.png $pca/PCA-neg.png`;
    `cp $ionStat_neg/*volcano-neg.pdf $volcano`;
    `cp $ionStat_neg/*volcano-neg.txt $volcanoFi`;
    `cp $ionStat_neg/qcPCAscores-neg.txt $qu`;
    `cp $ionStat_neg/*heatmap-neg.txt $diClusterFi`;
    `cp $ionStat_neg/*pcaScores-neg.txt $pcaFi`;
    `cp $ionStat_neg/*plsdaScores-neg.txt $plsdaFi`;
    `cp $ionStat_neg/PCAscores-neg.txt $pcaFi`;
    `cp $metaX_neg/data/*norm-metaboAnalystInput.csv $rsd/metaboAnalystInput-neg.csv`;
    `cp $ionStat_neg/quant-identification.txt $rsd/quant-identification-neg.txt`;
    foreach my $i(0..$#class){
        `convert -density 120 $ionStat_neg/$class[$i]-volcano-neg.pdf $volcano/$class[$i]-volcano-neg.png`;
        system("$pdftk A=$metaX_neg/data/$pre_neg-$class[$i]-PLSDA.pdf cat A1-1 output $plsda/$class[$i]-PLSDA-neg.pdf");
        #`convert -density 120 $plsda/$class[$i]-PLSDA-neg.pdf $plsda/$class[$i]-PLSDA-neg.png`;
        `cp $metaX_neg/data/*$class[$i]-PLSDA-score.png $plsda/$class[$i]-PLSDA-neg.png`;
        `cp $metaX_neg/data/*$class[$i]-PCA.png $pca/$class[$i]-PCA-neg.png`;
        system("$pdftk A=$metaX_neg/data/$pre_neg-$class[$i]-PCA.pdf cat A1-1 output $pca/$class[$i]-PCA-neg.pdf");
        `cp $ionStat_neg/$class[$i]-diff-quant.txt $diQuant/$class[$i]-diff-quant-neg.txt`;
        `cp $pathNeg/diff/$class[$i]-diff-quant-identification_filtering.txt $diQuantId/$class[$i]-diff-quant-identification-filtering-neg.txt`;
    }
    system("$pdftk A=$metaX_neg/data/$pre_neg-peakStat.pdf cat A6-6 output $pca/$class[0]-PCA-neg.pdf");
}
#=============================== summary.txt in BGI_result ===================================
`cp $item $ab`;
if($ionStat_pos && $ionStat_neg){
    `sed '1d' $ionStat_neg/Summary.1.txt >summary.txt`;
    `cat $ionStat_pos/Summary.1.txt summary.txt >$ab/Summary.1.txt`;
    `sed '1d' $ionStat_neg/Summary.2.txt >summary.txt`;
    `cat $ionStat_pos/Summary.2.txt summary.txt >$ab/Summary.2.txt`;
    `sed '1d' $ionStat_neg/Summary.3.txt >summary.txt`;
    `cat $ionStat_pos/Summary.3.txt summary.txt >$ab/Summary.3.txt`;
    `sed '1d' $ionStat_neg/Summary.4.txt >summary.txt`;
    `cat $ionStat_pos/Summary.4.txt summary.txt >$ab/Summary.4.txt`;
    `sed '1d' $ionStat_neg/R2_Q2.txt >summary.txt`;
    `cat $ionStat_pos/R2_Q2.txt summary.txt >$plsdaFi/R2_Q2.txt`;
    `rm summary.txt`;
    
    `cp $sampleList_pos $ab/sampleList-pos.txt`;
    `cp $sampleList_neg $ab/sampleList-neg.txt`;
}
if($ionStat_pos && !$ionStat_neg){
    `cp $ionStat_pos/Summary.1.txt $ionStat_pos/Summary.2.txt $ionStat_pos/Summary.3.txt $ionStat_pos/Summary.4.txt $ab`;
    `cp $ionStat_pos/R2_Q2.txt $plsdaFi`;

    `cp $sampleList_pos $ab/sampleList-pos.txt`;
}
if(!$ionStat_pos && $ionStat_neg){
    `cp $ionStat_neg/Summary.1.txt $ionStat_neg/Summary.2.txt $ionStat_neg/Summary.3.txt $ionStat_neg/Summary.4.txt $ab`;
    `cp $ionStat_neg/R2_Q2.txt $plsdaFi`;

    `cp $sampleList_neg $ab/sampleList-neg.txt`;
}
print "---BGI_result has been generated!\n";

#================================== Resource ====================================================
`cp -r $resource $out`;
print "---Resource has been generated!\n";

#================================== arf files ====================================================
my $arf_out="$out/arf";
mkpath $arf_out;

open IN,"<$arf/results_cn.arf"or die $!;
open TO,">$arf_out/results_cn.arf"or die $!;
while(<IN>){
    chomp;
    s/\s+$//;
    $_=~s/????????????????????????????????????/????????????????????????????????????$database/g;
    $_=~s/?????????????????????/?????????????????????$test/g;
    print TO "$_\n";
    ########sampleList######
    if($_=~/^????????????????????????/){
        if($sampleList_pos){
            print TO "\\href{BGI_result/1.Abstract/sampleList-pos.txt}{??????????????????sampleList-pos.txt}\n";
        }
        if($sampleList_neg){
            print TO "\\href{BGI_result/1.Abstract/sampleList-neg.txt}{??????????????????sampleList-neg.txt}\n";
        }
        next;
    }

    ########QC_TIC#######
    if($_=~/^title="QC??????TIC?????????"/){
        if($QCTIC_pos){
            `cp $QCTIC_pos $qu/QC_TIC_pos.png`;
            print TO "file=<url=BGI_result/2.QualityControl/QC_TIC_pos.png;label=\"QC-pos\">\n";
        }else{print "no positive QC TIC image\n";}
        if($QCTIC_neg){
            `cp $QCTIC_neg $qu/QC_TIC_neg.png`;
            print TO "file=<url=BGI_result/2.QualityControl/QC_TIC_neg.png;label=\"QC-neg\">\n";
        }else{print "no negative QC TIC image\n";}
        next;
    }
    #########QC PCA###########
    if($_=~/^title="QC?????????????????????"/){
        if($metaX_pos){
            print TO "file=<url=BGI_result/2.QualityControl/qc-PCA-pos.png;label=\"pos\">\n";
        }
        if($metaX_neg){
            print TO "file=<url=BGI_result/2.QualityControl/qc-PCA-neg.png;label=\"neg\">\n";
        }
        next;
    }
    #########volcano##########
    if($_=~/^title="?????????"/){
        if($metaX_pos){
            foreach my $a(0..$#class){
                print TO "file=<url=BGI_result/3.Statistic/Volcano/graph/$class[$a]-volcano-pos.png;label=\"$class[$a]-pos\">\n";
            }
        }
        if($metaX_neg){
            foreach my $b(0..$#class){
                print TO "file=<url=BGI_result/3.Statistic/Volcano/graph/$class[$b]-volcano-neg.png;label=\"$class[$b]-neg\">\n";
            }
        }
        next;
    }
    ##########PCA###############
    if($_=~/title="?????????????????????"/){
        if($metaX_pos){
            print TO "file=<url=BGI_result/3.Statistic/PCA/graph/PCA-pos.png;label=\"PCA-pos\">\n";
            if($#class>=1){
                foreach my $g(0..$#class){
                    print TO "file=<url=BGI_result/3.Statistic/PCA/graph/$class[$g]-PCA-pos.png;label=\"$class[$g]-pos\">\n";
                }
            }
        }
        if($metaX_neg){
            print TO "file=<url=BGI_result/3.Statistic/PCA/graph/PCA-neg.png;label=\"PCA-neg\">\n";
            if($#class>=1){
                foreach my $h(0..$#class){
                    print TO "file=<url=BGI_result/3.Statistic/PCA/graph/$class[$h]-PCA-neg.png;label=\"$class[$h]-neg\">\n";
                }
            }
        }
        next;
    }
    ##########PLSDA#############
    if($_=~/^title="PLS-DA??????????????????????????????"/){
        if($metaX_pos){
            foreach my $c(0..$#class){
                print TO "file=<url=BGI_result/3.Statistic/PLSDA/graph/$class[$c]-PLSDA-pos.png;label=\"$class[$c]-pos\">\n";
            }
        }
        if($metaX_neg){
            foreach my $d(0..$#class){
                print TO "file=<url=BGI_result/3.Statistic/PLSDA/graph/$class[$d]-PLSDA-neg.png;label=\"$class[$d]-neg\">\n";
            }
        }
        next;
    }
    ############heatmap#####################
    if($_=~/^?????????????????????????????????????????????/){
        if($ionStat_pos){`cp $ionStat_pos/*-diff-heatmap-pos.pdf $pdftemp`;}
        if($ionStat_neg){`cp $ionStat_neg/*-diff-heatmap-neg.pdf $pdftemp`;}
        my @files=glob "$pdftemp/*.pdf";
        if((scalar @files)){
            print TO "\@figure\n";
            print TO "title=\"???????????????????????????\"\n";
            foreach my $e(0..$#class){
                if(-e "$pdftemp/$class[$e]-diff-heatmap-pos.pdf"){
                system("$pdftk A=$pdftemp/$class[$e]-diff-heatmap-pos.pdf cat A2-2 output $diCluster/$class[$e]-diff-heatmap-pos.pdf");
                `convert -density 120 $diCluster/$class[$e]-diff-heatmap-pos.pdf $diCluster/$class[$e]-diff-heatmap-pos.png`;
                print TO "file=<url=BGI_result/4.Differential/Cluster/graph/$class[$e]-diff-heatmap-pos.png;label=\"$class[$e]-pos\">\n";
                }

                if(-e "$pdftemp/$class[$e]-diff-heatmap-neg.pdf"){
                system("$pdftk A=$pdftemp/$class[$e]-diff-heatmap-neg.pdf cat A2-2 output $diCluster/$class[$e]-diff-heatmap-neg.pdf");
                `convert -density 120 $diCluster/$class[$e]-diff-heatmap-neg.pdf $diCluster/$class[$e]-diff-heatmap-neg.png`;
                print TO "file=<url=BGI_result/4.Differential/Cluster/graph/$class[$e]-diff-heatmap-neg.png;label=\"$class[$e]-neg\">\n";
                }
            }
            print TO "desc=\"?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????\"\n";
            print TO "size=<width=500;height=500>\n";
        }
        `rm -r $out/pdftemp`;
        next;
    }
    if($_=~/^????????????????????????/){
        if($pathPos){
            `mkdir -p pos`unless -d "pos";
            `cp -r $pathPos/diff pos`;
            `cp -r $pathPos/total pos/RSD_0_30`;
            `rm pos/diff/*.txt`;
            `tar zcvf $pa/pos.tar.gz pos`;
                print TO "\\href{BGI_result/6.Pathway/pos.tar.gz}{??????????????????????????????RSD<=30%????????????????????????pos.tar.gz}\n";
            `rm -r pos`;
        }
        if($pathNeg){
            `mkdir -p neg`unless -d "neg";
            `cp -r $pathNeg/diff neg`;
            `cp -r $pathNeg/total neg/RSD_0_30`;
            `rm neg/diff/*.txt`;
            `tar zcvf $pa/neg.tar.gz neg`;
                print TO "\\href{BGI_result/6.Pathway/neg.tar.gz}{??????????????????????????????RSD<=30%????????????????????????neg.tar.gz}\n";
            `rm -r neg`;
        }
        next;
    }

    ################## .pdf and file ##########################
    if($_=~/^QC????????????????????????????????????$/){
        if($metaX_pos){
            print TO "\\href{BGI_result/2.QualityControl/qc-PCA-pos.pdf}{????????????????????????qc-PCA-pos.pdf}   \\href{BGI_result/2.QualityControl/qcPCAscores-pos.txt}{??????qcPCAscores-pos.txt}\n";
        }
        if($metaX_neg){
            print TO "\\href{BGI_result/2.QualityControl/qc-PCA-neg.pdf}{????????????????????????qc-PCA-neg.pdf}   \\href{BGI_result/2.QualityControl/qcPCAscores-neg.txt}{??????qcPCAscores-neg.txt}\n";
        }
        next;
    }
    if($_=~/^?????????????????????$/){
        if($metaX_pos){
            foreach my $i(0..$#class){
            print TO "\\href{BGI_result/3.Statistic/Volcano/graph/$class[$i]-volcano-pos.pdf}{????????????????????????$class[$i]-volcano-pos.pdf}\\href{BGI_result/3.Statistic/Volcano/file/$class[$i]-volcano-pos.txt}{??????$class[$i]-volcano-pos.txt}\n";
        }
    }
        if($metaX_neg){
            foreach my $j(0..$#class){
            print TO "\\href{BGI_result/3.Statistic/Volcano/graph/$class[$j]-volcano-neg.pdf}{????????????????????????$class[$j]-volcano-neg.pdf}   \\href{BGI_result/3.Statistic/Volcano/file/$class[$j]-volcano-neg.txt}{??????$class[$j]-volcano-neg.txt}\n";
            }
        }
        next;
    }
    if($_=~/^PCA???????????????$/){
        if($metaX_pos){
            print TO "\\href{BGI_result/3.Statistic/PCA/graph/PCA-pos.pdf}{????????????????????????PCA-pos.pdf}   \\href{BGI_result/3.Statistic/PCA/file/PCAscores-pos.txt}{??????PCAscores-pos.txt}\n";
            if($#class>1){
                foreach my $u(0..$#class){
                    print TO "\\href{BGI_result/3.Statistic/PCA/graph/$class[$u]-PCA-pos.pdf}{????????????????????????$class[$u]-PCA-pos.pdf}   \\href{BGI_result/3.Statistic/PCA/file/$class[$u]-pcaScores-pos.txt}{??????$class[$u]-pcaScores-pos.txt}\n";
                }
            }
        }
        if($metaX_neg){
            print TO "\\href{BGI_result/3.Statistic/PCA/graph/PCA-neg.pdf}{????????????????????????PCA-neg.pdf}   \\href{BGI_result/3.Statistic/PCA/file/PCAscores-neg.txt}{??????PCAscores-neg.txt}\n";
            if($#class>1){
                foreach my $k(0..$#class){
                    print TO "\\href{BGI_result/3.Statistic/PCA/graph/$class[$k]-PCA-neg.pdf}{????????????????????????$class[$k]-PCA-neg.pdf}   \\href{BGI_result/3.Statistic/PCA/file/$class[$k]-pcaScores-neg.txt}{??????$class[$k]-pcaScores-neg.txt}\n";
                }
            }
        }
        next;
    }
    if($_=~/^PLS-DA???????????????$/){
        if($metaX_pos){
            foreach my $l(0..$#class){
                print TO "\\href{BGI_result/3.Statistic/PLSDA/graph/$class[$l]-PLSDA-pos.pdf}{????????????????????????$class[$l]-PLSDA-pos.pdf} \\href{BGI_result/3.Statistic/PLSDA/file/$class[$l]-plsdaScores-pos.txt}{??????$class[$l]-plsdaScores-pos.txt}\n";
            }
        }
        if($metaX_neg){
            foreach my $m(0..$#class){
                print TO "\\href{BGI_result/3.Statistic/PLSDA/graph/$class[$m]-PLSDA-neg.pdf}{????????????????????????$class[$m]-PLSDA-neg.pdf} \\href{BGI_result/3.Statistic/PLSDA/file/$class[$m]-plsdaScores-neg.txt}{??????$class[$m]-plsdaScores-neg.txt}\n";
            }
        }
        next;
    }
    if($_=~/^heatmap???????????????$/){
        foreach my $n(0..$#class){
            if($metaX_pos){
		        if(-e "$diCluster/$class[$n]-diff-heatmap-pos.pdf"){
                    print TO "\\href{BGI_result/4.Differential/Cluster/graph/$class[$n]-diff-heatmap-pos.pdf}{????????????????????????$class[$n]-diff-heatmap-pos.pdf}  \\href{BGI_result/4.Differential/Cluster/file/$class[$n]-diff-heatmap-pos.txt}{??????$class[$n]-diff-heatmap-pos.txt}\n";
                }
                else{
                    print TO "\@paragraph\n?????????????????????$class[$n]??????????????????????????????????????????\n";
                }
	        }
            if($metaX_neg){
		        if(-e "$diCluster/$class[$n]-diff-heatmap-neg.pdf"){
                    print TO "\\href{BGI_result/4.Differential/Cluster/graph/$class[$n]-diff-heatmap-neg.pdf}{????????????????????????$class[$n]-diff-heatmap-neg.pdf}  \\href{BGI_result/4.Differential/Cluster/file/$class[$n]-diff-heatmap-neg.txt}{??????$class[$n]-diff-heatmap-neg.txt}\n";
                }
                else{
                    print TO "\@paragraph\n?????????????????????$class[$n]??????????????????????????????????????????\n";
                }
	        }       
        }
        next;
    }
    if($_=~/^????????????????????????????????????????????????$/){
        if($metaX_pos){
            print TO "\\href{BGI_result/5.RSD_0_30/metaboAnalystInput-pos.csv}{??????????????????RSD<=30%????????????????????????metaboAnalystInput-pos.csv}\n";
            print TO "\\href{BGI_result/5.RSD_0_30/quant-identification-pos.txt}{??????????????????RSD<=30%?????????????????????????????????quant-identification-pos.txt}\n";
            foreach my $p(0..$#class){
                print TO "\\href{BGI_result/4.Differential/Quant/$class[$p]-diff-quant-pos.txt}{??????????????????$class[$p]??????????????????????????????$class[$p]-diff-quant-pos.txt}\n";
                print TO "\\href{BGI_result/4.Differential/QuantIdenti/$class[$p]-diff-quant-identification-filtering-pos.txt}{??????????????????$class[$p]???????????????????????????????????????$class[$p]-diff-quant-identification-filtering-pos.txt}\n";
            }
        }
        if($metaX_neg){
            print TO "\\href{BGI_result/5.RSD_0_30/metaboAnalystInput-neg.csv}{??????????????????RSD<=30%????????????????????????metaboAnalystInput-neg.csv}\n";
            print TO "\\href{BGI_result/5.RSD_0_30/quant-identification-neg.txt}{??????????????????RSD<=30%?????????????????????????????????quant-identification-neg.txt}\n";
            foreach my $v(0..$#class){
                print TO "\\href{BGI_result/4.Differential/Quant/$class[$v]-diff-quant-neg.txt}{??????????????????$class[$v]??????????????????????????????$class[$v]-diff-quant-neg.txt}\n";
                print TO "\\href{BGI_result/4.Differential/QuantIdenti/$class[$v]-diff-quant-identification-filtering-neg.txt}{??????????????????$class[$v]???????????????????????????????????????$class[$v]-diff-quant-identification-filtering-neg.txt}\n";
            }
        }
        next;
    }
}

close IN;
close TO;

#`cp $arf/methods_cn.arf $arf_out`;
open IN,"<$arf/methods_cn.arf" or die $!;
open TO,">$arf_out/methods_cn.arf"or die $!;
while(<IN>){
    chomp;
    s/\s+$//;
    print TO "$_\n";
    if($_=~/ ??????????????????/){
        if(($sample eq "serum" || $sample eq "tissue")&& $expType eq "globe"){
            print TO "??????ACQUITY UPLC BEH C18 column (100mm*2.1mm???1.7??m??? Waters???UK)???????????????????????????????????????50 ??C????????????0.4ml/min?????????A??????????????????0.1%?????????B?????????????????????0.1%??????????????????????????????????????????????????????0-2min???100%?????????A???2-11min, 0-100%?????????B???11-13min???100%?????????B???13-15min??????100%?????????A?????????????????????????????????10??l???\n\@paragraph\nAll samples were acquired by the LC-MS system followed machine orders. Firstly, all chromatographic separations were performed using an ultra performance liquid chromatography (UPLC) system (Waters, UK).An ACQUITY UPLC BEH C18 column (100mm*2.1mm, 1.7??m, Waters???UK)was used for the reversed phase separation. The column oven was maintained at 50 ??C. The flow rate was 0.4 ml/min and the mobile phase consisted of solvent A (water + 0.1% formic acid) and solvent B (acetonitrile + 0.1% formic acid). Gradient elution conditions were set as follows: 0???2 min???100% phase A; 2~11 min???0% to 100% B; 11~13 min???100% B; 13???15 min???100% A. The injection volume for each sample was 10 ??l.\n";
        }
        if(($sample eq "serum" || $sample eq "tissue")&& $expType eq "lipids"){
            print TO "??????ACQUITY UPLC CSH C18 column (100 mm*2.1 mm???1.7 ??m??? Waters???UK)???????????????????????????????????????55 ??C????????????0.4 ml/min?????????A????????????ACN:H2O=60:40???0.1% FA???10mM????????????B????????????IPA:ACN=90:10???0.1% FA???10mM?????????????????????????????????????????????????????????0-2 min???40-43%?????????B???2.1-7 min???50-54%?????????B???7.1-13 min???70-99%?????????B???13.1-15 min???40%?????????B?????????????????????????????????10 ??l???\n\@paragraph\nAll samples were acquired by the LC-MS system followed machine orders. Firstly, all chromatographic separations were performed using an ultra performance liquid chromatography (UPLC) system (Waters, UK).An ACQUITY UPLC CSH C18 column (100 mm*2.1 mm???1.7 ??m, Waters???UK) was used for the separation. The column oven was maintained at 55 ??C. The flow rate was 0.4 ml/min and the mobile phase consisted of solvent A (ACN: H2O=60:40, 0.1% formate acid and 10mM ammonium formate) and solvent B (IPA: ACN=90:10, 0.1% formate acid and 10mM ammonium formate). Gradient elution conditions were set as follows: 0~2 min???40-43% phase B; 2.1~7 min???50-54% phase B; 7.1-13 min, 70-99% phase B; 13.1-15 min, 40% phase B. The injection volume for each sample was 10 ??l.\n";
        }
        if($sample eq "urine" && $expType eq "globe"){
            print TO "??????ACQUITY UPLC HSS T3 column (100 mm*2.1 mm???1.8 ??m???Waters???UK) ???????????????????????????????????????40 ??C????????????0.5 ml/min?????????A??????????????????0.1%?????????B?????????????????????0.1%??????????????????????????????????????????????????????0-1 min???99%?????????A???1-3 min???1-15%?????????B???3-6 min???15-50%?????????B???6-9 min??????50-95%?????????B??? 9-10 min??????95%?????????B??? 10.1-12 min??????99%?????????A?????????????????????????????????10 ??l???\n\@paragraph\nAll samples were acquired by the LC-MS system followed machine orders. Firstly, all chromatographic separations were performed using an ultra performance liquid chromatography (UPLC) system (Waters, UK).An ACQUITY UPLC HSS T3 column (100 mm*2.1 mm, 1.8 ??m, Waters, UK) was used for the reversed phase separation. The column oven was maintained at 40 ??C. The flow rate was 0.4 ml/min and the mobile phase consisted of solvent A (water + 0.1% formic acid) and solvent B (acetonitrile + 0.1% formic acid). Gradient elution conditions were set as follows: 0~1 min???99% phase A; 1~3min???1% to 15% phase B; 3~6 min???15-50% phase B; 6???9 min???50-95% phase A, 9-10 min, 95% phase B; 10.1-12 min, 99% phase A. The injection volume for each sample was 10 ??l.";
        }
        next;
    }
    if($_=~/ ??????????????????/){
        if($expType eq "globe"){
            print TO "????????????????????????????????????????????????????????????????????????Xevo G2-XS QTOF (Waters??? UK)???????????????????????????????????????????????????????????????????????????????????????????????????0.25 kV???40 V???????????????????????????????????????????????????????????????2 kV???40 V?????????MSE????????????centroid????????????????????????????????????50-1200 Da??????????????????0.2 s???????????????????????????20???40 eV?????????????????????????????????????????????????????????????????????0.2 s?????????????????????????????????LE?????????3 s??????????????????????????????????????????10?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????\n\@paragraph\nA high-resolution tandem mass spectrometer Xevo G2 XS QTOF (Waters, UK) was used to detect metabolites eluted form the column. The Q-TOF was operated in both positive and negative ion modes. For positive ion mode, the capillary and sampling cone voltages were set at 0.25 kV and 40 V, respectively. For negative ion mode, the capillary and sampling cone voltages were set at 2 kV and 40V, respectively. The mass spectrometry data were acquired in Centroid MSE mode. The TOF mass range was from 50 to 1200 Da and the scan time was 0.2 s. For the MS/MS detection, all precursors were fragmented using 20-40 eV, and the scan time was 0.2 s. During the acquisition, the LE signal was acquired every 3 s to calibrate the mass accuracy. Furthermore, in order to evaluate the stability of the LC-MS during the whole acquisition, a quality control sample (Pool of all samples) was acquired after every 10 samples.\n";
        }
        if($expType eq "lipids"){
            print TO "????????????????????????????????????????????????????????????????????????Xevo G2-XS QTOF (Waters??? UK)???????????????????????????????????????????????????????????????????????????????????????????????????0.25 kV???40 V???????????????????????????????????????????????????????????????2 kV???40 V?????????MSE????????????centroid?????????????????????????????????????????????100-2000 Da???????????????50-2000Da??????????????????0.2 s???????????????????????????19???45 eV?????????????????????????????????????????????????????????????????????0.2 s?????????????????????????????????LE?????????3 s??????????????????????????????????????????10?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????\n\@paragraph\nA high-resolution tandem mass spectrometer Xevo G2 XS QTOF (Waters, UK) was used to detect metabolites eluted form the column. The Q-TOF was operated in both positive and negative ion modes. For positive ion mode, the capillary and sampling cone voltages were set at 0.25 kV and 40 V, respectively. For negative ion mode, the capillary and sampling cone voltages were set at 2 kV and 40 V, respectively. The mass spectrometry data were acquired in Centroid MSE mode. The TOF mass range was from 100 to 2000 Da in positive mode and 50 to 2000 Da in negative mode. And the survey scan time was 0.2s . For the MS/MS detection, all precursors were fragmented using 19-45 eV, and the scan time was 0.2 s. During the acquisition, the LE signal was acquired every 3 s to calibrate the mass accuracy. Furthermore, in order to evaluate the stability of the LC-MS during the whole acquisition, a quality control sample (Pool of all samples) was acquired after every 10 samples.\n";
        }
        next;
    }
}
close TO;
close IN;

`cp $arf/help_cn.arf $arf_out`;
`cp $arf/glossaries_cn.arf $arf_out`;
`cp $arf/FAQs_cn.arf $arf_out`;

print "---.arf files have been generated!\n";
##################################function: read .conf file###########
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
