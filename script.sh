apt-get update
apt-get install -y util-linux
echo "=== CPU INFO ==="

echo "CPU cores available:"
nproc

echo
echo "CPU details:"
lscpu | grep -E '^(CPU\(s\)|Model name|Architecture|Thread|Core|Socket)'
