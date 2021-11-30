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
    $_=~s/其中代谢物鉴定基于数据库/其中代谢物鉴定基于数据库$database/g;
    $_=~s/该项目采用的是/该项目采用的是$test/g;
    print TO "$_\n";
    ########sampleList######
    if($_=~/^详细样品分组信息/){
        if($sampleList_pos){
            print TO "\\href{BGI_result/1.Abstract/sampleList-pos.txt}{正离子模式：sampleList-pos.txt}\n";
        }
        if($sampleList_neg){
            print TO "\\href{BGI_result/1.Abstract/sampleList-neg.txt}{负离子模式：sampleList-neg.txt}\n";
        }
        next;
    }

    ########QC_TIC#######
    if($_=~/^title="QC样本TIC重叠图"/){
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
    if($_=~/^title="QC样本主成分分析"/){
        if($metaX_pos){
            print TO "file=<url=BGI_result/2.QualityControl/qc-PCA-pos.png;label=\"pos\">\n";
        }
        if($metaX_neg){
            print TO "file=<url=BGI_result/2.QualityControl/qc-PCA-neg.png;label=\"neg\">\n";
        }
        next;
    }
    #########volcano##########
    if($_=~/^title="火山图"/){
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
    if($_=~/title="主成分分析模型"/){
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
    if($_=~/^title="PLS-DA判别分析模型的得分图"/){
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
    if($_=~/^对筛选出来的差异离子做聚类分析/){
        if($ionStat_pos){`cp $ionStat_pos/*-diff-heatmap-pos.pdf $pdftemp`;}
        if($ionStat_neg){`cp $ionStat_neg/*-diff-heatmap-neg.pdf $pdftemp`;}
        my @files=glob "$pdftemp/*.pdf";
        if((scalar @files)){
            print TO "\@figure\n";
            print TO "title=\"差异离子聚类分析图\"\n";
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
            print TO "desc=\"图中的每一行代表一个差异离子，每一列代表一个样本，不同颜色表示不同的强度，颜色从绿色到红色，表示强度从低到高。\"\n";
            print TO "size=<width=500;height=500>\n";
        }
        `rm -r $out/pdftemp`;
        next;
    }
    if($_=~/^差异离子代谢通路/){
        if($pathPos){
            `mkdir -p pos`unless -d "pos";
            `cp -r $pathPos/diff pos`;
            `cp -r $pathPos/total pos/RSD_0_30`;
            `rm pos/diff/*.txt`;
            `tar zcvf $pa/pos.tar.gz pos`;
                print TO "\\href{BGI_result/6.Pathway/pos.tar.gz}{正离子模式差异离子及RSD<=30%离子的代谢通路：pos.tar.gz}\n";
            `rm -r pos`;
        }
        if($pathNeg){
            `mkdir -p neg`unless -d "neg";
            `cp -r $pathNeg/diff neg`;
            `cp -r $pathNeg/total neg/RSD_0_30`;
            `rm neg/diff/*.txt`;
            `tar zcvf $pa/neg.tar.gz neg`;
                print TO "\\href{BGI_result/6.Pathway/neg.tar.gz}{负离子模式差异离子及RSD<=30%离子的代谢通路：neg.tar.gz}\n";
            `rm -r neg`;
        }
        next;
    }

    ################## .pdf and file ##########################
    if($_=~/^QC样本主成分得分图及表格：$/){
        if($metaX_pos){
            print TO "\\href{BGI_result/2.QualityControl/qc-PCA-pos.pdf}{正离子模式：图：qc-PCA-pos.pdf}   \\href{BGI_result/2.QualityControl/qcPCAscores-pos.txt}{表：qcPCAscores-pos.txt}\n";
        }
        if($metaX_neg){
            print TO "\\href{BGI_result/2.QualityControl/qc-PCA-neg.pdf}{负离子模式：图：qc-PCA-neg.pdf}   \\href{BGI_result/2.QualityControl/qcPCAscores-neg.txt}{表：qcPCAscores-neg.txt}\n";
        }
        next;
    }
    if($_=~/^火山图及表格：$/){
        if($metaX_pos){
            foreach my $i(0..$#class){
            print TO "\\href{BGI_result/3.Statistic/Volcano/graph/$class[$i]-volcano-pos.pdf}{正离子模式：图：$class[$i]-volcano-pos.pdf}\\href{BGI_result/3.Statistic/Volcano/file/$class[$i]-volcano-pos.txt}{表：$class[$i]-volcano-pos.txt}\n";
        }
    }
        if($metaX_neg){
            foreach my $j(0..$#class){
            print TO "\\href{BGI_result/3.Statistic/Volcano/graph/$class[$j]-volcano-neg.pdf}{负离子模式：图：$class[$j]-volcano-neg.pdf}   \\href{BGI_result/3.Statistic/Volcano/file/$class[$j]-volcano-neg.txt}{表：$class[$j]-volcano-neg.txt}\n";
            }
        }
        next;
    }
    if($_=~/^PCA图及表格：$/){
        if($metaX_pos){
            print TO "\\href{BGI_result/3.Statistic/PCA/graph/PCA-pos.pdf}{正离子模式：图：PCA-pos.pdf}   \\href{BGI_result/3.Statistic/PCA/file/PCAscores-pos.txt}{表：PCAscores-pos.txt}\n";
            if($#class>1){
                foreach my $u(0..$#class){
                    print TO "\\href{BGI_result/3.Statistic/PCA/graph/$class[$u]-PCA-pos.pdf}{正离子模式：图：$class[$u]-PCA-pos.pdf}   \\href{BGI_result/3.Statistic/PCA/file/$class[$u]-pcaScores-pos.txt}{表：$class[$u]-pcaScores-pos.txt}\n";
                }
            }
        }
        if($metaX_neg){
            print TO "\\href{BGI_result/3.Statistic/PCA/graph/PCA-neg.pdf}{负离子模式：图：PCA-neg.pdf}   \\href{BGI_result/3.Statistic/PCA/file/PCAscores-neg.txt}{表：PCAscores-neg.txt}\n";
            if($#class>1){
                foreach my $k(0..$#class){
                    print TO "\\href{BGI_result/3.Statistic/PCA/graph/$class[$k]-PCA-neg.pdf}{负离子模式：图：$class[$k]-PCA-neg.pdf}   \\href{BGI_result/3.Statistic/PCA/file/$class[$k]-pcaScores-neg.txt}{表：$class[$k]-pcaScores-neg.txt}\n";
                }
            }
        }
        next;
    }
    if($_=~/^PLS-DA图及表格：$/){
        if($metaX_pos){
            foreach my $l(0..$#class){
                print TO "\\href{BGI_result/3.Statistic/PLSDA/graph/$class[$l]-PLSDA-pos.pdf}{正离子模式：图：$class[$l]-PLSDA-pos.pdf} \\href{BGI_result/3.Statistic/PLSDA/file/$class[$l]-plsdaScores-pos.txt}{表：$class[$l]-plsdaScores-pos.txt}\n";
            }
        }
        if($metaX_neg){
            foreach my $m(0..$#class){
                print TO "\\href{BGI_result/3.Statistic/PLSDA/graph/$class[$m]-PLSDA-neg.pdf}{负离子模式：图：$class[$m]-PLSDA-neg.pdf} \\href{BGI_result/3.Statistic/PLSDA/file/$class[$m]-plsdaScores-neg.txt}{表：$class[$m]-plsdaScores-neg.txt}\n";
            }
        }
        next;
    }
    if($_=~/^heatmap图及表格：$/){
        foreach my $n(0..$#class){
            if($metaX_pos){
		        if(-e "$diCluster/$class[$n]-diff-heatmap-pos.pdf"){
                    print TO "\\href{BGI_result/4.Differential/Cluster/graph/$class[$n]-diff-heatmap-pos.pdf}{正离子模式：图：$class[$n]-diff-heatmap-pos.pdf}  \\href{BGI_result/4.Differential/Cluster/file/$class[$n]-diff-heatmap-pos.txt}{表：$class[$n]-diff-heatmap-pos.txt}\n";
                }
                else{
                    print TO "\@paragraph\n正离子模式下，$class[$n]组之间没有差异离子，没有热图\n";
                }
	        }
            if($metaX_neg){
		        if(-e "$diCluster/$class[$n]-diff-heatmap-neg.pdf"){
                    print TO "\\href{BGI_result/4.Differential/Cluster/graph/$class[$n]-diff-heatmap-neg.pdf}{负离子模式：图：$class[$n]-diff-heatmap-neg.pdf}  \\href{BGI_result/4.Differential/Cluster/file/$class[$n]-diff-heatmap-neg.txt}{表：$class[$n]-diff-heatmap-neg.txt}\n";
                }
                else{
                    print TO "\@paragraph\n负离子模式下，$class[$n]组之间没有差异离子，没有热图\n";
                }
	        }       
        }
        next;
    }
    if($_=~/^离子定量、定性分析结果文件如下：$/){
        if($metaX_pos){
            print TO "\\href{BGI_result/5.RSD_0_30/metaboAnalystInput-pos.csv}{正离子模式：RSD<=30%离子的强度信息：metaboAnalystInput-pos.csv}\n";
            print TO "\\href{BGI_result/5.RSD_0_30/quant-identification-pos.txt}{正离子模式：RSD<=30%离子的定量及定性信息：quant-identification-pos.txt}\n";
            foreach my $p(0..$#class){
                print TO "\\href{BGI_result/4.Differential/Quant/$class[$p]-diff-quant-pos.txt}{正离子模式：$class[$p]组差异离子定量信息：$class[$p]-diff-quant-pos.txt}\n";
                print TO "\\href{BGI_result/4.Differential/QuantIdenti/$class[$p]-diff-quant-identification-filtering-pos.txt}{正离子模式：$class[$p]组差异离子定量及定性信息：$class[$p]-diff-quant-identification-filtering-pos.txt}\n";
            }
        }
        if($metaX_neg){
            print TO "\\href{BGI_result/5.RSD_0_30/metaboAnalystInput-neg.csv}{负离子模式：RSD<=30%离子的强度信息：metaboAnalystInput-neg.csv}\n";
            print TO "\\href{BGI_result/5.RSD_0_30/quant-identification-neg.txt}{负离子模式：RSD<=30%离子的定量及定性信息：quant-identification-neg.txt}\n";
            foreach my $v(0..$#class){
                print TO "\\href{BGI_result/4.Differential/Quant/$class[$v]-diff-quant-neg.txt}{负离子模式：$class[$v]组差异离子定量信息：$class[$v]-diff-quant-neg.txt}\n";
                print TO "\\href{BGI_result/4.Differential/QuantIdenti/$class[$v]-diff-quant-identification-filtering-neg.txt}{负离子模式：$class[$v]组差异离子定量及定性信息：$class[$v]-diff-quant-identification-filtering-neg.txt}\n";
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
    if($_=~/ 液相参数描述/){
        if(($sample eq "serum" || $sample eq "tissue")&& $expType eq "globe"){
            print TO "采用ACQUITY UPLC BEH C18 column (100mm*2.1mm，1.7μm， Waters，UK)进行色谱分离，色谱柱柱温为50 °C，流速为0.4ml/min，其中A流动相为水和0.1%甲酸，B流动相为甲醇和0.1%甲酸。对代谢物采用以下梯度进行洗脱：0-2min，100%流动相A；2-11min, 0-100%流动相B；11-13min，100%流动相B；13-15min则为100%流动相A。每个样本的上样体积为10μl。\n\@paragraph\nAll samples were acquired by the LC-MS system followed machine orders. Firstly, all chromatographic separations were performed using an ultra performance liquid chromatography (UPLC) system (Waters, UK).An ACQUITY UPLC BEH C18 column (100mm*2.1mm, 1.7μm, Waters，UK)was used for the reversed phase separation. The column oven was maintained at 50 °C. The flow rate was 0.4 ml/min and the mobile phase consisted of solvent A (water + 0.1% formic acid) and solvent B (acetonitrile + 0.1% formic acid). Gradient elution conditions were set as follows: 0～2 min，100% phase A; 2~11 min，0% to 100% B; 11~13 min，100% B; 13～15 min，100% A. The injection volume for each sample was 10 μl.\n";
        }
        if(($sample eq "serum" || $sample eq "tissue")&& $expType eq "lipids"){
            print TO "采用ACQUITY UPLC CSH C18 column (100 mm*2.1 mm，1.7 μm， Waters，UK)进行色谱分离，色谱柱柱温为55 °C，流速为0.4 ml/min，其中A流动相为ACN:H2O=60:40，0.1% FA和10mM甲酸氨，B流动相为IPA:ACN=90:10，0.1% FA和10mM甲酸氨。对代谢物采用以下梯度进行洗脱：0-2 min，40-43%流动相B；2.1-7 min，50-54%流动相B；7.1-13 min，70-99%流动相B；13.1-15 min，40%流动相B。每个样本的上样体积为10 μl。\n\@paragraph\nAll samples were acquired by the LC-MS system followed machine orders. Firstly, all chromatographic separations were performed using an ultra performance liquid chromatography (UPLC) system (Waters, UK).An ACQUITY UPLC CSH C18 column (100 mm*2.1 mm，1.7 μm, Waters，UK) was used for the separation. The column oven was maintained at 55 °C. The flow rate was 0.4 ml/min and the mobile phase consisted of solvent A (ACN: H2O=60:40, 0.1% formate acid and 10mM ammonium formate) and solvent B (IPA: ACN=90:10, 0.1% formate acid and 10mM ammonium formate). Gradient elution conditions were set as follows: 0~2 min，40-43% phase B; 2.1~7 min，50-54% phase B; 7.1-13 min, 70-99% phase B; 13.1-15 min, 40% phase B. The injection volume for each sample was 10 μl.\n";
        }
        if($sample eq "urine" && $expType eq "globe"){
            print TO "采用ACQUITY UPLC HSS T3 column (100 mm*2.1 mm，1.8 μm，Waters，UK) 进行色谱分离，色谱柱柱温为40 °C，流速为0.5 ml/min，其中A流动相为水和0.1%甲酸，B流动相为乙腈和0.1%甲酸。对代谢物采用以下梯度进行洗脱：0-1 min，99%流动相A；1-3 min，1-15%流动相B；3-6 min，15-50%流动相B；6-9 min则为50-95%流动相B； 9-10 min则为95%流动相B； 10.1-12 min则为99%流动相A。每个样本的上样体积为10 μl。\n\@paragraph\nAll samples were acquired by the LC-MS system followed machine orders. Firstly, all chromatographic separations were performed using an ultra performance liquid chromatography (UPLC) system (Waters, UK).An ACQUITY UPLC HSS T3 column (100 mm*2.1 mm, 1.8 μm, Waters, UK) was used for the reversed phase separation. The column oven was maintained at 40 °C. The flow rate was 0.4 ml/min and the mobile phase consisted of solvent A (water + 0.1% formic acid) and solvent B (acetonitrile + 0.1% formic acid). Gradient elution conditions were set as follows: 0~1 min，99% phase A; 1~3min，1% to 15% phase B; 3~6 min，15-50% phase B; 6～9 min，50-95% phase A, 9-10 min, 95% phase B; 10.1-12 min, 99% phase A. The injection volume for each sample was 10 μl.";
        }
        next;
    }
    if($_=~/ 质谱参数描述/){
        if($expType eq "globe"){
            print TO "对从色谱柱上洗脱下来的小分子，利用高分辨串联质谱Xevo G2-XS QTOF (Waters， UK)分别进行正负离子模式采集。正离子模式下，毛细管电压和锥孔电压分别为0.25 kV和40 V。负离子模式下，毛细管电压及锥孔电压分别为2 kV和40 V。采用MSE模式进行centroid数据采集，一级扫描范围为50-1200 Da，扫描时间为0.2 s，对所有母离子按照20到40 eV的能量进行碎裂，采集所有的碎片信息，扫描时间为0.2 s。在数据采集过程中，对LE信号每3 s进行实时质量校正。同时，每隔10个样本进行一次混合后质控样本的采集，用于评估在样本采集过程中仪器状态的稳定性。\n\@paragraph\nA high-resolution tandem mass spectrometer Xevo G2 XS QTOF (Waters, UK) was used to detect metabolites eluted form the column. The Q-TOF was operated in both positive and negative ion modes. For positive ion mode, the capillary and sampling cone voltages were set at 0.25 kV and 40 V, respectively. For negative ion mode, the capillary and sampling cone voltages were set at 2 kV and 40V, respectively. The mass spectrometry data were acquired in Centroid MSE mode. The TOF mass range was from 50 to 1200 Da and the scan time was 0.2 s. For the MS/MS detection, all precursors were fragmented using 20-40 eV, and the scan time was 0.2 s. During the acquisition, the LE signal was acquired every 3 s to calibrate the mass accuracy. Furthermore, in order to evaluate the stability of the LC-MS during the whole acquisition, a quality control sample (Pool of all samples) was acquired after every 10 samples.\n";
        }
        if($expType eq "lipids"){
            print TO "对从色谱柱上洗脱下来的小分子，利用高分辨串联质谱Xevo G2-XS QTOF (Waters， UK)分别进行正负离子模式采集。正离子模式下，毛细管电压和锥孔电压分别为0.25 kV和40 V。负离子模式下，毛细管电压及锥孔电压分别为2 kV和40 V。采用MSE模式进行centroid数据采集，正离子一级扫描范围为100-2000 Da，负离子为50-2000Da，扫描时间为0.2 s，对所有母离子按照19到45 eV的能量进行碎裂，采集所有的碎片信息，扫描时间为0.2 s。在数据采集过程中，对LE信号每3 s进行实时质量校正。同时，每隔10个样本进行一次混合后质控样本的采集，用于评估在样本采集过程中仪器状态的稳定性。\n\@paragraph\nA high-resolution tandem mass spectrometer Xevo G2 XS QTOF (Waters, UK) was used to detect metabolites eluted form the column. The Q-TOF was operated in both positive and negative ion modes. For positive ion mode, the capillary and sampling cone voltages were set at 0.25 kV and 40 V, respectively. For negative ion mode, the capillary and sampling cone voltages were set at 2 kV and 40 V, respectively. The mass spectrometry data were acquired in Centroid MSE mode. The TOF mass range was from 100 to 2000 Da in positive mode and 50 to 2000 Da in negative mode. And the survey scan time was 0.2s . For the MS/MS detection, all precursors were fragmented using 19-45 eV, and the scan time was 0.2 s. During the acquisition, the LE signal was acquired every 3 s to calibrate the mass accuracy. Furthermore, in order to evaluate the stability of the LC-MS during the whole acquisition, a quality control sample (Pool of all samples) was acquired after every 10 samples.\n";
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
