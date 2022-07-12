import os

if os.path.exists('./.terraform.lock.hcl'):
  os.remove('./.terraform.lock.hcl')

if os.path.exists('./terraform.tfstate'):
  os.remove('./terraform.tfstate')

if os.path.exists('./terraform.tfstate.backup'):
  os.remove('./terraform.tfstate.backup')

if os.path.exists('./ssh_key'):
  os.remove('./ssh_key')

if os.path.exists('./ssh_key.pub'):
  os.remove('./ssh_key.pub')