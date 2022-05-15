# MRTModSeq
Modification profiling with Marathon RT

## Amplified prediction script
This script takes in three text files - the output of the Shapemapper experiments with --counted flag: profile file, "Mg2+, 'untreated' file", and "Mn2+, 'modified' file".
The output of this script is four arff files - one for each nucleotide type - primed for input into Weka.

#### INPUT: write the file path for the indicated input file at the indicated lines
profile: line 24

Mg2+ mutation file: line 25

Mn2+ mutation file: line 26

#### OUTPUT: write the file path at the indicated lines
uracils output: lines 225, 227, 233

cytosines output: lines 255, 257, 263

guanines output: lines 285, 287, 293

adenosines output: lines 315, 217, 323

## Model files
These files are trained models on 18S and 28S rRNA data. They are used in Weka for prediction. After prediction, Weka will output four arff files with the classifications. These are the inputs for the next step.

## Output reordering script
This script takes in the four outputted scripts from Weka and outputs a single csv file with position, nucleotide type, and modification classification.

#### INPUT: write the file path for the indicated input file at the indicated lines

#### OUTPUT: write the file path at the indicated lines
