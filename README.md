# MRT-ModSeq
RNA modification detection with Marathon RT
Computational package for inferring positions of RNA modifications in target transcripts using sequencing data from a MarathonRT ModSeq experiment. The current method employs machine learning models trained on human 18S and 28S rRNAs for classification of 2’-O-methylations (Nm) or pseudouridines (ψ), in addition to flag positions consistent with the presence of some base modifications (m1A, m3U/ m1acp3Y, m7G).

## Amplified prediction script
This script takes in three text files produced by shapemapper (using the "--output-counted-mutations" flag) after processing sequencing data from a ModSeq experiment. The three files are: profile file (containing mutation rates from both Mg and Mn experimental samples), 'untreated' file (mutation counts from the Mg sample data), and 'modified' file (mutation counts from the Mn sample data). 
The outputs of this script are four arff files - one for each nucleotide type - primed for input into Weka.

#### INPUT: write the file path for the indicated input file at the indicated lines if using the .rmd script
profile file: line 24

Mg2+ sample mutation counts file: line 25

Mn2+ sample mutation counts file: line 26

#### OUTPUT: write the file path at the indicated lines if using the .rmd script
uridines output: lines 225, 227, 233

cytidines output: lines 255, 257, 263

guanosines output: lines 285, 287, 293

adenosines output: lines 315, 217, 323

## Model files
These files are trained models on 18S and 28S rRNA data for detection of Nm and pseudouridines. They are used in Weka for prediction. After prediction, Weka will output four arff files with the classifications. These are the inputs for the next step.

## Output reordering script
This script takes in the four outputted arff files from Weka, in addition to the original profile file from shapemapper and outputs a single csv file with position, nucleotide type, and modification status. Nm/ψ predictions are done using ML models, while base modification predictions (m1A, m3U/ m1acp3Y, m7G) are based on pre-determined mutation rate cutoffs.

#### INPUT: write the file path for the indicated input file at the indicated lines if using the .rmd script
adenosines input: line 23

cytidines input: line 24

guanosines input: line 25

uridines input: line 26

#### OUTPUT: write the file path at the indicated lines if using the .rmd script
final classification output CSV file: line 57

# EXAMPLE 
The following are instructions on how to use the current MRT-ModSeq pipeline with sequencing data from a typical experiment, using both Mg and Mn cDNA samples. Sample files for 5.8S rRNA (libraries built from total RNA from Huh7.5 cells) are provided as an example.
1) use raw sequencing reads from MRT-ModSeq sequencing experiment: R1/R2 fastq files from both ‘modified’ (Mn2+) and 'untreated' (Mg2+) experiments. Run the shapemapper program (Smola et al. 2015) using the following command:

```
shapemapper --nproc 8 --output-counted-mutations --name [job name] --target [alignment reference file (.fasta extension)] --out [output directory name] --modified --R1 [Mn2+ R1 file (.fasta or .fasta.gz)] --R2 [Mn2+ R2 file (.fasta or .fasta.gz)] --untreated --R1 [Mg2+ R1 file (.fasta or .fasta.gz)] --R2 [Mg2+ R2 file (.fasta or .fasta.gz)] --overwrite
```
2) the output of the above shapemapper run is three files as follows: 1) profile, 2) 'untreated' file (Mg2+) and 3) 'modified' file (Mn2+). These constitute the inputs for the amplified prediction script.
If using the .R script on command line, download and navigate to pylelab/MRTModSeq directory and run the following (example shown with sample data):
mkdir sample_outputs
cd sample_outputs
Rscript ../Amplified_Prediction_script.R "../sample_5.8S_rRNA_data_input_and_output/amplified_predictions_script_INPUTS/Amplified-TRNA-Huh-5_8S_5_8_profile.txt" "../sample_5.8S_rRNA_data_input_and_output/amplified_predictions_script_INPUTS/Amplified-TRNA-Huh-5_8S_Untreated_5_8_mutation_counts.txt" "../sample_5.8S_rRNA_data_input_and_output/amplified_predictions_script_INPUTS/Amplified-TRNA-Huh-5_8S_Modified_5_8_mutation_counts.txt"
3) the output of the amplified prediction script is four arff files that, along with the model files, constitute the inputs for the Weka step.

### Using the WEKA GUI
4) Open the Weka GUI and the Explorer Application.
5) In the Preprocess tab, input the prediction file for the nucleotide you are analyzing. This will unlock the Classify tab.
6) Change the Test Options to "Supplied Test Set" and choose the prediction arff file for the nucleotide you are analyzing.
7) In the Classify tab, right click the left sidebar and choose load model.
8) Right click the selection on the left sidebar and click "Re-evaluate model on current test set."
9) Write click results tab on the left sidebar and click "Visualize classifier errors."
10) Save the file in the resultant window. This saves as an arff file.
11) Repeat the above steps for each nucleotide type. This will yield four output arff files that constitute the input for the 'output reordering' script. If using command line, run the following (example with sample data):
mkdir ordered_predictions
cd ordered_predictions
Rscript ../output_reordering.R "../sample_5.8S_rRNA_data_input_and_output/output_reordering_script_INPUTS/prac_5_8_adenine_amppred.arff" "../sample_5.8S_rRNA_data_input_and_output/output_reordering_script_INPUTS/prac_5_8_cytosine_amppred_acc.arff" "../sample_5.8S_rRNA_data_input_and_output/output_reordering_script_INPUTS/prac_5_8_guanine_amppred_acc.arff" "../sample_5.8S_rRNA_data_input_and_output/output_reordering_script_INPUTS/prac_5_8_uracil_amppred_acc.arff" "../sample_5.8S_rRNA_data_input_and_output/amplified_predictions_script_INPUTS/Amplified-TRNA-Huh-5_8S_5_8_profile.txt"
12) the output for the ‘output reordering’ script is a single csv file with nucleotide positions and the predicted modification status.
