# =============================================================================
#  Makefile  –  AXI-to-AHB Bridge UVM Verification  (QuestaSim)
#
#  !! IMPORTANT – Run from the sim/ subdirectory !!
#
#    mkdir -p sim && cp Makefile sim/ && cd sim && make <target>
#
#  Expected project layout (relative to this Makefile):
#    ../rtl/           – Verilog RTL + SV interfaces
#    ../tb/            – Testbench top (axi2ahb_tb_top.sv)
#    ../test/          – UVM package  (axi2ahb_pkg.sv)
#    ../axi_agent_top/ – AXI UVM agent (included via +incdir)
#    ../ahb_agent_top/ – AHB UVM agent (included via +incdir)
# =============================================================================

# ─── Simulator Tool Aliases ──────────────────────────────────────────────────
SIMULATOR = QuestaSim

VLIB      = vlib
VMAP      = vmap
VLOG      = vlog
VSIM      = vsim
VCOVER    = vcover

WORK      = work

# ─── RTL File Lists ─────────────────────────────────────────────────────────
RTL_DIR  = ../AXI2AHB_RTL

# Plain Verilog (.v) – compiled first
RTL_V    = $(RTL_DIR)/addr_fifo.sv       \
           $(RTL_DIR)/data_fifo.sv       \
           $(RTL_DIR)/write_fifo.v      \
           $(RTL_DIR)/size_fifo.v       \
           $(RTL_DIR)/resp_fifo.v       \
           $(RTL_DIR)/rdata_fifo.v      \
           $(RTL_DIR)/id_send_fifo.v    \
           $(RTL_DIR)/id_resp_fifo.v    \
           $(RTL_DIR)/fifo_wrapper.v    \
           $(RTL_DIR)/axi_controller.sv  \
           $(RTL_DIR)/ahb_controller.sv  \
           $(RTL_DIR)/axi2ahb_bridge_top.sv \
           $(RTL_DIR)/axi2fifo.sv \
           $(RTL_DIR)/fifo2axi.sv

# SystemVerilog interfaces – compiled after Verilog modules
RTL_SV   = $(RTL_DIR)/axi_interface.sv       \
           $(RTL_DIR)/ahb_interface.sv        \
           $(RTL_DIR)/axi_rst_if.sv    \
           $(RTL_DIR)/ahb_rst_interface.sv    \

# ─── Testbench & Package ─────────────────────────────────────────────────────
TB_TOP   = ../tb/top.sv
PKG_FILE = ../test/axi2ahb_pkg.sv

# ─── Include Directories ─────────────────────────────────────────────────────
INC      = +incdir+../axi_agent_top    \
           +incdir+../ahb_agent_top    \
           +incdir+../tb               \
           +incdir+../test

# Trimmed includes for pkg compilation (avoids duplicate typedef from +incdir agent folders)
INC_PKG  = +incdir+../tb              \
           +incdir+../test

# RTL step needs no agent +incdir (RTL files don't reference agent files)
INC_RTL  = +incdir+../tb              \
           +incdir+../test

# ─── Simulation Flags ────────────────────────────────────────────────────────
VSIMOPT    = -voptargs=+acc=rn
VSIMCOV    = -coverage -sva
VSIM_BASE  = $(VSIM) -c $(VSIMOPT) $(VSIMCOV) -cvgperinstance

# ─── Per-Test Artefact Names ─────────────────────────────────────────────────
WLFS   = wave1.wlf  wave2.wlf  wave3.wlf  wave4.wlf  wave5.wlf  \
          wave6.wlf  wave7.wlf  wave8.wlf  wave9.wlf  wave10.wlf

COVDBS = cov1 cov2 cov3 cov4 cov5 cov6 cov7 cov8 cov9 cov10

# Batch-mode do-string macro: $(call batch, <cov_db_name>)
batch = -do "log -r /* ; coverage save -onexit $(1) ; run -all ; quit"

