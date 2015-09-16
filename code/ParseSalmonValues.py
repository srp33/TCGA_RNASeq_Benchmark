import os, sys, glob
from utilities import *

salmonDirPath = sys.argv[1]

if not os.path.exists("%s/FPKM" % salmonDirPath):
    os.mkdir("%s/TPM" % salmonDirPath)
    os.mkdir("%s/FPKM" % salmonDirPath)
    os.mkdir("%s/Counts" % salmonDirPath)

salmonFilePaths = glob.glob("%s/*/quant.sf" % salmonDirPath)

for inFilePath in salmonFilePaths:
    sampleID = os.path.basename(os.path.dirname(inFilePath))

    outTpmFilePath = "%s/TPM/%s" % (salmonDirPath, sampleID)
    outFpkmFilePath = "%s/FPKM/%s" % (salmonDirPath, sampleID)
    outCountFilePath = "%s/Counts/%s" % (salmonDirPath, sampleID)

    if not os.path.exists(outCountFilePath):
        print "Parsing values from %s" % inFilePath
        data = [x for x in readMatrixFromFile(inFilePath) if not x[0].startswith("#")]

        tpmData = [[x[0], x[2]] for x in data]
        fpkmData = [[x[0], x[3]] for x in data]
        countData = [[x[0], x[4]] for x in data]

        writeMatrixToFile(tpmData, outTpmFilePath)
        writeMatrixToFile(fpkmData, outFpkmFilePath)
        writeMatrixToFile(countData, outCountFilePath)
