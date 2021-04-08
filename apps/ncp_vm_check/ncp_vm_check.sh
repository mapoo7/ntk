#!/bin/bash

#################################################################################
# env configuration
#################################################################################
export LC_ALL=C
export LANG=C
export PATH=$PATH:/sbin:/bin:/usr/local/sbin:/usr/local/bin

HOSTNAME=$(/bin/hostname)

OS_STR=$(/bin/uname -o | /bin/sed 's,GNU/,,g');
DATE_STR=$(/bin/date +%Y%m%d)
DATE_START=$(/bin/date '+%Y-%m-%d %X');
DATE_FINISH=$(/bin/date '+%Y-%m-%d %X');

if [ $(/bin/cat /etc/*release | grep -i "CentOS" | wc -l) -ge 1 ]
then
    if [ -z "${OSVERR}" ]; then
        osver=$(/bin/grep -Po '(?<=release )\d+\.\d+' /etc/redhat-release)
        [[ $osver =~ ^[0-9]{1,2}\.[0-9]{1,2}$ ]] || osver="0.0"
    fi
    osmajor=${osver%%.*}
    osrel="CentOS"
elif [ $(/bin/cat /etc/*release | grep -i "rhel" | wc -l) -ge 1 ]
then
    if [ -z "${OSVERR}" ]; then
        osver=$(/bin/grep -Po '(?<=release )\d+\.\d+' /etc/redhat-release)
        [[ $osver =~ ^[0-9]{1,2}\.[0-9]{1,2}$ ]] || osver="0.0"
    fi
    osmajor=${osver%%.*}
    osrel="RHEL"
elif [ $(/bin/cat /etc/*release | grep -i "Ubuntu" | wc -l) -ge 1 ]
then
    osrel="Ubuntu"
    osmajor=$(/bin/cat /etc/lsb-release | grep "DISTRIB_RELEASE" | cut -d '=' -f2 | cut -d '.' -f1)
else
    osrel="Other"
fi

if [ -z $NTK ]; then
    RESFILE=$HOSTNAME"_"$OS_STR"_"$DATE_STR".txt"
else
    RESFILE=$NTK/logs/ncp_vm_check/$HOSTNAME"_"$OS_STR"_"$DATE_STR".txt"
    if [ ! -d $NTK/logs/ncp_vm_check ]; then
        mkdir -p $NTK/logs/ncp_vm_check
    fi
fi

if [ -f $NTK/logs/ncp_vm_check/$HOSTNAME"_"$OS_STR"_"$DATE_STR".txt" ]; then
    LAST_TIME=$(cat $NTK/logs/ncp_vm_check/$HOSTNAME"_"$OS_STR"_"$DATE_STR".txt" | grep 'Starting Check System' -A 1 | tail -n1 | sed 's/\ /_/g')
    mv $NTK/logs/ncp_vm_check/$HOSTNAME"_"$OS_STR"_"$DATE_STR".txt" $NTK/logs/ncp_vm_check/$HOSTNAME"_"$OS_STR"_"$LAST_TIME".txt"
fi

R_SVR="false"
NFS_SVR="false"

echo "***************************************************************************"                              >   $RESFILE 2>&1
echo "*                                                                         *"                              >>  $RESFILE 2>&1
echo "*            NCP Linux VM Configuration Check                             *"                              >>  $RESFILE 2>&1
echo "*            Version : 0.6                                                *"                              >>  $RESFILE 2>&1
echo "*            Copyright : NBP                                              *"                              >>  $RESFILE 2>&1
echo "*                                                                         *"                              >>  $RESFILE 2>&1
echo "***************************************************************************"                              >>  $RESFILE 2>&1
echo ""                                                                                                         >>  $RESFILE 2>&1
echo ""
echo ""
echo "################# NCP Linux VM Configuration Check ##################"
echo ""
echo ""


#################################################################################
# Check DATE
#################################################################################
echo "===== Starting Check System ... ===== " >> $RESFILE 2>&1
echo "$DATE_START" >> $RESFILE 2>&1
echo "" >> $RESFILE 2>&1


#################################################################################
# host name Check
#################################################################################
echo "<< hostname >>" >> $RESFILE 2>&1
echo "$HOSTNAME" >> $RESFILE 2>&1
echo "" >> $RESFILE 2>&1


#################################################################################
# Linux Version Check
#################################################################################
echo "<< Linux Version >>" >> $RESFILE 2>&1
if [ -f /etc/lsb-release ]
then
    relinfo=$(/usr/bin/lsb_release -d | cut -f2 -d":" | sed 's,^\s,,g' 2>&1)
    if [ $(echo $relinfo | grep -ci Ubuntu) -ge 1 ]
    then
       echo $relinfo >> $RESFILE 2>&1
    else
       echo $relinfo >> $RESFILE 2>&1
    fi
    echo "" >> $RESFILE 2>&1
else
    /bin/cat /etc/redhat-* >> $RESFILE 2>&1
    echo "" >> $RESFILE 2>&1
fi
echo "<< Kernel Version >>" >> $RESFILE 2>&1
/bin/uname -r >> $RESFILE 2>&1
echo "" >> $RESFILE 2>&1


#################################################################################
# /etc/hosts, Memory Check
#################################################################################
echo "<< Hosts File Check >>" >> $RESFILE 2>&1
/bin/cat /etc/hosts >> $RESFILE 2>&1
echo "" >> $RESFILE 2>&1

echo "<< Memory Check >>" >> $RESFILE 2>&1
free -g >> $RESFILE 2>&1
echo "" >> $RESFILE 2>&1

################################################################################
# 
# ----- CONTENTS -----
# 
################################################################################
# A. OS Default Configuration Check
################################################################################
# B. Security Check
################################################################################
# C. -
################################################################################



################################################################################
#####################  A. OS Default Configuration Check #######################
################################################################################


echo "" >> $RESFILE 2>&1
echo "***************************************************************************"                              >>  $RESFILE 2>&1
echo "*                                                                         *"                              >>  $RESFILE 2>&1
echo "*         A. OS Default Configuration Check                               *"                              >>  $RESFILE 2>&1
echo "*                                                                         *"                              >>  $RESFILE 2>&1
echo "***************************************************************************"                              >>  $RESFILE 2>&1
echo "" >> $RESFILE 2>&1

################################################################################
# A1. Default Account Check
#################################################################################

echo "A1. Account Check" >> $RESFILE 2>&1

chkcmd="grep ^root: /etc/passwd /etc/shadow /etc/group"
chkvar=$($chkcmd | wc -l)

echo " A1-1) [CMD] $chkcmd" >> $RESFILE 2>&1
echo "$($chkcmd)" >> $RESFILE 2>&1

if [ $chkvar -eq 3 ]
        then
                echo " A1-1) [OK] root is OK" >> $RESFILE 2>&1
        else
                echo " A1-1) [NOK] root is NOT OK" >> $RESFILE 2>&1
fi

chkcmd="grep ^ncloud: /etc/passwd /etc/shadow /etc/group"
chkvar=$($chkcmd | wc -l)

echo " A1-2) [CMD] $chkcmd" >> $RESFILE 2>&1
echo "$($chkcmd)" >> $RESFILE 2>&1

if [ $chkvar -eq 3 ]
        then
                echo " A1-2) [OK] ncloud is OK" >> $RESFILE 2>&1
        else
                echo " A1-2) [NOK] ncloud is NOT OK **(Only Gov)**" >> $RESFILE 2>&1
fi

chkcmd="grep ^nbpmon: /etc/passwd /etc/shadow /etc/group"
chkvar=$($chkcmd | wc -l)

echo " A1-3) [CMD] $chkcmd" >> $RESFILE 2>&1
echo "$($chkcmd)" >> $RESFILE 2>&1

if [ $chkvar -eq 3 ]
        then
                echo " A1-3) [OK] nbpmon is OK" >> $RESFILE 2>&1
        else
                echo " A1-3) [NOK] nbpmon is NOT OK" >> $RESFILE 2>&1
fi

echo "" >> $RESFILE 2>&1


################################################################################
# A2. NCP Setup Script Check
#################################################################################


echo "" >> $RESFILE 2>&1
echo "A2. NCP Setup Script Check (ncloud_auto, nsight_updater - rc.local)" >> $RESFILE 2>&1

chkcmd="/usr/local/etc/ncloud_auto.sh"
if [ -x "$chkcmd" ]
        then
                echo " A2-1) [OK] ncloud_auto.sh file exist" >> $RESFILE 2>&1
        else
                echo " A2-1) [NOK] ncloud_auto.sh file does NOT exist.. Please Check" >> $RESFILE 2>&1
fi


echo " A2-2) [CMD] egrep -i 'nsight_updater|ncloud_auto' /etc/rc.local" >> $RESFILE 2>&1
echo "$(egrep -i 'nsight_updater|ncloud_auto' /etc/rc.local)" >> $RESFILE 2>&1

if [ $(cat /etc/rc.local | egrep -ic 'nsight_updater|ncloud_auto') -eq 2 ];then
        echo " A2-2) [OK] nsight_updater, ncloud_auto exist in /etc/rc.local" >> $RESFILE 2>&1
else
        echo " A2-2) [NOK] nsight_updater, ncloud_auto Not exist in /etc/rc.local... Please Check" >> $RESFILE 2>&1
fi

if [ ! -f /etc/rc.d/rc.local ]; then
        echo " A2-3) [CMD] /bin/ls -ld /etc/rc.local" >> $RESFILE 2>&1
        /bin/ls -ld /etc/rc.local >> $RESFILE 2>&1
        chkvar=$(/bin/ls -ld /etc/rc.local | awk '{print $1}')

        if [ "$chkvar" == "-rwxr-xr-x" ]; then
                if [ "$osmajor" -ge 16 ]; then
                        chkcmd2=$(systemctl list-unit-files | grep rc.local | grep static | wc -l)
                        if [ $chkcmd2 -ge 1 ]; then
                                echo "$(systemctl list-unit-files | grep rc.local | grep static)" >> $RESFILE 2>&1
                                echo " A2-3) [OK] /etc/rc_local and permission(-rwxr-xr-x) is OK" >> $RESFILE 2>&1
                        else
                                echo "$(systemctl list-unit-files | grep rc.local | grep static)" >> $RESFILE 2>&1
                                echo " A2-3) [NOK] /etc/rc_local or permission(-rwxr-xr-x) is Not OK.. Please Check" >> $RESFILE 2>&1
                        fi
                else
                        echo " A2-3) [OK] /etc/rc_local and permission(-rwxr-xr-x) is OK" >> $RESFILE 2>&1
                fi
        else
                echo " A2-3) [NOK] /etc/rc_local or permission(-rwxr-xr-x) is Not OK.. Please Check" >> $RESFILE 2>&1
        fi

else
        echo " A2-3) [CMD] /bin/ls -ld /etc/rc.d/rc.local" >> $RESFILE 2>&1
        /bin/ls -ld /etc/rc.d/rc.local >> $RESFILE 2>&1
        chkvar=$(/bin/ls -ld /etc/rc.d/rc.local | awk '{print $1}')

        if [ "$chkvar" == "-rwxr-xr-x." ]; then
                if [ "$osmajor" -ge 7 ]; then
                        chkcmd2=$(systemctl list-unit-files | grep rc.local | grep static | wc -l)
                        if [ $chkcmd2 -ge 1 ]; then
                                echo "$(systemctl list-unit-files | grep rc.local | grep static)" >> $RESFILE 2>&1
                                echo " A2-3) [OK] /etc/rc.d/rc_local and permission(-rwxr-xr-x.) is OK" >> $RESFILE 2>&1
                        else
                                echo "$(systemctl list-unit-files | grep rc.local | grep static)" >> $RESFILE 2>&1
                                echo " A2-3) [NOK] /etc/rc.d/rc_local or permission(-rwxr-xr-x.) is Nok OK.. Please Check" >> $RESFILE 2>&1
                        fi
                else
                        echo " A2-3) [OK] /etc/rc.d/rc_local and permission(-rwxr-xr-x.) is OK" >> $RESFILE 2>&1
                fi
        else
                echo " A2-3) [NOK] /etc/rc.d/rc_local or permission(-rwxr-xr-x.) is Not OK.. Please Check" >> $RESFILE 2>&1
        fi

fi

echo "" >> $RESFILE 2>&1

################################################################################
# A3. Essential Process Check
#################################################################################

echo "" >> $RESFILE 2>&1
echo "A3. Essential Process Check (nsight, nsight_updater, xentools - installation/auto start status)" >> $RESFILE 2>&1

chkcmd=$(/bin/ls -al /home1/nbpmon/noms/nsight/bin/ | egrep -i 'agent_info.domain|locator.domain|noms_nsight' | wc -l)
echo " A3-1) [CMD] /bin/ls -al /home1/nbpmon/noms/nsight/bin/ | egrep -i 'agent_info.domain|locator.domain|noms_nsight'" >> $RESFILE 2>&1
/bin/ls -al /home1/nbpmon/noms/nsight/bin/ | egrep -i 'agent_info.domain|locator.domain|noms_nsight' >> $RESFILE 2>&1
if [ "$chkcmd" -eq 3 ]; then
        echo " A3-1) [OK] nsight agent is exist" >> $RESFILE 2>&1
else
        echo " A3-1) [NOK] nsight agent is Not exist.. Please Check" >> $RESFILE 2>&1
fi

echo " A3-2) [CMD] /bin/ls -ld /usr/sbin/nsight_updater" >> $RESFILE 2>&1
/bin/ls -ld /usr/sbin/nsight_updater >> $RESFILE 2>&1

chkvar=$(/bin/ls -ld /usr/sbin/nsight_updater | awk '{print $1}')
if [[ $chkvar == "-rwxr-xr-x" ]]; then
        echo " A3-2) [OK] nsight_updater exist and permission(-rwxr-xr-x) is OK" >> $RESFILE 2>&1
else
        echo " A3-2) [NOK] nsight_updater Nok exist or permission(-rwxr-xr-x) is Not OK... Please Check" >> $RESFILE 2>&1
fi


if [[ "$osrel" == "Ubuntu" ]]; then
        echo " A3-3) [CMD] /bin/ls -al /etc/rc5.d/ | egrep -i 'noms_nsight'" >> $RESFILE 2>&1
        /bin/ls -al /etc/rc5.d/ | egrep -i 'noms_nsight' >> $RESFILE 2>&1
        if [ $(/bin/ls -al /etc/rc5.d/ | egrep -i 'noms_nsight' | wc -l) -eq "1" ];then
                echo " A3-3) [OK] nsight process auto start is OK" >> $RESFILE 2>&1
        else
                echo " A3-3) [NOK] nsight process auto start is Not OK.. Please check" >> $RESFILE 2>&1
        fi

        echo " A3-4) [CMD] dpkg --list xe-guest-*" >> $RESFILE 2>&1
        echo "------------------------------" >> $RESFILE 2>&1
        dpkg --list xe-guest-* >> $RESFILE 2>&1
        echo "------------------------------" >> $RESFILE 2>&1
        chkvar=$(dpkg --list xe-guest-* | grep xe-guest | wc -l)
        if [ "$chkvar" -ge 1 ]; then
                echo " A3-4) [OK] xe-guest-utilites installation status is OK" >> $RESFILE 2>&1
        else
                echo " A3-4) [NOK] xe-guest-utilites installation status is Not OK... Please Check" >> $RESFILE 2>&1
        fi

        echo " A3-5) [CMD] /bin/ls -al /etc/rc5.d/ | egrep -i 'xe-linux-distribution'" >> $RESFILE 2>&1
        /bin/ls -al /etc/rc5.d/ | egrep -i 'xe-linux-distribution' >> $RESFILE 2>&1
        if [ $(/bin/ls -al /etc/rc5.d/ | egrep -i 'xe-linux-distribution' | wc -l) -eq "1" ];then
                echo " A3-5) [OK] xentools auto start is OK" >> $RESFILE 2>&1
        else
                echo " A3-5) [NOK] xentools auto start is Not OK.. Please check" >> $RESFILE 2>&1
        fi

else
        nsight_ess=$(chkconfig --list 2>/dev/null | egrep 'noms_nsight' | awk '{print $4" "$5" "$6" "$7}' | sed 's/ /\n/g' | grep -c on)
        xe_ess=$(chkconfig --list 2>/dev/null | egrep '^xe' | awk '{print $4" "$5" "$6" "$7}' | sed 's/ /\n/g' | grep -c on)

        echo " A3-3) [CMD] chkconfig --list 2>/dev/null | egrep 'noms_nsight'" >> $RESFILE 2>&1
        echo "$(chkconfig --list 2>/dev/null | egrep 'noms_nsight')" >> $RESFILE 2>&1
        if [ $(echo $nsight_ess) -eq "4" ];then
                echo " A3-3) [OK] nsight process auto start is OK" >> $RESFILE 2>&1
        else
                echo " A3-3) [NOK] nsight process auto start is Not OK.. Please check" >> $RESFILE 2>&1
        fi

        echo " A3-4) [CMD] rpm -qa xe-guest-*" >> $RESFILE 2>&1
        echo "------------------------------" >> $RESFILE 2>&1
        rpm -qa xe-guest-* >> $RESFILE 2>&1
        echo "------------------------------" >> $RESFILE 2>&1
        chkvar=$(rpm -qa xe-guest-* | wc -l)
        if [ "$chkvar" -ge 1 ]; then
                echo " A3-4) [OK] xe-guest-utilites is OK" >> $RESFILE 2>&1
        else
                echo " A3-4) [NOK] xe-guest-utilites is Not OK... Please Check" >> $RESFILE 2>&1
        fi

        echo " A3-5) [CMD] chkconfig --list 2>/dev/null | egrep 'xe-linux-distribution'" >> $RESFILE 2>&1
        echo "$(chkconfig --list 2>/dev/null | egrep 'xe-linux-distribution')" >> $RESFILE 2>&1
        if [ $(echo $xe_ess) -eq "4" ];then
                echo " A3-5) [OK] xentools auto start is OK" >> $RESFILE 2>&1
        else
                echo " A3-5) [NOK] xentools auto start is Not OK.. Please check" >> $RESFILE 2>&1
        fi
fi

echo "" >> $RESFILE 2>&1


################################################################################
# A4. Root File System Check
#################################################################################

echo "" >> $RESFILE 2>&1
echo "A4. Root File System Check (/ iNode, Usage, rootfs touch)" >> $RESFILE 2>&1

df_i=$(df -ih / | grep ^/dev | awk '{print $5}' | sed 's/%//g')
df_h=$(df -Th / | grep ^/dev | awk '{print $6}' | sed 's/%//g')

if ([ $(echo $df_i) -gt 90 ] || [ $(echo $df_h) -gt 90 ]);then
        echo " A4-1-1) [NOK] rootfs is Not OK.. (90%) Please Check" >> $RESFILE 2>&1
        echo " A4-1-2) [INFO] iNode Usage : $(echo $df_i)%" >> $RESFILE 2>&1
        echo " A4-1-3) [INFO] FS Usage : $(echo $df_h)%" >> $RESFILE 2>&1
else
        echo " A4-1-1) [OK] rootfs is OK" >> $RESFILE 2>&1
        echo " A4-1-2) [INFO] iNode Usage : $(echo $df_i)%" >> $RESFILE 2>&1
        echo " A4-1-3) [INFO] FS Usage : $(echo $df_h)%" >> $RESFILE 2>&1
fi

if [[ "$osrel" == "Ubuntu" ]]
then
    echo " - Checking /tmp writable(-w)" >> $RESFILE 2>&1
    if [ -w "/tmp" ]
    then
        chkvar="rw"
    else
        chkvar="ro"
    fi
else
	echo " A4-2) [CMD]/bin/grep rootfs /proc/mounts" >> $RESFILE 2>&1
	/bin/grep rootfs /proc/mounts | /bin/grep "[[:space:]]rw[[:space:],]" >> $RESFILE 2>&1
	chkvar=$(/bin/grep rootfs /proc/mounts | /bin/grep "[[:space:]]rw[[:space:],]" | awk '{print $4}')
fi

if [[ "$chkvar" == "rw" ]]
then
    echo " A4-2) [OK] rootfs can write(/tmp)" >> $RESFILE 2>&1
    chkro=$(/bin/touch /tmp/rotest-temps)
    if [[ -f /tmp/rotest-temps ]]
    then
        echo " A4-3) [OK] rootfs can touch and delete(/tmp/rotest-temps)" >> $RESFILE 2>&1
        rm -f /tmp/rotest-temps
    else
        echo " A4-3) [NOK] rootfs can't touch and delete(/tmp/rotest-temps)" >> $RESFILE 2>&1
    fi
else
    echo " A4-2) [NOK] rootfs can't write(/tmp)" >> $RESFILE 2>&1
fi

echo "" >> $RESFILE 2>&1


################################################################################
# A5. Checking /etc/fstab and UUID
################################################################################
echo "" >> $RESFILE 2>&1
echo "A5. Checking /etc/fstab and UUID" >> $RESFILE 2>&1
echo " A5-1) [CMD] /sbin/blkid" >> $RESFILE 2>&1
/sbin/blkid >> $RESFILE 2>&1
if [ -f /etc/fstab ]
then
    echo " A5-1) [OK] /etc/fstab file exist" >> $RESFILE 2>&1
    echo " A5-2) [CMD] /bin/cat /etc/fstab" >> $RESFILE 2>&1
    #echo " A5-2) [CMD] /bin/cat /etc/fstab | grep -v -e '^$' -e '^#\ ' -e '^#$'" >> $RESFILE 2>&1
    echo "------------------------------" >> $RESFILE 2>&1
    /bin/cat /etc/fstab >> $RESFILE 2>&1
    echo "------------------------------" >> $RESFILE 2>&1
    #for chkvar in $(/sbin/blkid | /usr/bin/perl -pe 's,.+ UUID="(.+)" .+,$1,g');
    cntnumber=1
    subnumber=3
    len=$(/sbin/blkid | grep UUID | cut -d '=' -f 2 | awk '{print $1}' | sed 's/"//g' | wc -l)
    for chkvar in $(/sbin/blkid | grep UUID | cut -d '=' -f 2 | awk '{print $1}' | sed 's/"//g');
    do
        echo " A5-$subnumber) [CMD] /bin/grep $chkvar /etc/fstab" >> $RESFILE 2>&1
        /bin/grep $chkvar /etc/fstab >> $RESFILE 2>&1
        echo " - Checking fstab UUID ($cntnumber/$len)" >> $RESFILE 2>&1
        chkcnt=$(/bin/grep $chkvar /etc/fstab | wc -l)
        if [ "$chkcnt" -eq 1 ]
        then
            echo " A5-$subnumber-1) [OK] $chkvar : File System UUID exist in /etc/fstab" >> $RESFILE 2>&1

            echo " - Checking Backup Operation(5th field)" >> $RESFILE 2>&1
            chkvardtl=($(/bin/grep $chkvar /etc/fstab | awk '{print $5,$6}'))
            if [[ "${chkvardtl[0]}" -eq 0 || "${chkvardtl[0]}" -eq 1 ]]
            then
                echo " A5-$subnumber-2) [OK] $chkvar : Backup Operation is ok(${chkvardtl[0]})" >> $RESFILE 2>&1
            else
                echo " A5-$subnumber-2) [NOK] $chkvar : Backup Operation is not good(${chkvardtl[0]})" >> $RESFILE 2>&1
            fi

            echo " - Checking File system check order(6th field)" >> $RESFILE 2>&1
            if [[ "${chkvardtl[1]}" -eq 0 || "${chkvardtl[1]}" -eq 1 ]]
            then
                echo " A5-$subnumber-3) [OK] $chkvar : File system check order is ok(${chkvardtl[1]})" >> $RESFILE 2>&1
            else
                echo " A5-$subnumber-3) [NOK] $chkvar : File system check order is not good(${chkvardtl[1]})" >> $RESFILE 2>&1
            fi
        else
                echo " A5-$subnumber) [NOK] $chkvar : File System UUID doesn't exist in /etc/fstab" >> $RESFILE 2>&1
        fi
        cntnumber=$((cntnumber+1))
        subnumber=$((subnumber+1))
        echo "" >> $RESFILE 2>&1
    done
else
    echo " A5-1) [NOK] /etc/fstab file does not exist" >> $RESFILE 2>&1
fi

echo "" >> $RESFILE 2>&1


#exit

################################################################################
# A6. Checking /etc/passwd, /etc/shadow, /etc/group
################################################################################
echo "" >> $RESFILE 2>&1
echo "A6. Checking /etc/passwd, /etc/shadow, /etc/group files" >> $RESFILE 2>&1
chkfile="/etc/passwd /etc/shadow /etc/group"
cntnumber=1
subnumber=1
for chkvar in $chkfile;
do
    echo " A6-1-$subnumber) [CMD] /bin/ls -ld $chkvar" >> $RESFILE 2>&1    
    /bin/ls -ld $chkvar  >> $RESFILE 2>&1
    if [ -f $chkvar ]
    then
        echo " A6-1-$subnumber) [OK]  $chkvar file exist" >> $RESFILE 2>&1
    else
        echo " A6-1-$subnumber) [NOK] $chkvar file does not exist" >> $RESFILE 2>&1
    fi 
    subnumber=$((subnumber+1))
done
echo "" >> $RESFILE 2>&1

################################################################################
# A7. Checking Network Configuration
################################################################################
echo "" >> $RESFILE 2>&1
echo "A7. Checking Network Configuration" >> $RESFILE 2>&1
if [[ "$osrel" == "Ubuntu" ]]
then
    ncfile="/etc/networks"    
else
    ncfile="/etc/sysconfig/network"
fi
if [ -f $ncfile ] 
then
    echo " A7-1) [OK] $ncfile file exist" >> $RESFILE 2>&1
    echo " A7-1) [CMD] /bin/cat $ncfile" >> $RESFILE 2>&1 
    echo "------------------------------" >> $RESFILE 2>&1
    /bin/cat $ncfile >> $RESFILE 2>&1
    echo "------------------------------" >> $RESFILE 2>&1
else
    echo " A7-1) [NOK] $ncfile file does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# A8. Checking Network dhcp
################################################################################
echo "" >> $RESFILE 2>&1
echo "A8. Checking Network DHCP" >> $RESFILE 2>&1
mainnumber=2
subnumber=1
if [[ "$osrel" == "Ubuntu" ]]
then
    chkfile="/etc/network/interfaces"
    echo " A8-1) [CMD] ls -ld $chkfile" >> $RESFILE 2>&1
    echo " A8-$mainnumber-$subnumber) [CMD] /bin/cat $chkfile" >> $RESFILE 2>&1
    echo "------------------------------" >> $RESFILE 2>&1
    cat $chkfile >> $RESFILE 2>&1
    echo "------------------------------" >> $RESFILE 2>&1
    nicarr=($(/bin/grep -i "^iface" $chkfile | /bin/grep -v " lo " | awk '{print $2":"$4}'))
    for nic in "${nicarr[@]}";
    do
        echo "NIC Config : $nic" >> $RESFILE 2>&1
        chkarr=($(echo $nic | /bin/sed 's,:,\n,g'))
        if [ ! -z "${chkarr[1]}" ]
        then
            if [[ "${chkarr[1]}" == "dhcp" ]]
            then
                echo " A8-$mainnumber-$subnumber) [OK] ${chkarr[0]} is configured by ${chkarr[1]}" >> $RESFILE 2>&1
            else
                echo " A8-$mainnumber-$subnumber) [NOK] ${chkarr[0]} is configured by ${chkarr[1]}" >> $RESFILE 2>&1
            fi
        else
            echo " A8-$mainnumber-$subnumber) [NOK] BOOTPROTO entry does not exist in ${chkarr[0]}" >> $RESFILE 2>&1
        fi
        subnumber=$((subnumber+1))
    done
else
    echo " A8-1) [CMD] ls -ld /etc/sysconfig/network-scripts/ifcfg-eth*" >> $RESFILE 2>&1
    ls -d /etc/sysconfig/network-scripts/ifcfg-eth* >> $RESFILE 2>&1
    echo "" >> $RESFILE 2>&1
    nicarr=($(/bin/ls -d /etc/sysconfig/network-scripts/ifcfg-eth* 2>&1))
    for nic in "${nicarr[@]}";
    do
        echo " A8-$mainnumber-$subnumber) [CMD] /bin/cat $nic" >> $RESFILE 2>&1
        echo "------------------------------" >> $RESFILE 2>&1
        /bin/cat $nic >> $RESFILE 2>&1
        echo "------------------------------" >> $RESFILE 2>&1
        chkvar=$(/bin/grep -i BOOTPROTO $nic | cut -f2 -d"=")
        if [ ! -z "$chkvar" ]
        then
            if [[ "$chkvar" == "dhcp" ]]
            then
                echo " A8-$mainnumber-$subnumber) [OK] $nic is configured by $chkvar" >> $RESFILE 2>&1
            else
                echo " A8-$mainnumber-$subnumber) [NOK] $nic is configured by $chkvar" >> $RESFILE 2>&1
            fi
        else
            echo " A8-$mainnumber-$subnumber) [NOK] BOOTPROTO entry does not exist in $nic" >> $RESFILE 2>&1
        fi
        subnumber=$((subnumber+1))
    done
fi
echo "" >> $RESFILE 2>&1

################################################################################
# A9. Checking grub configuration
################################################################################
echo "" >> $RESFILE 2>&1
echo "A9. Checking GRUB Location and Configuration" >> $RESFILE 2>&1
if [[ "$osrel" == "Ubuntu" ]]
then
    echo " A9-1) [CMD] /bin/ls -ld /boot/grub/grub*.cfg" >> $RESFILE 2>&1
    /bin/ls -ld /boot/grub/grub*.cfg >> $RESFILE 2>&1
    grubfile=$(/bin/ls -ld /boot/grub/grub*.cfg | awk '{print $9}')
    if [ -f $grubfile ]
    then
        #if [ -f /usr/bin/grub2-script-check ]
        if [ -x /usr/bin/grub2-script-check ]
        then
            grubscriptcheck="/usr/bin/grub2-script-check"
        else
            grubscriptcheck="/usr/bin/grub-script-check"
        fi
        echo "$grubscriptcheck $grubfile" >> $RESFILE 2>&1
        $grubscriptcheck $grubfile; exitcode=$?
        if [ "$exitcode" -eq 0 ]
        then
            echo " A9-1) [OK] $grubfile config check passed(ok)" >> $RESFILE 2>&1 
        else
            echo " A9-1) [NOK] $grubfile config check not passed(nok)" >> $RESFILE 2>&1
        fi
    else
        echo " A9-1) [NOK] $grubfile file does not exist" >> $RESFILE 2>&1
    fi
else
    echo " A9-1) [CMD] /bin/ls -ld /etc/grub*" >> $RESFILE 2>&1
    /bin/ls -ld /etc/grub* >> $RESFILE 2>&1
    if [ "$osmajor" -ge 7 ]
    then
        [ -d /sys/firmware/efi ] && grubfile=$(/bin/ls -ld /etc/grub2-efi.cfg | cut -f2 -d">" | /bin/sed 's, \.\.,,g') || \
        grubfile=$(/bin/ls -ld /etc/grub2.cfg | cut -f2 -d">" | /bin/sed 's, \.\.,,g')
    else
        grubfile=$(/bin/ls -ld /etc/grub.conf | cut -f2 -d">" | /bin/sed 's, \.\.,,g')
    fi
    if [ -f $grubfile ]
    then
        if [ -x /usr/bin/grub2-script-check ]
        then
            echo " A9-2) [CMD] /usr/bin/grub2-script-check $grubfile" >> $RESFILE 2>&1
            /usr/bin/grub2-script-check $grubfile; exitcode=$?
            if [ "$exitcode" -eq 0 ]
            then
                echo " A9-2) [OK] $grubfile config check passed(ok)" >> $RESFILE 2>&1 
            else
                echo " A9-2) [NOK] $grubfile config check not passed(nok)" >> $RESFILE 2>&1
            fi
        else
            echo " A9-1) [OK] $grubfile file exist" >> $RESFILE 2>&1
            echo " A9-2) [CMD] /bin/cat $grubfile" >> $RESFILE 2>&1
            echo "------------------------------" >> $RESFILE 2>&1
            /bin/cat $grubfile >> $RESFILE 2>&1
            echo "------------------------------" >> $RESFILE 2>&1
        fi
    else
        echo " A9-1) [NOK] $grubfile file does not exist" >> $RESFILE 2>&1
    fi
fi
echo "" >> $RESFILE 2>&1

################################################################################
# A10. Listing KERNEL Image
################################################################################
echo "" >> $RESFILE 2>&1
echo "A10. Listing kernel images" >> $RESFILE 2>&1
kimgdir="/boot"
if [ -d $kimgdir ]
then
    echo " A10-1) [OK] $kimgdir folder exist" >> $RESFILE 2>&1
    echo " A10-2) [CMD] /bin/ls -ld /boot/*" >> $RESFILE 2>&1
    echo "------------------------------" >> $RESFILE 2>&1
    /bin/ls -ld /boot/* >> $RESFILE 2>&1
    echo "------------------------------" >> $RESFILE 2>&1
else
    echo " A10-1) [NOK] $kimgdir folder does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# A11. Checking Package Repository 
################################################################################
echo "" >> $RESFILE 2>&1
echo "A11. Checking Package Repository" >> $RESFILE 2>&1
if [[ "$osrel" == "Ubuntu" ]]
then
    repodir="/etc/apt"
    repofile="$repodir/sources.list"
else
    repodir="/etc/yum.repos.d"
    repofile="$repodir/CentOS-Base.repo"
fi

if [ -d $repodir ]
then
   echo " A11-1) [OK] $repodir folder exist" >> $RESFILE 2>&1
   if [ -f $repofile ]
   then
       echo " A11-2) [OK] $repofile file exist" >> $RESFILE 2>&1
       echo " A11-2) [CMD] /bin/cat $repofile" >> $RESFILE 2>&1
       echo "------------------------------" >> $RESFILE 2>&1
       /bin/cat $repofile >> $RESFILE 2>&1
       echo "------------------------------" >> $RESFILE 2>&1
   else
       echo " A11-2)[NOK] $repofile file does not exist" >> $RESFILE 2>&1
   fi
else 
    echo " A11-1) [NOK] $repodir folder does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# A12. Checking NetworkManager(CentOS 7)
################################################################################
echo "" >> $RESFILE 2>&1
echo "A12. Checking NetworkManager(CentOS 7)" >> $RESFILE 2>&1
if [ "$osrel" == "CentOS" -o "$osrel" == "RHEL" ]
then
    if [[ "$osmajor" -ge 7 ]]
    then
        echo " A12-1) [CMD] /usr/bin/systemctl list-unit-files | /bin/grep NetworkManager" >> $RESFILE 2>&1
        echo " A12-1) [OK] NetworkManager exist" >> $RESFILE 2>&1
        /usr/bin/systemctl status NetworkManager.service >> $RESFILE 2>&1
        if [[ $(/usr/bin/systemctl status NetworkManager.service | /bin/grep Active | awk '{print $2}' 2>&1) == "inactive" ]]
        then 
            echo " A12-2) [OK]  NetworkManager is inactive" >> $RESFILE 2>&1
        else
            echo " A12-2) [NOK] NetworkManager is active" >> $RESFILE 2>&1
        fi
    else
        echo " A12-1) [WARN] It is not CentOS 7 or above" >> $RESFILE 2>&1
    fi
else
    echo " A12-1) [WARN] It is not CentOS" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# A13. Checking /tmp Directory
################################################################################
echo "" >> $RESFILE 2>&1
echo "A13. Checking status of Temporary Directory" >> $RESFILE 2>&1
echo " A13-1) [CMD] /bin/ls -ld /tmp" >> $RESFILE 2>&1
/bin/ls -ld /tmp 2>&1 >> $RESFILE 2>&1
chkvar=$(/bin/ls -ld /tmp | awk '{print $1,$3,$4,$9}' 2>&1)
if [ -d "/tmp" ]
then
    echo " A13-1) [OK] /tmp exist." >> $RESFILE 2>&1
    arr=($(echo $chkvar | /bin/sed -e 's/\s/\n/g'))
    if [[ "${arr[0]}" == *drwxrwxrwt* ]]
    then 
        echo " A13-2) [OK] /tmp permission(${arr[0]}) is ok" >> $RESFILE 2>&1
    else
        echo " A13-2) [NOK] /tmp permission(${arr[0]}) is not ok" >> $RESFILE 2>&1
    fi
    if [[ "${arr[1]}" == "root" ]]
    then
        echo " A13-3) [OK] /tmp user(${arr[1]}) is ok" >> $RESFILE 2>&1
    else
        echo " A13-3) [NOK] /tmp user(${arr[1]}) is not ok" >> $RESFILE 2>&1
    fi
    if [[ "${arr[2]}" == "root" ]]
    then
        echo " A13-4) [OK] /tmp group(${arr[2]}) is ok" >> $RESFILE 2>&1
    else
        echo " A13-4) [NOK] /tmp group(${arr[2]}) is not ok" >> $RESFILE 2>&1
    fi
else
    echo " A13-1) [NOK] /tmp does not exist." >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1


################################################################################
#############################  B. Security Check  ##############################
################################################################################

echo "" >> $RESFILE 2>&1
echo "***************************************************************************"                              >>  $RESFILE 2>&1
echo "*                                                                         *"                              >>  $RESFILE 2>&1
echo "*            Security Check                                               *"                              >>  $RESFILE 2>&1
echo "*                                                                         *"                              >>  $RESFILE 2>&1
echo "***************************************************************************"                              >>  $RESFILE 2>&1
echo "" >> $RESFILE 2>&1
# echo "<< /usr/bin/chage check SUID/SGID >>" >> $RESFILE 2>&1
# chkper=$(/bin/ls -al /usr/bin/chage | awk '{print $1}')
# echo "$chkper" >> $RESFILE 2>&1
# chkvar=$(/bin/ls -al /usr/bin/chage | awk '{print $1}' | /bin/grep -Ei 's|g')
# if [[ -z "$chkvar" ]]
# then
#     echo "[OK]  /usr/bin/chage, SUID/SGID is ok($chkper)" >> $RESFILE 2>&1
# else
#     echo "[NOK] /usr/bin/chage, SUID/SGID is not ok($chkper)" >> $RESFILE 2>&1
# fi

################################################################################
# B1. Checking permission of important files
################################################################################

echo "B1. Checking permission of important files" >> $RESFILE 2>&1
chkflist="
/etc/passwd:644
/etc/shadow:400
/etc/group:644
/etc/gshadow:400
"
for chkfile in $chkflist;
do
    arr=($(echo $chkfile | sed -e 's/:/\n/g'))
    if [ -f ${arr[0]} ]
    then
        echo " [CMD] /bin/ls -al ${arr[0]}" >> $RESFILE 2>&1
        /bin/ls -al ${arr[0]} >> $RESFILE 2>&1
        chkvar=$(/bin/ls -al ${arr[0]} | awk '{print $1}')
        echo " [CHECK] ${arr[0]} permission(${arr[1]}) is $chkvar" >> $RESFILE 2>&1
    else
        echo " [NOK] ${arr[0]} file does not exist" >> $RESFILE 2>&1
    fi
done
echo "" >> $RESFILE 2>&1

################################################################################
# B2. Listing SUID/SGID stat of some files
################################################################################

echo "B2. Listing SUID/SGID stat of some files" >> $RESFILE 2>&1
chklist="
/usr/bin/chage
/usr/bin/gpasswd
/usr/bin/wall
/usr/bin/chfn
/usr/bin/chsh
/usr/bin/newgrp
/usr/bin/write
/usr/sbin/usernetctl
/bin/mount
/bin/umount
/sbin/netreport
"
for chkfile in $chklist;
do
    if [ -f $chkfile ]
    then
        echo " [CMD] /bin/ls -dlH $chkfile" >> $RESFILE 2>&1
        /bin/ls -dlH $chkfile >> $RESFILE 2>&1
        chkvar=$(/bin/ls -dlH $chkfile | awk '{print $1}')
        if [[ "$chkvar" == *s* || "$chkvar" == *g* || "$chkvar" == *t* ]]
        then
            echo " [CHECK] $chkfile permission is $chkvar" >> $RESFILE 2>&1
        else
            echo " [OK]  $chkfile permission is $chkvar(Good)" >> $RESFILE 2>&1
        fi
    else
        echo " [WARN] $chkfile file does not exist" >> $RESFILE 2>&1
    fi
done
echo "" >> $RESFILE 2>&1

################################################################################
# B3. Checking /etc/securetty
################################################################################

echo "B3. Checking /etc/securetty" >> $RESFILE 2>&1
chkfile="/etc/securetty"
echo " [CMD] ls -ld $chkfile" >> $RESFILE 2>&1
if [ -f $chkfile ]
then
    if [ "$osrel" != "Ubuntu" ]
    then
        echo " [CMD] /bin/cat $chkfile" >> $RESFILE 2>&1
        echo "------------------------------" >> $RESFILE 2>&1
        /bin/cat $chkfile >> $RESFILE 2>&1
        echo "------------------------------" >> $RESFILE 2>&1
    else
        echo " [WARN] Please, check $chkfile file manually on $osrel" >> $RESFILE 2>&1
    fi
else
    echo " [WARN] $chkfile file does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B4. Checking IDLE TIME for root user
################################################################################

echo "B4. Checking IDLE TIME for root user" >> $RESFILE 2>&1
chkfile="/etc/profile"
if [ -f $chkfile ]
then
    echo " [CMD] /bin/grep -i tmout $chkfile" >> $RESFILE 2>&1
    /bin/grep -i tmout $chkfile;exitcode=$?
    if [[ "$exitcode" -eq 0 ]]
    then 
        echo " [OK] TMOUT env exist in $chkfile" >> $RESFILE 2>&1
    else
        echo " [NOK] TMOUT env deos not exist in $chkfile" >> $RESFILE 2>&1
    fi
else
    echo " [WARN] $chkfile file does not exist" >> $RESFILE 2>&1
fi

echo "" >> $RESFILE 2>&1

################################################################################
# B5. Checking ssh port
################################################################################

echo "B5. Checking ssh port" >> $RESFILE 2>&1
if [[ "$osrel" == "Ubuntu" ]]
then
   chkfile="/usr/bin/lsof"
else
   chkfile="/usr/sbin/lsof"
fi
echo " [CMD] $chkfile -ni | /bin/grep LISTEN | /bin/grep -c ssh" >> $RESFILE 2>&1


if [ $($chkfile -ni | /bin/grep LISTEN | /bin/grep -c ssh) -ge 1 ]
then
    echo " [CHECK] ssh daemon is running" >> $RESFILE 2>&1
else
    echo " [CHECK] ssh daemon is not running" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B6. Checking UID : 0 user except root user
################################################################################

echo "B6. Checking UID : 0 user except root user" >> $RESFILE 2>&1
chkfile="/etc/passwd"
echo " [CMD] awk -F: '{print \$1\":\"\$3\":\"\$4}' /etc/passwd | grep -vw \"root\"" >> $RESFILE 2>&1
for chkvar in $(awk -F: '{print $1":"$3":"$4}' /etc/passwd | grep -vw "root");
do
    arr=($(echo $chkvar | sed -e 's/:/\n/g'))
    if [ "${arr[1]}" -eq 0 ]
    then
        echo " [NOK] ${arr[0]} user has UID(${arr[1]})" >> $RESFILE 2>&1
    else
        chkuval="ok"
    fi 
    if [ "${arr[2]}" -eq 0 ]
    then
        echo " [NOK] ${arr[0]} group has GID(${arr[2]})" >> $RESFILE 2>&1
    else
        chkgval="ok"
    fi 
    if [[ "$chkuval" == "ok" && "$chkgval" == "ok" ]] 
    then 
        echo " [OK] ${arr[0]} USER UID(${arr[1]}) and GID(${arr[2]}) doesn't have ID : 0(Good)" >> $RESFILE 2>&1
    fi
done
echo "" >> $RESFILE 2>&1

################################################################################
# B7. Checking unnecessary USER accounts
################################################################################

echo "B7. Checking unnecessary USER accounts" >> $RESFILE 2>&1
chkuser="
lp
sync
shutdown
halt
news
ghgh
operator
games
gopher
ftp
"
chkfile="/etc/passwd"
if [ -f $chkfile ]
then
    echo " [INFO] $chkfile exist" >> $RESFILE 2>&1
    for usr in $chkuser;
    do
        echo " [CMD] cat $chkfile | awk -F: '{print \$1}' | grep -wc $usr" >> $RESFILE 2>&1
        if [ $(cat $chkfile | awk -F: '{print $1}' | grep -wc $usr) -ge 1 ]
        then
            echo " [CHECK] $usr user is existing in $chkfile" >> $RESFILE 2>&1
        else
            echo " [OK] $usr user is not existing in $chkfile" >> $RESFILE 2>&1
        fi
    done
else
    echo " [WARN] $chkfile file does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B8. Checking unnecessary GROUP accounts
################################################################################

echo "B8. Checking unnecessary GROUP accounts" >> $RESFILE 2>&1
chkgroup="
adm
lp
news
uucp
games
dip
"
chkfile="/etc/group"
if [ -f $chkfile ]
then
    echo " [INFO] $chkfile exist" >> $RESFILE 2>&1
    for grp in $chkgroup;
    do
        echo "cat $chkfile | awk -F: '{print \$1}' | grep -wc $grp" >> $RESFILE 2>&1
        if [ $(cat $chkfile | awk -F: '{print $1}' | grep -wc $grp) -ge 1 ]
        then
            echo " [CHECK] $grp group is existing in $chkfile" >> $RESFILE 2>&1
        else
            echo " [OK] $grp group is not existing in $chkfile" >> $RESFILE 2>&1
        fi
    done
else
    echo " [WARN] $chkfile file does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B9. Checking rhosts
################################################################################

echo "B9. Checking rhosts(Passwordless Remote Login)" >> $RESFILE 2>&1
# nbpmon:x:1000:1000:agent-account:/home1/nbpmon:/bin/bash
chkfile="/etc/passwd"
if [ -f $chkfile ]
then
    echo " [INFO] $chkfile exist" >> $RESFILE 2>&1
    # cnt=0
    arr=$(cat $chkfile | grep -Ev "nologin$|false$|sync$" | awk -F: '{print $1":"$6":"$7}')
    for var in $arr;
    do
        chkarr=($(echo $var | sed 's/:/\n/g'))
        if [ -f "${chkarr[1]}/.rhosts" ]
        then
            echo " [CHECK] Please, check .rhosts file in ${chkarr[0]} user HOME(${chkarr[1]})" >> $RESFILE 2>&1
            # cnt=$((cnt+1))
        else
            echo " [OK] .rhosts file does not exist in ${chkarr[0]} USER HOME(${chkarr[1]})" >> $RESFILE 2>&1
        fi
    done
else
    echo " [WARN] $chkfile file does not exist" >> $RESFILE 2>&1
fi

chkfile="/etc/hosts.equiv"
if [ -f $chkfile ] 
then
    echo " [CHECK] Please, check $chkfile file in /etc/ directory" >> $RESFILE 2>&1
else
    echo " [OK] $chkfile file does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B10. Checking password rules
################################################################################

echo "B10. Checking password rules" >> $RESFILE 2>&1
chkfile="/etc/login.defs"
chkcat="
PASS_MAX_DAYS:120
PASS_MIN_DAYS:90
PASS_MIN_LEN:8
PASS_WARN_AGE:30
"
if [ -f $chkfile ]
then
    echo "[INFO] $chkfile exist" >> $RESFILE 2>&1
    for vars in $chkcat;
    do
        arr=($(echo $vars | sed 's/:/\n/g'))
        echo " [CMD] /bin/grep ^${arr[0]} $chkfile" >> $RESFILE 2>&1
        chkvar=$(/bin/grep -w ^${arr[0]} $chkfile | sed -e 's,\s, ,g' | cut -f2 -d' ')
        echo " [INFO] ${arr[0]} is ${arr[1]} -> $chkvar" >> $RESFILE 2>&1
    done        
else
    echo " [OK] $chkfile file does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B11. Checking blank password in /etc/shadow
################################################################################

echo "B11. Checking blank password in /etc/shadow" >> $RESFILE 2>&1
chkfile="/etc/shadow"
if [ -e $chkfile ]
then
    echo " [CMD] /bin/ls -dl $chkfile" >> $RESFILE 2>&1
    echo " [INFO]" >> $RESFILE 2>&1
    /bin/ls -ld $chkfile >> $RESFILE 2>&1
    chkvar=($(/bin/ls -cl $chkfile | awk '{print $1,$3,$4}'))
    echo " [INFO] $chkfile permission is ${chkvar[0]}" >> $RESFILE 2>&1
    echo " [INFO] $chkfile user is ${chkvar[1]} (default user : root)" >> $RESFILE 2>&1
    echo " [INFO] $chkfile group is ${chkvar[2]} (Ubuntu : shadow, CentOS : root)" >> $RESFILE 2>&1
    echo " [CMD] cat $chkfile | cut -f1,2 -d':'" >> $RESFILE 2>&1
    cnt=0
    chkvar=$(cat $chkfile | cut -f1,2 -d':')
    for vars in $chkvar;
    do
        arr=($(echo $vars | sed -e 's/:/\n/g'))
        if [ -z "${arr[1]}" ]
        then
            echo " [WARN] Password of ${arr[0]} user is blank" >> $RESFILE 2>&1
            cnt=$((cnt+1))
        fi
    done
    if [ "$cnt" -eq 0 ]
    then
        echo " [OK] Blank Password does not exist in $chkfile" >> $RESFILE 2>&1
    fi
else
    echo " [OK] $chkfile file does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B12. Checking Command History Size in /etc/profile
################################################################################

echo "B12. Checking Command History Size in /etc/profile" >> $RESFILE 2>&1
chkenv="
HISTSIZE:500
HISTFILESIZE:0
"
chkfile="/etc/profile"
if [ -e $chkfile ]
then
    echo " [INFO] $chkfile exist" >> $RESFILE 2>&1
    echo " [CMD] /bin/grep ^HISTSIZE $chkfile" >> $RESFILE 2>&1
    /bin/grep ^HISTSIZE $chkfile >> $RESFILE 2>&1
    chkvar=$(/bin/grep -E ^HISTSIZE $chkfile)
    if [ ! -z $chkvar ] 
    then
        for vars in $chkvar;
        do
            #echo "$vars --->" >> $RESFILE 2>&1
            arr=($(echo $vars | sed -e 's/=/\n/g'))
            if [ -z "${arr[0]}" ]
                echo " [WARN] HISTSIZE env does not exist in $chkfile" >> $RESFILE 2>&1
            then
                echo " [CHECK] ${arr[0]} env is ${arr[1]} in $chkfile" >> $RESFILE 2>&1
            fi
        done
    else
        echo " [CHECK] HISTSIZE env does not exist in $chkfile" >> $RESFILE 2>&1
    fi 
else
    echo " [OK] $chkfile file does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B13. Checking /etc/issue
################################################################################

echo "B13. Checking /etc/issue" >> $RESFILE 2>&1
chkfile="/etc/issue"
echo " [CMD] /bin/ls -ld /etc/issue*" >> $RESFILE 2>&1
/bin/ls -ld /etc/issue* >> $RESFILE 2>&1
chkvar=$(/bin/ls -ld /etc/issue* | wc -l)
if [ ! -z $chkvar ]
then
     echo " [CHECK] $chkfile exist : $chkvar" >> $RESFILE 2>&1
else
     echo " [OK]  $chkfile does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B14. Checking attribute of grub*.cfg
################################################################################

echo "B14. Checking attribute of grub*.cfg" >> $RESFILE 2>&1 
if [[ "$osrel" == "Ubuntu" ]]
then
    echo " [CMD] /bin/ls -ld /boot/grub/grub*.cfg" >> $RESFILE 2>&1
    /bin/ls -ld /boot/grub/grub*.cfg >> $RESFILE 2>&1
    grubfile=$(/bin/ls -d /boot/grub/grub*.cfg)
else
    echo " [CMD] /bin/ls -ld /etc/grub*" >> $RESFILE 2>&1
    /bin/ls -ld /etc/grub* >> $RESFILE 2>&1
    if [ "$osmajor" -ge 7 ]
    then
        [ -d /sys/firmware/efi ] && grubfile=$(/bin/ls -ld /etc/grub2-efi.cfg | cut -f2 -d">" | /bin/sed 's, \.\.,,g') || \
        grubfile=$(/bin/ls -ld /etc/grub2.cfg | cut -f2 -d">" | /bin/sed 's, \.\.,,g')
    else
        grubfile=$(/bin/ls -ld /etc/grub.conf | cut -f2 -d">" | /bin/sed 's, \.\.,,g')
    fi
fi

if [ -e "$grubfile" ] 
then
    echo " [CMD] /bin/ls -ld $grubfile | awk '{print \$1}'" >> $RESFILE 2>&1
    chkvar=$(ls -ld $grubfile | awk '{print $1}')
    if [ ! -z $chkvar ]
    then
         echo " [CHECK] $grubfile is $chkvar" >> $RESFILE 2>&1
    fi
else
     echo " [OK] $grubfile does not exist" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B15. Checking /etc/services
################################################################################

echo "B15. Checking /etc/services" >> $RESFILE 2>&1
chkfile="/etc/services"
echo " [CMD] /bin/ls -ld $chkfile" >> $RESFILE 2>&1
/bin/ls -ld $chkfile 2>&1 >> $RESFILE 2>&1
chkvar=$(/bin/ls -ld $chkfile | awk '{print $1,$3,$4,$9}' 2>&1)
if [ -e $chkfile ]
then
    echo " [INFO] $chkfile exist." >> $RESFILE 2>&1
    arr=($(echo $chkvar | /bin/sed -e 's/\s/\n/g'))
    echo " [CHECK] $chkfile permission(600) is (${arr[0]})" >> $RESFILE 2>&1
    echo " [CHECK] $chkfile user(root) is (${arr[1]})" >> $RESFILE 2>&1
    echo " [CHECK] $chkfile group(root) is (${arr[2]})" >> $RESFILE 2>&1
else
    echo " [WARN] $chkfile does not exist." >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B16. Checking /etc/login.defs
################################################################################

echo "B16. Checking /etc/login.defs" >> $RESFILE 2>&1
chkfile="/etc/login.defs"
echo " [CMD] /bin/ls -ld $chkfile" >> $RESFILE 2>&1
/bin/ls -ld $chkfile 2>&1 >> $RESFILE 2>&1
chkvar=$(/bin/ls -ld $chkfile | awk '{print $1,$3,$4,$9}' 2>&1)
if [ -e $chkfile ]
then
    echo " [INFO] $chkfile exist." >> $RESFILE 2>&1
    arr=($(echo $chkvar | /bin/sed -e 's/\s/\n/g'))
    echo " [CHECK] $chkfile permission(600) is (${arr[0]})" >> $RESFILE 2>&1
    echo " [CHECK] $chkfile user(root) is (${arr[1]})" >> $RESFILE 2>&1
    echo " [CHECK] $chkfile group(root) is (${arr[2]})" >> $RESFILE 2>&1
else
    echo " [WARN] $chkfile does not exist." >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B17. Checking sync of network time
################################################################################

echo "B17. Checking sync of network time" >> $RESFILE 2>&1
echo " [CMD] /bin/ps -ef | grep -Ei 'chrony|ntp' | grep -cv grep" >> $RESFILE 2>&1
/bin/ps -ef | grep -Ei 'chrony|ntp' | grep -v grep >> $RESFILE 2>&1 
if [ $(/bin/ps -ef | grep -Ei 'chrony|ntp' | grep -cv grep) -ge 1 ]
then
     echo " [OK] Network Time Daemon is running" >> $RESFILE 2>&1
else
echo ""
     echo " [WARN] Network Time Daemon is not running" >> $RESFILE 2>&1
fi
echo " [INFO] Current Date is $(/bin/date '+%Y/%m/%d %X')" >> $RESFILE 2>&1
echo "" >> $RESFILE 2>&1

################################################################################
# B18. Checking Network Promiscuous Mode
################################################################################

echo "B18. Checking Network Promiscuous Mode" >> $RESFILE 2>&1
echo " [CMD] netstat -i | grep eth | awk '{print \$12}' | grep -c P" >> $RESFILE 2>&1
if [ $(netstat -i | grep eth | awk '{print $12}' | grep -c P) -ge 1 ]
then
    echo " [WARN] NIC is Promiscuous mode" >> $RESFILE 2>&1
else
    echo " [OK] NIC is not Promiscuous mode" >> $RESFILE 2>&1
fi
echo "" >> $RESFILE 2>&1

################################################################################
# B19. Checking Network Some Parameters
################################################################################

echo "B19. Checking Network Some Parameters" >> $RESFILE 2>&1
chklist="
net.ipv4.icmp_echo_ignore_broadcasts:1
net.ipv4.tcp_syncookies:1
net.ipv4.conf.all.accept_redirect:0
net.ipv4.icmp_ignore_bogus_error_responses:1
net.ipv4.conf.all.rp_filter:1 
net.ipv4.conf.all.log_martians:1
"
for vars in $chklist;
do
    arr=($(echo $vars | sed 's/:/\n/g'))
    chkvar=$(sysctl ${arr[0]} 2> /dev/null | awk -F= '{print $2}' | sed -e 's/\s//g')
    #echo "$chkvar" 
    if [[ "$chkvar" -eq "${arr[1]}" ]] && [[ ! -z "$chkvar" ]]
    then
        echo " [OK] ${arr[0]} parameter is ok(${arr[1]})" >> $RESFILE 2>&1
    else
        echo " [WARN] ${arr[0]} parameter is not good(${arr[1]})" >> $RESFILE 2>&1
    fi
done
echo "" >> $RESFILE 2>&1

