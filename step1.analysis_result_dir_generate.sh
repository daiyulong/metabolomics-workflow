#!/bin/bash
result_dir=$1
raw_data_neg=$2
raw_data_pos=$3
dir="/ifs4/BC_PT/PROJECT/Metabo/Institute/2017"
if [ $# -ne 3 ]
then
echo "usage: sh analysis_result_dir_generate <result_dir_name> <Raw_data_neg> <Raw_data_pos> "
else
#================================mkdir and cp necessary file==========================
if [ -d $dir/$result_dir ]
then
rm -r $dir/$result_dir
mkdir $dir/$result_dir
else
mkdir $dir/$result_dir
fi
#=====================创建主目录=======================================
cd $dir/$result_dir
mkdir  CSV Audit Infor Script Quality_control QI_Archive Submit Personalized_analysis
#=====================创建子目录=====================================
cd $dir/$result_dir/Quality_control
mkdir neg pos
cd $dir/$result_dir/Script
cp /ifs5/ST_METABO/USER/daiyulong/Code/mk_dir_generate/last_script/*.pl $dir/$result_dir/Script
cd $dir/$result_dir/Personalized_analysis
mkdir Extra_PCA Extra_Heatmap ROC_analysis Mz_correlation_analysis
mkdir $dir/$result_dir/Personalized_analysis/Extra_PCA/pos
mkdir $dir/$result_dir/Personalized_analysis/Extra_PCA/neg
mkdir $dir/$result_dir/Personalized_analysis/Extra_Heatmap/pos
mkdir $dir/$result_dir/Personalized_analysis/Extra_Heatmap/neg
cd $dir/$result_dir/QI_Archive
mkdir QI_result_neg
mkdir QI_result_pos
ln -s $raw_data_neg
ln -s $raw_data_pos

echo "Neg raw data in linux dir:">$dir/$result_dir/QI_Archive/data_infor.txt
echo "$raw_data_neg">>$dir/$result_dir/QI_Archive/data_infor.txt
echo "Pos raw data in linux dir:">>$dir/$result_dir/QI_Archive/data_infor.txt
echo "$raw_data_pos">>$dir/$result_dir/QI_Archive/data_infor.txt
echo "Neg raw data in windows dir: ">>$dir/$result_dir/QI_Archive/data_infor.txt
echo "$raw_data_neg"|sed 's$/opt/lustresz/PAP3/$\\\\172.30.30.91\\pap3\\$'|sed 's$/nas/PAP_2014A/A/$\\\\172.30.30.90\\pap3-1\\A\\$'|sed 's$/$\\$g'>>$dir/$result_dir/QI_Archive/data_infor.txt
echo "Pos raw data in windows dir: ">>$dir/$result_dir/QI_Archive/data_infor.txt
echo "$raw_data_pos"|sed 's$/opt/lustresz/PAP3/$\\\\172.30.30.91\\pap3\\$'|sed 's$/nas/PAP_2014A/A/$\\\\172.30.30.90\\pap3-1\\A\\$'|sed 's$/$\\$g'>>$dir/$result_dir/QI_Archive/data_infor.txt
echo "Windows temp:172.30.30.90/A/Bioinformatics/temp_metabolomics">>$dir/$result_dir/QI_Archive/data_infor.txt
echo "linux temp:/nas/PAP_2014A/A/Bioinformatics/temp_metabolomics">>$dir/$result_dir/QI_Archive/data_infor.txt
#========================spl file================================
mkdir spl_neg spl_pos
cp -r /ifs5/ST_METABO/USER/daiyulong/Code/mk_dir_generate/SystemQC.pro $dir/$result_dir/QI_Archive/spl_neg
cp -r /ifs5/ST_METABO/USER/daiyulong/Code/mk_dir_generate/SystemQC.pro $dir/$result_dir/QI_Archive/spl_pos
cd $raw_data_neg
cd ../../../spl
cp *NEG.SPL $dir/$result_dir/QI_Archive/spl_neg/
cp *POS.SPL $dir/$result_dir/QI_Archive/spl_pos/

#=============================generate conf file===============================
echo "#=====================================" >$dir/$result_dir/Audit/Project_Information.conf
echo "#=========Project analysis Dir=============">>$dir/$result_dir/Audit/Project_Information.conf
echo "Main_dir = $dir/$result_dir">>$dir/$result_dir/Audit/Project_Information.conf
echo "#==========Pid and Sid and E-mail==========">>$dir/$result_dir/Audit/Project_Information.conf
echo "Pid =">>$dir/$result_dir/Audit/Project_Information.conf
echo "Sid =">>$dir/$result_dir/Audit/Project_Information.conf
echo "Guest_Email = daiyulong@genomics.cn">>$dir/$result_dir/Audit/Project_Information.conf
echo "#======== sample and expriment ============">>$dir/$result_dir/Audit/Project_Information.conf
echo "Sample = tissue   ### serum , tissue or urine">>$dir/$result_dir/Audit/Project_Information.conf
echo "ExperimentType = globe    ### lipids or globe">>$dir/$result_dir/Audit/Project_Information.conf
echo "#====identification database and species===">>$dir/$result_dir/Audit/Project_Information.conf
echo "Database = KEGG       ### KEGG ,LipidMaps or HMDB">>$dir/$result_dir/Audit/Project_Information.conf
echo "Species = mmu">>$dir/$result_dir/Audit/Project_Information.conf
echo "#============= compare group ==============">>$dir/$result_dir/Audit/Project_Information.conf
echo "Group =		#B:A;D:C;B:D;A:C;">>$dir/$result_dir/Audit/Project_Information.conf
echo "Extra_pca_group =			#B_A_D;C_B_D;">>$dir/$result_dir/Audit/Project_Information.conf
echo "Extra_heatmap_group =			#B_A_D C_B_D">>$dir/$result_dir/Audit/Project_Information.conf
echo "#=============== Raw data =================">>$dir/$result_dir/Audit/Project_Information.conf
echo "Rawdata_pos = $raw_data_pos">>$dir/$result_dir/Audit/Project_Information.conf
echo "Rawdata_neg = $raw_data_neg">>$dir/$result_dir/Audit/Project_Information.conf
echo "==========================end==============">>$dir/$result_dir/Audit/Project_Information.conf
echo "#可将标准分析比较组复制后存储为aa.txt;PCA分析存储为bb.txt；热图分析存储为cc.txt再运行group_convert.sh即可获得能直接填写的信息">>$dir/$result_dir/Audit/Project_Information.conf
echo "echo \"=======标准分析比较组=============\"">$dir/$result_dir/Audit/group_convert.sh
echo "cat aa.txt |tr \"\\n\" \";\"|sed 's/\\t/:/g'|sed 's/::/:/g'|sed 's/:;/;/g' #标准分析分组">>$dir/$result_dir/Audit/group_convert.sh
echo "echo \"\"" >>$dir/$result_dir/Audit/group_convert.sh
echo "echo \"=======PCA分析比较组=============\"">>$dir/$result_dir/Audit/group_convert.sh
echo "cat bb.txt |tr \"\\n\" \";\"|sed 's/\s//g'|sed 's/+/_/g' #PCA分组">>$dir/$result_dir/Audit/group_convert.sh
echo "echo \"\"" >>$dir/$result_dir/Audit/group_convert.sh
echo "echo \"=======热图分析比较组=============\"">>$dir/$result_dir/Audit/group_convert.sh
echo "cat cc.txt |sed 's/\s//g'|tr \"\\n\" \" \"|sed 's/+/_/g' #聚类分组">>$dir/$result_dir/Audit/group_convert.sh
echo "echo \"\"" >>$dir/$result_dir/Audit/group_convert.sh
#echo "">>$dir/$result_dir/Audit/Project_Information.conf
#==============================generate sh file=================================
echo "perl /ifs5/ST_METABO/USER/daiyulong/Code/mk_dir_generate/step2.script_and_support_file_generate.pl -conf $dir/$result_dir/Audit/Project_Information.conf" >$dir/$result_dir/Audit/script_and_support_file_generate.sh
#===============================sample list generate============================
cd $raw_data_neg;
cd ..
ls -tF|cut -d '.' -f 1|awk 'BEGIN{OFS=","}{print $1,"1","NA",NR}'|sed '1i sample,batch,class,order'>$dir/$result_dir/QI_Archive/sample_list_neg.csv
cd $raw_data_pos
cd ..
ls -tF|cut -d '.' -f 1|awk 'BEGIN{OFS=","}{print $1,"1","NA",NR}'|sed '1i sample,batch,class,order'>$dir/$result_dir/QI_Archive/sample_list_pos.csv
#=======================sample list generate.sh==============================
echo "/ifs5/ST_METABO/PMO/2015_project/pipeline/software/3.3.3/bin/Rscript /ifs5/ST_METABO/USER/daiyulong/Code/mk_dir_generate/sample_list_generate.R $dir/$result_dir/CSV $dir/$result_dir/QI_Archive">$dir/$result_dir/QI_Archive/sample_list_generate.sh
echo "sed -i 's/\"//g' $dir/$result_dir/CSV/s_neg.list">>$dir/$result_dir/QI_Archive/sample_list_generate.sh
echo "sed -i 's/\"//g' $dir/$result_dir/CSV/s_pos.list">>$dir/$result_dir/QI_Archive/sample_list_generate.sh
#=========================change the rights================================================
cd $dir/$result_dir
chmod -R 750 CSV Audit Infor Script Quality_control Personalized_analysis QI_Archive
chmod 755 Submit
echo "***************************************分析目录**************************************"
echo "$dir/$result_dir"
echo ""
#=============================read me=====================================================

fi
#=========================echo tips========================================================

echo "*****************************************提示****************************************"
echo "！！！重要！！！自动生成脚本产生的R命令，conf，sh文件需要检查后再运行！！！重要！！！"
echo "1.是否需要做plsda分析？样本数量是否足够？"
echo "2.需要做的ABC三组热图是否设置了AB，BC，AC比较组中的两组？"
echo "3.老师是否指定了数据库？没有明确说明的一定要邮件问清楚。"
echo "4.物种拉丁名有没有给出,能否找到物种缩写？没有明确的一定要邮件明确。"
echo "5.客户邮箱是多少？"
echo "6.物种是细菌的时候提取任务单有没有给提取方法？没有可以去提取任务单看看，再没有可参考E-LqIPD001发邮件给生产确认。"
echo ""
echo "*************************************运行步骤*****************************************"
echo "1.检查任务单信息是否齐全，找到原始数据，运行本步骤生成目录及拷贝分析脚本"
echo "2.完善$dir/$result_dir/$Audit/Project_Information.conf文件"
echo "3.导入原始数据进QI，制作samplelist给QI用及list格式"
echo "4.将生成的measurement及Identification文件导入CSV文件夹，并完善Audit中的sh，R，conf文件生成脚本"
echo "5.检查生成的R，conf及sh文件正确后运行"
