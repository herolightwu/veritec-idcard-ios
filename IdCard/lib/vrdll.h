/****************************************************************************
	File:		VRdll.h
	Updated:	2014-03-31(Mon)
 ----------------------------------------------------------------------------
		Copyright (c)  2002-2014  Veritec Iconix Ventures Inc.
		All rights reserved.
 ****************************************************************************/
#ifndef VRDLL_H
#define VRDLL_H

#if defined(_Global)
	#define _MyExtern
	//#include "windows.h" 	// trp - included to match Pulnex code
#else
	#if defined(__cplusplus)
		#define _MyExtern	extern "C"
	#else
		#define _MyExtern	extern
	#endif
#endif

//----------------------------------------------------------
// Constant Defines

// The following ifdef block is the standard way of creating macros which make exporting
// from a DLL simpler:
//
// All files within this DLL are compiled with the VRDLL_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL.
//
// ALL Win32 PROJECTS that use this DLL are compiled with the VRDLL_IMPORTS
// symbol defined on the command line.
//
// All others (UNIX and Win32-StaticLib's, for instance) leave these symbols undefined.
//
// This way any other project whose source files include this file see
// VRDLL_API functions as being imported from a DLL, wheras this DLL sees symbols
// defined with this macro as being exported.

#if defined(VRDLL_EXPORTS)
	#define VRDLL_API __declspec(dllexport)
#elif defined(VRDLL_IMPORTS)
	#define VRDLL_API __declspec(dllimport)
#else
	#define VRDLL_API
#endif
#define HIRES
#define MAXMAT  				256
//#define MAXIMAGEWIDTH  	1600
//#define MAXIMAGEHEIGHT 	1200
#define MAXIMAGEWIDTH  	1600
#define MAXIMAGEHEIGHT 	1200

#define MAXCELLS  	((MAXMAT-2)*(MAXMAT-2))
#define	MAXBLOCKS		((MAXCELLS + 63) / 64)
#define BIGBUFFSIZE (((MAXCELLS / 8) + ((MAXCELLS % 8)!=0) + 2) * 2)

#define SYM_VC 4    							// SymbolType == 0 or 4:  read VeriCode Symbols
#define SYM_QR 2    							// not active
#define SYM_DM 1                  // SymbolType == 1: read DM Symbols
#define SYM_AUTO 		(SYM_VC|SYM_DM)	// SymbolType == 5: Auto(VC or DM)

									//      -1    == CRC failure
									//      -2    == R-S failure
#define SHAPE_CHECK_ERR   -3 	// == Shape Check failure
#define NO_OBJECT_ERR     -4 	// == Nothing found failure
#define UNKNOWN_ERR       -5 	// == Unknown failure
#define BAD_FIXED_MATSIZE -7 	// == Bad Fixed Matrix Size
#define SECURITY_ERR      -9 	// == Security failure

//	Values for IsContrastNormal field
#define	Iicn_Inversed			0		//White symbol on black background
#define	Iicn_Normal				1		//Black symbol on white background
#define	Iicn_Outline			2		//Outline synmbol (edge, chrome)
#define	Iicn_Auto					3		//Auto select between black/white symbols
										//	When the value Iicn_Auto is specified,
										//	the actual contrast of the decoded symbol -- the value
										//	Iicn_Inversed or Iicn_Normal -- will be returned in
										//	'Contrast' field of 'RESULT'.

#define Max_MapCellsHori	(MAXIMAGEWIDTH  / 2) // if 2 bits per cell is allowed
#define Max_MapCellsVert	(MAXIMAGEHEIGHT / 2) // per Miles F.  2001-03-20

#define RMAX 		1000 	//=(sqrt((MAXIMAGEWIDTH*MAXIMAGEWIDTH)+(MAXIMAGEHEIGHT*MAXIMAGEHEIGHT))/2)
#define AMAX 		1024
#define SSDIV       25

// max number of error correction terms: ((70)/2)+1
#define	MAXTOEPLITZ		 37
#define MAXBUF			 256

#define Max_Objects 	 100
//----------------------------------------------------------
// Global Types for Users
typedef unsigned char PIXEL;

