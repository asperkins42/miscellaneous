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

[w] Phase 1: kernel software baselines (1x each)
[w] SW GEMM kernel sweep is capped at N<=2048 to keep softcore runtime reasonable.
Kernel      Case           Shape             Den      SW1xCyc   SW_GOPS  CanonEff   Checksum
----------  -------------  ----------------  ---  -----------  --------  --------  ----------
[w][perf] SW GEMV N=1024 cyc=18944369 GOPS=0.027 checksum=0xb1dbc34d
GEMV        dense-1024     N=1024              -     18944369     0.027     477.06  0xb1dbc34d
[w][perf] SW GEMV N=2048 cyc=256044429 GOPS=0.008 checksum=0xff1001c9
GEMV        dense-2048     N=2048              -    256044429     0.008     481.76  0xff1001c9
[w][perf] SW GEMV N=4096 cyc=1023847029 GOPS=0.008 checksum=0xcb2b0fbe
GEMV        dense-4096     N=4096              -   1023847029     0.008     481.76  0xcb2b0fbe
[w][perf] SW GEMV N=8192 cyc=4092928362 GOPS=0.008 checksum=0xff833018
GEMV        dense-8192     N=8192              -   4092928362     0.008     481.76  0xff833018
[w][perf] SW GEMV N=16384 cyc=16365261389 GOPS=0.008 checksum=0x6a154d60
GEMV        dense-16384    N=16384             -  16365261389     0.008     482.35  0x6a154d60
[w][perf] SW GEMM N=512 cyc=49936475167 GOPS=0.001 checksum=0x3e91001c
GEMM        dense-512      N=512               -  49936475167     0.001       0.00  0x3e91001c
[w][perf] SW GEMM N=1024 cyc=399475815893 GOPS=0.001 checksum=0xaab07d3b
GEMM        dense-1024     N=1024              -  399475815893     0.001       0.00  0xaab07d3b
[w][perf] SW GEMM N=2048 cyc=3259943732988 GOPS=0.001 checksum=0x5191dd1d
GEMM        dense-2048     N=2048              -  3259943732988     0.001       0.00  0x5191dd1d
GEMM        dense-4096     N=4096              -          N/A       N/A       N/A         cap
GEMM        dense-8192     N=8192              -          N/A       N/A       N/A         cap
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=50% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1954483099 cyc GOPS=0.002 checksum=0x9ca64d72
CSR-SpMV    xfmr-50        512x33792          50   1954483099     0.002     170.00  0x9ca64d72
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=40% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1703606854 cyc GOPS=0.002 checksum=0x3e004e8d
CSR-SpMV    xfmr-60        512x33792          40   1703606854     0.002     169.16  0x3e004e8d
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=30% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1433556617 cyc GOPS=0.001 checksum=0xaf75d5d4
CSR-SpMV    xfmr-70        512x33792          30   1433556617     0.001     181.00  0xaf75d5d4
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=20% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=1112566482 cyc GOPS=0.001 checksum=0xe600e581
CSR-SpMV    xfmr-80        512x33792          20   1112566482     0.001     172.22  0xe600e581
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=10% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=672768630 cyc GOPS=0.001 checksum=0x515403b1
CSR-SpMV    xfmr-90        512x33792          10    672768630     0.001     182.85  0x515403b1
[sw-only][setup] w CSR32 SpMV M=512 K=33792 density=5% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMV SW=375321039 cyc GOPS=0.001 checksum=0x1ea9af7a
CSR-SpMV    xfmr-95        512x33792           5    375321039     0.001     191.66  0x1ea9af7a
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=50% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=13976795055 cyc GOPS=0.001 checksum=0x0505057e
CSR-SpMM    xfmr-50-N4     512x33792x4        50  13976795055     0.001     410.00  0x0505057e
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=40% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=11664252156 cyc GOPS=0.001 checksum=0xec604139
CSR-SpMM    xfmr-60-N4     512x33792x4        40  11664252156     0.001     393.33  0xec604139
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=30% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=9106034484 cyc GOPS=0.001 checksum=0xb42cc209
CSR-SpMM    xfmr-70-N4     512x33792x4        30   9106034484     0.001     380.00  0xb42cc209
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=20% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=6310589384 cyc GOPS=0.001 checksum=0xdd4c3ed7
CSR-SpMM    xfmr-80-N4     512x33792x4        20   6310589384     0.001     363.33  0xdd4c3ed7
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=10% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=3273453335 cyc GOPS=0.001 checksum=0xb844c84f
CSR-SpMM    xfmr-90-N4     512x33792x4        10   3273453335     0.001     350.00  0xb844c84f
[sw-only][setup] w CSR32 SpMM M=512 K=33792 N=4 density=5% active_ports=8 generating CSR32...
[sw-only][perf] CSR32 SpMM SW=1665026375 cyc GOPS=0.001 checksum=0xd9ee6046
CSR-SpMM    xfmr-95-N4     512x33792x4         5   1665026375     0.001     343.33  0xd9ee6046

### DDR (SOFTWARE ONLY)

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

