# ADAPT-AXI-DMA

### AXI4-Based Direct Memory Access Controller | RTL Design, Verification & ASIC Physical Design

![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)
![Verification](https://img.shields.io/badge/Verification-Icarus%20Verilog-orange)
![Synthesis](https://img.shields.io/badge/Synthesis-Yosys-purple)
![Physical Design](https://img.shields.io/badge/Physical%20Design-OpenROAD-green)
![PDK](https://img.shields.io/badge/PDK-Sky130-red)
![Status](https://img.shields.io/badge/Project-Physical%20Design%20In%20Progress-yellow)

**ADAPT-AXI-DMA** is a SystemVerilog-based hardware design project implementing an AXI4-based Direct Memory Access (DMA) controller. The project covers RTL design, functional verification, AXI4 protocol handling, stress testing, logic synthesis, and ASIC physical design using open-source EDA tools.

The DMA controller is designed to move data between memory locations without requiring continuous CPU intervention.

The project follows a hardware development workflow from RTL implementation and simulation through synthesis and physical implementation using Yosys, OpenROAD, and the Sky130 platform.

---

## Table of Contents

- [Overview](#overview)
- [Project Objectives](#project-objectives)
- [Architecture](#architecture)
- [Features](#features)
- [Repository Structure](#repository-structure)
- [RTL Modules](#rtl-modules)
- [AXI4 DMA Operation](#axi4-dma-operation)
- [Functional Verification](#functional-verification)
- [Verification Results](#verification-results)
- [ASIC Physical Design](#asic-physical-design)
- [Measured Implementation Report](#measured-implementation-report)
- [Timing, Routing, and Sign-Off Status](#timing-routing-and-sign-off-status)
- [Technology Stack](#technology-stack)
- [Running the Simulation](#running-the-simulation)
- [Design Challenges](#design-challenges)
- [Future Improvements](#future-improvements)
- [Learning Outcomes](#learning-outcomes)
- [Author](#author)

---

## Overview

A Direct Memory Access (DMA) controller enables data movement between memory locations while reducing the processing workload of the CPU.

This project implements a DMA engine with AXI4 read and write interfaces, a DMA controller, configuration registers, and FIFO-based buffering.

The design was developed and tested using SystemVerilog and Icarus Verilog. Functional verification includes directed tests, protocol backpressure scenarios, reset handling, FIFO stress testing, AXI error responses, and randomized data transfers.

The project also explores ASIC implementation using Yosys, the Sky130 platform, and OpenROAD.

### Project Highlights

- SystemVerilog RTL implementation of an AXI4 DMA controller.
- Separate AXI4 read and write master interfaces.
- DMA controller and configuration register logic.
- FIFO-based data buffering.
- AXI4 VALID/READY handshake handling.
- Directed and randomized functional verification.
- Reset, boundary, stress, and error-response testing.
- RTL synthesis and ASIC physical design exploration.
- GDSII export and layout inspection.
- Open-source EDA workflow.

---

## Project Objectives

1. Design a modular DMA controller using SystemVerilog.
2. Implement AXI4 read and write transaction handling.
3. Support data movement between source and destination memory addresses.
4. Handle AXI4 VALID/READY handshakes and backpressure.
5. Verify functionality under normal and abnormal operating conditions.
6. Develop testbenches to check data integrity and transaction behavior.
7. Explore synthesis and ASIC physical implementation using open-source tools.
8. Understand the process of taking an RTL design toward GDSII generation.

---

## Architecture

```text
                   +----------------------+
                   |     DMA Registers    |
                   |                      |
                   | Source Address       |
                   | Destination Address  |
                   | Transfer Length      |
                   | Control / Status     |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   |    DMA Controller    |
                   |                      |
                   | Transfer Sequencing  |
                   | Read/Write Control   |
                   | Status Management    |
                   +----------+-----------+
                              |
                   +----------+-----------+
                   |                      |
                   v                      v
        +-------------------+  +-------------------+
        | AXI4 Read Master  |  | AXI4 Write Master |
        |                   |  |                   |
        | AR Channel        |  | AW Channel        |
        | R Channel         |  | W Channel         |
        |                   |  | B Channel         |
        +---------+---------+  +---------+---------+
                  |                      ^
                  v                      |
             +-------------------------------+
             |        DMA Data FIFO          |
             |                               |
             | Temporary Read Data Buffer    |
             +-------------------------------+
                              |
                              v
                   +----------------------+
                   |     AXI Memory       |
                   |        Model         |
                   +----------------------+
```

*Conceptual architecture diagram. Exact connections and control behavior are defined by the RTL implementation.*

### Main Components

**DMA Controller**  
Coordinates DMA operations, manages transfer sequencing, and controls interaction between the read and write interfaces.

**AXI4 Read Master**  
Issues read-address requests and receives read data from the memory interface.

**AXI4 Write Master**  
Issues write-address requests, transfers write data, and handles write responses.

**DMA FIFO**  
Buffers data between the read and write sides, helping accommodate differences in transaction timing.

**DMA Registers**  
Store configuration and status information required to initiate and monitor transfers.

**AXI Memory Model**  
Provides a simulation environment for testing memory transactions, handshakes, backpressure, and data integrity.

---

## Features

### AXI4 Interface Handling

- Read address channel: AR.
- Read data channel: R.
- Write address channel: AW.
- Write data channel: W.
- Write response channel: B.
- VALID/READY handshake handling.
- Backpressure testing.
- Error-response testing.

### DMA Functionality

- Configurable source and destination addresses.
- Transfer-length handling.
- Read-to-write data movement.
- FIFO-based buffering.
- Reset handling.
- Multiple consecutive transfers.
- Data-integrity checking.

### Verification

- Directed functional tests.
- Write-address backpressure testing.
- Reset during active transfers.
- Transfer-boundary testing.
- Long-stall scenarios.
- FIFO stress testing.
- AXI error-response testing.
- Randomized transfer testing.

---

## Repository Structure

```text
ADAPT-AXI-DMA/
│
├── rtl/
│   ├── axi/
│   │   ├── axi4_read_master.sv
│   │   └── axi4_write_master.sv
│   │
│   ├── dma/
│   │   ├── dma_registers.sv
│   │   ├── dma_controller.sv
│   │   └── dma_fifo.sv
│   │
│   └── top/
│       └── axi4_dma_top.sv
│
├── tb/
│   ├── axi_memory_model.sv
│   └── axi4_dma_tb.sv
│
├── physical_design/
│   ├── logs/
│   ├── reports/
│   ├── results/
│   └── scripts/
│       └── render_gds.py
│
├── README.md
└── .gitignore
```

*Keep this structure synchronized with the actual repository. Additional scripts, configuration files, and generated reports may exist in the project.*

---

## RTL Modules

### `axi4_read_master.sv`

Implements the AXI4 read-side transaction logic.

Responsibilities include:

- Generating read-address requests.
- Handling ARVALID and ARREADY.
- Receiving read data through the R channel.
- Handling RVALID and RREADY.
- Managing read transaction progress.

### `axi4_write_master.sv`

Implements the AXI4 write-side transaction logic.

Responsibilities include:

- Generating write-address requests.
- Handling AWVALID and AWREADY.
- Transmitting data through the W channel.
- Handling WVALID and WREADY.
- Processing write responses through the B channel.

### `dma_controller.sv`

Coordinates DMA operations, manages transfer sequencing, coordinates read and write operations, tracks transfer progress, and handles reset and completion conditions.

### `dma_registers.sv`

Stores DMA configuration and status information required by the controller.

### `dma_fifo.sv`

Buffers data transferred from the AXI4 read side to the write side.

### `axi4_dma_top.sv`

Integrates the main DMA modules into the top-level design.

### `axi_memory_model.sv`

Models memory transactions for simulation and supports testing of AXI handshakes, stalls, and error responses.

### `axi4_dma_tb.sv`

Acts as the main testbench for functional verification. It initiates transfers, exercises protocol conditions, and checks whether the observed behavior matches expectations.

---

## AXI4 DMA Operation

The general transfer sequence is:

1. Configure the DMA source address.
2. Configure the DMA destination address.
3. Configure the transfer length.
4. Initiate the DMA operation.
5. The read master requests data from the source address.
6. The memory model returns read data.
7. The received data is buffered in the FIFO.
8. The write master sends data to the destination address.
9. The write master processes the AXI response.
10. The controller tracks transfer progress and completion.

The exact behavior depends on the implemented controller state machine, FIFO control logic, and AXI master interfaces.

### AXI4 Handshake

A transfer occurs when VALID and READY are both asserted on the same clock edge.

```systemverilog
wire read_address_handshake  = ARVALID && ARREADY;
wire read_data_handshake     = RVALID  && RREADY;

wire write_address_handshake = AWVALID && AWREADY;
wire write_data_handshake    = WVALID  && WREADY;

wire write_response_handshake = BVALID && BREADY;
```

These expressions illustrate the handshake conditions. The actual implementation uses the signal names and logic defined in the RTL.

A correctly designed interface must preserve transaction information during stalls and avoid losing or duplicating data because of backpressure.

---

## Functional Verification

Functional verification was performed using SystemVerilog testbench code and Icarus Verilog.

The verification process checks data integrity, transaction sequencing, reset behavior, backpressure handling, and error-response scenarios.

### Verification Results

| Test | Scenario | Result |
|---|---|---|
| Test 5A | AWREADY backpressure | PASS |
| Test 7 | Reset during an active DMA transfer | PASS |
| Test 8 | Transfer boundary test using a 4-byte transfer | PASS |
| Test 9 | AWREADY blocked for 10 cycles | PASS |
| Test 10 | RVALID delayed for 10 cycles | PASS |
| Test 11 | Four consecutive transfers | PASS |
| Test 13 | FIFO stress test with a 1024-byte transfer | PASS |
| Test 14 | AXI read/write error responses | PASS |
| Test 15 | 20 randomized DMA transfers | PASS |

*The table records test outcomes reported during development. Test numbering follows the existing testbench; not every intermediate test number is listed.*

### Test 5A: AWREADY Backpressure

Introduces delays on the AXI write-address READY signal to verify that the DMA handles write-address backpressure without losing transaction information.

**Reported result: PASS.**

### Test 7: Reset During Active Transfer

Tests reset behavior while a transfer is active and checks whether the DMA can recover and perform a subsequent transfer. The test log reported that the DMA restarted after reset and transferred 64 bytes.

**Reported result: PASS.**

### Test 8: Transfer Boundary

Exercises a small transfer with a length of 4 bytes to check basic transfer-length handling and data movement.

**Reported result: PASS.**

### Test 9: Long AWREADY Stall

Blocks the write-address READY signal for 10 cycles to test prolonged write-address backpressure.

**Reported result: PASS.**

### Test 10: Long RVALID Stall

Delays the read-data response for 10 cycles to test behavior when read data is not immediately available.

**Reported result: PASS.**

### Test 11: Consecutive Transfers

Four transfers are performed consecutively:

- 16 bytes.
- 32 bytes.
- 64 bytes.
- 20 bytes.

**Reported result: PASS.**

### Test 13: FIFO Stress Test

Performs a 1024-byte transfer.

| Parameter | Value |
|---|---:|
| Transfer length | 1024 bytes |
| Number of 32-bit words | 256 |
| Reported execution time | 2304 cycles |

The test checks data transfer under a larger workload and verifies that the FIFO is empty after the transfer completes.

**Reported result: PASS.**

### Test 14: AXI Error Responses

Introduces AXI error responses, including SLVERR, to examine how the DMA handles unsuccessful transactions.

**Reported result: PASS according to the development test logs.**

This result applies to the tested error-response scenarios and does not establish complete error recovery for every possible AXI condition.

### Test 15: Randomized DMA Transfers

Executes 20 randomized DMA transfers and compares the transferred data against expected values.

**Reported result: PASS.** All randomized data comparisons passed in the reported run.

### Overall Verification Status

The development test log reported:

```text
ALL DMA TESTS PASSED
```

This result applies to the executed simulation tests. It does not constitute formal verification or complete AXI4 compliance certification.

---

## ASIC Physical Design

The project extends beyond RTL development and functional verification into ASIC physical implementation using the Sky130 platform and OpenROAD.

### Physical Design Flow

```text
SystemVerilog RTL
        |
        v
RTL Simulation
        |
        v
Synthesis - Yosys
        |
        v
Floorplanning
        |
        v
Power Distribution Network
        |
        v
Placement
        |
        v
Clock Tree Synthesis
        |
        v
Timing Repair
        |
        v
Global Routing
        |
        v
Detailed Routing
        |
        v
Physical Verification
        |
        v
GDSII Export
        |
        v
Layout Inspection and Validation
```

*This diagram shows the overall implementation flow. Individual stages may require iteration, and not every stage has reached verified final sign-off.*

### Implementation Platform

| Parameter | Details |
|---|---|
| Design | ADAPT-AXI-DMA |
| Design type | AXI4-based DMA controller |
| HDL | SystemVerilog |
| Target platform | Sky130 |
| Synthesis | Yosys |
| Physical implementation | OpenROAD |
| Timing analysis | OpenSTA |
| Layout inspection | KLayout / Magic |
| LVS tool | Netgen |
| Layout format | GDSII |

---

## Measured Implementation Report

The following results are taken from the available OpenROAD placement, clock-tree, routing, and design-check logs. Metrics are labelled by stage where the available output does not establish a final post-route value.

### Placement and Area

| Metric | Reported value |
|---|---:|
| Core area | 52,340.198 µm² |
| Standard-cell placement area | 21,032.672 µm² |
| Non-placeable instance area | 860.826 µm² |
| Macro instance area | 0.000 µm² |
| Target placement density | 60% |
| Average placement-instance area | 12.632 µm² |
| Total instances at placement stage | 2,353 |
| Place instances at placement stage | 1,665 |
| Fixed instances at placement stage | 688 |
| Final global-placement overflow reported in log | 0.099106 |

**Area interpretation:** The standard-cell placement area divided by the reported core area is approximately **40.2%**. This is a derived ratio, not a substitute for the tool's target placement density or a final post-route utilization report.

The placement log reports the target density as 60%. The total instance count includes both place instances and fixed instances, so it should not be treated as the synthesized standard-cell count.

### Clock Tree Synthesis

| Metric | Reported value |
|---|---:|
| Clock roots | 1 |
| Clock buffers inserted | 54 |
| Clock subnets | 54 |
| Clock sinks | 508 |

These values are from the available clock tree synthesis report.

### Routing Statistics

The routing log contains several intermediate detailed-routing iterations. The values below are reported snapshots, not a claim of final routing sign-off.

| Metric | Reported value |
|---|---:|
| Wire length at one routing snapshot | 77,400 µm |
| Vias at that snapshot | 16,149 |
| Detailed-routing violations at an earlier reported iteration | 7,894 |
| Detailed-routing violations at a later reported iteration | 2,980 |
| Final detailed-routing violation count | Not confirmed in the available excerpt |

The log shows that the reported violation count decreased during optimization, but the available output does not establish the final completed routing result.

### DEF Design Statistics

The available DEF report was previously summarized with the following counts:

| Metric | Reported value |
|---|---:|
| Component instances in DEF | 1,817 |
| Pins in DEF | 322 |
| Nets in DEF | 2,093 |

These are DEF file counts and are distinct from the placement-stage instance counts. They may reflect different implementation stages or inclusion rules and should not be directly compared as if they were the same statistic.

### Timing Analysis

The available post-route timing log contains slack values, including `1.36` and `0.27`, but the excerpt does not identify their path type, units, or whether they are the final worst setup and hold values.

Therefore, the following final timing metrics remain unconfirmed:

| Metric | Status |
|---|---|
| Target clock period | Not confirmed |
| Final worst setup slack | Not confirmed |
| Final worst hold slack | Not confirmed |
| Critical-path delay | Not confirmed |
| Total negative setup slack (TNS) | Not confirmed |
| Final timing closure | Not confirmed |

Timing values should be taken from the complete final timing reports and interpreted with their corresponding units and path classifications.

### Physical Checks and Antenna Results

The available design-check output reports:

| Check | Reported result |
|---|---|
| Antenna net violations | 43 |
| Antenna pin violations | 43 |
| Clean antenna sign-off | Not achieved in the reported check |
| Final DRC sign-off | Not confirmed |
| Final LVS result | Not confirmed |
| Power analysis result | Not confirmed |

The antenna results show that additional physical verification and/or repair is required. A GDSII export or layout image does not independently establish DRC cleanliness, LVS equivalence, or timing closure.

### GDSII and Layout Inspection

The project has reached GDSII export, structural validation, and layout visualization according to the development progress.

The existence of a GDSII file is a useful implementation milestone, but the layout should not be described as sign-off clean until the final routing, antenna, DRC, LVS, and timing checks have been reviewed.

---

## Timing, Routing, and Sign-Off Status

| Stage / Check | Current documented status |
|---|---|
| RTL development | Completed |
| Functional simulation | Reported test suite passed |
| Logic synthesis | Performed |
| Floorplanning and placement | Performed |
| Clock tree synthesis | Performed |
| Detailed routing | Executed; violations reported in available log |
| GDSII export | Reported completed |
| Structural validation | Reported completed |
| Layout visualization | Reported completed |
| Detailed-routing sign-off | Pending confirmation of final violation count |
| Antenna sign-off | Pending; 43 net and 43 pin violations reported |
| Final DRC sign-off | Not confirmed |
| Final LVS sign-off | Not confirmed |
| Final timing sign-off | Not confirmed |
| Final power result | Not confirmed |

### Physical Design Completion Checklist

- [ ] Confirm the final detailed-routing violation count.
- [ ] Resolve remaining routing violations.
- [ ] Resolve antenna violations or apply appropriate fixes.
- [ ] Re-run detailed routing after making changes.
- [ ] Verify the final DRC report.
- [ ] Run LVS against the intended reference netlist.
- [ ] Review final setup and hold timing.
- [ ] Confirm the final clock constraints and timing reports.
- [ ] Verify that the final GDSII corresponds to the latest validated implementation.
- [ ] Archive the final reports and implementation metrics.

### Physical Design Conclusion

The project demonstrates the progression of an AXI4 DMA controller from RTL implementation toward an ASIC layout using open-source EDA tools.

The documented results include a reported core area of 52,340.198 µm², standard-cell placement area of 21,032.672 µm², 54 inserted clock buffers, and routing iterations that reduced the reported detailed-routing violations. Antenna violations remain in the available design-check output, and final timing, DRC, and LVS sign-off have not been confirmed.

The next milestone is to resolve the outstanding physical violations, validate timing, complete DRC and LVS checks, and publish the final implementation metrics.

---

## Technology Stack

### Hardware Description and Verification

- SystemVerilog
- Icarus Verilog
- Verilator

### Synthesis and Physical Design

- Yosys
- OpenROAD
- OpenSTA
- Sky130 PDK

### Layout and Physical Verification

- Magic
- Netgen
- KLayout

### Development Environment

- Ubuntu Linux
- Bash
- Git
- GitHub

---

## Running the Simulation

The following commands illustrate how to compile and execute the simulation using Icarus Verilog. Run them from the repository root.

### 1. Check the Installation

```bash
iverilog -V
vvp -V
```

### 2. Compile the RTL and Testbench

```bash
iverilog -g2012 \
  -s axi4_dma_tb \
  -o dma_sim \
  rtl/axi/axi4_read_master.sv \
  rtl/axi/axi4_write_master.sv \
  rtl/dma/dma_registers.sv \
  rtl/dma/dma_controller.sv \
  rtl/dma/dma_fifo.sv \
  rtl/top/axi4_dma_top.sv \
  tb/axi_memory_model.sv \
  tb/axi4_dma_tb.sv
```

**Note:** This command assumes the repository uses the file paths shown in this README. If the project has additional dependencies, packages, include directories, or a different source-file order, update the command accordingly.

### 3. Run the Simulation

```bash
vvp dma_sim
```

### 4. Inspect the Output

Review the console output for:

- Test PASS or FAIL messages.
- Data comparison results.
- AXI handshake behavior.
- Reset recovery.
- FIFO status.
- Transfer completion.
- Simulation errors.

Use the existing testbench as the source of truth for the actual test sequence.

---

## Design Challenges

### 1. AXI4 Backpressure

The DMA must handle cases in which a receiving interface temporarily deasserts READY. Testing delayed READY responses helps identify issues involving transaction sequencing and handshake control.

### 2. Read and Write Coordination

The read and write interfaces operate independently and may experience different amounts of backpressure. FIFO-based buffering helps decouple their timing.

### 3. Reset During Active Transfers

Reset behavior must be tested to identify problems involving stale state, incorrect FIFO contents, and incomplete transactions.

### 4. FIFO Stress

Larger transfers exercise buffering and data movement over longer periods. The reported 1024-byte test provides evidence that the tested configuration can handle a larger transfer.

### 5. Error Responses

AXI error responses introduce conditions that differ from normal successful transactions. The reported error-response tests provide a starting point for validating the controller's behavior under these conditions.

### 6. Detailed Routing Runtime

Physical design can require substantial computational resources, particularly during detailed routing. The DMA implementation encountered long routing runtimes and routing violations, highlighting the importance of congestion analysis, design-rule debugging, and iterative physical optimization.

---

## Future Improvements

- Complete detailed routing and resolve all remaining routing violations.
- Resolve antenna violations and verify the final antenna report.
- Perform and document final static timing analysis.
- Complete DRC and LVS verification.
- Validate the final GDSII against the latest implementation.
- Add reproducible synthesis and physical-design scripts.
- Publish final verified area, cell-count, and timing metrics.
- Expand functional coverage reporting.
- Add assertions for important AXI protocol requirements.
- Develop a UVM-based verification environment.
- Add more extensive randomized and error-recovery tests.
- Evaluate performance across different transfer sizes and backpressure conditions.

These improvements should be marked complete only after implementation and validation.

---

## Learning Outcomes

This project provides practical experience in:

- Modular RTL design using SystemVerilog.
- AXI4 read and write transaction handling.
- VALID/READY handshake mechanisms.
- FIFO-based data buffering.
- Testbench development and functional simulation.
- Backpressure and reset testing.
- Randomized data-integrity testing.
- Logic synthesis using Yosys.
- ASIC physical implementation using OpenROAD.
- Working with the Sky130 platform.
- Debugging routing and physical-design issues.
- Interpreting placement, clock-tree, routing, and timing reports.
- Managing a hardware project using Git and GitHub.

---

## Author

**Praseed Kumar**

Electronics and Communication Engineering  
VIT-AP University

### Areas of Interest

- VLSI Design
- RTL Design
- Design Verification
- ASIC Physical Design
- Digital System Design

### Connect

- GitHub: [Praseedkarn](https://github.com/Praseedkarn)

---

## Acknowledgements

This project uses open-source hardware design and EDA tools, including Icarus Verilog, Yosys, OpenROAD, and the Sky130 platform.

Their documentation and community resources support learning and experimentation across RTL design, verification, synthesis, and ASIC implementation.

---

**ADAPT-AXI-DMA — Designing, verifying, and implementing an AXI4-based DMA controller using open-source EDA tools.**
