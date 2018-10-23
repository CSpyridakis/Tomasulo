# Tomasulo
Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture) implementing Tomasulo's Algorithm

Implementation of Tomasulo's Algorithm with following specifications:

	* 5x Reservation Stations where:
		-3 of them are for arithmetical operations
		-2 of them are for logical operations

	* 2x Functional Units (one for each operation type)
		-Arithmetic FU is a 3 level pipeline unit
		-Logic FU is a 2 level pipeline unit

	* 1x Register File
		-32x 32bits Registers for Data
		-32x 5bits Registers for Data

	* Common Data Bus


# Import and Run 
	* In order to run simulation create a new project
	* Right click on your Project
	* Select "Add copy of source"
	* Select all .vhd files from ./src and ./test
	* Have fun :)