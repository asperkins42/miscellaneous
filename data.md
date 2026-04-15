[D] Final demo 1-7 averaged results (3 repeats requested)
Demo   Case                   Shape        Pass AvgAccelCyc AvgTotalCyc  HW_GOPS  StreamBW  Eff       Checksum
-----  ---------------------  -----------  ---- ----------- ----------- -------- --------- -------- ----------
D1     Linear+bias+ReLU       N=64         3/3       176761     1516027    0.741       231  3210.04 0xbcf5a1d8
D1     Linear+bias+ReLU       N=128        3/3       671089     6095607    1.562       439  3559.20 0x9badf1cf
D1     Linear+bias+ReLU       N=256        3/3      4227800    26662171    1.984       527  3764.99 0x5360d3ce
D1     Linear+bias+ReLU       N=512        3/3     30956594   126919632    2.167       558  3885.00 0x9cb8332d
D1     Linear+bias+ReLU       N=1024       3/3    238041720   622188224    2.255       572  3942.93 0x9e89b5d4
D1     Linear+bias+ReLU       N=2048       3/3   1867763929  3404144149    2.299       579  3971.53 0x98fbcca3
D2     MLP2                   N=64         3/3       354746     6164336    0.738       230  3212.86 0x0c47c282
D2     MLP2                   N=128        3/3      1347477    24363204    1.556       437  3561.44 0xb766422e
D2     MLP2                   N=256        3/3      8461205   100220268    1.982       526  3769.65 0x8b3592e2
D2     MLP2                   N=512        3/3     61918291   428594561    2.167       558  3884.67 0x7dba89de
D2     MLP2                   N=1024       3/3    476089234  1954447368    2.255       572  3942.88 0x1629c593
D2     MLP2                   N=2048       3/3   3735533342  9814896448    2.299       579  3971.53 0xa79dee04
D3     Attention-ish          N=64         3/3       175556    30681602    0.746       233  3204.33 0xa5a5a5a5
D3     Attention-ish          N=128        3/3       672118   315965413    1.560       438  3561.87 0xa5a5a5a5
D3     Attention-ish          N=256        3/3      4228672  3894062179    1.983       526  3771.36 0xa5a5a5a5
D3     Attention-ish          N=512        SKIP         N/A         N/A      N/A       N/A      N/A        N/A
D3     Attention-ish          N=1024       SKIP         N/A         N/A      N/A       N/A      N/A        N/A
D3     Attention-ish          N=2048       SKIP         N/A         N/A      N/A       N/A      N/A        N/A
D4     Covariance/Gram        N=64         3/3       173496     4739575    0.755       236  3201.14 0xa5a5a5a5
D4     Covariance/Gram        N=128        3/3       670091    18809426    1.564       440  3556.40 0xa5a5a5a5
D4     Covariance/Gram        N=256        3/3      4226879    76621752    1.984       527  3765.80 0xa5a5a5a5
D4     Covariance/Gram        N=512        3/3     30955753   320251165    2.167       558  3885.10 0xa5a5a5a5
D4     Covariance/Gram        N=1024       3/3    238041033  1460718421    2.255       572  3942.95 0xa5a5a5a5
D4     Covariance/Gram        N=2048       3/3   1867763184  6756693654    2.299       579  3971.53 0xa5a5a5a5
D5     Dense GEMV proj        N=128        3/3        22404      123973    0.365       788   464.01 0x11681554
D5     Dense GEMV proj        N=256        3/3        44667      169332    0.733      1524   481.36 0xaace45c5
D5     Dense GEMV proj        N=512        3/3       142050      317833    0.922      1881   490.54 0x1602c74e
D5     Dense GEMV proj        N=1024       3/3       519933      788929    1.008      2036   495.27 0x12cc7261
D5     Dense GEMV proj        N=2048       3/3      2028273     2483963    1.033      2078   497.56 0xddf7cbb8
D6     Sparse SpMV agg        512x33792    3/3       872818         N/A    1.485      6076   244.50 0x68327357
D7     Sparse SpMM linear     512x33792x4  3/3      3139303         N/A    1.652      6751   244.72 0x10eaeb91

[D] AvgAccelCyc is the accelerated kernel portion: GEMM/GEMV/CSR HW cycles.
[D] AvgTotalCyc is only printed for demos with a measured post-kernel path.
[D] Demo 3 is capped at N<=256 here because Q*K^T is still a softcore O(N^3) loop.

[W] Software-vs-hardware speedup summary
Case                   Shape        HWAvgTotal   SW1xTotal    Speedup   Checksum    Note
---------------------  -----------  -----------  -----------  --------  ----------  ----------------
Linear+bias+ReLU       N=32                 N/A      1509789       N/A  0xb828d5e8  HW N/A
Linear+bias+ReLU       N=64             1516027    100865287    66.5x  0xbcf5a1d8  
Linear+bias+ReLU       N=128            6095607    797417508   130.8x  0x9badf1cf  
Linear+bias+ReLU       N=256           26662171   6339147454   237.7x  0x5360d3ce  
Linear+bias+ReLU       N=512          126919632  51517579123   405.9x  0x9cb8332d  
Linear+bias+ReLU       N=1024         622188224  411500021330   661.3x  0x9e89b5d4  
Linear+bias+ReLU       N=2048        3404144149  3693042100447  1084.8x  0x98fbcca3  
Linear+bias+ReLU       N=4096               N/A          N/A       N/A         N/A  skip: scratch cap
Linear+bias+ReLU       N=8192               N/A          N/A       N/A         N/A  skip: scratch cap

MLP2                   N=32                 N/A      2884404       N/A  0xc18a9969  HW N/A
MLP2                   N=64             6164336    201199738    32.6x  0x0c47c282  
MLP2                   N=128           24363204   1591866051    65.3x  0xb766422e  
MLP2                   N=256          100220268  12666997475   126.3x  0x8b3592e2  
MLP2                   N=512          428594561  102932179647   240.1x  0x7dba89de  
MLP2                   N=1024        1954447368  822447777230   420.8x  0x1629c593  
MLP2                   N=2048        9814896448  7385375070984   752.4x  0xa79dee04  
MLP2                   N=4096               N/A          N/A       N/A         N/A  skip: scratch cap
MLP2                   N=8192               N/A          N/A       N/A         N/A  skip: scratch cap

Attention-ish          N=32                 N/A      2994182       N/A  0xa5a5a5a5  HW N/A
Attention-ish          N=64            30681602    127867026     4.1x  0xa5a5a5a5  
Attention-ish          N=128          315965413   1097998398     3.4x  0xa5a5a5a5  
Attention-ish          N=256         3894062179  10167608438     2.6x  0xa5a5a5a5  
Attention-ish          N=512                N/A          N/A       N/A         N/A  skip: O(N^3) cap
Attention-ish          N=1024               N/A          N/A       N/A         N/A  skip: O(N^3) cap
Attention-ish          N=2048               N/A          N/A       N/A         N/A  skip: O(N^3) cap
Attention-ish          N=4096               N/A          N/A       N/A         N/A  skip: O(N^3) cap
Attention-ish          N=8192               N/A          N/A       N/A         N/A  skip: O(N^3) cap

Covariance/Gram        N=32                 N/A      1758941       N/A  0xa5a5a5a5  HW N/A
Covariance/Gram        N=64             4739575    101993726    21.5x  0xa5a5a5a5  
Covariance/Gram        N=128           18809426    801681623    42.6x  0xa5a5a5a5  
Covariance/Gram        N=256           76621752   6355378984    82.9x  0xa5a5a5a5  
Covariance/Gram        N=512          320251165  51575483805   161.0x  0xa5a5a5a5  
Covariance/Gram        N=1024        1460718421  411811134081   281.9x  0xa5a5a5a5  
Covariance/Gram        N=2048        6756693654  3694322692748   546.7x  0xa5a5a5a5  
Covariance/Gram        N=4096               N/A          N/A       N/A         N/A  skip: scratch cap
Covariance/Gram        N=8192               N/A          N/A       N/A         N/A  skip: scratch cap

Dense GEMV proj        N=32                 N/A        44553       N/A  0xd1caf642  HW N/A
Dense GEMV proj        N=64                 N/A       118970       N/A  0xfe8bcb8c  HW N/A
Dense GEMV proj        N=128             123973       366340     2.9x  0x9e324f0b  
Dense GEMV proj        N=256             169332      1260755     7.4x  0x25941f9a  
Dense GEMV proj        N=512             317833      4596166    14.4x  0x99589d11  
Dense GEMV proj        N=1024            788929     17591102    22.2x  0x9d96283e  
Dense GEMV proj        N=2048           2483963    256591941   103.2x  0x52ad91e7  
Dense GEMV proj        N=4096               N/A   1024361816       N/A  0xda643e13  HW N/A
Dense GEMV proj        N=8192               N/A   4093443060       N/A  0x157e6da8  HW N/A

[O] Final averaged results (3 repeats requested)
Kernel      Case           Shape             Den Pass AvgHWcyc    HW_GOPS  StreamBW  StreamEff CanonEff  AvgSWcyc    Speedup
----------  -------------  ----------------  --- ---- ----------- -------- --------- ---------- --------- ----------- -------
GEMV        dense-1024     N=1024              - 3/3       519634    1.008      2147     469.93    469.93         N/A     N/A
GEMV        dense-2048     N=2048              - 3/3      2026993    1.034      2200     470.27    470.27         N/A     N/A
GEMV        dense-4096     N=4096              - 3/3      8036830    1.043      2219     470.37    470.37         N/A     N/A
GEMV        dense-8192     N=8192              - 3/3     32037476    1.047      2226     470.50    470.50         N/A     N/A
GEMV        dense-16384    N=16384             - 3/3    127961841    1.048      2229     470.56    470.56         N/A     N/A
GEMM        dense-512      N=512               - 3/3     30877440    2.173       560    3881.05   3881.05         N/A     N/A
GEMM        dense-1024     N=1024              - 3/3    237961982    2.256       572    3944.26   3944.26         N/A     N/A
GEMM        dense-2048     N=2048              - 3/3   1867683624    2.299       579    3971.70   3971.70         N/A     N/A
GEMM        dense-4096     N=4096              - 3/3  14797629149    2.321       582    3989.63   3989.63         N/A     N/A
GEMM        dense-8192     N=8192              - 3/3  117805885111    2.333       584    3995.39   3995.39         N/A     N/A
CSR-SpMV    xfmr-50        512x33792          50 3/3      2790868    1.549      6253     247.87    166.66  4156396480 1489.2x
CSR-SpMV    xfmr-60        512x33792          40 3/3      2241114    1.544      6237     247.62    166.66  3473867037 1550.0x
CSR-SpMV    xfmr-70        512x33792          30 3/3      1691765    1.534      6216     246.83    166.66  2765965352 1634.9x
CSR-SpMV    xfmr-80        512x33792          20 3/3      1142599    1.514      6185     244.88    166.65  2001847685 1752.0x
CSR-SpMV    xfmr-90        512x33792          10 3/3       593375    1.457      6123     238.06    166.62  1114775307 1878.7x
CSR-SpMV    xfmr-95        512x33792           5 3/3       318777    1.355      5782     234.36    166.57   595447633 1867.9x
CSR-SpMM    xfmr-50-N4     512x33792x4        50 3/3     10349048    1.671      6744     247.91    333.32 22776557665 2200.8x
CSR-SpMM    xfmr-60-N4     512x33792x4        40 3/3      8285069    1.671      6747     247.67    333.34 18709150130 2258.1x
CSR-SpMM    xfmr-70-N4     512x33792x4        30 3/3      6227487    1.667      6752     246.92    333.32 14391384649 2310.9x
CSR-SpMM    xfmr-80-N4     512x33792x4        20 3/3      4169782    1.660      6774     245.07    333.29  9840017565 2359.8x
CSR-SpMM    xfmr-90-N4     512x33792x4        10 3/3      2107866    1.641      6886     238.36    333.20  5040453767 2391.2x
CSR-SpMM    xfmr-95-N4     512x33792x4         5 3/3      1071564    1.612      6863     234.95    333.08  2548863313 2378.6x

[O] StreamBW is estimated MB/s from the bytes actually streamed by the HW path.
[O] CanonEff uses canonical dense/CSR byte accounting; CSR RHS prejoin time is not included in HW cycles.

### HBM (SOFTWARE ONLY)

[A] Combined paper-comparison benchmark suite
[A] Phase 1 runs the software-only baseline sweep (w).
[A] Phase 2 runs the exhaustive offloaded comparison sweep (W).

[w] Software-only paper-comparison benchmark suite
[w] This suite mirrors the W-paper sweep but runs each case once and never issues CFU/HW commands.
[w] Large dense software cases can take a very long time on the softcore.

