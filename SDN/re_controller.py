from pox.core import core
from pox.lib.packet import ethernet, arp, ipv4
import pox.openflow

from pox_common import *

from copy import copy
from queue import Queue

MULTICAST = "ff:ff:ff:ff:ff:ff"


class Controller(object):
    def __init__(self):
        self.mac_port_by_ip: Dict[str, (str, int)] = {}
        self.ip_packet_queue: Dict[str, Queue[ethernet]] = {}

    def on_packet(self, event: pox.openflow.PacketIn):
        SWITCH_HW_ADR = of.EthAddr("10:00:00:00:00:42")
        SWITCH_IP_ADR = of.IPAddr(f"10.{event.port}.0.1")

        messages = []

        def learn_address(ip: str, mac: str, port: int):
            # https://noxrepo.github.io/pox-doc/html/#set-ip-source-or-destination-address
            nonlocal messages, self
            pm = self.mac_port_by_ip.get(ip)
            if pm is None:
                self.mac_port_by_ip[ip] = (mac, port)
                action_list = [
                    Action.alter_ethernet_address(SWITCH_HW_ADR, True),
                    Action.alter_ethernet_address(mac, False),
                    Action.fwd(port),
                ]
                messages += add_ip_flow(None, None, ip, None, action_list, Protocol.ip)
                print(f"Registered {mac} with IP {ip} at port {port}")

        eth_in = event.parsed
        if eth_in.type == ethernet.ARP_TYPE:
            # Received unhandled ARP packet:
            # * Learn as much as you can about the sender
            # * If it's a request for the router, reply
            # * If it's a new reply to the router, transmit any enqueued packets
            #   for that particular destination
            arp_in: arp = eth_in.payload
            requester_mac = arp_in.hwsrc
            requester_ip = arp_in.protosrc

            learn_address(requester_ip, requester_mac, event.port)

            if arp_in.opcode == arp.REQUEST and arp_in.protodst == SWITCH_IP_ADR:
                eth_out = copy(eth_in)
                eth_out.payload = copy(eth_in.payload)

                arp_out: arp = eth_out.payload
                arp_out.hwsrc = SWITCH_HW_ADR
                arp_out.hwdst = arp_in.hwsrc
                arp_out.protosrc = SWITCH_IP_ADR
                arp_out.protodst = arp_in.protosrc
                arp_out.opcode = arp.REPLY

                packet_msg = of.ofp_packet_out()
                packet_msg.data = eth_out.pack()
                packet_msg.actions.append(Action.fwd(event.port))

                messages.append(packet_msg)
            elif arp_in.opcode == arp.REPLY and arp_in.protodst == SWITCH_IP_ADR:
                dst = arp_in.protosrc
                queue = self.ip_packet_queue.get(dst.toStr())
                if queue is not None:
                    while not queue.empty():
                        eth_out = queue.get()
                        eth_out.src = SWITCH_HW_ADR
                        eth_out.dst = arp_in.hwsrc

                        packet_msg = of.ofp_packet_out()
                        packet_msg.data = eth_out.pack()
                        packet_msg.actions.append(Action.fwd(event.port))

                        messages.append(packet_msg)

        elif eth_in.type == ethernet.IP_TYPE:
            # Received unhandled IP packet:
            # * ARP it out (so the switch can learn)
            # * Enqueue the packet for when you get a reply
            ip_in: ipv4 = eth_in.payload
            ip_in_str = ip_in.dstip.toStr()

            eth_in_copy = copy(eth_in)
            eth_in_copy.payload = copy(eth_in.payload)

            self.ip_packet_queue[ip_in_str] = (
                self.ip_packet_queue.get(ip_in_str) or Queue()
            )
            self.ip_packet_queue[ip_in_str].put(eth_in_copy)

            for port in range(1, 4):

                eth_out = copy(eth_in)
                eth_out.src = SWITCH_HW_ADR
                eth_out.dst = of.EthAddr("ff:ff:ff:ff:ff:ff")

                eth_out.type = ethernet.ARP_TYPE
                eth_out.payload = arp()

                arp_out: arp = eth_out.payload
                arp_out.hwsrc = SWITCH_HW_ADR
                arp_out.hwdst = of.EthAddr("ff:ff:ff:ff:ff:ff")

                arp_out.protosrc = of.IPAddr(f"10.{port}.0.1")
                arp_out.protodst = ip_in.dstip
                arp_out.opcode = arp.REQUEST

                packet_msg = of.ofp_packet_out()
                packet_msg.data = eth_out.pack()
                packet_msg.actions.append(Action.flood())

                messages.append(packet_msg)

        for message in messages:
            event.connection.send(message)


def launch():
    c = Controller()
    print("Launching POX Controller...")
    core.openflow.addListenerByName(
        "ConnectionUp", lambda evt: Switch.on_connection_up(evt)
    )
    core.openflow.addListenerByName("PacketIn", lambda evt: c.on_packet(evt))
    print("Added listeners.")
