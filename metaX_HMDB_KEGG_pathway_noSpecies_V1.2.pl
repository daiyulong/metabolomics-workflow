#!/usr/bin/perl -w
use Getopt::Long;
use Cwd;
####cmd parameters
my $bin="/ifs5/ST_METABO/PMO/2015_project/pipeline/PathwayBinMetaXNoSpecies";
my ($total,$diff_indir,$species,$indir,$outdir,$help);
GetOptions(
        "total:s"       => \$total,
        "diff:s"        => \$diff,
        "species:s"     => \$species,
	"outdir:s"	=> \$outdir,	
        "help|?"        => \$help
);

####helps
if (!defined $total || !defined $diff || defined $help) {
        die << "USAGE";
description     : draw KEGG Map for both total and diff identificated motablic moleculars in kegg pathway
      usage     : perl $0 [options]
    options     :
		-total <file> result of total identification file,quant-identification.txt in Stat.pl result
		-diff <path> input directory, differential identification file between group,Stat.pl result
		-species <three-letter,lowercase> abbreviation for species,eg.hsa for human,mmu for mouse
		-outdir <full path> output directory, default is current directory 
		-help|? help information
           e.g. :
            perl $0 -total /ifs5/ST_METABO/USER/zengchunwei/metaxHtmlReport/Stat_mudan_neg/quant-identification.txt -diff /ifs5/ST_METABO/USER/zengchunwei/metaxHtmlReport/Stat_mudan_neg -species mmu -outdir /ifs5/ST_METABO/USER/zengchunwei/metaxHtmlReport/Stat_mudan_neg_pathway
USAGE
}
if(! defined $outdir || $outdir eq "."){
	$outdir=getcwd;
	}

`sh $bin/diff_pathway_1.2.sh $species $diff $outdir $bin && perl $bin/metaboPath_total_1.2.pl -gff $total -tab $outdir/$species.cpd_ko.tab -kegg /ifs5/ST_METABO/PMO/2015_project/pipeline/database/KEGG79/KEGG79.gff -outdir $outdir &&  perl $bin/metabo_genPathHTML.pl -indir $outdir/total`;




