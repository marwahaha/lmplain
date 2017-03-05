# THIS FILE BELONGS TO THE METATYPE1 PACKAGE
#
# It is a converter: PostScript (``raw'') font --> METATYPE1 (METAPOST) font;
# pre-release, rather not for raw people...
# AUTHORS: JNS team, JNSteam@gust.org.pl
# HISTORY
# 0.32 (19.02.2012)  * correction 0.31 abandoned, NO STEMS and ROUND_COORD parameters
#                      added; NO_SLANT explicitly mentioned in the preamble
# 0.31 (15.01.2012)  * sanitize_name adds _ if the name ends with a digit
#                      treat dots as digits -- a correction abandoned 
# 0.30 (06.07.2009)  * right and left ghoststems handled; ghoststems need
#                      more careful handling (their negative value
#                      must not be ignored)
# 0.29 (27.02.2007)  * the keyword .SKIP.ALL. allowed in the exception file;
#                      if present, all glyphs are ignored except those listed
#                      explicitly (possibly with renaming)
# 0.28 (20.04.2006)  * banner (nowtime) touched
# 0.27 (15.07.2005)  * flex decoding fixed, banner added
# 0.26 (11.07.2005)  * adaptation to changes in fontbase (pf_info_pfm
#                      pf_info_encoding)
# 0.25 (14.05.2005)  * a bug in the interpretation of parameters of
#                      the `Space' AFM comment (``AMS convention'') fixed
# 0.24 (23.12.2004)  * formatting in flush_node changed (to avoid
#                      exponential notation)
# 0.23 (26.09.2004)  * consequently the squared value of SNAP_TO_NODE is used
# 0.22 (14.08.2003)  * adjustments to the changes in fontbase 0.44:
#                      internal METATYPE1 (i.e., sanitized) names
#                      are used in encode, LK, LP, and KP commands;
#                      no premature checking of correctness of ligatures
#                      and kerns -- it is performed prior to flushing them;
#                      only a warning is issued, because the METATYPE1 macros
#                      will handle the weird cases properly; the following
#                      situation, however, is considered acceptable:
#                          LK("a_glyph")
#                            LP("another_glyph")("yet_another_glyph")
#                            KP("another_glyph")(value)
#                          KL  
#                      since METAFONT (and METAPOST) would also accept it
#                      without complaining
# 0.21 (11.06.2003)  * a bug in adl data fixed; now ADL_DESCENDER
#                      is positive (default 250)
# 0.20 (31.03.2003)  * wrong template "pf_info_fontdimen %2d: %s"
#                      replaced by "pf_info_fontdimen %2d, %s"
#                    * comments touched
# 0.19 (26.03.2003)  * flex resolving procedure used to return curveto
#                      instead of rrcurveto; now the occurence of flex
#                      is marked (as a comment) in *.mpg
# 0.18 (19.02.2003)  * newly introduced correct_path_directions handled;
#                      accented chars are first written to an auxiliary file
#                      (GLYX) and next are appended at the end of GLYF file;
#                      emergency_turning_number is default
# 0.17 (15.02.2003)  * a lot of changes: seac handled (it is assumed
#                      that if a seac command appears in a charstring, it is
#                      the only drawing command), weird characters names
#                      sanitized, AFM checked against repeated characters
#                      (charstrings already have been checked), FontMatrix
#                      taken into account (pretty complex), the script
#                      is aware of such singular fonts as Avangarde Oblique
#                      from `Adobe 35' (although one can never be sure
#                      in such cases...); DIGIT_KERNS introduced; some
#                      clearing: a couple of  functions introduced, order
#                      of function declarations altered
# 0.16 (16.01.2003)  * adaptation to a new way of handling fontdimens in AFMs
#                      a few comments touched; ADL_*SCENDERs distinguished
#                      from AFM ones; default ADL_ASCENDER i ADL_DESCENDER
#                      set to 750 -250
# 0.15 (19.08.2002)  * fairly old bug fixed: glyphs renamed in an exception
#                      file (*.EXC) were not taken into account in kerns
#                      and ligatures
#                    * discrepancy of character sets in AFM and PFB reported
#                      (in flush_character/flush_endglyph)
# 0.14 (12--14.08.2002) a bunch of alterations:
#                    * exception file is now read implicitly, unless
#                      NO_EXC is switched to true
#                    * warn function introduced
#                    * log file is obligatorily written by mess and warn
#                    * more general (robust) routine for retrieving PFB data
#                    * a (commented) phrase for standard encqxtex/encqxwin
#                      encoding input written to *.mp file
#                    * the first and the last point of a character subpath
#                      are checked against possible inaccuracy (using
#                      SNAP_TO_NODE---see function flush_closepath)
#                    * max_line renamed to MAXL and initialised
#                    * encountering of seac did not advance the stack
#                      pointer q[0]
#                    * a few comments added, some messages touched
# 0.13 (30.07.2002)  * NO_SLANT introduced for special purposes
# 0.12 (15.09.2001)  * quitting if maformed or nonexistent AFM
#                    * ROUND_KERNS introduced
#                    * some fontbase-specific
#                    * AFM comments handled
# 0.11 (11.03.2001)  * warning issued when the char string procedure
#                      occurs twice
# 0.10 (12.01.2001)  * first numbered version
# 0.00 (Dec 2000)      first attempt
BEGIN {
# CONSOLE="/dev/tty"
# for MS-DOS you may use:
 CONSOLE="CON"
 if (MAXL=="") MAXL=78 # the longest line to be written to the console
 if (LOGF=="") LOGF=OUTF ".log" # must not be empty
 set_ASE();
 if (!NO_EXC) # do not ignore exception file
   if (EXCF=="")  get_exc(1, "pf2mt1.exc")
   else get_exc(0, EXCF)
 if (BANNER=="") BANNER="Generated by PF2MT1 utility, ver. 0.32, " nowtime()
 if (AFMF!="") get_afm();
 if (OUTF=="") OUTF="prf2mpf"
 if (MPF=="") MPF=OUTF ".mp"
 if (GLYF=="") GLYF=OUTF ".mpg"
 if (GLYX=="") GLYX=OUTF ".mpx" # temporary, for accented characters
 if (ENCF=="") ENCF=OUTF ".mpe"
 if (HEAF=="") HEAF=OUTF ".mph"
 if (LKTF=="") LKTF=OUTF ".mpl" # ligature-kern table
 if (ITALIC_SHIFT=="") ITALIC_SHIFT=0
 if (SNAP_TO_NODE=="") SNAP_TO_NODE=2
 if (ROUND_COORD=="")  {
   ROUND_COORD=8 # default; number of significant digits for de-italicized coordinates
 } else {
    ROUND_COORD=round(ROUND_COORD)
    if (ROUND_COORD<0) ROUND_COORD=0
    if (ROUND_COORD>8) ROUND_COORD=8
 }
 if (ROUND_KERNS=="")  ROUND_KERNS=0 # default: don't round kerns
 if (DIGIT_KERNS=="")  DIGIT_KERNS=1 # default: don't ignore digit kerns
 if (NO_STEMS=="")     NO_STEMS=0 # default: do flush stems
 if (NO_SLANT=="")     NO_SLANT=0 # default: de-italicize glyph; NO_SLANT!=0 means ignoring italic angle setting
 tic()
}

/^% ADL:/ {# don't override AFM info
  ADL_ASCENDER=$3; ADL_DESCENDER=$4; ADL_LINESKIP=$5
}

