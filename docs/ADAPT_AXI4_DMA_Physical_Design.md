# ADAPT --- AXI4 DMA Controller

## Physical Design Documentation

**Project:** ADAPT --- AXI4 DMA Controller\
**Document:** ASIC Physical Design\
**Stage:** RTL-to-GDSII Physical Implementation\
**Technology:** SkyWater SKY130\
**Primary tools:** Yosys, OpenROAD, OpenSTA, Magic/KLayout where
applicable\
**Status:** Routed physical-design database and GDSII layout generated;
final sign-off should be confirmed from the complete project reports.

------------------------------------------------------------------------

## Document Purpose

This document records the physical-design implementation of the ADAPT
AXI4 DMA Controller. It describes the design flow, implementation
stages, key reports, available metrics, generated artifacts, validation
approach, and recommended reproducibility steps.

The document is intended to accompany the RTL and
functional-verification documentation in the project repository. It
distinguishes confirmed results from items that still require final
report review.

## 1. Project Overview

The ADAPT AXI4 DMA Controller transfers data from a source memory
address to a destination memory address. It is configured through an
AXI4-Lite interface and uses AXI4 read and write master interfaces for
memory access.

The physical-design work takes the verified RTL through synthesis and
implementation stages, including floorplanning, placement,
power-distribution planning, clock-tree synthesis, timing repair,
routing, post-route analysis, and GDSII generation.

### Physical-design objectives

1.  Synthesize the RTL into a standard-cell implementation.
2.  Establish a floorplan and core area.
3.  Place standard cells within the floorplan.
4.  Build the power-distribution network.
5.  Insert and balance the clock tree.
6.  Route signal interconnects.
7.  Analyze post-route timing and parasitics.
8.  Export a routed DEF and GDSII layout.
9.  Preserve reports and scripts for reproducibility.

## 2. Design Summary

The DMA implementation includes the following functional blocks:

-   AXI4-Lite configuration/register interface.
-   DMA controller finite-state machine.
-   AXI4 read master.
-   AXI4 write master.
-   FIFO buffering.
-   Top-level integration and memory-facing AXI signals.

Functional verification is documented separately. The previously
completed directed regression reported 15 major tests passing, including
backpressure, reset, boundary, consecutive-transfer, FIFO stress, AXI
error-response, and randomized-transfer tests. The UVM run shown in the
project screenshots also reported a successful data-integrity check and
zero UVM errors, warnings, and fatals for that run. These verification
results are not substitutes for physical sign-off.

## 3. Physical-Design Flow

The project flow is organized into the following stages:

``` text
SystemVerilog RTL
      |
      v
RTL / Constraint Checks
      |
      v
Yosys Synthesis
      |
      v
Floorplan and IO Planning
      |
      v
Tapcell Insertion
      |
      v
Global Placement
      |
      v
Power Distribution Network (PDN)
      |
      v
Clock Tree Synthesis (CTS)
      |
      v
Timing Repair / Optimization
      |
      v
Global and Detailed Routing
      |
      v
Post-Route Parasitics and Timing Analysis
      |
      v
Routed DEF Export
      |
      v
GDSII Export and Layout Inspection
```

The exact enabled operations and ordering are defined by the Tcl scripts
under `physical_design/scripts/`.

## 4. Toolchain and Project Artifacts

### Tools

  -----------------------------------------------------------------------
  Tool                                Role
  ----------------------------------- -----------------------------------
  Yosys                               RTL synthesis

  OpenROAD                            Floorplanning, placement, PDN, CTS,
                                      routing, implementation
                                      optimization

  OpenSTA                             Static timing analysis

  Magic / KLayout                     Layout viewing or inspection when
                                      configured

  Netgen                              Potential netlist/layout comparison
                                      where configured

  QuestaSim                           Functional/UVM simulation, separate
                                      from physical implementation
  -----------------------------------------------------------------------

Tool availability and exact versions should be recorded from the machine
used to produce the final results.

### Important project files

  ------------------------------------------------------------------------------------
  Artifact                            Path
  ----------------------------------- ------------------------------------------------
  Physical-design scripts             `physical_design/scripts/`

  Synthesis result JSON               `physical_design/results/axi4_dma_synth.json`

  Routed DEF                          `physical_design/results/axi4_dma_routed.def`

  GDSII layout                        `physical_design/gds/axi4_dma.gds`

  Rendered layout image               `physical_design/gds/axi4_dma_layout.png`

  Post-route setup timing             `physical_design/reports/post_route_setup.rpt`

  Post-route hold timing              `physical_design/reports/post_route_hold.rpt`

  Routing report                      `physical_design/reports/routing_drc.rpt`

  Wire-length report                  `physical_design/reports/wire_length.rpt`

  Clock-tree report                   `physical_design/reports/cts_report.txt`
  ------------------------------------------------------------------------------------

The repository may contain additional logs and intermediate databases.
The listed artifacts are the main outputs identified for this
documentation.

## 5. Synthesis

Yosys converts the RTL into a synthesized netlist and writes synthesis
statistics in JSON format.

