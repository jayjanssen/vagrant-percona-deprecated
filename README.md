# Vagrant + AWS + Percona Server

## AWS Setup

Need AWS setup with the following information in a file called ~/.aws_secrets:

```
access_key_id: YOUR_ACCESS_KEY
secret_access_key: THE_ASSOCIATED_SECRET_KEY
keypair_name: KEYPAIR_ID
keypair_path: PATH_TO_KEYPAIR_PEM
```

ALSO put your access and secret keys in environment variables in your .bashrc or similar (for packer):

```
	export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
	export AWS_SECRET_ACCESS_KEY=THE_ASSOCIATED_SECRET_KEY
```

# Software Requirements

* Vagrant 1.2+: http://vagrantup.com
* Packer 0.1.4+: http://packer.io
* Vagrant AWS Plugin: vagrant plugin install vagrant-aws


# Create your own AMI with an associated Vagrant box

```
cd packer
packer validate ubuntu.json
packer build ubuntu.json
vagrant box add ubuntu-aws-us-east packer__aws.box
cd ..
```

# Launch the box

```
vagrant up --provider=aws
vagrant ssh
```