[w] Phase 1: kernel software baselines (1x each)
[w] SW GEMM kernel sweep is capped at N<=2048 to keep softcore runtime reasonable.
Kernel      Case           Shape             Den      SW1xCyc   SW_GOPS  CanonEff   Checksum
----------  -------------  ----------------  ---  -----------  --------  --------  ----------
[w][perf] SW GEMV N=1024 cyc=18944790 GOPS=0.027 checksum=0xb1dbc34d
GEMV        dense-1024     N=1024              -     18944790     0.027     477.06  0xb1dbc34d
[w][perf] SW GEMV N=2048 cyc=256042405 GOPS=0.008 checksum=0xff1001c9
GEMV        dense-2048     N=2048              -    256042405     0.008     481.76  0xff1001c9
[w][perf] SW GEMV N=4096 cyc=1023846316 GOPS=0.008 checksum=0xcb2b0fbe
GEMV        dense-4096     N=4096              -   1023846316     0.008     481.76  0xcb2b0fbe
[w][perf] SW GEMV N=8192 cyc=4092927407 GOPS=0.008 checksum=0xff833018
GEMV        dense-8192     N=8192              -   4092927407     0.008     481.76  0xff833018
[w][perf] SW GEMV N=16384 cyc=16365260965 GOPS=0.008 checksum=0x6a154d60
GEMV        dense-16384    N=16384             -  16365260965     0.008     482.35  0x6a154d60
[w][perf] SW GEMM N=512 cyc=49936475513 GOPS=0.001 checksum=0x3e91001c
GEMM        dense-512      N=512               -  49936475513     0.001       0.00  0x3e91001c
[w][perf] SW GEMM N=1024 cyc=399475815900 GOPS=0.001 checksum=0xaab07d3b
GEMM        dense-1024     N=1024              -  399475815900     0.001       0.00  0xaab07d3b
[w][perf] SW GEMM N=2048 cyc=3259943732918 GOPS=0.001 checksum=0x5191dd1d
GEMM        dense-2048     N=2048              -  3259943732918     0.001       0.00  0x5191dd1d
GEMM        dense-4096     N=4096              -          N/A       N/A       N/A         cap
GEMM        dense-8192     N=8192              -          N/A       N/A       N/A         cap
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=50% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1956430773 cyc GOPS=0.002 checksum=0x9ca64d72
CSR-SpMV    xfmr-50        512x33792          50   1956430773     0.002     170.00  0x9ca64d72
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=40% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1705931344 cyc GOPS=0.002 checksum=0x3e004e8d
CSR-SpMV    xfmr-60        512x33792          40   1705931344     0.002     168.33  0x3e004e8d
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=30% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1435359059 cyc GOPS=0.001 checksum=0xaf75d5d4
CSR-SpMV    xfmr-70        512x33792          30   1435359059     0.001     180.00  0xaf75d5d4
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=20% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1113767818 cyc GOPS=0.001 checksum=0xe600e581
CSR-SpMV    xfmr-80        512x33792          20   1113767818     0.001     172.22  0xe600e581
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=10% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=673474732 cyc GOPS=0.001 checksum=0x515403b1
CSR-SpMV    xfmr-90        512x33792          10    673474732     0.001     182.85  0x515403b1
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=5% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=375675655 cyc GOPS=0.001 checksum=0x1ea9af7a
CSR-SpMV    xfmr-95        512x33792           5    375675655     0.001     190.00  0x1ea9af7a
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=50% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=13988196540 cyc GOPS=0.001 checksum=0x0505057e
CSR-SpMM    xfmr-50-N4     512x33792x4        50  13988196540     0.001     410.00  0x0505057e
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=40% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=11674020271 cyc GOPS=0.001 checksum=0xec604139
CSR-SpMM    xfmr-60-N4     512x33792x4        40  11674020271     0.001     393.33  0xec604139
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=30% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=9113790140 cyc GOPS=0.001 checksum=0xb42cc209
CSR-SpMM    xfmr-70-N4     512x33792x4        30   9113790140     0.001     376.66  0xb42cc209
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=20% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=6316010589 cyc GOPS=0.001 checksum=0xdd4c3ed7
CSR-SpMM    xfmr-80-N4     512x33792x4        20   6316010589     0.001     363.33  0xdd4c3ed7
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=10% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=3276326057 cyc GOPS=0.001 checksum=0xb844c84f
CSR-SpMM    xfmr-90-N4     512x33792x4        10   3276326057     0.001     350.00  0xb844c84f
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=5% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=1666450044 cyc GOPS=0.001 checksum=0xd9ee6046
CSR-SpMM    xfmr-95-N4     512x33792x4         5   1666450044     0.001     343.33  0xd9ee6046

[w] Phase 2: demo software baselines (1x each)
Case                   Shape        SW1xTotal    SW_GOPS    Checksum    Note
---------------------  -----------  -----------  ---------  ----------  ----------------
Linear+bias+ReLU       N=32             1502485      0.010  0xb828d5e8  
Linear+bias+ReLU       N=64           101018645      0.001  0xbcf5a1d8  
Linear+bias+ReLU       N=128          797905586      0.001  0x9badf1cf  
Linear+bias+ReLU       N=256         6394188405      0.001  0x5360d3ce  
Linear+bias+ReLU       N=512        51524183103      0.001  0x9cb8332d  
Linear+bias+ReLU       N=1024       411545475961      0.001  0x9e89b5d4  
Linear+bias+ReLU       N=2048       3693067627261      0.001  0x98fbcca3  
Linear+bias+ReLU       N=4096               N/A        N/A         N/A  skip: scratch cap
Linear+bias+ReLU       N=8192               N/A        N/A         N/A  skip: scratch cap

MLP2                   N=32             2890380      0.011  0xc18a9969  
MLP2                   N=64           201564206      0.001  0x0c47c282  
MLP2                   N=128         1593808986      0.001  0xb766422e  
MLP2                   N=256        12779519994      0.001  0x8b3592e2  
MLP2                   N=512        103006338037      0.001  0x7dba89de  


### DDR (SOFTWARE ONLY)

[w] Software-only paper-comparison benchmark suite
[w] This suite mirrors the W-paper sweep but runs each case once and never issues CFU/HW commands.
[w] Large dense software cases can take a very long time on the softcore.

[w] Phase 1: kernel software baselines (1x each)
[w] SW GEMM kernel sweep is capped at N<=2048 to keep softcore runtime reasonable.
Kernel      Case           Shape             Den      SW1xCyc   SW_GOPS  CanonEff   Checksum
----------  -------------  ----------------  ---  -----------  --------  --------  ----------
[w][perf] SW GEMV N=1024 cyc=18915373 GOPS=0.027 checksum=0xb1dbc34d
GEMV        dense-1024     N=1024              -     18915373     0.027     469.66  0xb1dbc34d
[w][perf] SW GEMV N=2048 cyc=86033465 GOPS=0.024 checksum=0xff1001c9
GEMV        dense-2048     N=2048              -     86033465     0.024     477.84  0xff1001c9
[w][perf] SW GEMV N=4096 cyc=361539803 GOPS=0.023 checksum=0xcb2b0fbe
GEMV        dense-4096     N=4096              -    361539803     0.023     473.46  0xcb2b0fbe
[w][perf] SW GEMV N=8192 cyc=1446018391 GOPS=0.023 checksum=0xff833018
GEMV        dense-8192     N=8192              -   1446018391     0.023     473.46  0xff833018
[w][perf] SW GEMV N=16384 cyc=5783574445 GOPS=0.023 checksum=0x6a154d60
GEMV        dense-16384    N=16384             -   5783574445     0.023     473.46  0x6a154d60
[w][perf] SW GEMM N=512 cyc=7150147955 GOPS=0.009 checksum=0x3e91001c
GEMM        dense-512      N=512               -   7150147955     0.009    4690.00  0x3e91001c
[w][perf] SW GEMM N=1024 cyc=59925023245 GOPS=0.008 checksum=0xaab07d3b
GEMM        dense-1024     N=1024              -  59925023245     0.008    4475.00  0xaab07d3b
[w][perf] SW GEMM N=2048 cyc=503370173829 GOPS=0.008 checksum=0x5191dd1d
GEMM        dense-2048     N=2048              -  503370173829     0.008    4265.00  0x5191dd1d
GEMM        dense-4096     N=4096              -          N/A       N/A       N/A         cap
GEMM        dense-8192     N=8192              -          N/A       N/A       N/A         cap
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=50% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=327313275 cyc GOPS=0.013 checksum=0x9ca64d72
CSR-SpMV    xfmr-50        512x33792          50    327313275     0.013     167.21  0x9ca64d72
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=40% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=271879552 cyc GOPS=0.012 checksum=0x3e004e8d
CSR-SpMV    xfmr-60        512x33792          40    271879552     0.012     167.50  0x3e004e8d
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=30% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=216749601 cyc GOPS=0.011 checksum=0xaf75d5d4
CSR-SpMV    xfmr-70        512x33792          30    216749601     0.011     168.59  0xaf75d5d4
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=20% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=158145062 cyc GOPS=0.010 checksum=0xe600e581
CSR-SpMV    xfmr-80        512x33792          20    158145062     0.010     168.30  0xe600e581
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=10% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=90859292 cyc GOPS=0.009 checksum=0x515403b1
CSR-SpMV    xfmr-90        512x33792          10     90859292     0.009     166.84  0x515403b1
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=5% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=50011897 cyc GOPS=0.008 checksum=0x1ea9af7a
CSR-SpMV    xfmr-95        512x33792           5     50011897     0.008     169.21  0x1ea9af7a
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=50% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=1857759386 cyc GOPS=0.009 checksum=0x0505057e
CSR-SpMM    xfmr-50-N4     512x33792x4        50   1857759386     0.009     344.81  0x0505057e
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=40% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=1544179997 cyc GOPS=0.008 checksum=0xec604139
CSR-SpMM    xfmr-60-N4     512x33792x4        40   1544179997     0.008     344.61  0xec604139
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=30% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=1205437490 cyc GOPS=0.008 checksum=0xb42cc209
CSR-SpMM    xfmr-70-N4     512x33792x4        30   1205437490     0.008     344.40  0xb42cc209
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=20% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=839224607 cyc GOPS=0.008 checksum=0xdd4c3ed7
CSR-SpMM    xfmr-80-N4     512x33792x4        20    839224607     0.008     343.33  0xdd4c3ed7
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=10% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=438841192 cyc GOPS=0.007 checksum=0xb844c84f
CSR-SpMM    xfmr-90-N4     512x33792x4        10    438841192     0.007     342.60  0xb844c84f
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=5% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=224667335 cyc GOPS=0.007 checksum=0xd9ee6046
CSR-SpMM    xfmr-95-N4     512x33792x4         5    224667335     0.007     334.34  0xd9ee6046

[w] Phase 2: demo software baselines (1x each)
Case                   Shape        SW1xTotal    SW_GOPS    Checksum    Note
---------------------  -----------  -----------  ---------  ----------  ----------------
Linear+bias+ReLU       N=32              575268      0.028  0xb828d5e8  
Linear+bias+ReLU       N=64            13278730      0.009  0xbcf5a1d8  
Linear+bias+ReLU       N=128          104844519      0.010  0x9badf1cf  
Linear+bias+ReLU       N=256          832282916      0.010  0x5360d3ce  
Linear+bias+ReLU       N=512         6884702799      0.009  0x9cb8332d  
Linear+bias+ReLU       N=1024       55101576312      0.009  0x9e89b5d4  
Linear+bias+ReLU       N=2048       505489512504      0.008  0x98fbcca3  
Linear+bias+ReLU       N=4096               N/A        N/A         N/A  skip: scratch cap
Linear+bias+ReLU       N=8192               N/A        N/A         N/A  skip: scratch cap

MLP2                   N=32             1112059      0.029  0xc18a9969  
MLP2                   N=64            26482117      0.009  0x0c47c282  
MLP2                   N=128          209381756      0.010  0xb766422e  
MLP2                   N=256         1663175334      0.010  0x8b3592e2  
MLP2                   N=512        13764006625      0.009  0x7dba89de  
MLP2                   N=1024       110184450026      0.009  0x1629c593  
MLP2                   N=2048       1010900181846      0.008  0xa79dee04  
MLP2                   N=4096               N/A        N/A         N/A  skip: scratch cap
MLP2                   N=8192               N/A        N/A         N/A  skip: scratch cap