### Synthesis goals

-   Elaborate the intended top-level design.
-   Infer and map sequential and combinational logic.
-   Resolve module hierarchy.
-   Generate synthesis statistics.
-   Preserve a machine-readable synthesis result for later inspection.

### Synthesis artifact

`physical_design/results/axi4_dma_synth.json`

This JSON file contains module-level cells and net names. Module-level
cell counts should not be summed and presented as the final placed chip
cell count without checking hierarchy, flattening, and mapping details.

### Suggested reproducibility command

Run the project's synthesis script using the repository's configured
environment and paths. The project script is:

``` text
physical_design/scripts/synth.tcl
```

Use the actual command and configuration recorded by the project rather
than assuming a generic PDK or library path.

## 6. Floorplanning and Placement

Floorplanning defines the core region and implementation boundaries.
Placement assigns physical locations to cells before clock-tree
synthesis and routing.

### Recorded placement metrics

The available placement log reports:

  Metric                                                  Reported value
  ----------------------------------------------------- ----------------
  Total instances                                                  2,353
  Placeable instances                                              1,665
  Fixed instances                                                    688
  Core area                                               52,340.198 µm²
  Standard-cell area                                      21,032.672 µm²
  Target placement density                                         0.600
  Final global-placement overflow (reported snapshot)           0.099106

The instance counts include different classes of implementation objects.
In particular, the total instance count should not be described as the
standard-cell count. The target placement density is a configuration
target, not the measured standard-cell-area/core-area ratio.

The ratio of the reported standard-cell area to the reported core area
is approximately 40.2%. This is a derived ratio, not the target
placement density.

### Interpretation

These metrics describe the placement snapshot available in the project
logs. If the implementation was subsequently changed, regenerate the
metrics from the final run before using them as final sign-off values.

## 7. Power Distribution Network

The PDN stage creates the power and ground distribution structures
required by the physical implementation.

The project includes the script:

``` text
physical_design/scripts/06_pdn.tcl
```

For a complete report, retain the PDN configuration and record the
applicable power-grid layers, stripe/ring settings, via strategy, and
the result of the tool's PDN connectivity checks. This document does not
infer unreported PDN parameters.

## 8. Clock Tree Synthesis

Clock Tree Synthesis inserts clock buffers and builds the clock
distribution network to deliver the clock to sequential sinks.

### Recorded CTS metrics

The available CTS report records:

  Metric                     Reported value
  ------------------------ ----------------
  Clock roots                             1
  Clock buffers inserted                 54
  Clock subnets                          54
  Clock sinks                           508

These values are from the available CTS report. If CTS is rerun, refresh
the report before treating the numbers as the final implementation
values.

### CTS artifact

`physical_design/reports/cts_report.txt`

### CTS script

`physical_design/scripts/08_cts.tcl`

## 9. Timing Repair and Static Timing Analysis

Static timing analysis checks timing paths against the constraints
supplied to the implementation flow. Setup and hold analysis should be
reviewed separately.

### Available timing reports

-   Setup: `physical_design/reports/post_route_setup.rpt`
-   Hold: `physical_design/reports/post_route_hold.rpt`

The setup report contains positive slack on at least one reported path.
One excerpt previously inspected showed approximately `1.358` slack
marked `MET`, but the unit and path context must be read from the full
report and its constraints. A single path's slack does not prove that
all setup paths meet timing.

### Timing values to record from the final reports

  -----------------------------------------------------------------------
  Timing item                         Value
  ----------------------------------- -----------------------------------
  Clock period / clock definition     Read from final SDC and timing
                                      report

  Worst setup slack (WNS)             Record from complete final report

  Total negative setup slack (TNS)    Record from complete final report

  Worst hold slack                    Record from complete final report

  Total negative hold slack           Record from complete final report

  Number of violating setup/hold      Record from final report if
  paths                               publishing sign-off status
  -----------------------------------------------------------------------

Do not state that timing is fully clean unless the complete final setup
and hold reports support that conclusion.

## 10. Routing

Routing connects placed pins and nets using the available metal layers
and routing rules. The project includes routing scripts and reports.

### Routing artifacts

  Artifact             Path
  -------------------- -----------------------------------------------
  Routing Tcl          `physical_design/scripts/09_routing.tcl`
  Routing report       `physical_design/reports/routing_drc.rpt`
  Wire-length report   `physical_design/reports/wire_length.rpt`
  Routed DEF           `physical_design/results/axi4_dma_routed.def`

The routed DEF records physical connectivity and geometry at the DEF
representation level. The wire-length report should be consulted for the
final run's interconnect statistics.

### Reporting guidance

Use the final routing report for final wire length, via count, and
routing completion status. Intermediate log snapshots can differ from
the final routed state, so intermediate values should not be presented
as final metrics.

## 11. Post-Route Analysis

After routing, parasitics and timing analysis help assess the
implementation with estimated interconnect effects.

Relevant scripts and reports include:

-   `physical_design/scripts/10_post_route_sta.tcl`
-   `physical_design/scripts/check_parasitics.tcl`
-   `physical_design/reports/post_route_setup.rpt`
-   `physical_design/reports/post_route_hold.rpt`

