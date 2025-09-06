# HG2821T-U SDN

* SoC：EN751221
* ROM：TC58CVG1S3H
* SDN 固件版本：FH.1.0.4

因镜像含用户配置，故不公开提供，需要请私信

> 非 CDN 版镜像：https://www.right.com.cn/forum/thread-4058319-1-1.html

## ROM 读取

> 参考 https://www.right.com.cn/forum/thread-4058319-1-1.html （此贴内附镜像为错误示范，切勿使用）

建议使用热风枪取下 SPI-NAND，芯片有 EPAD，GND 散热较快，加热透才能取下。

编译 https://github.com/McMCCRU/SNANDer 用 CH341 读取芯片，但**必须修改源码**将 TC58CVG1S3H 的 OOB 大小设为 128B，且**关闭 ECC** 并**包括 OOB 空间**进行读写，否则读取的内容将无法使用！

原始镜像大小应恰为 285212672，否则请检查上一步。

读出带 ECC 镜像后，用 decode.py 解码 ECC 获取 ROM。

## ROM 解包

> 见 extract.sh

按以下分区表提取：

```
Creating 14 MTD partitions on "EN7512-SPI_NAND":
0x000000000000-0x000000200000 : "boot"            0
0x000000200000-0x000000600000 : "KernelA"         1
0x000000600000-0x000002e00000 : "AppA"            2
0x000002e00000-0x000003e00000 : "RootfsA"         3
0x000003e00000-0x000004200000 : "KernelB"         4
0x000004200000-0x000006a00000 : "AppB"            5
0x000006a00000-0x000007a00000 : "RootfsB"         6
0x000007a00000-0x000007c00000 : "ConfigurationA"  7
0x000007c00000-0x000008600000 : "ConfigurationB"  8
0x000008600000-0x000008a00000 : "UserLocalCT"     9
0x000008a00000-0x000009000000 : "Userdata"        10
0x000009000000-0x000009800000 : "Framework1"      11
0x000009800000-0x00000a000000 : "Framework2"      12
0x00000a000000-0x00000ea00000 : "Apps"            13

mtd0:    // https://github.com/cjdelisle/EN751221-Linux26/tree/master/tclinux_phoenix/bootrom
mtd1:    LZMA compressed data, non-streamed, size 7116384
mtd2:    UBI image, version 1
mtd3:    UBI image, version 1
mtd4:    LZMA compressed data, non-streamed, size 7116384
mtd5:    UBI image, version 1
mtd6:    UBI image, version 1
mtd7:    Linux jffs2 filesystem data big endian
mtd8:    Linux jffs2 filesystem data big endian
mtd9:    Linux jffs2 filesystem data big endian
mtd10:   Linux jffs2 filesystem data big endian
mtd11:   // empty
mtd12:   Squashfs filesystem, little endian, version 4.0, xz compressed, 6845046 bytes, 962 inodes, blocksize: 262144 bytes, created: Thu Jul 20 03:12:21 2017
mtd13:   UBI image, version 1

/ # mount
rootfs on / type rootfs (rw)
ubi0:Rootfs on / type ubifs (ro,sync,relatime)
proc on /proc type proc (rw,relatime)
tmpfs on /tmp type tmpfs (rw,relatime)
udev on /dev type ramfs (rw,relatime)
/dev/pts on /dev/pts type devpts (rw,relatime,mode=600,ptmxmode=000)
ubi1:Appfs on /rom type ubifs (ro,sync,relatime)
/dev/mtdblock8 on /flash type jffs2 (rw,relatime)
/dev/mtdblock9 on /usr/local type jffs2 (rw,relatime)
/dev/mtdblock10 on /usr/wrifh type jffs2 (rw,relatime)
/dev/mtdblock7 on /data type jffs2 (ro,relatime)
ubi2:Apps_ubifs on /opt/upt/apps type ubifs (rw,sync,relatime)
tmpfs on /var type tmpfs (rw,relatime,size=263144k)
tmpfs on /var/run/netns type tmpfs (rw,relatime,size=263144k)
proc on /var/run/netns/MNG type proc (rw,relatime)
proc on /var/run/netns/NM type proc (rw,relatime)
proc on /var/run/netns/FM type proc (rw,relatime)
proc on /var/run/netns/APP type proc (rw,relatime)
proc on /var/run/netns/obox type proc (rw,relatime)
tmpfs on /mnt type tmpfs (rw,relatime)
obox on /sys type sysfs (rw,relatime)
```