Attention-ish          N=32             1169797      0.014  0xa5a5a5a5  
Attention-ish          N=64            18549063      0.007  0xa5a5a5a5  
Attention-ish          N=128          151613105      0.006  0xa5a5a5a5  
Attention-ish          N=256         1307799884      0.006  0xa5a5a5a5  
Attention-ish          N=512                N/A        N/A         N/A  skip: O(N^3) cap
Attention-ish          N=1024               N/A        N/A         N/A  skip: O(N^3) cap
Attention-ish          N=2048               N/A        N/A         N/A  skip: O(N^3) cap
Attention-ish          N=4096               N/A        N/A         N/A  skip: O(N^3) cap
Attention-ish          N=8192               N/A        N/A         N/A  skip: O(N^3) cap

Covariance/Gram        N=32              739403      0.022  0xa5a5a5a5  
Covariance/Gram        N=64            13912206      0.009  0xa5a5a5a5  
Covariance/Gram        N=128          107374088      0.009  0xa5a5a5a5  
Covariance/Gram        N=256          842362802      0.009  0xa5a5a5a5  
Covariance/Gram        N=512         6924500674      0.009  0xa5a5a5a5  
Covariance/Gram        N=1024       55235020756      0.009  0xa5a5a5a5  
Covariance/Gram        N=2048       506046858647      0.008  0xa5a5a5a5  
Covariance/Gram        N=4096               N/A        N/A         N/A  skip: scratch cap
Covariance/Gram        N=8192               N/A        N/A         N/A  skip: scratch cap

Dense GEMV proj        N=32               28128      0.018  0xd1caf642  
Dense GEMV proj        N=64               99958      0.020  0xfe8bcb8c  
Dense GEMV proj        N=128             283852      0.028  0x9e324f0b  
Dense GEMV proj        N=256            1079722      0.030  0x25941f9a  
Dense GEMV proj        N=512            4251660      0.030  0x99589d11  
Dense GEMV proj        N=1024          16890925      0.031  0x9d96283e  
Dense GEMV proj        N=2048          77883486      0.026  0x52ad91e7  
Dense GEMV proj        N=4096         328037907      0.025  0xda643e13  
Dense GEMV proj        N=8192        1311289481      0.025  0x157e6da8  

[sw-only][setup] w D6 Sparse aggregation M=512 K=33792 density=15% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=126029651 cyc GOPS=0.010 checksum=0xf7adecc8
Sparse SpMV agg        512x33792      126029651      0.010  0xf7adecc8  
[sw-only][setup] w D7 Sparse linear M=512 K=33792 N=4 density=15% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=643099461 cyc GOPS=0.008 checksum=0x639998e2
Sparse SpMM linear     512x33792x4    643099461      0.008  0x639998e2  

[w] Suite complete. These rows are DRAM/CPU baselines only; no HW cycles or speedups are reported here.

CSR-SpMM    xfmr-95-N4     512x33792x4         5    224667335     0.007     334.34  0xd9ee6046

#### SPARSE HBM vs HBM-OFFLOADED
[P] Sparse combined paper-comparison benchmark suite
[P] Phase 1 runs the sparse software-only baseline sweep.
[P] Phase 2 runs the sparse exhaustive offloaded comparison sweep.

[w] Sparse software-only paper-comparison benchmark suite
[w] This suite mirrors the sparse portions of A/W but runs each case once and never issues CFU/HW commands.

[w] Phase 1: sparse kernel software baselines (1x each)
Kernel      Case           Shape             Den      SW1xCyc   SW_GOPS  CanonEff   Checksum
----------  -------------  ----------------  ---  -----------  --------  --------  ----------
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=50% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1954492754 cyc GOPS=0.002 checksum=0x9ca64d72
CSR-SpMV    xfmr-50        512x33792          50   1954492754     0.002     170.00  0x9ca64d72
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=40% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1703606055 cyc GOPS=0.002 checksum=0x3e004e8d
CSR-SpMV    xfmr-60        512x33792          40   1703606055     0.002     169.16  0x3e004e8d
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=30% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1433559252 cyc GOPS=0.001 checksum=0xaf75d5d4
CSR-SpMV    xfmr-70        512x33792          30   1433559252     0.001     181.00  0xaf75d5d4
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=20% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1112566953 cyc GOPS=0.001 checksum=0xe600e581
CSR-SpMV    xfmr-80        512x33792          20   1112566953     0.001     172.22  0xe600e581
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=10% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=672768576 cyc GOPS=0.001 checksum=0x515403b1
CSR-SpMV    xfmr-90        512x33792          10    672768576     0.001     182.85  0x515403b1
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=5% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=375328379 cyc GOPS=0.001 checksum=0x1ea9af7a
CSR-SpMV    xfmr-95        512x33792           5    375328379     0.001     191.66  0x1ea9af7a
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=50% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=13976800733 cyc GOPS=0.001 checksum=0x0505057e
CSR-SpMM    xfmr-50-N4     512x33792x4        50  13976800733     0.001     410.00  0x0505057e
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=40% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=11664269045 cyc GOPS=0.001 checksum=0xec604139
CSR-SpMM    xfmr-60-N4     512x33792x4        40  11664269045     0.001     393.33  0xec604139
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=30% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=9106043029 cyc GOPS=0.001 checksum=0xb42cc209
CSR-SpMM    xfmr-70-N4     512x33792x4        30   9106043029     0.001     380.00  0xb42cc209
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=20% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=6310567637 cyc GOPS=0.001 checksum=0xdd4c3ed7
CSR-SpMM    xfmr-80-N4     512x33792x4        20   6310567637     0.001     363.33  0xdd4c3ed7
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=10% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=3273444556 cyc GOPS=0.001 checksum=0xb844c84f
CSR-SpMM    xfmr-90-N4     512x33792x4        10   3273444556     0.001     350.00  0xb844c84f
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=5% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=1665026074 cyc GOPS=0.001 checksum=0xd9ee6046
CSR-SpMM    xfmr-95-N4     512x33792x4         5   1665026074     0.001     343.33  0xd9ee6046

[w] Phase 2: sparse demo software baselines (1x each)
Case                   Shape        SW1xTotal    SW_GOPS    Checksum    Note
---------------------  -----------  -----------  ---------  ----------  ----------------
[sw-only][setup] w D6 Sparse aggregation M=512 K=33792 density=15% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=912174558 cyc GOPS=0.001 checksum=0xf7adecc8
Sparse SpMV agg        512x33792      912174558      0.001  0xf7adecc8  
[sw-only][setup] w D7 Sparse linear M=512 K=33792 N=4 density=15% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=4818575153 cyc GOPS=0.001 checksum=0x639998e2
Sparse SpMM linear     512x33792x4   4818575153      0.001  0x639998e2  

[w] Sparse suite complete. These rows are DRAM/CPU baselines only; no HW cycles or speedups are reported here.

[W] Sparse exhaustive paper-comparison benchmark suite
[W] Phase 1: sparse all-kernel averaged runtime suite
[W] This phase keeps only the CSR32 SpMV/SpMM comparison points.

[O] Overnight sparse-kernel benchmark
[O] Repeats per case: 3
[O] Kernels: CSR32 SpMV, CSR32 SpMM

[O] CSR32 SpMV transformer-50 density=50 repeat 1/3
[setup] O SpMV xfmr-50 M=512 K=33792 density=50% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=1081423 entry_batches=4259 rhs_stride=1081680
  p1 rows=64..127 nnz=1081077 entry_batches=4262 rhs_stride=1081336
  p2 rows=128..191 nnz=1080523 entry_batches=4253 rhs_stride=1080784
  p3 rows=192..255 nnz=1082384 entry_batches=4259 rhs_stride=1082640
  p4 rows=256..319 nnz=1082544 entry_batches=4266 rhs_stride=1082800
  p5 rows=320..383 nnz=1081945 entry_batches=4262 rhs_stride=1082208
  p6 rows=384..447 nnz=1080458 entry_batches=4257 rhs_stride=1080720
  p7 rows=448..511 nnz=1081272 entry_batches=4259 rhs_stride=1081528
  nnz=8651626 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 4158012730 cyc  HW: 1441301761 cyc  speedup: 2.8x
[perf] cyc/work: SW=480 HW=166
[perf] Throughput: SW=0.001 GOPS (1.04 MOPS)  HW=0.003 GOPS (3.00 MOPS)
[perf] Canonical Bandwidth Eff: SW=173.33 MOPS/GBPS  HW=166.66 MOPS/GBPS
[perf] HBM BW (canonical est): SW=6 MB/s  HW=18 MB/s
[perf] Stream Bandwidth Eff: HW=250.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=12 MB/s
[perf] bytes: canonical=103825688 hw_stream=69814272 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-50 density=50 repeat 2/3
[setup] O SpMV xfmr-50 M=512 K=33792 density=50% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=1081423 entry_batches=4259 rhs_stride=1081680
  p1 rows=64..127 nnz=1081077 entry_batches=4262 rhs_stride=1081336
  p2 rows=128..191 nnz=1080523 entry_batches=4253 rhs_stride=1080784
  p3 rows=192..255 nnz=1082384 entry_batches=4259 rhs_stride=1082640
  p4 rows=256..319 nnz=1082544 entry_batches=4266 rhs_stride=1082800
  p5 rows=320..383 nnz=1081945 entry_batches=4262 rhs_stride=1082208
  p6 rows=384..447 nnz=1080458 entry_batches=4257 rhs_stride=1080720
  p7 rows=448..511 nnz=1081272 entry_batches=4259 rhs_stride=1081528
  nnz=8651626 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 4157762205 cyc  HW: 1441301677 cyc  speedup: 2.8x
[perf] cyc/work: SW=480 HW=166
[perf] Throughput: SW=0.001 GOPS (1.04 MOPS)  HW=0.003 GOPS (3.00 MOPS)
[perf] Canonical Bandwidth Eff: SW=173.33 MOPS/GBPS  HW=166.66 MOPS/GBPS
[perf] HBM BW (canonical est): SW=6 MB/s  HW=18 MB/s
[perf] Stream Bandwidth Eff: HW=250.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=12 MB/s
[perf] bytes: canonical=103825688 hw_stream=69814272 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-50 density=50 repeat 3/3
[setup] O SpMV xfmr-50 M=512 K=33792 density=50% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=1081423 entry_batches=4259 rhs_stride=1081680
  p1 rows=64..127 nnz=1081077 entry_batches=4262 rhs_stride=1081336
  p2 rows=128..191 nnz=1080523 entry_batches=4253 rhs_stride=1080784
  p3 rows=192..255 nnz=1082384 entry_batches=4259 rhs_stride=1082640
  p4 rows=256..319 nnz=1082544 entry_batches=4266 rhs_stride=1082800
  p5 rows=320..383 nnz=1081945 entry_batches=4262 rhs_stride=1082208
  p6 rows=384..447 nnz=1080458 entry_batches=4257 rhs_stride=1080720
  p7 rows=448..511 nnz=1081272 entry_batches=4259 rhs_stride=1081528
  nnz=8651626 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 4158019173 cyc  HW: 1441296802 cyc  speedup: 2.8x
[perf] cyc/work: SW=480 HW=166
[perf] Throughput: SW=0.001 GOPS (1.04 MOPS)  HW=0.003 GOPS (3.00 MOPS)
[perf] Canonical Bandwidth Eff: SW=173.33 MOPS/GBPS  HW=166.66 MOPS/GBPS
[perf] HBM BW (canonical est): SW=6 MB/s  HW=18 MB/s
[perf] Stream Bandwidth Eff: HW=250.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=12 MB/s
[perf] bytes: canonical=103825688 hw_stream=69814272 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-60 density=40 repeat 1/3
[setup] O SpMV xfmr-60 M=512 K=33792 density=40% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=865957 entry_batches=3414 rhs_stride=866216
  p1 rows=64..127 nnz=865301 entry_batches=3411 rhs_stride=865560
  p2 rows=128..191 nnz=864685 entry_batches=3410 rhs_stride=864944
  p3 rows=192..255 nnz=865117 entry_batches=3407 rhs_stride=865376
  p4 rows=256..319 nnz=865693 entry_batches=3414 rhs_stride=865952
  p5 rows=320..383 nnz=865677 entry_batches=3413 rhs_stride=865936
  p6 rows=384..447 nnz=864350 entry_batches=3408 rhs_stride=864608
  p7 rows=448..511 nnz=865758 entry_batches=3415 rhs_stride=866016
  nnz=6922538 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 3474752248 cyc  HW: 1298703333 cyc  speedup: 2.6x