# in some fonts (e.g., Avangarde Oblique from `Adobe 35')
# some parameters may appear a few times
/\/version/ && !WAS_VERSION {
  WAS_VERSION=1; VERSION=get_str_val("version", $0)
}
/\/Notice/ && !WAS_AUTHOR {
  WAS_AUTHOR=1; AUTHOR=get_str_val("Notice", $0)
}
/\/FullName/ && !WAS_FULL_NAME {
  WAS_FULL_NAME=1; FULL_NAME=get_str_val("FullName", $0)
}
/\/FamilyName/ && !WAS_FAMILY_NAME {
  WAS_FAMILY_NAME=1; FAMILY_NAME=get_str_val("FamilyName", $0)
}
/\/Weight/ && !WAS_WEIGHT {
  WAS_WEIGHT=1; WEIGHT=get_str_val("Weight", $0)
}
/\/isFixedPitch/ && !WAS_FIXED_PITCH {
  WAS_FIXED_PITCH=1; FIXED_PITCH=get_num_val("isFixedPitch",$0)
}
/\/ItalicAngle/ && !WAS_ITALIC_ANGLE {# overrides AFM setting
  WAS_ITALIC_ANGLE=1
  ITALIC_ANGLE=(NO_SLANT ? 0 : get_num_val("ItalicAngle", $0))
}
/\/UnderlinePosition/ && !WAS_UNDERLINE_POSITION {# overrides AFM setting
  WAS_UNDERLINE_POSITION=1
  UNDERLINE_POSITION=get_num_val("UnderlinePosition", $0)
}
/\/UnderlineThickness/ && !WAS_UNDERLINE_THICKNESS {# overrides AFM setting
  WAS_UNDERLINE_THICKNESS=1
  UNDERLINE_THICKNESS=get_num_val("UnderlineThickness", $0)
}

/\/FontName/ && !WAS_FONT_NAME {# overrides AFM setting
  WAS_FONT_NAME=1; FONT_NAME=get_lit_val("FontName",$0)
}
/\/FontMatrix/ && !WAS_FONT_MATRIX {
  WAS_FONT_MATRIX=1; FONT_MATRIX=get_mat_val("FontMatrix", $0)
}
/\/FontBBox/ && !WAS_FONT_BOUNDING_BOX {
  WAS_FONT_BOUNDING_BOX=1; FONT_BOUNDING_BOX=get_mat_val("FontBBox", $0)
}
/\/BlueValues/ && !WAS_BLUE_VALUES {
  WAS_BLUE_VALUES=1; BLUE_VALUES=get_mat_val("BlueValues", $0)
}
/\/OtherBlues/ && !WAS_OTHER_BLUES {
  WAS_OTHER_BLUES=1; OTHER_BLUES=get_mat_val("OtherBlues",$0)
}
/\/BlueScale/ && !WAS_BLUE_SCALE {
  WAS_BLUE_SCALE=1; BLUE_SCALE=get_num_val("BlueScale", $0)
}
/\/BlueShift/ && !WAS_BLUE_SHIFT {
  WAS_BLUE_SHIFT=1; BLUE_SHIFT=get_num_val("BlueShift", $0)
}
/\/BlueFuzz/ && !WAS_BLUE_FUZZ {
  WAS_BLUE_FUZZ=1; BLUE_FUZZ=get_num_val("BlueFuzz", $0)
}
/\/UniqueID/ && !WAS_UNIQUE_ID {
  WAS_UNIQUE_ID=1; UNIQUE_ID=get_num_val("UniqueID", $0)
}
/\/StdHW/ && !WAS_STDHW {WAS_STDHW=1; STDHW=get_mat_val("StdHW", $0)}
/\/StdVW/ && !WAS_STDVW {WAS_STDVW=1; STDVW=get_mat_val("StdVW", $0)}
/\/StemSnapH/ && !WAS_STEMSNAPH {
  WAS_STEMSNAPH=1; STEMSNAPH=get_mat_val("StemSnapH", $0)
}
/\/StemSnapV/ && !WAS_STEMSNAPV {
  WAS_STEMSNAPV=1; STEMSNAPV=get_mat_val("StemSnapV", $0)
}
/\/ForceBold/ && !WAS_FORCE_BOLD {
  WAS_FORCE_BOLD=1; FORCE_BOLD=get_num_val($0)
}

/\/Subrs/ {
 # Subrs dictionary may appear a few times; presumably, it is just the
 # same dictionary repeated
 in_subrs=1; for (s in SUBRS) delete SUBRS[s]
}
/\/CharStrings/ {in_subrs=0; in_chstr=1}

in_subrs && /^[ \t]*dup[ \t]+[0-9]+[ \t]*{/ {
  n=$2
  while (getline >0) {
    if (/^[ \t]*}/) break
    SUBRS[n]=SUBRS[n] trunc_sp($0) " "
  }
}

