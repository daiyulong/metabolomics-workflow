#!/usr/bin/perl

#This program is aimed to check the arf file
#
#
#author:		dengshengyuan@genomics.cn
#version:		v1.0
#Date:			11/03/2015


use strict;
use warnings;
use Cwd;
use CGI qw(:standard);
use Getopt::Long;
use File::Basename qw(dirname basename);
use File::Path qw(mkpath);
use FindBin qw($Bin);



my ($arf, $data_dir, $help);
GetOptions(
	"i=s" => \$arf,
	"d=s" => \$data_dir,
	"help|?" => \$help
);

&usage() if(!$arf || $help);


#global variable
my $format = "";
my $lan = "";
my $pos;
my $line = 0;
my $error_line = 0;
my $lastlabel = "";
my $nowlabel = "";
my $success = 1;
my $flag_MENU = 0;
my $flag_TITLE = 0;
my $flag_ref_check = 0;
my $isArfFolder = 0;
#mark the %, such as %result, %method ...
my $type_label = "";
my $nowArf = "";
#mark the title
my $now_title = "";
#save the title
#save line, %, title_name
my @each_title;
#FROM paragraph content
#save the line,title, table_number
my @number_table_paragraph;
#save the line, title, figure_number
my @number_figure_paragraph;
#save the line, title, reference_number
my @number_reference_paragraph;
#each title, the number of table, figure, reference
#
my @number_table;
my @number_figure;
my @number_reference;
#flag
#array
my @old_menu = ("\%result", "\%method", "\%help", "\%glossary", "\%FAQ");
my @menu = ("\%Results", "\%Methods", "\%Help", "\%Glossaries", "\%FAQs");

my @content;
my @arf_folder;
my @arf_filename;

##############################################
##########	main start 	##############
if ( -d $arf ) {
	$isArfFolder = 1;
        opendir ( TEMPDIR, $arf ) or die "can't open $arf :$!";
        @arf_folder = readdir TEMPDIR;
        close TEMPDIR;

	# put the arf file name into @arf_filename
	foreach ( @arf_folder ) {
        	if($_ =~ /^(.*?)\.arf$/){
                	push @arf_filename, $_;
        	}
	}
	
	foreach ( @arf_filename ) {
		my $arfName = $_;
		
		if ( -e "$arf/$arfName") {
			$nowArf = $arfName;
			&arfProcess("$arf/$arfName");
			&resetValue();
		}		
	}
	print "\nReference check:\n";
	&referenceCheck();
	if ( !$flag_ref_check ) {
		print "The reference is perfect!\n";
	}
} else {
	$nowArf = $arf;
	$nowArf =~ s/^.*\///;
	&arfProcess("$arf");
#	print "\nReference check:\n";
        &referenceCheck();
#        if ( !$flag_ref_check ) {
#                print "The reference is perfect!\n";
#        }
	if ( $success ) {
                print "The arf format is correct.\n";
        }

        print "*****    FINISH  *****\n";
        
}