[perf] cyc/work: SW=501 HW=187
[perf] Throughput: SW=0.000 GOPS (0.99 MOPS)  HW=0.002 GOPS (2.66 MOPS)
[perf] Canonical Bandwidth Eff: SW=198.00 MOPS/GBPS  HW=177.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=5 MB/s  HW=15 MB/s
[perf] Stream Bandwidth Eff: HW=266.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=10 MB/s
[perf] bytes: canonical=83076632 hw_stream=55918592 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-60 density=40 repeat 2/3
[setup] O SpMV xfmr-60 M=512 K=33792 density=40% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=865957 entry_batches=3414 rhs_stride=866216
  p1 rows=64..127 nnz=865301 entry_batches=3411 rhs_stride=865560
  p2 rows=128..191 nnz=864685 entry_batches=3410 rhs_stride=864944
  p3 rows=192..255 nnz=865117 entry_batches=3407 rhs_stride=865376
  p4 rows=256..319 nnz=865693 entry_batches=3414 rhs_stride=865952
  p5 rows=320..383 nnz=865677 entry_batches=3413 rhs_stride=865936
  p6 rows=384..447 nnz=864350 entry_batches=3408 rhs_stride=864608
  p7 rows=448..511 nnz=865758 entry_batches=3415 rhs_stride=866016
  nnz=6922538 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 3474934030 cyc  HW: 1298701437 cyc  speedup: 2.6x
[perf] cyc/work: SW=501 HW=187
[perf] Throughput: SW=0.000 GOPS (0.99 MOPS)  HW=0.002 GOPS (2.66 MOPS)
[perf] Canonical Bandwidth Eff: SW=198.00 MOPS/GBPS  HW=177.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=5 MB/s  HW=15 MB/s
[perf] Stream Bandwidth Eff: HW=266.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=10 MB/s
[perf] bytes: canonical=83076632 hw_stream=55918592 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-60 density=40 repeat 3/3
[setup] O SpMV xfmr-60 M=512 K=33792 density=40% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=865957 entry_batches=3414 rhs_stride=866216
  p1 rows=64..127 nnz=865301 entry_batches=3411 rhs_stride=865560
  p2 rows=128..191 nnz=864685 entry_batches=3410 rhs_stride=864944
  p3 rows=192..255 nnz=865117 entry_batches=3407 rhs_stride=865376
  p4 rows=256..319 nnz=865693 entry_batches=3414 rhs_stride=865952
  p5 rows=320..383 nnz=865677 entry_batches=3413 rhs_stride=865936
  p6 rows=384..447 nnz=864350 entry_batches=3408 rhs_stride=864608
  p7 rows=448..511 nnz=865758 entry_batches=3415 rhs_stride=866016
  nnz=6922538 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 3474973682 cyc  HW: 1298701320 cyc  speedup: 2.6x
[perf] cyc/work: SW=501 HW=187
[perf] Throughput: SW=0.000 GOPS (0.99 MOPS)  HW=0.002 GOPS (2.66 MOPS)
[perf] Canonical Bandwidth Eff: SW=198.00 MOPS/GBPS  HW=177.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=5 MB/s  HW=15 MB/s
[perf] Stream Bandwidth Eff: HW=266.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=10 MB/s
[perf] bytes: canonical=83076632 hw_stream=55918592 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-70 density=30 repeat 1/3
[setup] O SpMV xfmr-70 M=512 K=33792 density=30% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=649287 entry_batches=2568 rhs_stride=649544
  p1 rows=64..127 nnz=649462 entry_batches=2563 rhs_stride=649720
  p2 rows=128..191 nnz=647534 entry_batches=2560 rhs_stride=647792
  p3 rows=192..255 nnz=648411 entry_batches=2564 rhs_stride=648672
  p4 rows=256..319 nnz=649779 entry_batches=2569 rhs_stride=650040
  p5 rows=320..383 nnz=649021 entry_batches=2567 rhs_stride=649280
  p6 rows=384..447 nnz=649540 entry_batches=2572 rhs_stride=649800
  p7 rows=448..511 nnz=648426 entry_batches=2566 rhs_stride=648688
  nnz=5191460 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 2766750022 cyc  HW: 1135371585 cyc  speedup: 2.4x
[perf] cyc/work: SW=532 HW=218
[perf] Throughput: SW=0.000 GOPS (0.93 MOPS)  HW=0.002 GOPS (2.28 MOPS)
[perf] Canonical Bandwidth Eff: SW=186.00 MOPS/GBPS  HW=175.38 MOPS/GBPS
[perf] HBM BW (canonical est): SW=5 MB/s  HW=13 MB/s
[perf] Stream Bandwidth Eff: HW=253.33 MOPS/GBPS
[perf] HBM BW (stream est): HW=9 MB/s
[perf] bytes: canonical=62303696 hw_stream=42067968 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-70 density=30 repeat 2/3
[setup] O SpMV xfmr-70 M=512 K=33792 density=30% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=649287 entry_batches=2568 rhs_stride=649544
  p1 rows=64..127 nnz=649462 entry_batches=2563 rhs_stride=649720
  p2 rows=128..191 nnz=647534 entry_batches=2560 rhs_stride=647792
  p3 rows=192..255 nnz=648411 entry_batches=2564 rhs_stride=648672
  p4 rows=256..319 nnz=649779 entry_batches=2569 rhs_stride=650040
  p5 rows=320..383 nnz=649021 entry_batches=2567 rhs_stride=649280
  p6 rows=384..447 nnz=649540 entry_batches=2572 rhs_stride=649800
  p7 rows=448..511 nnz=648426 entry_batches=2566 rhs_stride=648688
  nnz=5191460 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 2766838156 cyc  HW: 1135370568 cyc  speedup: 2.4x
[perf] cyc/work: SW=532 HW=218
[perf] Throughput: SW=0.000 GOPS (0.93 MOPS)  HW=0.002 GOPS (2.28 MOPS)
[perf] Canonical Bandwidth Eff: SW=186.00 MOPS/GBPS  HW=175.38 MOPS/GBPS
[perf] HBM BW (canonical est): SW=5 MB/s  HW=13 MB/s
[perf] Stream Bandwidth Eff: HW=253.33 MOPS/GBPS
[perf] HBM BW (stream est): HW=9 MB/s
[perf] bytes: canonical=62303696 hw_stream=42067968 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-70 density=30 repeat 3/3
[setup] O SpMV xfmr-70 M=512 K=33792 density=30% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=649287 entry_batches=2568 rhs_stride=649544
  p1 rows=64..127 nnz=649462 entry_batches=2563 rhs_stride=649720
  p2 rows=128..191 nnz=647534 entry_batches=2560 rhs_stride=647792
  p3 rows=192..255 nnz=648411 entry_batches=2564 rhs_stride=648672
  p4 rows=256..319 nnz=649779 entry_batches=2569 rhs_stride=650040
  p5 rows=320..383 nnz=649021 entry_batches=2567 rhs_stride=649280
  p6 rows=384..447 nnz=649540 entry_batches=2572 rhs_stride=649800
  p7 rows=448..511 nnz=648426 entry_batches=2566 rhs_stride=648688
  nnz=5191460 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 2766937654 cyc  HW: 1135375664 cyc  speedup: 2.4x
[perf] cyc/work: SW=532 HW=218
[perf] Throughput: SW=0.000 GOPS (0.93 MOPS)  HW=0.002 GOPS (2.28 MOPS)
[perf] Canonical Bandwidth Eff: SW=186.00 MOPS/GBPS  HW=175.38 MOPS/GBPS
[perf] HBM BW (canonical est): SW=5 MB/s  HW=13 MB/s
[perf] Stream Bandwidth Eff: HW=253.33 MOPS/GBPS
[perf] HBM BW (stream est): HW=9 MB/s
[perf] bytes: canonical=62303696 hw_stream=42067968 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-80 density=20 repeat 1/3
[setup] O SpMV xfmr-80 M=512 K=33792 density=20% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=432414 entry_batches=1722 rhs_stride=432672
  p1 rows=64..127 nnz=433056 entry_batches=1728 rhs_stride=433312
  p2 rows=128..191 nnz=431824 entry_batches=1720 rhs_stride=432080
  p3 rows=192..255 nnz=432382 entry_batches=1725 rhs_stride=432640
  p4 rows=256..319 nnz=432739 entry_batches=1726 rhs_stride=433000
  p5 rows=320..383 nnz=433443 entry_batches=1724 rhs_stride=433704
  p6 rows=384..447 nnz=431840 entry_batches=1721 rhs_stride=432096
  p7 rows=448..511 nnz=433474 entry_batches=1725 rhs_stride=433736
  nnz=3461172 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 2003363270 cyc  HW: 917459347 cyc  speedup: 2.1x
[perf] cyc/work: SW=578 HW=265
[perf] Throughput: SW=0.000 GOPS (0.86 MOPS)  HW=0.001 GOPS (1.88 MOPS)
[perf] Canonical Bandwidth Eff: SW=172.00 MOPS/GBPS  HW=170.90 MOPS/GBPS
[perf] HBM BW (canonical est): SW=5 MB/s  HW=11 MB/s
[perf] Stream Bandwidth Eff: HW=268.57 MOPS/GBPS
[perf] HBM BW (stream est): HW=7 MB/s
[perf] bytes: canonical=41540240 hw_stream=28268544 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-80 density=20 repeat 2/3
[setup] O SpMV xfmr-80 M=512 K=33792 density=20% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=432414 entry_batches=1722 rhs_stride=432672
  p1 rows=64..127 nnz=433056 entry_batches=1728 rhs_stride=433312
  p2 rows=128..191 nnz=431824 entry_batches=1720 rhs_stride=432080
  p3 rows=192..255 nnz=432382 entry_batches=1725 rhs_stride=432640
  p4 rows=256..319 nnz=432739 entry_batches=1726 rhs_stride=433000
  p5 rows=320..383 nnz=433443 entry_batches=1724 rhs_stride=433704
  p6 rows=384..447 nnz=431840 entry_batches=1721 rhs_stride=432096
  p7 rows=448..511 nnz=433474 entry_batches=1725 rhs_stride=433736
  nnz=3461172 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 2003341193 cyc  HW: 917460849 cyc  speedup: 2.1x
[perf] cyc/work: SW=578 HW=265
[perf] Throughput: SW=0.000 GOPS (0.86 MOPS)  HW=0.001 GOPS (1.88 MOPS)
[perf] Canonical Bandwidth Eff: SW=172.00 MOPS/GBPS  HW=170.90 MOPS/GBPS
[perf] HBM BW (canonical est): SW=5 MB/s  HW=11 MB/s
[perf] Stream Bandwidth Eff: HW=268.57 MOPS/GBPS
[perf] HBM BW (stream est): HW=7 MB/s
[perf] bytes: canonical=41540240 hw_stream=28268544 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-80 density=20 repeat 3/3
[setup] O SpMV xfmr-80 M=512 K=33792 density=20% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=432414 entry_batches=1722 rhs_stride=432672
  p1 rows=64..127 nnz=433056 entry_batches=1728 rhs_stride=433312
  p2 rows=128..191 nnz=431824 entry_batches=1720 rhs_stride=432080
  p3 rows=192..255 nnz=432382 entry_batches=1725 rhs_stride=432640
  p4 rows=256..319 nnz=432739 entry_batches=1726 rhs_stride=433000
  p5 rows=320..383 nnz=433443 entry_batches=1724 rhs_stride=433704
  p6 rows=384..447 nnz=431840 entry_batches=1721 rhs_stride=432096
  p7 rows=448..511 nnz=433474 entry_batches=1725 rhs_stride=433736
  nnz=3461172 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 2003269705 cyc  HW: 917461561 cyc  speedup: 2.1x
[perf] cyc/work: SW=578 HW=265
[perf] Throughput: SW=0.000 GOPS (0.86 MOPS)  HW=0.001 GOPS (1.88 MOPS)
[perf] Canonical Bandwidth Eff: SW=172.00 MOPS/GBPS  HW=170.90 MOPS/GBPS
[perf] HBM BW (canonical est): SW=5 MB/s  HW=11 MB/s
[perf] Stream Bandwidth Eff: HW=268.57 MOPS/GBPS
[perf] HBM BW (stream est): HW=7 MB/s
[perf] bytes: canonical=41540240 hw_stream=28268544 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-90 density=10 repeat 1/3
[setup] O SpMV xfmr-90 M=512 K=33792 density=10% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=216210 entry_batches=887 rhs_stride=216472
  p1 rows=64..127 nnz=215992 entry_batches=887 rhs_stride=216248
  p2 rows=128..191 nnz=215894 entry_batches=886 rhs_stride=216152
  p3 rows=192..255 nnz=216839 entry_batches=888 rhs_stride=217096
  p4 rows=256..319 nnz=215460 entry_batches=881 rhs_stride=215720
  p5 rows=320..383 nnz=216494 entry_batches=888 rhs_stride=216752
  p6 rows=384..447 nnz=216324 entry_batches=885 rhs_stride=216584
  p7 rows=448..511 nnz=216661 entry_batches=883 rhs_stride=216920
  nnz=1729874 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 1116682571 cyc  HW: 579251470 cyc  speedup: 1.9x
