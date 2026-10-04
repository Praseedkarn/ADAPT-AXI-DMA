# ADAPT AXI4 DMA Controller
## UVM Verification Document

**Project:** ADAPT — AXI4 DMA Controller  
**Document:** UVM Verification  
**Stage:** 4 — UVM Verification  
**Methodology:** Universal Verification Methodology (UVM)  
**Simulator:** Questa Altera Starter FPGA Edition  
**UVM Version:** UVM 1.2 source environment used by the project  
**Status:** Completed — UVM tests passed

---

## 1. Introduction

After completing directed functional verification, the ADAPT AXI4 DMA Controller was verified using a reusable UVM-based verification environment.

The purpose of the UVM stage was to move from task-based directed testing toward a structured, reusable verification architecture containing transactions, sequences, sequencers, drivers, monitors, agents, a scoreboard, and coverage collection.

The UVM environment verifies the AXI4-Lite control path, AXI4 data path, DMA data integrity, and intentionally injected AXI error responses.

---

## 2. UVM Verification Objectives

The main objectives were:

1. Build a reusable UVM verification environment.
2. Create transaction-level stimulus for DMA operation.
3. Drive AXI4-Lite control transactions.
4. Drive and monitor AXI4 transactions.
5. Monitor DUT activity independently of stimulus generation.
6. Check expected and actual DMA behavior using a scoreboard.
7. Verify data integrity.
8. Test intentional AXI `SLVERR` responses.
9. Collect functional coverage information.
10. Execute regression tests with zero unexpected UVM errors or fatals.

---

# 3. UVM Verification Architecture

The implemented environment follows this structure:

```text
                         ┌────────────────────┐
                         │     UVM TEST       │
                         │ dma_basic_test     │
                         │ dma_error_test     │
                         └─────────┬──────────┘
                                   │
                                   ▼
                         ┌────────────────────┐
                         │     DMA ENV        │
                         └─────────┬──────────┘
                                   │
                 ┌─────────────────┼─────────────────┐
                 │                 │                 │
                 ▼                 ▼                 ▼
        ┌────────────────┐ ┌───────────────┐ ┌──────────────┐
        │ AXI-Lite Agent │ │  AXI4 Agent   │ │  Scoreboard  │
        └───────┬────────┘ └───────┬───────┘ └──────┬───────┘
                │                  │                 │
        ┌───────┼───────┐  ┌───────┼───────┐         │
        │       │       │  │       │       │         │
      Driver Monitor Sequencer Driver Monitor      Checking
                │                  │
                └─────────┬────────┘
                          │
                          ▼
                         DUT

                     ┌──────────────┐
                     │   Coverage   │
                     └──────────────┘
```

---

# 4. UVM Directory Structure

The UVM source files are organized as follows:

```text
uvm/
├── dma_uvm_pkg.sv
│
├── env/
│   └── dma_env.sv
│
├── interfaces/
│   ├── axi4_if.sv
│   └── axi_lite_if.sv
│
├── dut_if/
│   └── dma_dut_if.sv
│
├── agents/
│   ├── axi_master_agent/
│   │   ├── axi_master_agent.sv
│   │   ├── axi_master_driver.sv
│   │   ├── axi_master_monitor.sv
│   │   └── axi_master_sequencer.sv
│   │
│   └── axi_lite_agent/
│       ├── axi_lite_agent.sv
│       ├── axi_lite_driver.sv
│       ├── axi_lite_monitor.sv
│       └── axi_lite_sequencer.sv
│
├── scoreboard/
│   └── dma_scoreboard.sv
│
├── sequences/
│   ├── dma_sequence.sv
│   ├── dma_transaction.sv
│   ├── axi_transaction.sv
│   └── axi_lite_transaction.sv
│
├── coverage/
│   └── dma_coverage.sv
│
├── smoke/
│   └── uvm_smoke.sv
│
└── tests/
    ├── dma_basic_test.sv
    └── dma_error_test.sv
```

---

# 5. UVM Package