# =============================================================================
#  Sanity-check macro – called at the top of sv_cmp
#  Verifies that ../rtl exists (i.e. you're running from sim/)
# =============================================================================
define CHECK_DIR
        @if [ ! -d "../AXI2AHB_RTL" ]; then \
            echo ""; \
            echo "  ╔══════════════════════════════════════════════════════════╗"; \
            echo "  ║  ERROR: ../AXI2AHB_RTL not found!                                         ║"; \
            echo "  ║                                                          ║"; \
            echo "  ║  This Makefile must be run from the sim/ subdirectory.  ║"; \
            echo "  ║                                                          ║"; \
            echo "  ║  Fix:                                                    ║"; \
            echo "  ║    mkdir -p sim                                          ║"; \
            echo "  ║    cp Makefile sim/                                      ║"; \
            echo "  ║    cd sim                                                ║"; \
            echo "  ║    make sv_cmp                                           ║"; \
            echo "  ╚══════════════════════════════════════════════════════════╝"; \
            echo ""; \
            exit 1; \
        fi
        @if [ ! -d "../tb" ] || [ ! -d "../test" ]; then \
            echo ""; \
            echo "  ERROR: ../tb or ../test not found."; \
            echo "  Check your repo is fully cloned and the Makefile is in sim/."; \
            echo ""; \
            exit 1; \
        fi
        @echo "  ✔ Directory layout OK  (running from: $$(pwd))"
endef

# =============================================================================
#  PHONY Targets
# =============================================================================
.PHONY: help clean sv_cmp \
        run_test1  run_test2  run_test3  run_test4  run_test5  \
        run_test6  run_test7  run_test8  run_test9  run_test10 \
        view_wave1  view_wave2  view_wave3  view_wave4  view_wave5  \
        view_wave6  view_wave7  view_wave8  view_wave9  view_wave10 \
        regress merge_cov report cov

# =============================================================================
#  help
# =============================================================================
help:
        @echo ""
        @echo "  AXI2AHB Bridge UVM TB  –  QuestaSim targets"
        @echo "  ─────────────────────────────────────────────────────────────"
        @echo "  SETUP (first time only):"
        @echo "    mkdir -p sim && cp Makefile sim/ && cd sim"
        @echo ""
        @echo "  COMPILE:"
        @echo "    make sv_cmp           Compile RTL + TB (3-step)"
        @echo ""
        @echo "  INDIVIDUAL TESTS:"
        @echo "    make run_test1        Single WRITE         (axi_write_test)"
        @echo "    make run_test2        Single READ          (axi_read_test)"
        @echo "    make run_test3        Write-then-Read      (axi_wr_rd_test)"
        @echo "    make run_test4        INCR burst write     (axi_incr_burst_test)"
        @echo "    make run_test5        WRAP burst write     (axi_wrap_burst_test)"
        @echo "    make run_test6        FIXED burst write    (axi_fixed_burst_test)"
        @echo "    make run_test7        Stress 5 WR+RD       (axi_stress_test)"
        @echo "    make run_test8        Random 50 txns       (axi_random_test)"
        @echo "    make run_test9        Back-to-back 8 wr    (axi_back2back_write_test)"
        @echo "    make run_test10       Narrow B/HW/W        (axi_narrow_transfer_test)"
        @echo ""
        @echo "  WAVEFORMS (opens Questa GUI):"
        @echo "    make view_wave<N>     Open waveform N  (N = 1 … 10)"
        @echo ""
        @echo "  REGRESSION + COVERAGE:"
        @echo "    make regress          Full regression (clean→compile→all tests→cov)"
        @echo "    make merge_cov        Merge all 10 coverage DBs → cov_merged"
        @echo "    make report           HTML report → covhtmlreport/index.html"
        @echo "    make cov              Open report in Firefox"
        @echo ""
        @echo "  HOUSEKEEPING:"
        @echo "    make clean            Remove all generated artefacts"
        @echo ""

