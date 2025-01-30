#!/bin/bash
LC_ALL=C
TERM_WIDTH=$(tput cols)


##############################################################################################################
######################################## PrettyTable.sh ######################################################
##############################################################################################################
## This script for github repe: https://github.com/jakobwesthoff/prettytable.sh

## how to use:
# {
#  printf 'PID\tUSER\tAPPNAME\n';
#  printf '%s\t%s\t%s\n' "1" "john" "foo bar";
#  printf '%s\t%s\t%s\n' "12345678" "someone_with_a_long_name" "blub blib blab bam boom";
# } | prettytable 3 ("3 is the number of columns")

            
_prettytable_char_top_left="┌"
_prettytable_char_horizontal="─"
_prettytable_char_vertical="│"
_prettytable_char_bottom_left="└"
_prettytable_char_bottom_right="┘"
_prettytable_char_top_right="┐"
_prettytable_char_vertical_horizontal_left="├"
_prettytable_char_vertical_horizontal_right="┤"
_prettytable_char_vertical_horizontal_top="┬"
_prettytable_char_vertical_horizontal_bottom="┴"
_prettytable_char_vertical_horizontal="┼"

# Default colors
_prettytable_color_blue="0;34"
_prettytable_color_green="0;32"
_prettytable_color_cyan="0;36"
_prettytable_color_red="0;31"
_prettytable_color_purple="0;35"
_prettytable_color_yellow="0;33"
_prettytable_color_gray="1;30"
_prettytable_color_light_blue="1;34"
_prettytable_color_light_green="1;32"
_prettytable_color_light_cyan="1;36"
_prettytable_color_light_red="1;31"
_prettytable_color_light_purple="1;35"
_prettytable_color_light_yellow="1;33"
_prettytable_color_light_gray="0;37"

# Somewhat special colors
_prettytable_color_black="0;30"
_prettytable_color_white="1;37"
_prettytable_color_none="0"

function _prettytable_prettify_lines() {
  cat - | sed -e "s@^@${_prettytable_char_vertical}@;s@\$@	@;s@	@	${_prettytable_char_vertical}@g"
}

function _prettytable_fix_border_lines() {
  cat - | sed -e "1s@ @${_prettytable_char_horizontal}@g;3s@ @${_prettytable_char_horizontal}@g;\$s@ @${_prettytable_char_horizontal}@g"
}

function _prettytable_colorize_lines() {
  local color="$1"
  local range="$2"
  local ansicolor="$(eval "echo \${prettytable_color${color}}")"

  cat - | sed -e "${range}s@\\([^${_prettytable_char_vertical}]\\{1,\\}\\)@"$'\E'"[${ansicolor}m\1"$'\E'"[${_prettytable_color_none}m@g"
}

function prettytable() {
  local cols="${1}"
  local color="${2:-none}"
  local input="$(cat -)"
  local header="$(echo -e "${input}"|head -n1)"
  local body="$(echo -e "${input}"|tail -n+2)"
  {
      # Top border
    echo -n "${_prettytable_char_top_left}"
    for i in $(seq 2 ${cols}); do
      echo -ne "\t${_prettytable_char_vertical_horizontal_top}"
    done
    echo -e "\t${_prettytable_char_top_right}"

    echo -e "${header}" | _prettytable_prettify_lines

    # Header/Body delimiter
    echo -n "${_prettytable_char_vertical_horizontal_left}"
    for i in $(seq 2 ${cols}); do
      echo -ne "\t${_prettytable_char_vertical_horizontal}"
    done
    echo -e "\t${_prettytable_char_vertical_horizontal_right}"

    echo -e "${body}" | _prettytable_prettify_lines

    # Bottom border
    echo -n "${_prettytable_char_bottom_left}"
    for i in $(seq 2 ${cols}); do
      echo -ne "\t${_prettytable_char_vertical_horizontal_bottom}"
    done
    echo -e "\t${_prettytable_char_bottom_right}"
  } | column -t -s $'\t' | _prettytable_fix_border_lines | _prettytable_colorize_lines "${color}" "2"
}

###########################################################################################################
############################################# COLORS ######################################################
###########################################################################################################

##
# Color Variables
##

RED='\e[31m' #error
GREEN='\e[32m' #sucess
YELLOW='\e[33m' #instructions
BLUE='\e[34m' #input
MAGENTA='\e[35m' #input
CYAN='\e[36m' #input
CLEAR='\e[0m'

##
# Color Functions
##

ColorRed(){
  echo -ne "$RED$1$CLEAR"
}

ColorGreen(){
  echo -ne "$GREEN$1$CLEAR"
}

ColorYellow(){
  echo -ne "$YELLOW$1$CLEAR"
}

ColorBlue(){
  echo -ne "$BLUE$1$CLEAR"
}

ColorMagenta(){
  echo -ne "$MAGENTA$1$CLEAR"
}

ColorCyan(){
  echo -ne "$CYAN$1$CLEAR"
}

