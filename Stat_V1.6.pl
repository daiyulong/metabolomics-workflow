#!/usr/bin/perl -w
use strict;
use Getopt::Long;

# add Adduct,isotope,netural mass, charge informations compared to Stat_V1.4.pl

my ($meas,$metax,$prefix,$mode,$test,$vip,$out);
GetOptions(
    "meas=s" => \$meas,
    "metax=s" => \$metax,
    "prefix=s" => \$prefix,
    "mode=s" => \$mode,
    "test=s" => \$test,
    "vip=s" => \$vip,
    "out=s" => \$out,
);
die "
    Description:Summarize metaX result,draw volcano,draw heatmap graph of different m/z and prepare files for pathway analysis
    Usage:
    -meas   <file>  *measurement.csv file
    -metax  <path>  metaX result directory
    -prefix <str>   prefix in metaX,usually be pos or neg
    -mode   <str>   pos or neg
    -test   <str>   used to choose different m/z,choose t.test_p.value or wilcox.test_p.value or t.test_p.value_BHcorrect or wilcox.test_p.value_BHcorrect
    -vip    <str>   1 or 2, 2 indicates VIP will not be taken into account when select different m/z
    -out    <path>  output directory
    e.g.:
    perl $0 -meas *measurment.csv -metax metaxPos -prefix pos -mode pos -test wilcox.test_p.value -vip 1 -out StatPos\n" unless ($meas and $metax and $prefix and $mode and $test and $vip);

`mkdir -p $out` unless -d "$out";

my $Rscript="/ifs5/ST_METABO/PMO/2015_project/pipeline/software/3.3.3/bin/Rscript";
my $KEGG="/ifs5/ST_METABO/PMO/2015_project/pipeline/database/KEGG81/kegg_81_chart.txt";
my $HMDB="/ifs5/ST_METABO/PMO/2015_project/pipeline/database/hmdb3.6.gff";
my $Lipidmaps="/ifs5/ST_METABO/PMO/2015_project/pipeline/database/Lipidmaps.txt";

my (%Cname,%Cmap,%HtoC,%LtoC)=();
open IN,"<$KEGG"or die "unexist file $KEGG!";
while(<IN>){
    chomp;
    my @r=split /\t/;
    $Cname{$r[0]}=$r[1];
    $Cmap{$r[0]}=$r[5];
}
close IN;

open IN,"<$HMDB"or die "unexist file $HMDB!";
while(<IN>){
    chomp;
    my @r=split /\t/;
    $HtoC{$r[3]}=$r[7];
}
close IN;

open IN,"<$Lipidmaps"or die "unexist file $Lipidmaps";
while(<IN>){
    chomp;
    my @r=split /\t/;
    $LtoC{$r[0]}=$r[9];
}
close IN;

