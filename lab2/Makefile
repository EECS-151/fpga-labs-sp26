SHELL                   := $(shell which bash) -o pipefail
ABS_TOP                 := $(subst /cygdrive/c/,C:/, $(shell pwd))
SCRIPTS                 := $(ABS_TOP)/../scripts
VIVADO                  ?= /share/instsww/xilinx/2025.2/Vivado/bin/vivado
VIVADO_OPTS             ?= -nolog -nojournal -mode batch
FPGA_PART               ?= xczu3eg-sfvc784-2-e
RTL                     += $(subst /cygdrive/c/,C:/, $(shell find $(ABS_TOP)/src -type f -name "*.v"))
RTL_FPGA				:= $(ABS_TOP)/src/z1top.v
CONSTRAINTS             += $(subst /cygdrive/c/,C:/, $(shell find $(ABS_TOP)/src -type f -name "*.xdc"))
TOP                     ?= z1top
SIM_RTL_PRIMER          := $(shell find $(ABS_TOP)/sim -type f -name "*.v")
SIM_TARGETS             := $(shell realpath --relative-to $(ABS_TOP) $(SIM_RTL_PRIMER))
VCS                     := /home/ff/eecs151/hammer-tools/synopsys/vcs/P-2019.06/bin/vcs -full64
VCS_OPTS                := -notice -line +lint=all,noVCDE,noNS,noSVA-UA -sverilog -timescale=1ns/10ps -debug
VCS_TARGETS             := $(SIM_TARGETS:%.v=%.vpd)
SIM_RTL                 := $(subst /cygdrive/c/,C:/, $(shell find $(ABS_TOP)/sim -type f -name "*.v"))
IVERILOG                := iverilog
IVERILOG_OPTS           := -D IVERILOG=1 -g2012 -gassertions -Wall -Wno-timescale
IVERILOG_TARGETS        := $(SIM_TARGETS:%.v=%.fst)
VVP                     := vvp
RTL_PRIMER				:= $(ABS_TOP)/src/d_flip_flop.sv

sim/%.tb: sim/%.v FORCE
	cd sim && $(VCS) $(VCS_OPTS) -o $*.tb $*.v $(RTL_PRIMER) ../src/$(patsubst %_tb.v,%.sv,$(notdir $<))

# Special case where one testbench depends on two sources
sim/decoder_4_to_16_tb.tb: sim/decoder_4_to_16_tb.v FORCE
	cd sim && $(VCS) $(VCS_OPTS) -o decoder_4_to_16_tb.tb decoder_4_to_16_tb.v $(RTL_PRIMER) ../src/line_decoder.sv ../src/$(patsubst %_tb.v,%.sv,$(notdir $<))

$(VCS_TARGETS): sim/%.vpd: sim/%.tb FORCE
	cd sim && ./$*.tb +verbose=1 +vpdfile+$*.vpd

sim-all: 
	make sim/one_bit_comparator_structural_tb.vpd 
	make sim/one_bit_comparator_behavioral_tb.vpd 
	make sim/one_bit_comparator_always_tb.vpd 
	make sim/four_bit_comparator_always_tb.vpd 
	make sim/shift_register_structural_tb.vpd 
	make sim/shift_register_behavioral_tb.vpd 
	make sim/simple_counter_tb.vpd 
	make sim/decoder_4_to_16_tb.vpd

build/target.tcl: $(RTL_FPGA) $(CONSTRAINTS)
	mkdir -p build
	truncate -s 0 $@
	echo "set ABS_TOP                        $(ABS_TOP)"    >> $@
	echo "set TOP                            $(TOP)"    >> $@
	echo "set FPGA_PART                      $(FPGA_PART)"  >> $@
	echo "set_param general.maxThreads       4"    >> $@
	echo "set_param general.maxBackupLogs    0"    >> $@
	echo -n "set RTL_FPGA { " >> $@
	FLIST="$(RTL_FPGA)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	echo "}" >> $@
	echo -n "set CONSTRAINTS { " >> $@
	FLIST="$(CONSTRAINTS)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	echo "}" >> $@