function welcome() {
  ASCII_ART=$(figlet "ITI DBMS")

  ADDITIONAL_TEXT=$(cat <<EOT
    $(ColorYellow "To learn more about how to use ITI DBMS$BLUE")
    $(ColorYellow "go to https://github.com/nada19885/DBMS-ITI.git$BLUE")

    $(ColorYellow "The README contains a lot of information.$BLUE")
    $(ColorYellow "Authors: Nada Maher, Yoser Yasser$BLUE")
EOT
  )

  FULL_CONTENT="$ASCII_ART\n$ADDITIONAL_TEXT"
  BOX=$(echo -e "$FULL_CONTENT" | boxes -d shell -p a2 -a c -s ${TERM_WIDTH}x)
  COLORED_BOX=$(echo -e "$BOX" | while IFS= read -r line; do ColorBlue "$line"; done)

  echo -e "$COLORED_BOX"
  echo -e "Welcome to ITI DBMS:"
}

###########################################################################################################
############################################# Helpers #####################################################
###########################################################################################################

function displayTableData() {
  tableData="$1" 
  IFS=$'\n' read -r -d '' -a rows <<< "$tableData"

  headers="${rows[0]}"
  unset rows[0]

  IFS=':' read -ra columnsMetadata <<< "$headers"
  columns=()

  for metadata in "${columnsMetadata[@]}"; do
    columnName=$(echo "$metadata" | cut -d " " -f 1) 
    columns+=("$columnName")
  done

  {
    for index in "${!columns[@]}"; do
      if [[ $index -eq 0 ]]; then
        printf '%s' "${columns[$index]}"
      else
        printf '\t%s' "${columns[$index]}"
      fi
    done
    printf '\n'

    for row in "${rows[@]}"; do
      IFS=':' read -ra rowColumns <<< "$row"
      for colIndex in "${!rowColumns[@]}"; do
        if [[ $colIndex -eq 0 ]]; then
          printf '%s' "${rowColumns[$colIndex]}"
        else
          printf '\t%s' "${rowColumns[$colIndex]}"
        fi
      done
      printf '\n'
    done
  } | prettytable ${#columns[@]}
}

function getDirs() {
  dirs=()

  for dir in *; do
    if [[ -d $dir ]]; then
        if [[ "$dir" == *.db ]]; then
            dirs+=("$dir")
        fi
    fi
  done

  echo ${dirs[@]}
}

# Function to create a database
function create_database() {
    while true; do
        echo -e "$(ColorYellow 'Please enter database name ending with .db')"
        read -p "Enter database name: " db_name 

        # Call the validation function to check if the database name is valid
        if validate_database_creation "$db_name"; then
            # If validation passes, create the database
            if [ -d "./$db_name" ]; then 
                echo -e "$(ColorRed "Database [${db_name}] already exists!")"
            else
                mkdir "./$db_name"
                echo -e "$(ColorGreen "Database [${db_name}] created successfully.")"
            fi
            break  # Exit the loop if the database creation is successful
        fi
    done
}


#----------------------------------------------------------
# Validation function for database name
function validate_database_creation() {
    # list of reserved words
    reserved_keywords=("select" "insert" "update" "delete" "drop" "table" "alter" "create" "grant" "revoke" "use" "show" "int" "integer" "str" "string" "varchar" "float" "double" "for" "while" "if" "else" "break" "done" "function" )
    
    # Check if the database name starts with a number
    if [[ "$1" =~ ^[0-9] ]]; then 
        echo -e "$(ColorRed "Please enter a valid database name. It should not start with a number.")"
        echo
        return 1  # Return 1 to indicate failure
    fi
    
    # Check if the database name contains spaces
    if [[ "$1" =~ [[:space:]] ]]; then 
        echo -e "$(ColorRed "Please enter a valid database name without spaces.")"
        echo
        return 1  # Return 1 to indicate failure
    fi 
    # Check if the database name is a reserved keyword (case-insensitive)
    for keyword in "${reserved_keywords[@]}"; do
        if [[ "${1,,}" == "$keyword" ]]; then
            echo -e "$(ColorRed "The name '$1' is a reserved keyword. Please choose a different name.")"
            echo
            return 1  # Return 1 to indicate failure
        fi
     
    done
    
    if [[ "$1" == '' ]]; then
    	echo -e "$(ColorRed "No database name is entered")"
        echo
    	return 1
    fi 
    
    # Check length of the database name not exceeding 128 bytes
    if [[ ${#1} -gt 64 ]]; then
        echo -e "$(ColorRed "Please enter a valid database name (name can't exceed 128 bytes)")"
        echo
        return 1
    fi
    
    if [[ ! "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*\.db$ ]]; then

        echo -e "$(ColorRed "Please enter a valid database name.")"
        echo
    return 1  # Return 1 to indicate failure
    fi  
}


#--------------------------------------------------------------------


function list_databases() {
    # dir='.'  # Path of the current directory
    # echo "List of all databases ending with .db in the current directory:"
    
    # # Get the list of .db files
    # db_files=$(ls "$dir"/*.db 2>/dev/null)  # Suppress errors if no .db files exist
    
    # # Check if the list is empty
    # if [ -z "$db_files" ]; then
    #     echo "No databases found ending with .db"
    # else
    #     # List the databases without leaving blank lines
    #     echo "$db_files" | sed 's/:$//' | sed 's|^\./||' # Print just the filenames without extra lines
    # fi


    databases=($(getDirs))
    if [[ "${#databases[@]}" -eq 0 ]]; then
        echo -e "$(ColorRed "No databases found ending with .db")"
    else
        {
            printf 'Datbase\n';
            for database in ${databases[@]}; do
                printf '%s\n' "${database%/}";
            done
        } | prettytable 1

        echo -e "$(ColorYellow "${#databases[@]} rows in set")"
        echo "------------------------------------"
    fi
}

#-----------------------------------------------------------------------

# Function to drop a database
function drop_database() {
    read -p "Enter database name: " db_name
    if [ -d "./$db_name" ]; then
        read -p "Are you sure you want to delete the database '$db_name'? (y/n): " confirm
        if [ "$confirm" == "y" ]; then
            rm -r "./$db_name"
            echo -e "$(ColorGreen "Database '$db_name' has been deleted.")"
        else
            echo -e "$(ColorRed "Deletion aborted.")"
        fi
    else
        echo -e "$(ColorRed "Database '$db_name' does not exist.")"
    fi
}

#-------------------------------------------------------------------------

# Update the main menu function to call the combined manage_table function
function database_menu() {
echo -e    "\n+------------Table Menu------------------+"
	echo "| $(ColorGreen '1.') Manage Table (Create, Init, Insert) |"
	echo "| $(ColorGreen '2.') List Tables                         |"
	echo "| $(ColorGreen '3.') Remove Table                        |"
	echo "| $(ColorGreen '4.') Update Data                         |"
	echo "| $(ColorGreen '5.') Select Data                         |"
	echo "| $(ColorGreen '6.') Delete                              |"
	echo "| $(ColorGreen '7.') Exit                                |"
	echo "+---------------------------------------+"
	read -p "$(ColorBlue 'Enter your choice: ')" choice

    case $choice in
        1) manage_table ;;
        2) list_table ;;
        3) remove_table ;;
        4) update_data;;
        5) select_data;;
        6) delete;;
        7) exit ;;
        *) echo "Please enter a valid input"; database_menu ;;
    esac
}