in_chstr && /^[ \t]*\/[^ \t\/]+[ \t]*{/ {
  n=$0; sub(/^[ \t]*\//,"",n); sub(/[ \t]*{.*$/,"",n)
  if (n in EXCEPTIONS) n=EXCEPTIONS[n]
  else if (SKIPALL) n=""
  if (n!="") {
    if (n in CHRS)
     warn(n " already in char strings; the recent routine will be stored")
    else CHRN[++CHRN[0]]=n;
    s=""
    while (getline >0) {
      if (/^[ \t]*}/) break
      s=s trunc_sp($0) " "
    }
    s=resolve_subrs(n,s); sub(/ $/,"",s);
    CHRS[n]=s
  }
}

END {
  if (quitting) exit(quitting)
  SLANT=-tand(ITALIC_ANGLE)
  analyse_font_matrix(FONT_MATRIX)
  tic()
  flush_main()                                          # MP
  flush_encoding()                                      # MPE
  flush_font_info(); flush_introduce(); flush_metrics() # MPH
  flush_characters()                                    # MPG
  tic()
  flush_ligtable()                                      # MPL
  tic(); print "" > CONSOLE
  if (was_warning) print "See the transcript file " LOGF " for details" > CONSOLE
}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#   AFM   #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

function nowtime( d,m,Y,H,M,S) {
  d=strftime("%d"); m=strftime("%m"); Y=strftime("%Y")
  H=strftime("%H"); M=strftime("%M"); S=strftime("%S")
  return sprintf("%04d-%02d-%02d//%02d:%02d:%02d",Y,m,d,H,M,S)
}

function get_exc(implicit, EXCF,    e,io_res) {
  while ((io_res=(getline < EXCF)) > 0)
    if ((!/^[ \t]*$/) && (!/^[ \t]*%/)) EXCEPTIONS[$1]=$2
  if (io_res==-1) {# exception file not found (most probably)
    if (!implicit) {warn("Troubles with exception file " EXCF ":", ERRNO)}
    else if ("METATYPE1" in ENVIRON) {# no local EXCF, try global one
      EXCF=ENVIRON["METATYPE1"] "/" EXCF
      while ((io_res=getline < EXCF) > 0)
        if ((!/^[ \t]*$/) && (!/^[ \t]*%/)) EXCEPTIONS[$1]=$2
      if (io_res==-1) warn("Global exception file not found:", EXCF)
      else mess("Global exception file used:", EXCF)
    }
  } else mess("Local exception file used" (implicit ? " (implicit):" : ":"),
              EXCF)
  if (".SKIP.ALL." in EXCEPTIONS) {SKIPALL=1; delete EXCEPTIONS[".SKIP.ALL."]}
  if (SKIPALL) for (e in EXCEPTIONS) if (EXCEPTIONS[e]=="") EXCEPTIONS[e]=e
  EXCEPTIONS[".notdef"]="" # .notdef is exceptional, isn't it?
}

function get_afm( i,n,n1,n2,dn,dv,afm_num) {
  RS="(\012|\015|\012\015)"
  if (getline < AFMF <=0) {
    QUIET=0
    mess("Missing AFM file, quitting; you may wish to use pf2afm script",
      "from a Ghostscript distribution to create a ``vicar'' " AFMF);
    quitting=1; exit
  }
  if (!/^StartFontMetrics/) {
    QUIET=0
    mess(AFMF " is not an AFM file, quitting");
    quitting=1; exit
  }
  FS=" +;? *" # convenient (but cf. sanitize_name) FS for parsing AFM files
  while (getline < AFMF > 0) {
    if ($1=="UnderlineThickness") UNDERLINE_THICKNESS=$2
    if ($1=="UnderlinePosition") UNDERLINE_POSITION=$2
    if ($1=="FontName") FONT_NAME=$2
    if ($1=="CapHeight") CAP_HEIGHT=$2
    if ($1=="XHeight") X_HEIGHT=$2
    if ($1=="Ascender") ASCENDER=$2
    if ($1=="Descender") DESCENDER=$2
    if ($1=="ItalicAngle") ITALIC_ANGLE=(NO_SLANT ? 0 : $2)
    if ($1=="EncodingScheme") {
      ENCODING_SCHEME=$0; sub(/^EncodingScheme[ \t]*/,"",ENCODING_SCHEME)
    }
    if ($1=="Comment") {
      # obsolete convention:
      if ($2=="DesignSize") DESIGN_SIZE=$3
      if ($2=="SpaceParams") {SPACE=$3; SPACE_STRETCH=$5; SPACE_SHRINK=$7}
      # e.g., Comment SpaceParams 333 plus 167 minus 111
      if ($2=="Quad") QUAD=$3
      if ($2=="PFMParams") {PFM_NAME=$3; PFM_BOLD=$4; PFM_ITALIC=$5}
      # AMS convention:
      if ($2=="Space") {SPACE=$3; SPACE_STRETCH=$4; SPACE_SHRINK=$5}
      if ($2=="ExtraSpace") {EXTRA_SPACE=$3}
      # current convention:
      if ($2=="TFM") {
        if ($3=="designsize:") {
          DESIGN_SIZE=$4; print "designsize", DESIGN_SIZE > CONSOLE
        }
        if ($3=="fontdimen") {
          if ($4=="2:") SPACE=$5*(1000/DESIGN_SIZE)
          if ($4=="3:") SPACE_STRETCH=$5*(1000/DESIGN_SIZE)
          if ($4=="4:") SPACE_SHRINK=$5*(1000/DESIGN_SIZE)
          if ($4=="5:") TFM_X_HEIGHT=$5
          if ($4=="6:") QUAD=$5*(1000/DESIGN_SIZE)
          if ($4=="7:") EXTRA_SPACE=$5*(1000/DESIGN_SIZE)
          dn=$4+0 # ignore trailing colon
          if (dn>max_dimen_no) max_dimen_no=dn
          FONT_DIMEN[dn]=$5
          FONT_DIMEN_DESC[dn]=$6
          for (i=7; i<=NF; ++i) FONT_DIMEN_DESC[dn]=FONT_DIMEN_DESC[dn] " " $i
        }
      }
      if (($2=="PFM") && ($3=="parameters:"))
        {PFM_NAME=$4; PFM_BOLD=$5; PFM_ITALIC=$6; PFM_CHARSET=$7}
    }
    if ($1=="C") {
      n=$6;
      if (n in EXCEPTIONS) n=EXCEPTIONS[n]
      else if (SKIPALL) n=""
      if (n!="") {
        if (n in AFM_SET) {
           warn(n " already in metrics; the recent data will be stored")
           afm_num=AFM_SET[n]
        } else {afm_num=AFM_NUM+1; AFM_SET[n]=afm_num}
        AFM_C[afm_num]=$2
        AFM_W[afm_num]=$4
        AFM_N[afm_num]=n
        XL[afm_num]=$8
        YL[afm_num]=$9
        XH[afm_num]=$10
        YH[afm_num]=$11
        AFM_CN[AFM_C[afm_num]]=AFM_N[afm_num]
        if (AFM_C[afm_num]>Cmax) Cmax=AFM_C[afm_num]
        for (i=12; i<=NF; i+=3) {
          n1=$(i+1); n2=$(i+2);
          if ( !SKIPALL || ((n1 in EXCEPTIONS) && (n2 in EXCEPTIONS)) ) {
            if (n1 in EXCEPTIONS) n1=EXCEPTIONS[n1]
            if (n2 in EXCEPTIONS) n2=EXCEPTIONS[n2]
            if (($i=="L") && (n1!="") && (n2!="")) AFM_L[n,n1]=n2
          }
        }
        if (afm_num>AFM_NUM) AFM_NUM=afm_num
      }
    }
    if ($1 == "KPX") {
      n1=$2; n2=$3;
      if ( !SKIPALL || ((n1 in EXCEPTIONS) && (n2 in EXCEPTIONS)) ) {
        if (n1 in EXCEPTIONS) n1=EXCEPTIONS[n1]
        if (n2 in EXCEPTIONS) n2=EXCEPTIONS[n2]
      } else {n1=""; n2=""}
      if ((n1!="") && (n2!="")) {
        i=(ROUND_KERNS>0 ? round($4/ROUND_KERNS)*ROUND_KERNS : $4);
	if (i!=0) AFM_K[n1,n2]=i
      }
    }
  }
  FS=" " # restore standard FS
}

function flush_main() {
  print "% " BANNER > MPF
  print "input fontbase;" > MPF
  print "% if false if known generating: if generating=1: or true fi fi:" > MPF
  print "%  input encqxtex; else: input encqxwin;" > MPF
  print "% fi" > MPF
  print "use_emergency_turningnumber;" > MPF
  print "input " ENCF ";" > MPF
  print "maybeinput \"" HEAF "\";" > MPF
  print "beginfont"  > MPF
  print "maybeinput \"" GLYF "\";" > MPF
  print "maybeinput \"" LKTF "\";" > MPF
  print "endfont\n%%\\end\n%%%% EOF" > MPF
}

function pfm_val(x) {return (x=="" ? "*" : x )}
function pfm_qval(x) {return (pfm_val(x)=="*" ? "\"*\"" : x)}
                                                         
function flush_encoding(i) {# uses PS names
  print "% " BANNER > ENCF
  print "% ENCODING" > ENCF
  if (ENCODING_SCHEME!="") {
    if (ENCODING_SCHEME=="AdobeStandardEncoding") {
      print "pf_info_encoding" > ENCF
      print " \"AdobeStandardEncoding\", % for AFM" > ENCF
      print " \"Adobe Standard Encoding\",  % for TFM" > ENCF
      print " \"StandardEncoding\"; % for PFB "\
        "(instead of explicit encoding);" > ENCF
    }
    else print "pf_info_encoding \"" ENCODING_SCHEME "\";" > ENCF
  }
  if ((PFM_CHARSET!="") && (PFM_CHARSET!="*"))
    print "pf_info_pfm \"*\", \"*\", \"*\", \"" PFM_CHARSET "\";" > ENCF
  for (i=0; i<=255; i++) if (i in AFM_CN)
    print "encode(\"" sanitize_name(AFM_CN[i]) "\")(" i ");" > ENCF
  print "endinput" > ENCF
}

function flush_font_info(  a,i,s) {# first part of HEAF
  print "% " BANNER > HEAF
  print "% FONT INFORMATIONS" > HEAF
  print "pf_info_familyname \"" FAMILY_NAME "\";" > HEAF
  print "pf_info_weight \"" WEIGHT "\";" > HEAF
  printf "pf_info_fontname \"" FONT_NAME "\"" > HEAF
    if (FULL_NAME!=FONT_NAME) printf ", \"" FULL_NAME "\"" > HEAF
    print ";" > HEAF
  print "pf_info_version \"" VERSION "\";" > HEAF
  print "pf_info_author \"" AUTHOR "\";" > HEAF
  print "pf_info_italicangle " 0-ITALIC_ANGLE ";" > HEAF
  print "pf_info_underline " UNDERLINE_POSITION ", " UNDERLINE_THICKNESS ";" > HEAF
  if (FIXED_PITCH!="") print "pf_info_fixedpitch " FIXED_PITCH ";" > HEAF
  if (ASCENDER!="") print "pf_info_ascender " ASCENDER ";" > HEAF
  if (DESCENDER!="") print "pf_info_descender " DESCENDER ";" > HEAF
  if (ADL_ASCENDER=="") ADL_ASCENDER=750
  if (ADL_DESCENDER=="") ADL_DESCENDER=250
  if (ADL_LINESKIP=="") ADL_LINESKIP=max(0,1000-ADL_ASCENDER-ADL_DESCENDER)
  print "pf_info_adl "  ADL_ASCENDER ", " ADL_DESCENDER ", "\
    ADL_LINESKIP ";" > HEAF
  if ((pfm_val(PFM_NAME)!="*") || (pfm_val(PFM_BOLD)!="*") ||
      (pfm_val(PFM_ITALIC)!="*"))
    print "pf_info_pfm " "\"" pfm_val(PFM_NAME) "\", " pfm_qval(PFM_BOLD)\
      ", "  pfm_qval(PFM_ITALIC) ";" > HEAF
  if (FORCE_BOLD!="") print "pf_info_forcebold " FORCE_BOLD ";" > HEAF
#
  if (BLUE_FUZZ!="") print "blue_fuzz:=" BLUE_FUZZ ";" > HEAF
  if (BLUE_SCALE!="") print "blue_scale:=" BLUE_SCALE ";" > HEAF
  if (BLUE_SHIFT!="") print "blue_shift:=" BLUE_SHIFT ";" > HEAF
#
  # numbers in BLUE_VALUES and OTHER_BLUES have sometimes
  # superfluous trailing zeros, hence ``+0'':
  if (OTHER_BLUES!="") {
    a[0]=split(OTHER_BLUES,a)
    for (i=1; i<=a[0]; i+=2)
      s=s "(" y_scale(a[i+1]+0) "," y_scale(a[i]-a[i+1]) "), "
  }
  if (BLUE_VALUES!="") {
    a[0]=split(BLUE_VALUES,a)
    s=s "(" y_scale(a[2]+0) "," y_scale(a[1]-a[2]) "), "
    for (i=3; i<=a[0]; i+=2)
      s=s "(" y_scale(a[i]+0) "," y_scale(a[i+1]-a[i]) "), "
  }
  if (s=="") print "% pf_info_overshoots ???;" > HEAF
  else {
    sub(/, $/,"",s); print "pf_info_overshoots " s ";" > HEAF
  }
#
  if (DESIGN_SIZE!="") print "pf_info_designsize " DESIGN_SIZE ";" > HEAF
  if ((SPACE!="") || (SPACE_STRETCH!="") || (SPACE_SHRINK!="")) {
    if (SPACE=="") SPACE="whatever"
    if (SPACE_STRETCH=="") SPACE_STRETCH="whatever"
    if (SPACE_SHRINK=="") SPACE_SHRINK="whatever"
    print "pf_info_space " SPACE ", " SPACE_STRETCH ", "\
      SPACE_SHRINK ";" > HEAF
  }
  if (QUAD!="") print "pf_info_quad " QUAD ";" > HEAF
  if (EXTRA_SPACE!="") print "pf_info_extra_space " EXTRA_SPACE ";" > HEAF
  if (CAP_HEIGHT !="") print "pf_info_capheight " CAP_HEIGHT ";" > HEAF
  if ((X_HEIGHT=="") && (TFM_X_HEIGHT!=""))
    X_HEIGHT=TFM_X_HEIGHT*(1000/DESIGN_SIZE)
  if (X_HEIGHT!="") print "pf_info_xheight " X_HEIGHT\
    (TFM_X_HEIGHT=="" ? "" : ", " TFM_X_HEIGHT) ";" > HEAF
  print "pf_info_creationdate;" > HEAF
  print "italic_shift:=" ITALIC_SHIFT ";" > HEAF
  for (i=1; i<=max_dimen_no; ++i) if (i in FONT_DIMEN) {
    printf "pf_info_fontdimen %2d, %s", i, FONT_DIMEN[i] > HEAF
    if (FONT_DIMEN_DESC[i]!="") printf ", \"%s\"", FONT_DIMEN_DESC[i] > HEAF
    print ";" > HEAF
  }
#
  print "% UniqueID " UNIQUE_ID > HEAF
  print "% FontMatrix " FONT_MATRIX\
    (FONT_MATRIX~/^0\.001 +0(\.0)? +0(\.0)? +0\.001 +0(\.0)? +0(\.0)?/ ?\
    "" : " !!!") > HEAF
  print "% FontBBox " FONT_BOUNDING_BOX > HEAF
  print "% StdHW " STDHW > HEAF
  print "% StdVW " STDVW > HEAF
  print "% StemSnapH "  STEMSNAPH > HEAF
  print "% StemSnapV " STEMSNAPV > HEAF
}

function flush_introduce(i, n,ns) {# second part of HEAF
  print "\n% INTRODUCE CHARS" > HEAF
  for (i=1; i<=CHRN[0]; i++) {
    n=CHRN[i]; ns=sanitize_name(n)
    print "standard_introduce(\"" ns "\");" > HEAF
    if (n!=ns) print "  assign_name _" ns "(\"" n "\");" > HEAF
  }
}

function flush_metrics(  i,n) {# third and last part of HEAF
# The TeX book says: ``The result of \hbox never has negative height
# or negative depth.'' Therefore, it is unwise to assign a negative
# value to height or depth without good purpose; the exception are
# mathematical characters (e.g., an `equal' sign) for which negative
# depth makes sense. Since we do not assume using math environment
# with the fonts generated by the pf2mt1 converter, we will suppress
# all negative values (as afm2tfm does).
  print "% METRICS" > HEAF
  for (i=1; i<=AFM_NUM; i++) {
    n=sanitize_name(AFM_N[i])
    printf "wd._%s=%s; ht._%s=%s; dp._%s=%s;\n",
      n, AFM_W[i], n, nneg(YH[i]), n, -nneg(-YL[i]) > HEAF
  }
  print "endinput" > HEAF
}

function flush_ligtable(i,j,u,v,T,tt,TT) {# uses METATYPE1 (sanitized) names
# check ligtable data  
  for (i in AFM_L) {
    split(i,u,SUBSEP)
    j="Weird ligature triple: " u[1] " " u[2] " " AFM_L[i]
    if (!(u[1] in CHRS)) {warn(j); warn(" ",u[1],"is absent"); j=""}
    if (!(u[2] in CHRS)) {if (j) warn(j); warn(" ",u[2],"is absent"); j=""}
    if (!(AFM_L[i] in CHRS)) {if (j) warn(j); warn(" ",AFM_L[i],"is absent")}
  }
  for (i in AFM_K) {
    split(i,u,SUBSEP)
    j="Weird kern pair: " u[1] " " u[2] " (" AFM_K[i] ")"
    if (!(u[1] in CHRS)) {warn(j); warn(" ",u[1],"is absent"); j=""}
    if (!(u[2] in CHRS)) {if (j) warn(j); warn(" ",u[2],"is absent")}
  }
  print "% " BANNER > LKTF
  print "% LIGTABLE DATA" > LKTF
# excerpt from TOIL
# 6a: write ligatures and kerns
  for (i in AFM_L) if (AFM_L[i]!="") {
    split(i,u,SUBSEP)
    tt="LK(\"" sanitize_name(u[1]) "\")\n"
    tt=tt " LP(\"" sanitize_name(u[2]) "\")(\""\
      sanitize_name(AFM_L[i]) "\")\n"
    AFM_L[i]="" # mark used ligature
    for (j in AFM_L) if (AFM_L[j]!="") {
      split(j,v,SUBSEP)
      if (v[1]==u[1]) {
        tt=tt " LP(\"" sanitize_name(v[2]) "\")(\""\
          sanitize_name(AFM_L[j]) "\")\n"
        AFM_L[j]="" # mark used ligature
      }
    }
    T[0]=0;
    for (j in AFM_K) if (AFM_K[j]!="") {
      split(j,v,SUBSEP)
      if (v[1]==u[1]) {
      T[++T[0]]=print_kern(v,AFM_K[j]); AFM_K[j]="" # mark used kern
      }
    }
    qsort(T,1,T[0])
    for (j=1; j<=T[0]; j++) tt=tt T[j] "\n"
    TT[++TT[0]]=tt "KL;"
  }
# 6b: write remaining kerns
  for (i in AFM_K) if (AFM_K[i]!="") {
    split(i,u,SUBSEP)
    tt="LK(\"" sanitize_name(u[1]) "\")\n"
    T[0]=0; T[++T[0]]=print_kern(u,AFM_K[i]); AFM_K[i]="" # mark used kern
    for (j in AFM_K) if (AFM_K[j]!="") {
      split(j,v,SUBSEP)
      if (v[1]==u[1]) {
        T[++T[0]]=print_kern(v,AFM_K[j]); AFM_K[j]="" # mark used kern
      }
    }
    qsort(T,1,T[0])
    for (j=1; j<=T[0]; j++) tt=tt T[j] "\n"
    TT[++TT[0]]=tt "KL;"
  }
  qsort(TT,1,TT[0])
  for (i=1; i<=TT[0]; i++) print TT[i] > LKTF
  print "endinput" > LKTF
}

function print_kern(c,k){
  if (!DIGIT_KERNS && (is_digit(c[1]) || is_digit(c[1]))) k=0
  return " KP(\"" sanitize_name(c[2]) "\")(" k ")"
}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#   PFB   #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

function flush_characters(  i) {
  print "% " BANNER > GLYF
  print "% CHARACTERS\n" > GLYF
  for (i=1; i<=CHRN[0]; i++) flush_character(CHRN[i])
  close(GLYX); while (getline i < GLYX > 0) print i > GLYF; close(GLYX)
  print "endinput" > GLYF
}

function flush_character(n, n_s, a,l,m,i,j,q,w,
 vstem,hstem,width,sidebar,bb,xset,yset,max_l) {
  # n is an element of CHRN, thus never empty
  bb[0]=bb[1]=10000; bb[2]=bb[3]=-10000; max_l=-10000
  if (CHRS[n] ~ /seac/) flush_beginglyph(n, GLYX)
  else flush_beginglyph(n, GLYF)
#
  a[0]=split(CHRS[n],a)
  for (i=1; i<=a[0]; i++) {
    if (a[i]~/hsbw/) {
      width=q[q[0]--]; sidebar=q[q[0]--]; CX=sidebar; CY=0
    } else if (a[i]~/vmoveto/) {
      m=flush_closepath(n, m, l, bb, xset, yset, 0); l=0
      CY+=q[q[0]--]
      CX0=CX; CY0=CY
    } else if (a[i]~/hmoveto/) {
      m=flush_closepath(n, m, l, bb, xset, yset, 0); l=0
      CX+=q[q[0]--]
      CX0=CX; CY0=CY
    } else if (a[i]~/rmoveto/) {
      m=flush_closepath(n, m, l, bb, xset, yset, 0); l=0
      CY+=q[q[0]--]; CX+=q[q[0]--]
      CX0=CX; CY0=CY
    } else if (a[i]~/vlineto/) {
      flush_node(m, l, CX, CY, "", "\n")
      find_bb(bb,xset,yset,CX,CY)
      CY+=q[q[0]--]; l++; max_l=max(l, max_l)
    } else if (a[i]~/hlineto/) {
      flush_node(m, l, CX, CY, "", "\n")
      find_bb(bb,xset,yset,CX,CY)
      CX+=q[q[0]--]; l++; max_l=max(l, max_l)
    } else if (a[i]~/rlineto/) {
      flush_node(m, l, CX, CY, "", "\n")
      find_bb(bb,xset,yset,CX,CY)
      CY+=q[q[0]--]; CX+=q[q[0]--]; l++; max_l=max(l, max_l)
    } else if (a[i]~/vhcurveto/) {
      flush_curve(0, q[q[0]-3], q[q[0]-2], q[q[0]-1], q[q[0]], 0,
        m, l, bb, xset, yset)
      q[0]-=4; l++; max_l=max(l, max_l)
    } else if (a[i]~/hvcurveto/) {
      flush_curve(q[q[0]-3], 0, q[q[0]-2], q[q[0]-1], 0, q[q[0]],
        m, l, bb, xset, yset)
      q[0]-=4; l++; max_l=max(l, max_l)
    } else if (a[i]~/[xr]rcurveto/) {# xrcurveto denotes flex's rrcurveto
      flush_curve(q[q[0]-5], q[q[0]-4], q[q[0]-3], q[q[0]-2], q[q[0]-1],
        q[q[0]], m, l, bb, xset, yset, (a[i]~/xrcurveto/))
      q[0]-=6; l++; max_l=max(l, max_l)
    } else if (a[i]~/hstem3/) {
      w=q[q[0]--]; add_stem(hstem, w, q[q[0]--])
      w=q[q[0]--]; add_stem(hstem, w, q[q[0]--])
      w=q[q[0]--]; add_stem(hstem, w, q[q[0]--])
    } else if (a[i]~/hstem/) {
      w=q[q[0]--]; add_stem(hstem, w, q[q[0]--])
    } else if (a[i]~/vstem3/) {
      w=q[q[0]--]; add_stem(vstem, w, q[q[0]--]+sidebar)
      w=q[q[0]--]; add_stem(vstem, w, q[q[0]--]+sidebar)
      w=q[q[0]--]; add_stem(vstem, w, q[q[0]--]+sidebar)
    } else if (a[i]~/vstem/) {
      w=q[q[0]--]; add_stem(vstem, w, q[q[0]--]+sidebar)
    } else if (a[i]~/closepath/) {
      m=flush_closepath(n, m, l, bb, xset, yset, 1); l=0
    } else if (a[i]~/^seac$/) {
      if ((q[4] in ASE) && (q[5] in ASE)) {
        print " if is_stored(_" ASE[q[4]]\
          ") and is_stored(_" ASE[q[5]] "):" > GLYX
        # ``Adobe Type 1 Font format,'' ver. 1.1, p. 50: ``The origin of the
        # accent is placed at (adx, ady) relative to the origin
        # of the base character.'' We'll assume that the sidebar of the base
        # character and the composite character are the same:
        print "  use_glyph(_" ASE[q[4]] ");", "use_glyph(_" ASE[q[5]] ")",
          "(" x_scale(q[2]-q[1]+sidebar) "," y_scale(q[3]) ");" > GLYX
        print "  % |use_accent(_" ASE[q[4]] ",_" ASE[q[5]] ");|",
          "% alternative" > GLYX
        # ignored data: q[1] (side bar of accent)
        print " else:" > GLYX
        print "  if not is_stored(_" ASE[q[4]] "):" > GLYX
        print "   message \"GLYPH _" sanitize_name(n) ":",
          "_" ASE[q[4]] " not stored\";" > GLYX
        print "  fi" > GLYX
        print "  if not is_stored(_" ASE[q[5]] "):" > GLYX
        print "   message \"GLYPH _" sanitize_name(n) ":",
          "_" ASE[q[5]] " not stored\";" > GLYX
        print "  fi" > GLYX
        print " fi" > GLYX
      } else {
        print "% seac:", q[1], q[2], q[3], q[4], q[5], "% ???" > GLYX
        warn(n ": unortodox seac command encountered---ignored")
      }
      q[0]-=5
    } else if (a[i]~/^dotsection$/) {
      dotsection[n]
    } else if (a[i]~/^-?[0-9]+(.[0-9]+)?$/) {
      q[++q[0]]=a[i]
    } else warn(n ": command " a[i] " ignored")
  }
  if (n in dotsection) warn(n ": dotsection command encountered---ignored")
  m=flush_closepath(n, m, l, bb, xset, yset, 0); l=0
  if (q[0]!=0) warn(n ": " q[0] " numbers on stack at the end of the char")
  if (m>0) {
    printf " correct_path_directions(" > GLYF
    for (j=0; j<m; ++j) printf (j>0 ? "," : "") "p%d", j > GLYF
    print ")(p);\n" > GLYF
  }
  for (j=0; j<m; ++j)
    printf " if turningnumber p%d>0: Fill else: unFill fi \\\\ p%d;\n",
    j, j  > GLYF
  print ""  > GLYF
#
  flush_stems(n,vstem,hstem,bb,xset,yset,m)
  if (CHRS[n] ~ /seac/) flush_endglyph(n,width,GLYX)
  else flush_endglyph(n,width,GLYF)
}

function flush_closepath(n, m, l, bb, xset, yset, legal,    dxy) {
  if (l>0) {
    if (!legal) warn(n ": open path encountered---closed par force")
    dxy=(CX-CX0)*(CX-CX0)+(CY-CY0)*(CY-CY0)
    if ((dxy>0) && (dxy<=SNAP_TO_NODE*SNAP_TO_NODE)) {
      warn(n ": inaccurate closepath;", CX ", " CY " --> " CX0 ", " CY0)
      dxy=" % snapped (" CX "," CY ")"
      CX=CX0; CY=CY0
    } else dxy=""
    flush_node(m, l, CX, CY, "", dxy "\n")
    find_bb(bb,xset,yset,CX,CY)
    print " p" m+0 "=compose_path.z" m+0 "(" l ");\n" > GLYF
    m++
  } else if (legal) {
    warn(n ": dangling closepath in character---ignored")
  }
  return m
}

function flush_curve(dxa,dya,dxb,dyb,dxc,dyc,m,l,bb,xset,yset,flex,  b) {
  find_bb(bb,xset,yset,CX,CY)
  flush_node(m, l, CX, CY, "", "")
  b=(dxa*dxa+dya*dya<=SNAP_TO_NODE*SNAP_TO_NODE)
  if (!b) {CX+=dxa; CY+=dya}
  flush_node(m, l, CX, CY, "a", "")
  if (b) {CX+=dxa; CY+=dya}
  CX+=dxb; CY+=dyb
  b=(dxc*dxc+dyc*dyc<=SNAP_TO_NODE*SNAP_TO_NODE)
  if (b) {CX+=dxc; CY+=dyc}
  flush_node(m, l+1, CX, CY, "b", (flex ? " % flex" : "") "\n")
  if (!b) {CX+=dxc; CY+=dyc}
}

function flush_node(m,l,x,y,suffix,tail,  x_,y_) {
  x_=x_scale(x); y_=y_scale(y); x_=de_it(x_,y_)
  if (ROUND_COORD==0) x_=sprintf("%0d", round(x_)) # sprintf not necessarily employs rounding
  else {x_=sprintf("%0." ROUND_COORD "f", x_); sub(/\.?0+$/,"", x_)} # which we ignore here
  y_=sprintf("%0d", y_); # y_ coordinate is assumed to be integer
  printf(" z%d %d%s=(%s,%s);%s", m, l, suffix, x_, y_, tail) > GLYF
}

function flush_beginglyph(n, GLYF) {
  print "%% \\vfill\\break" > GLYF
  print "%% \\--------------------------------------------------------------------" > GLYF
  print "%% Construction of the character " n ":" > GLYF
  print "%% \\-" > GLYF
  print "%% Konstrukcja znaku " n ":" > GLYF
  print "%% %" > GLYF
  print "%% \\PICT{" n "}" > GLYF
  print "%% \\--------------------------------------------------------------------" > GLYF
  print "beginglyph(_" sanitize_name(n) ");" > GLYF
  print " save p; path p[];\n" > GLYF
}

function flush_endglyph(n,width,GLYF) {
  if (!(n in AFM_SET)) {
    warn(n ": present in PFB, absent from AFM")
    printf " wd._%s=%s; %% char not in AFM, wd from PFB (hsbw)\n",
      n, x_scale(width) > GLYF
  } else if (abs(x_scale(width)-AFM_W[AFM_SET[n]])>1/32)
  # the coefficient 1/32 is consistent with function rational from mp2pf.awk
    warn(n ": inconsistent widths (" sprintf("%f",x_scale(width)) "," \
      sprintf("%f",AFM_W[AFM_SET[n]]) ")")
  print " standard_exact_hsbw(\"" sanitize_name(n) "\");" > GLYF
  print "endglyph;\n" > GLYF
}

function flush_stems(n,vstem,hstem,bb,xset,yset,m, i,j,a,l,u,g) {
# l,u,g -- lists of: normal, unmatched and ghost stems, respectively
  if (NO_STEMS) return
  else {
   u=g=""
   for (i in hstem) {
     l=" fix_hstem(" y_scale(i) ")("
     for (j=0; j<m; j++) l=l (j>0?",":"") "p" j
     l=l ") candidate_list(y)("
     a[0]=split(hstem[i],a)
     for (j=1; j<=a[0]; ++j) {
       if (!(a[j] in yset) && !(a[j]+i in yset)) {
         warn(n ": non-matching hstem; " disp_hstem(a[j],i))
         u=u (u==""?"":", ") "(" y_scale(a[j]) "," y_scale(a[j]+i) ")"
       } else if ((a[j] in yset) && (a[j]+i in yset)) {
         if ((i==20) || (i==21)) {
           if (a[j]==bb[1]) g=g (g==""?"":",") "bot"
           else if (a[j]+i==bb[3]) g=g (g==""?"":",") "top"
           else {# ???
             warn(n ": odd-looking hstem (ghoststem?); " disp_gstem(a[j],i))
             l=l y_scale(a[j]) ", " y_scale(a[j]+i) ", "
           }
         } else l=l y_scale(a[j]) ", " y_scale(a[j]+i) ", "
       } else if ((i==20) || (i==21)) {
         if (a[j] in yset) {# heuresis: bot
           g=g (g==""?"":",") "bot"\
             (a[j]==bb[1] ? "" : "[" y_scale(a[j]) "]")
         } else {# heuresis: top
           g=g (g==""?"":",") "top"\
             (a[j]+i==bb[3] ? "" : "[" y_scale(a[j]+i) "]")
         }
       } else {
         warn(n ": semi-matching hstem; " disp_hstem(a[j],i))
         u=u (u==""?"":", ") "(" y_scale(a[j]) "," y_scale(a[j]+i) ")"
       }
     }
     if (sub(/, $/,"",l)>0) print breaklong(l ");")  > GLYF
   }
   if (u!="") print breaklong(" set_hstem " u ";") > GLYF
   u="";
   for (i in vstem) {
     l= " fix_vstem(" x_scale(i) ")("
     for (j=0; j<m; j++) l=l (j>0?",":"") "p" j
     l=l ") candidate_list(x" (SLANT!=0?".it":"") ")("
     a[0]=split(vstem[i],a);
     for (j=1; j<=a[0]; ++j) {
       if (!(a[j] in xset) && !(a[j]+i in xset)) {
         warn(n ": non-matching vstem; " disp_vstem(a[j],i))
         u=u (u==""?"":", ") "(" x_scale(a[j]) "," x_scale(a[j]+i) ")"
       } else if ((a[j] in xset) && (a[j]+i in xset)) {
         if ((i==20) || (i==21)) {
           if (a[j]==bb[0]) g=g (g==""?"":",") "lft"
           else if (a[j]+i==bb[2]) g=g (g==""?"":",") "rt"
           else {# ???
             warn(n ": odd-looking vstem (ghoststem?); " disp_gstem(a[j],i))
             l=l x_scale(a[j]) ", " x_scale(a[j]+i) ", "
           }
         } else l=l x_scale(a[j]) ", " x_scale(a[j]+i) ", "
       } else if ((i==20) || (i==21)) {
         if (a[j] in xset) {# heuresis: left
           g=g (g==""?"":",") "lft"\
             (a[j]==bb[0] ? "" : "[" x_scale(a[j]) "]")
         } else {# heuresis: right
           g=g (g==""?"":",") "rt"\
             (a[j]+i==bb[2] ? "" : "[" x_scale(a[j]+i) "]")
         }
       } else {
         warn(n ": semi-matching vstem; " disp_vstem(a[j],i))
         u=u (u==""?"":", ") "(" x_scale(a[j]) "," x_scale(a[j]+i) ")"
       }
     }
     if (sub(/, $/,"",l)>0) print breaklong(l ");")  > GLYF
   }
   if (u!="") print breaklong(" set_vstem " u ";") > GLYF
   if (g!="") print breaklong(" ghost_stem " g ";") > GLYF
  }
}
 
function add_stem(stem, w, x, w_, x_) {
  w_=abs(w); x_=(w<0? x+w : x)
  if ((" " stem[w_] " ") !~ (" " x_ " "))
    stem[w_]=stem[w_] (stem[w_]!=""?" ":"") x_
}

function disp_vstem(x,dx,  r) {
  r=x ", " dx
  if (fmat_xx!=0.001) r=r "; scaled: " x_scale(x) ", " x_scale(dx)
  return r
}

function disp_hstem(y,dy,  r) {
  r=y ", " dy
  if (fmat_yy!=0.001) r=r "; scaled: " y_scale(y) ", " y_scale(dy)
  return r
}

function disp_gstem(s,ds) {# ghost stem -- no scaling involved
  return s ", " ds
}

function find_bb(bb,xset,yset,x,y) {
 yset[y]++; xset[x]++
 if (x<bb[0]) bb[0]=x; if (x>bb[2]) bb[2]=x
 if (y<bb[1]) bb[1]=y; if (y>bb[3]) bb[3]=y
}

function resolve_subrs(n,s,  q,a,i,k,r) {
  a[0]=split(s,a);
  for (i=1; i<=a[0]; i++) {
    if (a[i]~/^callothersubr$/) {
      if ((q[0]!=3) || (q[q[0]]!=3) || (q[q[0]-1]!=1)) 
        warn(n ": odd `callothersub' (" q[q[0]-1] " " q[q[0]] ")")
      q[0]-=2; # skip `1 3 callothersubr';
      q[++q[0]]=10000 # dummy value; `pop' and, next, `callsubr'
                      # are expected to ensue
    } else if (a[i]~/^callsubr$/) {
      k=q[q[0]--]
      if (k==1) in_flex=1
      else if (k==0) {# flush flex series
        in_flex=0; if (q[0]!=17) warn(n ": malformed flex (" q[0] ")")
        r=r (q[1]+q[3]) " " (q[2]+q[4]) " "
        for (j=5; j<=8; j++) r=r q[j] " "; r=r "xrcurveto "
        for (j=9; j<=14; j++) r=r q[j] " "; r=r "xrcurveto "; q[0]=0
      } else if (k==2) {
        if (!in_flex) warn(n ": `2 callsubr' outside of flex series")
      } else if (k>3) {
        r=r resolve_subrs(n,SUBRS[k], q)
      }
    } else if (a[i]~/^pop$/) {
      q[0]--; if (q[0]<0) warn(n ": subr stack underflow")
    } else if (a[i]~/^div$/) {
      k=q[q[0]-1]/q[q[0]]; q[--q[0]]=k
    } else if ((a[i]~/^[rhv]moveto$/) && in_flex) {
# Adobe Type 1 Font format, ver. 1.1, p. 77 says only about `rmoveto'
# but, e.g., Adobe Palatino uses `hmoveto' and `vmoveto'
      if (a[i]~/^hmoveto$/) q[++q[0]]=0
      else if (a[i]~/^vmoveto$/) {++q[0]; q[q[0]]=q[q[0]-1]; q[q[0]-1]=0}
    } else if (a[i]~/^return$/) {} else if (a[i]~/^endchar$/) {# not needed
      if (q[0]!=0) warn(n ": " q[0] " numbers on stack at the end of the char")
    } else if (a[i]~/^[a-z]+3?$/) {
      for (j=1; j<=q[0]; j++) r=r q[j] " "; q[0]=0
      r=r a[i] " "
    } else q[++q[0]]=a[i]
  }
  return r
}

function get_str_val(r,s) {# gets PostScript string (r is the name)
  match(s,"/" r "[^\\(]*\\(.*\\)")
  s=substr(s,RSTART+1+length(r),RLENGTH-length(r)-1)
  match(s,/\(.*\)/)
  return substr(s,RSTART+1,RLENGTH-2)
}
function get_num_val(r,s) {# gets either numeric or Boolean (r is the name)
  match(s,"/" r " +[^ \t]+ ")
  return trunc_sp(substr(s,RSTART+1+length(r),RLENGTH-length(r)-1))
}
function get_lit_val(r, s) {# gets PostScript literal (r is the name)
  sub("^.*/" r "[^/]*/","",s); sub(/ .*$/,"",s); return s
}
function get_mat_val(r,s) {# gets PostScript table (r is the name)
  match(s,"/" r "[^\\[{]*[\\[{][^}\\]]*[}\\]]")
  s=substr(s,RSTART+1+length(r),RLENGTH-length(r)-1)
  match(s,/[\[{][^}\]]*[}\]]/)
  return trunc_sp(substr(s,RSTART+1,RLENGTH-2))
}

