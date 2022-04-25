#!/usr/bin/env python3
"""
This file doesn't work- run POX and Mininet in two separate terminals.
"""
import os
import sys
from typing import List, Dict, Callable

from mininet.net import Mininet
from mininet.node import Controller, RemoteController
from mininet.cli import CLI
from mininet.util import dumpNodeConnections
from .topology import *

POX_PATH = os.getenv("POX_PATH") or f"/home/mininet/pox/pox.py"


class POXController(Controller):
    def start(self):
        __dir__ = os.path.dirname(__file__)
        self.cmd(POX_PATH, f"pox_controller > {__dir__}/pox.log &")

    def stop(self):
        self.cmd(f"kill %{POX_PATH}")


def run_mininet_cli(pox: bool):
    topo = ProjectTopology()
    controller = RemoteController
    if pox:
        controller = POXController
    net = Mininet(topo=topo, controller=controller, listenPort=6633)
    net.start()
    print("Dumping host connections...")
    dumpNodeConnections(net.hosts)
    print("Starting mininet, awaiting external commands...")
    CLI(net)
    net.stop()


controllers: Dict[str, Callable] = {"pox_controller": POXController}


def main(argv: List[str]):
    if len(argv) > 1:
        exit(64)

    pox = False
    if len(argv) == 1 and argv[0] == "with-pox":
        pox = True
    print("Starting...")
    run_mininet_cli(pox=pox)


if __name__ == "__main__":
    main(sys.argv[1:])