setup: build/target.tcl

elaborate: build/target.tcl $(SCRIPTS)/elaborate.tcl
	mkdir -p ./build
	cd ./build && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/elaborate.tcl |& tee elaborate.log

build/synth/$(TOP).dcp: build/target.tcl $(SCRIPTS)/synth_lab1.tcl
	mkdir -p ./build/synth/
	cd ./build/synth/ && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/synth_lab1.tcl |& tee synth.log

synth: build/synth/$(TOP).dcp

build/impl/$(TOP).bit: build/synth/$(TOP).dcp $(SCRIPTS)/impl.tcl
	mkdir -p ./build/impl/
	cd ./build/impl && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/impl.tcl |& tee impl.log

impl: build/impl/$(TOP).bit
all: build/impl/$(TOP).bit

program: build/impl/$(TOP).bit $(SCRIPTS)/program.tcl
	@rm -f $(SCRIPTS)/assign_board_test_log.tmp; \
	assign-fpga-board > $(SCRIPTS)/assign_board_test_log.tmp 2>&1 & \
	ASSIGN_PID=$$!; \
	while ! grep -q "Vivado hw_server port:" $(SCRIPTS)/assign_board_test_log.tmp && ! grep -q "already have an instance" $(SCRIPTS)/assign_board_test_log.tmp; do \
		sleep 0.1; \
	done; \
	if grep -q "already have an instance" $(SCRIPTS)/assign_board_test_log.tmp; then \
		PORT=$$(cat $(SCRIPTS)/port.tmp); \
		SERIAL=$$(cat $(SCRIPTS)/serial.tmp); \
	else \
		sleep infinity | assign-fpga-board > $(SCRIPTS)/assign_board_log.tmp 2>&1 & \
		while ! grep -q "Vivado hw_server port:" $(SCRIPTS)/assign_board_log.tmp && ! grep -q "already have an instance" $(SCRIPTS)/assign_board_log.tmp; do \
			sleep 0.1; \
		done; \
		PORT=$$(grep -oP 'Vivado hw_server port: \K\d+' $(SCRIPTS)/assign_board_log.tmp); \
		SERIAL=$$(grep -oP 'serial \K[A-Z0-9]+' $(SCRIPTS)/assign_board_log.tmp); \
		echo $$PORT > $(SCRIPTS)/port.tmp; \
		echo $$SERIAL > $(SCRIPTS)/serial.tmp; \
		/share/instsww/xilinx/2025.2/Vivado/bin/hw_server -stcp:localhost:$$PORT > /dev/null 2>&1 & \
	fi; \
	echo "BOARD SERIAL: $$SERIAL"; \
	cd build/impl && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/program.tcl -tclargs $$PORT

program-force:
	cd build/impl && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/program.tcl

vivado: build
	cd build && nohup $(VIVADO) </dev/null >/dev/null 2>&1 &

lint:
	verilator --lint-only --top-module $(TOP) $(RTL)

sim_build/compile_simlib/synopsys_sim.setup:
	mkdir -p sim_build/compile_simlib
	cd build/sim_build/compile_simlib && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/compile_simlib.tcl

compile_simlib: sim_build/compile_simlib/synopsys_sim.setup

clean:
	rm -rf ./build $(junk) *.daidir sim/output.txt \
	sim/*.tb sim/*.daidir sim/csrc \
	sim/ucli.key sim/*.vpd sim/*.vcd \
	sim/*.tbi sim/*.fst sim/*.jou sim/*.log sim/*.out
	killall sleep
	cd $(SCRIPTS)
	rm -f port.tmp assign_board_log.tmp serial.tmp

.PHONY: setup synth impl program program-force vivado all clean %.tb FORCE
.PRECIOUS: sim/%.tb sim/%.tbi sim/%.fst sim/%.vpd
