# MRT-ModSeq
RNA modification detection with Marathon RT

From sequencing data derived from our divalent cation strategy, we use this computational pipeline to profile chemical modifications on the RNA transcript of interest.

## Amplified prediction script
This script takes in three text files produced by Shapemapper2 (using the "--counted" flag) after processing sequencing data from a ModSeq experiment. The three files are: profile file (containing mutation rates from both Mg and Mn experimental samples), 'untreated' file (mutation counts from the Mg sample data), and 'modified' file (mutation counts from the Mn sample data). 
The outputs of this script are four arff files - one for each nucleotide type - primed for input into Weka.

#### INPUT: write the file path for the indicated input file at the indicated lines
profile: line 24

Mg2+ mutation file: line 25

Mn2+ mutation file: line 26

#### OUTPUT: write the file path at the indicated lines
uridines output: lines 225, 227, 233

cytidines output: lines 255, 257, 263

guanosines output: lines 285, 287, 293

adenosines output: lines 315, 217, 323

## Model files
These files are trained models on 18S and 28S rRNA data. They are used in Weka for prediction. After prediction, Weka will output four arff files with the classifications. These are the inputs for the next step.

## Output reordering script
This script takes in the four outputted scripts from Weka and outputs a single csv file with position, nucleotide type, and modification classification.

#### INPUT: write the file path for the indicated input file at the indicated lines
adenosines input: line 23

cytidines input: line 24

guanosines input: line 25

uridines input: line 26

#### OUTPUT: write the file path at the indicated lines
final classification output CSV file: line 57

# EXAMPLE 
1) use raw reads from divalent cation sequencing experiment: R1/R2 files from both modified (Mn2+) and 'untreated' (Mg2+) experiments.

```
shapemapper --nproc 8 --output-counted-mutations --name [job name] --target [alignment reference file (.fasta extension)] --out [output directory name] --modified --R1 [Mn2+ R1 file (.fasta or .fasta.gz extension)] --R2 [Mn2+ R2 file (.fasta or .fasta.gz extension)] --untreated --R1 [Mg2+ R1 file (.fasta or .fasta.gz extension)] --R2 [Mg2+ R2 file (.fasta or .fasta.gz extension)] --overwrite
```

2) the output of the above shapemapper run is three files as follows: 1) profile, 2) 'untreated' file (Mg2+) and 3) 'modified' file (Mn2+). These constitute the inputs for our amplified prediction script

3) the output of the amplified prediction script is four arff files that, along with the model files included in this directory, constitute the inputs for Weka.

### Using the WEKA GUI
4) Open the Weka GUI and the Explorer Application
5) In the Preprocess tab, input the prediction file for the nucleotide you are analyzing. This will unlock the Classify tab.
6) Change the Test Options to "Supplied Test Set" and choose the prediction arff file for the nucleotide you are analyzing.
7) In the Classify tab, right click the left sidebar and choose load model.
8) Right click the selection on the left sidebar and click "Re-evaluate model on current test set"
9) Write click results tab on the left sidebar and click "Visualize classifier errors"
10) Save the file in the resultant window. This saves as an arff file.
11) Repeat the above steps for each nucleotide type.

This will yield four output arff files that constitute the input for the 'output reordering' script.

12) the output for the output reordering script is a single csv file with ordered nucleotides and classfications.
