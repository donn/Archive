import os

from pox.core import core
from pox.lib.util import dpid_to_str

from pox_common import *


def on_packet(event):
    dpid = dpid_to_str(event.connection.dpid)
    switch = Switch.by_dpid[dpid]

    print(f"Received unhandled packet from {switch}, sending program back...")

    messages = []

    if switch.number == 1:
        messages += allow_all_ip("192.168.60.1", Action.fwd(1))
        messages += allow_all_ip("192.168.61.0/24", Action.fwd(2))
        messages += allow_all_ip("192.168.62.0/24", Action.fwd(3))
    elif switch.number == 2:
        messages += allow_all_ip("192.168.60.0/24", Action.fwd(1))
        messages += allow_all_ip("192.168.61.1", Action.fwd(2))
        messages += allow_all_ip("192.168.62.0/24", Action.fwd(3))
    elif switch.number == 3:
        if os.getenv("LIMITED_FLOWS") == "1":
            for peer, action in [
                ["192.168.60.1", Action.fwd(1)],
                ["192.168.61.1", Action.fwd(2)],
            ]:
                for protocol in [Protocol.arp]:
                    messages += add_ip_flow(
                        "192.168.62.2", None, peer, None, [action], protocol, 3
                    )
                for peer_port in [22, 80]:
                    messages += add_ip_flow(
                        "192.168.62.2", None, peer, peer_port, [action], Protocol.tcp, 3
                    )

            for protocol in [Protocol.arp, Protocol.ip]:
                messages += add_ip_flow(
                    "192.168.62.2", None, None, None, [], protocol, 2
                )

        messages += allow_all_ip("192.168.60.0/24", Action.fwd(1))
        messages += allow_all_ip("192.168.61.0/24", Action.fwd(2))
        messages += allow_all_ip("192.168.62.1", Action.fwd(4))
        messages += allow_all_ip("192.168.62.2", Action.fwd(3))

    for message in messages:
        event.connection.send(message)


def launch():
    print("Launching POX Controller...")
    core.openflow.addListenerByName(
        "ConnectionUp", lambda evt: Switch.on_connection_up(evt)
    )
    core.openflow.addListenerByName("PacketIn", on_packet)
    print("Added listeners.")
