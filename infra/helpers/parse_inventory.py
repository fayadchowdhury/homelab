from typing import Dict
import sys
import json

def parse_tf_output(json_string: str) -> Dict:
    return json.loads(json_string)["vm_metadata"]["value"]

def generate_inventory_dict(vm_metadata: Dict) -> Dict:
    inventory = {}
    for k, v in vm_metadata.items():
        if "master" in k:
            if "kube-master" not in inventory:
                inventory["kube-master"] = []
            inventory["kube-master"].append(f"{k} ansible_host={v["ip"].split("/")[0]}")
        if "worker" in k:
            if "kube-worker" not in inventory:
                inventory["kube-worker"] = []
            inventory["kube-worker"].append(f"{k} ansible_host={v["ip"].split("/")[0]}")
        tags = v.get("tags", "").split(",")
        for tag in tags:
            if tag not in inventory:
                inventory[tag] = []
            inventory[tag].append(f"{k} ansible_host={v["ip"].split("/")[0]}")
    return inventory

def write_inventory_file(inventory: Dict, path: str) -> None:
    with open(path, "w") as f:
        for k, v in inventory.items():
            f.write(f"[{k}]\n")
            for i in v:
                f.write(f"{i}\n")
            f.write(f"\n")
    return

if __name__=="__main__":
    json_string = sys.stdin.read()
    vm_metadata = parse_tf_output(json_string)
    inventory_dict = generate_inventory_dict(vm_metadata)
    inventory_file_output = sys.argv[1]
    write_inventory_file(inventory_dict, inventory_file_output)

    print(f"Complete inventory:\n{inventory_dict}")