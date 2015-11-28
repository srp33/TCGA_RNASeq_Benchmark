import os, sys, glob

inFilePattern = sys.argv[1]

print len(glob.glob(inFilePattern))