typedef struct {
	short IsMatrixFixed;
		//	0: Try each valid size
		//	1: Use FixedMatrixSize value
	short FixedMatrixSize;
		//	This value is valid, when IsMatrixFixed == 1
		//	Valid matrix sizes are even numbers from 12 to 48
		//	(
		//	and sizes
		//		13(=26x8), 17(=34x10), and 21(=42x12)
		//			-- Rectangular VeriCode
		//	and
		//		9(=18x8), 11(=32x8), 13(=26x12), 15(=36x12), 17(=36x16), 19(=48x16)
		//			-- Rectangular DataMatrix
		//	)
	short MarkingStyle;		// (not used)
	short IndexContrast;	// sets vcObject_thres = (## * 1024 * 5 / 100) or (0 == Auto)
	short IsContrastNormal;
		//	0: White foreground on black background (inversed contrast)
		//	1: Black on white background (normal contrast)
		//	2: Outline synmbol (edge, chrome)
	short EdacLevel;
		//	0: Auto
		//	1: 12.5%
		//	2: 25%
	short NumSymbols;		// 1 == Return first symbol found; n == concatnate upto "n" symbols
	short IsSizeFixed;  //  (not used)
	short Compression;
		//	 0: None     (8-bit)
		//	-1: Numeric  (4-bit)
		//	-2: UC Alpha (6-bit)
	double FixedSize;		//  (not used)
} SYM;

typedef struct {
	short SymbolType;
		//	0 or 4: Vericode
		//	1: 			DataMatrix
		//	5: 			Auto
	short EdgeMethod;       //  (not used)
	short SampleMethod;     //  (not used)
	short BitsPerCell;
		//	2, 4, 8, 16 (used in locate::MapHorizontal,Vert & DispObjectMap)
	short SampleWidth;      //  (used extensivly by locate)
	short AorLeft;
	short AorRight;
	short AorTop;
	short AorBottom;
		//					      g_vcAor[XS]     g_vcAor[XE]
		//					      g_vcOpt.AorLeft	g_vcOpt.AorRight
		//	g_vcAor[YE]   				��          ��
		//	g_vcOpt.AorBottom	 ��	��������������
		//							          ��          ��
		//							          ��          ��
		//	g_vcAor[YS]				    ��          ��
		//	g_vcOpt.AorTop		 ��	��������������
	short Noise;           //  (not used)
	short Prefiltering;
	short FilterSize;
		//	Ver 1.08.002v03 T3.00 or later..
		//		bit7..0 (lower byte):
		//			Shift magnitude to get contrast value.
		//			if 0 is specified, the former program logic will be valid
		//			(same as 8 is specified).
	short FilterIterations;
	short UsePacket;
	short TriggerCharacter;
	short Terminate1;
	short Terminate2;
	char  NoReadString[80];
	short Port;
	long  BaudRate;
	char  Parity;
	short DataBits;
	short StopBits;
	short NumRetry;
} OPTIONS;

typedef struct {
	short DispExtractPoints;	// used at extract if IsMatrixFixed is TRUE
	short DispObjectMap;			// draws g_vcMap on image
	short DispBorder;					// draws lines between g_vcVC_corners_sav
	short DispVericode;				// displays raw data & vecoded cells

	short DispStatistics;
	short DispAor;						// draws rectangle that shows the AOR
	short DispPlotting;				//	(not usaed)
	short Bell;
	short Control;						//	(not usaed)
	short FileMode;
	short StopOnNoRead;
	short WriteOnNoRead;
	short DispRates;
} DIAG;

typedef struct {
	short MaxImageWidth;
	short MaxImageHeight;
	short MaxMat;
	short Turns;							// count of rotations for tryall...
	double vcQualityFactor;
	long vcCorners[4][2];
	short Mirror;
	short MatrixSize;
	short numXcells;
	short numYcells;
	short Contrast;
	short EDAC;
	short vcMessageLength;
	short vcMaxCorrected;
	short BlockCorrections[MAXBLOCKS];	// num of corrections for each block
	int hits;
	short LastSymbolRead;		// Last successful symbol-type decoded (VC or DM)
	short TrySymbol;				// Symbol-type to try (for AUTO VC or DM)
#ifdef _DEBUG
	short total_steps;
	short strong[4];
	short strongr[4];
	short strongtheta[4];
	short cstrong[4];
	short cstrongr[4];
	short cstrongtheta[4];
	short sample_step;
	short angle_step;
	short sf;
	short AMax;
	short rmax;
	short RMax;
	short center_x;
	short center_y;
	unsigned char strong_rt_map[4][15][15];
#endif // _DEBUG
} RESULT;

typedef struct {
	short codetype;
	short numXcells;
	short numYcells;
	PIXEL cellmap[MAXMAT][MAXMAT];
} VERI_MARK;
	//		  col -->
	//	row     [0][0]           [0][1]        ..    [0][numXcells-1]
	//	  |	    [1][0]           [1][1]        ..    [1][numXcells-1]
	//	  V	      :                :                         :
	//		[numYcells-1][0] [numYcells-1][1] .. [numYcells-1][numXcells-1]