function analyse_font_matrix(FM,  a,m) {
  # Adobe Type 1 Font format, ver. 1.1, p. 26: ``The only exceptions
  # to the standard 1000 to 1 scaling matrix involve obliquing, narrowing
  # and expanding transformations applied to a font that has been originally
  # defined by a 1000 to 1 scaling matrix. Even in these cases, at least one
  # dimension of the FontMatrix will be a simple 1000 to 1 scale.''
  # (This limit is violated by FontLab 3.5 which, for fonts of TTF origin,
  # generates font matrix [0.00049 0 0 0.00049 0 0]; the exact value
  # should correspond to a 2048 to 1 matrix, namely,
  # [0.00048828125 0 0 0.00048828125 0 0].) Anyway, we'll assume that
  # if there is a non-zero `slanting' element in FontMatrix, it will be only
  # used for setting italic angle in the resulting METAYPE1 program,
  # i.e., glyphs are presumed to be `straightened' (otherwise, they are
  # straightened by de_it function). The scaling, if any, will be applied
  # at the `last minute', i.e., at the output phase, for width, node
  # coordinates (flush_node) hints (but ghost stems), and blue values
  # (only BlueValues and OtherBlues tables).
  split(FM,m);
  fmat_xx=m[1]+0; fmat_yx=m[2]+0; fmat_xy=m[3]+0; fmat_yy=m[4]+0
  # the last two entries of FontMatrix are purposedly ignored
  if (fmat_xx!=0.001) warn("Horizontal scaling in FontMatrix (" m[1] ")")
  if ((abs(1-fmat_xx*2048)>.0001) && (abs(1-fmat_xx*2048)<.005)) {
    warn("Perhaps `TrueType' scaling---value 1/2048 forced"); fmat_xx=1/2048
  }
  if (fmat_yy!=0.001) warn("Vertical scaling in FontMatrix (" m[4] ")")
  if ((abs(1-fmat_yy*2048)>.0001) && (abs(1-fmat_yy*2048)<.005)) {
    warn("Perhaps `TrueType' scaling---value 1/2048 forced"); fmat_yy=1/2048
  }
  if (fmat_yx!=0) {#
    fmat_yx=0; warn("non-zero yxpart of FontMatrix (" m[2] ")---zeroed")
  }
  if (fmat_yy==0) fmat_slant=0 # unlikely, but you never know...
  else fmat_slant=fmat_xy/fmat_yy
  if (fmat_slant!=0) {
    a=-atand(fmat_slant)
    warn("Non-zero xypart of FontMatrix (corresponds to slant angle " a ")")
    if (abs(1-(ITALIC_ANGLE/a))>.01) {
      warn("Inconsisent slants in FontMatrix (" a \
        ") and AFM/PFB (" SLANT ")---the former one used")
      SLANT=fmat_slant; ITALIC_ANGLE=a
    }
  }
}