#---------------------------------------------------
function validate_table_creation() {
    # List of reserved words for table names
    reserved_keywords=("select" "insert" "update" "delete" "drop" "table" "alter" "create" "grant" "revoke" "use" "show" "rename" "index" "primary" "foreign" "unique" "check" "int" "integer" "str" "string" "varchar" "float" "double" "for" "while" "if" "else" "break" "done" "function" )
    
    # Check if the table name starts with a number
    if [[ "$1" =~ ^[0-9] ]]; then
        echo "Please enter a valid table name. It should not start with a number."
        return 1  # Return 1 to indicate failure
    fi
    
    # Check if the table name contains spaces
    if [[ "$1" =~ [[:space:]] ]]; then
        echo "Please enter a valid table name without spaces."
        return 1  # Return 1 to indicate failure
    fi

    # Check if the table name is a reserved keyword (case-insensitive)
    for keyword in "${reserved_keywords[@]}"; do
        if [[ "${1,,}" == "$keyword" ]]; then
            echo "The name '$1' is a reserved keyword. Please choose a different name."
            return 1  # Return 1 to indicate failure
        fi
    done
    
    # Check if the table name is empty
    if [[ -z "$1" ]]; then
        echo "No table name is entered."
        return 1  # Return 1 to indicate failure
    fi

    # Check the length of the table name not exceeding 128 bytes
    if [[ ${#1} -gt 128 ]]; then
        echo "Please enter a valid table name (name can't exceed 128 bytes)."
        return 1  # Return 1 to indicate failure
    fi

    # Check if the table name contains only valid characters (alphanumeric and underscores)
    if [[ ! "$1" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Table name can only contain alphanumeric characters and underscores (_)."
        return 1  # Return 1 to indicate failure
    fi

    # If no validation errors, return 0 (success)
    return 0
}

#-----------------------------------------------------------------------------------------------------------
#Validate insertion Data
function validate_int() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Helper function to validate if a value is a valid string
function validate_str() {
    [[ "$1" =~ ^[a-zA-Z_]+$ ]]
}

# Helper function to check for empty values
function is_empty() {
    [[ -z "$1" ]]
}

# Helper function to check uniqueness of primary key
function check_unique_pk() {
    local table_name="$1"
    local column_index="$2"
    local value="$3"
    cut -d':' -f"$column_index" "$table_name.data" | tail -n +2 | grep -q "^$value$"
    [[ $? -ne 0 ]] # Returns true if the value is unique
}


#------------------------------------------------------------------------------------------------

# Insert data function with validation improvements

function insert_data() {
    read -p "Enter the table name to insert data into: " table_name

    if [[ -e "$table_name.meta" && -e "$table_name.data" ]]; then
        # Read column names and metadata
        IFS=$'\n' read -d '' -r -a metadata_lines < "$table_name.meta"
        column_metadata=()
        column_names=()
        for line in "${metadata_lines[@]}"; do
            column_metadata+=("$line")
            column_names+=("$(echo "$line" | cut -d':' -f1)")
        done

        while true; do
            echo "1. Insert data"
            echo "2. Exit"
            read -p "Enter your choice: " sub_choice

            case $sub_choice in
                1)
                    row_data=()
                    for i in "${!column_metadata[@]}"; do
                        column="${column_names[$i]}"
                        meta="${column_metadata[$i]}"
                        type=$(echo "$meta" | cut -d':' -f3)
                        constraint=$(echo "$meta" | cut -d':' -f2)

                        while true; do
                            read -p "Enter value for '$column' (Type: $type): " value

                            # Check if input is empty
                            if [[ "$constraint" == "NULL" ]] && is_empty "$value"; then
                                echo "Error: Input for '$column' cannot be empty. Please try again."
                                continue
                            fi

                            # Validate based on metadata type
                            if [[ "$type" == "Str" ]]; then
                                if validate_str "$value"; then
                                    break
                                else
                                    echo "Invalid input. '$value' is not a valid string. Please use alphabetic characters or underscores only."
                                fi
                            elif [[ "$type" == "Int" ]]; then
                                if validate_int "$value"; then
                                    break
                                else
                                    echo "Invalid input. '$value' is not a valid integer. Please enter a positive number."
                                fi
                            else
                                echo "Unknown metadata type. Skipping validation."
                                break
                            fi
                        done

                        # Check if primary key is unique
                        if [[ "$constraint" == "PK" ]]; then
                            column_index=$((i + 1))
                            while ! check_unique_pk "$table_name" "$column_index" "$value"; do
                                echo "Error: Value '$value' already exists as a primary key. Please enter a unique value."
                                read -p "Enter a unique value for '$column': " value
                            done
                        fi

                        # Add value to row data
                        row_data+=("$value")
                    done

                    # Write the row to the table
                    echo "${row_data[*]}" | tr ' ' ':' >> "$table_name.data"
                    echo "Data inserted into '$table_name' successfully."
                    ;;
                2)
                    break
                    ;;
                *)
                    echo "Invalid choice. Please try again."
                    ;;
            esac

            # Ask user if they want to insert more data
            read -p "Do you want to insert more data? (yes/no): " insert_more
            if [[ "$insert_more" == "no" ]]; then
                break
            fi
        done
    else
        echo "Table '$table_name' does not exist or is missing metadata."
    fi
}
#----------------------------------------------------------------------------------
#function to validate column names 
function validate_column_name() {
    # List of reserved keywords
    reserved_keywords=("select" "insert" "update" "delete" "drop" "table" "alter" "create" "grant" "revoke" "use" "show" "int" "integer" "str" "string" "varchar" "float" "double" "for" "while" "if" "else" "break" "done" "function" )
    
    # Check if the column name starts with a number
    if [[ "$1" =~ ^[0-9] ]]; then 
        echo "Error: Column name should not start with a number."
        return 1  # Return 1 to indicate failure
    fi
    
    # Check if the column name contains spaces
    if [[ "$1" =~ [[:space:]] ]]; then 
        echo "Error: Column name should not contain spaces."
        return 1  # Return 1 to indicate failure
    fi 

    # Check if the column name is a reserved keyword (case-insensitive)
    for keyword in "${reserved_keywords[@]}"; do
        if [[ "${1,,}" == "$keyword" ]]; then
            echo "Error: Column name '$1' is a reserved keyword. Please choose a different name."
            return 1  # Return 1 to indicate failure
        fi
    done
    
    # Check if the column name is empty
    if [[ -z "$1" ]]; then
        echo "Error: No column name entered."
        return 1  # Return 1 to indicate failure
    fi 
    
    # Check length of the column name (should not exceed 64 characters)
    if [[ ${#1} -gt 64 ]]; then
        echo "Error: Column name should not exceed 64 characters."
        return 1  # Return 1 to indicate failure
    fi
    
    # Check for valid column name pattern (only allows letters, numbers, and underscores; cannot start with special characters)
    if [[ ! "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "Error: Column name should only contain letters, numbers, or underscores and cannot start with special characters."
        return 1  # Return 1 to indicate failure
    fi  
    
    # If all checks pass
    return 0  # Return 0 to indicate success
}



#-----------------------------------------------------------------------------------------------------------------

# Function to manage the table operations
function manage_table() {
    while true; do
        echo "Please pick an option:"
	echo -e "\n+-------------Table Menu----------------+"
	echo "| $(ColorGreen '1.') Create Table                      |"
	echo "| $(ColorGreen '2.') Initialize Table (Set columns and |"
	echo "|    metadata)                         |"
	echo "| $(ColorGreen '3.') Insert Data into Table            |"
	echo "| $(ColorGreen '4.') Exit                              |"
	echo "+---------------------------------------+"
        read -p "Enter your choice: " choice

        case $choice in
            1)  # Create Table
                while true; do
                    read -p "Enter the table name: " table_name
                    if validate_table_creation "$table_name"; then
                        if [ ! -e "$table_name.data" ]; then
                            touch "$table_name.data"
                            touch "$table_name.meta"
                            echo "Table '$table_name' created successfully."
                            break
                        else
                            echo "The table '$table_name' already exists."
                        fi
                    else
                        echo "Invalid table name. Please try again."
                    fi
                done
                ;;
            2)  
            	read -p "Please enter the table you want to initialize: " table_name
		if [[ -e ./"$table_name".data && ! -s ./"$table_name".data ]]; then
		    while true; do
			read -p 'Please enter the number of columns: ' col_num
			# Validate that col_num is a positive number
			if [[ "$col_num" =~ ^[1-9][0-9]*$ ]]; then
			
			    pk_assigned=0  # Flag to ensure only one PK is assigned
			    columns=()  # Array to hold column names

			    for ((i = 1; i <= col_num; i++)); do
				while true; do
				    read -p "Please enter the name of column $i: " col_name
				    if validate_column_name "$col_name"; then
				        columns+=("$col_name")
				        meta_entry="$col_name:"
				        break  # Exit the loop once the column name is valid
				    else
				        echo "Invalid column name. Please try again."
				    fi
				done

				# Ask if the column should be the primary key (only if no PK has been assigned yet)
				if [[ $pk_assigned -eq 0 ]]; then
				    while true; do
				        read -p "Do you want '$col_name' to be the PK? (yes/no): " pk_ans
				        if [[ "$pk_ans" == "yes" ]]; then
				            meta_entry+="PK:"
				            pk_assigned=1  # Mark that a primary key has been assigned
				            break
				        elif [[ "$pk_ans" == "no" ]]; then
				            meta_entry+="NULL:"
				            break
				        else
				            echo "Invalid input. Please enter 'yes' or 'no'."
				        fi
				    done
				else
				    meta_entry+="NULL:"  # Automatically set as non-PK if a PK has already been assigned
				fi

				# Choose the data type for the column
				while true; do
				    echo "Please choose a data type for '$col_name':"
				    echo "1. Int"
				    echo "2. Str"
				    read -p "Enter your choice: " var
				    case $var in
				        1)
				            meta_entry+="Int"
				            break
				            ;;
				        2)
				            meta_entry+="Str"
				            break
				            ;;
				        *)
				            echo "Invalid choice. Please enter 1 for Int or 2 for Str."
				            ;;
				    esac
				done
				echo "$meta_entry" >> ./"$table_name".meta
			    done

			    echo "${columns[*]}" | tr ' ' ':' > ./"$table_name".data
			    echo "Table '$table_name' has been initialized successfully."
			    break  # Exit the initialization loop
			else
			    echo "Invalid input. Please enter a positive number for the number of columns."
			fi
		    done
		elif [[ -e ./"$table_name".data && -s ./"$table_name".data ]]; then
		    echo "Table '$table_name' is already initialized with columns:"
		    head -n 1 ./"$table_name".data | tr ':' '\n'
		else
		    echo "Table '$table_name' does not exist."
		fi
		;;
            3)  # Insert Data into Table
                insert_data
                ;;
            4)  # Exit
                echo "Exiting..."
                break
                ;;
            *)  # Default invalid choice
                echo "Invalid choice. Please choose again."
                ;;
        esac
    done
}