[perf] cyc/work: SW=645 HW=334
[perf] Throughput: SW=0.000 GOPS (0.77 MOPS)  HW=0.001 GOPS (1.49 MOPS)
[perf] Canonical Bandwidth Eff: SW=192.50 MOPS/GBPS  HW=186.25 MOPS/GBPS
[perf] HBM BW (canonical est): SW=4 MB/s  HW=8 MB/s
[perf] Stream Bandwidth Eff: HW=248.33 MOPS/GBPS
[perf] HBM BW (stream est): HW=6 MB/s
[perf] bytes: canonical=20764664 hw_stream=14534656 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-90 density=10 repeat 2/3
[setup] O SpMV xfmr-90 M=512 K=33792 density=10% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=216210 entry_batches=887 rhs_stride=216472
  p1 rows=64..127 nnz=215992 entry_batches=887 rhs_stride=216248
  p2 rows=128..191 nnz=215894 entry_batches=886 rhs_stride=216152
  p3 rows=192..255 nnz=216839 entry_batches=888 rhs_stride=217096
  p4 rows=256..319 nnz=215460 entry_batches=881 rhs_stride=215720
  p5 rows=320..383 nnz=216494 entry_batches=888 rhs_stride=216752
  p6 rows=384..447 nnz=216324 entry_batches=885 rhs_stride=216584
  p7 rows=448..511 nnz=216661 entry_batches=883 rhs_stride=216920
  nnz=1729874 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 1116675199 cyc  HW: 579253504 cyc  speedup: 1.9x
[perf] cyc/work: SW=645 HW=334
[perf] Throughput: SW=0.000 GOPS (0.77 MOPS)  HW=0.001 GOPS (1.49 MOPS)
[perf] Canonical Bandwidth Eff: SW=192.50 MOPS/GBPS  HW=186.25 MOPS/GBPS
[perf] HBM BW (canonical est): SW=4 MB/s  HW=8 MB/s
[perf] Stream Bandwidth Eff: HW=248.33 MOPS/GBPS
[perf] HBM BW (stream est): HW=6 MB/s
[perf] bytes: canonical=20764664 hw_stream=14534656 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-90 density=10 repeat 3/3
[setup] O SpMV xfmr-90 M=512 K=33792 density=10% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=216210 entry_batches=887 rhs_stride=216472
  p1 rows=64..127 nnz=215992 entry_batches=887 rhs_stride=216248
  p2 rows=128..191 nnz=215894 entry_batches=886 rhs_stride=216152
  p3 rows=192..255 nnz=216839 entry_batches=888 rhs_stride=217096
  p4 rows=256..319 nnz=215460 entry_batches=881 rhs_stride=215720
  p5 rows=320..383 nnz=216494 entry_batches=888 rhs_stride=216752
  p6 rows=384..447 nnz=216324 entry_batches=885 rhs_stride=216584
  p7 rows=448..511 nnz=216661 entry_batches=883 rhs_stride=216920
  nnz=1729874 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 1116655668 cyc  HW: 579252361 cyc  speedup: 1.9x
[perf] cyc/work: SW=645 HW=334
[perf] Throughput: SW=0.000 GOPS (0.77 MOPS)  HW=0.001 GOPS (1.49 MOPS)
[perf] Canonical Bandwidth Eff: SW=192.50 MOPS/GBPS  HW=186.25 MOPS/GBPS
[perf] HBM BW (canonical est): SW=4 MB/s  HW=8 MB/s
[perf] Stream Bandwidth Eff: HW=248.33 MOPS/GBPS
[perf] HBM BW (stream est): HW=6 MB/s
[perf] bytes: canonical=20764664 hw_stream=14534656 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-95 density=5 repeat 1/3
[setup] O SpMV xfmr-95 M=512 K=33792 density=5% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=107991 entry_batches=448 rhs_stride=108248
  p1 rows=64..127 nnz=108050 entry_batches=450 rhs_stride=108312
  p2 rows=128..191 nnz=107836 entry_batches=448 rhs_stride=108096
  p3 rows=192..255 nnz=108210 entry_batches=448 rhs_stride=108472
  p4 rows=256..319 nnz=108028 entry_batches=448 rhs_stride=108288
  p5 rows=320..383 nnz=108056 entry_batches=448 rhs_stride=108312
  p6 rows=384..447 nnz=107952 entry_batches=449 rhs_stride=108208
  p7 rows=448..511 nnz=107819 entry_batches=449 rhs_stride=108080
  nnz=863942 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 596883850 cyc  HW: 329416721 cyc  speedup: 1.8x
[perf] cyc/work: SW=690 HW=381
[perf] Throughput: SW=0.000 GOPS (0.72 MOPS)  HW=0.001 GOPS (1.31 MOPS)
[perf] Canonical Bandwidth Eff: SW=180.00 MOPS/GBPS  HW=187.14 MOPS/GBPS
[perf] HBM BW (canonical est): SW=4 MB/s  HW=7 MB/s
[perf] Stream Bandwidth Eff: HW=262.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=10373480 hw_stream=7372800 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-95 density=5 repeat 2/3
[setup] O SpMV xfmr-95 M=512 K=33792 density=5% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=107991 entry_batches=448 rhs_stride=108248
  p1 rows=64..127 nnz=108050 entry_batches=450 rhs_stride=108312
  p2 rows=128..191 nnz=107836 entry_batches=448 rhs_stride=108096
  p3 rows=192..255 nnz=108210 entry_batches=448 rhs_stride=108472
  p4 rows=256..319 nnz=108028 entry_batches=448 rhs_stride=108288
  p5 rows=320..383 nnz=108056 entry_batches=448 rhs_stride=108312
  p6 rows=384..447 nnz=107952 entry_batches=449 rhs_stride=108208
  p7 rows=448..511 nnz=107819 entry_batches=449 rhs_stride=108080
  nnz=863942 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 596892011 cyc  HW: 329417264 cyc  speedup: 1.8x
[perf] cyc/work: SW=690 HW=381
[perf] Throughput: SW=0.000 GOPS (0.72 MOPS)  HW=0.001 GOPS (1.31 MOPS)
[perf] Canonical Bandwidth Eff: SW=180.00 MOPS/GBPS  HW=187.14 MOPS/GBPS
[perf] HBM BW (canonical est): SW=4 MB/s  HW=7 MB/s
[perf] Stream Bandwidth Eff: HW=262.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=10373480 hw_stream=7372800 (HW cycles include RHS software prejoin)

[O] CSR32 SpMV transformer-95 density=5 repeat 3/3
[setup] O SpMV xfmr-95 M=512 K=33792 density=5% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=107991 entry_batches=448 rhs_stride=108248
  p1 rows=64..127 nnz=108050 entry_batches=450 rhs_stride=108312
  p2 rows=128..191 nnz=107836 entry_batches=448 rhs_stride=108096
  p3 rows=192..255 nnz=108210 entry_batches=448 rhs_stride=108472
  p4 rows=256..319 nnz=108028 entry_batches=448 rhs_stride=108288
  p5 rows=320..383 nnz=108056 entry_batches=448 rhs_stride=108312
  p6 rows=384..447 nnz=107952 entry_batches=449 rhs_stride=108208
  p7 rows=448..511 nnz=107819 entry_batches=449 rhs_stride=108080
  nnz=863942 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[perf] SW: 596881467 cyc  HW: 329417738 cyc  speedup: 1.8x
[perf] cyc/work: SW=690 HW=381
[perf] Throughput: SW=0.000 GOPS (0.72 MOPS)  HW=0.001 GOPS (1.31 MOPS)
[perf] Canonical Bandwidth Eff: SW=180.00 MOPS/GBPS  HW=187.14 MOPS/GBPS
[perf] HBM BW (canonical est): SW=4 MB/s  HW=7 MB/s
[perf] Stream Bandwidth Eff: HW=262.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=10373480 hw_stream=7372800 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-50 density=50 N=4 repeat 1/3
[setup] O SpMM xfmr-50 M=512 K=33792 N=4 density=50% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=1081423 entry_batches=4259 rhs_stride=1081680
  p1 rows=64..127 nnz=1081077 entry_batches=4262 rhs_stride=1081336
  p2 rows=128..191 nnz=1080523 entry_batches=4253 rhs_stride=1080784
  p3 rows=192..255 nnz=1082384 entry_batches=4259 rhs_stride=1082640
  p4 rows=256..319 nnz=1082544 entry_batches=4266 rhs_stride=1082800
  p5 rows=320..383 nnz=1081945 entry_batches=4262 rhs_stride=1082208
  p6 rows=384..447 nnz=1080458 entry_batches=4257 rhs_stride=1080720
  p7 rows=448..511 nnz=1081272 entry_batches=4259 rhs_stride=1081528
  nnz=8651626 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 22825863638 cyc  HW: 12058456519 cyc  speedup: 1.8x
[perf] cyc/work: SW=659 HW=348
[perf] Throughput: SW=0.000 GOPS (0.75 MOPS)  HW=0.001 GOPS (1.43 MOPS)
[perf] Canonical Bandwidth Eff: SW=375.00 MOPS/GBPS  HW=357.50 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=4 MB/s
[perf] Stream Bandwidth Eff: HW=286.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=207657488 hw_stream=279183360 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-50 density=50 N=4 repeat 2/3
[setup] O SpMM xfmr-50 M=512 K=33792 N=4 density=50% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=1081423 entry_batches=4259 rhs_stride=1081680
  p1 rows=64..127 nnz=1081077 entry_batches=4262 rhs_stride=1081336
  p2 rows=128..191 nnz=1080523 entry_batches=4253 rhs_stride=1080784
  p3 rows=192..255 nnz=1082384 entry_batches=4259 rhs_stride=1082640
  p4 rows=256..319 nnz=1082544 entry_batches=4266 rhs_stride=1082800
  p5 rows=320..383 nnz=1081945 entry_batches=4262 rhs_stride=1082208
  p6 rows=384..447 nnz=1080458 entry_batches=4257 rhs_stride=1080720
  p7 rows=448..511 nnz=1081272 entry_batches=4259 rhs_stride=1081528
  nnz=8651626 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 22825833539 cyc  HW: 12058462656 cyc  speedup: 1.8x
[perf] cyc/work: SW=659 HW=348
[perf] Throughput: SW=0.000 GOPS (0.75 MOPS)  HW=0.001 GOPS (1.43 MOPS)
[perf] Canonical Bandwidth Eff: SW=375.00 MOPS/GBPS  HW=357.50 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=4 MB/s
[perf] Stream Bandwidth Eff: HW=286.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=207657488 hw_stream=279183360 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-50 density=50 N=4 repeat 3/3
[setup] O SpMM xfmr-50 M=512 K=33792 N=4 density=50% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=1081423 entry_batches=4259 rhs_stride=1081680
  p1 rows=64..127 nnz=1081077 entry_batches=4262 rhs_stride=1081336
  p2 rows=128..191 nnz=1080523 entry_batches=4253 rhs_stride=1080784
  p3 rows=192..255 nnz=1082384 entry_batches=4259 rhs_stride=1082640
  p4 rows=256..319 nnz=1082544 entry_batches=4266 rhs_stride=1082800
  p5 rows=320..383 nnz=1081945 entry_batches=4262 rhs_stride=1082208
  p6 rows=384..447 nnz=1080458 entry_batches=4257 rhs_stride=1080720
  p7 rows=448..511 nnz=1081272 entry_batches=4259 rhs_stride=1081528
  nnz=8651626 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 22825854056 cyc  HW: 12058465461 cyc  speedup: 1.8x
[perf] cyc/work: SW=659 HW=348
[perf] Throughput: SW=0.000 GOPS (0.75 MOPS)  HW=0.001 GOPS (1.43 MOPS)
[perf] Canonical Bandwidth Eff: SW=375.00 MOPS/GBPS  HW=357.50 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=4 MB/s
[perf] Stream Bandwidth Eff: HW=286.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=207657488 hw_stream=279183360 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-60 density=40 N=4 repeat 1/3
[setup] O SpMM xfmr-60 M=512 K=33792 N=4 density=40% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=865957 entry_batches=3414 rhs_stride=866216
  p1 rows=64..127 nnz=865301 entry_batches=3411 rhs_stride=865560
  p2 rows=128..191 nnz=864685 entry_batches=3410 rhs_stride=864944
  p3 rows=192..255 nnz=865117 entry_batches=3407 rhs_stride=865376
  p4 rows=256..319 nnz=865693 entry_batches=3414 rhs_stride=865952
  p5 rows=320..383 nnz=865677 entry_batches=3413 rhs_stride=865936
  p6 rows=384..447 nnz=864350 entry_batches=3408 rhs_stride=864608
  p7 rows=448..511 nnz=865758 entry_batches=3415 rhs_stride=866016
  nnz=6922538 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 18753469732 cyc  HW: 10138975770 cyc  speedup: 1.8x
