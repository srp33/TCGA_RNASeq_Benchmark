import os, sys, glob

queryText = sys.argv[1]
filePattern = sys.argv[2]

for f in glob.glob(filePattern):
    if queryText in f:
        print True
        exit(0)

print False
