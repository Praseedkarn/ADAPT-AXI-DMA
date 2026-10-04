# ADAPT AXI4 DMA Controller
## RTL Design Document

**Project:** ADAPT — AXI4 DMA Controller  
**Document:** RTL Design  
**Stage:** 2 — RTL Design  
**HDL:** SystemVerilog  
**Status:** RTL design completed and verified

---

## 1. Introduction

The ADAPT AXI4 DMA Controller is a SystemVerilog-based Direct Memory Access (DMA) design that transfers data between memory locations without requiring the processor to handle every individual data movement operation.

The design provides an **AXI4-Lite control interface** for programming the DMA and an **AXI4 master interface** for performing memory read and write transactions.

The RTL was developed as a modular design so that the control logic, register interface, FIFO buffering, AXI read path, AXI write path, and top-level integration can be developed and verified independently.

---

## 2. RTL Architecture

```text
                         ┌───────────────────────┐
                         │       CPU / SW        │
                         └───────────┬───────────┘
                                     │
                                AXI4-Lite
                                     │
                         ┌───────────▼───────────┐
                         │   AXI4-Lite Slave     │
                         │  Control Interface    │
                         └───────────┬───────────┘
                                     │
                         ┌───────────▼───────────┐
                         │    DMA Registers      │
                         │ CTRL / SRC / DST/LEN  │
                         └───────────┬───────────┘
                                     │
                         ┌───────────▼───────────┐
                         │    DMA Controller     │
                         │     Control FSM       │
                         └───────┬───────┬───────┘
                                 │       │
                         Read Control   Write Control
                                 │       │
                    ┌────────────▼─┐   ┌─▼────────────┐
                    │ AXI4 Read    │   │ AXI4 Write   │
                    │ Master       │   │ Master       │
                    └──────┬───────┘   └──────┬───────┘
                           │                  │
                           │      FIFO        │
                           └──────►──────►────┘
                                      │
                              ┌───────▼───────┐
                              │ Memory / AXI  │
                              └───────────────┘
```

---

## 3. RTL File Structure

```text
rtl/
├── axi/
│   ├── axi4_lite_slave.sv
│   ├── axi4_read_master.sv
│   └── axi4_write_master.sv
│
├── dma/
│   ├── dma_controller.sv
│   ├── dma_fifo.sv
│   └── dma_registers.sv
│
└── top/
    └── axi4_dma_top.sv
```

| Module | Description |
|---|---|
| `axi4_lite_slave.sv` | AXI4-Lite control/register interface |
| `dma_registers.sv` | DMA configuration registers |
| `dma_controller.sv` | Main DMA control logic and transfer sequencing |
| `dma_fifo.sv` | Data buffering between read and write paths |
| `axi4_read_master.sv` | AXI4 read transaction generation |
| `axi4_write_master.sv` | AXI4 write transaction generation |
| `axi4_dma_top.sv` | Top-level integration |

---

## 4. AXI4-Lite Control Interface

The AXI4-Lite interface is used to configure and control the DMA.

The processor/software side writes the DMA configuration registers before starting a transfer.

Main configuration information:

- Source address
- Destination address
- Transfer length
- Control/start information

```text
CPU
 │
 ├── Write Source Address
 │
 ├── Write Destination Address
 │
 ├── Write Transfer Length
 │
 └── Write Start/Control
             │
             ▼
        DMA Controller
```

---

## 5. DMA Register Map

| Register | Address | Function |
|---|---:|---|
| CTRL | `0x00` | DMA control/start |
| SRC | `0x08` | Source memory address |
| DST | `0x0C` | Destination memory address |
| LEN | `0x10` | Transfer length |

### CTRL Register

Used to initiate a DMA transfer.

### SRC Register

Contains the source memory address from which data is read.

### DST Register

Contains the destination memory address to which data is written.

### LEN Register

Contains the number of bytes to be transferred.

---

## 6. DMA Controller

The `dma_controller.sv` module is the central control block.

Responsibilities:

- Starting DMA transfers
- Controlling the read operation
- Controlling the write operation
- Coordinating the FIFO
- Tracking transfer completion
- Managing read/write sequencing
- Handling reset conditions

---

## 7. DMA Transfer Flow

```text
Source Memory
     │
     │ AXI4 READ
     ▼
┌──────────────┐
│ AXI Read     │
│ Master       │
└──────┬───────┘
       │
       │ Read Data
       ▼
┌──────────────┐
│ DMA FIFO     │
└──────┬───────┘
       │
       │ Buffered Data
       ▼
┌──────────────┐
│ AXI Write    │
│ Master       │
└──────┬───────┘
       │
       │ AXI4 WRITE
       ▼
Destination Memory
```

The FIFO decouples the AXI read and write data paths.

---

## 8. AXI4 Read Master

The `axi4_read_master.sv` module generates AXI4 read-side transactions.

Responsibilities:

- Generating read addresses
- Managing `ARVALID` / `ARREADY`
- Receiving read data
- Managing `RVALID` / `RREADY`
- Handling read responses
- Detecting the last read data beat
- Providing received data to the DMA/FIFO path

### Read Handshake

```text
ARVALID = 1
ARREADY = 1
        │
        ▼
  Address accepted
```

For read data:

```text
RVALID = 1
RREADY = 1
        │
        ▼
   Data accepted
```

