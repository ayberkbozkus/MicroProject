;*******************************************************************************
;@file				 Main.s
;@project		     Microprocessor Systems Term Project
;@31/01/2021
;
;@PROJECT GROUP
;@Group no: 41
;@Muhammet Dervis Kopuz 504201531
;@Ayberk Bozkış 150160067
;@member3
;@member4
;@member5
;*******************************************************************************
;*******************************************************************************
;@section 		INPUT_DATASET
;*******************************************************************************

;@brief 	This data will be used for insertion and deletion operation.
;@note		The input dataset will be changed at the grading. 
;			Therefore, you shouldn't use the constant number size for this dataset in your code. 
				AREA     IN_DATA_AREA, DATA, READONLY
IN_DATA			DCD		0x10, 0x20, 0x15, 0x65, 0x25, 0x01, 0x01, 0x12, 0x65, 0x25, 0x85, 0x46, 0x10, 0x00
END_IN_DATA

;@brief 	This data contains operation flags of input dataset. 
;@note		0 -> Deletion operation, 1 -> Insertion 
				AREA     IN_DATA_FLAG_AREA, DATA, READONLY
IN_DATA_FLAG	DCD		0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x02
END_IN_DATA_FLAG


;*******************************************************************************
;@endsection 	INPUT_DATASET
;*******************************************************************************

;*******************************************************************************
;@section 		DATA_DECLARATION
;*******************************************************************************

;@brief 	This part will be used for constant numbers definition.
NUMBER_OF_AT	EQU		20									; Number of Allocation Table
AT_SIZE			EQU		NUMBER_OF_AT*4						; Allocation Table Size


DATA_AREA_SIZE	EQU		AT_SIZE*32*2						; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 2 word (Value + Address)
															; Each word has 4 byte
ARRAY_SIZE		EQU		AT_SIZE*32							; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 1 word (Value)
															; Each word has 4 byte
LOG_ARRAY_SIZE	EQU     AT_SIZE*32*3						; Log Array Size
															; Each log contains 3 word
															; 16 bit for index
															; 8 bit for error_code
															; 8 bit for operation
															; 32 bit for data
															; 32 bit for timestamp in us

;//-------- <<< USER CODE BEGIN Constant Numbers Definitions >>> ----------------------	
;Flag codes for program status
PROGRAM_START	EQU			0								;Allocate flag code 0 to program start operation								
TIMER_START		EQU			1								;Allocate flag code 1 to program timer operation
FINISHED		EQU			2								;Allocate flag code 2 to program finish
	
;Operation Flags
REMOVE			EQU			0								;Allocate flag code 0 to remove data operation from Linked List
INSERT			EQU			1								;Allocate flag code 1 to inserting data to linked list
TRANSFORM		EQU			2								;Allocate flag code 2 to transforming linked list to array

;Error codes
NO_ERROR		EQU			0								;Allocate flag code 0 to No error explanation for all operations
NO_AREA			EQU			1								;Allocate flag code 1 to There is no allocable area explanation for insertion operations
DUPLICATE_DATA	EQU			2								;Allocate flag code 2 to Duplicated insertion operation explanation	for insertion operations
LL_EMPTY		EQU			3								;Allocate flag code 3 to The linked list is empty explanation for deletion operations
NO_ELEMENT		EQU			4								;Allocate flag code 4 to The element is not found explanation for deletion operations
CANT_TRANSFORM	EQU			5								;Allocate flag code 5 to The linked list could not be transformed explanation for Linked list to array function
NO_OPERATION	EQU			6								;Allocate flag code 6 to Operation is not found error.

;//-------- <<< USER CODE END Constant Numbers Definitions >>> ------------------------	

;*******************************************************************************
;@brief 	This area will be used for global variables.
				AREA     GLOBAL_VARIABLES, DATA, READWRITE		
				ALIGN	
TICK_COUNT		SPACE	 4									; Allocate #4 byte area to store tick count of the system tick timer.
FIRST_ELEMENT  	SPACE    4									; Allocate #4 byte area to store the first element pointer of the linked list.
INDEX_INPUT_DS  SPACE    4									; Allocate #4 byte area to store the index of input dataset.
INDEX_ERROR_LOG SPACE	 4									; Allocate #4 byte aret to store the index of the error log array.
PROGRAM_STATUS  SPACE    4									; Allocate #4 byte to store program status.
															; 0-> Program started, 1->Timer started, 2-> All data operation finished.
;//-------- <<< USER CODE BEGIN Global Variables >>> ----------------------															
				;MOVS	PROGRAM_STATUS,#0					;assign 0 to pogram status


