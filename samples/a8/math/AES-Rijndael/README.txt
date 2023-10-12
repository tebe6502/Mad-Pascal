Files in this archive:

README.txt		this file
rijndael.pas		unit with basic Rijndael routines
rijndaelECB.pas		unit for using Rijndael in Electronic Codebook mode
rijndael-test.pas	program for simple automatic test of unit Rijndael
rijndael-tool.pas	interactive program using unit RijndaelECB;
			Test: encrypting all-0 plaintext with all-0 key
			yields ciphertext 66E94BD4EF8A2C3B884CFA59CA342B2E

In October 2000, the National Institute of Standards and Technology
(NIST) proposed Rijndael as the new Advanced Encryption Standard (AES),
the successor of the Data Encryption Standard (DES) adopted in 1977
and Triple DES (standardized in 1999).

A slightly different version of the software in this archive played
a central role in task DOUBLE on the second competition day of the
International Olympiad in Informatics (IOI) held in Tampere, Finland,
in July 2001.  At IOI 2001, FreePascal was one of the programming tools
available to the competitors.

Web sites:

AES		http://www.nist.gov/aes/
DES		http://www.itl.nist.gov/fipspubs/fip46-2.htm
IOI		http://olympiads.win.tue.nl/ioi/
NIST		http://www.nist.gov/
Rijndael	http://www.esat.kuleuven.ac.be/~rijmen/rijndael/
Task DOUBLE	http://olympiads.win.tue.nl/ioi/ioi2001/contest/day2/double/
Triple DES	http://csrc.nist.gov/cryptval/des/fr990115.htm

Crypto ToolKit	http://csrc.nist.gov/encryption/tkencryption.html