function x_scale(x) {# ignore slant, MP will do it (see analyse_font_matrix)
  if (fmat_xx==0.001) return x
  else return round(1000*fmat_xx*x)
}

function y_scale(y) {
  if (fmat_yy==0.001) return y
  else return round(1000*fmat_yy*y)
}

function de_it(x,y) {
  return (fmat_slant!=0 ? x : x-y*SLANT-ITALIC_SHIFT)
}

function sanitize_name(n,  n0,r) {
  if (n in SANITIZED) return SANITIZED[n]
  else {
    n0=n
    gsub(/[\-\+]/,"!", n)
    gsub(/;/,"?", n) # weird: XP Arial (2001) contains something like this!
    while (match(n,/[0-9][0-9]/)) {
      r=r substr(n,1,RSTART) "_"; n=substr(n,RSTART+RLENGTH-1)
    }
    n=r n
    while (n in XANITIZED) n=n "~"; SANITIZED[n0]=n; XANITIZED[n]
    return n
  }
}

function set_ASE() {# Adobe Standard Encoding vector (for seac)
  ASE[32]="space"; ASE[33]="exclam"; ASE[34]="quotedbl";
  ASE[35]="numbersign"; ASE[36]="dollar"; ASE[37]="percent";
  ASE[38]="ampersand"; ASE[39]="quoteright"; ASE[40]="parenleft";
  ASE[41]="parenright"; ASE[42]="asterisk"; ASE[43]="plus"; ASE[44]="comma";
  ASE[45]="hyphen"; ASE[46]="period"; ASE[47]="slash"; ASE[48]="zero";
  ASE[49]="one"; ASE[50]="two"; ASE[51]="three"; ASE[52]="four";
  ASE[53]="five"; ASE[54]="six"; ASE[55]="seven"; ASE[56]="eight";
  ASE[57]="nine"; ASE[58]="colon"; ASE[59]="semicolon"; ASE[60]="less";
  ASE[61]="equal"; ASE[62]="greater"; ASE[63]="question"; ASE[64]="at";
  ASE[65]="A"; ASE[66]="B"; ASE[67]="C"; ASE[68]="D"; ASE[69]="E";
  ASE[70]="F"; ASE[71]="G"; ASE[72]="H"; ASE[73]="I"; ASE[74]="J";
  ASE[75]="K"; ASE[76]="L"; ASE[77]="M"; ASE[78]="N"; ASE[79]="O";
  ASE[80]="P"; ASE[81]="Q"; ASE[82]="R"; ASE[83]="S"; ASE[84]="T";
  ASE[85]="U"; ASE[86]="V"; ASE[87]="W"; ASE[88]="X"; ASE[89]="Y";
  ASE[90]="Z"; ASE[91]="bracketleft"; ASE[92]="backslash";
  ASE[93]="bracketright"; ASE[94]="asciicircum"; ASE[95]="underscore";
  ASE[96]="quoteleft"; ASE[97]="a"; ASE[98]="b"; ASE[99]="c"; ASE[100]="d";
  ASE[101]="e"; ASE[102]="f"; ASE[103]="g"; ASE[104]="h"; ASE[105]="i";
  ASE[106]="j"; ASE[107]="k"; ASE[108]="l"; ASE[109]="m"; ASE[110]="n";
  ASE[111]="o"; ASE[112]="p"; ASE[113]="q"; ASE[114]="r"; ASE[115]="s";
  ASE[116]="t"; ASE[117]="u"; ASE[118]="v"; ASE[119]="w"; ASE[120]="x";
  ASE[121]="y"; ASE[122]="z"; ASE[123]="braceleft"; ASE[124]="bar";
  ASE[125]="braceright"; ASE[126]="asciitilde"; ASE[161]="exclamdown";
  ASE[162]="cent"; ASE[163]="sterling"; ASE[164]="fraction"; ASE[165]="yen";
  ASE[166]="florin"; ASE[167]="section"; ASE[168]="currency";
  ASE[169]="quotesingle"; ASE[170]="quotedblleft"; ASE[171]="guillemotleft";
  ASE[172]="guilsinglleft"; ASE[173]="guilsinglright"; ASE[174]="fi";
  ASE[175]="fl"; ASE[177]="endash"; ASE[178]="dagger"; ASE[179]="daggerdbl";
  ASE[180]="periodcentered"; ASE[182]="paragraph"; ASE[183]="bullet";
  ASE[184]="quotesinglbase"; ASE[185]="quotedblbase";
  ASE[186]="quotedblright"; ASE[187]="guillemotright"; ASE[188]="ellipsis";
  ASE[189]="perthousand"; ASE[191]="questiondown"; ASE[193]="grave";
  ASE[194]="acute"; ASE[195]="circumflex"; ASE[196]="tilde";
  ASE[197]="macron"; ASE[198]="breve"; ASE[199]="dotaccent";
  ASE[200]="dieresis"; ASE[202]="ring"; ASE[203]="cedilla";
  ASE[205]="hungarumlaut"; ASE[206]="ogonek"; ASE[207]="caron";
  ASE[208]="emdash"; ASE[225]="AE"; ASE[227]="ordfeminine";
  ASE[232]="Lslash"; ASE[233]="Oslash"; ASE[234]="OE";
  ASE[235]="ordmasculine"; ASE[241]="ae"; ASE[245]="dotlessi";
  ASE[248]="lslash"; ASE[249]="oslash"; ASE[250]="oe"; ASE[251]="germandbls";
}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#   GEN   #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

