import os, sys, glob

countDict = {}

for filePath in glob.glob("FeatureCounts/*"):
    fileName = os.path.basename(filePath)
    sampleID = fileName[:20]
    #sampleID = fileName[:12]

    if sampleID in countDict:
        countDict[sampleID].append(fileName)
    else:
        countDict[sampleID] = [fileName]

numCommon = 0

for sampleID in countDict:
    if len(countDict[sampleID]) > 1:
        print countDict[sampleID]
        numCommon += 1

print numCommon
