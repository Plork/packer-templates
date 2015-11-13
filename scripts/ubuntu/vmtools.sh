#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)
    mkdir -p /tmp/vbox;
    ver="`cat /home/vagrant/.vbox_version`";
    mount -o loop $HOME_DIR/VBoxGuestAdditions_${ver}.iso /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
            "For more read https://www.virtualbox.org/ticket/12479";
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;
    ;;

vmware-iso|vmware-vmx)
    mkdir -p /tmp/vmware;
    mkdir -p /tmp/vmware-archive;
    mount -o loop $HOME_DIR/linux.iso /tmp/vmware;
    tar xzf /tmp/vmware/VMwareTools-*.tar.gz -C /tmp/vmware-archive;
    /tmp/vmware-archive/vmware-tools-distrib/vmware-install.pl --force-install;
    umount /tmp/vmware;
    rm -rf  /tmp/vmware;
    rm -rf  /tmp/vmware-archive;
    rm -f $HOME_DIR/*.iso;
    ;;

*)
    echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected.";
    echo "Known are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm.";
    ;;

esac

echo ""
read -p "Please press enter to continue..." nothing
