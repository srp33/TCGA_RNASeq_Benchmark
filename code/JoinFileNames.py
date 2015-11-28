import os, sys, glob

filePattern = sys.argv[1]
delimiter = sys.argv[2]

print delimiter.join(glob.glob(filePattern))