[perf] cyc/work: SW=677 HW=366
[perf] Throughput: SW=0.000 GOPS (0.73 MOPS)  HW=0.001 GOPS (1.36 MOPS)
[perf] Canonical Bandwidth Eff: SW=365.00 MOPS/GBPS  HW=340.00 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=4 MB/s
[perf] Stream Bandwidth Eff: HW=272.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=166159376 hw_stream=223600640 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-60 density=40 N=4 repeat 2/3
[setup] O SpMM xfmr-60 M=512 K=33792 N=4 density=40% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=865957 entry_batches=3414 rhs_stride=866216
  p1 rows=64..127 nnz=865301 entry_batches=3411 rhs_stride=865560
  p2 rows=128..191 nnz=864685 entry_batches=3410 rhs_stride=864944
  p3 rows=192..255 nnz=865117 entry_batches=3407 rhs_stride=865376
  p4 rows=256..319 nnz=865693 entry_batches=3414 rhs_stride=865952
  p5 rows=320..383 nnz=865677 entry_batches=3413 rhs_stride=865936
  p6 rows=384..447 nnz=864350 entry_batches=3408 rhs_stride=864608
  p7 rows=448..511 nnz=865758 entry_batches=3415 rhs_stride=866016
  nnz=6922538 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 18753504554 cyc  HW: 10138978695 cyc  speedup: 1.8x
[perf] cyc/work: SW=677 HW=366
[perf] Throughput: SW=0.000 GOPS (0.73 MOPS)  HW=0.001 GOPS (1.36 MOPS)
[perf] Canonical Bandwidth Eff: SW=365.00 MOPS/GBPS  HW=340.00 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=4 MB/s
[perf] Stream Bandwidth Eff: HW=272.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=166159376 hw_stream=223600640 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-60 density=40 N=4 repeat 3/3
[setup] O SpMM xfmr-60 M=512 K=33792 N=4 density=40% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=865957 entry_batches=3414 rhs_stride=866216
  p1 rows=64..127 nnz=865301 entry_batches=3411 rhs_stride=865560
  p2 rows=128..191 nnz=864685 entry_batches=3410 rhs_stride=864944
  p3 rows=192..255 nnz=865117 entry_batches=3407 rhs_stride=865376
  p4 rows=256..319 nnz=865693 entry_batches=3414 rhs_stride=865952
  p5 rows=320..383 nnz=865677 entry_batches=3413 rhs_stride=865936
  p6 rows=384..447 nnz=864350 entry_batches=3408 rhs_stride=864608
  p7 rows=448..511 nnz=865758 entry_batches=3415 rhs_stride=866016
  nnz=6922538 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 18753523449 cyc  HW: 10138975728 cyc  speedup: 1.8x
[perf] cyc/work: SW=677 HW=366
[perf] Throughput: SW=0.000 GOPS (0.73 MOPS)  HW=0.001 GOPS (1.36 MOPS)
[perf] Canonical Bandwidth Eff: SW=365.00 MOPS/GBPS  HW=340.00 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=4 MB/s
[perf] Stream Bandwidth Eff: HW=272.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=166159376 hw_stream=223600640 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-70 density=30 N=4 repeat 1/3
[setup] O SpMM xfmr-70 M=512 K=33792 N=4 density=30% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=649287 entry_batches=2568 rhs_stride=649544
  p1 rows=64..127 nnz=649462 entry_batches=2563 rhs_stride=649720
  p2 rows=128..191 nnz=647534 entry_batches=2560 rhs_stride=647792
  p3 rows=192..255 nnz=648411 entry_batches=2564 rhs_stride=648672
  p4 rows=256..319 nnz=649779 entry_batches=2569 rhs_stride=650040
  p5 rows=320..383 nnz=649021 entry_batches=2567 rhs_stride=649280
  p6 rows=384..447 nnz=649540 entry_batches=2572 rhs_stride=649800
  p7 rows=448..511 nnz=648426 entry_batches=2566 rhs_stride=648688
  nnz=5191460 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 14430604598 cyc  HW: 7968752851 cyc  speedup: 1.8x
[perf] cyc/work: SW=694 HW=383
[perf] Throughput: SW=0.000 GOPS (0.71 MOPS)  HW=0.001 GOPS (1.30 MOPS)
[perf] Canonical Bandwidth Eff: SW=355.00 MOPS/GBPS  HW=433.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=260.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=124613504 hw_stream=168198144 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-70 density=30 N=4 repeat 2/3
[setup] O SpMM xfmr-70 M=512 K=33792 N=4 density=30% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=649287 entry_batches=2568 rhs_stride=649544
  p1 rows=64..127 nnz=649462 entry_batches=2563 rhs_stride=649720
  p2 rows=128..191 nnz=647534 entry_batches=2560 rhs_stride=647792
  p3 rows=192..255 nnz=648411 entry_batches=2564 rhs_stride=648672
  p4 rows=256..319 nnz=649779 entry_batches=2569 rhs_stride=650040
  p5 rows=320..383 nnz=649021 entry_batches=2567 rhs_stride=649280
  p6 rows=384..447 nnz=649540 entry_batches=2572 rhs_stride=649800
  p7 rows=448..511 nnz=648426 entry_batches=2566 rhs_stride=648688
  nnz=5191460 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 14430862849 cyc  HW: 7968772018 cyc  speedup: 1.8x
[perf] cyc/work: SW=694 HW=383
[perf] Throughput: SW=0.000 GOPS (0.71 MOPS)  HW=0.001 GOPS (1.30 MOPS)
[perf] Canonical Bandwidth Eff: SW=355.00 MOPS/GBPS  HW=433.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=260.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=124613504 hw_stream=168198144 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-70 density=30 N=4 repeat 3/3
[setup] O SpMM xfmr-70 M=512 K=33792 N=4 density=30% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=649287 entry_batches=2568 rhs_stride=649544
  p1 rows=64..127 nnz=649462 entry_batches=2563 rhs_stride=649720
  p2 rows=128..191 nnz=647534 entry_batches=2560 rhs_stride=647792
  p3 rows=192..255 nnz=648411 entry_batches=2564 rhs_stride=648672
  p4 rows=256..319 nnz=649779 entry_batches=2569 rhs_stride=650040
  p5 rows=320..383 nnz=649021 entry_batches=2567 rhs_stride=649280
  p6 rows=384..447 nnz=649540 entry_batches=2572 rhs_stride=649800
  p7 rows=448..511 nnz=648426 entry_batches=2566 rhs_stride=648688
  nnz=5191460 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 14430753398 cyc  HW: 7968750210 cyc  speedup: 1.8x
[perf] cyc/work: SW=694 HW=383
[perf] Throughput: SW=0.000 GOPS (0.71 MOPS)  HW=0.001 GOPS (1.30 MOPS)
[perf] Canonical Bandwidth Eff: SW=355.00 MOPS/GBPS  HW=433.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=260.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=124613504 hw_stream=168198144 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-80 density=20 N=4 repeat 1/3
[setup] O SpMM xfmr-80 M=512 K=33792 N=4 density=20% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=432414 entry_batches=1722 rhs_stride=432672
  p1 rows=64..127 nnz=433056 entry_batches=1728 rhs_stride=433312
  p2 rows=128..191 nnz=431824 entry_batches=1720 rhs_stride=432080
  p3 rows=192..255 nnz=432382 entry_batches=1725 rhs_stride=432640
  p4 rows=256..319 nnz=432739 entry_batches=1726 rhs_stride=433000
  p5 rows=320..383 nnz=433443 entry_batches=1724 rhs_stride=433704
  p6 rows=384..447 nnz=431840 entry_batches=1721 rhs_stride=432096
  p7 rows=448..511 nnz=433474 entry_batches=1725 rhs_stride=433736
  nnz=3461172 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 9869272823 cyc  HW: 5558076603 cyc  speedup: 1.7x
[perf] cyc/work: SW=712 HW=401
[perf] Throughput: SW=0.000 GOPS (0.70 MOPS)  HW=0.001 GOPS (1.24 MOPS)
[perf] Canonical Bandwidth Eff: SW=350.00 MOPS/GBPS  HW=413.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=248.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=83086592 hw_stream=113000448 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-80 density=20 N=4 repeat 2/3
[setup] O SpMM xfmr-80 M=512 K=33792 N=4 density=20% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=432414 entry_batches=1722 rhs_stride=432672
  p1 rows=64..127 nnz=433056 entry_batches=1728 rhs_stride=433312
  p2 rows=128..191 nnz=431824 entry_batches=1720 rhs_stride=432080
  p3 rows=192..255 nnz=432382 entry_batches=1725 rhs_stride=432640
  p4 rows=256..319 nnz=432739 entry_batches=1726 rhs_stride=433000
  p5 rows=320..383 nnz=433443 entry_batches=1724 rhs_stride=433704
  p6 rows=384..447 nnz=431840 entry_batches=1721 rhs_stride=432096
  p7 rows=448..511 nnz=433474 entry_batches=1725 rhs_stride=433736
  nnz=3461172 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 9869395152 cyc  HW: 5558074653 cyc  speedup: 1.7x
[perf] cyc/work: SW=712 HW=401
[perf] Throughput: SW=0.000 GOPS (0.70 MOPS)  HW=0.001 GOPS (1.24 MOPS)
[perf] Canonical Bandwidth Eff: SW=350.00 MOPS/GBPS  HW=413.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=248.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=83086592 hw_stream=113000448 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-80 density=20 N=4 repeat 3/3
[setup] O SpMM xfmr-80 M=512 K=33792 N=4 density=20% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=432414 entry_batches=1722 rhs_stride=432672
  p1 rows=64..127 nnz=433056 entry_batches=1728 rhs_stride=433312
  p2 rows=128..191 nnz=431824 entry_batches=1720 rhs_stride=432080
  p3 rows=192..255 nnz=432382 entry_batches=1725 rhs_stride=432640
  p4 rows=256..319 nnz=432739 entry_batches=1726 rhs_stride=433000
  p5 rows=320..383 nnz=433443 entry_batches=1724 rhs_stride=433704
  p6 rows=384..447 nnz=431840 entry_batches=1721 rhs_stride=432096
  p7 rows=448..511 nnz=433474 entry_batches=1725 rhs_stride=433736
  nnz=3461172 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 9869376857 cyc  HW: 5558074653 cyc  speedup: 1.7x
[perf] cyc/work: SW=712 HW=401
[perf] Throughput: SW=0.000 GOPS (0.70 MOPS)  HW=0.001 GOPS (1.24 MOPS)
[perf] Canonical Bandwidth Eff: SW=350.00 MOPS/GBPS  HW=413.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=248.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=83086592 hw_stream=113000448 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-90 density=10 N=4 repeat 1/3
[setup] O SpMM xfmr-90 M=512 K=33792 N=4 density=10% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=216210 entry_batches=887 rhs_stride=216472
  p1 rows=64..127 nnz=215992 entry_batches=887 rhs_stride=216248
  p2 rows=128..191 nnz=215894 entry_batches=886 rhs_stride=216152
  p3 rows=192..255 nnz=216839 entry_batches=888 rhs_stride=217096
  p4 rows=256..319 nnz=215460 entry_batches=881 rhs_stride=215720
  p5 rows=320..383 nnz=216494 entry_batches=888 rhs_stride=216752
  p6 rows=384..447 nnz=216324 entry_batches=885 rhs_stride=216584
  p7 rows=448..511 nnz=216661 entry_batches=883 rhs_stride=216920
  nnz=1729874 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 5057357886 cyc  HW: 2900448836 cyc  speedup: 1.7x
[perf] cyc/work: SW=730 HW=419
[perf] Throughput: SW=0.000 GOPS (0.68 MOPS)  HW=0.001 GOPS (1.19 MOPS)
[perf] Canonical Bandwidth Eff: SW=340.00 MOPS/GBPS  HW=396.66 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=238.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=41535440 hw_stream=58064896 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-90 density=10 N=4 repeat 2/3
[setup] O SpMM xfmr-90 M=512 K=33792 N=4 density=10% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=216210 entry_batches=887 rhs_stride=216472
  p1 rows=64..127 nnz=215992 entry_batches=887 rhs_stride=216248
  p2 rows=128..191 nnz=215894 entry_batches=886 rhs_stride=216152
  p3 rows=192..255 nnz=216839 entry_batches=888 rhs_stride=217096
  p4 rows=256..319 nnz=215460 entry_batches=881 rhs_stride=215720
  p5 rows=320..383 nnz=216494 entry_batches=888 rhs_stride=216752
  p6 rows=384..447 nnz=216324 entry_batches=885 rhs_stride=216584
  p7 rows=448..511 nnz=216661 entry_batches=883 rhs_stride=216920
  nnz=1729874 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 5057230929 cyc  HW: 2900452111 cyc  speedup: 1.7x