The `dma_uvm_pkg.sv` file provides the main package for the UVM environment.

It imports UVM functionality and includes the required project components.

Conceptually:

```text
dma_uvm_pkg
      │
      ├── Transactions
      ├── Sequences
      ├── Sequencers
      ├── Drivers
      ├── Monitors
      ├── Agents
      ├── Scoreboard
      ├── Coverage
      ├── Environment
      └── Tests
```

This allows the testbench to compile and use the complete verification hierarchy as a common package.

---

# 6. Interfaces

The environment uses dedicated SystemVerilog interfaces.

## AXI4 Interface

```text
uvm/interfaces/axi4_if.sv
```

This interface represents the AXI4 data-transfer signals used by the verification environment.

## AXI4-Lite Interface

```text
uvm/interfaces/axi_lite_if.sv
```

This interface represents the AXI4-Lite control/register interface.

## DUT Interface

```text
uvm/dut_if/dma_dut_if.sv
```

This provides the UVM environment with access to relevant DUT-side signals.

Virtual interfaces are supplied to UVM components through the UVM configuration mechanism.

---

# 7. Transactions

Transactions represent individual operations at the UVM transaction level.

The project contains:

```text
dma_transaction.sv
axi_transaction.sv
axi_lite_transaction.sv
```

### DMA Transaction

Represents the high-level DMA configuration and transfer information.

### AXI Transaction

Represents AXI4 transaction information such as:

- Address
- Data
- Response
- Burst information
- Transfer size
- Last indication

### AXI-Lite Transaction

Represents control/register accesses.

Using transactions allows stimulus and checking to be separated from signal-level implementation.

---

# 8. Sequences

The main DMA sequence is:

```text
uvm/sequences/dma_sequence.sv
```

The sequence generates the configuration required for a DMA transfer.

The implemented basic sequence uses:

```text
Source      = 0x08
Destination = 0x0C
Length      = 0x10
Control     = 0x00
Start/Data  = 1
```

The sequence operates through the AXI-Lite sequencer.

---

# 9. Sequencers

Sequencers control the flow of transactions from sequences to drivers.

The environment contains:

```text
AXI4 Sequencer
AXI4-Lite Sequencer
```

The sequence generates transactions and the corresponding sequencer passes them to the appropriate driver.

---

# 10. AXI4-Lite Agent

The AXI4-Lite agent contains:

```text
AXI-Lite Agent
    │
    ├── Sequencer
    ├── Driver
    └── Monitor
```

### Driver

The driver converts AXI-Lite transactions into signal-level AXI-Lite activity.

### Monitor

The monitor observes AXI-Lite activity and publishes transactions for checking and coverage.

### Sequencer

The sequencer supplies transactions from the active sequence to the driver.

---

# 11. AXI4 Agent

The AXI4 agent contains:

```text
AXI4 Agent
    │
    ├── Sequencer
    ├── Driver
    └── Monitor
```

The AXI4 driver provides the AXI4-side behavior required by the UVM environment.

The AXI4 monitor observes the resulting AXI transactions and sends transaction-level information to the scoreboard and coverage model.

---

# 12. AXI4 Error Injection

The AXI4 driver contains explicit error-injection controls:

```text
inject_read_slverr
inject_write_slverr
```

The controls are used to intentionally generate AXI `SLVERR` responses.

Conceptually:

```text
Normal Test
    │
    ├── inject_read_slverr  = 0
    └── inject_write_slverr = 0

Error Test
    │
    ├── inject_read_slverr  = 1
    └── inject_write_slverr = 1
```

This allows the same UVM environment to test both normal and error scenarios.

---

# 13. Monitors and Scoreboard Connection

The monitors observe transactions independently of the drivers.

The transaction flow is:

```text
AXI-Lite Monitor ──────┐
                       │
                       ▼
                   Scoreboard
                       ▲
                       │
AXI4 Monitor ──────────┘
```

The monitors also provide transaction information to the coverage component.

This separation allows the scoreboard to check what actually occurred on the interfaces instead of relying only on what the driver intended to send.