## 获取 shell

> 参考 https://github.com/haoqi366/SDN_research https://www.right.com.cn/forum/thread-8442337-1-1.html

PCB 上有 TTL 接口，但固件默认封锁 TTL，需通过脚本提权。

固件自带 busybox 工具不全，需另外下载 [busybox](https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/) 并传输到光猫上。光猫自带 tftp、ftpget、curl，u 盘默认挂载点为 /mnt/usb1_1。

注意：光猫可能会反复切换网络，造成断连假象，可另开窗口持续 `ping 192.168.1.1` 检查光猫网络是否正常。

举例：使用 HTTP 传输 busybox

1. 确认本机 IP 地址，假设为 192.168.1.2；
2. 在存放 busybox 的文件夹中启动 HTTP 服务，如：`python3 -m http.server`
3. 执行
```sh
./sdn.py ip netns exec obox curl http://192.168.1.2:8000/busybox -o /tmp/busybox
./sdn.py chmod +x /tmp/busybox
./sdn.py ip netns exec obox /tmp/busybox telnetd -l /bin/sh
```
4. 连接光猫：`telnet 192.168.1.1`
5. 固化配置
```sh
mkdir /usr/local/bin
cp /tmp/busybox /usr/local/bin/busybox
/usr/local/bin/busybox --install -s /usr/local/bin

mount -o remount,rw /
# 打开 TTL 输入
sed -i 's|#ttyS0::respawn:-/bin/sh|ttyS0::respawn:-/bin/sh|' /etc/inittab
# 自启动 telnetd（警告：无密码验证）
echo '(cd /; ip netns exec obox /usr/local/bin/telnetd -l /usr/local/bin/sh)' >> /usr/init_scripts/init_script.sh
mount -o remount,ro /
```

强烈建议获取 shell 后立即备份光猫固件，例：
1. 电脑执行：`for i in $(seq 0 13); do nc -l -p 100$(printf "%02d" $i) > mtd$i; done`
2. 光猫执行：`for i in $(/usr/local/bin/seq 0 13); do dd if=/dev/mtd$i | ip netns exec obox /usr/local/bin/nc 192.168.1.2 100$(printf "%02d" $i); done`

## 固件切换

bootloader 支持固件切换（A/B 槽位），位于 `0x1e0000`（kernel 选择）和 `0x1e0004`（rootfs 选择），`0x30`（`'0'`）选择 A 槽，`0x31`（`'1'`）选择 B 槽，其他值视作 '0'。

选择 A 槽：
```
memwl 80000000 30ffffff
memwl 80000004 30ffffff
flash 1e0000 80000000 8
```

选择 B 槽：
```
memwl 80000000 31ffffff
memwl 80000004 31ffffff
flash 1e0000 80000000 8
```

## 刷非 SDN 固件

解包固件确认 SDN HTTP 确实无任何配置页面，可考虑刷成非 SDN 版使用。经确认，上述链接中非 SDN 镜像的 B 槽系统正常。

将 `KernelB.bin`, `AppB.bin`, `RootfsB.bin`, `RootfsA.bin` 传输到设备上（`/tmp`）。确认当前设备中使用的槽位，再往未使用的槽位中写入，假设未使用的是 B 槽位：
```
flash_erase /dev/mtd4 0 0
flash_erase /dev/mtd5 0 0
flash_erase /dev/mtd6 0 0
dd if=KernelB.bin of=/dev/mtd4 bs=131072
dd if=AppB.bin of=/dev/mtd5 bs=131072
dd if=RootfsB.bin of=/dev/mtd6 bs=131072
```

若未使用的是 A 槽位，则将 456 相应替换为 123。

参考上一章 [固件切换](#固件切换)，在 TTL 内或者对 `/dev/mtd0` 手动修改。

## 其他

`/etc/passwd`：`root:$1$b2r2spjB$JXYqaXI8QjsyAVe0u9rg3/:0:0:root:/root:/bin/sh`

root 密码：hg2x0

`/root/.ssh/authorized_keys`：`ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQCEFT+BZ0fMZpk3ZEf82eI3mRcL3d/q72eEgoq5UyUbcmZqMj3GUenleeJEopLEanaHD/FHGaOczdybpj1/g3c0Jz4gI61WB2UOENQzD+vbAxqLjY6GHwO4ts73uYC0V3uasSdiNxHTmayAY1eITLZ6qVL1Ep0mfGZrUXR7VAr0Gw== root@(none)`