;//-------- <<< USER CODE END Global Variables >>> ------------------------															

;*******************************************************************************

;@brief 	This area will be used for the allocation table
				AREA     ALLOCATION_TABLE, DATA, READWRITE		
				ALIGN	
__AT_Start
AT_MEM       	SPACE    AT_SIZE							; Allocate #AT_SIZE byte area from memory.
__AT_END

;@brief 	This area will be used for the linked list.
				AREA     DATA_AREA, DATA, READWRITE		
				ALIGN	
__DATA_Start
DATA_MEM        SPACE    DATA_AREA_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__DATA_END

;@brief 	This area will be used for the array. 
;			Array will be used at the end of the program to transform linked list to array.
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__ARRAY_Start
ARRAY_MEM       SPACE    ARRAY_SIZE						; Allocate #ARRAY_SIZE byte area from memory.
__ARRAY_END

;@brief 	This area will be used for the error log array. 
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__LOG_Start
LOG_MEM       	SPACE    LOG_ARRAY_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__LOG_END

;//-------- <<< USER CODE BEGIN Data Allocation >>> ----------------------															
							


;//-------- <<< USER CODE END Data Allocation >>> ------------------------															

;*******************************************************************************
;@endsection 	DATA_DECLARATION
;*******************************************************************************

;*******************************************************************************
;@section 		MAIN_FUNCTION
;*******************************************************************************

			
;@brief 	This area contains project codes. 
;@note		You shouldn't change the main function. 				
				AREA MAINFUNCTION, CODE, READONLY
				ENTRY
				THUMB
				ALIGN 
__main			FUNCTION
				EXPORT __main
				BL	Clear_Alloc					; Call Clear Allocation Function.
				BL  Clear_ErrorLogs				; Call Clear ErrorLogs Function.
				BL	Init_GlobVars				; Call Initiate Global Variable Function.
				BL	SysTick_Init				; Call Initialize System Tick Timer Function.
				LDR R0, =PROGRAM_STATUS			; Load Program Status Variable Addresses.
LOOP			LDR R1, [R0]					; Load Program Status Variable.
				CMP	R1, #2						; Check If Program finished.
				BNE LOOP						; Go to loop If program do not finish.
STOP			B	STOP						; Infinite loop.
				
				ENDFUNC
			
;*******************************************************************************
;@endsection 		MAIN_FUNCTION
;*******************************************************************************				

;*******************************************************************************
;@section 			USER_FUNCTIONS
;*******************************************************************************