sub arfProcess(){
	my @inputArf = @_;

	print "$nowArf	\n";
	print "*****	START	*****\n";

	#check the arf file  exist
	if (!(-e $inputArf[0]) ) {
		print "the arf does not exist!\n";
		exit;	
	}


	if(!$data_dir){
		print "warning: It will not check the table and the figure exist.\n";
	
	}

	open IN, $inputArf[0] or die $!;

	while(<IN>){
		chomp;
		#It's used to print error position
	#	next if(/^$/ || /^#/);
		$line++;
		if(($_ =~ /^(format)\s?=\s?(.*?)$/) && !($lastlabel eq "\@table")){
			$nowlabel = $1;
			if($lastlabel){
				&main_process($lastlabel, @content);
				$lastlabel = $1;
				undef @content;
			}else{
				$lastlabel = $1;
				undef @content;
			}
			$error_line = $line;
		}elsif($_ =~ /^(language)\s?=\s?(.*?)$/){
			$nowlabel = $1;
			&main_process($lastlabel, @content);
			$lastlabel = $1;
			undef @content;
		
		}elsif($_ =~ /^(\%.*?)(\s*?)$/){
			$nowlabel = $1;
			&main_process($lastlabel, @content);
			$error_line = $line;
			if($lastlabel =~ /^(\%.*?)$/){
				$success = 0;
				print "Format Error: Line $error_line. No content between $lastlabel and $nowlabel.\n";
			}
			$lastlabel = $1;
			$lastlabel =~ s/\s//g;
			undef @content;	
		}elsif($_ =~ /^(\@title)(\s*?)$/){
			$nowlabel = $1;
			&main_process($lastlabel, @content);
			$error_line = $line;
			#check $lastlabel n $nowlabel
			if($1 eq $lastlabel){
				$success = 0;
                	        print "Format Error: Line $error_line. No content between two titles.\n";
	                }
			$lastlabel = $1;
			undef @content;
		}elsif($_ =~ /^(\@paragraph)(\s*?)$/){
			$nowlabel = $1;
			&main_process($lastlabel, @content);
			$error_line = $line;
			$lastlabel = $1;
			undef @content;		
		}elsif($_ =~ /^(\@table)(\s*?)$/){
			$nowlabel = $1;
			&main_process($lastlabel, @content);
			$error_line = $line;
			$lastlabel = $1;
			undef @content;		
		}elsif($_ =~ /^(\@figure)(\s*?)$/){
			$nowlabel = $1;
			&main_process($lastlabel, @content);	
			$error_line = $line;
			$lastlabel = $1;
			undef @content;
		}elsif($_ =~ /^(\@reference)(\s*?)$/){
			$nowlabel = $1;
			&main_process($lastlabel, @content);
			$error_line = $line;
			$lastlabel = $1;
			undef @content;	
		}elsif($_ =~ /^(\@glossary)(\s*?)$/){
			$nowlabel = $1;
			&main_process($lastlabel, @content);
			$error_line = $line;
			$lastlabel = $1;
			undef @content;	
		}elsif($_ =~ /^(\@FAQ)(\s*?)$/){
			$nowlabel = $1;
			&main_process($lastlabel, @content);
			$error_line = $line;
			$lastlabel = $1;
			undef @content;
		}elsif($_ =~ /^(\@.*?)(\s*?)$/){
			$nowlabel = $1;
			&main_process($lastlabel, @content);
			$error_line = $line;
			$lastlabel = $1;
			undef @content;
		}

		#It's used to print error position
		push @content, $_;
	}

	close IN;

	#add the lastlabel
	&main_process($lastlabel, @content);

##########	check the variable	##########	

	#check the table number n the \table{number}in paragrap
	for my $i (0 .. $#number_table_paragraph){
		my $flag_number = 0;
		for my $j (0 .. $#number_table){
			if(($number_table_paragraph[$i][1] eq $number_table[$j][0]) && ($number_table_paragraph[$i][2] eq $number_table[$j][1])){
				$flag_number = 1;
			}
		}
		if(!$flag_number){
			$success = 0;
			print "Format Error: Line $number_table_paragraph[$i][0]. In \@paragraph, the \\table{$number_table_paragraph[$i][2]} does not exist.\n";
		}
	}


	#check the figure number n the \figure{number}in paragrap
	for my $i (0 .. $#number_figure_paragraph){
       		my $flag_number = 0;
        	for my $j (0 .. $#number_figure){
                	if(($number_figure_paragraph[$i][1] eq $number_figure[$j][0]) && ($number_figure_paragraph[$i][2] eq $number_figure[$j][1])){
                        	$flag_number = 1;
                	}
        	}
        	if(!$flag_number){
			$success = 0;
                	print "Format Error: Line $number_figure_paragraph[$i][0]. In \@paragraph, the \\figure{$number_figure_paragraph[$i][2]} does not exist.\n";
        	}
	}
	
	if(!$format){
        	$success = 0;
        	print "warning: No format! Please insert the format.\n";
	}
	if(!$lan){
        	print "warning: The arf is EN version.\n";
	}
	
	if ( $success && $isArfFolder ) {
		print "The arf format is correct.\n";
	}
	
	if ( $isArfFolder ) {
		print "*****	FINISH	*****\n\n";
	}
	
}
########## 	main end	##############
##############################################


##########	subroutine	##############

########## check rules n print the message ##########
#	sub main_process(){}			the main program
#	sub format_process(){}			process the format
#	sub lan_process(){}			process the lan
#	sub menu_process(){			process the menu
#	sub title_process(){}			process the title
#	sub paragraph_process(){}		process teh paragraph
#	sub table_process(){}			process the table
#	sub figure_process(){}			process the figure
#	sub reference_process(){}		process the reference
#	sub glossary_process(){}		process the glossary
#	sub FAQ_process(){}			process the FAQ
#	sub wrong_label_process(){}		process the erroe label
#	sub usage(){}				print the help information