my %hash=(
    't.test_p.value' =>2,
    'wilcox.test_p.value' =>3,
    't.test_p.value_BHcorrect' =>4,
    'wilcox.test_p.value_BHcorrect' =>5
);
##### put pathway map into *identification table
my ($IDcolumn,$nameColumn,$mzIDCol,$ratioCol,$tpCol,$wpCol,$tqCol,$wqCol,$VIPCol,$sampleCol,$FormuCol,$scoreCol,$FragCol,$massCol,$mzCol,$retenCol,$AdductCol,$isotopeCol,$neutralCol,$chargeCol);
open TO,">$out/quant-identification.txt"or die $!;
open OUT,">$out/one-test-quant-identification.txt"or die $!;
open IN,"<$metax/data/$prefix-quant-identification.txt"or die "unexist file $prefix-quant-identification.txt!";
    while(<IN>){
        chomp;
        my $line=();
        my @r=split /\t/;

        if($.==1){
            foreach my $i(0..$#r){
                if($r[$i]=~/^Compound/i){$IDcolumn=$i;}elsif($r[$i]=~/^Description$/i){$nameColumn=$i;}elsif($r[$i]=~/^ID$/i){$mzIDCol=$i;}elsif($r[$i]=~/^ratio$/i){$ratioCol=$i;}elsif($r[$i]=~/^t.test_p.value$/i){$tpCol=$i;}elsif($r[$i]=~/^wilcox.test_p.value$/i){$wpCol=$i;}elsif($r[$i]=~/^t.test_p.value_BHcorrect$/i){$tqCol=$i;}elsif($r[$i]=~/^wilcox.test_p.value_BHcorrect$/i){$wqCol=$i;}elsif($r[$i]=~/^VIP$/i){$VIPCol=$i;}elsif($r[$i]=~/^sample$/i){$sampleCol=$i;}elsif($r[$i]=~/^Formula$/i){$FormuCol=$i;}elsif($r[$i]=~/^score$/i){$scoreCol=$i;}elsif($r[$i]=~/^Fragmentation/i){$FragCol=$i;}elsif($r[$i]=~/^Mass/i){$massCol=$i;}elsif($r[$i]=~/^m.z$/i){$mzCol=$i;}elsif($r[$i]=~/^Retention/i){$retenCol=$i;}elsif($r[$i]=~/^Adducts/i){$AdductCol=$i;}elsif($r[$i]=~/^Isotope/i){$isotopeCol=$i;}elsif($r[$i]=~/^Neutral/i){$neutralCol=$i;}elsif($r[$i]=~/^Charge/i){$chargeCol=$i;}
            }
            push @r,"Pathway";
            $r[$IDcolumn]="ID";
            $r[$IDcolumn+1]="KEGG ID";
            if($vip==1){
                print TO "Compound ID\t$r[$ratioCol]\t$r[$tpCol]\t$r[$wpCol]\t$r[$tqCol]\t$r[$wqCol]\t$r[$VIPCol]\t$r[$sampleCol]\t$r[$IDcolumn]\t$r[$IDcolumn+1]\t$r[$FormuCol]\t$r[$AdductCol]\t$r[$scoreCol]\t$r[$FragCol]\t$r[$massCol]\t$r[$isotopeCol]\t$r[$nameColumn]\t$r[$mzCol]\t$r[$neutralCol]\t$r[$retenCol]\t$r[$chargeCol]\t$r[$#r]\n";
                print OUT "$r[$mzIDCol]\t$r[$ratioCol]\t$r[$hash{$test}]\t$r[$VIPCol]\t$r[$sampleCol]\t$r[$IDcolumn]\t$r[$IDcolumn+1]\t$r[$FormuCol]\t$r[$AdductCol]\t$r[$scoreCol]\t$r[$FragCol]\t$r[$massCol]\t$r[$isotopeCol]\t$r[$nameColumn]\t$r[$mzCol]\t$r[$neutralCol]\t$r[$retenCol]\t$r[$chargeCol]\t$r[$#r]\n";
            }else{
                print TO "Compound ID\t$r[$ratioCol]\t$r[$tpCol]\t$r[$wpCol]\t$r[$tqCol]\t$r[$wqCol]\t$r[$sampleCol]\t$r[$IDcolumn]\t$r[$IDcolumn+1]\t$r[$FormuCol]\t$r[$AdductCol]\t$r[$scoreCol]\t$r[$FragCol]\t$r[$massCol]\t$r[$isotopeCol]\t$r[$nameColumn]\t$r[$mzCol]\t$r[$neutralCol]\t$r[$retenCol]\t$r[$chargeCol]\t$r[$#r]\n";
                print OUT "$r[$mzIDCol]\t$r[$ratioCol]\t$r[$hash{$test}]\t$r[$sampleCol]\t$r[$IDcolumn]\t$r[$IDcolumn+1]\t$r[$FormuCol]\t$r[$AdductCol]\t$r[$scoreCol]\t$r[$FragCol]\t$r[$massCol]\t$r[$isotopeCol]\t$r[$nameColumn]\t$r[$mzCol]\t$r[$neutralCol]\t$r[$retenCol]\t$r[$chargeCol]\t$r[$#r]\n"; 
            }
            next;
        }

        if($r[$IDcolumn]=~/^C/){
            $r[$IDcolumn+1]=$r[$IDcolumn];
            if(exists $Cname{$r[$IDcolumn]}){
                $r[$nameColumn]=$Cname{$r[$IDcolumn]};
                push @r,$Cmap{$r[$IDcolumn]};
            }else{
                push @r,"NULL";
            }
        }elsif($r[$IDcolumn]=~/^H/){
                if(exists $HtoC{$r[$IDcolumn]}){
                    $r[$IDcolumn+1]=$HtoC{$r[$IDcolumn]};
                    if(exists $Cmap{$HtoC{$r[$IDcolumn]}}){
                        push @r,$Cmap{$HtoC{$r[$IDcolumn]}};
                    }else{push @r,"NULL";}
                }else{
                    $r[$IDcolumn+1]="NULL";
                    push @r,"NULL";
                }
        }elsif($r[$IDcolumn]=~/^L/){
                if(exists $LtoC{$r[$IDcolumn]}){
                    $r[$IDcolumn+1]=$LtoC{$r[$IDcolumn]};
                    if(exists $Cmap{$LtoC{$r[$IDcolumn]}}){
                        push @r,$Cmap{$LtoC{$r[$IDcolumn]}};
                    }else{push @r,"NULL";}
                }else{
                    $r[$IDcolumn+1]="NULL";
                    push @r,"NULL";
                }
        }
            if($vip==1){
                    print TO "$r[$mzIDCol]\t$r[$ratioCol]\t$r[$tpCol]\t$r[$wpCol]\t$r[$tqCol]\t$r[$wqCol]\t$r[$VIPCol]\t$r[$sampleCol]\t$r[$IDcolumn]\t$r[$IDcolumn+1]\t$r[$FormuCol]\t$r[$AdductCol]\t$r[$scoreCol]\t$r[$FragCol]\t$r[$massCol]\t$r[$isotopeCol]\t$r[$nameColumn]\t$r[$mzCol]\t$r[$neutralCol]\t$r[$retenCol]\t$r[$chargeCol]\t$r[$#r]\n";
                    print OUT "$r[$mzIDCol]\t$r[$ratioCol]\t$r[$hash{$test}]\t$r[$VIPCol]\t$r[$sampleCol]\t$r[$IDcolumn]\t$r[$IDcolumn+1]\t$r[$FormuCol]\t$r[$AdductCol]\t$r[$scoreCol]\t$r[$FragCol]\t$r[$massCol]\t$r[$isotopeCol]\t$r[$nameColumn]\t$r[$mzCol]\t$r[$neutralCol]\t$r[$retenCol]\t$r[$chargeCol]\t$r[$#r]\n";
                }else{
                    print TO "$r[$mzIDCol]\t$r[$ratioCol]\t$r[$tpCol]\t$r[$wpCol]\t$r[$tqCol]\t$r[$wqCol]\t$r[$sampleCol]\t$r[$IDcolumn]\t$r[$IDcolumn+1]\t$r[$FormuCol]\t$r[$AdductCol]\t$r[$scoreCol]\t$r[$FragCol]\t$r[$massCol]\t$r[$isotopeCol]\t$r[$nameColumn]\t$r[$mzCol]\t$r[$neutralCol]\t$r[$retenCol]\t$r[$chargeCol]\t$r[$#r]\n";
                    print OUT "$r[$mzIDCol]\t$r[$ratioCol]\t$r[$hash{$test}]\t$r[$sampleCol]\t$r[$IDcolumn]\t$r[$IDcolumn+1]\t$r[$FormuCol]\t$r[$AdductCol]\t$r[$scoreCol]\t$r[$FragCol]\t$r[$massCol]\t$r[$isotopeCol]\t$r[$nameColumn]\t$r[$mzCol]\t$r[$neutralCol]\t$r[$retenCol]\t$r[$chargeCol]\t$r[$#r]\n"; 
                }
}
close IN;
close TO;