#-------------------------------------------------------------------------------------------------




# Function to list all tables in the current database
function list_table() {
    dir='.'  # path of the current directory
    echo "List of all tables in database:"
    if [ "$(ls -1 $dir | wc -l)" -gt 0 ]; then
        ls -1 "$dir"
    else 
        echo "No tables exist in your database, please create a table first."
    fi
}

#------------------------------------------
# Function to remove a table and check if the database contains any tables
function remove_table() {
    table_count=$(find . -type f -name "*.data" | wc -l)
    if [ "$table_count" -ge 1 ]; then 
        echo "There are $table_count tables available for removal."
        read -p "Enter the table name you want to remove: " removed_table
        data_file="$removed_table.data"
        meta_file="$removed_table.meta"
        if [ -e "$data_file" ] && [ -e "$meta_file" ]; then 
            while true; do
                read -p "Are you sure you want to delete the table '$removed_table'? (yes/no or y/n): " confirm
                # Convert to lowercase for case-insensitive comparison
                confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
                if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
                    rm "$data_file" "$meta_file"
                    echo "Table '$removed_table' has been deleted."
                    break
                elif [[ "$confirm" == "n" || "$confirm" == "no" ]]; then
                    echo "Deletion aborted."
                    break
                else
                    echo "Invalid input. Please enter 'yes' or 'no', or 'y' or 'n'."
                fi
            done
        else
            echo "The table '$removed_table' does not exist."
        fi
    else
        echo "No tables exist in the database."
    fi
}

