AXI4 DMA — Design Specification v1.0
1. Project objective

We will design and verify a single-channel AXI4 DMA controller that transfers data between two memory locations without requiring a CPU to control every individual data transfer.

The DMA will be configured through an AXI4-Lite slave interface and will perform the actual memory transfers through an AXI4 master interface.

                   ┌──────────────────────────────┐
                   │          AXI4 DMA             │
                   │                              │
 AXI4-Lite ───────►│  Control Registers           │
                   │         │                    │
                   │         ▼                    │
                   │  DMA Control FSM             │
                   │      │       │               │
                   │      ▼       ▼               │
                   │   AXI Read  AXI Write        │
                   │      │       ▲               │
                   │      └──FIFO──┘               │
                   └──────────┬───────────────────┘
                              │
                         AXI4 Master
                              │
                              ▼
                       Memory Model

2. Main specifications
Parameter	Specification
DMA channels	1
Address width	32-bit
Data width	32-bit
Control interface	AXI4-Lite Slave
Data interface	AXI4 Master
Transfer direction	Memory → Memory
Transfer mode	Incrementing
Initial transfer size	4 bytes
Maximum initial transfer	Configurable
Data buffer	FIFO
Clock	Single clock domain
Reset	Active-low synchronous/asynchronous — we'll finalize during RTL
HDL	SystemVerilog
Verification	SystemVerilog testbench
Simulation	Icarus Verilog
Synthesis	Yosys
Physical design	OpenROAD
Layout verification	Magic / Netgen
Final output	GDSII
3. AXI4-Lite control interface

The DMA will have an AXI4-Lite slave interface.

The software/CPU/testbench writes configuration registers.
Registers
Offset	Register	Width	Description
0x00	CONTROL	32	Start/control
0x04	STATUS	32	DMA status
0x08	SOURCE_ADDR	32	Source address
0x0C	DEST_ADDR	32	Destination address
0x10	LENGTH	32	Transfer length
0x14	RESERVED	32	Future use
CONTROL

31                      1  0
+-------------------------+-+
|       RESERVED          |S|
+-------------------------+-+
                           │
                          START

START = 1 begins the transfer.
STATUS

31       2   1    0
+----------+----+----+
| RESERVED |DONE|BUSY|
+----------+----+----+

Meaning:

BUSY = 1 → DMA is transferring
BUSY = 0 → DMA is idle

DONE = 1 → transfer completed
DONE = 0 → transfer not completed

4. Example programming sequence

Suppose we want:

Source      = 0x00001000
Destination = 0x00002000
Length      = 64 bytes

The controller/testbench performs:

Write 0x1000 → SOURCE_ADDR
Write 0x2000 → DEST_ADDR
Write 64     → LENGTH
Write 1      → CONTROL.START

DMA then performs:

0x1000 → read data
0x1004 → read data
0x1008 → read data
...

and writes:

0x2000
0x2004
0x2008
...

until all 64 bytes have been transferred.
5. AXI4 Master interface

This interface connects our DMA to the memory system.

We'll initially implement the basic AXI4 channels:
Read

AR channel
R channel

Write

AW channel
W channel
B channel

So:

DMA
 │
 ├── AR ─────► Memory
 │
 ├── R  ◄───── Memory
 │
 ├── AW ─────► Memory
 │
 ├── W  ─────► Memory
 │
 └── B  ◄───── Memory

6. DMA internal blocks

Our RTL will be divided into these blocks:

rtl/
│
├── axi/
│   ├── axi4_lite_slave.sv
│   ├── axi4_read_master.sv
│   └── axi4_write_master.sv
│
├── dma/
│   ├── dma_registers.sv
│   ├── dma_controller.sv
│   └── dma_fifo.sv
│
└── top/
    └── axi4_dma_top.sv

dma_registers.sv

Stores:

source_addr
dest_addr
transfer_length
start

and provides:

busy
done

dma_controller.sv

This is the brain of the DMA.

It controls the sequence:

IDLE
  ↓