;@brief 	This function will be used for System Tick Handler
SysTick_Handler	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
				EXPORT	SysTick_Handler
				
				;increase tick count
				LDR		r0,=TICK_COUNT					;load tick count address
				LDR		r1,[r0]							;load tick count value to r1
				ADDS	r1,#1							;increase tick count by 1
				STR		r1,[r0]							;Store new tick count value
				
				;read input data
				
				BX 		LR
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------							
				LDR		r0,=0xE000E010					;Load SysTick control and status register address
				LDR		r1,=3336						;Load the reload value to r1 register
				STR 	r1,[r0,#4]						;Store reload value to reload value register
				MOVS	r1,#0							;assign 0 to r1 register
				STR		r1,[r0,#8]						;clear current value register
				MOVS	r1,#7							;set enable,clock,and interrupt flags
				STR		r1,[r0]							;Store r1 value to SystickCSR register
				
				;update program status
				LDR		r0,=PROGRAM_STATUS				;load program status address
				LDR		r1,=TIMER_START					;load r1 with timer started info
				STR		r1,[r0]							;Change program status to 1
				
				BX 		LR								;return with LR
				
;//-------- <<< USER CODE END System Tick Timer Initialize >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to stop the System Tick Timer
SysTick_Stop	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Stop >>> ----------------------	
				LDR		r0,=0xE000E010					;Load SysTick control and status register address
				MOVS	r1,#0							;set enable,clock,and interrupt flags
				STR		r1,[r0]							;Store r1 value to SystickCSR register
				MOVS	r1,#0							;assign 0 to r1 register
				STR		r1,[r0,#8]						;clear current value register and count flag
				
				;update program status
				LDR		r0,=PROGRAM_STATUS				;load program status address
				LDR		r1,=FINISHED					;load r1 with finished info
				STR		r1,[r0]							;Change program status to 1
				
				BX 		LR								;return with LR
				
				
;//-------- <<< USER CODE END System Tick Timer Stop >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to clear allocation table
Clear_Alloc		FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Allocation Table Function >>> ----------------------															
				LDR		r0,=AT_MEM							;Load AT memory address
				LDR		r1,=NUMBER_OF_AT					;Load number of allocation table to r1
				MOVS	r2,#0								;assign 0 to r2 for clearing
				MOVS	r3,#0								;assign 0 to r3 for counting loops(i)
C_A_LOOP		CMP		r3,r1								;check if i>Number of allocations
				BGE		C_A_END								;branch to end of clear allocation
				PUSH	{r3}								;push r3 to stack
				LSLS	r3,#2								;multiply r3 by 4
				STR		r2,[r0,r3]							;clear allocation node
				POP		{r3}								;get r3 back from stack
				ADDS	r3,r3,#1							;increase r3 by 1
				B		C_A_LOOP							;branch to next iteration
				
			
C_A_END			BX 		LR									;return with LR
				
				
;//-------- <<< USER CODE END Clear Allocation Table Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************		

;@brief 	This function will be used to clear error log array
Clear_ErrorLogs	FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Error Logs Function >>> ----------------------															
				LDR		r0,=LOG_MEM							;Load log memory address
				LDR		r1,=NUMBER_OF_AT					;Load number of allocation table to r1
				MOVS	r2,#32								;assign 32 to r2, there is 32 cells
				MULS	r1,r2,r1							;multiply r1 by 32
				MOVS	r2,#3								;assign 3 to r2, each cell has 3 words
				MULS	r1,r2,r1							;multiply r1 by 3
				MOVS	r2,#0								;assign 0 to r2 for clearing
				MOVS	r3,#0								;assign 0 to r3 for counting loops(i)
C_E_LOOP		CMP		r3,r1								;check if i>log size
				BGE		C_E_END								;branch to end of clearing logs
				PUSH	{r3}								;push r3 to stack
				LSLS	r3,#2								;multiply r3 by 4
				STR		r2,[r0,r3]							;clear allocation node
				POP		{r3}								;get r3 back from stack
				ADDS	r3,r3,#1							;increase r3 by 1
				B		C_E_LOOP							;branch to next iteration
				
C_E_END			BX		LR									;Return with LR
				
				
;//-------- <<< USER CODE END Clear Error Logs Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************

;@brief 	This function will be used to initialize global variables
Init_GlobVars	FUNCTION			
;//-------- <<< USER CODE BEGIN Initialize Global Variables >>> ----------------------		
				MOVS 	r1,#0								;Assign 0 to r1 register for initialization
				LDR		r0,=TICK_COUNT						;Load address of TICK_COUNT	
				STR		r1,[r0]								;Initialize TICK_COUNT as 0
				LDR		r0,=FIRST_ELEMENT					;Load address of FIRST_ELEMENT
				STR		r1,[r0]								;Initialize FIRST_ELEMENT as 0
				LDR		r0,=INDEX_INPUT_DS					;Load address of INDEX_INPUT_DS
				STR		r1,[r0]								;Initialize INDEX_INPUT_DS as 0
				LDR		r0,=INDEX_ERROR_LOG					;Load address of INDEX_ERROR_LOG
				STR		r1,[r0]								;Initialize INDEX_ERROR_LOG as 0
				LDR		r0,=PROGRAM_STATUS					;Load address of PROGRAM_STATUS
				STR		r1,[r0]								;Initialize PROGRAM_STATUS as 0
				BX		LR									;Return with LR
				
;//-------- <<< USER CODE END Initialize Global Variables >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************	

;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
				
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------
				
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R0 <- The data to insert
;@return    R0 <- Error Code
Insert			FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------															
				
;//-------- <<< USER CODE END Insert Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R0 <- the data to delete
;@return    R0 <- Error Code
Remove			FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------															
				
;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------															

;//-------- <<< USER CODE END Linked List To Array >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to write errors to the error log array.
;@param		R0 -> Index of Input Dataset Array
;@param     R1 -> Error Code 
;@param     R2 -> Operation (Insertion / Deletion / LinkedList2Array)
;@param     R3 -> Data
WriteErrorLog	FUNCTION			
;//-------- <<< USER CODE BEGIN Write Error Log >>> ----------------------															
				
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------															
				
;//-------- <<< USER CODE END Get Now >>> ------------------------
				ENDFUNC
				
;*******************************************************************************	

;//-------- <<< USER CODE BEGIN Functions >>> ----------------------															


;//-------- <<< USER CODE END Functions >>> ------------------------

;*******************************************************************************
;@endsection 		USER_FUNCTIONS
;*******************************************************************************
				ALIGN
				END		; Finish the assembly file
				
;*******************************************************************************
;@endfile 			main.s
;*******************************************************************************				

