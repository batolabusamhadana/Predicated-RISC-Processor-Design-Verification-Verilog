# Design and Verification of a Simplified Predicated RISC Processor

A 32-bit **Predicated RISC Processor** designed and implemented in **Verilog HDL** as part of the Computer Architecture course at Birzeit University.

The project covers processor **microarchitecture, RTL design, control-path implementation, instruction execution, and simulation-based verification**.

## Project Overview

The processor implements a custom RISC-style instruction set supporting:

* Arithmetic operations
* Logical operations
* Immediate operations
* Load/store memory operations
* Conditional/predicated execution
* Unconditional jumps
* Function calls and returns

The design follows a multi-stage execution flow consisting of:

**Fetch → Decode → Execute → Memory Access → Write-Back**

The processor uses a datapath and control path to coordinate instruction execution and includes a register file, ALU, instruction memory, data memory, program counter, and control logic.

## Architecture Specifications

| Feature                   | Specification           |
| ------------------------- | ----------------------- |
| Processor width           | 32-bit                  |
| Instruction size          | 32-bit                  |
| General-purpose registers | 32                      |
| Register width            | 32-bit                  |
| R0                        | Hardwired to zero       |
| R30                       | Program Counter (PC)    |
| R31                       | Return Address Register |
| Instruction memory        | Separate                |
| Data memory               | Separate                |
| Memory addressing         | Word-addressable        |
| HDL                       | Verilog                 |
| Verification              | Simulation-based        |

## Predicated Execution

A key feature of the processor is **predicated execution**.

Each instruction contains a predicate register `Rp` that determines whether the instruction executes.

* If `Reg[Rp] ≠ 0`, the instruction executes.
* If `Reg[Rp] = 0`, the instruction is skipped.
* `R0` can be used as the predicate register to execute an instruction unconditionally because `R0` is always zero according to the project ISA convention.

This mechanism allows conditional execution to be incorporated directly into the instruction format.

## Instruction Set

The processor supports the following instructions:

### Register-Type Instructions

| Instruction | Description                          |
| ----------- | ------------------------------------ |
| `ADD`       | Register addition                    |
| `SUB`       | Register subtraction                 |
| `OR`        | Bitwise OR                           |
| `NOR`       | Bitwise NOR                          |
| `AND`       | Bitwise AND                          |
| `JR`        | Jump to address stored in a register |

### Immediate-Type Instructions

| Instruction | Description           |
| ----------- | --------------------- |
| `ADDI`      | Add immediate         |
| `ORI`       | OR with immediate     |
| `NORI`      | NOR with immediate    |
| `ANDI`      | AND with immediate    |
| `LW`        | Load word from memory |
| `SW`        | Store word to memory  |

### Jump-Type Instructions

| Instruction | Description                                                   |
| ----------- | ------------------------------------------------------------- |
| `J`         | Conditional jump                                              |
| `CALL`      | Conditional function call with return address stored in `R31` |

Immediate values are zero-extended for logical operations and sign-extended for other applicable instructions. Negative values use two's-complement representation.

## RTL Design

The processor was implemented using modular Verilog RTL.

The design includes components for:

* ALU operations
* Register file
* Instruction decoding
* Control signal generation
* Program counter management
* Datapath operation
* Memory access
* Instruction execution
* Write-back
* Predicated execution

### Execution Flow

```text
              ┌─────────┐
              │  Fetch  │
              └────┬────┘
                   │
                   ▼
              ┌─────────┐
              │ Decode  │
              └────┬────┘
                   │
                   ▼
              ┌─────────┐
              │ Execute │
              │   ALU   │
              └────┬────┘
                   │
                   ▼
              ┌─────────┐
              │ Memory  │
              └────┬────┘
                   │
                   ▼
              ┌──────────┐
              │Write Back│
              └──────────┘
```

## Verification

The project includes a **simulation-based verification environment** designed to test processor functionality using Verilog testbench code and instruction-level test programs.

The verification process includes:

* Instruction execution testing
* Arithmetic operation testing
* Logical operation testing
* Immediate instruction testing
* Load/store testing
* Jump testing
* Function call/return testing
* Predicated execution testing
* Processor state observation
* Waveform-based debugging

Test programs were developed using the processor's custom ISA and stored in binary/instruction format for execution by the processor.

## My Contribution

This was a team-based processor design project.

My primary contribution was the **ALU implementation**.

### ALU Responsibilities

* Implemented arithmetic operations including `ADD` and `SUB`
* Implemented logical operations including `AND`, `OR`, and `NOR`
* Integrated ALU functionality with the processor datapath
* Verified ALU behavior through simulation
* Debugged RTL behavior using simulation results and waveforms

I also participated in the overall processor implementation, simulation, testing, and project documentation as part of the development team.

## Repository Structure

```text
Predicated-RISC-Processor/
│
├── diagrams/
│   ├── BlockDiagram.pdf
│   ├── LogicalDiagram.png
│   ├── LogicalDiagram2.png
│   └── StateDiagram.png
│
├── project2/
│   └── src/
│       ├── modules.v
│       ├── mutlicycle.v
│       └── tb.v
│
├── report/
│   └── ArchReport.pdf
│
├── testPrograms/
│   └── testing_instructions.txt
│
├── .gitignore
└── README.md
```

## Design Documentation

The `diagrams/` directory contains the processor's design documentation, including:

* Overall processor block diagram
* Logical/datapath diagrams
* State diagram
* Control and architecture documentation

The complete project report is available in:

`report/ArchReport.pdf`

## Technologies

* **Verilog HDL**
* **RTL Design**
* **Digital Logic**
* **Computer Architecture**
* **Processor Design**
* **Simulation & Verification**
* **Git & GitHub**

## Academic Context

**Course:** ENCS4370 — Computer Architecture
**Institution:** Birzeit University
**Project:** Design and Verification of a Simplified Predicated RISC Processor using Verilog
**Semester:** Fall 2025/2026

## Team Project

This project was developed collaboratively as a team of Computer Engineering students. Responsibilities included processor design, RTL implementation, simulation, verification, testing, documentation, and project presentation.

## Author

**Batol Abu Samhadana**
Computer Engineering Student — Birzeit University

[LinkedIn](https://www.linkedin.com/in/batolabusamhadana) • [GitHub](https://github.com/batolabusamhadana)

**Hala Sarsour** 
Computer Engineering Student — Birzeit University

## Disclaimer

This repository contains an academic project developed for educational purposes as part of the Computer Architecture course at Birzeit University.
