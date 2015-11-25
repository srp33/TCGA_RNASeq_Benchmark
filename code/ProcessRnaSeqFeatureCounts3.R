library(Rsubread)
library(limma)
library(edgeR)
library(tools)
options(digits=2)

sampleID = commandArgs()[7]
referenceGenomeFastaFilePath = commandArgs()[8]
inFilePath1 = commandArgs()[9]
inFilePath2 = commandArgs()[10] # NULL for single-end analyses or when a BAM file has been specified
gtfFilePath = commandArgs()[11]
gtfAttrType = commandArgs()[12]
outBamFilePath = commandArgs()[13]
outDirPath = commandArgs()[14]
orientation = commandArgs()[15]

memory = 8000
nthreads = 2

input_format = "gzFASTQ"
if (file_ext(inFilePath1) == "bam")
  input_format = "BAM"
if (file_ext(inFilePath1) %in% c("fastq", "fq"))
  input_format = "FASTQ"

if (is.na(orientation))
  orientation = "fr"

outCountsFilePath = paste(outDirPath, "/FeatureCounts/", sampleID, sep="")
outFpkmFilePath = paste(outDirPath, "/FPKM/", sampleID, sep="")
outTpmFilePath = paste(outDirPath, "/TPM/", sampleID, sep="")
outStatsFilePath = paste(outDirPath, "/Stats/", sampleID, sep="")

for (filePath in c(outBamFilePath, outCountsFilePath, outFpkmFilePath, outTpmFilePath, outStatsFilePath))
  dir.create(dirname(filePath), showWarnings=FALSE, recursive=TRUE)

if (file.exists(outTpmFilePath))
{
  print(paste(outTpmFilePath, " already exists, so this sample will not be processed again.", sep=""))
} else {
  referenceGenomeIndexFilePrefix = paste(referenceGenomeFastaFilePath, "__reference_index", sep="")

  if (!file.exists(paste(referenceGenomeIndexFilePrefix, ".reads", sep="")))
    buildindex(basename=referenceGenomeIndexFilePrefix, reference=referenceGenomeFastaFilePath, memory=memory)

  if (inFilePath2 == "NULL")
    inFilePath2 = NULL

  if (!file.exists(outBamFilePath))
    #align(index=referenceGenomeIndexFilePrefix, readfile1=inFilePath1, readfile2=inFilePath2, output_file=outBamFilePath, nthreads=nthreads, input_format=input_format, tieBreakHamming=TRUE, unique=TRUE, indels=5)
    align(index=referenceGenomeIndexFilePrefix, readfile1=inFilePath1, readfile2=inFilePath2, output_file=outBamFilePath, nthreads=nthreads, input_format=input_format, tieBreakHamming=TRUE, unique=TRUE, indels=5, PE_orientation=orientation)

  useMetaFeatures = TRUE
  if (gtfAttrType == "exon")
    useMetaFeatures = FALSE

  fCountsList = featureCounts(outBamFilePath, annot.ext=gtfFilePath, isGTFAnnotationFile=TRUE, useMetaFeatures=useMetaFeatures, GTF.attrType=gtfAttrType, nthreads=nthreads, isPairedEnd=!is.null(inFilePath2))
  dgeList = DGEList(counts=fCountsList$counts, genes=fCountsList$annotation)
  fpkm = rpkm(dgeList, dgeList$genes$Length)
  tpm = exp(log(fpkm) - log(sum(fpkm)) + log(1e6))

  write.table(fCountsList$stat, outStatsFilePath, sep="\t", col.names=FALSE, row.names=FALSE, quote=FALSE)

  counts = cbind(fCountsList$annotation[,1], fCountsList$counts)
  write.table(counts, outCountsFilePath, sep="\t", col.names=FALSE, row.names=FALSE, quote=FALSE)

  write.table(cbind(fCountsList$annotation[,1], fpkm), outFpkmFilePath, sep="\t", col.names=FALSE, row.names=FALSE, quote=FALSE)
  write.table(cbind(fCountsList$annotation[,1], tpm), outTpmFilePath, sep="\t", col.names=FALSE, row.names=FALSE, quote=FALSE)

  unlink(paste(outBamFilePath, ".indel", sep=""))
}