sub main_process(){
	my ($lastlabel, @arf_content) = @_;

	if($lastlabel eq "format"){
		&format_process(@arf_content);

	}elsif($lastlabel eq "language"){
		&lan_process(@arf_content);

	}elsif($lastlabel =~ /^\%(.*?)$/){
		&menu_process(@arf_content);

	}elsif($lastlabel eq "\@title"){
		&title_process(@arf_content);


	}elsif($lastlabel eq "\@paragraph"){
		&paragraph_process(@arf_content);


	}elsif($lastlabel eq "\@table"){
		&table_process(@arf_content);


	}elsif($lastlabel eq "\@figure"){
		&figure_process(@arf_content);


	}elsif($lastlabel eq "\@reference"){
		&reference_process(@arf_content);


	}elsif($lastlabel eq "\@glossary"){
		&glossary_process(@arf_content);


	}elsif($lastlabel eq "\@FAQ"){
		&FAQ_process(@arf_content);

	}elsif($lastlabel =~ /(\@.*?)/){
		&wrong_label_process(@arf_content);
	}
}



#################################
sub format_process(){
	my @content = @_;
#	if(!($nowlabel =~ /^(\%)$/)){
#		print "Line:$error_line. The next label should be \%content, such as \%result, \%method, \%help, \%glossary or \%FAQ.\n";
#	}
	$error_line = $error_line - 1;
	foreach(@content){
		$error_line++;
		next if(/^$/ || /^#/);

		if($_ =~ /^(format)\s*?=\s*(.*?)$/){
			my $content = $2;
			$format = $content;
			if($content =~ /^(arf.*?)\s*$/){
				my $format_content = $1;
				if(!$format){
					#$format: the global variable, mark the format
					$format = $format_content;
				}else{
					#two formats are different
					my $temp_format = $format_content;
					#remove the space
					$temp_format =~ s/\s//g;
					my $temp2_format = $format;
					$temp2_format =~ s/\s//g;
					#the format space without space
					if(!($temp_format eq $temp2_format)){
						$success = 0;
						print "Format Error: Line $error_line. Two formats are different.\n";
					}
				}
			}else{
				$success = 0;
				print "Format Error: Line $error_line. The format is incorrect. \n";

			}
		}
	}
}


sub lan_process(){
	my @language = @_;
	foreach(@language){
		$error_line++;
		next if(/^$/ || /^#/);
		
		if($_ =~ /^(language)\s*?=\s*(.*?)\s*$/){
			$lan = $2;
			if(!(($lan eq "EN") || ($lan eq "CN") || ($lan eq "en") || ($lan eq "cn"))){
				$success = 0;
				print "Format Error: Line $error_line. The language should be EN, CN, en or cn.\n";								
			}
		}
	}
}

sub menu_process(){
	my @content = @_;
#	if(!($nowlabel eq "\@title")){
#		print "Line:$error_line. The next label should be \@title.\n";
#	}
	$flag_MENU = 1;
	$error_line = $error_line - 1;
	foreach(@content){
		$error_line++;
		next if(/^$/ || /^#/);
		
		if($_ =~  /^(\%.*?)$/){
			my $menu_content = $1;
			$menu_content =~ s/\s//g;
			if($menu_content eq "\%Results" || $menu_content eq "\%result"){
				$type_label = "\%result";
			}elsif($menu_content eq "\%Methods" || $menu_content eq "\%method"){
				$type_label = "\%method";
			}elsif($menu_content eq "\%Help" || $menu_content eq "\%help"){
				$type_label = "\%help";
			}elsif($menu_content eq "\%Glossaries" || $menu_content eq "\%glossary"){
				$type_label = "\%glossary";
			}elsif($menu_content eq "\%FAQs" || $menu_content eq "\%FAQ"){
				$type_label = "\%FAQ";
			}else{
				$type_label = $menu_content;
			}
			if(!($menu_content eq "\%Results" || $menu_content eq "\%result" || $menu_content eq "\%Methods" || $menu_content eq "\%method" || $menu_content eq "\%Help" || $menu_content eq "\%help" || $menu_content eq "\%Glossaries" || $menu_content eq "\%glossary" || $menu_content eq "\%FAQs" || $menu_content eq "\%FAQ")){

				$success = 0;
				print "warning: Line $error_line. New label $menu_content.\n";
			}
		}
	}
}

sub title_process(){
	my @content = @_;
	my $num = 0;
	my @temp_array_title;
	if(!$flag_MENU){
		$success = 0;
		print "Format Error: Line $error_line. The title should belong to a \%content, such as \%result, \%method, \%help, \%FAQ or \%glossary\n";
	}
	if(!($nowlabel eq "\@paragraph")){
		$success = 0;
		print "Format Error: Line $error_line. \@title: The next label should be \@paragraph.\n";
	}
	$flag_TITLE = 1;
	$error_line = $error_line - 1;
	foreach(@content){
		$error_line++;
                next if(/^$/ || /^#/);

		my $temp_content = $_;
		$temp_content =~ s/\s//g;
		if($temp_content){
			$num++;
			$now_title = $temp_content;
			if($num > 3){
         	        	$success = 0;
                		print "Format Error: Line $error_line. The \@title should contain only one line.\n";
        		}
		}
	}
	
}

sub paragraph_process(){
	my @content = @_;
	if(!$flag_TITLE){
		$success = 0;
		print "Format Error: Line $error_line. The \@paragraph should belong to a title\n";
	}
	$error_line = $error_line - 1;
	foreach(@content){
		$error_line++;
		next if(/^$/ || /^#/);

		my $temp_content = $_;
		while($temp_content =~ /\\table\s*?{(.*?)}/g){
			my $temp = $1;
                        #remove the space
                        $temp =~ s/\s//g;
			push @number_table_paragraph, [$error_line, $now_title, $temp];
		}
		while($temp_content =~ /\\figure\s*?{(.*?)}/g){
			my $temp = $1;
                        #remove the space
                        $temp =~ s/\s//g;
			push @number_figure_paragraph, [$error_line, $now_title, $temp];
		}
		
		while($temp_content =~ /\\reference\s*?{(.*?)}/g){
			my $temp = $1;
			#remove the space
			$temp =~ s/\s//g;
			push @number_reference_paragraph, [ $nowArf, $error_line, $now_title, $temp];
		}
	}
}

sub table_process(){
	my @content = @_;
	my $flag_title = 0;
	my $flag_file = 0;
	my $flag_format = 0;
	my $flag_view = 0;
	my $flag_exist = 0;
	my $table_path = "";
	my $num_format = 0;
	my $temp_line = $error_line;
	if(!$flag_TITLE){
                $success = 0;
                print "Format Error: Line $error_line. The \@table should belong to a title\n";
        }
	$error_line = $error_line - 1;
	foreach(@content){
		$error_line++;
		next if(/^$/ || /^#/);

		if($_ =~ /^number\s*=\s*(.*?)$/){
			if(!($1 =~ /^((?!=).*?)\s*?$/)){
				$success = 0;
				print "Format Error: Line $error_line. The number format is incorrect.\n";
			}else{
				my $temp = $1;
        	                #remove the space
	                        $temp =~ s/\s//g;
				push @number_table, [$now_title, $temp];
			}
		}elsif($_ =~ /^title\s*=\s*(.*?)$/){
			$flag_title = 1;
			if(!($1 =~ /^(?!=)\s*"(.*?)"/)){
				$success = 0;
				#error format
				print "Format Error: Line $error_line. The title format is incorrect.\n";
			}
		}elsif($_ =~ /^file\s*=\s*(.*?)$/){
			#the file is exist
			$flag_file = 1;
			if(!($1 =~ /^(?!=)<(.*?)>\s*$/)){
				$success = 0;
				#check the file format
				print "Format Error: Line $error_line. The file format is incorrect.\n";
			}else{
				if(!($1 =~ /^\s*?url\s*?=\s*?(.*?)$/)){
					$success = 0;
					#check the url exist in file
					print "Format Error: Line $error_line. The file should contain the url.\n";
				}else{
					my $content_path = $1;
					$content_path =~ s/\s//g;
					if(!$content_path){
						$success = 0;
						#The url does not have the table path in file
						print "Format Error: Line $error_line. The url should contain the table path in file\n";
					}else{
						if($data_dir){
							if(!(-e "$data_dir/$content_path")){
								$success = 0;
								print "File Error: Line $error_line. The table path does not exist.\n";
								print "Path: $data_dir/$content_path\n";
							}else{
								$flag_exist = 1;
								$table_path = "$data_dir/$content_path";
							}
						}
					}
				}
			}			
		}elsif($_ =~ /^format\s*=\s*(.*?)$/){
			#the format is exist
			$flag_format = 1;
			$num_format++;

			if(!($1 =~ /^(?!=)<(.*?)>\s*$/)){
				$success = 0;
				print "Format Error: Line $error_line. The 'format' is incorrect.\n";			
			}else{
				#check the content of format
				my $content_format = $1;
				if($content_format =~ /;/){
					my $flag_field = 0;
					my $flag_type = 0;
					my $mark_type = "";
					my @content = (split /;/, $content_format);
					#check each option
					foreach(@content){
						if($_ =~ /^\s*?field\s*=\s*(.*?)$/){
							$flag_field = 1;
							my $content_field = $1;
							$content_field =~ s/\s//g;
							if(!($content_field =~ /^\d+$/)){
								$success = 0;
								print "Format Error: Line $error_line. In the format,the field should be a number.\n";
							}
						}elsif($_ =~ /^\s*?type\s*=\s*(.*?)$/){
							$flag_type = 1;
							my $content_type = $1;
							#remove the space
							$content_type =~ s/\s//g;
							#check the type in format
							if($content_type eq "float"){
								$mark_type = "float";
							}
							if($content_type eq "scientific"){
								$mark_type = "scientific";
							}
							if(!($content_type eq "int" || $content_type eq "float" || $content_type eq "string" || $content_type eq "scientific" || $content_type eq "url")){
								$success = 0;
								print "Format Error: Line $error_line. In the format, the type should be int, float, string, scientific or url.\n";
							}
						}elsif($_ =~ /^\s*?precision\s*=\s*(.*?)$/){
							if(!($mark_type eq "float") && !($mark_type eq "scientific")){
								$success = 0;
								print "Format Error: Line $error_line. In the format, the type should be float or scientific.\n";
							}
							my $content_pre = $1;
							my $reg1 = qr/^-?\d+(\.\d+)?$/;
							my $reg2 = qr/^-?0(\d+)?$/;
							#remove the space
							$content_pre =~ s/\s//g;
							if(!(($content_pre =~ $reg1 && $content_pre !~ $reg2) || ($content_pre eq "0"))){
								$success = 0;
								print "Format Error: Line $error_line. In the format,the precision should be a number.\n ";
							}
						}elsif($_ =~ /^\s*?desc\s*=\s*(.*?)$/){
							if(!($1 =~ /^(?!=)"(.*?)"/)){
								$success = 0;
								print "Format Error: Line $error_line. In the format, the desc format is incorrect.\n";
							}else{
								my $content_desc = $1;
								if(!$content_desc){
									$success = 0;
									print "Format Error: Line $error_line. In the format, the desc should contain the content.\n";
								}
							}
						}elsif($_ =~ /^\s*?align\s*=\s*(.*?)\s*?$/){
							my $content_align = $1;
							#remove the space
							$content_align =~ s/\s//g;
							
							if(!($content_align eq "left" || $content_align eq "right" || $content_align eq "centre" || $content_align eq "auto")){
								$success = 0;
								print "Format Error: Line $error_line. In format, the align should be left, right, centre or auto.\n";
							}
						}
					}
					#the field n the type r require.
					if(!$flag_field){
						$success = 0;
						print "Format Error: Line $error_line. The 'format' should contain the field.\n";
					}
					if(!$flag_type){
						$success = 0;
						print "Format Error: Line $error_line. The 'format' should contain the type.\n";
					}		
				}else{
					$success = 0;
					print "Format Error: Line $error_line. The 'format' is incorrect.\n";
				}
			}
		}elsif($_ =~ /^footnote\s*=\s*(.*?)$/){
			if(!($1 =~ /^(?!=)"(.*?)"\s*?$/)){
				$success = 0;
				print "Format Error: Line $error_line.The footnote format is incorrect.\n";
			}else{
				my $content_footnote = $1;
				$content_footnote =~ s/\s//g;
				if(!($content_footnote)){
					$success = 0;
					print "Format Error: Line $error_line.The footnote should contain the content.\n";
				}
			}
		}elsif($_ =~ /^view\s*?=\s*?(.*?)\s*?$/){
			my $content_view = $1;
			my $reg1 = qr/^-?\d+(\.\d+)?$/;
			my $reg2 = qr/^-?0(\d+)?$/;
			#remove the space
			$content_view =~ s/\s//g;
			if($content_view eq 0){
				$flag_view = 1;
			}
			if(!(($content_view =~ $reg1 && $content_view !~ $reg2 )||($content_view eq 0))){
				$success = 0;
				print "Format Error: Line $error_line. The view should be a number.\n";
			}
		}
	}

	if($flag_exist){
		open TABLE, $table_path or die $!;
		my $num = 0;
		my $table_head = <TABLE>;
		$table_head =~ s/\s+$//;
		my @td = (split /\t/, $table_head);
		foreach(@td){
			$num++;
		}

		if(!($num eq $num_format) && !$flag_view){
			$success = 0;
			print "Format Error: Line $temp_line. The number of columns($num) in the table and the number of formats($num_format) in the \@table are not the same.\n";

		}		
		close TABLE;
	}
	#the title, file n format r require.
	if(!$flag_title){
		$success = 0;
		print "Format Error: Line $temp_line. The the \@table should contain the title.\n";
	}
	if(!$flag_file){
		$success = 0;
		print "Format Error: Line $temp_line. The the \@table should contain the table path.\n";
	}
	if(!($flag_format) && !$flag_view){
		$success = 0;
		print "Format Error: Line $temp_line. The the \@table should contain the 'format'.\n";
	}
} 

sub figure_process(){
	my $flag_file = 0;
	my $flag_title = 0;
	my $flag_desc = 0;
	my @content = @_;
	my $num_file = 0;
	my $temp_line = $error_line;
	if(!$flag_TITLE){
                $success = 0;
                print "Format Error: Line $error_line. The \@figure should belong to a title\n";
        }
	$error_line = $error_line - 1;
	foreach(@content){
		$error_line++;
		if($_ =~ /^number\s*=\s*(.*?)$/){
			if(!($1 =~ /^(?!=)(.*?)\s*?$/)){
				$success = 0;
				print "Foramt Error: Line $error_line. The number format is incorrect.\n";				
			}else{
				my $temp = $1;
        	                #remove the space
	                        $temp =~ s/\s//g;
				push @number_figure, [$now_title, $temp];
			}
		}elsif($_ =~ /^title\s*=\s*(.*?)$/){
			$flag_title = 1;
			if(!($1 =~ /^(?!=)\s*"(.*?)"\s*$/)){
				$success = 0;
				print "Format Error: Line $error_line. The title format is incorrect.\n";
			}else{
				my $content_title = $1;
				if(!$content_title){
					$success = 0;
					print "Format Error: Line $error_line. The title should contain the content.\n";
				}
			}
		}elsif($_ =~ /^file\s*=\s*(.*?)$/){
			$flag_file = 1;
			$num_file++;
			if(!($1 =~ /^(?!=)<(.*?)>\s*?$/)){
				$success = 0;
				print "Format Error: Line $error_line. The file format is incorrect.\n";
			}else{	
				my @temp;
				my $flag_url = 0;
				my $content_file = $1;			
				if($content_file =~ /;/){
					@temp = (split /;/, $content_file);
				}else{		
					push @temp, $content_file;					
				}

				foreach(@temp){	
					if(!$_){
						next;
					}
					if($_ =~ /^\s*?url\s*=\s*(.*?)$/){
						$flag_url = 1;
						my $path = $1;
						$path =~ s/\s//g;
						if(!$path){
							$success = 0;
							print "Format Error: Line $error_line. The url should contain the content\n";
						}
						
						if($data_dir){
							if(!(-e "$data_dir/$path")){
								$success = 0;
								print "File Error: Line $error_line. The figure path does not exist.\n";
								print "Path: $data_dir/$path\n";
							}
						}
					}elsif($_ =~ /\s*?label\s*?=(.*?)\s*?$/){
						if(!($1 =~ /^(?!=)\s*"(.*?)"\s*?$/)){
							$success = 0;
							print "Format Error: Line $error_line. In the file , the label format is incorrect.\n";
						}else{
							my $content_label = $1;
							if(!$content_label){
								$success = 0;
								print "Format Error: Line $error_line. In the file, the label should contain the content\n";
							}
						}
					}
				}
				if(!$flag_url){
					$success = 0;
					print "Format Error: Line $error_line. The file should contain the url.\n";
					
				}
			}
		}elsif($_ =~ /^desc\s*=\s*(.*?)\s*$/){
			$flag_desc = 1;
			my $figDesc = $1;
			while ( $figDesc =~ /\\reference\s*?{(.*?)}/g){
                        	my $temp = $1;
                        	#remove the space
                        	$temp =~ s/\s//g;
                        	push @number_reference_paragraph, [ $nowArf, $error_line, $now_title, $temp];
                	}
			if(!($1 =~ /^(?!=)\s*"(.*?)"$/)){
				$success = 0;
				print "Format Error: Line $error_line. The desc format is incorrect.\n";
			}else{
				if(!$1){
					$success = 0;
					print "Format Error: Line $error_line. The desc should contain the content.\n";
				}
			}

		}elsif($_ =~ /^size\s*=\s*(.*?)$/){
			if(!($1 =~ /^(?!=)\s*<(.*?)>\s*$/)){
				$success = 0;
				print "Format Error: Line $error_line. The size format is incorrect.\n";
			}else{
				my $flag_size = 0;
				my @temp;
				my $size_content = $1;
				if($size_content =~ /;/){
					@temp = (split /;/, $size_content);
				}else{
					push @temp, $size_content;
				}
				
				foreach(@temp){
					if(!$_){
						next;
					}
					if($_ =~ /^\s*?width\s*=\s*(.*?)$/){
						$flag_size = 1;
						my $content_width = $1;
						#remove the space
						$content_width =~ s/\s//g;
						if(!($content_width =~ /^\d+$/)){
							$success = 0;
							print "Format Error: Line $error_line. In the size, the width should be a number.\n"; 
						}
					}elsif($_ =~ /^\s*?height\s*=\s*(.*?)$/){
						$flag_size = 1;
						my $content_height = $1;
						#remove the space
						$content_height =~ s/\s//g;
						if(!($content_height =~ /^\d+$/)){
							$success = 0;
							print "Format Error: Line $error_line. In the size, the height should be a number.\n";
						}
					}
				}
				if(!$flag_size){
					$success = 0;
					print "Format Error: Line $error_line. The size should contain the width or height.\n";
				}
			}
		}
	}
	
	#check the file exist
	if(!$flag_file){
		$success = 0;
		print "Format Error: Line $temp_line. The the \@figure should contain the file.\n";
	}
	if($flag_title xor $flag_desc){
		$success = 0;
		print "Format Error: Line $temp_line. In the \@figure, if there is a title, it must have a description.\n";
	}
}

sub reference_process(){
	my @content = @_;
	my $flag_text = 0;
	my $flag_url = 0;
	my $flag_insert = 0;
	my $IsUsed = 0;
	my $ref_num = "";
	my $ref_url = "";
	my $ref_text = "";
	my $temp_line = $error_line;
	$error_line = $error_line -1;
	foreach(@content){
		$error_line++;
		if($_ =~ /^number\s*=\s*(.*?)\s*$/){
                        if(!($1 =~ /^(?!=)(.*?)$/)){
				$success = 0;
                                print "Format Error: Line $error_line. The number format is incorrect.\n";
                        }else{
				$ref_num = $1;
        	                #remove the space
	                        $ref_num =~ s/\s//g;
                        }
		}elsif($_ =~ /^text\s*=\s*(.*?)\s*$/){
			$flag_text = 1;
			if(!($1 =~ /^(?!=)"(.*?)"$/)){
				$success = 0;
				print "Format Error: Line $error_line. The text format is incorrect.\n";
			}else{
				my $content_text = $1;
				$ref_text = $content_text;
				$content_text =~ s/\s//g;
				if(!$content_text){
					$success = 0;
					print "Format Error: Line $error_line. The text should contain the content.\n";
				}
			}
		}elsif($_ =~ /^url\s*=\s*(.*?)\s*$/){
			$flag_url = 1;
			if(!($1 =~ /^(?!=)(.*?)$/)){
				$success = 0;
				print "Format Error: Line $error_line. The url format is incorrect.\n";
			}else{
				my $content_url = $1;
				$content_url =~ s/\s//g;
				$ref_url = $content_url;
				if(!$content_url){
					$success = 0;
					print "Format Error: Line $error_line. The url should contain the content.\n";
				}
			}
		}
	}
	if(!($flag_text)){
		$success = 0;
		print "Format Error: Line $temp_line. The \@reference should contain the text.\n";
	}
	if(!($flag_url)){
		$success = 0;
		print "Format Error: Line $temp_line. The \@reference should contain the url.\n";
	}
	
	
	if ( $flag_text && $flag_url ) {

		for my $i ( 0 .. $#number_reference ) {
                	if ( $ref_url eq $number_reference[$i][5] ) {
                        	# exist in the \@number_reference, get the reference number
                        	$flag_insert = 1;
                	}
                }
	}
	
	if ( !$flag_insert ) {
		push @number_reference, [ $nowArf, $now_title, $ref_num, $IsUsed, $temp_line, $ref_url, $ref_text ];
	} else {
		$flag_insert = 0;
	}
}

sub glossary_process(){
	my @content = @_;
	my $flag_keyword = 0;
	my $flag_desc = 0;
	my $num_keyword = 0;
	my $num_desc = 0;
	my $temp_line = $error_line;
	$error_line = $error_line - 1;
	foreach(@content){
		$error_line++;
		if($_ =~ /^keyword\s*=\s*(.*?)\s*$/){
			$flag_keyword = 1;
			$num_keyword++;
			if(!($1 =~ /^(?!=)"(.*?)"$/)){
				$success = 0;
				print "Format Error: Line $error_line. The keyword format is incorrect.\n";
			}else{
				if(!$1){
					$success = 0;
					print "Format Error: Line $error_line. The keyword should contain the content.\n";
				}
			}
		}elsif($_ =~ /^desc\s*=\s*(.*?)\s*$/){
			$flag_desc = 1;
			$num_desc++;
			if(!($1 =~ /^(?!=)"(.*?)"$/)){
				$success = 0;
				print "Format Error: Line $error_line. The desc format is incorrect.\n";
			}else{
				if(!($1)){
					$success = 0;
					print "Format Error: Line $error_line. The desc should contain the content.\n";
				}
			}
		}	
	}
	if(!($flag_keyword)){
		$success = 0;
		print "Format Error: Line $temp_line. The \@glossary should contain the keyword.\n";
	}
	if(!($flag_desc)){
		$success = 0;
		print "Format Error: Line $temp_line. The \@glossary should contain the desc.\n";
	}

	if($num_keyword > 1){
		$success = 0;
		print "Format Error: Line $temp_line. The \@glossary should contain only one keyword.\n";
	}
	if($num_desc > 1){
		$success = 0;
		print "Format Error: Line $temp_line. The \@glossary should contain only one desc.\n";
	}
}

sub FAQ_process(){
	my @content = @_;
	my $temp_line = $error_line;
	$error_line = $error_line - 1;
	foreach(@content){
		$error_line++;
		if($_ =~ /^question\s*=\s*(.*?)\s*$/){
			if(!($1 =~ /^(?!=)"(.*?)"$/)){
				$success = 0;
				print "Format Error: Line $error_line. The question format is incorrect.\n";
			}else{
				if(!($1)){
					$success = 0;
					print "Format Error: Line $error_line. The question should contain the content\n";
				}
			}
		}elsif($_ =~ /^answer\s*=\s*(.*?)\s*$/){
			if(!($1 =~ /^(?!=)"(.*?)"$/)){
				$success = 0;
				print "Format Error: Line $error_line. The answer format is incorrect.\n";
			}else{
				if(!$1){
					$success = 0;
					print "Format Error: Line $error_line. The answer should contain the content.\n";
				}
			}
		}
	}
}

sub wrong_label_process(){
	my @content = @_;
	my $wrong_label = $content[0];
	$wrong_label =~ s/\s//g;
	$success = 0;
	print "Format Error: Line $error_line. Wrong label $wrong_label.\n";
}


##########	print program information	#########
sub usage{
	die "Description: This program is used to check the arf file
	Version:	1.0
	Date:		24/09/2015
	\@author:	dengshengyuan\@genomics.cn

	Usage:
	\tperl $0 [options]
	Options:
	\t-i<str>	the input arf file path or the arf folder.
	\t-d<str>	the data path.
	\t-help|?	print help information.
e.g:
\tperl $0 -i /ifs4/BC_PUB/biosoft/bin/example/Upload_report/arf/results.arf  -d /ifs4/BC_PUB/biosoft/bin/example/Upload_report
\tperl $0 -i /ifs4/BC_PUB/biosoft/bin/example/Upload_report/arf  -d /ifs4/BC_PUB/biosoft/bin/example/Upload_report
";
}

sub resetValue(){
	
	#global variable
	undef $format;
	undef $lan;
	undef $pos;
	$line = 0;
	$error_line = 0;
	$lastlabel = "";
	undef $nowlabel;
	$success = 1;
	$flag_MENU = 0;
	$flag_TITLE = 0;
	#mark the %, such as %result, %method ...
	undef $type_label;

	#mark the title
	undef $now_title;
	#save the title
	#save line, %, title_name
	undef @each_title;
	#FROM paragraph content
	#save the line,title, table_number
	undef @number_table_paragraph;
	#save the line, title, figure_number
	undef @number_figure_paragraph;
	#save the line, title, reference_number
	#each title, the number of table, figure, reference
	#
	undef @number_table;
	undef @number_figure;
	#flag
	#array

	undef @content;
}

sub referenceCheck(){	
	#check the reference number n the \reference{number}in paragrap
        for my $i (0 .. $#number_reference_paragraph){
                my $flag_number = 0;
                for my $j (0 .. $#number_reference){
                        if ( ( $number_reference_paragraph[$i][3] eq $number_reference[$j][2] ) && ( $number_reference_paragraph[$i][2] eq $number_reference[$j][1] ) ) {
                                $flag_number = 1;
                                $number_reference[$j][3] = "1";
                        }
                }
		
		for my $j ( 0 .. $#number_reference ) {
                        if ( $number_reference_paragraph[$i][3] eq $number_reference[$j][2] ) {
                                $flag_number = 1;
                                $number_reference[$j][3] = "1";
                        }
                }

                if(!$flag_number){
                        $success = 0;
			$flag_ref_check = 1;
                        print "Format Error: arf: $number_reference_paragraph[$i][0]. Line $number_reference_paragraph[$i][1]. In \@paragraph, the \\reference{$number_reference_paragraph[$i][3]} does not exist.\n";
                }
        }
	
	#print the reference which not use
        for my $i (0 .. $#number_reference){
                if ( $number_reference[$i][3] eq "0" ) {
                        $success = 0;
			$flag_ref_check = 1;
                        print "Warning: arf: $number_reference[$i][0]. Line $number_reference[$i][4]. The reference does not use.\n";
			print "\@reference\n";
			print "url = $number_reference[$i][5]\n";
			print "text = $number_reference[$i][6]\n\n";
                }
        }
	
}

##########	subroutine end		##########