READ
  ↓
BUFFER
  ↓
WRITE
  ↓
CHECK
  ↓
READ
  ↓
...
  ↓
DONE
  ↓
IDLE

We'll implement this as an FSM.
dma_fifo.sv

Temporary data storage:

AXI READ
    │
    ▼
┌─────────┐
│   FIFO  │
└────┬────┘
     │
     ▼
 AXI WRITE

7. Address generation

For 32-bit data:

DATA_WIDTH = 32 bits
           = 4 bytes

Therefore addresses initially increment by:

4 bytes

Example:

Source:

0x1000
0x1004
0x1008
0x100C
...

Destination:

0x2000
0x2004
0x2008
0x200C
...

8. Initial AXI strategy

We're deliberately starting with single-beat transactions.

That means:

ARVALID → ARREADY
        ↓
       READ
        ↓
RVALID → RREADY

Then:

AWVALID → AWREADY
        ↓
WVALID → WREADY
        ↓
BVALID → BREADY

Once this works, we'll add AXI burst support.

That gives us a natural project progression:

V1
Single-beat DMA
       ↓
V2
Burst DMA
       ↓
V3
FIFO optimization
       ↓
V4
Interrupt support
       ↓
V5
Performance measurements
       ↓
Physical Design

9. Verification requirements

We won't just test one transfer.

We'll eventually test:
Basic

4-byte transfer
8-byte transfer
16-byte transfer
64-byte transfer

Different addresses

SOURCE = 0x1000
DEST   = 0x2000

Then:

SOURCE = 0x4000
DEST   = 0x8000

Error cases

LENGTH = 0
START while BUSY
invalid AXI response

Randomized testing

We'll generate:

random source address
random destination address
random transfer length
random data

and compare:

Expected Memory
       vs
Actual Memory

This is where the project becomes a proper Design Verification project, rather than just a Verilog implementation.
10. Physical-design target

After RTL verification:

SystemVerilog RTL
       ↓
     Yosys
       ↓
Gate-level netlist
       ↓
   OpenROAD
       ↓
Floorplan
       ↓
Placement
       ↓
CTS
       ↓
Routing
       ↓
   DRC/LVS
       ↓
     GDSII

We'll collect:

Area
Cell count
WNS
TNS
Clock frequency
Power estimate
Routing congestion
DRC violations
LVS result

11. Important project boundary

Our first version is not a complete microcontroller or complete SoC.

We're designing a reusable SoC IP block:

                  Complete SoC
                       │
        ┌──────────────┼──────────────┐
        │              │              │
       CPU            DMA           Memory
                       │
                  OUR PROJECT

Later, this DMA could be integrated into a larger SoC containing a CPU, SRAM, UART, GPIO, timers, etc.
12. Final project architecture

So the complete v1 architecture is:

                         TESTBENCH
                             │
                             │ AXI4-Lite
                             ▼
                  ┌──────────────────────┐
                  │                      │
                  │      AXI4 DMA        │
                  │                      │
                  │ ┌──────────────────┐ │
                  │ │ AXI4-Lite Slave │ │
                  │ └────────┬─────────┘ │
                  │          │            │
                  │          ▼            │
                  │ ┌──────────────────┐ │
                  │ │ DMA Registers    │ │
                  │ └────────┬─────────┘ │
                  │          │            │
                  │          ▼            │
                  │ ┌──────────────────┐ │
                  │ │ DMA Controller   │ │
                  │ │      FSM         │ │
                  │ └───────┬──────────┘ │
                  │         │            │
                  │     ┌───┴───┐        │
                  │     ▼       ▼        │
                  │  READ     WRITE      │
                  │ ENGINE    ENGINE     │
                  │     │       ▲        │
                  │     └───┬───┘        │
                  │         ▼            │
                  │      FIFO            │
                  │                      │
                  └─────────┬────────────┘
                            │
                         AXI4 Master
                            │
                            ▼
                     ┌──────────────┐
                     │ Memory Model │
                     └──────────────┘