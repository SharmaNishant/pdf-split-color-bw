#!/bin/bash

function pdf-splitter-colbw(){

	#save pdf file name into a variable
	pdf_file=$1

	#a file to store temporary info in
	dump_file="/tmp/pageinfo.txt"

	#dump page color info into the dump file
	gs -o - -sDEVICE=inkcov -q ${pdf_file} 2> /dev/null > ${dump_file}

	#retrieve different page numbers
	black_pages=`pdf_split_get_black_page_list ${dump_file}`
	color_pages=`pdf_split_get_color_page_list ${dump_file}`

	#generate corresponding files
	pdftk ${pdf_file} cat ${black_pages} output black_output.pdf
	pdftk ${pdf_file} cat ${color_pages} output color_output.pdf
}

function pdf_split_get_color_page_list(){

	local dump_file=$1

	#read pages print info into a var
	print_info=`cat -n ${dump_file}`

	local page_list=""

	while IFS= read -r line ; do

		page_num=`echo $line | awk '{print $1}'`
		color_C=`echo $line | awk '{print $2}'`
		color_Y=`echo $line | awk '{print $3}'`
		color_M=`echo $line | awk '{print $4}'`
		color_K=`echo $line | awk '{print $5}'`

		if (( $(bc <<< "${color_C} > 0.0") )) || (( $(bc <<< "${color_Y} > 0.0") )) || (( $(bc <<< "${color_M} > 0.0") ))
		then
			page_list="${page_list}"${page_num}" "
		fi

	done <<< "${print_info}"
#	page_list=`echo ${page_list:0:-1}`  # remove last char
	echo "${page_list}"
}

function pdf_split_get_black_page_list(){

	local dump_file=$1

	#read pages print info into a var
	print_info=`cat -n ${dump_file}`

	local page_list=""

	while IFS= read -r line ; do
#		echo $line;

		page_num=`echo $line | awk '{print $1}'`
		color_C=`echo $line | awk '{print $2}'`
		color_Y=`echo $line | awk '{print $3}'`
		color_M=`echo $line | awk '{print $4}'`
		color_K=`echo $line | awk '{print $5}'`

		if (( $(bc <<< "${color_C} == 0.0") )) && (( $(bc <<< "${color_Y} == 0.0") )) && (( $(bc <<< "${color_M} == 0.0") ))
		then
			page_list="${page_list}"${page_num}" "
		fi

	done <<< "${print_info}"
#	page_list=`echo ${page_list:0:-1}`  # remove last char
	echo "${page_list}"
}




#
#	page_info=`while IFS= read -r line ; do echo $line; done <<< "$print_info"`
#
#	for $page in ${page_info}
#	do
#		colors=( ${page} )
#		color_C=${colors[1]}
#		color_Y=${colors[1]}
#		color_M=${colors[1]}
#		color_K=${colors[1]}
#
#		page_list=${page_list}""
#	done
#
#
#	page_list=""

#
