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
		-32x 5bits Registers for Tags

	* Common Data Bus

	* Issue Unit

# Import and Run 

	* In order to run simulation create a new project
	
	* Right click on your Project
	
	* Select "Add copy of source"
	
	* Select all .vhd files from ./src 
	
	* If you want to run our test code import all .vhd files from ./test and open simulation files from ./sim (Simulation screenshots are included on ./doc/sim)

	* Reports path  : ./doc/Milestone-X.pdf