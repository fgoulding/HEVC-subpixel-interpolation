#!/usr/bin/env python
import argparse, os
from argparse import ArgumentParser
import sys
import scipy.misc
import numpy as np

def main():
    parser = ArgumentParser(description='Convert PNG into text file for processing.')
    parser.add_argument("-i", "--infile", type=argparse.FileType('r'),
                        default=sys.stdin)
    parser.add_argument("-o", "--outfile",
                    help="output file name", metavar="FILE")
    args = parser.parse_args()
    im = scipy.misc.imread(args.infile, flatten=False)
    r_im,g_im,b_im = [im[:,:,i] for i in range(3)]
    f,ext = os.path.splitext(args.outfile)
    f_red   = f+"_red" + ext
    f_green = f+"_green" + ext
    f_blue  = f+"_blue" + ext
    print r_im
    np.savetxt(f_red, r_im, fmt='%d', delimiter=" ")
    np.savetxt(f_green, g_im, fmt='%d', delimiter=" ")
    np.savetxt(f_blue, b_im, fmt='%d', delimiter=" ")

if __name__ == '__main__':
    main()
