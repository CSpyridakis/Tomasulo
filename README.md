# Tomasulo ![MIT license](https://img.shields.io/github/license/CSpyridakis/Tomasulo.svg?style=plastic) ![Size](https://img.shields.io/github/repo-size/CSpyridakis/Tomasulo.svg?style=plastic)

Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture). This project is an educational proof of concept implementation of Tomasulo's Algorithm with following specifications:

### 5 x Reservation Stations:  
* 3 of them are for arithmetic operations 
* 2 of them are for logic operations

### 2 x Functional Units (one for each operation type): 
* Arithmetic FU is a 3 stage pipeline unit 
* Logic FU is a 2 stage pipeline unit

### Register File:
* 32 x 32bits Registers for Data
* 32 x 5bits Registers for Tags

### Common Data Bus
* Broadcasts data from FU to RS and ROB

### Issue Unit (acceptable operations):
* add/addi 
* sub/subi
* sll
* and/andi
* or/ori
* not 

### Reorder Buffer:
* 30 x Available Slots

## Documentation
### Reports
If you want more information about each module you could read (or just try to read, unfortunately at this point are only in greek language) the following report files:
* [Milestone 1-a](./doc/Milestone-1a.pdf)
* [Milestone 1-b](./doc/Milestone-1b.pdf)
* [Milestone 2](./doc/Milestone-2.pdf)
* [Milestone 3](./doc/Milestone-3.pdf) 

### Diagrams

Block and timing diagrams are able to be changed:
* For [xml](./doc/schematics/) files (block diagrams) i have used [draw.io](https://www.draw.io/)
* For [json](./doc/timingDiagram/) file (timing diagram) i have used [Wavedrom editor](https://wavedrom.com)
 

## Usage 

### Enviroment
This project was developed using [Xilinx ISE 14.7](https://www.xilinx.com/products/design-tools/ise-design-suite.html)

### Import and Run

In order to import project and run simulations:

1. Create a new project

2. Right click on your Project

3. Select "Add copy of source"

4. Select all  [source files](./src) 

5. If you want to run my test code import all [test files](./test) and open [simulation files](./sim)

(Simulation screenshots are included [here](./doc/sim))