#----------------------------------------------------------------

# Selecting data function
function select_data(){
    while true; do
        read -p "Enter the table name: " table_name
        file_path="./$table_name.data"  # Define the file_path
        
        if [[ -e "$file_path" ]]; then
            echo -e "\n+------------------------Select Option------------------------+"
            echo "| $(ColorGreen '1.') The entire table                                           |"
            echo "| $(ColorGreen '2.') A specific column                                          |"
            echo "| $(ColorGreen '3.') Select rows based on condition                             |"
            echo "+--------------------------------------------------------------+"

            read -p "Enter your choice (1, 2, or 3): " choice

            case "$choice" in
                1) 
                    # Check if the table is empty
                    if [ $(wc -l < "$file_path") -le 1 ]; then
                        echo "Table is empty (no data inserted)"
                    else
                        # Display the entire table
                        # column -t -s ':' "$file_path"
                        displayTableData "$(awk -F ':' '{print}' $file_path)" 
                    fi
                    break
                    ;;
                2)
		 echo "Available columns:"
		head -n 1 "$file_path" | tr ':' '\n'

		# Loop until a valid column name is entered
		while true; do
		    read -p "Enter the column name to display: " coln

		    # Check if the column exists
		    column_exists=$(head -n 1 "$file_path" | tr ':' '\n' | grep -w "$coln" | wc -l)

		    if [ "$column_exists" -eq 0 ]; then
			echo "Error: Column '$coln' does not exist. Please try again."
		    else
			# Extract and display the specific column
			echo "Values of column '$coln':"
            data=$(awk -F: -v column="$coln" '
			BEGIN {
			    var = -1
			}
			{
			    if (NR == 1) {
                    for (i = 1; i <= NF; i++) {

                        if ($i == column) {
                            var = i
                            break
                        }

                    }

                    if (var == -1) {
                        print "Error: Column not found."
                        exit 1
                    }
			    } else {
                    print $var
			    }
			}
			' "$file_path")

            full_data="${coln}"$'\n'"${data}"
            displayTableData "$full_data"

			# Call the database_menu function after displaying the column values
			database_menu
			return
		    fi
		done
                    ;;
                3)     
		echo "Available columns:"
		head -n 1 "$file_path" | tr ':' '\n'

		# Loop until a valid column name is entered
		while true; do
		    read -p "Enter the column name to apply condition: " coln
		    column_exists=$(head -n 1 "$file_path" | tr ':' '\n' | grep -w "$coln" | wc -l)

		    if [ "$column_exists" -eq 0 ]; then
			echo "Error: Column '$coln' does not exist. Please try again."
		    else
			# Break the loop if the column exists
			break
		    fi
		done

		# Loop until a valid condition value is entered
		while true; do
		    read -p "Enter the condition value: " condition_val

		    # Check if the condition value exists in the column
		    condition_exists=$(awk -F: -v column="$coln" -v value="$condition_val" '
		    BEGIN {
			var = -1;
			found = 0;
		    }
		    {
			if (NR == 1) {
			    # Find the column index
			    for (i = 1; i <= NF; i++) {
				if ($i == column) {
				    var = i;
				    break;
				}
			    }
			} else if ($var == value) {
			    found = 1;
			}
		    }
		    END { print found; }
		    ' "$file_path")

		    if [ "$condition_exists" -eq 0 ]; then
			echo "Error: Condition value '$condition_val' does not exist in column '$coln'. Please try again."
		    else
			# Display all rows based on the condition
            data=$(awk -F: -v column="$coln" -v value="$condition_val" '
                BEGIN {
                    var = -1;
                }
                {
                    if (NR == 1) {
                    # Find the column index
                    for (i = 1; i <= NF; i++) {
                        if ($i == column) {
                            var = i;
                            break;
                        }
                    }
                    } else if ($var == value) {
                    print $0;  # Print the entire row if the condition matches
                    }
                }
                ' "$file_path"
            )
            
            header=$(awk 'NR==1 {print; exit}' "$file_path")
            full_data="${header}"$'\n'"${data}"
            displayTableData "$full_data"

			# Call the database_menu function after displaying the result
			database_menu
			return
		    fi
		done
		;;
                *)
                    echo "Invalid choice. Please select 1, 2, or 3."
                    ;;
            esac
        else
            echo "Table '$table_name' does not exist."
            echo "Available tables:"
            # List available tables
            ls *.data 2>/dev/null | sed 's/\.data$//'
        fi
    done
}