[perf] cyc/work: SW=730 HW=419
[perf] Throughput: SW=0.000 GOPS (0.68 MOPS)  HW=0.001 GOPS (1.19 MOPS)
[perf] Canonical Bandwidth Eff: SW=340.00 MOPS/GBPS  HW=396.66 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=238.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=41535440 hw_stream=58064896 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-90 density=10 N=4 repeat 3/3
[setup] O SpMM xfmr-90 M=512 K=33792 N=4 density=10% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=216210 entry_batches=887 rhs_stride=216472
  p1 rows=64..127 nnz=215992 entry_batches=887 rhs_stride=216248
  p2 rows=128..191 nnz=215894 entry_batches=886 rhs_stride=216152
  p3 rows=192..255 nnz=216839 entry_batches=888 rhs_stride=217096
  p4 rows=256..319 nnz=215460 entry_batches=881 rhs_stride=215720
  p5 rows=320..383 nnz=216494 entry_batches=888 rhs_stride=216752
  p6 rows=384..447 nnz=216324 entry_batches=885 rhs_stride=216584
  p7 rows=448..511 nnz=216661 entry_batches=883 rhs_stride=216920
  nnz=1729874 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 5057337120 cyc  HW: 2900445022 cyc  speedup: 1.7x
[perf] cyc/work: SW=730 HW=419
[perf] Throughput: SW=0.000 GOPS (0.68 MOPS)  HW=0.001 GOPS (1.19 MOPS)
[perf] Canonical Bandwidth Eff: SW=340.00 MOPS/GBPS  HW=396.66 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=238.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=5 MB/s
[perf] bytes: canonical=41535440 hw_stream=58064896 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-95 density=5 N=4 repeat 1/3
[setup] O SpMM xfmr-95 M=512 K=33792 N=4 density=5% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=107991 entry_batches=448 rhs_stride=108248
  p1 rows=64..127 nnz=108050 entry_batches=450 rhs_stride=108312
  p2 rows=128..191 nnz=107836 entry_batches=448 rhs_stride=108096
  p3 rows=192..255 nnz=108210 entry_batches=448 rhs_stride=108472
  p4 rows=256..319 nnz=108028 entry_batches=448 rhs_stride=108288
  p5 rows=320..383 nnz=108056 entry_batches=448 rhs_stride=108312
  p6 rows=384..447 nnz=107952 entry_batches=449 rhs_stride=108208
  p7 rows=448..511 nnz=107819 entry_batches=449 rhs_stride=108080
  nnz=863942 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 2557544727 cyc  HW: 1479115013 cyc  speedup: 1.7x
[perf] cyc/work: SW=740 HW=428
[perf] Throughput: SW=0.000 GOPS (0.67 MOPS)  HW=0.001 GOPS (1.16 MOPS)
[perf] Canonical Bandwidth Eff: SW=335.00 MOPS/GBPS  HW=386.66 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=290.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=4 MB/s
[perf] bytes: canonical=20753072 hw_stream=29417472 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-95 density=5 N=4 repeat 2/3
[setup] O SpMM xfmr-95 M=512 K=33792 N=4 density=5% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=107991 entry_batches=448 rhs_stride=108248
  p1 rows=64..127 nnz=108050 entry_batches=450 rhs_stride=108312
  p2 rows=128..191 nnz=107836 entry_batches=448 rhs_stride=108096
  p3 rows=192..255 nnz=108210 entry_batches=448 rhs_stride=108472
  p4 rows=256..319 nnz=108028 entry_batches=448 rhs_stride=108288
  p5 rows=320..383 nnz=108056 entry_batches=448 rhs_stride=108312
  p6 rows=384..447 nnz=107952 entry_batches=449 rhs_stride=108208
  p7 rows=448..511 nnz=107819 entry_batches=449 rhs_stride=108080
  nnz=863942 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 2557617810 cyc  HW: 1479115013 cyc  speedup: 1.7x
[perf] cyc/work: SW=740 HW=428
[perf] Throughput: SW=0.000 GOPS (0.67 MOPS)  HW=0.001 GOPS (1.16 MOPS)
[perf] Canonical Bandwidth Eff: SW=335.00 MOPS/GBPS  HW=386.66 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=290.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=4 MB/s
[perf] bytes: canonical=20753072 hw_stream=29417472 (HW cycles include RHS software prejoin)

[O] CSR32 SpMM transformer-95 density=5 N=4 repeat 3/3
[setup] O SpMM xfmr-95 M=512 K=33792 N=4 density=5% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=107991 entry_batches=448 rhs_stride=108248
  p1 rows=64..127 nnz=108050 entry_batches=450 rhs_stride=108312
  p2 rows=128..191 nnz=107836 entry_batches=448 rhs_stride=108096
  p3 rows=192..255 nnz=108210 entry_batches=448 rhs_stride=108472
  p4 rows=256..319 nnz=108028 entry_batches=448 rhs_stride=108288
  p5 rows=320..383 nnz=108056 entry_batches=448 rhs_stride=108312
  p6 rows=384..447 nnz=107952 entry_batches=449 rhs_stride=108208
  p7 rows=448..511 nnz=107819 entry_batches=449 rhs_stride=108080
  nnz=863942 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[perf] SW: 2557499469 cyc  HW: 1479115495 cyc  speedup: 1.7x
[perf] cyc/work: SW=740 HW=428
[perf] Throughput: SW=0.000 GOPS (0.67 MOPS)  HW=0.001 GOPS (1.16 MOPS)
[perf] Canonical Bandwidth Eff: SW=335.00 MOPS/GBPS  HW=386.66 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=290.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=4 MB/s
[perf] bytes: canonical=20753072 hw_stream=29417472 (HW cycles include RHS software prejoin)

[O] Final averaged results (3 repeats requested)
Kernel      Case           Shape             Den Pass AvgHWcyc    HW_GOPS  StreamBW  StreamEff CanonEff  AvgSWcyc    Speedup
----------  -------------  ----------------  --- ---- ----------- -------- --------- ---------- --------- ----------- -------
CSR-SpMV    xfmr-50        512x33792          50 3/3   1441300080    0.003        12     250.00    166.66  4157931369    2.8x
CSR-SpMV    xfmr-60        512x33792          40 3/3   1298702030    0.002        10     266.00    177.33  3474886653    2.6x
CSR-SpMV    xfmr-70        512x33792          30 3/3   1135372605    0.002         9     253.33    175.38  2766841944    2.4x
CSR-SpMV    xfmr-80        512x33792          20 3/3    917460585    0.001         7     268.57    170.90  2003324722    2.1x
CSR-SpMV    xfmr-90        512x33792          10 3/3    579252445    0.001         6     248.33    186.25  1116671146    1.9x
CSR-SpMV    xfmr-95        512x33792           5 3/3    329417241    0.001         5     262.00    187.14   596885776    1.8x
CSR-SpMM    xfmr-50-N4     512x33792x4        50 3/3  12058461545    0.001         5     286.00    357.50 22825850411    1.8x
CSR-SpMM    xfmr-60-N4     512x33792x4        40 3/3  10138976731    0.001         5     272.00    340.00 18753499245    1.8x
CSR-SpMM    xfmr-70-N4     512x33792x4        30 3/3   7968758359    0.001         5     260.00    433.33 14430740281    1.8x
CSR-SpMM    xfmr-80-N4     512x33792x4        20 3/3   5558075303    0.001         5     248.00    413.33  9869348277    1.7x
CSR-SpMM    xfmr-90-N4     512x33792x4        10 3/3   2900448656    0.001         5     238.00    396.66  5057308645    1.7x
CSR-SpMM    xfmr-95-N4     512x33792x4         5 3/3   1479115173    0.001         4     290.00    386.66  2557554002    1.7x

[O] StreamBW is estimated MB/s from the bytes actually streamed by the HW path.
[O] CanonEff uses canonical dense/CSR byte accounting; CSR RHS prejoin time is included in HW cycles.

[W] Phase 2: sparse demo averaged suite
[W] This phase keeps only demos 6 and 7.

[D] Sparse demo 6-7 averaged benchmark suite
[D] Repeats per runnable case: 3

[D] Demo 6 SpMV repeat 1/3
[setup] D6 Sparse aggregation M=512 K=33792 density=15% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=324025 entry_batches=1293 rhs_stride=324288
  p1 rows=64..127 nnz=324458 entry_batches=1296 rhs_stride=324720
  p2 rows=128..191 nnz=323529 entry_batches=1293 rhs_stride=323792
  p3 rows=192..255 nnz=324157 entry_batches=1294 rhs_stride=324416
  p4 rows=256..319 nnz=323394 entry_batches=1292 rhs_stride=323656
  p5 rows=320..383 nnz=325291 entry_batches=1292 rhs_stride=325552
  p6 rows=384..447 nnz=323939 entry_batches=1293 rhs_stride=324200
  p7 rows=448..511 nnz=324516 entry_batches=1293 rhs_stride=324776
  nnz=2593309 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[demo] bias+ReLU checksum=0x68327357
[perf] SW: 1579698289 cyc  HW: 769018481 cyc  speedup: 2.0x
[perf] cyc/work: SW=609 HW=296
[perf] Throughput: SW=0.000 GOPS (0.82 MOPS)  HW=0.001 GOPS (1.68 MOPS)
[perf] Canonical Bandwidth Eff: SW=205.00 MOPS/GBPS  HW=168.00 MOPS/GBPS
[perf] HBM BW (canonical est): SW=4 MB/s  HW=10 MB/s
[perf] Stream Bandwidth Eff: HW=280.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=6 MB/s
[perf] bytes: canonical=31125884 hw_stream=21213184 (HW cycles include RHS software prejoin)

[D] Demo 6 SpMV repeat 2/3
[setup] D6 Sparse aggregation M=512 K=33792 density=15% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=324025 entry_batches=1293 rhs_stride=324288
  p1 rows=64..127 nnz=324458 entry_batches=1296 rhs_stride=324720
  p2 rows=128..191 nnz=323529 entry_batches=1293 rhs_stride=323792
  p3 rows=192..255 nnz=324157 entry_batches=1294 rhs_stride=324416
  p4 rows=256..319 nnz=323394 entry_batches=1292 rhs_stride=323656
  p5 rows=320..383 nnz=325291 entry_batches=1292 rhs_stride=325552
  p6 rows=384..447 nnz=323939 entry_batches=1293 rhs_stride=324200
  p7 rows=448..511 nnz=324516 entry_batches=1293 rhs_stride=324776
  nnz=2593309 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[demo] bias+ReLU checksum=0x68327357
[perf] SW: 1579652848 cyc  HW: 769020210 cyc  speedup: 2.0x
[perf] cyc/work: SW=609 HW=296
[perf] Throughput: SW=0.000 GOPS (0.82 MOPS)  HW=0.001 GOPS (1.68 MOPS)
[perf] Canonical Bandwidth Eff: SW=205.00 MOPS/GBPS  HW=168.00 MOPS/GBPS
[perf] HBM BW (canonical est): SW=4 MB/s  HW=10 MB/s
[perf] Stream Bandwidth Eff: HW=280.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=6 MB/s
[perf] bytes: canonical=31125884 hw_stream=21213184 (HW cycles include RHS software prejoin)

[D] Demo 6 SpMV repeat 3/3
[setup] D6 Sparse aggregation M=512 K=33792 density=15% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=324025 entry_batches=1293 rhs_stride=324288
  p1 rows=64..127 nnz=324458 entry_batches=1296 rhs_stride=324720
  p2 rows=128..191 nnz=323529 entry_batches=1293 rhs_stride=323792
  p3 rows=192..255 nnz=324157 entry_batches=1294 rhs_stride=324416
  p4 rows=256..319 nnz=323394 entry_batches=1292 rhs_stride=323656
  p5 rows=320..383 nnz=325291 entry_batches=1292 rhs_stride=325552
  p6 rows=384..447 nnz=323939 entry_batches=1293 rhs_stride=324200
  p7 rows=448..511 nnz=324516 entry_batches=1293 rhs_stride=324776
  nnz=2593309 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[demo] bias+ReLU checksum=0x68327357
[perf] SW: 1579621734 cyc  HW: 769018481 cyc  speedup: 2.0x
[perf] cyc/work: SW=609 HW=296
[perf] Throughput: SW=0.000 GOPS (0.82 MOPS)  HW=0.001 GOPS (1.68 MOPS)
[perf] Canonical Bandwidth Eff: SW=205.00 MOPS/GBPS  HW=168.00 MOPS/GBPS
[perf] HBM BW (canonical est): SW=4 MB/s  HW=10 MB/s
[perf] Stream Bandwidth Eff: HW=280.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=6 MB/s
[perf] bytes: canonical=31125884 hw_stream=21213184 (HW cycles include RHS software prejoin)