my $filterIon;
open IN,"<$out/../logFile/metaX.R.$prefix.loge"or die "unexist $out/logFile/metaX.R.$prefix.loge file $!";
while(<IN>){
    chomp;
    if($_=~/\d\s+QC\s+(\d+)\s+(\d+)\s+(\d+)/){
        $filterIon=$1;
        last;
    }
}
close IN;

my $Rcode=<<qq;

#library(pheatmap)
library(grid)
library(RColorBrewer)
library(scales)
library(gtable)
library(stats)
library(grDevices)
library(graphics)
library(ggplot2)

source("/ifs5/ST_METABO/PMO/2015_project/pipeline/MetaXHtmlReport/pheatmap.r")

meas<-read.csv("$meas")
norm<-read.csv("$metax/data/$prefix-norm-metaboAnalystInput.csv",check.names=F)
iden<-read.table("$metax/data/$prefix-quant-identification.txt",header=T,sep="\\t",quote="")

###### Summary.1.txt #########
summ1<-matrix(0,nrow=1,ncol=5)
colnames(summ1)<-c("mode","total ion number","RSD<=30% ion number","MS","MS2")
summ1[1,1]<-"$mode"
summ1[1,2]<-summ1_2<-nrow(meas)-2 ## total ion number
summ1[1,3]<-summ1_3<-nrow(norm)-1 ## RSD<=30% ion number
summ1[1,5]<-length(unique(iden[(!is.na(iden\$Compound.ID)& iden\$Fragmentation.Score!=0),][,1])) ## MS2
summ1[1,4]<-length(unique(iden[!is.na(iden\$Compound.ID),][,1])) ## MS1
write.table(summ1,"$out/Summary.1.txt",sep="\\t",row.names=F,quote=F)
    
quant<-read.table("$metax/data/$prefix-quant.txt",header=T,sep="\\t")
iden<-read.delim("$out/one-test-quant-identification.txt",header=T,sep="\\t",quote="")

