library(Rsubread)
library(limma)
library(edgeR)
library(tools)
options(digits=2)

sampleID = commandArgs()[7]
referenceGenomeFastaFilePath = commandArgs()[8]
inFilePath1 = commandArgs()[9]
inFilePath2 = commandArgs()[10] # NULL for single-end analyses or when a BAM file has been specified
outBamFilePath = commandArgs()[11]
outDirPath = commandArgs()[12]

memory = 8000
nthreads = 12

input_format = "gzFASTQ"
if (file_ext(inFilePath1) == "bam")
  input_format = "BAM"
if (file_ext(inFilePath1) %in% c("fastq", "fq"))
  input_format = "FASTQ"

outIndelFilePath = paste(outDirPath, "/InDel/", sampleID, sep="")
outJunctionFilePath = paste(outDirPath, "/Junction/", sampleID, sep="")
outFusionFilePath = paste(outDirPath, "/Fusion/", sampleID, sep="")

for (filePath in c(outBamFilePath, outIndelFilePath, outJunctionFilePath, outFusionFilePath))
  dir.create(dirname(filePath), showWarnings=FALSE, recursive=TRUE)

if (file.exists(outFusionFilePath))
{
  print(paste(outFusionFilePath, " already exists, so this sample will not be processed again.", sep=""))
} else {
  referenceGenomeIndexFilePrefix = paste(referenceGenomeFastaFilePath, "__reference_index", sep="")

  if (!file.exists(paste(referenceGenomeIndexFilePrefix, ".reads", sep="")))
    buildindex(basename=referenceGenomeIndexFilePrefix, reference=referenceGenomeFastaFilePath, memory=memory)

  if (inFilePath2 == "NULL")
    inFilePath2 = NULL

  subjunc(index=referenceGenomeIndexFilePrefix, readfile1=inFilePath1, readfile2=inFilePath2, nthreads=nthreads, input_format=input_format, reportAllJunctions=TRUE, output_file=outBamFilePath)

  file.rename(paste(outBamFilePath, ".indel", sep=""), outIndelFilePath)
  file.rename(paste(outBamFilePath, ".junction.bed", sep=""), outJunctionFilePath)
  file.rename(paste(outBamFilePath, ".fusion.txt", sep=""), outFusionFilePath)
}

#unlink(outBamFilePath)
