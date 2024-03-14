#######################################################
#######################################################
reference=$1
output_dir=$2
if_hg38=$3
h1=$4
h2=$5
scriptDir=$6
echo "reference: $reference"
echo "output_dir: $output_dir"
echo "if_hg38: $if_hg38"
echo "h1: $h1"
echo "h2: $h2"
echo "scriptDir: $scriptDir"


#######################################################


#1. Align assembly to reference

#use lra (https://github.com/ChaissonLab/LRA) to align asm to ref
echo "indexing reference"
lra index -CONTIG $reference


if [ ! -f assem1_sort.bam.bai ]; then
    echo "aligning assembly h1 to reference"
    lra align -CONTIG $reference $h1 -t 16 -p s | samtools sort -o assem1_sort.bam
    samtools index assem1_sort.bam
fi

# if the index exists, then skip this step
if [ ! -f assem2_sort.bam.bai ]; then
    echo "aligning assembly h2 to reference"
    lra align -CONTIG $reference $h2 -t 16 -p s | samtools sort -o assem2_sort.bam
    samtools index assem2_sort.bam
fi


#######################################################
#######################################################
#2. Trim overlapping contigs

#trim overlapping contigs
python "$scriptDir"/trim_overlapping_contigs.py assem1_sort.bam $output_dir $if_hg38
python "$scriptDir"/trim_overlapping_contigs.py assem2_sort.bam $output_dir $if_hg38

#sort trimmed bam file
samtools sort $output_dir/assem1_sort_nool.bam -o $output_dir/assem1_nool_sort.bam
samtools sort $output_dir/assem2_sort_nool.bam -o $output_dir/assem2_nool_sort.bam

#index sorted trimmed file
samtools index $output_dir/assem1_nool_sort.bam
samtools index $output_dir/assem2_nool_sort.bam

#######################################################
#######################################################
#3. Liftover

#convert to sam file
samtools view -h $output_dir/assem1_nool_sort.bam | samtools sort -O sam -o $output_dir/assem1_nool_sort.sam
samtools view -h $output_dir/assem2_nool_sort.bam | samtools sort -O sam -o $output_dir/assem2_nool_sort.sam

#liftover using samLiftover (https://github.com/mchaisso/mcutils): ref to asm lo
python "$scriptDir"/lo_assem_to_ref.py $output_dir $output_dir/assem1_nool_sort.bam $output_dir/assem2_nool_sort.bam

samLiftover $output_dir/assem1_nool_sort.sam $output_dir/lo_pos_assem1.bed $output_dir/lo_pos_assem1_result.bed --dir 1
samLiftover $output_dir/assem2_nool_sort.sam $output_dir/lo_pos_assem2.bed $output_dir/lo_pos_assem2_result.bed --dir 1

#liftover using samLiftover (https://github.com/mchaisso/mcutils): asm to ref lo
python "$scriptDir"/lo_assem_to_ref_0.py $output_dir $output_dir/assem1_nool_sort.bam $output_dir/assem2_nool_sort.bam

samLiftover $output_dir/assem1_nool_sort.sam $output_dir/lo_pos_assem1_0.bed $output_dir/lo_pos_assem1_0_result.bed --dir 0
samLiftover $output_dir/assem2_nool_sort.sam $output_dir/lo_pos_assem2_0.bed $output_dir/lo_pos_assem2_0_result.bed --dir 0

#######################################################
#######################################################
#4. Compress liftover files

python "$scriptDir"/compress_liftover.py $output_dir lo_pos_assem1_result.bed lo_pos_assem1_result_compressed.bed
python "$scriptDir"/compress_liftover.py $output_dir lo_pos_assem2_result.bed lo_pos_assem2_result_compressed.bed
python "$scriptDir"/compress_liftover.py $output_dir lo_pos_assem1_0_result.bed lo_pos_assem1_0_result_compressed.bed
python "$scriptDir"/compress_liftover.py $output_dir lo_pos_assem2_0_result.bed lo_pos_assem2_0_result_compressed.bed

#######################################################
#######################################################
#5. Get non-covered regions

python "$scriptDir"/get_conf_int.py $output_dir $output_dir/assem1_nool_sort.bam $output_dir/assem2_nool_sort.bam $if_hg38