#-------------------------------------------------------------------------------------------------------------------------------
function update_data() {
    read -p "Enter the table name to update data in: " table_name
    file_path="./$table_name.data"
    meta_file="./$table_name.meta"

    if [[ -e "$file_path" && -e "$meta_file" ]]; then
        # Read column names and metadata
        IFS=$'\n' read -d '' -r -a metadata_lines < "$meta_file"
        column_metadata=()
        column_names=()
        for line in "${metadata_lines[@]}"; do
            column_metadata+=("$line")
            column_names+=("$(echo "$line" | cut -d':' -f1)")
        done

        while true; do
            echo "1. Update data"
            echo "2. Exit"
            read -p "Enter your choice: " sub_choice

            case $sub_choice in
                1)
                    row_data=()
                    while true; do
                        echo "Available columns:"
                        for col in "${column_names[@]}"; do
                            echo "- $col"
                        done

			# Get the column name
			read -p "Enter the column name to update: " col_name

			# Check if column name exists
			if [[ ! " ${column_names[@]} " =~ " $col_name " ]]; then
			    echo "Error: Column '$col_name' does not exist. Please try again."
			    continue
			fi

			# Get column index and metadata
			col_index=$(( $(echo "${column_names[@]}" | tr ' ' '\n' | grep -nx "$col_name" | cut -d':' -f1) ))
			if [[ -z "$col_index" ]]; then
			    echo "Error: Could not determine column index for '$col_name'."
			    continue
			fi

			meta="${column_metadata[$((col_index-1))]}"
			type=$(echo "$meta" | cut -d':' -f3)
			constraint=$(echo "$meta" | cut -d':' -f2)

			# Get the old value to update
			read -p "Enter the current value of '$col_name' you want to change: " old_value

			# Check if old value exists in the column
			exists=$(awk -F: -v col_index="$col_index" -v old_val="$old_value" '
			    NR > 1 { if ($col_index == old_val) { found=1; exit } }
			    END { if (!found) exit 1 }
			' "$file_path")

			if [[ $? -ne 0 ]]; then
			    echo "Error: Old value '$old_value' not found in the column '$col_name'. Please try again."
			    continue
			fi


                        # Validate new value input
                        while true; do
                            read -p "Enter the new value for '$col_name' (Type: $type): " new_value

                            # Validate input based on type
                            if [[ "$type" == "Str" ]]; then
                                if validate_str "$new_value"; then
                                    break
                                else
                                    echo "Invalid input. '$new_value' is not a valid string. Please use alphabetic characters or underscores only."
                                fi
                            elif [[ "$type" == "Int" ]]; then
                                if validate_int "$new_value"; then
                                    break
                                else
                                    echo "Invalid input. '$new_value' is not a valid integer. Please enter a positive number."
                                fi
                            else
                                echo "Unknown metadata type. Skipping validation."
                                break
                            fi
                        done

                        # Check for primary key uniqueness if applicable
                        if [[ "$constraint" == "PK" ]]; then
                            while ! check_unique_pk "$table_name" "$col_index" "$new_value"; do
                                echo "Error: Value '$new_value' already exists as a primary key. Please enter a unique value."
                                read -p "Enter a unique value for '$col_name': " new_value
                            done
                        fi

                        # Update the value in the data
                        awk -F: -v col_index="$col_index" -v old_val="$old_value" -v new_val="$new_value" '
                        BEGIN { OFS=":" }
                        NR == 1 { print $0 }
                        NR > 1 { if ($col_index == old_val) $col_index = new_val; print $0 }
                        ' "$file_path" > "$file_path.temp" && mv "$file_path.temp" "$file_path"

                        echo "Data updated successfully in column '$col_name'."
                        break
                    done
                    ;;

                2)
                    break
                    ;;

                *)
                    echo "Invalid choice. Please try again."
                    ;;

            esac

            # Ask user if they want to update more data
            read -p "Do you want to update more data? (yes/no): " update_more
            if [[ "$update_more" == "no" ]]; then
                break
            fi
        done
    else
        echo "Table '$table_name' or metadata file does not exist."
    fi
}
#-----------------------------------------------------
# Delete a record or column from the table
function delete() {
    while true; do
        # List available tables
        echo "Available tables:"
        ls *.data 2>/dev/null | sed 's/\.data$//'  # List table files without the .data extension

        # Ask user for the table name
        read -p "Enter the table name: " table_name
        file_path="./$table_name.data"  # Define the file path to the table file

        # Check if the table exists
        if [[ -e "$file_path" ]]; then
            break  # Exit the loop if a valid table name is provided
        else
            echo "Error: Table '$table_name' does not exist. Please try again."
        fi
    done

    # Once a valid table name is provided, proceed with delete options
 echo "+------------Delete Options------------------+"
    echo "| $(ColorGreen '1.') Delete a record (row)                   |"
    echo "| $(ColorGreen '2.') Delete a column                         |"
    echo "+-------------------------------------------+"
    read -p "Enter your choice (1 or 2): " choice


        case "$choice" in
            1)
		echo "Available columns:"
		head -n 1 "$file_path" | tr ':' '\n'  # Display column names from the first row

		while true; do
		    read -p "Enter column to delete record from: " coldel

		    # Check if the entered column exists
		    if head -n 1 "$file_path" | grep -q -w "$coldel"; then
			# Column exists, proceed to check if value exists in the column
			read -p "Enter value to delete: " vldel

			# Check if the value exists in the specified column in the entire table
			value_exists=$(awk -F: -v column="$coldel" -v value="$vldel" '
			BEGIN {
			    var = -1
			}
			{
			    if (NR == 1) {
				# Find the column index
				for (i = 1; i <= NF; i++) {
				    if ($i == column) {
				        var = i
				        break
				    }
				}
				if (var == -1) {
				    exit 1  # Column not found
				}
			    } else {
				# Check if the value exists in the column
				if ($var == value) {
				    found = 1
				    exit 0
				}
			    }
			}
			END {
			    if (found != 1) {
				print "not_found"
			    }
			}
			' "$file_path")

			if [[ "$value_exists" == "not_found" ]]; then
			    # Value doesn't exist in the column, notify the user
			    echo "Error: Value '$vldel' does not exist in column '$coldel'. No record was deleted."
			else
			    # Value exists, proceed with deletion
			    awk -F: -v column="$coldel" -v value="$vldel" '
			    BEGIN {
				var = -1
			    }
			    {
				if (NR == 1) {
				    # Find the column index
				    for (i = 1; i <= NF; i++) {
				        if ($i == column) {
				            var = i
				            break
				        }
				    }
				    if (var == -1) {
				        exit 1  # Column not found
				    }
				} else {
				    # Skip the row if the value matches the condition
				    if ($var == value) {
				        next  # Skip this row
				    }
				}
				# Print the row if it doesnt match the condition
				print $0
			    }' "$file_path" > tmp && mv tmp "$file_path"

			    echo "Record with value '$vldel' in column '$coldel' has been deleted."
			fi
			break  # Exit the loop once the deletion process is completed (or skipped)
		    else
			# Column does not exist, prompt the user again
			echo "Error: Column '$coldel' does not exist. Please enter a valid column name."
		    fi
		done
                ;;
            2)
		echo "Available columns:"
		head -n 1 "$file_path" | tr ':' '\n'  # Show the column names (first row)

		while true; do
		    read -p "Enter column to delete: " coldel  # Get the column name to delete

		    # Check if the entered column exists
		    if head -n 1 "$file_path" | grep -q -w "$coldel"; then
			# Column exists, proceed to delete from .data file
			awk -F: -v column="$coldel" '
			BEGIN {
			    var = -1
			}
			{
			    if (NR == 1) {
				# Find the column index in the header (first row)
				for (i = 1; i <= NF; i++) {
				    if ($i == column) {
				        var = i
				        break
				    }
				}
				if (var == -1) {
				    print "Error: Column not found."
				    exit 1
				}
				# Print the header without the column
				for (i = 1; i <= NF; i++) {
				    if (i != var) {
				        if (i == 1) {
				            printf "%s", $i
				        } else {
				            printf ":%s", $i
				        }
				    }
				}
				print ""  # Print the modified header
			    } else {
				# Print each row, skipping the value of the deleted column
				for (i = 1; i <= NF; i++) {
				    if (i != var) {
				        if (i == 1) {
				            printf "%s", $i
				        } else {
				            printf ":%s", $i
				        }
				    }
				}
				print ""  # Print the modified row
			    }
			}' "$file_path" > tmp && mv tmp "$file_path"  # Update the table data file

			# Now proceed to delete from .meta file
			awk -F: -v column="$coldel" '
			{
			    # Keep all lines except the one with the deleted column name
			    if ($1 != column) {
				print $0
			    }
			}' "$table_name.meta" > tmp_meta && mv tmp_meta "$table_name.meta"  # Update the metadata file

			echo "Column '$coldel' has been deleted from the table '$table_name' and metadata file."
			break  # Exit the loop once the column is deleted
		    else
			# Column does not exist, prompt the user again
			echo "Error: Column '$coldel' does not exist. Please enter a valid column name."
		    fi
		done

                ;;
            *)
                echo "Invalid choice. Please select 1 or 2."
                ;;
        esac
}



        

#--------------------------------------------------------------------





# Main menu function to interact with the user
function Main_Menu() {
    while true; do
        echo -e "\n+---------Database Menu---------+"
        echo "| $(ColorGreen '1.') Create Database            |"
        echo "| $(ColorGreen '2.') List Databases             |"
        echo "| $(ColorGreen '3.') Connect to Database        |"
        echo "| $(ColorGreen '4.') Drop Database              |"
        echo "| $(ColorGreen '5.') Exit                       |"
        echo "+--------------------------------+"

        read -p "$(ColorBlue 'Enter your choice: ')" choice 
        case $choice in
            1) create_database;;
            2) list_databases;;
            3) connect_to_database;;
            4) drop_database;;
            5) echo -e "$(ColorYellow "Good Bye!")"; exit 0 ;;
            *) echo -e "$(ColorRed "Invalid choice, please try again.")"; Main_Menu;;
        esac
    done
}

# Function to connect to a database
function connect_to_database() {
    read -p "Please enter the database name that you would like to connect to: " db_name 
    if [ -d "./$db_name" ]; then 
        cd "./$db_name"
        while true; do
            database_menu
        done
    else 
        echo "There is no database with this name."
    fi
}

welcome
Main_Menu
