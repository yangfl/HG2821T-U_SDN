# apt install mtd-utils

sudo rmmod mtdblock
sudo rmmod ubifs
sudo rmmod ubi
sudo rmmod nandsim

file="$1"

mkdir -p mtd
dd "if=${file}" of=mtd/mtd0 bs=131072 skip=0 count=16
dd "if=${file}" of=mtd/mtd1 bs=131072 skip=16 count=32
dd "if=${file}" of=mtd/mtd2 bs=131072 skip=48 count=320
dd "if=${file}" of=mtd/mtd3 bs=131072 skip=368 count=128
dd "if=${file}" of=mtd/mtd4 bs=131072 skip=496 count=32
dd "if=${file}" of=mtd/mtd5 bs=131072 skip=528 count=320
dd "if=${file}" of=mtd/mtd6 bs=131072 skip=848 count=128
dd "if=${file}" of=mtd/mtd7 bs=131072 skip=976 count=16
dd "if=${file}" of=mtd/mtd8 bs=131072 skip=992 count=80
dd "if=${file}" of=mtd/mtd9 bs=131072 skip=1072 count=32
dd "if=${file}" of=mtd/mtd10 bs=131072 skip=1104 count=48
dd "if=${file}" of=mtd/mtd11 bs=131072 skip=1152 count=64
dd "if=${file}" of=mtd/mtd12 bs=131072 skip=1216 count=64
dd "if=${file}" of=mtd/mtd13 bs=131072 skip=1280 count=592

sudo modprobe nandsim first_id_byte=0x20 second_id_byte=0xaa third_id_byte=0x00 fourth_id_byte=0x15 parts=0x10,0x20,0x140,0x80,0x20,0x140,0x80,0x10,0x50,0x20,0x30,0x40,0x40,0x250
sudo modprobe ubifs
mkdir -p mntdir
for i in 2 3 5 6 13; do
  sudo dd if=mtd/mtd${i} of=/dev/mtd${i} bs=131072
  if sudo ubiattach /dev/ubi_ctrl -m $i -d $i -O 2048; then
    if sudo mount -t ubifs ubi${i}_0 mntdir; then
      mkdir -p part${i}
      sudo cp -a mntdir/. part${i}
      sudo umount mntdir
    fi
    sudo ubidetach -d $i
  fi
done

sudo modprobe mtdblock
for i in 7 8 9 10; do
  jffs2dump -r -e mtd/mtd${i}le -b mtd/mtd${i}
  sudo dd if=mtd/mtd${i}le of=/dev/mtd${i} bs=131072
  if sudo mount -t jffs2 /dev/mtdblock${i} mntdir; then
    mkdir -p part${i}
    sudo cp -a mntdir/. part${i}
    sudo umount mntdir
  fi
done

for i in 11 12; do
  if sudo mount -t squashfs mtd/mtd${i} mntdir; then
    mkdir -p part${i}
    sudo cp -a mntdir/. part${i}
    sudo umount mntdir
  fi
done
