#!/usr/bin/env python
import argparse, os
from argparse import ArgumentParser
import sys
import scipy.misc
import numpy as np
from PIL import Image


def main():
    parser = ArgumentParser(description='Convert PNG into text file for processing.')
    parser.add_argument("-i", "--infile", type=argparse.FileType('r'),
                        default=sys.stdin)
    parser.add_argument("-o", "--outfile",
                    help="output file name", metavar="FILE")
    args = parser.parse_args()
    im = scipy.misc.imread(args.infile, flatten=False)
    r_im,g_im,b_im = [im[:,:,i] for i in range(3)]
    r_im_rows = []
    for i in xrange(0,r_im.shape[0],3):
        # print i
        if (i+15> r_im.shape[0]):
            break;
        if (r_im_rows == []):
            print "strat"
            r_im_rows = r_im[:,i:i+15]
        else:
            r_im_rows = np.append(r_im_rows,r_im[:,i:i+15],axis=0)

    r_im_rows = np.array(r_im_rows)
    print r_im_rows.shape
    out_im = Image.fromarray(r_im_rows)
    out_im.show()


    f,ext = os.path.splitext(args.outfile)
    f_red   = f+"_red" + ext
    f_red_rows   = f+"_red_rows" + ext

    f_green = f+"_green" + ext
    f_blue  = f+"_blue" + ext
    print r_im
    np.savetxt(f_red, r_im, fmt='%x', delimiter=" ")
    np.savetxt(f_red_rows, r_im_rows, fmt='%x', delimiter=" ")
    np.savetxt(f_green, g_im, fmt='%x', delimiter=" ")
    np.savetxt(f_blue, b_im, fmt='%x', delimiter=" ")

if __name__ == '__main__':
    main()