---

# 14. Scoreboard

The scoreboard is implemented in:

```text
uvm/scoreboard/dma_scoreboard.sv
```

Its primary responsibility is checking DMA behavior and data integrity.

The scoreboard performs checks including:

- AXI-Lite transactions
- AXI read/write activity
- Address/data consistency
- DMA data integrity
- AXI write responses
- Expected `SLVERR` behavior during the error test

The final verification output includes:

```text
DMA DATA INTEGRITY CHECK : PASS
```

---

# 15. Expected SLVERR Handling

The scoreboard contains an explicit control for intentional error testing:

```text
expected_slverr
```

Normal test:

```text
expected_slverr = 0
```

Error test:

```text
expected_slverr = 1
```

When `SLVERR` is intentionally injected, the scoreboard recognizes the response as an expected condition rather than reporting it as an unexpected UVM error.

The error test produced expected SLVERR messages while still finishing with:

```text
UVM_WARNING : 0
UVM_ERROR   : 0
UVM_FATAL   : 0
```

---

# 16. Coverage

The project uses a manual counter-based functional coverage model in:

```text
uvm/coverage/dma_coverage.sv
```

Native SystemVerilog functional coverage was not used because the available Questa Starter license did not provide the required `svverification` feature.

Therefore, the project uses manual coverage counters.

The coverage model tracks categories including:

### Transfer Length

```text
4
8
16
32
64
```

### AXI-Lite Registers

```text
CTRL
SRC
DST
LEN
```

### AXI Command

```text
READ
WRITE
```

### Burst Type

```text
FIXED
INCR
WRAP
```

### Transfer Size

```text
BYTE
HALFWORD
WORD
```

### Response

```text
OKAY
EXOKAY
SLVERR
DECERR
```

### Last Condition

```text
LAST
NOT_LAST
```

The coverage model also records transaction counts.

---

# 17. UVM Basic Test

The basic test is:

```text
uvm/tests/dma_basic_test.sv
```

The test creates the UVM environment and starts the DMA sequence.

The test uses `$urandom` to generate pseudo-random source, destination, and length values because the current Questa Starter license configuration does not provide the `svverification` feature used by the project's original randomization approach.

The test then allows the DMA transaction to complete and the scoreboard performs the required checks.

---

# 18. UVM Error Test

The error test is:

```text
uvm/tests/dma_error_test.sv
```

It extends the basic DMA test.

Before starting the normal test flow, it enables:

```text
inject_read_slverr  = 1
inject_write_slverr = 1
expected_slverr     = 1
```

Therefore:

```text
dma_error_test
      │
      ├── Enable READ SLVERR
      ├── Enable WRITE SLVERR
      └── Tell scoreboard SLVERR is expected
                │
                ▼
          Run DMA sequence
                │
                ▼
        Check scoreboard
```

---

# 19. UVM Testbench Top

The top-level UVM testbench is:

```text
tb/uvm_tb_top.sv
```

It is responsible for:

- Clock generation
- Reset generation
- Instantiating AXI interfaces
- Instantiating the DUT
- Connecting virtual interfaces
- Starting the UVM test

The virtual interfaces are placed into the UVM configuration database so that UVM components can access the DUT interfaces.

---

# 20. Basic UVM Test Execution

The basic UVM test is executed using:

```bash
vsim -c -voptargs=+acc +UVM_TESTNAME=dma_basic_test work.uvm_tb_top -do "run -all; quit -f"
```

The output is captured in the project regression report.

---

# 21. Error UVM Test Execution

The AXI error test is executed using:

```bash
vsim -c -voptargs=+acc +UVM_TESTNAME=dma_error_test work.uvm_tb_top -do "run -all; quit -f"
```

This enables the UVM error-injection configuration and checks the resulting responses.

---

# 22. Basic UVM Test Results

The final basic UVM regression produced:

```text
FUNCTIONAL COVERAGE = 43.48%

DMA DATA INTEGRITY CHECK : PASS

UVM_WARNING : 0
UVM_ERROR   : 0
UVM_FATAL   : 0
```

