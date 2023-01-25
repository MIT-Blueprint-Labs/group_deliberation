// Set-up 
version 17 
clear all 
set more off 
set trace off 
set tracedepth 1 


// Paths
global user 		`c(username)'
global root 		"A:/groups_deliberation"
global code			"${root}/${user}/code"
global data 		"${root}/${user}/clean_data"
global output 		"${root}/${user}/output"
global raw_data 	"${root}/${user}/raw_data"

// Switches 
local clean_gift 		0
local clean_lottery   	0
local tables 			1

// Execute
if `clean_gift' == 1 {
	do "${code}/gift_exchange_clean.do"
}

if `clean_lottery' == 1 {
	do "${code}/lottery_clean.do"
}

if  `tables' == 1 {
	do "${code}/tables.do"
}