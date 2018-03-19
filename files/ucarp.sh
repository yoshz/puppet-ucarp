#!/bin/bash

. /etc/init.d/functions

get_files() {
    _cfg=$1
    FILES=`find ${CONFDIR} -maxdepth 1 -type f -regex ".*/vip-[0-9]*.conf" \
        -printf "%f\n" | egrep '^vip-[[:digit:]]+\.conf$' | LC_COLLATE="C" sort`
}

prog=$"common address redundancy protocol daemon"
LOGGER="/usr/bin/logger -p daemon.notice -t ucarp"
CONFDIR=/etc/ucarp
UPSCRIPT=/usr/libexec/ucarp/vip-up
DOWNSCRIPT=/usr/libexec/ucarp/vip-down

start() {
    RETVAL=-1
    VIP_RETVAL=0

    echo -n $"Starting ${prog}: "

    get_files

    if [ -z "${FILES}" ]; then
        ${LOGGER} "no virtual addresses are configured in ${CONFDIR}"
        failure
        RETVAL=1
    else
        for FILE in ${FILES}; do
            # Check that the file name gives us an ID between 1 and 255
            ID=`echo ${FILE}| sed 's/^vip-\(.*\).conf/\1/'`
            if [ ${ID} -lt 1 -o ${ID} -gt 255 ]; then
                ${LOGGER} "ID out of range (1-255) for ${FILE}, skipped VIP ID ${ID}"
                continue
            fi

            #unset PASSWORD BIND_INTERFACE SOURCE_ADDRESS VIP_ADDRESS OPTIONS
            # Source ucarp settings
            . ${CONFDIR}/vip-common.conf
            . ${CONFDIR}/${FILE}
            TMP_RETVAL=0

            if [ -z "${PASSFILE}" ]; then
                ${LOGGER} "no PASSFILE found for ${FILE}, skipped VIP ID ${ID}"
                TMP_RETVAL=1
            fi
            if [ -z "${BIND_INTERFACE}" ]; then
                ${LOGGER} "no BIND_INTERFACE found for ${FILE}, skipped VIP ID ${ID}"
                TMP_RETVAL=1
            fi
            if [ -z "${SOURCE_ADDRESS}" ]; then
                ${LOGGER} "no SOURCE_ADDRESS found for ${FILE}, skipped VIP ID ${ID}"
                TMP_RETVAL=1
            fi
            if [ -z "${VIP_ADDRESS}" ]; then
                ${LOGGER} "no VIP_ADDRESS found for ${FILE}, skipped VIP ID ${ID}"
                TMP_RETVAL=1
            fi

            # If one of more of the above failed, skip the daemon launch
            if [ ${TMP_RETVAL} -ne 0 ]; then
                VIP_RETVAL=1
                continue
            fi

            [ ${RETVAL} -eq -1 ] && RETVAL=0
            daemon /usr/sbin/ucarp --daemonize --interface=${BIND_INTERFACE} --passfile=${PASSFILE} --srcip=${SOURCE_ADDRESS} --vhid=${ID} --addr=${VIP_ADDRESS} ${OPTIONS} --upscript=$UPSCRIPT --downscript=$DOWNSCRIPT >/dev/null
            LAUNCH_RETVAL=$?
            [ ${LAUNCH_RETVAL} -ne 0 ] && RETVAL=1
        done

        # failure/success or warning if launch worked with some vip errors
        if [ ${RETVAL} -eq 0 -a ${VIP_RETVAL} -eq 0 ]; then
            ${LOGGER} "all ucarp configurations were applied successfully"
            success
            touch /var/lock/subsys/ucarp
        elif [ ${RETVAL} -eq 0 -a ${VIP_RETVAL} -eq 1 ]; then
            ${LOGGER} "error in one or more of the ucarp configurations"
            warning
        else
           ${LOGGER} "error running one or more of the ucarp daemon instances"
            failure
        fi
    fi
    echo
}

stop() {
    echo -n $"Stopping $prog: "
    killproc /usr/sbin/ucarp >/dev/null
    RETVAL=$?

    # With "--shutdown" in the default OPTIONS, the down script is called
    # when ucarp is stopped, so IP addresses are released, no "leftovers".

    # failure/success (no warning, too complicated to handle properly)
    if [ ${RETVAL} -eq 1 ]; then
        ${LOGGER} "it seems like no ucarp daemon were running"
        failure
    else
        ${LOGGER} "all ucarp daemons stopped and IP addresses unassigned"
        success
        rm -f /var/lock/subsys/ucarp
    fi
    echo
}

# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    condrestart)
        if [ -f /var/lock/subsys/ucarp ]; then
            stop
            start
        fi
        ;;
    status)
        status /usr/sbin/ucarp
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|condrestart|status}"
        exit 1
esac

exit $RETVAL