Therefore the basic UVM test completed successfully.

---

# 23. Error UVM Test Results

The final error test produced expected `SLVERR` responses.

The regression reported:

```text
EXPECTED SLVERR: WRITE RESPONSE RESP=2
```

for the intentionally injected write responses.

Final result:

```text
FUNCTIONAL COVERAGE = 43.48%

DMA DATA INTEGRITY CHECK : PASS

UVM_WARNING : 0
UVM_ERROR   : 0
UVM_FATAL   : 0
```

Therefore the error-injection UVM test also passed.

---

# 24. UVM Coverage Result

The manual coverage model reported:

```text
FUNCTIONAL COVERAGE = 43.48%
```

This value represents the coverage calculated by the project's manual counter-based coverage implementation.

Important note:

The 43.48% value should **not** be interpreted as native Questa UCDB/SystemVerilog functional coverage. The project could not use native SystemVerilog functional coverage because the available Questa Starter license did not provide the required `svverification` feature.

Also, not every coverage bin is necessarily an architectural requirement of this DMA. For example, unsupported or intentionally unrequired AXI combinations should not be added merely to increase the percentage.

---

# 25. Verification Regression Summary

| Test | Purpose | Result |
|---|---|---|
| `dma_basic_test` | Normal UVM DMA operation | PASS |
| `dma_error_test` | Intentional AXI SLVERR injection | PASS |

### Overall UVM Status

```text
===============================
      UVM VERIFICATION
===============================

Basic Test       : PASS
Error Test       : PASS

Data Integrity   : PASS
UVM Errors       : 0
UVM Fatals       : 0

Overall           : PASS
===============================
```

---

# 26. Regression Log Files

The final UVM regression outputs were saved as:

```text
reports/dma_basic_final.log
reports/dma_error_final.log
```

These logs provide recorded evidence of the final UVM test results.

---

# 27. UVM Verification Strengths

The implemented UVM environment provides:

- Reusable transaction-level stimulus
- Separate AXI4 and AXI4-Lite agents
- Driver/monitor separation
- Transaction-level scoreboard checking
- Data integrity checking
- Controlled AXI error injection
- Manual functional coverage
- Separate normal and error tests
- Regression logs
- A scalable structure for additional tests

---

# 28. Limitations

The current UVM verification stage has the following documented limitations:

1. Native SystemVerilog functional coverage was not available because of the Questa Starter license.
2. Manual counter-based coverage is used instead.
3. The current UVM regression contains the basic and AXI error tests.
4. Additional AXI scenarios should only be added when they are architecturally applicable to the implemented DMA.

The existing directed verification campaign already provides broader scenario coverage, including boundary, stress, reset, backpressure, consecutive-transfer, and randomized tests.

---

# 29. Final UVM Verification Conclusion

The UVM verification stage was successfully completed.

The environment provides a structured and reusable verification architecture with:

```text
Transactions
    ↓
Sequences
    ↓
Sequencers
    ↓
Drivers
    ↓
DUT
    ↓
Monitors
    ↓
Scoreboard
    ↓
Coverage
```

Both final UVM tests passed:

```text
dma_basic_test  → PASS
dma_error_test  → PASS
```

The final verification results showed:

```text
DMA DATA INTEGRITY CHECK : PASS
UVM_WARNING : 0
UVM_ERROR   : 0
UVM_FATAL   : 0
```

The verified RTL and UVM environment were frozen and committed to Git before beginning the physical-design phase.

---

# 30. Transition to Physical Design

The completed verification flow is:

```text
Design Specification
        │
        ▼
RTL Design
        │
        ▼
Directed Functional Verification
        │
        ▼
UVM Verification
        │
        ▼
      PASS
        │
        ▼
   Synthesis
        │
        ▼
Physical Design
```

The next stage is **Stage 5 — Synthesis**, where the verified RTL will be converted into a technology-mapped gate-level netlist.
