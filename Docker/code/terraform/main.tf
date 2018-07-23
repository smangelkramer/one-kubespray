provider "opennebula" {
        endpoint = "${var.endpoint_url}"
        username = "${var.one_username}"
        password = "${var.one_password}"
}

data "template_file" "one-kube-template" {
        template = "${file("opennebula_kubernetes_template.tmpl")}"
}

resource "opennebula_template" "one-kube-template" {
        name = "terraform-kubernetes-template"
        description = "${data.template_file.one-kube-template.rendered}"
        permissions = "600"
}

resource "opennebula_vm" "kube-node" {
        name = "tf-kube-node${count.index}"
        template_id = "${opennebula_template.one-kube-template.id}"
        permissions = "600"

        # number of cluster nodes
        count = 3
}

resource "null_resource" "kubernetes" {
        provisioner "local-exec" {
                command = "cp -rfp /code/kubespray/inventory/sample /code/kubespray/inventory/mycluster"
        }

        provisioner "local-exec" {
                command = "/bin/bash -c \"declare -a IPS=(${join(" ", opennebula_vm.kube-node.*.ip)})\""
        }
        
        provisioner "local-exec" {
                command = "CONFIG_FILE=/code/kubespray/inventory/mycluster/hosts.ini python3 /code/kubespray/contrib/inventory_builder/inventory.py ${join(" ", opennebula_vm.kube-node.*.ip)}"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /code/kubespray/inventory/mycluster/hosts.ini /code/kubespray/cluster.yml --private-key=/code/id_rsa_kubespray"
        }
}

output "kube-node-vm_id" {
        value = "${opennebula_vm.kube-node.*.id}"
}

output "kube-node-vm_ip" {
        value = "${opennebula_vm.kube-node.*.ip}"
}