# =============================================================================
#  sv_cmp – Three-step compilation
#
#  Step 1: Verilog RTL (.v) + SV interfaces
#  Step 2: UVM Package  (must be in work lib before TB top imports it)
#  Step 3: Testbench top
# =============================================================================
sv_cmp:
        $(CHECK_DIR)
        $(VLIB) $(WORK)
        $(VMAP) work $(WORK)
        @echo "── Step 1: Compile Verilog RTL + SV Interfaces ──────────────────"
        $(VLOG) -sv -work $(WORK) $(INC_RTL) \
                $(RTL_V) $(RTL_SV)
        @echo "── Step 2: Compile UVM Package ──────────────────────────────────"
        $(VLOG) -sv -work $(WORK) $(INC_PKG) \
                $(PKG_FILE)
        @echo "── Step 3: Compile top.sv (imports axi2ahb_pkg) ─────────────────"
        $(VLOG) -sv -work $(WORK) $(INC) \
                ../tb/top.sv
        @echo "── Step 4: Compile Testbench Top ────────────────────────────────"
        $(VLOG) -sv -work $(WORK) $(INC) \
                $(TB_TOP)
        @echo "── Compilation complete ─────────────────────────────────────────"

# =============================================================================
#  Individual Test Targets
# =============================================================================
run_test1: sv_cmp
        @echo "── Test 1: axi_write_test ───────────────────────────────────────"
        $(VSIM_BASE) -wlf wave1.wlf \
            $(call batch,cov1) -l test1.log -sv_seed random \
            work.top \
            +UVM_TESTNAME=write_to_slave_test \
            +UVM_VERBOSITY=UVM_MEDIUM
        @echo "=== run_test1 done ===" | tee -a test1.log

run_test2: sv_cmp
        @echo "── Test 2: axi_read_test ────────────────────────────────────────"
        $(VSIM_BASE) -wlf wave2.wlf \
            $(call batch,cov2) -l test2.log -sv_seed random \
            work.top \
            +UVM_TESTNAME=read_from_slave_test \
            +UVM_VERBOSITY=UVM_MEDIUM
        @echo "=== run_test2 done ===" | tee -a test2.log

run_test3: sv_cmp
        @echo "── Test 3: axi_wr_rd_test ───────────────────────────────────────"
        $(VSIM_BASE) -wlf wave3.wlf \
            $(call batch,cov3) -l test3.log -sv_seed random \
            work.top \
            +UVM_TESTNAME=axi2ahb_reset \
            +UVM_VERBOSITY=UVM_MEDIUM
        @echo "=== run_test3 done ===" | tee -a test3.log

run_test4: sv_cmp
        @echo "── Test 4: axi_incr_burst_test ──────────────────────────────────"
        $(VSIM_BASE) -wlf wave4.wlf \
            $(call batch,cov4) -l test4.log -sv_seed random \
            work.top \
            +UVM_TESTNAME=write_to_slave_test \
            +UVM_VERBOSITY=UVM_MEDIUM
        @echo "=== run_test4 done ===" | tee -a test4.log

run_test5: sv_cmp
        @echo "── Test 5: axi_wrap_burst_test ──────────────────────────────────"
        $(VSIM_BASE) -wlf wave5.wlf \
            $(call batch,cov5) -l test5.log -sv_seed random \
            work.top \
            +UVM_TESTNAME=read_from_slave_test \
            +UVM_VERBOSITY=UVM_MEDIUM
        @echo "=== run_test5 done ===" | tee -a test5.log

run_test6: sv_cmp
        @echo "── Test 6: axi_fixed_burst_test ─────────────────────────────────"
        $(VSIM_BASE) -wlf wave6.wlf \
            $(call batch,cov6) -l test6.log -sv_seed random \
            work.top \
            +UVM_TESTNAME=axi2ahb_reset \
            +UVM_VERBOSITY=UVM_MEDIUM
        @echo "=== run_test6 done ===" | tee -a test6.log

