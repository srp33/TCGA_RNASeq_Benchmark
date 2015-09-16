import os, sys, glob
from utilities import *

inDirPath = sys.argv[1]

if not os.path.exists("%s/Counts" % inDirPath):
    os.mkdir("%s/TPM" % inDirPath)
    os.mkdir("%s/Counts" % inDirPath)

inFilePaths = glob.glob("%s/*/abundance.tsv" % inDirPath)

for inFilePath in inFilePaths:
    sampleID = os.path.basename(os.path.dirname(inFilePath))

    outTpmFilePath = "%s/TPM/%s" % (inDirPath, sampleID)
    outCountFilePath = "%s/Counts/%s" % (inDirPath, sampleID)

    if not os.path.exists(outCountFilePath):
        print "Parsing values from %s" % inFilePath
        data = [x for x in readMatrixFromFile(inFilePath) if not x[0].startswith("target_id")]

        tpmData = [[x[0], x[4]] for x in data]
        countData = [[x[0], x[3]] for x in data]

        writeMatrixToFile(tpmData, outTpmFilePath)
        writeMatrixToFile(countData, outCountFilePath)
