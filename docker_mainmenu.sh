#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__TITLE_FG_LIGHTBLUE=$'\e[30;38;5;45m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__INSIDE_BG_WHITE=$'\e[30;48;5;15m'
DOCKER__OUTSIDE_BG_LIGHTGREY=$'\e[30;48;5;246m'

#---Define constants
DOCKER__FIVESPACES="     "
DOCKER__READ_FG_EXITING_NOW="Exiting Docker Main-menu..."


#---Define PATHS
docker__run_multiple_dockfiles_filename="docker_run_multiple_dockfiles.sh"
docker__create_image_from_existing_repository_filename="docker_create_image_from_existing_repository.sh"
docker__create_image_from_container_filename="docker_create_image_from_container.sh"
docker__run_container_from_a_repository_filename="docker_run_container_from_a_repository.sh"
docker__remove_image_filename="docker_remove_image.sh"
docker__remove_container_filename="docker_remove_container.sh"
docker__cp_fromto_container_filename="docker_cp_fromto_container.sh"
docker__create_dockerfile_filename="docker_create_dockerfile_filename.sh"
docker__git_push_filename="git_push.sh"
docker__git_pull_filename="git_pull.sh"

docker__repo_LTPP3_ROOTFS_dir=/repo/LTPP3_ROOTFS
docker__repo_LTPP3_ROOTFS_development_tools_dir=/repo/LTPP3_ROOTFS/development_tools

docker__run_multiple_dockfiles_fpath=${docker__repo_LTPP3_ROOTFS_dir}/${docker__run_multiple_dockfiles_filename}
docker__create_image_from_existing_repository_fpath=${docker__repo_LTPP3_ROOTFS_development_tools_dir}/${docker__create_image_from_existing_repository_filename}
docker__create_image_from_container_fpath=${docker__repo_LTPP3_ROOTFS_development_tools_dir}/${docker__create_image_from_container_filename}
docker__run_container_from_a_repository_fpath=${docker__repo_LTPP3_ROOTFS_development_tools_dir}/${docker__run_container_from_a_repository_filename}
docker__remove_image_fpath=${docker__repo_LTPP3_ROOTFS_development_tools_dir}/${docker__remove_image_filename}
docker__remove_container_fpath=${docker__repo_LTPP3_ROOTFS_development_tools_dir}/${docker__remove_container_filename}
docker__cp_fromto_container_fpath=${docker__repo_LTPP3_ROOTFS_development_tools_dir}/${docker__cp_fromto_container_filename}
docker__create_dockerfile_fpath=${docker__repo_LTPP3_ROOTFS_development_tools_dir}/${docker__create_dockerfile_filename}
docker__git_push_fpath=${docker__repo_LTPP3_ROOTFS_development_tools_dir}/${docker__git_push_filename}
docker__git_pull_fpath=${docker__repo_LTPP3_ROOTFS_development_tools_dir}/${docker__git_pull_filename}

#---Trap ctrl-c and Call ctrl_c()

# trap CTRL_C_func INT

# function CTRL_C_func() {
#     echo -e "\r"
#     echo -e "\r"
#     echo -e ${DOCKER__READ_FG_EXITING_NOW}
#     echo -e "\r"
#     echo -e "\r"

#     exit
# }


#---Local functions & subroutines
function GOTO__func {
	#Input args
    LABEL=$1
	
	#Define Command line
    cmd_line=$(sed -n "/$LABEL:/{:a;n;p;ba;};" $0 | grep -v ':$')
	
	#Execute Command line
    eval "${cmd_line}"
	
	#Exit Function
    exit
}

press_any_key__localfunc() {
	#Define constants
	local cTIMEOUT_ANYKEY=10

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${cTIMEOUT_ANYKEY} ]];
	do
		delta_tcounter=$(( ${cTIMEOUT_ANYKEY} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	echo -e "\r"
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_LIGHTBLUE}                                DOCKER${DOCKER__TITLE_BG_LIGHTBLUE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__mychoice=""
}

docker__mainmenu__sub() {
    while true
    do
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__TITLE_FG_LIGHTBLUE}DOCKER MAIN-MENU${DOCKER__NOCOLOR}"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}1. Create ${DOCKER__GENERAL_FG_YELLOW}multiple${DOCKER__NOCOLOR} ${DOCKER__IMAGEID_FG_BORDEAUX}images${DOCKER__NOCOLOR} using ${DOCKER__TITLE_FG_LIGHTBLUE}docker-files${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}2. Create an ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR} from a ${DOCKER__REPOSITORY_FG_PURPLE}repository${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}3. Create an ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR} from a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}4. Run ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR} from a ${DOCKER__REPOSITORY_FG_PURPLE}repository${DOCKER__NOCOLOR} "
        echo -e "${DOCKER__FIVESPACES}5. Remove ${DOCKER__IMAGEID_FG_BORDEAUX}image(s)${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}6. Remove ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container(s)${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}7. Copy a ${DOCKER__FILES_FG_ORANGE}file${DOCKER__NOCOLOR} from/to a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}p. Git ${DOCKER__OUTSIDE_BG_LIGHTGREY}${DOCKER__OUTSIDE_FG_WHITE}Push${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}g. Git ${DOCKER__INSIDE_BG_WHITE}${DOCKER__INSIDE_FG_LIGHTGREY}Pull${DOCKER__NOCOLOR}"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}q. Quit"
        echo -e "----------------------------------------------------------------------"
        echo -e "\r"	

        while true
        do
            #Select an option
            read -N 1 -e -p "Please choose an option: " docker__mychoice
            echo -e "\r"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__mychoice} ]]; then
                if [[ ${docker__mychoice} =~ [1-7,p,g,q] ]]; then
                    break
                else
                    tput cuu1	#move UP with 1 line
                    tput cuu1	#move UP with 1 line
                    tput el		#clear until the END of line
                fi
            else
                tput cuu1	#move UP with 1 line
                tput el		#clear until the END of line
            fi
        done
            
        #Goto the selected option
        case ${docker__mychoice} in
            1)
                ${docker__run_multiple_dockfiles_fpath}
                ;;

            2)
                ${docker__create_image_from_existing_repository_fpath}
                ;;

            3)
                ${docker__create_image_from_container_fpath}
                ;;

            4)
                ${docker__run_container_from_a_repository_fpath}
                ;;

            5)
                ${docker__remove_image_fpath}
                ;;

            6)
                ${docker__remove_container_fpath}
                ;;

            7)
                ${docker__cp_fromto_container_fpath}
                ;;        
            
            p)  
                ${docker__git_push_fpath}
                ;;

            g)  
                ${docker__git_pull_fpath}
                ;;

            q)
                exit
                ;;
        esac
    done
}


main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker__mainmenu__sub
}

#Execute main subroutine
main_sub