For a complete post-route record, document the extracted parasitics
source, timing constraints, setup/hold summary, and whether the reports
correspond to the same final routed database.

## 12. DEF and GDSII Generation

The project contains a routed DEF and a GDSII file.

  Output            Path
  ----------------- -----------------------------------------------
  Routed DEF        `physical_design/results/axi4_dma_routed.def`
  GDSII             `physical_design/gds/axi4_dma.gds`
  Rendered layout   `physical_design/gds/axi4_dma_layout.png`

The rendered PNG is useful for documentation and visual inspection. The
GDSII file is the layout exchange artifact; the PNG is a visualization
of the layout and is not a replacement for the GDSII database.

### Layout inspection

Inspect the layout at both full-chip and zoomed-in scales. Confirm that
the rendered image corresponds to the same GDSII database intended for
release.

Generating a GDSII file demonstrates that a layout artifact was
exported. It does not, by itself, prove that all physical sign-off
checks have completed successfully.

## 13. Key Results Summary

The following summarizes the currently identified implementation
results:

  Category                    Result
  --------------------------- ----------------
  Synthesis JSON              Generated
  Placement database/logs     Available
  Core area                   52,340.198 µm²
  Standard-cell area          21,032.672 µm²
  Total placement instances   2,353
  Placeable instances         1,665
  CTS clock roots             1
  CTS buffers inserted        54
  CTS clock sinks             508
  Routed DEF                  Generated
  GDSII                       Generated
  Layout visualization        Generated
  Post-route setup report     Available
  Post-route hold report      Available
  Wire-length report          Available

Values above should be refreshed if the physical-design flow is rerun.
Final timing and routing summary numbers should be extracted from the
final reports rather than inferred from partial logs.

## 14. Recommended Evidence for the Project README or LinkedIn

Use a small set of authentic tool outputs:

1.  Full-chip GDSII layout visualization.
2.  Synthesis statistics from the mapped netlist.
3.  Placement area summary.
4.  CTS summary.
5.  Post-route setup timing summary.
6.  A concise flow diagram showing RTL through GDSII.

Prefer cropped, readable screenshots or generated report tables. Keep
the raw reports and scripts in the repository for reproducibility.

## 15. Reproducibility Checklist

Before presenting results as final:

-   [ ] Record the exact RTL commit or revision used.
-   [ ] Record the SDC and PDK/library configuration.
-   [ ] Record tool versions.
-   [ ] Confirm synthesis uses the intended top module.
-   [ ] Confirm placement and CTS reports correspond to the final
    database.
-   [ ] Confirm routing reports correspond to the final routed database.
-   [ ] Review complete setup and hold reports.
-   [ ] Confirm parasitics were extracted or loaded for post-route
    timing.
-   [ ] Confirm the routed DEF and GDSII were generated from the
    intended final database.
-   [ ] Save the final logs and commands used.
-   [ ] Update the README with the final measured values.

## 16. Conclusion

The ADAPT AXI4 DMA Controller has progressed through synthesis and
physical implementation to the generation of a routed DEF, GDSII layout,
and a rendered layout image. The available records also include
placement-area data, CTS statistics, post-route setup and hold reports,
and a wire-length report.

The current documented results include a core area of 52,340.198 µm²,
standard-cell area of 21,032.672 µm², 54 inserted clock buffers, and 508
clock sinks. These metrics provide a useful snapshot of the
implementation.

Final sign-off should be described only after the complete final timing,
routing, parasitic, and physical verification reports have been reviewed
and tied to the same final design database.

------------------------------------------------------------------------

## Appendix A --- Main Script Inventory

The following scripts were present in the project inventory:

-   `physical_design/scripts/synth.tcl`
-   `physical_design/scripts/02_check_sdc.tcl`
-   `physical_design/scripts/03_init.tcl`
-   `physical_design/scripts/04_floorplan.tcl`
-   `physical_design/scripts/05_tapcells.tcl`
-   `physical_design/scripts/06_pdn.tcl`
-   `physical_design/scripts/07_placement.tcl`
-   `physical_design/scripts/08_cts.tcl`
-   `physical_design/scripts/09_routing.tcl`
-   `physical_design/scripts/10_post_route_sta.tcl`
-   `physical_design/scripts/11_power_check.tcl`
-   `physical_design/scripts/check_routed_design.tcl`
-   `physical_design/scripts/check_routed_db.tcl`
-   `physical_design/scripts/check_parasitics.tcl`
-   `physical_design/scripts/export_routed_def.tcl`

## Appendix B --- Suggested Repository Structure

``` text
ADAPT/
├── rtl/
├── tb/
├── physical_design/
│   ├── scripts/
│   ├── reports/
│   ├── results/
│   └── gds/
├── docs/
│   ├── functional_verification.md
│   └── physical_design.md
└── README.md
```

Keep the documentation aligned with the final files and actual flow
configuration. Update this document whenever the RTL, constraints, PDK,
scripts, or implementation results change.
