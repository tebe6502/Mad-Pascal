{*
 * Rijndael.pas
 *
 * Optimised Pascal implementation of the Rijndael cipher (now AES).
 * For Advanced Encryption Standard (AES) see http://www.nist.gov/aes/
 *
 * Assumes SIZEOF(cardinal) = 4.
 * Developed with Turbo Pascal 7, later FreePascal.
 *
 * @version 1.0 (February 2001)
 * @author Tom Verhoeff <T.Verhoeff@tue.nl>
 *
 * Based on
 * version 1.0 (January 2001) of Rijndael.mod (in Oberon-2)
 * @author Paulo Barreto <paulo.barreto@terra.com.br>
 *
 * and
 *
 * version 3.0 (December 2000) of rijndael-alg-fst.c
 * Optimised ANSI C code for the Rijndael cipher (now AES)
 * @author Vincent Rijmen <vincent.rijmen@esat.kuleuven.ac.be>
 * @author Antoon Bosselaers <antoon.bosselaers@esat.kuleuven.ac.be>
 * @author Paulo Barreto <paulo.barreto@terra.com.br>

 * This code is hereby placed in the public domain.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS ''AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *}
unit rijndael;

interface

    CONST MAXNR = 14;
    CONST MAXRK = 4*(MAXNR + 1);
    CONST MAXKS = 256 DIV 8;

  { TYPE  Block       = ARRAY [ 0..31 ] OF BYTE;  only needed conceptually }
    TYPE  ExpandedKey = ARRAY [ 0..MAXRK-1 ] OF cardinal;

    FUNCTION KeySetupEnc (VAR rk: ExpandedKey; CONST cipherKey: PByte; keyBits: cardinal): byte;

    FUNCTION KeySetupDec (VAR rk: ExpandedKey; CONST cipherKey: PByte; keyBits: cardinal): byte;

    PROCEDURE Encrypt (CONST rk: ExpandedKey; Nr: cardinal; CONST pt: PByte; p0: cardinal; ct: PByte; c0: cardinal);

    PROCEDURE Decrypt (CONST rk: ExpandedKey; Nr: cardinal; CONST ct: PByte; c0: cardinal; pt: PByte; p0: cardinal);


implementation

    (*
        Te0[x] = Sbox[x].[02, 01, 01, 03];
        Te1[x] = Sbox[x].[03, 02, 01, 01];
        Te2[x] = Sbox[x].[01, 03, 02, 01];
        Te3[x] = Sbox[x].[01, 01, 03, 02];
        Te4[x] = Sbox[x].[01, 01, 01, 01];

        Td0[x] = Ibox[x].[0e, 09, 0d, 0b];
        Td1[x] = Ibox[x].[0b, 0e, 09, 0d];
        Td2[x] = Ibox[x].[0d, 0b, 0e, 09];
        Td3[x] = Ibox[x].[09, 0d, 0b, 0e];
        Td4[x] = Ibox[x].[01, 01, 01, 01];
    *)