The RTL was verified under read-side backpressure conditions.

---

## 9. AXI4 Write Master

The `axi4_write_master.sv` module generates AXI4 write-side transactions.

Responsibilities:

- Generating write addresses
- Managing `AWVALID` / `AWREADY`
- Sending write data
- Managing `WVALID` / `WREADY`
- Generating `WLAST`
- Receiving write responses
- Managing `BVALID` / `BREADY`

### Write Address Handshake

```text
AWVALID = 1
AWREADY = 1
        │
        ▼
  Address accepted
```

### Write Data Handshake

```text
WVALID = 1
WREADY = 1
        │
        ▼
    Data accepted
```

### Write Response

After the write operation, the AXI slave provides a response through the B channel.

The verification environment also tested AXI `SLVERR` responses.

---

## 10. DMA FIFO

The `dma_fifo.sv` module provides temporary storage between the read and write paths.

The FIFO is important because the AXI read and AXI write sides do not necessarily operate at the same rate.

```text
              WRITE
                │
                ▼
        ┌───────────────┐
        │   DMA FIFO    │
        └───────────────┘
                │
                ▼
               READ
```

The FIFO provides status information such as:

- Empty
- Full
- Data count

The FIFO was exercised using a large transfer during directed verification.

---

## 11. Top-Level Integration

The `axi4_dma_top.sv` module connects the individual RTL blocks.

```text
AXI4-Lite Interface
        │
        ▼
AXI4-Lite Slave
        │
        ▼
DMA Registers
        │
        ▼
DMA Controller
      /   \
     /     \
    ▼       ▼
AXI Read   AXI Write
    │       ▲
    └──►FIFO┘
```

This module represents the complete DMA IP from the external interface perspective.

---

## 12. Reset Behavior

Reset returns the DMA to a known idle state.

During reset, the design initializes its control state and prevents an invalid DMA transaction from continuing.

The verification environment specifically tested reset during an active DMA operation.

The reset test demonstrated that:

1. An active transfer can be interrupted by reset.
2. The DMA returns to its reset state.
3. A new DMA transfer can be started after reset.
4. The post-reset transfer completed successfully.

---

## 13. AXI Backpressure Handling

AXI allows either side of an interface to temporarily delay a transfer using the VALID/READY handshake.

The RTL was designed and verified to tolerate backpressure.

Examples tested include:

- `AWREADY` delayed
- `RVALID` delayed
- Long AXI stalls

The DMA must keep transaction information stable until the corresponding handshake occurs.

---

## 14. Error Response Handling

The AXI protocol provides response information for transactions.

The verification environment tested `SLVERR` conditions on the AXI read/write paths.

The UVM environment includes controlled error injection so that the design's behavior under AXI error responses can be evaluated.

The final UVM error test completed with:

```text
DMA DATA INTEGRITY CHECK : PASS

UVM_WARNING : 0
UVM_ERROR   : 0
UVM_FATAL   : 0
```

---

## 15. RTL Design Characteristics

- SystemVerilog RTL
- AXI4-Lite control interface
- AXI4 read master
- AXI4 write master
- FIFO-based buffering
- Dedicated DMA controller
- Register-based configuration
- Reset handling
- AXI backpressure handling
- AXI error-response verification
- Modular top-level integration

---

## 16. RTL Verification Status

### Directed Verification

The directed verification suite included:

- Basic DMA operation
- AXI backpressure
- Reset during active DMA
- Transfer boundary conditions
- Long AXI stalls
- Consecutive DMA transfers
- FIFO stress
- AXI error responses
- Randomized DMA transfers

The directed verification campaign completed successfully.

```text
ALL DMA TESTS PASSED
```

### UVM Verification

The UVM environment includes:

```text
UVM Test
   │
   ▼
UVM Environment
   │
   ├── AXI-Lite Agent
   ├── AXI4 Agent
   ├── Scoreboard
   └── Coverage
```

The basic UVM test and AXI error test completed with zero UVM errors and fatal errors.

---

## 17. RTL Design Completion

The RTL design stage is considered complete after:

- RTL modules were implemented.
- Top-level integration was completed.
- AXI interfaces were implemented.
- FIFO buffering was implemented.
- Directed verification passed.
- UVM verification passed.
- RTL and UVM sources were committed to Git.
- The verified RTL/UVM state was frozen before physical design.

Verified project commit:

```text
f1fdc80 Freeze verified AXI4 DMA RTL and UVM verification
```

---

## 18. Next Stage

The next stage is **Synthesis**.

```text
RTL Design
     │
     ▼
Functional Verification
     │
     ▼
UVM Verification
     │
     ▼
┌──────────────────┐
│    SYNTHESIS     │
└──────────────────┘
     │
     ▼
Gate-Level Netlist
     │
     ▼
Physical Design
```

The synthesis stage will convert the verified RTL into a technology-mapped gate-level netlist and provide initial area and timing information.

---

## Document Status

| Item | Status |
|---|---|
| RTL Architecture | Complete |
| AXI4-Lite Interface | Complete |
| AXI4 Read Master | Complete |
| AXI4 Write Master | Complete |
| DMA Controller | Complete |
| FIFO | Complete |
| Top-Level Integration | Complete |
| Directed Verification | Passed |
| UVM Verification | Passed |
| RTL Freeze | Complete |
| Physical Design | Next Stage |
