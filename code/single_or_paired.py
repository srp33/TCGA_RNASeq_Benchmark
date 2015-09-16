#! /usr/bin/env python
import sys
import re
import pysam

bamFilePath = sys.argv[1]

bamFile = pysam.AlignmentFile(bamFilePath, "rb")

numSingle = 0
numPaired = 0

for read in bamFile.fetch():
    if read.is_paired:
        numPaired += 1
        if numPaired > 1000000:
            break
    else:
        numSingle += 1
        if numSingle > 1000000:
            break

bamFile.close()

if numPaired > numSingle:
    print "paired"
else:
    print "single"
