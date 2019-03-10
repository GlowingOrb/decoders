Implementation of message passing based decoders for LDPC codes using Python/numpy. 
Includes, min-sum (MSA) and sum-product (SPA) algorithms for binary erasure (BEC), binary symmetric (BSC) and binary-AWGN (biawgn) channels.

### Dependencies
Following Python/package versions (or higher) are required.
* `Python version 3.5.2`
* `numpy version 1.12.0`
* `scipy version 0.18.1`


## Exploring pre-computed results
Checkout `assests` branch to see all pre-compupted results. These include different codes, simulation results and plots.
<img src="../assets/plots/BIAWGN_MSA_ensemble.png?raw=true" width="280" />
<img src="../assets/plots/BSC_SPA_compare.png?raw=true" width="280" />
<img src="../assets/plots/MSA_SPA_BIAWGN.png?raw=true" width="280" />
<img src="../assets/plots/BEC_compare.png?raw=true" width="280" />
<img src="../assets/plots/BEC_max_iter.png?raw=true" width="280" />
<img src="../assets/plots/HMG_BIAWGN.png?raw=true" width="280" />


## Starting from scratch

### Running simulations
* Make directories `codes` and `data` in the root directory.
* Execute `python src/codes.py 10 1200 3 6` to generate 10 random samples from `LDPC(1200,3,6)` ensemble.
* Run simulations using `run_sims.sh {CASE} {PARA} {ARGS}` command. For example,
  * `./run_sims.sh HMG` executes all Hamming code related simulations **sequentially**.
  * `./run_sims.sh BEC SEQL --data-dir=./data --console` executes some LDPC and BEC related simulations **sequentially** while printing logs onto console.
  * `./run_sims.sh BEC PARA --data-dir=./data` executes the same **in parallel**.
  * Use the latter only on a **dedicated server** as it will take large amount of CPU.
  * See [`run_sims.sh`](../master/run_sims.sh) for other choices of `{CASE}`.

* If running the simulations on [Niagara cluster](https://docs.computecanada.ca/wiki/Niagara), need to setup environment first by executing [`setup_env.sh`](../master/niagara/setup_env.sh).
* Execute `./run_sims.sh BEC PARA --data-dir=$SCRATCH` to test if simulations run properly.
* All simulations can be submitted for later excution on Niagara by using command `sbatch niagara/submit_job.sh`.


### Generating plots
* Make directory `plots` in the root directory.
* Execute  `./plot_results.sh HMG`  to view and save Hamming code related plots in PNG format.
* Execute `./plot_results.sh BEC pdf ./data ./plots` to view and save BEC related plots in PDF format.
* Execute `./plot_results.sh BEC png ./data ./plots --silent --error=ber` to silently save BEC related bit-error-rate plots.
* Execute `./plot_results.sh ALL png ./data ./plots --silent --error=wer` to generate all word-error-rate plots.
* If running on the Niagara cluster execute `./plot_results.sh ALL png $SCRATCH $SCRATCH --silent --agg` to use the proper back-end for `matplotlib`.


## Specific commands

### Simulations
* `python src/main.py bec 1200_3_6_rand_ldpc_1 SPA --codeword=1 --console --params .5 .475 .45 .425 .4 .375 .35 .325 .3`
* `python src/main.py biawgn 7_4_hamming SPA --codeword=1 --params .01 .05 .1 .5 1 2 4 6 --console`
* See [`run_sims.sh`](../master/run_sims.sh) for more.

### Ensemble average
* `python src/stats.py bec 1200_3_6_rand_ldpc SPA`

### Plots
* `python src/graph.py bec 1200_3_6_ldpc SPA single --error ber`
* `python src/graph.py bsc 7_4_hamming SPA ML comp_dec --error wer`
* See [`plot_results.sh`](../master/plot_results.sh) for more.