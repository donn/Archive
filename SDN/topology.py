from mininet.topo import Topo
from typing import Dict, Callable


class ProjectTopology(Topo):
    def build(self):
        IA = "192.168.60.1"
        EA = "10:00:00:00:00:10"
        IB = "192.168.61.1"
        EB = "10:00:00:00:00:20"
        IC = "192.168.62.1"
        EC = "10:00:00:00:00:30"
        ID = "192.168.62.2"
        ED = "10:00:00:00:00:40"

        # ALERT: All ports in the given topology incremented by 1

        # Hosts
        a = self.addHost("A", ip=IA, mac=EA)
        b = self.addHost("B", ip=IB, mac=EB)
        c = self.addHost("C", ip=IC, mac=EC)
        d = self.addHost("D", ip=ID, mac=ED)

        # Switches
        s1 = self.addSwitch("S1")
        s2 = self.addSwitch("S2")
        s3 = self.addSwitch("S3")

        # Links
        self.addLink(node1=s1, port1=1, node2=a)

        self.addLink(node1=s1, port1=2, node2=s2, port2=1)
        self.addLink(node1=s1, port1=3, node2=s3, port2=1)

        self.addLink(node1=s2, port1=2, node2=b)
        self.addLink(node1=s2, port1=3, node2=s3, port2=2)

        self.addLink(node1=s3, port1=4, node2=c)
        self.addLink(node1=s3, port1=3, node2=d)


class RouterExerciseTopology(Topo):
    def build(self):
        ih1 = "10.1.0.100/24"
        eh1 = "10:00:00:00:00:10"
        ih2 = "10.2.0.100/24"
        eh2 = "10:00:00:00:00:20"
        ih3 = "10.3.0.100/24"
        eh3 = "10:00:00:00:00:30"

        # Hosts
        h1 = self.addHost("h1", ip=ih1, mac=eh1, defaultRoute="via 10.1.0.1")
        h2 = self.addHost("h2", ip=ih2, mac=eh2, defaultRoute="via 10.2.0.1")
        h3 = self.addHost("h3", ip=ih3, mac=eh3, defaultRoute="via 10.3.0.1")

        # Switches
        s1 = self.addSwitch("s1", mac="10:00:00:00:00:42")

        # Links
        self.addLink(node1=s1, port1=1, node2=h1)
        self.addLink(node1=s1, port1=2, node2=h2)
        self.addLink(node1=s1, port1=3, node2=h3)


topos: Dict[str, Callable] = {
    "project_topology": ProjectTopology,
    "router_exercise_topology": RouterExerciseTopology,
}
