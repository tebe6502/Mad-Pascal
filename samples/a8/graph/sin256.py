# generowanie tablicy sinus

import os, sys, msvcrt, pickle, struct, math


def scale(ile):

	f = open('sin256.pas', "w")

	f.write("\t")
	f.write("tsin : array [0..255] of sineType = (\n")

	s = 360/256

	for b in range(ile):


		x=math.sin(b*s*math.pi/180)

		f.write("{:10.4f}".format(x))		# sin

		if b != ile-1:
			f.write(",\t// {0:03d}".format(b))

		f.write("\n")


	f.write("\t);\n")
	f.close()


	return


def main():
	scale(256)

main()