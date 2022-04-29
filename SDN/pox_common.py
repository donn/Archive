import re
from typing import Dict, List, Optional
from enum import Enum

import pox.openflow
import pox.openflow.libopenflow_01 as of
from pox.lib.util import dpid_to_str
from pox.lib.packet import packet_base as Packet


class Action(of.ofp_action_base):
    @staticmethod
    def fwd(port: int) -> "Action":
        return of.ofp_action_output(port=port)

    @staticmethod
    def drop():
        return None

    @staticmethod
    def flood() -> "Action":
        return of.ofp_action_output(port=of.OFPP_FLOOD)

    @staticmethod
    def alter_ethernet_address(addr: str, src: bool) -> "Action":
        """
        if src is true, the src is altered.
        if src is false, the destination is altered.
        """
        type = 4 if src else 5
        return of.ofp_action_dl_addr(type, addr)


class Protocol(Enum):
    ip = (0x800, None)
    arp = (0x806, None)
    tcp = (0x800, 6)
    any = (None, None)


def add_ip_flow(
    src: Optional[str],
    src_port: Optional[str],
    dst: Optional[str],
    dst_port: Optional[str],
    actions: List[Action],
    protocol: Protocol,
    priority: int = 1,
) -> List[of.ofp_flow_mod]:
    """
    Empty array to 'actions' for a drop
    """

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

    msg.actions += actions

    return [msg]


def add_eth_flow(
    src: Optional[str],
    dst: Optional[str],
    action: Optional[Action],
    protocol: Protocol,
    priority: int = 1,
) -> List[of.ofp_flow_mod]:

    (dl_type, _) = protocol.value

    msg = of.ofp_flow_mod()
    msg.priority = priority
    msg.idle_timeout = 1000

    msg.match.dl_type = dl_type
    if src is not None:
        msg.match._dl_src = src

    if dst is not None:
        msg.match._dl_dst = dst

    if action is not None:  # a None action is a drop
        msg.actions.append(action)

    return [msg]


def allow_all_ip(dst: str, action: Optional[Action], priority: int = 1):
    msgs = []
    for protocol in [Protocol.ip, Protocol.arp]:
        msgs += add_ip_flow(None, None, dst, None, [action], protocol, priority)
    return msgs


class Switch(object):
    by_dpid: Dict[str, "Switch"] = {}

    def __init__(self, number: int, dpid: str):
        self.number = number
        self.dpid = dpid

    @classmethod
    def on_connection_up(Self, event: pox.openflow.ConnectionUp):
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
