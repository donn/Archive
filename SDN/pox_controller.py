import os
import re
from typing import Dict, List, Optional
from enum import Enum

from pox.core import core
import pox.openflow.libopenflow_01 as of
from pox.lib.util import dpid_to_str

Action = of.ofp_action_base


class Protocol(Enum):
    ip = (0x800, None)
    arp = (0x806, None)
    tcp = (0x800, 6)


def add_ip_flow(
    src: Optional[str],
    src_port: Optional[str],
    dst: Optional[str],
    dst_port: Optional[str],
    action: Optional[Action],
    protocol: Protocol,
    priority: int = 1,
) -> List[of.ofp_flow_mod]:

    (dl_type, nw_proto) = protocol.value

    msg = of.ofp_flow_mod()
    msg.priority = priority
    msg.idle_timeout = 1000

    msg.match.dl_type = dl_type
    if nw_proto is not None:
        msg.match.nw_proto = nw_proto
    if src is not None:
        msg.match.nw_src = src
    if src_port is not None:
        msg.match.tp_src = src_port
    if dst is not None:
        msg.match.nw_dst = dst
    if dst_port is not None:
        msg.match.tp_dst = dst_port

    if action is not None:  # a None action is a drop
        msg.actions.append(action)

    return [msg]


def allow_all_ip(dst: str, action: Optional[Action], priority: int = 1):
    msgs = []
    for protocol in [Protocol.ip, Protocol.arp]:
        msgs += add_ip_flow(None, None, dst, None, action, protocol, priority)
    return msgs


# ---


class Switch(object):
    by_dpid: Dict[str, "Switch"] = {}

    def __init__(self, number: int, dpid: str):
        self.number = number
        self.dpid = dpid

    @classmethod
    def on_connection_up(Self, event):
        rx = re.compile(r"[sS](\d+)\-eth\d+")
        print(
            f"Recieved new connection from switch: {dpid_to_str(event.connection.dpid)}"
        )

        for m in event.connection.features.ports:
            match = rx.match(m.name)
            if match is None:
                continue
            switch_number = int(match[1])
            dpid = dpid_to_str(event.connection.dpid)

            switch = Self(switch_number, dpid)
            Self.by_dpid[dpid] = switch
            print(f"Switches.by_dpid[{dpid}] <- {switch}")

    def __repr__(self) -> str:
        return f"<Switch #{self.number} (DPID: {self.dpid})>"


def on_packet(event):
    def fwd(port: int) -> Action:
        return of.ofp_action_output(port=port)

    def drop():
        return None

    dpid = dpid_to_str(event.connection.dpid)
    switch = Switch.by_dpid[dpid]

    print(f"Received unhandled packet from {switch}, sending program back...")

    messages = []

    if switch.number == 1:
        messages += allow_all_ip("192.168.60.1", fwd(1))
        messages += allow_all_ip("192.168.61.0/24", fwd(2))
        messages += allow_all_ip("192.168.62.0/24", fwd(3))
    elif switch.number == 2:
        messages += allow_all_ip("192.168.60.0/24", fwd(1))
        messages += allow_all_ip("192.168.61.1", fwd(2))
        messages += allow_all_ip("192.168.62.0/24", fwd(3))
    elif switch.number == 3:
        if os.getenv("LIMITED_FLOWS") == "1":
            for peer, action in [["192.168.60.1", fwd(1)], ["192.168.61.1", fwd(2)]]:
                for protocol in [Protocol.arp]:
                    messages += add_ip_flow(
                        "192.168.62.2", None, peer, None, action, protocol, 3
                    )
                for peer_port in [22, 80]:
                    messages += add_ip_flow(
                        "192.168.62.2", None, peer, peer_port, action, Protocol.tcp, 3
                    )

            for protocol in [Protocol.arp, Protocol.ip]:
                messages += add_ip_flow(
                    "192.168.62.2", None, None, None, drop(), protocol, 2
                )

        messages += allow_all_ip("192.168.60.0/24", fwd(1))
        messages += allow_all_ip("192.168.61.0/24", fwd(2))
        messages += allow_all_ip("192.168.62.1", fwd(4))
        messages += allow_all_ip("192.168.62.2", fwd(3))

    for message in messages:
        event.connection.send(message)


def launch():
    print("Launching POX Controller...")
    core.openflow.addListenerByName(
        "ConnectionUp", lambda evt: Switch.on_connection_up(evt)
    )
    core.openflow.addListenerByName("PacketIn", on_packet)
    print("Added listeners.")