run_test7: sv_cmp
        @echo "── Test 7: axi_stress_test ──────────────────────────────────────"
        $(VSIM_BASE) -wlf wave7.wlf \
            $(call batch,cov7) -l test7.log -sv_seed random \
            work.top \
            +UVM_TESTNAME=write_to_slave_test \
            +UVM_VERBOSITY=UVM_MEDIUM
        @echo "=== run_test7 done ===" | tee -a test7.log

run_test8: sv_cmp
        @echo "── Test 8: axi_random_test ──────────────────────────────────────"
        $(VSIM_BASE) -wlf wave8.wlf \
            $(call batch,cov8) -l test8.log -sv_seed random \
            work.top \
            +UVM_TESTNAME=read_from_slave_test \
            +UVM_VERBOSITY=UVM_MEDIUM
        @echo "=== run_test8 done ===" | tee -a test8.log

run_test9: sv_cmp
        @echo "── Test 9: axi_back2back_write_test ─────────────────────────────"
        $(VSIM_BASE) -wlf wave9.wlf \
            $(call batch,cov9) -l test9.log -sv_seed random \
            work.top \
            +UVM_TESTNAME=write_to_slave_test \
            +UVM_VERBOSITY=UVM_MEDIUM
        @echo "=== run_test9 done ===" | tee -a test9.log

run_test10: sv_cmp
        @echo "── Test 10: axi_narrow_transfer_test ────────────────────────────"
        $(VSIM_BASE) -wlf wave10.wlf \
            $(call batch,cov10) -l test10.log -sv_seed random \
            work.top \
            +UVM_TESTNAME=read_from_slave_test \
            +UVM_VERBOSITY=UVM_MEDIUM
        @echo "=== run_test10 done ===" | tee -a test10.log

# =============================================================================
#  Waveform Viewer  (opens Questa GUI as a background process)
# =============================================================================
view_wave1:  ; $(VSIM) -view wave1.wlf  &
view_wave2:  ; $(VSIM) -view wave2.wlf  &
view_wave3:  ; $(VSIM) -view wave3.wlf  &
view_wave4:  ; $(VSIM) -view wave4.wlf  &
view_wave5:  ; $(VSIM) -view wave5.wlf  &
view_wave6:  ; $(VSIM) -view wave6.wlf  &
view_wave7:  ; $(VSIM) -view wave7.wlf  &
view_wave8:  ; $(VSIM) -view wave8.wlf  &
view_wave9:  ; $(VSIM) -view wave9.wlf  &
view_wave10: ; $(VSIM) -view wave10.wlf &

# =============================================================================
#  Full Regression
# =============================================================================
regress: clean sv_cmp \
         run_test1  run_test2  run_test3  run_test4  run_test5  \
         run_test6  run_test7  run_test8  run_test9  run_test10 \
         merge_cov report
        @echo ""
        @echo "════════════════════════════════════════════"
        @echo "  REGRESSION COMPLETE"
        @echo "  Coverage →  covhtmlreport/index.html"
        @echo "  Logs     →  test1.log … test10.log"
        @echo "════════════════════════════════════════════"
        @echo ""
        @grep -h "\[OK\]\|\[FAIL\]\|TEST RESULT\|UVM_ERROR\|UVM_FATAL" \
              test1.log  test2.log  test3.log  test4.log  test5.log   \
              test6.log  test7.log  test8.log  test9.log  test10.log  \
              2>/dev/null | sort | uniq -c | sort -rn || true

# =============================================================================
#  Coverage
# =============================================================================
merge_cov:
        $(VCOVER) merge cov_merged \
                  cov1 cov2 cov3 cov4 cov5 cov6 cov7 cov8 cov9 cov10

report:
        $(VCOVER) report -cvg -details -nocompactcrossbins \
                  -codeAll -assert -directive \
                  -html -output covhtmlreport \
                  cov_merged

cov:
        firefox covhtmlreport/index.html &

# =============================================================================
#  Clean
# =============================================================================
clean:
        rm -rf transcript* *.log *.wlf \
               cov? cov?? cov_merged covhtmlreport \
               modelsim.ini $(WORK) .bak*
        @echo "── Clean complete ───────────────────────────────────────────────"