function tic() {printf "." > CONSOLE}
function max(x,y) {return (x>y ? x : y)}
function abs(x) {return (x>0 ? x : -x)}
function nneg(x) {return max(x,0)}
function round(x) {return (x>0 ? int(x+.5) : -int(-x+.5))}

function is_digit(n) {# let's be explicit here; it suffices that it is used
                      # in a tricky way...
  return (n~/^(zero|one|two|three|four|five|six|seven|eight|nine)$/)
}

function trunc_sp(s) {
  gsub(/[ \t]+/," ",s); sub(/^ /,"",s); sub(/ $/,"",s); return s
}

function breaklong(s, i,r,a) {
 if (length(s)>75) {
   a[0]=split(s, a, ", "); s=a[1];
   for (i=2; i<=a[0]; ++i)
     if (length(s ", " a[i])>75) {r=r s ",\n  "; s=a[i]} else s=s ", " a[i]
   r=r s
 } else r=s
 return r
}

function warn(s1,s2,s3,s4) {# at most four parts may occur
  mess(s1,s2,s3,s4); was_warning=1
}

function mess(s1,s2,s3,s4, s) {# at most four parts may occur
  s=s1; if (s2!="") s=s " " s2; if (s3!="") s=s " " s3; if (s4!="") s=s " " s4
  if (length(s)<=MAXL) {
    if (!QUIET) print s > CONSOLE; print s > LOGF
  } else {
    if ((!QUIET) && (s1!="")) print s1 > CONSOLE
    if (s1!="") print s1 > LOGF
    if ((!QUIET) && (s2!="")) print s2 > CONSOLE
    if (s2!="") print s2 > LOGF
    if ((!QUIET) && (s3!="")) print s3 > CONSOLE
    if (s3!="") print s3 > LOGF
    if ((!QUIET) && (s4!="")) print s4 > CONSOLE
    if (s4!="") print s4 > LOGF
  }
}

# qsort -- sort A[left..right] using ``quick sort''
# (cf. ``The AWK Programming Language,'' p. 161)

function swap(A,i,j, t) {# t -- auxiliary
  t=A[i]; A[i]=A[j]; A[j]=t
}

function qsort(A,left,right, i,last) {# i, last -- auxiliary
  if (left>=right) return      # nothing to sort
  swap(A, left, left+int((right-left+1)*rand()))
  last=left                    # A[left] is a ``pivot'' element
  for (i=left+1; i<=right; i++) if (A[i]<A[left]) swap(A,++last,i)
  swap(A,left,last)
  qsort(A,left,last-1); qsort(A,last+1,right) # recurse
}

function tand(x){return sin(x/180*3.14159265)/(cos(x/180*3.14159265))}
function atand(x){return 180/3.14159265*atan2(x,1)}