const Te0: ARRAY [0..255] OF cardinal = (
    $c66363a5, $f87c7c84, $ee777799, $f67b7b8d,
    $fff2f20d, $d66b6bbd, $de6f6fb1, $91c5c554,
    $60303050, $02010103, $ce6767a9, $562b2b7d,
    $e7fefe19, $b5d7d762, $4dababe6, $ec76769a,
    $8fcaca45, $1f82829d, $89c9c940, $fa7d7d87,
    $effafa15, $b25959eb, $8e4747c9, $fbf0f00b,
    $41adadec, $b3d4d467, $5fa2a2fd, $45afafea,
    $239c9cbf, $53a4a4f7, $e4727296, $9bc0c05b,
    $75b7b7c2, $e1fdfd1c, $3d9393ae, $4c26266a,
    $6c36365a, $7e3f3f41, $f5f7f702, $83cccc4f,
    $6834345c, $51a5a5f4, $d1e5e534, $f9f1f108,
    $e2717193, $abd8d873, $62313153, $2a15153f,
    $0804040c, $95c7c752, $46232365, $9dc3c35e,
    $30181828, $379696a1, $0a05050f, $2f9a9ab5,
    $0e070709, $24121236, $1b80809b, $dfe2e23d,
    $cdebeb26, $4e272769, $7fb2b2cd, $ea75759f,
    $1209091b, $1d83839e, $582c2c74, $341a1a2e,
    $361b1b2d, $dc6e6eb2, $b45a5aee, $5ba0a0fb,
    $a45252f6, $763b3b4d, $b7d6d661, $7db3b3ce,
    $5229297b, $dde3e33e, $5e2f2f71, $13848497,
    $a65353f5, $b9d1d168, $00000000, $c1eded2c,
    $40202060, $e3fcfc1f, $79b1b1c8, $b65b5bed,
    $d46a6abe, $8dcbcb46, $67bebed9, $7239394b,
    $944a4ade, $984c4cd4, $b05858e8, $85cfcf4a,
    $bbd0d06b, $c5efef2a, $4faaaae5, $edfbfb16,
    $864343c5, $9a4d4dd7, $66333355, $11858594,
    $8a4545cf, $e9f9f910, $04020206, $fe7f7f81,
    $a05050f0, $783c3c44, $259f9fba, $4ba8a8e3,
    $a25151f3, $5da3a3fe, $804040c0, $058f8f8a,
    $3f9292ad, $219d9dbc, $70383848, $f1f5f504,
    $63bcbcdf, $77b6b6c1, $afdada75, $42212163,
    $20101030, $e5ffff1a, $fdf3f30e, $bfd2d26d,
    $81cdcd4c, $180c0c14, $26131335, $c3ecec2f,
    $be5f5fe1, $359797a2, $884444cc, $2e171739,
    $93c4c457, $55a7a7f2, $fc7e7e82, $7a3d3d47,
    $c86464ac, $ba5d5de7, $3219192b, $e6737395,
    $c06060a0, $19818198, $9e4f4fd1, $a3dcdc7f,
    $44222266, $542a2a7e, $3b9090ab, $0b888883,
    $8c4646ca, $c7eeee29, $6bb8b8d3, $2814143c,
    $a7dede79, $bc5e5ee2, $160b0b1d, $addbdb76,
    $dbe0e03b, $64323256, $743a3a4e, $140a0a1e,
    $924949db, $0c06060a, $4824246c, $b85c5ce4,
    $9fc2c25d, $bdd3d36e, $43acacef, $c46262a6,
    $399191a8, $319595a4, $d3e4e437, $f279798b,
    $d5e7e732, $8bc8c843, $6e373759, $da6d6db7,
    $018d8d8c, $b1d5d564, $9c4e4ed2, $49a9a9e0,
    $d86c6cb4, $ac5656fa, $f3f4f407, $cfeaea25,
    $ca6565af, $f47a7a8e, $47aeaee9, $10080818,
    $6fbabad5, $f0787888, $4a25256f, $5c2e2e72,
    $381c1c24, $57a6a6f1, $73b4b4c7, $97c6c651,
    $cbe8e823, $a1dddd7c, $e874749c, $3e1f1f21,
    $964b4bdd, $61bdbddc, $0d8b8b86, $0f8a8a85,
    $e0707090, $7c3e3e42, $71b5b5c4, $cc6666aa,
    $904848d8, $06030305, $f7f6f601, $1c0e0e12,
    $c26161a3, $6a35355f, $ae5757f9, $69b9b9d0,
    $17868691, $99c1c158, $3a1d1d27, $279e9eb9,
    $d9e1e138, $ebf8f813, $2b9898b3, $22111133,
    $d26969bb, $a9d9d970, $078e8e89, $339494a7,
    $2d9b9bb6, $3c1e1e22, $15878792, $c9e9e920,
    $87cece49, $aa5555ff, $50282878, $a5dfdf7a,
    $038c8c8f, $59a1a1f8, $09898980, $1a0d0d17,
    $65bfbfda, $d7e6e631, $844242c6, $d06868b8,
    $824141c3, $299999b0, $5a2d2d77, $1e0f0f11,
    $7bb0b0cb, $a85454fc, $6dbbbbd6, $2c16163a
);
const Te1: ARRAY [0..255] OF cardinal = (
    $a5c66363, $84f87c7c, $99ee7777, $8df67b7b,
    $0dfff2f2, $bdd66b6b, $b1de6f6f, $5491c5c5,
    $50603030, $03020101, $a9ce6767, $7d562b2b,
    $19e7fefe, $62b5d7d7, $e64dabab, $9aec7676,
    $458fcaca, $9d1f8282, $4089c9c9, $87fa7d7d,
    $15effafa, $ebb25959, $c98e4747, $0bfbf0f0,
    $ec41adad, $67b3d4d4, $fd5fa2a2, $ea45afaf,
    $bf239c9c, $f753a4a4, $96e47272, $5b9bc0c0,
    $c275b7b7, $1ce1fdfd, $ae3d9393, $6a4c2626,
    $5a6c3636, $417e3f3f, $02f5f7f7, $4f83cccc,
    $5c683434, $f451a5a5, $34d1e5e5, $08f9f1f1,
    $93e27171, $73abd8d8, $53623131, $3f2a1515,
    $0c080404, $5295c7c7, $65462323, $5e9dc3c3,
    $28301818, $a1379696, $0f0a0505, $b52f9a9a,
    $090e0707, $36241212, $9b1b8080, $3ddfe2e2,
    $26cdebeb, $694e2727, $cd7fb2b2, $9fea7575,
    $1b120909, $9e1d8383, $74582c2c, $2e341a1a,
    $2d361b1b, $b2dc6e6e, $eeb45a5a, $fb5ba0a0,
    $f6a45252, $4d763b3b, $61b7d6d6, $ce7db3b3,
    $7b522929, $3edde3e3, $715e2f2f, $97138484,
    $f5a65353, $68b9d1d1, $00000000, $2cc1eded,
    $60402020, $1fe3fcfc, $c879b1b1, $edb65b5b,
    $bed46a6a, $468dcbcb, $d967bebe, $4b723939,
    $de944a4a, $d4984c4c, $e8b05858, $4a85cfcf,
    $6bbbd0d0, $2ac5efef, $e54faaaa, $16edfbfb,
    $c5864343, $d79a4d4d, $55663333, $94118585,
    $cf8a4545, $10e9f9f9, $06040202, $81fe7f7f,
    $f0a05050, $44783c3c, $ba259f9f, $e34ba8a8,
    $f3a25151, $fe5da3a3, $c0804040, $8a058f8f,
    $ad3f9292, $bc219d9d, $48703838, $04f1f5f5,
    $df63bcbc, $c177b6b6, $75afdada, $63422121,
    $30201010, $1ae5ffff, $0efdf3f3, $6dbfd2d2,
    $4c81cdcd, $14180c0c, $35261313, $2fc3ecec,
    $e1be5f5f, $a2359797, $cc884444, $392e1717,
    $5793c4c4, $f255a7a7, $82fc7e7e, $477a3d3d,
    $acc86464, $e7ba5d5d, $2b321919, $95e67373,
    $a0c06060, $98198181, $d19e4f4f, $7fa3dcdc,
    $66442222, $7e542a2a, $ab3b9090, $830b8888,
    $ca8c4646, $29c7eeee, $d36bb8b8, $3c281414,
    $79a7dede, $e2bc5e5e, $1d160b0b, $76addbdb,
    $3bdbe0e0, $56643232, $4e743a3a, $1e140a0a,
    $db924949, $0a0c0606, $6c482424, $e4b85c5c,
    $5d9fc2c2, $6ebdd3d3, $ef43acac, $a6c46262,
    $a8399191, $a4319595, $37d3e4e4, $8bf27979,
    $32d5e7e7, $438bc8c8, $596e3737, $b7da6d6d,
    $8c018d8d, $64b1d5d5, $d29c4e4e, $e049a9a9,
    $b4d86c6c, $faac5656, $07f3f4f4, $25cfeaea,
    $afca6565, $8ef47a7a, $e947aeae, $18100808,
    $d56fbaba, $88f07878, $6f4a2525, $725c2e2e,
    $24381c1c, $f157a6a6, $c773b4b4, $5197c6c6,
    $23cbe8e8, $7ca1dddd, $9ce87474, $213e1f1f,
    $dd964b4b, $dc61bdbd, $860d8b8b, $850f8a8a,
    $90e07070, $427c3e3e, $c471b5b5, $aacc6666,
    $d8904848, $05060303, $01f7f6f6, $121c0e0e,
    $a3c26161, $5f6a3535, $f9ae5757, $d069b9b9,
    $91178686, $5899c1c1, $273a1d1d, $b9279e9e,
    $38d9e1e1, $13ebf8f8, $b32b9898, $33221111,
    $bbd26969, $70a9d9d9, $89078e8e, $a7339494,
    $b62d9b9b, $223c1e1e, $92158787, $20c9e9e9,
    $4987cece, $ffaa5555, $78502828, $7aa5dfdf,
    $8f038c8c, $f859a1a1, $80098989, $171a0d0d,
    $da65bfbf, $31d7e6e6, $c6844242, $b8d06868,
    $c3824141, $b0299999, $775a2d2d, $111e0f0f,
    $cb7bb0b0, $fca85454, $d66dbbbb, $3a2c1616
);
const Te2: ARRAY [0..255] OF cardinal = (
    $63a5c663, $7c84f87c, $7799ee77, $7b8df67b,
    $f20dfff2, $6bbdd66b, $6fb1de6f, $c55491c5,
    $30506030, $01030201, $67a9ce67, $2b7d562b,
    $fe19e7fe, $d762b5d7, $abe64dab, $769aec76,
    $ca458fca, $829d1f82, $c94089c9, $7d87fa7d,
    $fa15effa, $59ebb259, $47c98e47, $f00bfbf0,
    $adec41ad, $d467b3d4, $a2fd5fa2, $afea45af,
    $9cbf239c, $a4f753a4, $7296e472, $c05b9bc0,
    $b7c275b7, $fd1ce1fd, $93ae3d93, $266a4c26,
    $365a6c36, $3f417e3f, $f702f5f7, $cc4f83cc,
    $345c6834, $a5f451a5, $e534d1e5, $f108f9f1,
    $7193e271, $d873abd8, $31536231, $153f2a15,
    $040c0804, $c75295c7, $23654623, $c35e9dc3,
    $18283018, $96a13796, $050f0a05, $9ab52f9a,
    $07090e07, $12362412, $809b1b80, $e23ddfe2,
    $eb26cdeb, $27694e27, $b2cd7fb2, $759fea75,
    $091b1209, $839e1d83, $2c74582c, $1a2e341a,
    $1b2d361b, $6eb2dc6e, $5aeeb45a, $a0fb5ba0,
    $52f6a452, $3b4d763b, $d661b7d6, $b3ce7db3,
    $297b5229, $e33edde3, $2f715e2f, $84971384,
    $53f5a653, $d168b9d1, $00000000, $ed2cc1ed,
    $20604020, $fc1fe3fc, $b1c879b1, $5bedb65b,
    $6abed46a, $cb468dcb, $bed967be, $394b7239,
    $4ade944a, $4cd4984c, $58e8b058, $cf4a85cf,
    $d06bbbd0, $ef2ac5ef, $aae54faa, $fb16edfb,
    $43c58643, $4dd79a4d, $33556633, $85941185,
    $45cf8a45, $f910e9f9, $02060402, $7f81fe7f,
    $50f0a050, $3c44783c, $9fba259f, $a8e34ba8,
    $51f3a251, $a3fe5da3, $40c08040, $8f8a058f,
    $92ad3f92, $9dbc219d, $38487038, $f504f1f5,
    $bcdf63bc, $b6c177b6, $da75afda, $21634221,
    $10302010, $ff1ae5ff, $f30efdf3, $d26dbfd2,
    $cd4c81cd, $0c14180c, $13352613, $ec2fc3ec,
    $5fe1be5f, $97a23597, $44cc8844, $17392e17,
    $c45793c4, $a7f255a7, $7e82fc7e, $3d477a3d,
    $64acc864, $5de7ba5d, $192b3219, $7395e673,
    $60a0c060, $81981981, $4fd19e4f, $dc7fa3dc,
    $22664422, $2a7e542a, $90ab3b90, $88830b88,
    $46ca8c46, $ee29c7ee, $b8d36bb8, $143c2814,
    $de79a7de, $5ee2bc5e, $0b1d160b, $db76addb,
    $e03bdbe0, $32566432, $3a4e743a, $0a1e140a,
    $49db9249, $060a0c06, $246c4824, $5ce4b85c,
    $c25d9fc2, $d36ebdd3, $acef43ac, $62a6c462,
    $91a83991, $95a43195, $e437d3e4, $798bf279,
    $e732d5e7, $c8438bc8, $37596e37, $6db7da6d,
    $8d8c018d, $d564b1d5, $4ed29c4e, $a9e049a9,
    $6cb4d86c, $56faac56, $f407f3f4, $ea25cfea,
    $65afca65, $7a8ef47a, $aee947ae, $08181008,
    $bad56fba, $7888f078, $256f4a25, $2e725c2e,
    $1c24381c, $a6f157a6, $b4c773b4, $c65197c6,
    $e823cbe8, $dd7ca1dd, $749ce874, $1f213e1f,
    $4bdd964b, $bddc61bd, $8b860d8b, $8a850f8a,
    $7090e070, $3e427c3e, $b5c471b5, $66aacc66,
    $48d89048, $03050603, $f601f7f6, $0e121c0e,
    $61a3c261, $355f6a35, $57f9ae57, $b9d069b9,
    $86911786, $c15899c1, $1d273a1d, $9eb9279e,
    $e138d9e1, $f813ebf8, $98b32b98, $11332211,
    $69bbd269, $d970a9d9, $8e89078e, $94a73394,
    $9bb62d9b, $1e223c1e, $87921587, $e920c9e9,
    $ce4987ce, $55ffaa55, $28785028, $df7aa5df,
    $8c8f038c, $a1f859a1, $89800989, $0d171a0d,
    $bfda65bf, $e631d7e6, $42c68442, $68b8d068,
    $41c38241, $99b02999, $2d775a2d, $0f111e0f,
    $b0cb7bb0, $54fca854, $bbd66dbb, $163a2c16
);
const Te3: ARRAY [0..255] OF cardinal = (
    $6363a5c6, $7c7c84f8, $777799ee, $7b7b8df6,
    $f2f20dff, $6b6bbdd6, $6f6fb1de, $c5c55491,
    $30305060, $01010302, $6767a9ce, $2b2b7d56,
    $fefe19e7, $d7d762b5, $ababe64d, $76769aec,
    $caca458f, $82829d1f, $c9c94089, $7d7d87fa,
    $fafa15ef, $5959ebb2, $4747c98e, $f0f00bfb,
    $adadec41, $d4d467b3, $a2a2fd5f, $afafea45,
    $9c9cbf23, $a4a4f753, $727296e4, $c0c05b9b,
    $b7b7c275, $fdfd1ce1, $9393ae3d, $26266a4c,
    $36365a6c, $3f3f417e, $f7f702f5, $cccc4f83,
    $34345c68, $a5a5f451, $e5e534d1, $f1f108f9,
    $717193e2, $d8d873ab, $31315362, $15153f2a,
    $04040c08, $c7c75295, $23236546, $c3c35e9d,
    $18182830, $9696a137, $05050f0a, $9a9ab52f,
    $0707090e, $12123624, $80809b1b, $e2e23ddf,
    $ebeb26cd, $2727694e, $b2b2cd7f, $75759fea,
    $09091b12, $83839e1d, $2c2c7458, $1a1a2e34,
    $1b1b2d36, $6e6eb2dc, $5a5aeeb4, $a0a0fb5b,
    $5252f6a4, $3b3b4d76, $d6d661b7, $b3b3ce7d,
    $29297b52, $e3e33edd, $2f2f715e, $84849713,
    $5353f5a6, $d1d168b9, $00000000, $eded2cc1,
    $20206040, $fcfc1fe3, $b1b1c879, $5b5bedb6,
    $6a6abed4, $cbcb468d, $bebed967, $39394b72,
    $4a4ade94, $4c4cd498, $5858e8b0, $cfcf4a85,
    $d0d06bbb, $efef2ac5, $aaaae54f, $fbfb16ed,
    $4343c586, $4d4dd79a, $33335566, $85859411,
    $4545cf8a, $f9f910e9, $02020604, $7f7f81fe,
    $5050f0a0, $3c3c4478, $9f9fba25, $a8a8e34b,
    $5151f3a2, $a3a3fe5d, $4040c080, $8f8f8a05,
    $9292ad3f, $9d9dbc21, $38384870, $f5f504f1,
    $bcbcdf63, $b6b6c177, $dada75af, $21216342,
    $10103020, $ffff1ae5, $f3f30efd, $d2d26dbf,
    $cdcd4c81, $0c0c1418, $13133526, $ecec2fc3,
    $5f5fe1be, $9797a235, $4444cc88, $1717392e,
    $c4c45793, $a7a7f255, $7e7e82fc, $3d3d477a,
    $6464acc8, $5d5de7ba, $19192b32, $737395e6,
    $6060a0c0, $81819819, $4f4fd19e, $dcdc7fa3,
    $22226644, $2a2a7e54, $9090ab3b, $8888830b,
    $4646ca8c, $eeee29c7, $b8b8d36b, $14143c28,
    $dede79a7, $5e5ee2bc, $0b0b1d16, $dbdb76ad,
    $e0e03bdb, $32325664, $3a3a4e74, $0a0a1e14,
    $4949db92, $06060a0c, $24246c48, $5c5ce4b8,
    $c2c25d9f, $d3d36ebd, $acacef43, $6262a6c4,
    $9191a839, $9595a431, $e4e437d3, $79798bf2,
    $e7e732d5, $c8c8438b, $3737596e, $6d6db7da,
    $8d8d8c01, $d5d564b1, $4e4ed29c, $a9a9e049,
    $6c6cb4d8, $5656faac, $f4f407f3, $eaea25cf,
    $6565afca, $7a7a8ef4, $aeaee947, $08081810,
    $babad56f, $787888f0, $25256f4a, $2e2e725c,
    $1c1c2438, $a6a6f157, $b4b4c773, $c6c65197,
    $e8e823cb, $dddd7ca1, $74749ce8, $1f1f213e,
    $4b4bdd96, $bdbddc61, $8b8b860d, $8a8a850f,
    $707090e0, $3e3e427c, $b5b5c471, $6666aacc,
    $4848d890, $03030506, $f6f601f7, $0e0e121c,
    $6161a3c2, $35355f6a, $5757f9ae, $b9b9d069,
    $86869117, $c1c15899, $1d1d273a, $9e9eb927,
    $e1e138d9, $f8f813eb, $9898b32b, $11113322,
    $6969bbd2, $d9d970a9, $8e8e8907, $9494a733,
    $9b9bb62d, $1e1e223c, $87879215, $e9e920c9,
    $cece4987, $5555ffaa, $28287850, $dfdf7aa5,
    $8c8c8f03, $a1a1f859, $89898009, $0d0d171a,
    $bfbfda65, $e6e631d7, $4242c684, $6868b8d0,
    $4141c382, $9999b029, $2d2d775a, $0f0f111e,
    $b0b0cb7b, $5454fca8, $bbbbd66d, $16163a2c
);
const Te4: ARRAY [0..255] OF cardinal = (
    $63636363, $7c7c7c7c, $77777777, $7b7b7b7b,
    $f2f2f2f2, $6b6b6b6b, $6f6f6f6f, $c5c5c5c5,
    $30303030, $01010101, $67676767, $2b2b2b2b,
    $fefefefe, $d7d7d7d7, $abababab, $76767676,
    $cacacaca, $82828282, $c9c9c9c9, $7d7d7d7d,
    $fafafafa, $59595959, $47474747, $f0f0f0f0,
    $adadadad, $d4d4d4d4, $a2a2a2a2, $afafafaf,
    $9c9c9c9c, $a4a4a4a4, $72727272, $c0c0c0c0,
    $b7b7b7b7, $fdfdfdfd, $93939393, $26262626,
    $36363636, $3f3f3f3f, $f7f7f7f7, $cccccccc,
    $34343434, $a5a5a5a5, $e5e5e5e5, $f1f1f1f1,
    $71717171, $d8d8d8d8, $31313131, $15151515,
    $04040404, $c7c7c7c7, $23232323, $c3c3c3c3,
    $18181818, $96969696, $05050505, $9a9a9a9a,
    $07070707, $12121212, $80808080, $e2e2e2e2,
    $ebebebeb, $27272727, $b2b2b2b2, $75757575,
    $09090909, $83838383, $2c2c2c2c, $1a1a1a1a,
    $1b1b1b1b, $6e6e6e6e, $5a5a5a5a, $a0a0a0a0,
    $52525252, $3b3b3b3b, $d6d6d6d6, $b3b3b3b3,
    $29292929, $e3e3e3e3, $2f2f2f2f, $84848484,
    $53535353, $d1d1d1d1, $00000000, $edededed,
    $20202020, $fcfcfcfc, $b1b1b1b1, $5b5b5b5b,
    $6a6a6a6a, $cbcbcbcb, $bebebebe, $39393939,
    $4a4a4a4a, $4c4c4c4c, $58585858, $cfcfcfcf,
    $d0d0d0d0, $efefefef, $aaaaaaaa, $fbfbfbfb,
    $43434343, $4d4d4d4d, $33333333, $85858585,
    $45454545, $f9f9f9f9, $02020202, $7f7f7f7f,
    $50505050, $3c3c3c3c, $9f9f9f9f, $a8a8a8a8,
    $51515151, $a3a3a3a3, $40404040, $8f8f8f8f,
    $92929292, $9d9d9d9d, $38383838, $f5f5f5f5,
    $bcbcbcbc, $b6b6b6b6, $dadadada, $21212121,
    $10101010, $ffffffff, $f3f3f3f3, $d2d2d2d2,
    $cdcdcdcd, $0c0c0c0c, $13131313, $ecececec,
    $5f5f5f5f, $97979797, $44444444, $17171717,
    $c4c4c4c4, $a7a7a7a7, $7e7e7e7e, $3d3d3d3d,
    $64646464, $5d5d5d5d, $19191919, $73737373,
    $60606060, $81818181, $4f4f4f4f, $dcdcdcdc,
    $22222222, $2a2a2a2a, $90909090, $88888888,
    $46464646, $eeeeeeee, $b8b8b8b8, $14141414,
    $dededede, $5e5e5e5e, $0b0b0b0b, $dbdbdbdb,
    $e0e0e0e0, $32323232, $3a3a3a3a, $0a0a0a0a,
    $49494949, $06060606, $24242424, $5c5c5c5c,
    $c2c2c2c2, $d3d3d3d3, $acacacac, $62626262,
    $91919191, $95959595, $e4e4e4e4, $79797979,
    $e7e7e7e7, $c8c8c8c8, $37373737, $6d6d6d6d,
    $8d8d8d8d, $d5d5d5d5, $4e4e4e4e, $a9a9a9a9,
    $6c6c6c6c, $56565656, $f4f4f4f4, $eaeaeaea,
    $65656565, $7a7a7a7a, $aeaeaeae, $08080808,
    $babababa, $78787878, $25252525, $2e2e2e2e,
    $1c1c1c1c, $a6a6a6a6, $b4b4b4b4, $c6c6c6c6,
    $e8e8e8e8, $dddddddd, $74747474, $1f1f1f1f,
    $4b4b4b4b, $bdbdbdbd, $8b8b8b8b, $8a8a8a8a,
    $70707070, $3e3e3e3e, $b5b5b5b5, $66666666,
    $48484848, $03030303, $f6f6f6f6, $0e0e0e0e,
    $61616161, $35353535, $57575757, $b9b9b9b9,
    $86868686, $c1c1c1c1, $1d1d1d1d, $9e9e9e9e,
    $e1e1e1e1, $f8f8f8f8, $98989898, $11111111,
    $69696969, $d9d9d9d9, $8e8e8e8e, $94949494,
    $9b9b9b9b, $1e1e1e1e, $87878787, $e9e9e9e9,
    $cececece, $55555555, $28282828, $dfdfdfdf,
    $8c8c8c8c, $a1a1a1a1, $89898989, $0d0d0d0d,
    $bfbfbfbf, $e6e6e6e6, $42424242, $68686868,
    $41414141, $99999999, $2d2d2d2d, $0f0f0f0f,
    $b0b0b0b0, $54545454, $bbbbbbbb, $16161616
);
const Td0: ARRAY [0..255] OF cardinal = (
    $51f4a750, $7e416553, $1a17a4c3, $3a275e96,
    $3bab6bcb, $1f9d45f1, $acfa58ab, $4be30393,
    $2030fa55, $ad766df6, $88cc7691, $f5024c25,
    $4fe5d7fc, $c52acbd7, $26354480, $b562a38f,
    $deb15a49, $25ba1b67, $45ea0e98, $5dfec0e1,
    $c32f7502, $814cf012, $8d4697a3, $6bd3f9c6,
    $038f5fe7, $15929c95, $bf6d7aeb, $955259da,
    $d4be832d, $587421d3, $49e06929, $8ec9c844,
    $75c2896a, $f48e7978, $99583e6b, $27b971dd,
    $bee14fb6, $f088ad17, $c920ac66, $7dce3ab4,
    $63df4a18, $e51a3182, $97513360, $62537f45,
    $b16477e0, $bb6bae84, $fe81a01c, $f9082b94,
    $70486858, $8f45fd19, $94de6c87, $527bf8b7,
    $ab73d323, $724b02e2, $e31f8f57, $6655ab2a,
    $b2eb2807, $2fb5c203, $86c57b9a, $d33708a5,
    $302887f2, $23bfa5b2, $02036aba, $ed16825c,
    $8acf1c2b, $a779b492, $f307f2f0, $4e69e2a1,
    $65daf4cd, $0605bed5, $d134621f, $c4a6fe8a,
    $342e539d, $a2f355a0, $058ae132, $a4f6eb75,
    $0b83ec39, $4060efaa, $5e719f06, $bd6e1051,
    $3e218af9, $96dd063d, $dd3e05ae, $4de6bd46,
    $91548db5, $71c45d05, $0406d46f, $605015ff,
    $1998fb24, $d6bde997, $894043cc, $67d99e77,
    $b0e842bd, $07898b88, $e7195b38, $79c8eedb,
    $a17c0a47, $7c420fe9, $f8841ec9, $00000000,
    $09808683, $322bed48, $1e1170ac, $6c5a724e,
    $fd0efffb, $0f853856, $3daed51e, $362d3927,
    $0a0fd964, $685ca621, $9b5b54d1, $24362e3a,
    $0c0a67b1, $9357e70f, $b4ee96d2, $1b9b919e,
    $80c0c54f, $61dc20a2, $5a774b69, $1c121a16,
    $e293ba0a, $c0a02ae5, $3c22e043, $121b171d,
    $0e090d0b, $f28bc7ad, $2db6a8b9, $141ea9c8,
    $57f11985, $af75074c, $ee99ddbb, $a37f60fd,
    $f701269f, $5c72f5bc, $44663bc5, $5bfb7e34,
    $8b432976, $cb23c6dc, $b6edfc68, $b8e4f163,
    $d731dcca, $42638510, $13972240, $84c61120,
    $854a247d, $d2bb3df8, $aef93211, $c729a16d,
    $1d9e2f4b, $dcb230f3, $0d8652ec, $77c1e3d0,
    $2bb3166c, $a970b999, $119448fa, $47e96422,
    $a8fc8cc4, $a0f03f1a, $567d2cd8, $223390ef,
    $87494ec7, $d938d1c1, $8ccaa2fe, $98d40b36,
    $a6f581cf, $a57ade28, $dab78e26, $3fadbfa4,
    $2c3a9de4, $5078920d, $6a5fcc9b, $547e4662,
    $f68d13c2, $90d8b8e8, $2e39f75e, $82c3aff5,
    $9f5d80be, $69d0937c, $6fd52da9, $cf2512b3,
    $c8ac993b, $10187da7, $e89c636e, $db3bbb7b,
    $cd267809, $6e5918f4, $ec9ab701, $834f9aa8,
    $e6956e65, $aaffe67e, $21bccf08, $ef15e8e6,
    $bae79bd9, $4a6f36ce, $ea9f09d4, $29b07cd6,
    $31a4b2af, $2a3f2331, $c6a59430, $35a266c0,
    $744ebc37, $fc82caa6, $e090d0b0, $33a7d815,
    $f104984a, $41ecdaf7, $7fcd500e, $1791f62f,
    $764dd68d, $43efb04d, $ccaa4d54, $e49604df,
    $9ed1b5e3, $4c6a881b, $c12c1fb8, $4665517f,
    $9d5eea04, $018c355d, $fa877473, $fb0b412e,
    $b3671d5a, $92dbd252, $e9105633, $6dd64713,
    $9ad7618c, $37a10c7a, $59f8148e, $eb133c89,
    $cea927ee, $b761c935, $e11ce5ed, $7a47b13c,
    $9cd2df59, $55f2733f, $1814ce79, $73c737bf,
    $53f7cdea, $5ffdaa5b, $df3d6f14, $7844db86,
    $caaff381, $b968c43e, $3824342c, $c2a3405f,
    $161dc372, $bce2250c, $283c498b, $ff0d9541,
    $39a80171, $080cb3de, $d8b4e49c, $6456c190,
    $7bcb8461, $d532b670, $486c5c74, $d0b85742
);
const Td1: ARRAY [0..255] OF cardinal = (
    $5051f4a7, $537e4165, $c31a17a4, $963a275e,
    $cb3bab6b, $f11f9d45, $abacfa58, $934be303,
    $552030fa, $f6ad766d, $9188cc76, $25f5024c,
    $fc4fe5d7, $d7c52acb, $80263544, $8fb562a3,
    $49deb15a, $6725ba1b, $9845ea0e, $e15dfec0,
    $02c32f75, $12814cf0, $a38d4697, $c66bd3f9,
    $e7038f5f, $9515929c, $ebbf6d7a, $da955259,
    $2dd4be83, $d3587421, $2949e069, $448ec9c8,
    $6a75c289, $78f48e79, $6b99583e, $dd27b971,
    $b6bee14f, $17f088ad, $66c920ac, $b47dce3a,
    $1863df4a, $82e51a31, $60975133, $4562537f,
    $e0b16477, $84bb6bae, $1cfe81a0, $94f9082b,
    $58704868, $198f45fd, $8794de6c, $b7527bf8,
    $23ab73d3, $e2724b02, $57e31f8f, $2a6655ab,
    $07b2eb28, $032fb5c2, $9a86c57b, $a5d33708,
    $f2302887, $b223bfa5, $ba02036a, $5ced1682,
    $2b8acf1c, $92a779b4, $f0f307f2, $a14e69e2,
    $cd65daf4, $d50605be, $1fd13462, $8ac4a6fe,
    $9d342e53, $a0a2f355, $32058ae1, $75a4f6eb,
    $390b83ec, $aa4060ef, $065e719f, $51bd6e10,
    $f93e218a, $3d96dd06, $aedd3e05, $464de6bd,
    $b591548d, $0571c45d, $6f0406d4, $ff605015,
    $241998fb, $97d6bde9, $cc894043, $7767d99e,
    $bdb0e842, $8807898b, $38e7195b, $db79c8ee,
    $47a17c0a, $e97c420f, $c9f8841e, $00000000,
    $83098086, $48322bed, $ac1e1170, $4e6c5a72,
    $fbfd0eff, $560f8538, $1e3daed5, $27362d39,
    $640a0fd9, $21685ca6, $d19b5b54, $3a24362e,
    $b10c0a67, $0f9357e7, $d2b4ee96, $9e1b9b91,
    $4f80c0c5, $a261dc20, $695a774b, $161c121a,
    $0ae293ba, $e5c0a02a, $433c22e0, $1d121b17,
    $0b0e090d, $adf28bc7, $b92db6a8, $c8141ea9,
    $8557f119, $4caf7507, $bbee99dd, $fda37f60,
    $9ff70126, $bc5c72f5, $c544663b, $345bfb7e,
    $768b4329, $dccb23c6, $68b6edfc, $63b8e4f1,
    $cad731dc, $10426385, $40139722, $2084c611,
    $7d854a24, $f8d2bb3d, $11aef932, $6dc729a1,
    $4b1d9e2f, $f3dcb230, $ec0d8652, $d077c1e3,
    $6c2bb316, $99a970b9, $fa119448, $2247e964,
    $c4a8fc8c, $1aa0f03f, $d8567d2c, $ef223390,
    $c787494e, $c1d938d1, $fe8ccaa2, $3698d40b,
    $cfa6f581, $28a57ade, $26dab78e, $a43fadbf,
    $e42c3a9d, $0d507892, $9b6a5fcc, $62547e46,
    $c2f68d13, $e890d8b8, $5e2e39f7, $f582c3af,
    $be9f5d80, $7c69d093, $a96fd52d, $b3cf2512,
    $3bc8ac99, $a710187d, $6ee89c63, $7bdb3bbb,
    $09cd2678, $f46e5918, $01ec9ab7, $a8834f9a,
    $65e6956e, $7eaaffe6, $0821bccf, $e6ef15e8,
    $d9bae79b, $ce4a6f36, $d4ea9f09, $d629b07c,
    $af31a4b2, $312a3f23, $30c6a594, $c035a266,
    $37744ebc, $a6fc82ca, $b0e090d0, $1533a7d8,
    $4af10498, $f741ecda, $0e7fcd50, $2f1791f6,
    $8d764dd6, $4d43efb0, $54ccaa4d, $dfe49604,
    $e39ed1b5, $1b4c6a88, $b8c12c1f, $7f466551,
    $049d5eea, $5d018c35, $73fa8774, $2efb0b41,
    $5ab3671d, $5292dbd2, $33e91056, $136dd647,
    $8c9ad761, $7a37a10c, $8e59f814, $89eb133c,
    $eecea927, $35b761c9, $ede11ce5, $3c7a47b1,
    $599cd2df, $3f55f273, $791814ce, $bf73c737,
    $ea53f7cd, $5b5ffdaa, $14df3d6f, $867844db,
    $81caaff3, $3eb968c4, $2c382434, $5fc2a340,
    $72161dc3, $0cbce225, $8b283c49, $41ff0d95,
    $7139a801, $de080cb3, $9cd8b4e4, $906456c1,
    $617bcb84, $70d532b6, $74486c5c, $42d0b857
);
const Td2: ARRAY [0..255] OF cardinal = (
    $a75051f4, $65537e41, $a4c31a17, $5e963a27,
    $6bcb3bab, $45f11f9d, $58abacfa, $03934be3,
    $fa552030, $6df6ad76, $769188cc, $4c25f502,
    $d7fc4fe5, $cbd7c52a, $44802635, $a38fb562,
    $5a49deb1, $1b6725ba, $0e9845ea, $c0e15dfe,
    $7502c32f, $f012814c, $97a38d46, $f9c66bd3,
    $5fe7038f, $9c951592, $7aebbf6d, $59da9552,
    $832dd4be, $21d35874, $692949e0, $c8448ec9,
    $896a75c2, $7978f48e, $3e6b9958, $71dd27b9,
    $4fb6bee1, $ad17f088, $ac66c920, $3ab47dce,
    $4a1863df, $3182e51a, $33609751, $7f456253,
    $77e0b164, $ae84bb6b, $a01cfe81, $2b94f908,
    $68587048, $fd198f45, $6c8794de, $f8b7527b,
    $d323ab73, $02e2724b, $8f57e31f, $ab2a6655,
    $2807b2eb, $c2032fb5, $7b9a86c5, $08a5d337,
    $87f23028, $a5b223bf, $6aba0203, $825ced16,
    $1c2b8acf, $b492a779, $f2f0f307, $e2a14e69,
    $f4cd65da, $bed50605, $621fd134, $fe8ac4a6,
    $539d342e, $55a0a2f3, $e132058a, $eb75a4f6,
    $ec390b83, $efaa4060, $9f065e71, $1051bd6e,
    $8af93e21, $063d96dd, $05aedd3e, $bd464de6,
    $8db59154, $5d0571c4, $d46f0406, $15ff6050,
    $fb241998, $e997d6bd, $43cc8940, $9e7767d9,
    $42bdb0e8, $8b880789, $5b38e719, $eedb79c8,
    $0a47a17c, $0fe97c42, $1ec9f884, $00000000,
    $86830980, $ed48322b, $70ac1e11, $724e6c5a,
    $fffbfd0e, $38560f85, $d51e3dae, $3927362d,
    $d9640a0f, $a621685c, $54d19b5b, $2e3a2436,
    $67b10c0a, $e70f9357, $96d2b4ee, $919e1b9b,
    $c54f80c0, $20a261dc, $4b695a77, $1a161c12,
    $ba0ae293, $2ae5c0a0, $e0433c22, $171d121b,
    $0d0b0e09, $c7adf28b, $a8b92db6, $a9c8141e,
    $198557f1, $074caf75, $ddbbee99, $60fda37f,
    $269ff701, $f5bc5c72, $3bc54466, $7e345bfb,
    $29768b43, $c6dccb23, $fc68b6ed, $f163b8e4,
    $dccad731, $85104263, $22401397, $112084c6,
    $247d854a, $3df8d2bb, $3211aef9, $a16dc729,
    $2f4b1d9e, $30f3dcb2, $52ec0d86, $e3d077c1,
    $166c2bb3, $b999a970, $48fa1194, $642247e9,
    $8cc4a8fc, $3f1aa0f0, $2cd8567d, $90ef2233,
    $4ec78749, $d1c1d938, $a2fe8cca, $0b3698d4,
    $81cfa6f5, $de28a57a, $8e26dab7, $bfa43fad,
    $9de42c3a, $920d5078, $cc9b6a5f, $4662547e,
    $13c2f68d, $b8e890d8, $f75e2e39, $aff582c3,
    $80be9f5d, $937c69d0, $2da96fd5, $12b3cf25,
    $993bc8ac, $7da71018, $636ee89c, $bb7bdb3b,
    $7809cd26, $18f46e59, $b701ec9a, $9aa8834f,
    $6e65e695, $e67eaaff, $cf0821bc, $e8e6ef15,
    $9bd9bae7, $36ce4a6f, $09d4ea9f, $7cd629b0,
    $b2af31a4, $23312a3f, $9430c6a5, $66c035a2,
    $bc37744e, $caa6fc82, $d0b0e090, $d81533a7,
    $984af104, $daf741ec, $500e7fcd, $f62f1791,
    $d68d764d, $b04d43ef, $4d54ccaa, $04dfe496,
    $b5e39ed1, $881b4c6a, $1fb8c12c, $517f4665,
    $ea049d5e, $355d018c, $7473fa87, $412efb0b,
    $1d5ab367, $d25292db, $5633e910, $47136dd6,
    $618c9ad7, $0c7a37a1, $148e59f8, $3c89eb13,
    $27eecea9, $c935b761, $e5ede11c, $b13c7a47,
    $df599cd2, $733f55f2, $ce791814, $37bf73c7,
    $cdea53f7, $aa5b5ffd, $6f14df3d, $db867844,
    $f381caaf, $c43eb968, $342c3824, $405fc2a3,
    $c372161d, $250cbce2, $498b283c, $9541ff0d,
    $017139a8, $b3de080c, $e49cd8b4, $c1906456,
    $84617bcb, $b670d532, $5c74486c, $5742d0b8
);
const Td3: ARRAY [0..255] OF cardinal = (
    $f4a75051, $4165537e, $17a4c31a, $275e963a,
    $ab6bcb3b, $9d45f11f, $fa58abac, $e303934b,
    $30fa5520, $766df6ad, $cc769188, $024c25f5,
    $e5d7fc4f, $2acbd7c5, $35448026, $62a38fb5,
    $b15a49de, $ba1b6725, $ea0e9845, $fec0e15d,
    $2f7502c3, $4cf01281, $4697a38d, $d3f9c66b,
    $8f5fe703, $929c9515, $6d7aebbf, $5259da95,
    $be832dd4, $7421d358, $e0692949, $c9c8448e,
    $c2896a75, $8e7978f4, $583e6b99, $b971dd27,
    $e14fb6be, $88ad17f0, $20ac66c9, $ce3ab47d,
    $df4a1863, $1a3182e5, $51336097, $537f4562,
    $6477e0b1, $6bae84bb, $81a01cfe, $082b94f9,
    $48685870, $45fd198f, $de6c8794, $7bf8b752,
    $73d323ab, $4b02e272, $1f8f57e3, $55ab2a66,
    $eb2807b2, $b5c2032f, $c57b9a86, $3708a5d3,
    $2887f230, $bfa5b223, $036aba02, $16825ced,
    $cf1c2b8a, $79b492a7, $07f2f0f3, $69e2a14e,
    $daf4cd65, $05bed506, $34621fd1, $a6fe8ac4,
    $2e539d34, $f355a0a2, $8ae13205, $f6eb75a4,
    $83ec390b, $60efaa40, $719f065e, $6e1051bd,
    $218af93e, $dd063d96, $3e05aedd, $e6bd464d,
    $548db591, $c45d0571, $06d46f04, $5015ff60,
    $98fb2419, $bde997d6, $4043cc89, $d99e7767,
    $e842bdb0, $898b8807, $195b38e7, $c8eedb79,
    $7c0a47a1, $420fe97c, $841ec9f8, $00000000,
    $80868309, $2bed4832, $1170ac1e, $5a724e6c,
    $0efffbfd, $8538560f, $aed51e3d, $2d392736,
    $0fd9640a, $5ca62168, $5b54d19b, $362e3a24,
    $0a67b10c, $57e70f93, $ee96d2b4, $9b919e1b,
    $c0c54f80, $dc20a261, $774b695a, $121a161c,
    $93ba0ae2, $a02ae5c0, $22e0433c, $1b171d12,
    $090d0b0e, $8bc7adf2, $b6a8b92d, $1ea9c814,
    $f1198557, $75074caf, $99ddbbee, $7f60fda3,
    $01269ff7, $72f5bc5c, $663bc544, $fb7e345b,
    $4329768b, $23c6dccb, $edfc68b6, $e4f163b8,
    $31dccad7, $63851042, $97224013, $c6112084,
    $4a247d85, $bb3df8d2, $f93211ae, $29a16dc7,
    $9e2f4b1d, $b230f3dc, $8652ec0d, $c1e3d077,
    $b3166c2b, $70b999a9, $9448fa11, $e9642247,
    $fc8cc4a8, $f03f1aa0, $7d2cd856, $3390ef22,
    $494ec787, $38d1c1d9, $caa2fe8c, $d40b3698,
    $f581cfa6, $7ade28a5, $b78e26da, $adbfa43f,
    $3a9de42c, $78920d50, $5fcc9b6a, $7e466254,
    $8d13c2f6, $d8b8e890, $39f75e2e, $c3aff582,
    $5d80be9f, $d0937c69, $d52da96f, $2512b3cf,
    $ac993bc8, $187da710, $9c636ee8, $3bbb7bdb,
    $267809cd, $5918f46e, $9ab701ec, $4f9aa883,
    $956e65e6, $ffe67eaa, $bccf0821, $15e8e6ef,
    $e79bd9ba, $6f36ce4a, $9f09d4ea, $b07cd629,
    $a4b2af31, $3f23312a, $a59430c6, $a266c035,
    $4ebc3774, $82caa6fc, $90d0b0e0, $a7d81533,
    $04984af1, $ecdaf741, $cd500e7f, $91f62f17,
    $4dd68d76, $efb04d43, $aa4d54cc, $9604dfe4,
    $d1b5e39e, $6a881b4c, $2c1fb8c1, $65517f46,
    $5eea049d, $8c355d01, $877473fa, $0b412efb,
    $671d5ab3, $dbd25292, $105633e9, $d647136d,
    $d7618c9a, $a10c7a37, $f8148e59, $133c89eb,
    $a927eece, $61c935b7, $1ce5ede1, $47b13c7a,
    $d2df599c, $f2733f55, $14ce7918, $c737bf73,
    $f7cdea53, $fdaa5b5f, $3d6f14df, $44db8678,
    $aff381ca, $68c43eb9, $24342c38, $a3405fc2,
    $1dc37216, $e2250cbc, $3c498b28, $0d9541ff,
    $a8017139, $0cb3de08, $b4e49cd8, $56c19064,
    $cb84617b, $32b670d5, $6c5c7448, $b85742d0
);
const Td4: ARRAY [0..255] OF cardinal = (
    $52525252, $09090909, $6a6a6a6a, $d5d5d5d5,
    $30303030, $36363636, $a5a5a5a5, $38383838,
    $bfbfbfbf, $40404040, $a3a3a3a3, $9e9e9e9e,
    $81818181, $f3f3f3f3, $d7d7d7d7, $fbfbfbfb,
    $7c7c7c7c, $e3e3e3e3, $39393939, $82828282,
    $9b9b9b9b, $2f2f2f2f, $ffffffff, $87878787,
    $34343434, $8e8e8e8e, $43434343, $44444444,
    $c4c4c4c4, $dededede, $e9e9e9e9, $cbcbcbcb,
    $54545454, $7b7b7b7b, $94949494, $32323232,
    $a6a6a6a6, $c2c2c2c2, $23232323, $3d3d3d3d,
    $eeeeeeee, $4c4c4c4c, $95959595, $0b0b0b0b,
    $42424242, $fafafafa, $c3c3c3c3, $4e4e4e4e,
    $08080808, $2e2e2e2e, $a1a1a1a1, $66666666,
    $28282828, $d9d9d9d9, $24242424, $b2b2b2b2,
    $76767676, $5b5b5b5b, $a2a2a2a2, $49494949,
    $6d6d6d6d, $8b8b8b8b, $d1d1d1d1, $25252525,
    $72727272, $f8f8f8f8, $f6f6f6f6, $64646464,
    $86868686, $68686868, $98989898, $16161616,
    $d4d4d4d4, $a4a4a4a4, $5c5c5c5c, $cccccccc,
    $5d5d5d5d, $65656565, $b6b6b6b6, $92929292,
    $6c6c6c6c, $70707070, $48484848, $50505050,
    $fdfdfdfd, $edededed, $b9b9b9b9, $dadadada,
    $5e5e5e5e, $15151515, $46464646, $57575757,
    $a7a7a7a7, $8d8d8d8d, $9d9d9d9d, $84848484,
    $90909090, $d8d8d8d8, $abababab, $00000000,
    $8c8c8c8c, $bcbcbcbc, $d3d3d3d3, $0a0a0a0a,
    $f7f7f7f7, $e4e4e4e4, $58585858, $05050505,
    $b8b8b8b8, $b3b3b3b3, $45454545, $06060606,
    $d0d0d0d0, $2c2c2c2c, $1e1e1e1e, $8f8f8f8f,
    $cacacaca, $3f3f3f3f, $0f0f0f0f, $02020202,
    $c1c1c1c1, $afafafaf, $bdbdbdbd, $03030303,
    $01010101, $13131313, $8a8a8a8a, $6b6b6b6b,
    $3a3a3a3a, $91919191, $11111111, $41414141,
    $4f4f4f4f, $67676767, $dcdcdcdc, $eaeaeaea,
    $97979797, $f2f2f2f2, $cfcfcfcf, $cececece,
    $f0f0f0f0, $b4b4b4b4, $e6e6e6e6, $73737373,
    $96969696, $acacacac, $74747474, $22222222,
    $e7e7e7e7, $adadadad, $35353535, $85858585,
    $e2e2e2e2, $f9f9f9f9, $37373737, $e8e8e8e8,
    $1c1c1c1c, $75757575, $dfdfdfdf, $6e6e6e6e,
    $47474747, $f1f1f1f1, $1a1a1a1a, $71717171,
    $1d1d1d1d, $29292929, $c5c5c5c5, $89898989,
    $6f6f6f6f, $b7b7b7b7, $62626262, $0e0e0e0e,
    $aaaaaaaa, $18181818, $bebebebe, $1b1b1b1b,
    $fcfcfcfc, $56565656, $3e3e3e3e, $4b4b4b4b,
    $c6c6c6c6, $d2d2d2d2, $79797979, $20202020,
    $9a9a9a9a, $dbdbdbdb, $c0c0c0c0, $fefefefe,
    $78787878, $cdcdcdcd, $5a5a5a5a, $f4f4f4f4,
    $1f1f1f1f, $dddddddd, $a8a8a8a8, $33333333,
    $88888888, $07070707, $c7c7c7c7, $31313131,
    $b1b1b1b1, $12121212, $10101010, $59595959,
    $27272727, $80808080, $ecececec, $5f5f5f5f,
    $60606060, $51515151, $7f7f7f7f, $a9a9a9a9,
    $19191919, $b5b5b5b5, $4a4a4a4a, $0d0d0d0d,
    $2d2d2d2d, $e5e5e5e5, $7a7a7a7a, $9f9f9f9f,
    $93939393, $c9c9c9c9, $9c9c9c9c, $efefefef,
    $a0a0a0a0, $e0e0e0e0, $3b3b3b3b, $4d4d4d4d,
    $aeaeaeae, $2a2a2a2a, $f5f5f5f5, $b0b0b0b0,
    $c8c8c8c8, $ebebebeb, $bbbbbbbb, $3c3c3c3c,
    $83838383, $53535353, $99999999, $61616161,
    $17171717, $2b2b2b2b, $04040404, $7e7e7e7e,
    $babababa, $77777777, $d6d6d6d6, $26262626,
    $e1e1e1e1, $69696969, $14141414, $63636363,
    $55555555, $21212121, $0c0c0c0c, $7d7d7d7d
);
const rcon: ARRAY [0..9] OF cardinal = (
	$01000000, $02000000, $04000000, $08000000,
	$10000000, $20000000, $40000000, $80000000,
	$1B000000, $36000000
); (* for 128-bit blocks, Rijndael never uses more than 10 rcon values *)

    FUNCTION GetSet(pt: PByte; pos: cardinal): cardinal;
    BEGIN
        GetSet :=
            (cardinal(pt[pos    ]) SHL 24) +
            (cardinal(pt[pos + 1]) SHL 16) +
            (cardinal(pt[pos + 2]) SHL  8) +
             cardinal(pt[pos + 3])          ;
    END { GetSet };

    PROCEDURE PutSet(ct: PByte; pos: cardinal; st: cardinal);
    BEGIN
        ct[pos    ] := (st SHR 24);
        ct[pos + 1] := (st SHR 16) AND $FF;
        ct[pos + 2] := (st SHR  8) AND $FF;
        ct[pos + 3] := (st       ) AND $FF;
    END { PutSet };

    
    (**
     * Expand the cipher key into the encryption key schedule.
     *
     * @return    the number of rounds for the given cipher key size.
                  (assuming 128-bit i/o blocks)
     *)
    FUNCTION KeySetupEnc (VAR rk: ExpandedKey; const cipherKey: PByte; keyBits: cardinal): byte;
    { pre: keyBits in [128, 192, 256] }
        VAR temp: cardinal; 
	    i, p: byte;
    BEGIN
        p := 0;
        i := 0;
        rk[p    ] := GetSet(cipherKey,  0);
        rk[p + 1] := GetSet(cipherKey,  4);
        rk[p + 2] := GetSet(cipherKey,  8);
        rk[p + 3] := GetSet(cipherKey, 12);
        IF keyBits = 128 THEN BEGIN
            WHILE TRUE DO BEGIN
                temp := rk[p + 3];
                rk[p + 4] := rk[p] XOR
                    (Te4[(temp SHR 16) AND $FF] AND $FF000000) XOR
                    (Te4[(temp SHR  8) AND $FF] AND $00FF0000) XOR
                    (Te4[(temp       ) AND $FF] AND $0000FF00) XOR
                    (Te4[(temp SHR 24)        ] AND $000000FF) XOR
                    rcon[i];
                rk[p + 5] := rk[p + 1] XOR rk[p + 4];
                rk[p + 6] := rk[p + 2] XOR rk[p + 5];
                rk[p + 7] := rk[p + 3] XOR rk[p + 6];
                INC(i);
                IF i = 10 THEN BEGIN
                    KeySetupEnc := 10;
                    Exit;
                END { IF };
                INC(p, 4);
            END { WHILE };
        END { IF };
	
        rk[p + 4] := GetSet(cipherKey, 16);
        rk[p + 5] := GetSet(cipherKey, 20);
        IF keyBits = 192 THEN BEGIN
            WHILE TRUE DO BEGIN
                temp := rk[p + 5];
                rk[p + 6] := rk[p] XOR
                    (Te4[(temp SHR 16) AND $FF] AND $FF000000) XOR
                    (Te4[(temp SHR  8) AND $FF] AND $00FF0000) XOR
                    (Te4[(temp       ) AND $FF] AND $0000FF00) XOR
                    (Te4[(temp SHR 24)        ] AND $000000FF) XOR
                    rcon[i];
                rk[p + 7] := rk[p + 1] XOR rk[p + 6];
                rk[p + 8] := rk[p + 2] XOR rk[p + 7];
                rk[p + 9] := rk[p + 3] XOR rk[p + 8];
                INC(i);
                IF i = 8 THEN BEGIN
                    KeySetupEnc := 12;
                    Exit;
                END { IF };
                rk[p + 10] := rk[p + 4] XOR rk[p +  9];
                rk[p + 11] := rk[p + 5] XOR rk[p + 10];
                INC(p, 6);
            END { WHILE };
        END { IF };
        rk[p + 6] := GetSet(cipherKey, 24);
        rk[p + 7] := GetSet(cipherKey, 28);
        IF keyBits = 256 THEN BEGIN
            WHILE TRUE DO BEGIN
                temp := rk[p + 7];
                rk[p + 8] := rk[p] XOR
                    (Te4[(temp SHR 16) AND $FF] AND $FF000000) XOR
                    (Te4[(temp SHR  8) AND $FF] AND $00FF0000) XOR
                    (Te4[(temp       ) AND $FF] AND $0000FF00) XOR
                    (Te4[(temp SHR 24)        ] AND $000000FF) XOR
                    rcon[i];
                rk[p +  9] := rk[p + 1] XOR rk[p +  8];
                rk[p + 10] := rk[p + 2] XOR rk[p +  9];
                rk[p + 11] := rk[p + 3] XOR rk[p + 10];
                INC(i);
                IF i = 7 THEN BEGIN
                    KeySetupEnc := 14;
                    Exit;
                END { IF };
                temp := rk[p + 11];
                rk[p + 12] := rk[p + 4] XOR
                    (Te4[(temp SHR 24)        ] AND $FF000000) XOR
                    (Te4[(temp SHR 16) AND $FF] AND $00FF0000) XOR
                    (Te4[(temp SHR  8) AND $FF] AND $0000FF00) XOR
                    (Te4[(temp       ) AND $FF] AND $000000FF);
                rk[p + 13] := rk[p + 5] XOR rk[p + 12];
                rk[p + 14] := rk[p + 6] XOR rk[p + 13];
                rk[p + 15] := rk[p + 7] XOR rk[p + 14];
                INC(p, 8);
            END { WHILE };
        END { IF };
	
        KeySetupEnc := 0; (* invalid key size *)
    END { KeySetupEnc };

    (**
     * Expand the cipher key into the decryption key schedule.
     *
     * @return    the number of rounds for the given cipher key size.
     *)
    FUNCTION KeySetupDec (VAR rk: ExpandedKey; CONST cipherKey: PByte; keyBits: cardinal): byte;
        VAR temp: cardinal;
	    i, j, Nr, p: byte;
    BEGIN
        (* expand the cipher key: *)
        Nr := KeySetupEnc(rk, cipherKey, keyBits);
        (* invert the order of the round keys: *)
        i := 0; j := Nr shl 2;
   
	WHILE i < j DO BEGIN
            temp := rk[i    ]; rk[i    ] := rk[j    ]; rk[j    ] := temp;
            temp := rk[i + 1]; rk[i + 1] := rk[j + 1]; rk[j + 1] := temp;
            temp := rk[i + 2]; rk[i + 2] := rk[j + 2]; rk[j + 2] := temp;
            temp := rk[i + 3]; rk[i + 3] := rk[j + 3]; rk[j + 3] := temp;
            INC(i, 4); DEC(j, 4);
        END { WHILE };

        (* apply the inverse MixColumn transform to all round keys but the first and the last: *)  
	p := 0;
        FOR i := 1 TO Nr - 1 DO BEGIN
            INC(p, 4);
            rk[p    ] :=
                Td0[Te4[(rk[p    ] SHR 24)        ] AND $FF] XOR
                Td1[Te4[(rk[p    ] SHR 16) AND $FF] AND $FF] XOR
                Td2[Te4[(rk[p    ] SHR  8) AND $FF] AND $FF] XOR
                Td3[Te4[(rk[p    ]       ) AND $FF] AND $FF];
            rk[p + 1] :=
                Td0[Te4[(rk[p + 1] SHR 24)        ] AND $FF] XOR
                Td1[Te4[(rk[p + 1] SHR 16) AND $FF] AND $FF] XOR
                Td2[Te4[(rk[p + 1] SHR  8) AND $FF] AND $FF] XOR
                Td3[Te4[(rk[p + 1]       ) AND $FF] AND $FF];
            rk[p + 2] :=
                Td0[Te4[(rk[p + 2] SHR 24)        ] AND $FF] XOR
                Td1[Te4[(rk[p + 2] SHR 16) AND $FF] AND $FF] XOR
                Td2[Te4[(rk[p + 2] SHR  8) AND $FF] AND $FF] XOR
                Td3[Te4[(rk[p + 2]       ) AND $FF] AND $FF];
            rk[p + 3] :=
                Td0[Te4[(rk[p + 3] SHR 24)        ] AND $FF] XOR
                Td1[Te4[(rk[p + 3] SHR 16) AND $FF] AND $FF] XOR
                Td2[Te4[(rk[p + 3] SHR  8) AND $FF] AND $FF] XOR
                Td3[Te4[(rk[p + 3]       ) AND $FF] AND $FF];

        END { FOR i };
        KeySetupDec := Nr;
	
    END { KeySetupDec };

    (**
     * Encrypt a block (16 bytes) from pt at index p0 onto ct at index c0.
     *)
    PROCEDURE Encrypt (CONST rk: ExpandedKey; Nr: cardinal; CONST pt: PByte; p0: cardinal; ct: PByte; c0: cardinal);
        VAR s0, s1, s2, s3, t0, t1, t2, t3: cardinal; 
	    p,  r: byte;
    BEGIN 
        (*
         * map byte array block to cipher state
         * and add initial round key:
         *)

        s0 := GetSet(pt, p0     ) XOR rk[0];
        s1 := GetSet(pt, p0 +  4) XOR rk[1];
        s2 := GetSet(pt, p0 +  8) XOR rk[2];
        s3 := GetSet(pt, p0 + 12) XOR rk[3];
	
        (*
         * Nr - 1 full rounds:
         *)
        r := Nr DIV 2;
        p := 0;

        WHILE r <> 0 DO BEGIN
            t0 :=
                Te0[(s0 SHR 24)        ] XOR
                Te1[(s1 SHR 16) AND $FF] XOR
                Te2[(s2 SHR  8) AND $FF] XOR
                Te3[(s3       ) AND $FF] XOR
                rk[p + 4];
            t1 :=
                Te0[(s1 SHR 24)        ] XOR
                Te1[(s2 SHR 16) AND $FF] XOR
                Te2[(s3 SHR  8) AND $FF] XOR
                Te3[(s0       ) AND $FF] XOR
                rk[p + 5];
            t2 :=
                Te0[(s2 SHR 24)        ] XOR
                Te1[(s3 SHR 16) AND $FF] XOR
                Te2[(s0 SHR  8) AND $FF] XOR
                Te3[(s1       ) AND $FF] XOR
                rk[p + 6];
            t3 :=
                Te0[(s3 SHR 24)        ] XOR
                Te1[(s0 SHR 16) AND $FF] XOR
                Te2[(s1 SHR  8) AND $FF] XOR
                Te3[(s2       ) AND $FF] XOR
                rk[p + 7];

            INC(p, 8);
            DEC(r);
            IF r <> 0 THEN BEGIN
	    
            s0 :=
                Te0[(t0 SHR 24)        ] XOR
                Te1[(t1 SHR 16) AND $FF] XOR
                Te2[(t2 SHR  8) AND $FF] XOR
                Te3[(t3       ) AND $FF] XOR
                rk[p];
            s1 :=
                Te0[(t1 SHR 24)        ] XOR
                Te1[(t2 SHR 16) AND $FF] XOR
                Te2[(t3 SHR  8) AND $FF] XOR
                Te3[(t0       ) AND $FF] XOR
                rk[p + 1];
            s2 :=
                Te0[(t2 SHR 24)        ] XOR
                Te1[(t3 SHR 16) AND $FF] XOR
                Te2[(t0 SHR  8) AND $FF] XOR
                Te3[(t1       ) AND $FF] XOR
                rk[p + 2];
            s3 :=
                Te0[(t3 SHR 24)        ] XOR
                Te1[(t0 SHR 16) AND $FF] XOR
                Te2[(t1 SHR  8) AND $FF] XOR
                Te3[(t2       ) AND $FF] XOR
                rk[p + 3];
            END { IF };

        END { WHILE };

	
        (*
         * apply last round and
         * map cipher state to byte array block:
         *)
        s0 :=
            (Te4[(t0 SHR 24)        ] AND $FF000000) XOR
            (Te4[(t1 SHR 16) AND $FF] AND $00FF0000) XOR
            (Te4[(t2 SHR  8) AND $FF] AND $0000FF00) XOR
            (Te4[(t3       ) AND $FF] AND $000000FF) XOR
            rk[p];
        PutSet(ct, c0 + 0, s0);
        s1 :=
            (Te4[(t1 SHR 24)        ] AND $FF000000) XOR
            (Te4[(t2 SHR 16) AND $FF] AND $00FF0000) XOR
            (Te4[(t3 SHR  8) AND $FF] AND $0000FF00) XOR
            (Te4[(t0       ) AND $FF] AND $000000FF) XOR
            rk[p + 1];
        PutSet(ct, c0 +  4, s1);
        s2 :=
            (Te4[(t2 SHR 24)        ] AND $FF000000) XOR
            (Te4[(t3 SHR 16) AND $FF] AND $00FF0000) XOR
            (Te4[(t0 SHR  8) AND $FF] AND $0000FF00) XOR
            (Te4[(t1       ) AND $FF] AND $000000FF) XOR
            rk[p + 2];
        PutSet(ct, c0 +  8, s2);
        s3 :=
            (Te4[(t3 SHR 24)        ] AND $FF000000) XOR
            (Te4[(t0 SHR 16) AND $FF] AND $00FF0000) XOR
            (Te4[(t1 SHR  8) AND $FF] AND $0000FF00) XOR
            (Te4[(t2       ) AND $FF] AND $000000FF) XOR
            rk[p + 3];
        PutSet(ct, c0 + 12, s3);

    END { Encrypt };

    (**
     * Decrypt a block (16 bytes) from ct at index c0 onto pt at index p0.
     *)
    PROCEDURE Decrypt (CONST rk: ExpandedKey; Nr: cardinal; CONST ct: PByte; c0: cardinal; pt: PByte; p0: cardinal);
        VAR s0, s1, s2, s3, t0, t1, t2, t3: cardinal;
	    p, r: byte;
    BEGIN 
        (*
         * map byte array block to cipher state
         * and add initial round key:
         *)
        s0 := GetSet(ct, c0     ) XOR rk[0];
        s1 := GetSet(ct, c0 +  4) XOR rk[1];
        s2 := GetSet(ct, c0 +  8) XOR rk[2];
        s3 := GetSet(ct, c0 + 12) XOR rk[3];
        (*
         * Nr - 1 full rounds:
         *)
        r := Nr DIV 2;
        p := 0;
        WHILE r <> 0 DO BEGIN
            t0 :=
                Td0[(s0 SHR 24)        ] XOR
                Td1[(s3 SHR 16) AND $FF] XOR
                Td2[(s2 SHR  8) AND $FF] XOR
                Td3[(s1       ) AND $FF] XOR
                rk[p + 4];
            t1 :=
                Td0[(s1 SHR 24)        ] XOR
                Td1[(s0 SHR 16) AND $FF] XOR
                Td2[(s3 SHR  8) AND $FF] XOR
                Td3[(s2       ) AND $FF] XOR
                rk[p + 5];
            t2 :=
                Td0[(s2 SHR 24)        ] XOR
                Td1[(s1 SHR 16) AND $FF] XOR
                Td2[(s0 SHR  8) AND $FF] XOR
                Td3[(s3       ) AND $FF] XOR
                rk[p + 6];
            t3 :=
                Td0[(s3 SHR 24)        ] XOR
                Td1[(s2 SHR 16) AND $FF] XOR
                Td2[(s1 SHR  8) AND $FF] XOR
                Td3[(s0       ) AND $FF] XOR
                rk[p + 7];

            INC(p, 8);
            DEC(r);
            IF r <> 0 THEN BEGIN

            s0 :=
                Td0[(t0 SHR 24)        ] XOR
                Td1[(t3 SHR 16) AND $FF] XOR
                Td2[(t2 SHR  8) AND $FF] XOR
                Td3[(t1       ) AND $FF] XOR
                rk[p];
            s1 :=
                Td0[(t1 SHR 24)        ] XOR
                Td1[(t0 SHR 16) AND $FF] XOR
                Td2[(t3 SHR  8) AND $FF] XOR
                Td3[(t2       ) AND $FF] XOR
                rk[p + 1];
            s2 :=
                Td0[(t2 SHR 24)        ] XOR
                Td1[(t1 SHR 16) AND $FF] XOR
                Td2[(t0 SHR  8) AND $FF] XOR
                Td3[(t3       ) AND $FF] XOR
                rk[p + 2];
            s3 :=
                Td0[(t3 SHR 24)        ] XOR
                Td1[(t2 SHR 16) AND $FF] XOR
                Td2[(t1 SHR  8) AND $FF] XOR
                Td3[(t0       ) AND $FF] XOR
                rk[p + 3];
            END { IF };
        END { WHILE };
        (*
         * apply last round and
         * map cipher state to byte array block:
         *)
        s0 :=
            (Td4[(t0 SHR 24)        ] AND $FF000000) XOR
            (Td4[(t3 SHR 16) AND $FF] AND $00FF0000) XOR
            (Td4[(t2 SHR  8) AND $FF] AND $0000FF00) XOR
            (Td4[(t1       ) AND $FF] AND $000000FF) XOR
            rk[p];
        PutSet(pt, p0 + 0, s0);
        s1 :=
            (Td4[(t1 SHR 24)        ] AND $FF000000) XOR
            (Td4[(t0 SHR 16) AND $FF] AND $00FF0000) XOR
            (Td4[(t3 SHR  8) AND $FF] AND $0000FF00) XOR
            (Td4[(t2       ) AND $FF] AND $000000FF) XOR
            rk[p + 1];
        PutSet(pt, p0 +  4, s1);
        s2 :=
            (Td4[(t2 SHR 24)        ] AND $FF000000) XOR
            (Td4[(t1 SHR 16) AND $FF] AND $00FF0000) XOR
            (Td4[(t0 SHR  8) AND $FF] AND $0000FF00) XOR
            (Td4[(t3       ) AND $FF] AND $000000FF) XOR
            rk[p + 2];
        PutSet(pt, p0 +  8, s2);
        s3 :=
            (Td4[(t3 SHR 24)        ] AND $FF000000) XOR
            (Td4[(t2 SHR 16) AND $FF] AND $00FF0000) XOR
            (Td4[(t1 SHR  8) AND $FF] AND $0000FF00) XOR
            (Td4[(t0       ) AND $FF] AND $000000FF) XOR
            rk[p + 3];
        PutSet(pt, p0 + 12, s3);
    END { Decrypt };

END { unit rijndael }.
