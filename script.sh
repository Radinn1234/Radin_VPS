apt-get update
apt-get install -y util-linux
echo "=============================="
echo "        SYSTEM INFO"
echo "=============================="

echo
echo "=== CPU ==="
echo "Logical CPUs:"
nproc

echo
echo "CPU details:"
lscpu | grep -E '^(Architecture|CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket|Socket\(s\)|Model name)'

echo
echo "=== RAM ==="
free -h

echo
echo "=== DISK ==="
df -h /

echo
echo "=== FILESYSTEM ==="
df -T /

echo
echo "=== CPU LIMIT ==="
cat /sys/fs/cgroup/cpu.max 2>/dev/null || echo "cgroup v1/unknown"

echo
echo "=== MEMORY LIMIT ==="
cat /sys/fs/cgroup/memory.max 2>/dev/null || echo "cgroup v1/unknown"

echo
echo "=== KERNEL ==="
uname -a

echo
echo "=== HOSTNAME ==="
hostname

echo
echo "=============================="
echo "       INFO COMPLETE"
echo "=============================="
