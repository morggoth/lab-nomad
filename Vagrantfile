BOX_IMAGE = 'ubuntu/bionic64'
NODE_COUNT = 2

Vagrant.configure('2') do |config|
  config.vm.define 'consul' do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.hostname = 'consul'
    subconfig.vm.network :private_network, ip: '10.0.0.10'
    subconfig.vm.network 'forwarded_port', guest: 80, host: 8080
    subconfig.vm.provider 'virtualbox' do |vb|
      vb.memory = '1024'
      vb.cpus = '1'
    end
    subconfig.vm.provision 'shell', inline: <<-SHELL
      set -x
      apt install -y \
          unzip \
          nginx
      # Install consul server
      wget https://releases.hashicorp.com/consul/1.5.2/consul_1.5.2_linux_amd64.zip
      unzip consul_1.5.2_linux_amd64.zip
      mv consul /usr/local/bin
      mkdir -p /etc/consul.d/bootstrap
      cp /vagrant/consul/config.json /etc/consul.d/bootstrap/config.json
      cp /vagrant/consul/consul.service /etc/systemd/system/consul.service
      systemctl daemon-reload
      systemctl enable consul
      systemctl start consul
      systemctl status consul

      # Install NGINX
      # consul:consul
      cp /vagrant/consul/htpasswd /etc/nginx/.htpasswd
      cp /vagrant/consul/consul-auth.conf /etc/nginx/sites-enabled/consul-auth.conf
      rm -rf /etc/nginx/sites-enabled/default
      systemctl reload nginx
    SHELL
  end
  (1..NODE_COUNT).each do |i|
    config.vm.define "nomad_node#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      subconfig.vm.hostname = "nomad-node#{i}"
      subconfig.vm.network :private_network, ip: "10.0.0.#{i + 10}"
      subconfig.vm.network 'forwarded_port', guest: 80, host: 8080 + i
      subconfig.vm.provider 'virtualbox' do |vb|
        vb.memory = '1024'
        vb.cpus = '1'
      end
      subconfig.vm.provision 'shell', inline: <<-SHELL
        set -x
        apt install -y \
            unzip \
            nginx
        # install consul agent
        wget https://releases.hashicorp.com/consul/1.5.2/consul_1.5.2_linux_amd64.zip
        unzip consul_1.5.2_linux_amd64.zip
        mv consul /usr/local/bin
        mkdir -p /etc/consul.d/client
        cp /vagrant/nomad/config.json /etc/consul.d/client/config.json
        sed -i "s/local_addr/10.0.0.#{i + 10}/" /etc/consul.d/client/config.json
        cp /vagrant/nomad/consul.service /etc/systemd/system/consul.service
        sed -i "s/local_addr/10.0.0.#{i + 10}/" /etc/systemd/system/consul.service
        systemctl daemon-reload
        systemctl enable consul
        systemctl start consul
        systemctl status consul

        # install nomad
        wget https://releases.hashicorp.com/nomad/0.9.3/nomad_0.9.3_linux_amd64.zip
        unzip nomad_0.9.3_linux_amd64.zip
        mv nomad /usr/local/bin/
        nomad -autocomplete-install
        complet -C /usr/local/bin/nomad nomad
        mkdir /etc/nomad.d
        chmod 700 /etc/nomad.d
        mkdir -p /opt/nomad
        cp /vagrant/nomad/nomad.service /etc/systemd/system/nomad.service
        sed -i "s/local_addr/10.0.0.#{i + 10}/" /etc/systemd/system/nomad.service
        cp /vagrant/nomad/{nomad.hcl,server.hcl} /etc/nomad.d/
        sed -i "s/local_addr/10.0.0.#{i + 10}/" /etc/nomad.d/server.hcl
        systemctl daemon-reload
        systemctl enable nomad
        systemctl start nomad
        systemctl status nomad

        # install NGINX
        # nomad:nomad
        cp /vagrant/nomad/htpasswd /etc/nginx/.htpasswd
        cp /vagrant/nomad/nomad-auth.conf /etc/nginx/sites-enabled/nomad-auth.conf
        sed -i "s/local_addr/10.0.0.#{i + 10}/" /etc/nginx/sites-enabled/nomad-auth.conf
        rm -rf /etc/nginx/sites-enabled/default
        systemctl reload nginx
      SHELL
    end
  end
end