group<-unique(quant\$sample)

R2Q2<-matrix(0,nrow=length(group),ncol=6)
colnames(R2Q2)<-c("mode","group","R2","Q2","pvalue(R2)","pvalue(Q2)")

summ2<-matrix(0,nrow=length(group),ncol=7)
colnames(summ2)<-c("mode","group","diff ion number","up","down","MS","MS2")
summ4<-matrix(0,nrow=length(group),ncol=7)
colnames(summ4)<-c("mode","group","diff ion number","up(MS)","down(MS)","up(MS2)","down(MS2)")

for(j in 1:length(group)){

    samp<-chartr(":","_",group[j])

    ########### volcano ##########################
    volClass<-quant[quant\$sample==group[j],]
    volFrame<-data.frame(CompoundID=volClass\$ID,ratio=volClass\$ratio,value=volClass\$$test)
    write.table(volFrame,paste("$out/",samp,"-volcano-$mode.txt",sep=""),sep="\\t",row.names=F)

    volFrame\$sig<-((volFrame\$ratio<=1/1.2 | volFrame\$ratio>=1.2)& volFrame\$value<0.05)
    pdf(paste("$out/",samp,"-volcano-$mode.pdf",sep=""),w=5,h=5)
    g<-ggplot(data=volFrame,aes(x=log2(ratio),y=-log10(value),colour=sig))+theme_bw()+geom_point(alpha=0.7)+scale_colour_manual(values=c("#9999CC","red"))+xlab("Log2(Fold change)")+ylab("-Log10($test)")+theme(legend.position="none")
    print(g)
    dev.off()

    ########### diff-quant.txt ###################
    diff<-quant[quant\$sample==group[j],][,c(1,2,$hash{$test}+1,7)]
    
    if($vip==1){
        sig<-((diff\$ratio<=1/1.2 | diff\$ratio>=1.2)& diff\$$test<0.05 & diff\$VIP>=1)
        diff<-diff[sig,]
    }else{
        sig<-((diff\$ratio<=1/1.2 | diff\$ratio>=1.2)& diff\$$test<0.05)
        diff<-diff[sig,][,1:3]
    }
    colnames(diff)[1]<-c("Compound ID")
    write.table(diff,paste("$out/",samp,"-diff-quant.txt",sep=""),sep="\\t",row.names=F,quote=F)
    
    ############# diff-quant-identification.txt ##############
    identi<-merge(iden[iden\$sample==group[j],],diff[,1:2],by.x="ID",by.y="Compound ID")
    identi<-identi[,-(ncol(identi))]
    #if($vip==2){identi<-identi[,-4]}
    colnames(identi)[1:2]<-c("Compound ID","ratio")
    write.table(identi,paste("$out/",samp,"-diff-quant-identification.txt",sep=""),sep="\\t",row.names=F,quote=F)

    ############ heatmap.pdf ####################
    str<-strsplit(samp,split="_")[[1]]
    heatNum<-merge(norm,diff[,1:2],by.x="Sample",by.y="Compound ID")
    if(nrow(heatNum)>1){
    heatNum<-rbind(norm[1,],heatNum[,-(ncol(heatNum))])
    rowname<-heatNum[,1]
    heatNum<-heatNum[,(heatNum[1,]==str[1] | heatNum[1,]==str[2])]

    classLabel<-data.frame(t(heatNum[1,]))
    classLabel[,1]<-as.character(classLabel[,1])
    colnames(classLabel)<-"class"
    data<-as.matrix(heatNum[-1,])
    data<-matrix(as.numeric(data),nrow=nrow(data))
    x<-log2(data)
    colnames(x)<-colnames(heatNum)
    rownames(x)<-rowname[-1]
    pdf(paste("$out/",samp,"-diff-heatmap-$mode.pdf",sep=""),width=5,height=5)
    pheatmap(x,annotation=classLabel,scale="row",color=colorRampPalette(c("green","black","red"))(255),show_colnames=F,show_rownames=F,border_color=NA,out_file=paste("$out/",samp,"-diff-heatmap-$mode.txt",sep=""))
    dev.off()

    #x<-rbind(classLabel\$class,x)
    #rownames(x)<-rowname
    #write.table(x,paste("$out/",samp,"-diff-heatmap-$mode.txt",sep=""),sep="\\t",quote=F,col.names=NA)
    }else{
        cat(paste("There's no differente m/z between",samp,sep=""))
    }
    
    ############ R2_Q2 ############################################
    if($vip==1){
        plsda<-readRDS(paste("$metax/data/$prefix-",samp,"-plsDAmodel.rds",sep=""))
        R2Q2[j,3]<-round(plsda\$plsda\$res\$R2,4)
        R2Q2[j,4]<-round(plsda\$plsda\$res\$Q2,4)
        R2Q2[j,5]<-round(plsda\$pvalue\$R2,4)
        R2Q2[j,6]<-round(plsda\$pvalue\$Q2,4)
        R2Q2[j,1]<-"$mode"
        R2Q2[j,2]<-samp
        write.table(R2Q2,"$out/R2_Q2.txt",sep="\\t",row.names=F,quote=F)
    }
    pca<-readRDS(paste("$metax/data/$prefix-",samp,"-pca.rds",sep=""))

    #plsClass<-plsda\$class\$rawLabel
    plsSample<-rownames(pca\@scores)

    ############ PLS-DA score ###################################
    if($vip==1){
        plsdaScores<-data.frame(sample=plsSample,Comp1=plsda\$model\$scores[,1],Comp2=plsda\$model\$scores[,2])
        write.table(plsdaScores,paste("$out/",samp,"-plsdaScores-$mode.txt",sep=""),sep="\\t",row.names=F)
    }
    ############ PCA scores of two group ########################
    pcaScores<-data.frame(sample=plsSample,Comp1=pca\@scores[,1],Comp2=pca\@scores[,2])
    write.table(pcaScores,paste("$out/",samp,"-pcaScores-$mode.txt",sep=""),sep="\\t",row.names=F)

    ############ summary.2.txt #################################
    summ2[j,1]<-"$mode"
    summ2[j,2]<-samp
    summ2[j,3]<-nrow(diff)
    summ2[j,4]<-nrow(diff[diff\$ratio>1,])
    summ2[j,5]<-nrow(diff[diff\$ratio<1,])
    summ2[j,7]<-summ2_7<-length(unique(identi[(identi\$Fragmentation.Score!=0 & !is.na(identi\$Fragmentation.Score)),][,1]))
    summ2[j,6]<-summ2_6<-length(unique(identi[!is.na(identi\$Fragmentation.Score),][,1]))
    write.table(summ2,"$out/Summary.2.txt",sep="\\t",row.names=F,quote=F)
    
    ############ summary.4.txt ##################################
    summ4[j,1]<-"$mode"
    summ4[j,2]<-samp
    summ4[j,3]<-nrow(diff)
    summ4[j,6]<-summ4_6<-length(unique(identi[(identi\$ratio>1 & identi\$Fragmentation.Score!=0 & !is.na(identi\$Fragmentation.Score)),][,1]))
    summ4[j,7]<-summ2_7-summ4_6
    summ4[j,4]<-summ4_4<-length(unique(identi[(identi\$ratio>1 & !is.na(identi\$Fragmentation.Score)),][,1]))
    summ4[j,5]<-summ2_6-summ4_4
    write.table(summ4,"$out/Summary.4.txt",sep="\\t",row.names=F,quote=F)
}
    
    ############### summary.3.txt ####################
    summ3<-matrix(0,nrow=1,ncol=5)
    colnames(summ3)<-c("mode","total ion number","ion number after low quality ion filtering","RSD<=30% ion number","ratio(%)")
    summ3[1,1]<-"$mode"
    summ3[1,2]<-summ1[1,2]
    summ3[1,3]<-$filterIon
    summ3[1,4]<-summ1[1,3]
    summ3[1,5]<-round(summ1_3/$filterIon*100,2)
    write.table(summ3,"$out/Summary.3.txt",sep="\\t",row.names=F,quote=F)

    ############## PCA scores of all samples including QC #############################
    qcPCA<-readRDS("$metax/data/$prefix-pca.rds")
    qcPCAscores<-data.frame(sample=rownames(qcPCA\@scores),Comp1=qcPCA\@scores[,1],Comp2=qcPCA\@scores[,2])
    write.table(qcPCAscores,"$out/qcPCAscores-$mode.txt",sep="\\t",row.names=F)

    ############## PCA scores of all samples ############################
    PCA<-readRDS("$metax/data/$prefix-noqc-pca.rds")
    PCAscores<-data.frame(sample=rownames(PCA\@scores),Comp1=PCA\@scores[,1],Comp2=PCA\@scores[,2])
    write.table(PCAscores,"$out/PCAscores-$mode.txt",sep="\\t",row.names=F)

qq

open TO,">$out/Rcode.R"or die $!;
print TO "$Rcode";
close TO;
`$Rscript $out/Rcode.R`;
`rm $out/one-test-quant-identification.txt`;