//----------------------------------------------------------
// API
_MyExtern VRDLL_API SYM			g_vcSym;
_MyExtern VRDLL_API OPTIONS	g_vcOpt;
_MyExtern VRDLL_API OPTIONS	g_vctmpOpt;
_MyExtern VRDLL_API DIAG		g_vcDiag;
_MyExtern VRDLL_API RESULT	g_vcRes;

_MyExtern unsigned char	bContrastShift;

//---------------------------------------------------------------------------
//	Put Vericode struct data value to library
_MyExtern VRDLL_API int PutVcStruct(
	SYM			*pPrmSym,	//	IN	SYM     value to DLL, when pointer!=NULL
	OPTIONS	*pPrmOpt,	//	IN	OPTIONS value to DLL, when pointer!=NULL
	DIAG		*pPrmDia	//	IN	DIAG    value to DLL, when pointer!=NULL
	//	If you do not want to put the value to this library, you can specify
	//	NULL pointer value.
);
//---------------------------------------------------------------------------
//	Get Vericode struct data value from library
_MyExtern VRDLL_API int GetVcStruct(
	SYM			*pPrmSym,	//	OUT	SYM     value from DLL, when pointer!=NULL
	OPTIONS	*pPrmOpt,	//	OUT	OPTIONS value from DLL, when pointer!=NULL
	DIAG		*pPrmDia,	//	OUT	DIAG    value from DLL, when pointer!=NULL
	RESULT	*pPrmRes	//	OUT	RESULT  value from DLL, when pointer!=NULL
	//	If you do not need to get the value from this library, you can specify
	//	NULL pointer value.
);

//--------------------------------------------------------------------------
//
// vcRead is the entry point to read a Vericode from an image.  This
// is what the image acquisition program calls.
//
// Input:	short xSize		x-dimension of the image
//			short ySize		y-dimension of the image
//			PIXEL *img		Pointer to the 8-bit gray scale image
//
// Output:	char *msg		Pointer to the buffer containing the
//							decoded message.
//					Terminator '\0' is appended at the end of the
//					dedoded message.
//					Max length of the decoded message is 392 bytes
//					+ 1 byte of terminator '\0'.
//					Assign BIGBUFFSIZE * 2 bytes for this area
//					for the additional temporary work area.
//
// Returns: Number of symbols decoded (default =1) or error:
//      -1 == CRC failure
//      -2 == R-S failure
//      -3 == Shape Check failure
//      -4 == Nothing found failure
//      -5 == Unknown failure
//      -7 == Bad Fixed Matrix Size
//      -9 == Security failure

_MyExtern RESULT vcRes;

_MyExtern VRDLL_API int vcRead(int xSize,int ySize,PIXEL*	img,char*	msg,
														char* 	str_pw,	char* str_id	//TF:for MAC protect
															);

//------------------------------------------------------------------------
// GetDllVersion
//
// Input:	nBufSize	length of the buffer provided for the Output string.
//
// Output:	szBuf		a string containing the software Version Number, and
//				the status of the
//						License Key ("Version x.xx.xxx - NoLicense",
//				"Version x.xx.xxx",
//                      "Version x.xx.xxx - w/Outline", or "*DEMO* x.xx.xxx".)
//
// Returns: TRUE
_MyExtern VRDLL_API int GetDllVersion(char* szBuf, int nBufSize
																			,char* str_pw			//TF:for MAC protect
																			);

_MyExtern VRDLL_API void SetMinMaxSquareLength(int nMin,int nMax,int nDiff);

//--------------------------------------------------------------------------
//  GetDllQualityFactor returns the total number of R-S bits corrected, or
//
//      -1 == CRC failure
//      -2 == R-S failure
//      -3 == Shape Check failure
//      -4 == Nothing found failure
//      -5 == Unknown failure
//      -7 == Bad Fixed Matrix Size
//      -9 == Security failure
//
//  (also present in vcRes.vcQualityFactor).
_MyExtern VRDLL_API void GetDllQualityFactor(double* pdRet);

//--------------------------------------------------------------------------
//  GetSymbolCorners returns the x & y position for the four corners
//      of the decoded symbol (also present in vcRes.vcCorners[4] [2]):
//
//               UL == 0      vcX  0
//               UR == 1      vcY  1
//               LL == 2
//               LR == 3
_MyExtern VRDLL_API void GetSymbolCorners(short vcCorners[4][2]);

//--------------------------------------------------------------------------
//  vcDecode returns the total number of R-S bits corrected, or
//
//      -1 == CRC failure
//      -2 == R-S failure
//      -3 == Parameter was null
//      -4 == Nothing found failure
//      -9 == Security failure
_MyExtern VRDLL_API int vcDecode(
		VERI_MARK*	pVm,
		char*				msg,
		char* 			str_pw			//TF:for MAC protect
);

#undef _MyExtern
#undef _Global

#endif // VRDLL_H
