#!/bin/bash
#---Local Functions
press_any_key__func() {
	#Define constants
	local cTIMEOUT_ANYKEY=0

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


#---Define path variables
press_any_key__func
echo -e "\r"
echo "---Defining Varabiles (Filenames, Directories, Paths, Full-Paths)---"
echo -e "\r"
home_dir=~
etc_dir=/etc
home_scripts_dir=${home_dir}/scripts
Downloads_dir=${home_dir}/Downloads
sunplus_foldername="SP7021"
sunplus_dir=${home_dir}/${sunplus_foldername}

#---Check if current working directory
echo -e "\r"
echo "---Checking current working directory---"
echo -e "\r"
current_working_dir=`pwd`

if [[ ${current_working_dir} != ${home_dir} ]]; then
	echo -e "\r"
	echo ">Current working directory is <${current_working_dir}>..."
	echo ">>>Please navigate to <${home_dir}>..."
	echo ">>>...And execute script again."
	echo -e "\r"
	echo "Exiting Now..."
	echo -e "\r"
	echo -e "\r"

    exit
fi


#---Check if Sunplus is already installed
if [[ -d ${sunplus_dir} ]]; then
	echo -e "\r"
	echo "---Removing existing directory: ${sunplus_dir}---"
	echo -e "\r"
	rm -rf ${sunplus_dir}
fi


#---Execute commands
press_any_key__func
echo -e "\r"
echo "---Installing Libraries for Sunplus---"
echo -e "\r"
apt-get install openssl libssl-dev bison flex -y

press_any_key__func
echo -e "\r"
echo "---Cloning Sunplus Image (in other words: writing data to local disk)---"
echo -e "\r"
git clone https://github.com/sunplus-plus1/SP7021.git

echo -e "\r"
echo ">Navigating to ${sunplus_dir}"
echo -e "\r"
cd ${sunplus_dir}

echo -e "\r"
echo ">Adding <${sunplus_dir}/boot/uboot/tools> to <PATH>"
echo -e "\r"
echo "export PATH=\$PATH:"${sunplus_dir}/boot/uboot/tools >>  ${home_dir}/.bashrc

#Remove DOUBLE ENTRIES in
echo -e "\r"
echo ">Removing double-entries in <PATH> (if any)"
echo -e "\r"
PATH=`perl -e 'print join ":", grep {!$h{$_}++} split ":", $ENV{PATH}'`
export PATH


press_any_key__func
echo -e "\r"
echo "---Executing script <${home_dir}/.bashrc>---"
echo -e "\r"
source ${home_dir}/.bashrc

press_any_key__func
echo -e "\r"
echo "---Updating submodules with git-command---"
echo -e "\r"
git submodule update --init --recursive
git submodule foreach --recursive git checkout master
cd ${sunplus_dir}/linux/kernel
git checkout 268e3fe2c2d9a644c7fa5dd8e587e4c4c0a31991

echo -e "\r"
echo ">Navigating to ${sunplus_dir}"
echo -e "\r"
cd ${sunplus_dir}


echo -e "\r"
echo -e "---Kernel Configuration File"
echo -e ">Copying: ${make_menuconfig_filename}"
echo -e ">from: ${home_lttp3rootfs_kernel_makeconfig_dir}"
echo -e ">to: ${SP7xxx_linux_kernel_dir}"
echo -e ">as: ${make_menuconfig_default_filename}"
echo -e "\r"
echo -e "\r"
make_menuconfig_filename="armhf_kernel.config"
make_menuconfig_default_filename=".config"
SP7xxx_dir=${home_dir}/SP7021
SP7xxx_linux_kernel_dir=${SP7xxx_dir}/linux/kernel
home_lttp3rootfs_dir=${home_dir}/LTPP3_ROOTFS
home_lttp3rootfs_kernel_dir=${home_lttp3rootfs_dir}/kernel
home_lttp3rootfs_kernel_makeconfig_dir=${home_lttp3rootfs_kernel_dir}/makeconfig
src_make_menuconfig_fpath=${home_lttp3rootfs_kernel_makeconfig_dir}/${make_menuconfig_filename}
dst_make_menuconfig_fpath=${SP7xxx_linux_kernel_dir}/${make_menuconfig_default_filename}
cp ${src_make_menuconfig_fpath} ${dst_make_menuconfig_fpath}

press_any_key__func
echo -e "\r"
echo "---Executing: <make config <<< 2>---"
echo -e "\r"
make config <<< 2 1		#Select: [2] LTPP3G2 Board

press_any_key__func
echo -e "\r"
echo "---Executing: <make all>---"
echo -e "\r"
make all
