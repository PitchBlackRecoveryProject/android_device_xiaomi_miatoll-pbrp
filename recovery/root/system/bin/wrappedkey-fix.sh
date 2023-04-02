#!/system/bin/sh
#
#	This file is part of the OrangeFox Recovery Project
# 	Copyright (C) 2022-2023 The OrangeFox Recovery Project
#
#	OrangeFox is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	any later version.
#
#	OrangeFox is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
# 	This software is released under GPL version 3 or any later version.
#	See <http://www.gnu.org/licenses/>.
#
# 	Please maintain this if you use this script or any part of it
#
#
# Wrappedkey fix script for FBEv2
# Deal with situations where the ROM doesn't support wrappedkey encryption;
# In such cases, remove the wrappedkey flag from the fstab file
#
# the recovery log
LOGF=/tmp/recovery.log;

# do we want debug info?
DEBUG=1; # yes

fix_fstab_wrappedkey() {
local D=/FFiles/temp/vendor_prop;
local S=/dev/block/bootdevice/by-name/vendor;
local F=/FFiles/temp/vendor-build.prop;
    cd /FFiles/temp/;
    mkdir -p $D;
    mount -r $S $D;
    cp $D/build.prop $F;
    cp $D/etc/fstab.qcom /FFiles/temp/;
    umount $D;
    rmdir $D;

    [ ! -e $F ] && {
    	echo "$F does not exist. Quitting." >> $LOGF;
    	return;
    }

    # cleanup
    rm -f $F;

    # check for FBEv2 wrappedkey_v0 flags
    F=/FFiles/temp/fstab.qcom;
    local wrap0=$(grep "/userdata" "$F" | grep "wrappedkey_v0");
    if [ -n "$wrap0" ]; then
       [ "$DEBUG" = "1" ] && echo "Debug:OrangeFox: this ROM supports wrappedkey_v0. Correcting the fstab" >> $LOGF;
       cp /system/etc/recovery-fbev2-wrap0.fstab /system/etc/recovery.fstab;
    else
       [ "$DEBUG" = "1" ] && echo "Debug:OrangeFox: this ROM does not support wrappedkey_v0" >> $LOGF;
    fi
}

# ---
[ "$DEBUG" = "1" ] && echo "Debug:OrangeFox: Starting wrappedkey fix" >> $LOGF;
fix_fstab_wrappedkey;
exit 0;
