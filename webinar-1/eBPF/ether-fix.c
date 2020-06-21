// eBPF - to compile and run:
//# clang -I/usr/include/x86_64-linux-gnu   -O2 -target bpf -c ether-fix.c -o ether-fix.o
//# ip link set dev eth0 xdp obj ether-fix.o sec ether-fix


#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <linux/ip.h>

#define SEC(NAME) __attribute__((section(NAME), used))

#define htons __builtin_bswap16
#define ntohs __builtin_bswap16

SEC("qfx-fix")

int qfxfix(struct xdp_md *xdp) {


    void *data = (void *)(long)xdp->data;
    void *data_end = (void *)(long)xdp->data_end;

    int eth_len = sizeof(struct ethhdr);
    int ip_len = sizeof(struct iphdr);

    struct ethhdr *eth = data;
    struct iphdr *ip = data + eth_len;

    if (data + eth_len + ip_len > data_end) {
	return XDP_ABORTED;
    }

    //EthType 0x86dd (IPv6) and IPv4 header does not mix
    if (eth->h_proto == ntohs(ETH_P_IPV6) && ip->version == 4)
    {
	//set ethtype to 0x0800 (IPv4)
	eth->h_proto = htons(ETH_P_IP); 
    }

    return XDP_PASS;
}
 
char _license[] SEC("license") = "GPL";

