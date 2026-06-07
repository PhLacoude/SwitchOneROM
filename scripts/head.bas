1000 rem -----
1010 rem character rom switcher
1020 rem (for one rom)
1030 rem
1040 rem (c) 2026 by philippe lacoude
1050 rem -----
1060 rem
1070 rem we need to make room for the
1080 rem copy of the character rom 
1090 rem in the ram at $3000 and the 
1100 rem screen at $5C00
1110 rem
1120 poke 55, 0 : poke 56, 52 : clr
1130 rem -----
1135 sys 58692
1140 print "character rom switcher"
1150 print : print "available roms:"
1160 print "  1: c64 original font"
1170 print "  2: apple ][ font"
1180 print "  3: zx spectrum font"
1190 print "  4: minecraft font"
1200 print "  5: aniron (tolkien)"
1210 print "  6: aurebesh (star wars)"
1220 print
1230 print "switch character rom? (";
1240 print "1 to 6, 'n' or 'q' t";
1250 input "o quit)"; a$
1270 if a$="n" or a$="q" then 3000
1280 c = val(a$)
1290 if c < 1 or 6 < c then 1220
1300 print "switching char rom to ";
1310 print "set"; c; ". . ."
2000 rem ----- 
2010 rem loading ml to memory
2130 rem ($c000 to $cfff)
2140 for i = 49152 to 53247
2150 read d : if d = -1 then 2180
2160 poke i, d
2170 next i
2180 rem -----
2190 rem we need to pass c to the ml
2200 rem code to pick the right rom
2210 poke i+20, c-1 : rem set ml
2300 rem jump to machine language code
2310 sys 49152
2320 sys 58692
2325 print "switch done!" : print
2330 print "error code: "; peek(i)
2340 print "zp 5      : "; peek(i+1)
2341 print "(0 & 0 = success)": print
2326 print "the first 16 bytes of";
2327 print " the char rom before ";
2338 print "the switch (check):"
2330 print
2350 print " @:";
2360 for j = 1 to 16
2370 print peek(i+j+1);
2380 if (j and 7)>0 or j=16 then 2410
2390 print
2400 print " a:";
2410 next j
2415 print
2420 print "(for verification only)"
2430 print
3000 rem -----
3010 rem decide to soft reset or not
3020 print 
3030 print "the ram copy of the chara";
3040 print "cter rom is "
3050 print "still there, ";
3060 print "and the ram is shrunk to"
3070 print "11,263 bytes. do you want";
3080 print " to soft "
3090 print "reset? even if you reset ";
3100 print "the system, ";
3110 print "one rom will ";
3120 print "still use the new font. ";
3130 print "(y/n)";
3140 input a$
3150 if a$ = "y" then sys 64738
3160 end
3170 rem -----