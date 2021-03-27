#!/usr/bin/env bash
#
# os/ubuntu/user
#
# Set up a new sudo user.
#

# shellcheck source=../../lib/utils.sh
. "${DOTFILES_DIR}/lib/utils.sh"


# Execute a command as a certain user
#
# Arguments:
#   Account Username
#   Command to be executed
function user::exec () {
  local username=${1}
  local exec_command=${2}
  # @TODO can `execute`'s nice feedback be used here?
  sudo -u "${username}" -H bash -c "${exec_command}"
}

# Create the new user account.
# Arguments:
#   Account Username
#   Account Password
function user::create_account () {
  local username=${1}
  local password=${2}
  sudo adduser --disabled-password --gecos '' "${username}"
  echo "${username}:${password}" | sudo chpasswd
  sudo usermod -aG sudo "${username}"
}

# Keep prompting for the password and password confirmation.
# Globals:
#   PASSWORD
#   PASSWORD_CONFIRMATION
function user::prompt_for_password () {
  PASSWORDS_MATCH=0
  while [ "${PASSWORDS_MATCH}" -eq "0" ]; do
    ask_silently "Enter new UNIX password:"
    PASSWORD=$(get_answer)
    ask_silently "Retype new UNIX password:"
    PASSWORD_CONFIRMATION=$(get_answer)

    if [[ "${PASSWORD}" != "${PASSWORD_CONFIRMATION}" ]]; then
      echo "Passwords do not match! Please try again."
    else
      PASSWORDS_MATCH=1
    fi
  done
}

# Allow passwordless sudo for a user.
# Parameters:
#   Username
function user::allow_passwordless_sudo () {
  local username="${1}"
  sudo cp /etc/sudoers /etc/sudoers.bak
  sudo bash -c "echo '${1} ALL=(ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)"
}

# Get SSH authorized keys.
# Globals:
#   CDOM_INIT_PUBKEY
function user::get_ssh_pub_key() {
  local key
  if [[ -n "${CDOM_INIT_PUBKEY}" ]]; then
    key="${CDOM_INIT_PUBKEY}"
  else
    ask_for_confirmation "Use root's authorized SSH keys for ${USERNAME}?"
    if user_confirmed; then
      key=$(<"${HOME}/.ssh/authorized_keys")
    else
      ask 'Paste in the public SSH key for the new user:\n'
      key=$(get_answer)
    fi
  fi
  echo "$key"
}

# Add an SSH public key for a user.
# Parameters:
#   Username
#   SSH public key
function user::add_ssh_pub_key () {
  local username=${1}
  local pubkey=${2}

  user::exec "${username}" \
    "mkdir -p ~/.ssh; chmod 700 ~/.ssh; touch ~/.ssh/authorized_keys"
  user::exec "${username}" \
    "echo \"${pubkey}\" | sudo tee -a ~/.ssh/authorized_keys"
  user::exec "${username}" \
    "chmod 600 ~/.ssh/authorized_keys"
}

# Modify the sshd_config file.
function user::change_ssh_config () {
  # shellcheck disable=2116
  sudo sed -re \
    's/^(\#?)(PasswordAuthentication)([[:space:]]+)yes/\2\3no/' \
    -i."$(echo 'old')" \
    /etc/ssh/sshd_config
  sudo sed -re \
    's/^(\#?)(PermitRootLogin)([[:space:]]+)(.*)/PermitRootLogin no/' \
    -i /etc/ssh/sshd_config
}

# Install dotfiles for a user.
# Parameters:
#   Username
function user::install_dotfiles () {
  local username=$1
  user::exec "${username}" \
    "sudo cp -r /root/.dots ~/."
}

# Create and set up the new user.
# Globals:
#   USERNAME
function user::main () {
  if [[ "root" != $(whoami) ]]; then
    print_error "${FUNCNAME[0]} must be run as root! Aborting."
    return 1
  fi

  if [[ -n "${CDOM_INIT_NEW_USER_NAME}" ]]; then
    USERNAME="${CDOM_INIT_NEW_USER_NAME}"
  else
    ask "Enter the username of the new user account:"
    USERNAME=$(get_answer)
  fi
  readonly USERNAME


  if [[ -n "${CDOM_INIT_NEW_USER_PASSWORD}" ]]; then
    PASSWORD="${CDOM_INIT_NEW_USER_PASSWORD}"
  else
    user::prompt_for_password
  fi

  # Run setup functions
  trap .cleanup EXIT SIGHUP SIGINT SIGTERM

  user::create_account "${USERNAME}" "${PASSWORD}"

  user::allow_passwordless_sudo "${USERNAME}" \
    && user::add_ssh_pub_key \
        "${USERNAME}" \
        user::get_ssh_pub_key \
    && user::change_ssh_config
  print_result $? "Configure SSH"
}

user::main "$@"