[D] Demo 7 SpMM repeat 1/3
[setup] D7 Sparse linear M=512 K=33792 N=4 density=15% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=324025 entry_batches=1293 rhs_stride=324288
  p1 rows=64..127 nnz=324458 entry_batches=1296 rhs_stride=324720
  p2 rows=128..191 nnz=323529 entry_batches=1293 rhs_stride=323792
  p3 rows=192..255 nnz=324157 entry_batches=1294 rhs_stride=324416
  p4 rows=256..319 nnz=323394 entry_batches=1292 rhs_stride=323656
  p5 rows=320..383 nnz=325291 entry_batches=1292 rhs_stride=325552
  p6 rows=384..447 nnz=323939 entry_batches=1293 rhs_stride=324200
  p7 rows=448..511 nnz=324516 entry_batches=1293 rhs_stride=324776
  nnz=2593309 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[demo] bias+ReLU checksum=0x10eaeb91
[perf] SW: 7488518867 cyc  HW: 4257047234 cyc  speedup: 1.7x
[perf] cyc/work: SW=721 HW=410
[perf] Throughput: SW=0.000 GOPS (0.69 MOPS)  HW=0.001 GOPS (1.21 MOPS)
[perf] Canonical Bandwidth Eff: SW=345.00 MOPS/GBPS  HW=403.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=302.50 MOPS/GBPS
[perf] HBM BW (stream est): HW=4 MB/s
[perf] bytes: canonical=62257880 hw_stream=84779008 (HW cycles include RHS software prejoin)

[D] Demo 7 SpMM repeat 2/3
[setup] D7 Sparse linear M=512 K=33792 N=4 density=15% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=324025 entry_batches=1293 rhs_stride=324288
  p1 rows=64..127 nnz=324458 entry_batches=1296 rhs_stride=324720
  p2 rows=128..191 nnz=323529 entry_batches=1293 rhs_stride=323792
  p3 rows=192..255 nnz=324157 entry_batches=1294 rhs_stride=324416
  p4 rows=256..319 nnz=323394 entry_batches=1292 rhs_stride=323656
  p5 rows=320..383 nnz=325291 entry_batches=1292 rhs_stride=325552
  p6 rows=384..447 nnz=323939 entry_batches=1293 rhs_stride=324200
  p7 rows=448..511 nnz=324516 entry_batches=1293 rhs_stride=324776
  nnz=2593309 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[demo] bias+ReLU checksum=0x10eaeb91
[perf] SW: 7488581689 cyc  HW: 4257043842 cyc  speedup: 1.7x
[perf] cyc/work: SW=721 HW=410
[perf] Throughput: SW=0.000 GOPS (0.69 MOPS)  HW=0.001 GOPS (1.21 MOPS)
[perf] Canonical Bandwidth Eff: SW=345.00 MOPS/GBPS  HW=403.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=302.50 MOPS/GBPS
[perf] HBM BW (stream est): HW=4 MB/s
[perf] bytes: canonical=62257880 hw_stream=84779008 (HW cycles include RHS software prejoin)

[D] Demo 7 SpMM repeat 3/3
[setup] D7 Sparse linear M=512 K=33792 N=4 density=15% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=324025 entry_batches=1293 rhs_stride=324288
  p1 rows=64..127 nnz=324458 entry_batches=1296 rhs_stride=324720
  p2 rows=128..191 nnz=323529 entry_batches=1293 rhs_stride=323792
  p3 rows=192..255 nnz=324157 entry_batches=1294 rhs_stride=324416
  p4 rows=256..319 nnz=323394 entry_batches=1292 rhs_stride=323656
  p5 rows=320..383 nnz=325291 entry_batches=1292 rhs_stride=325552
  p6 rows=384..447 nnz=323939 entry_batches=1293 rhs_stride=324200
  p7 rows=448..511 nnz=324516 entry_batches=1293 rhs_stride=324776
  nnz=2593309 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[demo] bias+ReLU checksum=0x10eaeb91
[perf] SW: 7488611934 cyc  HW: 4257058288 cyc  speedup: 1.7x
[perf] cyc/work: SW=721 HW=410
[perf] Throughput: SW=0.000 GOPS (0.69 MOPS)  HW=0.001 GOPS (1.21 MOPS)
[perf] Canonical Bandwidth Eff: SW=345.00 MOPS/GBPS  HW=403.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=302.50 MOPS/GBPS
[perf] HBM BW (stream est): HW=4 MB/s
[perf] bytes: canonical=62257880 hw_stream=84779008 (HW cycles include RHS software prejoin)

[D] Final sparse demo 6-7 averaged results (3 repeats requested)
Demo   Case                   Shape        Pass AvgAccelCyc AvgTotalCyc  HW_GOPS  StreamBW  Eff       Checksum
-----  ---------------------  -----------  ---- ----------- ----------- -------- --------- -------- ----------
D6     Sparse SpMV agg        512x33792    3/3    769019057         N/A    0.001         6   280.00 0x68327357
D7     Sparse SpMM linear     512x33792x4  3/3   4257049788         N/A    0.001         4   302.50 0x10eaeb91

[D] AvgAccelCyc is the accelerated kernel portion: GEMM/GEMV/CSR HW cycles.
[D] AvgTotalCyc is only printed for demos with a measured post-kernel path.

[W] Sparse software-vs-hardware speedup summary
Case                   Shape        HWAvgTotal   SW1xTotal    Speedup   Checksum    Note
---------------------  -----------  -----------  -----------  --------  ----------  ----------------
[setup] W D6 Sparse aggregation M=512 K=33792 density=15% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=324025 entry_batches=1293 rhs_stride=324288
  p1 rows=64..127 nnz=324458 entry_batches=1296 rhs_stride=324720
  p2 rows=128..191 nnz=323529 entry_batches=1293 rhs_stride=323792
  p3 rows=192..255 nnz=324157 entry_batches=1294 rhs_stride=324416
  p4 rows=256..319 nnz=323394 entry_batches=1292 rhs_stride=323656
  p5 rows=320..383 nnz=325291 entry_batches=1292 rhs_stride=325552
  p6 rows=384..447 nnz=323939 entry_batches=1293 rhs_stride=324200
  p7 rows=448..511 nnz=324516 entry_batches=1293 rhs_stride=324776
  nnz=2593309 (*float*%)
  format: canonical CSR32 + prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMV...
[flush] flushing caches...
[hw]  running 8-port CSR32 SpMV...
[verify] checking CSR32 SpMV CFU output vs reference...
  PASS: all 512 elements match
[demo] bias+ReLU checksum=0x68327357
[perf] SW: 1579644773 cyc  HW: 769021448 cyc  speedup: 2.0x
[perf] cyc/work: SW=609 HW=296
[perf] Throughput: SW=0.000 GOPS (0.82 MOPS)  HW=0.001 GOPS (1.68 MOPS)
[perf] Canonical Bandwidth Eff: SW=205.00 MOPS/GBPS  HW=168.00 MOPS/GBPS
[perf] HBM BW (canonical est): SW=4 MB/s  HW=10 MB/s
[perf] Stream Bandwidth Eff: HW=280.00 MOPS/GBPS
[perf] HBM BW (stream est): HW=6 MB/s
[perf] bytes: canonical=31125884 hw_stream=21213184 (HW cycles include RHS software prejoin)
[setup] W D7 Sparse linear M=512 K=33792 N=4 density=15% active_ports=8 generating CSR32...
  p0 rows=0..63 nnz=324025 entry_batches=1293 rhs_stride=324288
  p1 rows=64..127 nnz=324458 entry_batches=1296 rhs_stride=324720
  p2 rows=128..191 nnz=323529 entry_batches=1293 rhs_stride=323792
  p3 rows=192..255 nnz=324157 entry_batches=1294 rhs_stride=324416
  p4 rows=256..319 nnz=323394 entry_batches=1292 rhs_stride=323656
  p5 rows=320..383 nnz=325291 entry_batches=1292 rhs_stride=325552
  p6 rows=384..447 nnz=323939 entry_batches=1293 rhs_stride=324200
  p7 rows=448..511 nnz=324516 entry_batches=1293 rhs_stride=324776
  nnz=2593309 (*float*%)
  format: canonical CSR32 + per-tile prejoined int32 RHS stream
[sw]  computing CPU reference CSR32 SpMM...
[flush] flushing canonical CSR/dense inputs...
[hw]  running 8-port CSR32 SpMM in N_TILE=4 groups...
[verify] checking CSR32 SpMM CFU output vs reference...
  PASS: all 512 x 4 elements match
[demo] bias+ReLU checksum=0x10eaeb91
[perf] SW: 7488491737 cyc  HW: 4257044476 cyc  speedup: 1.7x
[perf] cyc/work: SW=721 HW=410
[perf] Throughput: SW=0.000 GOPS (0.69 MOPS)  HW=0.001 GOPS (1.21 MOPS)
[perf] Canonical Bandwidth Eff: SW=345.00 MOPS/GBPS  HW=403.33 MOPS/GBPS
[perf] HBM BW (canonical est): SW=2 MB/s  HW=3 MB/s
[perf] Stream Bandwidth Eff: HW=302.50 MOPS/GBPS
[perf] HBM BW (stream est): HW=4 MB/s
[perf] bytes: canonical=62257880 hw_stream=84779008 (HW cycles include RHS software prejoin)
Sparse SpMV agg        512x33792      769021448   1579644773     2.0x  0x68327357  
Sparse SpMM linear     512x33792x4   4257044476   7488491737     1.7x  0x10eaeb91  

[W] D6 and D7 use one extra CSR32 run because their software references already exist.

[W] Reprinting sparse O summary table at end

[O] Final averaged results (3 repeats requested)
Kernel      Case           Shape             Den Pass AvgHWcyc    HW_GOPS  StreamBW  StreamEff CanonEff  AvgSWcyc    Speedup
----------  -------------  ----------------  --- ---- ----------- -------- --------- ---------- --------- ----------- -------
CSR-SpMV    xfmr-50        512x33792          50 3/3   1441300080    0.003        12     250.00    166.66  4157931369    2.8x
CSR-SpMV    xfmr-60        512x33792          40 3/3   1298702030    0.002        10     266.00    177.33  3474886653    2.6x
CSR-SpMV    xfmr-70        512x33792          30 3/3   1135372605    0.002         9     253.33    175.38  2766841944    2.4x
CSR-SpMV    xfmr-80        512x33792          20 3/3    917460585    0.001         7     268.57    170.90  2003324722    2.1x
CSR-SpMV    xfmr-90        512x33792          10 3/3    579252445    0.001         6     248.33    186.25  1116671146    1.9x
CSR-SpMV    xfmr-95        512x33792           5 3/3    329417241    0.001         5     262.00    187.14   596885776    1.8x
CSR-SpMM    xfmr-50-N4     512x33792x4        50 3/3  12058461545    0.001         5     286.00    357.50 22825850411    1.8x
CSR-SpMM    xfmr-60-N4     512x33792x4        40 3/3  10138976731    0.001         5     272.00    340.00 18753499245    1.8x
CSR-SpMM    xfmr-70-N4     512x33792x4        30 3/3   7968758359    0.001         5     260.00    433.33 14430740281    1.8x
CSR-SpMM    xfmr-80-N4     512x33792x4        20 3/3   5558075303    0.001         5     248.00    413.33  9869348277    1.7x
CSR-SpMM    xfmr-90-N4     512x33792x4        10 3/3   2900448656    0.001         5     238.00    396.66  5057308645    1.7x
CSR-SpMM    xfmr-95-N4     512x33792x4         5 3/3   1479115173    0.001         4     290.00    386.66  2557554002    1.7x

[O] StreamBW is estimated MB/s from the bytes actually streamed by the HW path.
[O] CanonEff uses canonical dense/CSR byte accounting; CSR RHS prejoin time is included in HW cycles.

[W] Reprinting sparse D summary table at end

[D] Final sparse demo 6-7 averaged results (3 repeats requested)
Demo   Case                   Shape        Pass AvgAccelCyc AvgTotalCyc  HW_GOPS  StreamBW  Eff       Checksum
-----  ---------------------  -----------  ---- ----------- ----------- -------- --------- -------- ----------
D6     Sparse SpMV agg        512x33792    3/3    769019057         N/A    0.001         6   280.00 0x68327357
D7     Sparse SpMM linear     512x33792x4  3/3   4257049788         N/A    0.001         4   302.50 0x10eaeb91

[D] AvgAccelCyc is the accelerated kernel portion: GEMM/GEMV/CSR HW cycles.
[D] AvgTotalCyc is only printed for demos with a measured post-kernel path.

[W] Sparse exhaustive suite complete.

[P] Sparse combined suite complete.

